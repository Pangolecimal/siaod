package main

import (
	"errors"
	"fmt"
	"strings"
)

type Node struct {
	data  string
	left  *Node
	right *Node
}

func (n *Node) insert(data string) error {
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
	var helper func(n *Node, prefix string, SPC_num int, SPC_char string)

	helper = func(n *Node, prefix string, SPC_num int, SPC_char string) {
		if n == nil {
			return
		}
		fmt.Print(strings.Repeat(SPC_char, SPC_num*3) + prefix + n.data + "\n")
		if n.left != nil {
			helper(n.left, "L: ", SPC_num+1, SPC_char)
		}
		if n.right != nil {
			helper(n.right, "R: ", SPC_num+1, SPC_char)
		}
	}
	helper(n, "&: ", 0, " ")
}

func main() {
	tree := &Node{data: "d"}
	tree.insert("b")
	tree.insert("c")
	tree.insert("a")
	tree.insert("f")
	tree.insert("e")
	tree.insert("g")

	tree.print()
}
func print(args ...any) {
	fmt.Println(args...)
}
