package main

import (
	"fmt"
	"os"
	"regexp"
)

func main() {
	content, err := os.ReadFile("CHANGELOG.md")
	if err != nil {
		fmt.Print("v0.0.0")
		return
	}

	re := regexp.MustCompile(`v[0-9].*`)
	match := re.FindString(string(content))
	if match != "" {
		fmt.Print(match)
	} else {
		fmt.Print("v0.0.0")
	}
}
