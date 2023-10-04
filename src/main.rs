#![allow(dead_code, unused_variables)]

use colored::Colorize;
use std::{
    io::{self, Write},
    ops::Deref,
};

fn main() -> io::Result<()> {
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
        println!(
            "{}{}",
            "Available commands: ".green().bold(),
            commands.join(", ").blue().bold()
        );

        // read the MAIN command into buffer_a
        read(
            &format!("{}", "Input the command: ".underline()),
            &mut buffer_a,
        )?;

        // prettify the MAIN command
        let cmd = buffer_a.trim();

        // check which command was given (before each block is the name of the command)
        if cmd == commands[0] {
            // NOTE CMD: exit

            println!("{}", "Finished Gracefully.".bold().green());
            break;
        } else if cmd == commands[1] {
            // NOTE CMD: fill

            // read the subcommand into buffer_b
            read(
                &format!("{}", "  Input Number of random entries: ".italic().yellow()),
                &mut buffer_b,
            )?;

            let n = buffer_b.trim().parse::<u32>().unwrap();

            println!(
                "{} {} {}",
                "Filling the HashTable with".yellow(),
                n,
                "random values.".yellow()
            );
            let add_data = gen_random_data(n as usize);

            for entry in add_data {
                let add_result = hash_table.add(entry.0, entry.1);
                match add_result {
                    Ok(()) => println!("{}", "Added Successfully".green()),
                    Err(HashError::Collision) => {
                        println!("{}", "Collision encountered, rehashing, try again.".red());
                        let _ = hash_table.rehash();
                    }
                    Err(e) => println!("what???: {:?}", e),
                }
            }
        } else if cmd == commands[2] {
            // NOTE CMD: add

            // read the subcommand into buffer_b
            read(
                &format!(
                    "{}",
                    "  Input Data (pattern: \"123456 name\"): "
                        .italic()
                        .yellow()
                ),
                &mut buffer_b,
            )?;

            let (key, value): (&str, &str) = buffer_b.trim().split_once(' ').unwrap();
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
                    hash_table.rehash().unwrap();
                }
                Err(e) => {
                    println!("{} {:?}", "Error: ".red(), e);
                }
            }
        } else if cmd == commands[3] {
            // NOTE CMD: remove

            // read the subcommand into buffer_b
            read(
                &format!(
                    "{}",
                    "  Input Key (pattern: \"123456\"): ".italic().yellow()
                ),
                &mut buffer_b,
            )?;

            let key: u32 = buffer_b.trim().parse().unwrap();

            hash_table.remove(key).unwrap();

            println!(
                "{} {k:?} {}",
                "Removed".green(),
                "successfully".green(),
                k = key
            );
        } else if cmd == commands[4] {
            // NOTE CMD: print

            println!(
                "{} {:#?} {}",
                "HashTable:".yellow(),
                hash_table,
                hash_table.entries.len()
            );
        } else if cmd == commands[5] {
            // NOTE CMD: clear
            println!("{}", "Clearing the HashTable.".yellow());

            hash_table = HashTable::new();
        } else if cmd == commands[6] {
            // NOTE CMD: find

            read(
                &format!(
                    "{}",
                    "  Input Key (pattern: \"123456\"): ".italic().yellow()
                ),
                &mut buffer_b,
            )?;

            let key: u32 = buffer_b.trim().parse().unwrap();

            match hash_table.find(key) {
                Ok(found) => println!("{} {:#?}", "Successfully found:".green(), found),
                Err(error) => println!("{} {:#?}", "Element not found, E:".red(), error),
            }
        } else {
            // NOTE CMD: error

            println!("{} {:?}", "E: unknown command:".red().bold(), buffer_a)
        }
    }

    Ok(())
}

/// Hash(u32) + Key(K) + Value(V)
#[derive(Debug, Clone, PartialEq)]
struct HashEntry<K, V> {
    hash: u32,
    key: K,
    value: V,
}

impl<K, V> HashEntry<K, V> {
    fn new(hash: u32, key: K, value: V) -> Self {
        Self { hash, key, value }
    }
}

#[derive(Debug)]
struct HashTable<K, V> {
    entries: Vec<HashEntry<K, V>>,
    hash_cap: u32,
    hash_add: u32,
}

#[derive(Debug)]
enum HashError {
    Collision,
    AlreadyExists,
    DoesNotExist,
}

