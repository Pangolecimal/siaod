#![allow(
    dead_code,
    unused_variables,
    unreachable_patterns,
    irrefutable_let_patterns
)]

use rand;
use std::fmt;

fn main() {
    let low_bound: f64 = rand::random();
    let up_bound: f64 = rand::random();
    let num_c: i32 = rand::random::<u16>() as i32 % 5 + 3;
    let mut cs: Vec<f64> = vec![];
    for i in 0..num_c {
        cs.push(rand::random::<f64>());
    }

    let int = Integral::new(low_bound, up_bound, Function::Polynomial(cs));
    println!("f = {}", int.f);
    // println!("f'= {}", int.f.derivate());
    // println!("F = {}", int.f.integrate());

    // println!("\n{:?}", int);
    println!("\ntrue value: {:?}", int.eval_exact());

    let mut c = 0;
    let p = 1e-2;
    println!("\napprox value (d. p.): {:.6}", int.eval_brute(p, &mut c));
    println!("compare count: {c}");

    c = 0;
    println!("\napprox value (brute): {:.6}", int.eval_dp(p, &mut c));
    println!("compare count: {c}");
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

    fn eval_trap(&self, n: i32) -> f64 {
        let h: f64 = (self.bounds.1 - self.bounds.0) / n as f64;
        let fafb = self.f.eval_at(self.bounds.0) + self.f.eval_at(self.bounds.1);
        let mut result = fafb / 2.;
        for i in 1..n {
            result += self.f.eval_at(i as f64 * h + self.bounds.0);
        }
        result * h
    }

    fn eval_brute(&self, precision: f64, c: &mut i32) -> f64 {
        let true_value = self.eval_exact();
        let mut n = 1;
        let mut approx_value: f64;

        loop {
            approx_value = self.eval_trap(n);
            *c += n;

            let error = (1. - approx_value / true_value).abs();
            if error < precision {
                break;
            } else {
                n *= 2;
            }
        }

        approx_value
    }

    fn eval_trap_hm(&self, hm: &mut Vec<(f64, f64)>, c: &mut i32, n: i32, fafb: f64) -> f64 {
        let h: f64 = (self.bounds.1 - self.bounds.0) / n as f64;

        let mut result = fafb / 2.;
        for i in 1..n {
            let x = i as f64 * h + self.bounds.0;
            for j in 0..hm.len() {
                if hm[j].0 == x {
                    result += hm[j].1;
                    break;
                }
                if j == hm.len() - 1 {
                    let y = self.f.eval_at(x);
                    hm.push((x, y));
                    result += y;
                    *c += 1;
                    break;
                }
            }
        }
        result * h
    }

    fn eval_dp(&self, precision: f64, c: &mut i32) -> f64 {
        let true_value = self.eval_exact();
        let mut hm: Vec<(f64, f64)> = vec![(0., self.f.eval_at(0.))];
        let mut approx_value: f64;
        let mut n = 1;

        // calculate fa + fb
        let mut fafb = 0f64;
        for i in 0..hm.len() {
            if hm[i].0 == self.bounds.0 {
                fafb += hm[i].1;
                break;
            }
            if i == hm.len() - 1 {
                let v = self.f.eval_at(self.bounds.0);
                hm.push((self.bounds.0, v));

                fafb += v;
                *c += 1;
                break;
            }

            if hm[i].0 == self.bounds.1 {
                fafb += hm[i].1;
                break;
            }
            if i == hm.len() - 1 {
                let v = self.f.eval_at(self.bounds.1);
                hm.push((self.bounds.1, v));
                fafb += v;
                *c += 1;
                break;
            }
        }

        loop {
            approx_value = self.eval_trap_hm(&mut hm, c, n, fafb);

            let error = (1. - approx_value / true_value).abs();
            if error < precision {
                break;
            } else {
                n *= 2;
            }
        }

        approx_value
    }
}

// fn get_input(prompt: &str, line: &mut String) {
//     print!("{}", prompt);
//     let _ = io::stdout().flush();
//
//     io::stdin()
//         .read_line(line)
//         .expect("Error reading from STDIN");
// }
//
// fn get_input_number(prompt: &str) -> Result<f32> {
//     let mut input = String::new();
//     get_input(prompt, &mut input);
//     Ok(input.trim().parse::<f32>()?)
// }
