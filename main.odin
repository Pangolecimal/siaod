package main

import "core:fmt"

main :: proc() {
	x: u8 = 255
	fmt.println(foo(x))
}

foo :: proc(n: byte) -> byte {
	return n + 1
}
