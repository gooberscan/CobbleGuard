package hog

// SpeedCategory enumerates CR-style speed descriptors.
type SpeedCategory string

const (
    SpeedVeryFast SpeedCategory = "Very Fast"
)

// CardStats captures immutable card definition values.
type CardStats struct {
    Name            string
    ElixirCost      int
    Rarity          string
    Type            string
    Arena           string
    ReleaseISODate  string // YYYY-MM-DD
    Target          string
    Transport       string
    RangeTiles      float64
    DeploySeconds   float64
    Speed           SpeedCategory
    FirstHitSeconds float64
    HitSpeedSeconds float64
}

// Base is the canonical, level-agnostic Hog Rider definition.
var Base = CardStats{
    Name:            "Hog Rider",
    ElixirCost:      4,
    Rarity:          "Rare",
    Type:            "Troop",
    Arena:           "Builder's Workshop",
    ReleaseISODate:  "2016-01-04",
    Target:          "Buildings",
    Transport:       "Ground",
    RangeTiles:      0.8,  // melee short
    DeploySeconds:   1.0,
    Speed:           SpeedVeryFast,
    FirstHitSeconds: 0.6,
    HitSpeedSeconds: 1.6,
}

