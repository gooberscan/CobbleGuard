package main

import (
	"fmt"
	"time"
)

// Entry point prints a short Hog Rider summary as a placeholder.
func main() {
    fmt.Println("HOG RIDER!")
    fmt.Println("Fast melee troop that targets buildings and can jump the river.")
    fmt.Printf("Release: %s\n", time.Date(2016, time.January, 4, 0, 0, 0, 0, time.UTC).Format("2006-01-02"))
}
