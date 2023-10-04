#![allow(dead_code, unused_variables)]

use colored::Colorize;
use std::{
    io::{self, Write},
    ops::Deref,
};

fn main() -> io::Result<()> {
    //{{{

    // the PRIMARY command.
    let mut buffer_a = String::new();
    // the SECONDARY command.
    let mut buffer_b = String::new();
    let stdin = io::stdin();

    // the HASH TABLE of types: key=u32, value=String.
    let mut hash_table: HashTable<u32, String> = HashTable::new();

    // all supported commands.
    let commands = vec!["exit", "fill", "add", "remove", "print", "clear", "find"];

    // the main loop that is listening to commands.
    // every "print" statement uses the `colored` crate to add colors to the text.
    loop {
        println!();
        print!("{}", "Available commands: ".green().bold());
        // print out all of the commands
        commands.iter().for_each(|c| print!("{} ", c.blue().bold()));
        println!();
        // read the MAIN command into buffer_a
        read(
            &format!("{}", "Input the command: ".underline()),
            &mut buffer_a,
        )?;

        // prettify the MAIN command
        let cmd = buffer_a.as_str().trim();

        // check which command was given (before each block is the name of the command)
        // CMD: exit
        if cmd == commands[0] {
            println!("{}", "Finished Gracefully.".bold().green());
            break;

            // CMD: refill
        } else if cmd == commands[1] {
            println!("{}", "Filling the HashTable with 3 random values.".yellow());
            let add_result = hash_table.add_from_vec(gen_raw_data(3));

            match add_result {
                Err(HashError::Collision) => {
                    println!("{}", "Collision encountered, rehashing, try again.".red());
                    let _ = hash_table.handle_collision();
                }
                _ => {}
            }

            // CMD: add
        } else if cmd == commands[2] {
            // read the subcommand into buffer_b
            read(
                &format!(
                    "{}",
                    "  Input Data (pattern: \"123456 12 name\"): "
                        .italic()
                        .yellow()
                ),
                &mut buffer_b,
            )?;

            let (key, value): (&str, &str) = buffer_b.as_str().trim().split_once(' ').unwrap();
            let key: u32 = key.parse().unwrap();

            let add_result = hash_table.add(key, value.to_string());

            match add_result {
                Ok(_) => println!(
                    "{} {k:?}={v:?} {}",
                    "Added".green(),
                    "successfully".green(),
                    k = key,
                    v = value,
                ),
                Err(HashError::Collision) => {
                    println!("{}", "Collision encountered, rehashing, try again.".red());
                    hash_table.handle_collision().unwrap();
                }
                Err(e) => {
                    println!("{} {:?}", "Error: ".red(), e);
                }
            }

            // CMD: remove
        } else if cmd == commands[3] {
            // read the subcommand into buffer_b
            read(
                &format!(
                    "{}",
                    "  Input Key (pattern: \"123456\"): ".italic().yellow()
                ),
                &mut buffer_b,
            )?;

            let key: u32 = buffer_b.as_str().trim().parse().unwrap();

            hash_table.remove(key).unwrap();

            println!(
                "{} {k:?} {}",
                "Removed".green(),
                "successfully".green(),
                k = key
            );

            // CMD: print
        } else if cmd == commands[4] {
            println!("{} {:#?}", "HashTable:".yellow(), hash_table.entries);

            // CMD: clear
        } else if cmd == commands[5] {
            println!("{}", "Clearing the HashTable.".yellow());
            hash_table = HashTable::new();

            // CMD: find
        } else if cmd == commands[6] {
            read(
                &format!(
                    "{}",
                    "  Input Key (pattern: \"123456\"): ".italic().yellow()
                ),
                &mut buffer_b,
            )?;

            let key: u32 = buffer_b.as_str().trim().parse().unwrap();

            match hash_table.find(key) {
                Ok(found) => println!("{} {:?}", "Successfully found:".green(), found),
                Err(error) => println!("{} {:#?}", "Element not found, E:".red(), error),
            }

            // CMD: error
        } else {
            println!("{} {:?}", "E: unknown command:".red().bold(), buffer_a)
        }
    }

    Ok(())
} //}}}

#[derive(Debug)]
struct HashTable<K, V> {
    //{{{
    /// hash_key + (actual key + value)
    entries: Vec<(u32, K, V)>,

    hash_add: u32,
} //}}}

#[derive(Debug)]
enum HashError {
    //{{{
    Collision,
    AlreadyExists,
    DoesNotExist,
} //}}}

