package main
import "core:fmt"
import "core:strings"
import "core:math/rand"

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

	bit_sets: [dynamic]bit_set[0 ..< 12]
	defer delete(bit_sets)

	for i in 0 ..< len(bin) {
		b := bin[i]
		bs: bit_set[0 ..< 12]

		for j in 0 ..< cast(u8)8 {
			if b & (1 << j) >> j == 1 {
				bs += {cast(int)j}
			}
		}

		append(&bit_sets, bs)
	}


	result = make([]int, len(bit_sets) * 24)

	for bs, i in bit_sets {
		res, ok := encode_bitset(bs)

		if ok {
			for j in 0 ..< len(res) {
				result[i * 24 + j] = res[j]
			}
		} else {
			fmt.eprintln("ENCODING ERROR:", res, ok, bs)
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
	res := make([]u8, len(code) / 8) // 3 bytes per 24 bits

	uniques: [4096][24]int
	for i in 0 ..< 4096 {
		bs: bit_set[0 ..< 12]
		for j in 0 ..< cast(u8)12 {
			if i & (1 << j) >> j == 1 {
				bs += {cast(int)j}
			}
		}

		v, ok := encode_bitset(bs)
		for j in 0 ..< 24 {
			uniques[i][j] = v[j]
		}
	}

	for i := 0; i < len(code); i += 24 {
		bin := code[i:][:24]

		min_dist, min_idx, repeats := 999999, 999999, 1
		for j in 0 ..< 4096 {
			d, ok := distance(bin, uniques[j][:])
			if d < min_dist {
				min_dist, min_idx, repeats = d, j, 1
			} else if min_dist == d {
				repeats += 1
			}
		}
		if min_dist > 0 {
			fmt.println("TRANSMISSION ERROR:\n", " GOT:     ", bin)
		}
		if repeats == 1 {
			bin = uniques[min_idx][:]
			if min_dist > 0 {fmt.println("  EXPECTED:", bin)}
		} else {
			fmt.println("UNRECOVERABLE TRANSMISSION ERROR")
		}

		for j in 0 ..< 8 {
			res[i / 24] |= cast(u8)(1 & bin[0:8][j]) << cast(u8)j
		}
	}

	result = transmute(string)res
	return result, true
}

print_code :: proc(code: []int) {
	for i in 0 ..< len(code) {
		if i % 24 == 0 && i > 0 {fmt.println()}
		if i % 12 == 0 && i % 24 != 0 {fmt.print(" ")}

		fmt.printf("%b", code[i])
	}
	fmt.println()
}

main :: proc() {
	word := "lorem ipsum"
	fmt.printf("Encode: \"%s\"\n\nCode:\n", word)

	res1, ok1 := encode(word)
	print_code(res1)
	fmt.println()

	fmt.println("Transmitted Code:")

	swap: [24]int
	for i in 0 ..< 24 {swap[i] = i}
	rand.shuffle(swap[:])
	num_errors := 3
	for i in 0 ..< num_errors {
		idx := swap[i]
		res1[idx] = 1 - res1[idx]
		fmt.printf("  ADD TRANSMISSION ERROR: INDEX=%v, BIT=%v LINE=%v\n", idx, idx % 24, idx / 24)
	}

	fmt.println()
	print_code(res1)
	fmt.println()

	res2, ok2 := decode(res1)

	// fmt.println(res1, ok1)
	fmt.printf("\nDecode: \"%s\"\n", res2)
}
