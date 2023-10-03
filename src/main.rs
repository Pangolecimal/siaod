#![allow(dead_code, unused_variables)]

use std::io::{self, Write};

fn main() -> io::Result<()> {
    //{{{
    // let raw_data = gen_raw_data(10);
    // println!("{:#?}", raw_data);

    // let foo = HashTable::from_vec(gen_raw_data(4));
    // println!("{:#?}", foo);

    let mut buffer_a = String::new();
    let mut buffer_b = String::new();
    let stdin = io::stdin();

    let mut hash_table: HashTable<u32, String> = HashTable::new();

    let commands = vec!["exit", "fill", "add", "remove", "print", "clear"];
    println!("Available commands: {:?}", commands);

    loop {
        println!();
        read("Input the command: ", &mut buffer_a)?;

        let cmd = buffer_a.as_str().trim();

        // NOTE exit
        if cmd == commands[0] {
            println!("Finished Gracefully.");
            break;
            //
            // NOTE refill
        } else if cmd == commands[1] {
            println!("Filling the HashTable with 4 random values.");
            hash_table.add_from_vec(gen_raw_data(4)).unwrap();
            //
            // NOTE add
        } else if cmd == commands[2] {
            read(
                "  Input Data (pattern: \"123456 12 name\"): ",
                &mut buffer_b,
            )?;

            let (key, value): (&str, &str) = buffer_b.as_str().trim().split_once(' ').unwrap();
            let key: u32 = key.parse().unwrap();

            hash_table.add(key, value.to_string()).unwrap();

            println!("Added {:?}={:?} successfully", key, value);
            //
            // NOTE remove
        } else if cmd == commands[3] {
            read("  Input Key (pattern: \"123456\"): ", &mut buffer_b)?;

            let key: u32 = buffer_b.as_str().trim().parse().unwrap();

            hash_table.remove(key).unwrap();

            println!("Removed {:?} successfully", key);
            //
            // NOTE print
        } else if cmd == commands[4] {
            println!("HashTable: {:#?}", hash_table.entries);
            //
            // NOTE clear
        } else if cmd == commands[5] {
            println!("Clearing the HashTable.");
            hash_table = HashTable::new();
            //
            // error
        } else {
            println!("E: unknown command: {:?}", buffer_a);
        }
    }

    Ok(())
} //}}}

#[derive(Debug)]
struct HashTable<K, V> {
    //{{{
    /// hash_key + (actual key + value)
    entries: Vec<(u32, (K, V))>,

    hash_add: u32,
} //}}}

#[derive(Debug)]
enum HashError {
    //{{{
    Collision,
    AlreadyExists,
    DoesNotExist,
} //}}}

impl<K, V: Clone> HashTable<K, V>
where
    u32: From<<K as std::ops::Add<u32>>::Output>,
    K: Copy + PartialEq + Into<u32> + std::ops::Add<u32> + std::fmt::Debug,
{
    //{{{ 123456 12 abc

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
        self.entries
            .clone()
            .iter()
            .map(|e| e.1 .0.clone())
            .collect()
    }

    fn get_hashes(&self) -> Vec<u32> {
        self.entries.clone().iter().map(|e| e.0).collect()
    }

    fn add(&mut self, key: K, value: V) -> Result<(), HashError> {
        if self.get_keys().contains(&key) {
            return Err(HashError::AlreadyExists);
        }

        let hashed = hash(key + self.hash_add);
        if self.get_hashes().contains(&hashed) {
            return Err(HashError::Collision);
        }

        self.check_and_increase_capacity()?;

        self.entries.push((hashed, (key, value)));

        Ok(())
    }

    fn remove(&mut self, key: K) -> Result<(), HashError> {
        let hashed = hash(key + self.hash_add);

        if !self.get_hashes().contains(&hashed) {
            return Err(HashError::DoesNotExist);
        }

        // after making sure that the key is present
        let index = self.get_hashes().iter().position(|h| h == &hashed).unwrap();
        self.entries.swap_remove(index);

        Ok(())
    }

    fn rehash(&mut self) -> Result<(), HashError> {
        let raw_kv: Vec<(K, V)> = self.entries.iter().map(|e| e.1.clone()).collect();
        for key in self.get_keys() {
            self.remove(key)?;
        }

        self.hash_add += 7;
        for (key, value) in raw_kv {
            self.add(key, value)?;
        }

        Ok(())
    }

    fn check_and_increase_capacity(&mut self) -> Result<(), HashError> {
        if self.entries.len() as f32 / self.entries.capacity() as f32 > 0.75 {
            self.entries.reserve(self.entries.len() * 2);
            self.rehash()?;
            println!("Successfully increased capacity and rehashed.");
        }
        Ok(())
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

fn hash<T: Into<u32>>(input: T) -> u32 {
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
