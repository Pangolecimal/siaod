package main

import (
	"bufio"
	"errors"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Node struct {
	data  int
	left  *Node
	right *Node
}

// create a function `insert` invokable on Node pointer
//
// func	(call_on) name(args) return_type
func (n *Node) insert(data int) error {
	if n == nil {
		return errors.New("given Node n is nil")
	}
	if n.data == data {
		return errors.New("data already exists")
	}

	if data < n.data {
		if n.left == nil {
			n.left = &Node{data: data}
		} else {
			return n.left.insert(data)
		}
	} else {
		if n.right == nil {
			n.right = &Node{data: data}
		} else {
			return n.right.insert(data)
		}
	}

	return nil
}

func (n *Node) print() {
	if n == nil {
		println("E: Empty Tree")
		return
	}

	// literally a helper function that does all the work with recursion
	//
	// 'red'==name, 'yellow'==type ;;
	// 'red, red' 'yellow' == 'red' 'yellow', 'red' 'yellow'
	var helper func(n *Node, infix, prefix, indent string, last bool)
	helper = func(n *Node, infix, prefix, indent string, last bool) {
		if n == nil {
			return
		}

		println(indent+prefix+infix, n.data)
		if last {
			indent += "   "
		} else {
			indent += "│  "
		}

		if n.left != nil {
			var TEMP string
			if n.right == nil {
				TEMP = "╰"
			} else {
				TEMP = "├"
			}
			helper(n.left, "L:", TEMP+"──", indent, false)
		}
		if n.right != nil {
			helper(n.right, "R:", "╰──", indent, true)
		}
	}
	helper(n, "&:", "╰──", "", true)
	println()
}

// in-order==симметрично ;; post-order==обратно
func (n *Node) print_in_order(order_type string) {
	var helper func(n *Node, ot string) // ot==order_type
	helper = func(n *Node, ot string) {
		if n == nil {
			return
		}
		switch order_type {
		case "in-order": // left -> root -> right
			helper(n.left, ot)
			print(n.data, " ")
			helper(n.right, ot)
		case "post-order": // left -> right -> root
			helper(n.left, ot)
			helper(n.right, ot)
			print(n.data, " ")
		default:
			println("Incorrect order_type:", order_type)
		}
	}
	print("S -> ")
	helper(n, order_type)
	println("-> E (" + order_type + ")")
}

// get distance to `data` from `root`
func (n *Node) get_level_of(data int) int {
	if n.data == data {
		return 0
	}
	if n.left == nil && n.right == nil {
		return -1
	}

	if n.left != nil {
		got := n.left.get_level_of(data)
		if got >= 0 {
			return got + 1
		}
	}

	if n.right != nil {
		got := n.right.get_level_of(data)
		if got >= 0 {
			return got + 1
		}
	}

	return -1
}

// height of the tree
func (n *Node) get_height() int {
	if n == nil {
		return 0
	}
	if n.left == nil && n.right == nil {
		return 1
	}
	return max(n.left.get_height()+1, n.right.get_height()+1)
}

func main() {
	println("COMMAND HINT: name[?FULL NAME] (number of arguments)")
	println()
	println("exit (0), mk[make-default] (0), mkc[make-custom] (n),\n cl[clear] (0), ins[insert] (1), print (0), order[print-order] (1),\n level[level-of] (1), height (0)")
	println()

	var cmd, args string
	var tree *Node
	scanner := bufio.NewScanner(os.Stdin)

loop:

	for {
		print("Input command:\n>> ")
		scanner.Scan()
		cmd = scanner.Text()

		switch cmd {
		case "exit":
			break loop

		case "mk":
			tree = make_default_tree()
			println("  Default tree made.")
			tree.print()

		case "mkc":
			print("  Input data entries (numbers) in insertion order:\n  >> ")
			scanner.Scan()
			args = scanner.Text()
			for i, num := range strings.Fields(args) {
				value, err := strconv.Atoi(num)
				if err != nil {
					println("    Invalid data entry:", num)
					continue
				}
				if i == 0 {
					tree = &Node{data: value}
				} else {
					tree.insert(value)
				}
			}
			tree.print()

		case "cl": // clear
			tree = nil
			println("  Tree cleared.")

		case "ins": // insert
			print("  Input data entry (number):\n  >> ")
			scanner.Scan()
			args = scanner.Text()
			for _, num := range strings.Fields(args) {
				value, err := strconv.Atoi(num)
				if err != nil {
					println("    Invalid data entry:", num)
					continue
				}
				if tree == nil {
					tree = &Node{data: value}
				} else {
					tree.insert(value)
				}
			}
			tree.print()

		case "print":
			tree.print()

		case "order": // print-order
			print("  Input the order ('in' or 'post'):\n  >> ")
			scanner.Scan()
			args = scanner.Text()
			print("  ")
			tree.print_in_order(args + "-order")

		case "level": // level-of
			print("  Input the number to look for:\n  >> ")
			scanner.Scan()
			args = scanner.Text()
			value, err := strconv.Atoi(args)
			if err != nil {
				println("E:    Invalid data entry:", args)
				continue
			}
			println("  Height to {"+args+"}:", tree.get_level_of(value))

		case "height":
			println("  Height of the tree is:", tree.get_height())

		default:
			println("  Not a command ¯\\_(ツ)_/¯:", cmd)
		}
		println()
	}

	println("\n (⌐■_■) program finished gracefully (◠‿◠)")
}

func make_default_tree() *Node {
	tree := &Node{data: 7}
	tree.insert(3)
	tree.insert(11)
	tree.insert(1)
	tree.insert(5)
	tree.insert(9)
	tree.insert(13)
	tree.insert(0)
	tree.insert(2)
	tree.insert(4)
	tree.insert(6)
	tree.insert(8)
	tree.insert(10)
	tree.insert(12)
	tree.insert(14)

	return tree
}

func println(args ...any) {
	fmt.Println(args...)
}
func print(args ...any) {
	fmt.Print(args...)
}
func max(a, b int) int {
	return int(math.Max(float64(a), float64(b)))
}
