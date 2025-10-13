package main

import (
	"flag"
	"fmt"
	"os"

	"cobbleguard/hog"
)

func main() {
    level := flag.Int("level", 11, "Hog Rider level (3-15)")
    towerHP := flag.Int("tower", 4000, "Target tower hitpoints")
    flag.Parse()

    ls, ok := hog.GetLevel(*level)
    if !ok {
        fmt.Fprintf(os.Stderr, "unknown level %d\n", *level)
        os.Exit(2)
    }

    hits := hog.HitsToDestroy(ls, *towerHP)
    t := hog.TimeToDestroySeconds(ls, *towerHP)

    fmt.Printf("%s L%d: %d HP, %d dmg/hit (%d dps)\n", hog.Base.Name, ls.Level, ls.Hitpoints, ls.DamagePerHit, ls.DamagePerSecond)
    fmt.Printf("Target %d HP -> %d hits, ~%.1fs (no walk)\n", *towerHP, hits, t)
}