impl<K, V> HashTable<K, V>
where
    u32: From<<K as std::ops::Add<u32>>::Output>,
    K: Copy + PartialEq + Into<u32> + std::ops::Add<u32> + std::fmt::Debug,
    V: Clone + Deref + std::fmt::Debug,
{
    //{{{ 123456 12 abc
    const HASH_OFFSET: u32 = 7;

    fn new() -> Self {
        return Self {
            entries: Vec::with_capacity(8),
            hash_add: 0,
        };
    }

    fn add_from_vec(&mut self, in_vec: Vec<(K, V)>) -> Result<(), HashError> {
        for (key, value) in in_vec {
            self.add(key, value)?;
        }

        Ok(())
    }

    fn get_keys(&self) -> Vec<K> {
        self.entries.clone().iter().map(|e| e.1.clone()).collect()
    }

    fn get_hashes(&self) -> Vec<u32> {
        self.entries.clone().iter().map(|e| e.0).collect()
    }

    fn add(&mut self, key: K, value: V) -> Result<(), HashError> {
        if self.get_keys().contains(&key) {
            return Err(HashError::AlreadyExists);
        }

        let hashed = self.hash(key);
        if self.get_hashes().contains(&hashed) {
            println!(
                "prev: {:?}, next: {:?}",
                self.entries.iter().find(|e| e.0 == hashed),
                (key, value)
            );
            return Err(HashError::Collision);
        }

        self.check_and_increase_capacity()?;

        self.entries.push((hashed, key, value));

        Ok(())
    }

    fn remove(&mut self, key: K) -> Result<(), HashError> {
        let hashed = self.hash(key);

        if !self.get_hashes().contains(&hashed) {
            return Err(HashError::DoesNotExist);
        }

        // after making sure that the key is present
        let index = self.get_hashes().iter().position(|h| h == &hashed).unwrap();
        self.entries.swap_remove(index);

        Ok(())
    }

    fn check_and_increase_capacity(&mut self) -> Result<(), HashError> {
        if self.entries.len() as f32 / self.entries.capacity() as f32 > 0.75 {
            self.entries.reserve(self.entries.len() * 2);
            println!("Successfully increased capacity.");
        }
        Ok(())
    }

    fn find(&self, key: K) -> Result<V, HashError> {
        let hashed = self.hash(key);

        if !self.get_hashes().contains(&hashed) {
            return Err(HashError::DoesNotExist);
        }

        return Ok(self
            .entries
            .iter()
            .find(|e| e.0 == hashed && e.1 == key)
            .unwrap()
            .2
            .clone());
    }

    fn rehash(&mut self) -> Result<(), HashError> {
        let raw_kv: Vec<(K, V)> = self.entries.iter().map(|e| (e.1, e.2.clone())).collect();
        for key in self.get_keys() {
            self.remove(key)?;
        }

        for (key, value) in raw_kv {
            self.add(key, value)?;
        }

        Ok(())
    }

    fn handle_collision(&mut self) -> Result<(), HashError> {
        self.hash_add += HashTable::<K, V>::HASH_OFFSET;
        self.rehash()
    }

    fn hash<T: Into<u32>>(&self, input: T) -> u32 {
        return input.into() % self.entries.capacity() as u32 + self.hash_add;
    }
} //}}}

fn gen_raw_data(num: usize) -> Vec<(u32, String)> {
    //{{{
    let mut keys: Vec<u32> = vec![];
    for i in 0..num {
        // 6-digits number
        keys.push(100_000u32 + rand::random::<u32>() % 900_000u32);
    }

    let mut name_gen = names::Generator::default();
    let mut values: Vec<String> = vec![];
    for i in 0..num {
        // 2-digit number + ' ' + random name
        values.push((10 + rand::random::<u8>() % 90).to_string() + " " + &name_gen.next().unwrap());
    }

    let mut raw_table: Vec<(u32, String)> = vec![];
    for i in 0..num {
        raw_table.push((keys[i], values[i].clone()));
    }

    return raw_table;
} //}}}

fn hash_rng<T: Into<u32>>(input: T) -> u32 {
    //{{{
    let mut state: u32 = input.into();
    state ^= 2747636419;
    state = state.overflowing_mul(2654435769).0;
    state ^= state >> 16;
    state = state.overflowing_mul(2654435769).0;
    state ^= state >> 16;
    state = state.overflowing_mul(2654435769).0;
    return state;
} //}}}

fn read(msg: &str, buffer: &mut String) -> io::Result<()> {
    //{{{
    print!("{msg}");
    let _ = io::stdout().flush();

    buffer.clear();
    io::stdin().read_line(buffer)?;

    Ok(())
} //}}}
