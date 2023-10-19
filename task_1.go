package main

import "strings"

func task_1() {
	print("\n\nTask_1")

	text := lorem_min
	word := strings.Split(text, " ")[len(strings.Split(text, " "))-1]

    print(" * Text:", text)
    print(" * Word:", word)

	eq := find_eq(word, text)
	print(" - Equal: ", eq)

	bt := find_bt(word, text)
	print(" - Bigger:", bt)

	lt := find_lt(word, text)
	print(" - Lesser:", lt)
}

func find_eq(word, text string) []int {
    // split the `text` on <space>s to get words
	words := strings.Split(text, " ")

	var entries []int

    // enumerate words -> (index, word)
	for i, a_word := range words {
		if a_word == word {
			entries = append(entries, i)
		}
	}

	return entries
}

func find_bt(word, text string) []int {
    // split the `text` on <space>s to get words
	words := strings.Split(text, " ")

	var entries []int

    // enumerate words -> (index, word)
	for i, a_word := range words {
		if len(a_word) > len(word) {
			entries = append(entries, i)
		}
	}

	return entries
}

func find_lt(word, text string) []int {
    // split the `text` on <space>s to get words
	words := strings.Split(text, " ")

	var entries []int

    // enumerate words -> (index, word)
	for i, a_word := range words {
		if len(a_word) < len(word) {
			entries = append(entries, i)
		}
	}

	return entries
}
