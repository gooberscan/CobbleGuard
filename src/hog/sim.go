package hog

import "math"

// Tower describes a generic building target with hitpoints.
type Tower struct {
    Name      string
    Hitpoints int
}

// HitsToDestroy returns the number of swings required to destroy the target.
func HitsToDestroy(level LevelStats, targetHP int) int {
    if level.DamagePerHit <= 0 {
        return math.MaxInt
    }
    n := int(math.Ceil(float64(targetHP) / float64(level.DamagePerHit)))
    if n < 0 {
        return math.MaxInt
    }
    return n
}

// TimeToDestroySeconds estimates time (first-hit + hits-1 intervals) ignoring walk.
func TimeToDestroySeconds(level LevelStats, targetHP int) float64 {
    hits := HitsToDestroy(level, targetHP)
    if hits == math.MaxInt {
        return math.Inf(1)
    }
    // First hit occurs after Base.FirstHitSeconds, subsequent (hits-1) spaced by HitSpeedSeconds.
    if hits <= 0 {
        return 0
    }
    return Base.FirstHitSeconds + float64(max(hits-1, 0))*Base.HitSpeedSeconds
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}

