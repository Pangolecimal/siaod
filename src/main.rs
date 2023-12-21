#![allow(
    dead_code,
    unused_variables,
    unreachable_patterns,
    irrefutable_let_patterns
)]

use anyhow::Result;
use std::{
    fmt,
    io::{self, Write},
};

fn main() {
    let int = Integral::new(0., 1., Function::Polynomial(vec![1., 2., 1.]));
    println!("f = {}", int.f);
    println!("f'= {}", int.f.derivate());
    println!("F = {}", int.f.integrate());

    println!("\n{:?}", int);
    println!("{:.6}", int.eval_exact());
}

#[derive(Debug, PartialEq, Clone)]
enum Function {
    /// vec[i] * x ^ i
    Polynomial(Vec<f64>),
}

impl Function {
    fn eval_at(&self, x: f64) -> f64 {
        if let Function::Polynomial(coefficients) = self {
            let mut result = 0f64;
            for (i, c) in coefficients.iter().enumerate() {
                result += c * x.powf(i as f64);
            }
            result
        } else {
            unreachable!();
        }
    }

    fn derivate(&self) -> Function {
        let mut new_coefficients = vec![];
        if let Function::Polynomial(coefficients) = self {
            for i in 1..coefficients.len() {
                new_coefficients.push(i as f64 * coefficients[i]);
            }
            Function::Polynomial(new_coefficients)
        } else {
            unreachable!()
        }
    }

    fn integrate(&self) -> Function {
        let mut new_coefficients = vec![];
        if let Function::Polynomial(coefficients) = self {
            new_coefficients.push(0.);
            for i in 0..coefficients.len() {
                new_coefficients.push(coefficients[i] / (i + 1) as f64);
            }
            Function::Polynomial(new_coefficients)
        } else {
            unreachable!()
        }
    }
}

impl fmt::Display for Function {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut result: Vec<String> = vec![];

        match self {
            Function::Polynomial(coefficients) => {
                if coefficients.len() == 0 {
                    return write!(f, "Function: f(x) = 0");
                }

                for (i, c) in coefficients.iter().enumerate() {
                    let mut res = String::new();

                    if i == 0 || i > 0 && c != &1. {
                        if c % 1. > 0. {
                            res += &format!("{:.3}", c);
                        } else {
                            res += &format!("{}", c);
                        }
                    }

                    if i > 0 {
                        if i == 1 {
                            res += "x";
                        } else {
                            res += &format!("x^{}", i);
                        }
                    }

                    result.push(res);
                    if i < coefficients.len() - 1 {
                        result.push(String::from(" + "));
                    }
                }
            }
            _ => unreachable!(),
        }

        result.reverse();
        write!(f, "f(x) = {}", result.join(""))
    }
}

#[derive(Debug, PartialEq, Clone)]
struct Integral {
    bounds: (f64, f64),
    f: Function,
}

impl Integral {
    fn new(lower_bound: f64, upper_bound: f64, f: Function) -> Self {
        Integral {
            bounds: (lower_bound.into(), upper_bound.into()),
            f,
        }
    }

    fn eval_exact(&self) -> f64 {
        let int = self.f.integrate();
        int.eval_at(self.bounds.1) - int.eval_at(self.bounds.0)
    }
}

fn get_input(prompt: &str, line: &mut String) {
    print!("{}", prompt);
    let _ = io::stdout().flush();

    io::stdin()
        .read_line(line)
        .expect("Error reading from STDIN");
}

fn get_input_number(prompt: &str) -> Result<f32> {
    let mut input = String::new();
    get_input(prompt, &mut input);
    Ok(input.trim().parse::<f32>()?)
}

/*

let n = 4
h = (b - a) / n
\int_a^b f(x) dx = h * ( (f a + f b)/2 + \sum_{k=1}^n f(x_k) )

*/
