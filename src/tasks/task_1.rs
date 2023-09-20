use std::{
    fs::{self, read_to_string, OpenOptions},
    io::BufWriter,
    io::Write,
};

// use heapsize::HeapSizeOf;
use jemalloc_ctl::{epoch, stats};
use rand::prelude::*;

#[global_allocator]
static ALLOC: jemallocator::Jemalloc = jemallocator::Jemalloc;

pub fn main() {
    t1a();
    t1b();
    t1c();

    t2a();
    t2b();
    t2c();

    create_numbers_file();
    fill_numbers_file();
    t3a_loud();
    t3b();
}

fn t1a() {
    println!();
    println!("task 1.a:   [ y = x & mask ]");

    let x: u8 = 255; // 8-digit binary number = 0b1111_1111
    let mask: u8 = 1 << 4; // = 0b0001_0000
    let y: u8 = x & (!mask); // = 239

    println!("    x: {:#010b}, mask: {:#010b}, y: {:#010b}", x, mask, y);
    println!("    x: {:>10}, mask: {:>10}, y: {:>10}", x, mask, y);
}

fn t1b() {
    println!();
    println!("task 1.b:   [ y = x | mask ]");

    let x: u8 = 141; // random binary number
    let mask: u8 = 1 << 6; // = 0b0100_0000
    let y: u8 = x | mask; // = 205

    println!("    x: {:#010b}, mask: {:#010b}, y: {:#010b}", x, mask, y);
    println!("    x: {:>10}, mask: {:>10}, y: {:>10}", x, mask, y);
}

fn t1c() {
    println!();
    println!("task 1.c:");

    let x: u32 = 25; // some 32 bit binary number
    let n: i32 = 32; // size of u32 (bits)
    let mut mask: u32 = 1 << (n - 1); // = 2^33-1
    println!("    x:    {:#034b}", x);
    println!("    mask: {:#032b}", mask);

    print!("    y:    0b");
    for i in 1..=n {
        let y = (x & mask) >> (n - i); // takes `i` bits of x
        print!("{y}");
        mask = mask >> 1;
    }

    // ther program copies the value of `x` into `y` bit by bit, starting from the left
    println!();
}

fn t2a() {
    println!();
    println!("task 2.a:");

    // generate random array of [3, 8] 8-bit numbers
    let mut rng = rand::thread_rng(); // Random Number Generator
    let n: u8 = 3 + (rand::random::<u8>() % 6);
    let mut arr: Vec<u8> = (0..8).collect();
    arr.shuffle(&mut rng);
    let arr = &arr[0..n as usize];
    println!("    arr: {:?}", arr);

    // generate the bit array
    let mut bit_arr: u8 = 0;
    for i in arr {
        bit_arr |= 1 << i;
    }
    println!("    bit_arr: {:#08b}", bit_arr);

    // generate the sorted array based on the bit array
    let mut sort_arr: Vec<u8> = vec![0; n as usize];
    let mut j = 0;
    for i in 0..8 {
        if bit_arr & (1 << i) != 0 {
            sort_arr[j] = i;
            j += 1;
        }
    }
    println!("    sort_arr: {:?}", sort_arr);
}

fn t2b() {
    println!();
    println!("task 2.b:");

    // generate random array of [4..64] 8-bit numbers
    let mut rng = rand::thread_rng(); // Random Number Generator
    let n: u8 = 4 + (rand::random::<u8>() % 61);
    let mut arr: Vec<u8> = (0..64).collect();
    arr.shuffle(&mut rng);
    let arr = &arr[0..n as usize];
    println!("    arr: {:?}", arr);

    // generate the bit array
    let mut bit_arr: u64 = 0;
    for i in arr {
        bit_arr |= 1 << i;
    }
    println!("    bit_arr: {:#064b}", bit_arr);

    // generate the sorted array based on the bit array
    let mut sort_arr: Vec<u8> = vec![0; n as usize];
    let mut j = 0;
    for i in 0..64 {
        if bit_arr & (1 << i) != 0 {
            sort_arr[j] = i;
            j += 1;
        }
    }
    println!("    sort_arr: {:?}", sort_arr);
}

fn t2c() {
    println!();
    println!("task 2.c:");

    // generate random array of [4..64] 8-bit numbers
    let mut rng = rand::thread_rng(); // Random Number Generator
    let n: u8 = 4 + (rand::random::<u8>() % 61);
    let mut arr: Vec<u8> = (0..64).collect();
    arr.shuffle(&mut rng);
    let arr = &arr[0..n as usize];
    println!("    arr: {:?}", arr);

    // generate the bit array
    let mut bit_arr: Vec<bool> = vec![false; 64];
    for i in arr {
        bit_arr[*i as usize] = true;
    }
    println!("    bit_arr: {:?}", bit_arr);

    // generate the sorted array based on the bit array
    let mut sort_arr: Vec<u8> = vec![0; n as usize];
    let mut j = 0;
    for i in 0..64 {
        if bit_arr[i as usize] {
            sort_arr[j] = i;
            j += 1;
        }
    }
    println!("    sort_arr: {:?}", sort_arr);
}

