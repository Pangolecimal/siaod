package main

import "time"

func task_2() {
	print("\n\nTask_2")
	var word = "dolor"
	test(lorem_min, word)
	test(lorem_mid, word)
	test(lorem_max, word)
}

func test(text string, word string) {
	print(" - Word:", word)
	// if len(text) < 256 {
	// 	print(" - Text:", text)
	// } else {
	print(" - Text (length):", len(text))
	// }

	start, end := time.Now().UnixNano(), time.Now().UnixNano()
	result, comparisons := make([]int, 0), 0

	print()

	start = time.Now().UnixNano()
	result, comparisons = find_simple(text, word)
	end = time.Now().UnixNano()
	print("   + simple (length):", len(result))
	print("   * time (ns):      ", end-start)
	print("   * comparisons:    ", comparisons)

	print()

	lps := compute_lps_array(word)
	start = time.Now().UnixNano()
	result, comparisons = find_kmp(text, word, lps)
	end = time.Now().UnixNano()
	print("   + kmp (length):   ", len(result))
	print("   * time (ns):      ", end-start)
	print("   * comparisons:    ", comparisons)

	print()
	print()
}

func find_simple(text string, word string) ([]int, int) {
	var entries []int
	C := 0 // comparisons

	// just a double nested for-loop
	for i := 0; i < len(text); i++ {
		C++
		for j := 0; j < len(word); j++ {
			C++
			// break the inner loop on first difference
			if text[i+j] != word[j] {
				C++
				break
			}
			// append the index, if checked the whole word
			if j == len(word)-1 {
				C++
				entries = append(entries, i)
			}
		}
	}

	return entries, C
}

func compute_lps_array(word string) []int {
	// initialize an empty (zeroed) integer array of size equal to the word
	lps := make([]int, len(word))
	j := 0

	for i := 1; i < len(word); {
		if word[i] == word[j] {
			j++
			lps[i] = j
			i++
		} else {
			if j != 0 {
				j = lps[j-1]
			} else {
				lps[i] = 0
				i++
			}
		}
	}

	return lps
}

func find_kmp(text string, word string, lps []int) ([]int, int) {
	var entries []int
	C := 0 // comparisons

	M := len(text)
	N := len(word)

	// i for the text, j for the word
	i, j := 0, 0

	for i < M {
		C++
		// the letters match
		if word[j] == text[i] {
			C++
			i++
			j++
		}

		// checked the whole word yet?
		if j == N {
			C++
			entries = append(entries, i-j)
			j = lps[j-1]
		} else if i < M && word[j] != text[i] {
			C++
			if j != 0 {
				j = lps[j-1]
			} else {
				i++
			}
		}
	}

	return entries, C
}
