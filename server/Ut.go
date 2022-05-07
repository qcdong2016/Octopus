package main

import (
	"fmt"
	"math/rand"
)

func RandomNum(minNum int64, maxNum int64) int64 {
	if minNum == maxNum {
		return minNum
	}

	return rand.Int63n(maxNum-minNum+1) + minNum
}

func RandAvatar(name string) string {
	v := []rune(name)
	return fmt.Sprintf("fonts:/#%x%x%x/#%x%x%x/%v",
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		string(v[0]),
	)
}