fn create_numbers_file() {
    println!();
    println!("creation of the `number` files");

    println!("    creating the `random` file");
    fs::write("./numbers_random.txt", "").unwrap();

    println!("    creating the `sorted` file");
    fs::write("./numbers_sorted.txt", "").unwrap();
}

fn fill_numbers_file() {
    println!();
    println!("filling of the `random` file");
    println!("    generating random numbers");
    // generate shuffled array of all 32-bit numbers in the range [0..10_000_000]
    let mut rng = rand::thread_rng(); // Random Number Generator
    let n: u32 = 1_000_000 + (rand::random::<u32>() % 9_000_000);
    let mut arr: Vec<String> = (0..10_000_000).map(|n| n.to_string()).collect();
    arr.shuffle(&mut rng);
    let arr = &arr[0..n as usize].join("\n");

    println!("    writing to the `random` file");
    // write the array to the `numbers_random.txt` file
    fs::write("./numbers_random.txt", arr).unwrap();
}

fn t3a_silent() {
    // create a bit vector to store the occurrences of the numbers
    let mut bit_arr: Vec<bool> = vec![false; 10_000_000];

    // read the file
    for line in read_to_string("numbers_random.txt").unwrap().lines() {
        let n = line.parse::<usize>().unwrap();
        bit_arr[n] = true;
    }

    // write to the sorted file
    let file = OpenOptions::new()
        .write(true)
        .append(true)
        .open("./numbers_sorted.txt")
        .expect("unable to open file");
    let mut file = BufWriter::new(file);
    for i in 0..10_000_000 {
        if bit_arr[i] {
            writeln!(file, "{}", i).expect("unable to write");
        }
    }
}

fn t3a_loud() {
    println!();
    println!("task 3.a:");

    // create a bit vector to store the occurrences of the numbers
    println!("    creating the bit array");

    let mut bit_arr: Vec<bool> = vec![false; 10_000_000];

    // read the file
    println!("    reading the `random` file into bit array");

    for line in read_to_string("numbers_random.txt").unwrap().lines() {
        let n = line.parse::<usize>().unwrap();
        bit_arr[n] = true;
    }

    // write to the sorted file
    println!("    writing the sorted file");

    let file = OpenOptions::new()
        .write(true)
        .append(true)
        .open("./numbers_sorted.txt")
        .expect("unable to open file");
    let mut file = BufWriter::new(file);
    for i in 0..10_000_000 {
        if bit_arr[i] {
            writeln!(file, "{}", i).expect("unable to write");
        }
    }

    println!("    finished gracefully.");
}

fn t3a_memory() {
    let e = epoch::mib().unwrap();
    let allocated = stats::allocated::mib().unwrap();

    let mem_pre = allocated.read().unwrap();

    // create a bit vector to store the occurrences of the numbers
    let mut bit_arr: Vec<bool> = vec![false; 10_000_000];

    // read the file
    for line in read_to_string("numbers_random.txt").unwrap().lines() {
        let n = line.parse::<usize>().unwrap();
        bit_arr[n] = true;
    }

    // write to the sorted file
    let file = OpenOptions::new()
        .write(true)
        .append(true)
        .open("./numbers_sorted.txt")
        .expect("unable to open file");
    let mut file = BufWriter::new(file);
    for i in 0..10_000_000 {
        if bit_arr[i] {
            writeln!(file, "{}", i).expect("unable to write");
        }
    }

    e.advance().unwrap();
    let mem_post = allocated.read().unwrap();

    println!(
        "    (in bytes) mem_pre: {}, mem_post: {}, diff: {}",
        mem_pre,
        mem_post,
        mem_post - mem_pre
    );
}

fn t3b() {
    println!();
    println!("task 3.b:");

    // benchmark time
    fs::write("./numbers_sorted.txt", "").unwrap(); // clear the `sorted` file
    println!("    ...benchmarking time");
    benchmarking::warm_up();
    let bench_result = benchmarking::bench_function(|measurer| {
        measurer.measure(|| t3a_silent());
    })
    .unwrap();
    println!("    Time spent: {:?}", bench_result.elapsed());

    // benchmark memory usage
    fs::write("./numbers_sorted.txt", "").unwrap(); // clear the `sorted` file
    println!("    ...benchmarking memory usage");
    t3a_memory();
}
