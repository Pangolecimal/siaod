package main
import "core:fmt"

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
        1  2  3  4  5  6  7  8  9 10 11 12 -- A  B  C  D  E  F  G  H  I  J  K  L
        |  |  |  |  |  |  |  |  |  |  |  |    |  |  |  |  |  |  |  |  |  |  |  |
1  A -- 1  0  0  0  0  0  0  0  0  0  0  0 -- 1  0  1  1  0  0  1  1  1  0  0  1
2  B -- 0  1  0  0  0  0  0  0  0  0  0  0 -- 0  1  0  1  1  0  0  1  1  1  0  1
3  C -- 0  0  1  0  0  0  0  0  0  0  0  0 -- 1  0  1  0  1  1  0  0  1  1  0  1
4  D -- 0  0  0  1  0  0  0  0  0  0  0  0 -- 1  1  0  1  0  1  1  0  0  1  0  1
5  E -- 0  0  0  0  1  0  0  0  0  0  0  0 -- 0  1  1  0  1  1  1  1  0  0  0  1
6  F -- 0  0  0  0  0  1  0  0  0  0  0  0 -- 0  0  1  1  1  1  0  1  1  0  1  0
7  G -- 0  0  0  0  0  0  1  0  0  0  0  0 -- 1  0  0  1  1  0  1  0  1  1  1  0
8  H -- 0  0  0  0  0  0  0  1  0  0  0  0 -- 1  1  0  0  1  1  0  1  0  1  1  0
9  I -- 0  0  0  0  0  0  0  0  1  0  0  0 -- 1  1  1  0  0  1  1  0  1  0  1  0
10 J -- 0  0  0  0  0  0  0  0  0  1  0  0 -- 0  1  1  1  0  0  1  1  0  1  1  0
11 K -- 0  0  0  0  0  0  0  0  0  0  1  0 -- 0  0  0  0  0  1  1  1  1  1  1  1
12 L -- 0  0  0  0  0  0  0  0  0  0  0  1 -- 1  1  1  1  1  0  0  0  0  0  1  1

        ^^^  LEFT = INFORMATION BASIS  ^^^    ^^^  RIGHT = CORRECTION BASIS  ^^^
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
		return []int{}, false
	}

	result = make([]int, len(word1))

	for i in 0 ..< len(word1) {result[i] = word1[i] ~ word2[i]}
	return result, true
}

product :: proc(word1, word2: []int) -> (result: []int, ok: bool) {
	if len(word1) != len(word2) {
		return []int{}, false
	}

	result = make([]int, len(word1))

	for i in 0 ..< len(word1) {result[i] = word1[i] & word2[i]}
	return result, true
}

main :: proc() {
	word1 := BASIS[0][12:]
	word2 := BASIS[1][12:]

	fmt.println(word1, weight(word1))
	fmt.println(word2, weight(word2))
	fmt.println()
	word, _ := sum(word1, word2)
	fmt.println(word, weight(word))
	fmt.println()
	word, _ = product(word1, word2)
	fmt.println(word, weight(word))
}