impl<K, V> HashTable<K, V>
where
    u32: From<<K as std::ops::Add<u32>>::Output>,
    K: Copy + PartialEq + Into<u32> + std::ops::Add<u32> + std::fmt::Debug,
    V: Clone + PartialEq + Deref + std::fmt::Debug,
{
    const HASH_OFFSET: u32 = 3;

    fn new() -> Self {
        let cap = 16;
        return Self {
            entries: Vec::with_capacity(cap),
            hash_add: 0,
            hash_cap: cap as u32,
        };
    }

    fn get_hashes(&self) -> Vec<u32> {
        self.entries.clone().iter().map(|e| e.hash).collect()
    }

    fn get_keys(&self) -> Vec<K> {
        self.entries.clone().iter().map(|e| e.key.clone()).collect()
    }

    fn add(&mut self, key: K, value: V) -> Result<(), HashError> {
        // if self.get_keys().contains(&key) {
        //     return Err(HashError::AlreadyExists);
        // }

        let hashed = self.hash(key);
        let collided = self.get_hashes().contains(&hashed);

        // add anyway
        self.entries.push(HashEntry::new(hashed, key, value));
        let _ = self.check_and_increase_capacity();

        // HACK
        self.entries
            .sort_by(|a, b| a.hash.partial_cmp(&b.hash).unwrap());

        // if collision occured, return an error
        if collided {
            Err(HashError::Collision)
        } else {
            Ok(())
        }
    }

    // does not care if the queried key is in the collisions or normal entries.
    fn remove(&mut self, key: K) -> Result<(), HashError> {
        let hashed = self.hash(key);

        if !self.get_hashes().contains(&hashed) {
            return Err(HashError::DoesNotExist);
        }

        // the possible amount of hits
        let possibilities = self.entries.iter().filter(|e| e.hash == hashed);

        match possibilities.clone().count() {
            n if n == 1 => {
                // after making sure that the key is present
                let index = self.get_hashes().iter().position(|h| h == &hashed).unwrap();
                self.entries.swap_remove(index);
            }
            n if n > 1 => {
                // try to find it
                let maybe = possibilities.clone().find(|e| e.key == key);

                // if it exists:
                if let Some(entry) = maybe {
                    let index = self.get_hashes().iter().position(|h| h == &hashed).unwrap();
                    self.entries.swap_remove(index);
                }
            }
            _ => unreachable!(),
        }

        Ok(())
    }

    fn check_and_increase_capacity(&mut self) -> Result<(), HashError> {
        if self.entries.len() as f32 / self.entries.capacity() as f32 >= 0.75 {
            self.entries.reserve(self.entries.capacity());
            self.hash_cap = self.entries.capacity() as u32;
            println!("Successfully increased capacity.");
        }
        Ok(())
    }

    fn find(&self, key: K) -> Result<HashEntry<K, V>, HashError> {
        let hashed = self.hash(key);

        if !self.get_hashes().contains(&hashed) {
            return Err(HashError::DoesNotExist);
        }

        // the possible amount of hits
        let possibilities = self.entries.iter().filter(|e| e.hash == hashed);

        match possibilities.clone().count() {
            n if n == 1 => {
                // after making sure that the key is present
                return Ok(possibilities.collect::<Vec<&HashEntry<K, V>>>()[0].clone());
            }
            n if n > 1 => {
                // try to find it
                let maybe = possibilities.clone().find(|e| e.key == key);

                // if it exists:
                if let Some(entry) = maybe {
                    return Ok(entry.clone());
                }
            }
            _ => unreachable!(),
        }

        unreachable!();
    }

    fn rehash(&mut self) -> Result<(), HashError> {
        // get the entries
        let entries_temp = self.entries.clone();

        // remove them
        for key in self.get_keys() {
            self.remove(key)?;
        }

        // set new hash offset
        self.hash_add += Self::HASH_OFFSET;

        // readd them
        for he in entries_temp {
            self.add(he.key, he.value)?;
        }

        Ok(())
    }

    fn hash<T: Into<u32>>(&self, input: T) -> u32 {
        // `hash_prng` is better overall, but for showing the collissions the `A mod B` is better.
        // return hash_prng(input.into() + self.hash_add);
        return (input.into() + self.hash_add) % self.hash_cap as u32;
    }
}

fn gen_random_data(num: usize) -> Vec<(u32, String)> {
    let mut keys: Vec<u32> = vec![];
    for i in 0..num {
        // 6-digits number
        keys.push(100_000u32 + rand::random::<u32>() % 900_000u32);
    }

    let mut name_gen = names::Generator::default();
    let mut values: Vec<String> = vec![];
    for i in 0..num {
        // random name
        values.push(name_gen.next().unwrap());
    }

    let mut raw_table: Vec<(u32, String)> = vec![];
    for i in 0..num {
        raw_table.push((keys[i], values[i].clone()));
    }

    return raw_table;
}

/// actually good hashing function (technically a PRNG function) that is operating on 32 bits.
fn hash_prng<T: Into<u32>>(input: T) -> u32 {
    let mut state: u32 = input.into();
    state ^= 2747636419;
    state = state.overflowing_mul(2654435769).0;
    state ^= state >> 16;
    state = state.overflowing_mul(2654435769).0;
    state ^= state >> 16;
    state = state.overflowing_mul(2654435769).0;
    return state;
}

fn read(msg: &str, buffer: &mut String) -> io::Result<()> {
    print!("{msg}");
    let _ = io::stdout().flush();

    buffer.clear();
    io::stdin().read_line(buffer)?;

    Ok(())
}
