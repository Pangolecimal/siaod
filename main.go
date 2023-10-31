package main

import (
	"errors"
	"fmt"
)

type Node struct {
	data  int
	left  *Node
	right *Node
}

func (n *Node) insert(data int) error {
	if n != nil {
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
  if n == nil {}
}

func main() {
	fmt.Println("Hello, World!")
}
