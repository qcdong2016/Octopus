package main

import (
	"fmt"
	"math/rand"
)

func RandomNum(minNum int, maxNum int) int {
	if minNum == maxNum {
		return minNum
	}

	return rand.Intn(maxNum-minNum+1) + minNum
}

func RandAvatar(name string) string {
	v := []rune(name)
	return fmt.Sprintf("fonts:/#%x%x%x/#%x%x%x/%v",
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		string(v[0]),
	)
}
