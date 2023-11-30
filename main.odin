package main
import "core:fmt"
import "core:strings"

BASIS := [12][24]int{
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1},
	{0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1},
	{0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1},
	{0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1},
	{0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1},
}

BASIS_STR := `
    1 2 3 4 5 6 7 8 9 a b c   A B C D E F G H I J K L

1   1 . . . . . . . . . . .   1 . 1 1 . . 1 1 1 . . 1
2   . 1 . . . . . . . . . .   . 1 . 1 1 . . 1 1 1 . 1
3   . . 1 . . . . . . . . .   1 . 1 . 1 1 . . 1 1 . 1
4   . . . 1 . . . . . . . .   1 1 . 1 . 1 1 . . 1 . 1
5   . . . . 1 . . . . . . .   . 1 1 . 1 1 1 1 . . . 1
6   . . . . . 1 . . . . . .   . . 1 1 1 1 . 1 1 . 1 .
7   . . . . . . 1 . . . . .   1 . . 1 1 . 1 . 1 1 1 .
8   . . . . . . . 1 . . . .   1 1 . . 1 1 . 1 . 1 1 .
9   . . . . . . . . 1 . . .   1 1 1 . . 1 1 . 1 . 1 .
a   . . . . . . . . . 1 . .   . 1 1 1 . . 1 1 . 1 1 .
b   . . . . . . . . . . 1 .   . . . . . 1 1 1 1 1 1 1
c   . . . . . . . . . . . 1   1 1 1 1 1 . . . . . 1 1
    │                     │   │                     │
    ╰──INFORMATION BASIS──╯   ╰──CORRECTION BASIS───╯
[. means 0]

ANY COMBINATION OF BASIS CODES HAS A WEIGHT OF:
    0 (#1 ~0%),  8 (#759 ~18%),  12 (#2576 ~63%),  16 (#759 ~18%),  24 (#1 ~0%)
[weight (#number-of-occurences ~percentage-of-occurences%)]

0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
1  .  .  .  .  .  .  .  2  .  .  .  3  .  .  .  4  .  .  .  .  .  .  .  5
1  1  1  1  .  2  2  2  2  2  .  3  3  3  .  4  4  4  4  4  .  5  5  5  5
`

weight :: proc(word: []int) -> int {
	sum := 0
	for bit in word {
		sum += bit
	}
	return sum
}

sum :: proc(word1, word2: []int) -> (result: []int, ok: bool) {
	if len(word1) != len(word2) {
		return result, false
	}

	result = make([]int, len(word1))

	for i in 0 ..< len(word1) {result[i] = word1[i] ~ word2[i]}
	return result, true
}

product :: proc(word1, word2: []int) -> (result: []int, ok: bool) {
	if len(word1) != len(word2) {
		return result, false
	}

	result = make([]int, len(word1))

	for i in 0 ..< len(word1) {result[i] = word1[i] & word2[i]}
	return result, true
}

distance :: proc(word1, word2: []int) -> (result: int, ok: bool) {
	if len(word1) != len(word2) {
		return -1, false
	}

	for i in 0 ..< len(word1) {
		if word1[i] != word2[i] {
			result += 1
		}
	}

	return result, true
}

encode_bitset :: proc(bs: bit_set[0 ..< 12]) -> (result: []int, ok: bool) {
	result = make([]int, 24)

	for i in 0 ..< 12 {
		if i in bs {
			result, ok = sum(result, BASIS[i][:])
			if !ok {
				return result, false
			}
		}
	}
	return result, true
}

encode_string :: proc(word: string) -> (result: []int, ok: bool) {
	if len(word) == 0 {
		return result, false
	}

	bin := strings.clone(word)
	spaces := (3 - len(bin) % 3) % 3
	bin = strings.concatenate({strings.repeat(" ", spaces), bin})

	bs: [dynamic]bit_set[0 ..< 12]
	defer delete(bs)

	for i in 0 ..< len(bin) - 2 {
		b := strings.concatenate({bin[i:i + 3]})
		// fmt.println(
		// 	strings.right_justify(fmt.tprintf("%b", b[0]), 8, "0"),
		// 	strings.right_justify(fmt.tprintf("%b", b[1]), 8, "0"),
		// 	strings.right_justify(fmt.tprintf("%b", b[2]), 8, "0"),
		// )
		bs01: bit_set[0 ..< 12]
		bs12: bit_set[0 ..< 12]

		for j in 0 ..< cast(u8)8 {
			if b[0] & (1 << j) >> j == 1 {
				bs01 += {cast(int)j}
			}
			if b[1] & (1 << j) >> j == 1 {
				if j < 4 {
					bs01 += {cast(int)j + 8}
				}
				if j >= 4 {
					bs12 += {cast(int)j}
				}
			}
			if b[2] & (1 << j) >> j == 1 {
				bs12 += {cast(int)j + 4}
			}
		}

		append(&bs, bs01)
		append(&bs, bs12)
	}


	result = make([]int, len(bs) * 24)

	for b, i in bs {
		res, ok := encode_bitset(b)

		if ok {
			for j in 0 ..< len(res) {
				result[i * 24 + j] = res[j]
			}
		} else {
			fmt.eprintln("ERROR:", res, ok, b)
		}
	}

	return result, true
}

encode :: proc {
	encode_string,
	encode_bitset,
}

decode :: proc(code: []int) -> (result: string, ok: bool) {
	if len(code) == 0 || len(code) % 24 != 0 {
		return result, false
	}

	for i := 0; i < len(code); i += 24 {
		bin := code[i:i + 24]

		w := weight(bin)
		if w != 0 && w != 8 && w != 12 && w != 16 && w != 24 {
			fmt.eprintln("TRANSMISSION ERROR")
		}
	}

	return result, true
}

main :: proc() {
	// word := "lorem ipsum"
	//
	// res1, ok1 := encode(word)
	// // for i in 0 ..< len(res) {
	// // 	if i % 24 == 0 {fmt.println()}
	// // 	if i % 12 == 0 && i % 24 != 0 {fmt.print(" ")}
	// //
	// // 	fmt.printf("%b", res[i])
	// // }
	// // fmt.println()
	//
	// res2, ok2 := decode(res1)
	//
	// // fmt.println(res1, ok1)
	// fmt.println(res2, ok2)

	for i in 0 ..< 4096 {
		for j in 0 ..< 12 {

		}
	}

}
