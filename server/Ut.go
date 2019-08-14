package main

import (
	"math/rand"
)

func RandomNum(minNum int, maxNum int) int {
	if minNum == maxNum {
		return minNum
	}

	return rand.Intn(maxNum-minNum+1) + minNum
}
