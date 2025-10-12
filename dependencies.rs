use rand::Rng;
use std::fs::File;
use std::io::{self, Write};
use std::thread;
use std::sync::{Arc, Mutex};
use std::time::Duration;

#[derive(Debug)]
struct MathResult {
    sum: i32,
    product: i32,
    difference: i32,
    quotient: Option<f32>,
}

impl MathResult {
    fn new(a: i32, b: i32) -> Self {
        let sum = a + b;
        let product = a * b;
        let difference = a - b;
        let quotient = if b != 0 { Some(a as f32 / b as f32) } else { None };
        MathResult {
            sum,
            product,
            difference,
            quotient,
        }
    }
}

fn generate_random_numbers() -> (i32, i32) {
    let mut rng = rand::thread_rng();
    let num1 = rng.gen_range(1..101); // Random number between 1 and 100
    let num2 = rng.gen_range(1..101); // Random number between 1 and 100
    (num1, num2)
}

fn perform_math_operations(a: i32, b: i32) -> MathResult {
    MathResult::new(a, b)
}

fn write_results_to_file(results: Arc<Mutex<Vec<String>>>) {
    let file_name = "results.txt";
    let file = File::create(file_name);
    match file {
        Ok(mut f) => {
            let results = results.lock().unwrap();
            for result in results.iter() {
                if let Err(e) = writeln!(f, "{}", result) {
                    eprintln!("Failed to write to file: {}", e);
                }
            }
        }
        Err(e) => eprintln!("Error creating file: {}", e),
    }
}

fn main() {
    let num_threads = 10;
    let results = Arc::new(Mutex::new(Vec::new()));

    let mut handles = vec![];

    for _ in 0..num_threads {
        let results = Arc::clone(&results);
        let handle = thread::spawn(move || {
            let (a, b) = generate_random_numbers();
            let math_result = perform_math_operations(a, b);

            let result_string = format!(
                "For numbers {} and {}: Sum = {}, Product = {}, Difference = {}, Quotient = {:?}",
                a, b, math_result.sum, math_result.product, math_result.difference, math_result.quotient
            );

            let mut results = results.lock().unwrap();
            results.push(result_string);

            thread::sleep(Duration::from_secs(1)); // Simulate some delay
        });
        handles.push(handle);
    }

    // Wait for all threads to finish
    for handle in handles {
        handle.join().unwrap();
    }

    // After all threads finish, write results to file
    write_results_to_file(results);
    println!("Results have been written to 'results.txt'");
}
