package hog

// LevelStats contains balance numbers for a specific level.
type LevelStats struct {
    Level            int
    Hitpoints        int
    DamagePerHit     int
    DamagePerSecond  int
}

// Levels maps level -> stats, matching the wiki table included by user.
var Levels = []LevelStats{
    {Level: 3, Hitpoints: 802, DamagePerHit: 150, DamagePerSecond: 93},
    {Level: 4, Hitpoints: 881, DamagePerHit: 164, DamagePerSecond: 102},
    {Level: 5, Hitpoints: 967, DamagePerHit: 181, DamagePerSecond: 113},
    {Level: 6, Hitpoints: 1060, DamagePerHit: 198, DamagePerSecond: 123},
    {Level: 7, Hitpoints: 1166, DamagePerHit: 218, DamagePerSecond: 136},
    {Level: 8, Hitpoints: 1279, DamagePerHit: 239, DamagePerSecond: 149},
    {Level: 9, Hitpoints: 1405, DamagePerHit: 262, DamagePerSecond: 163},
    {Level: 10, Hitpoints: 1544, DamagePerHit: 288, DamagePerSecond: 180},
    {Level: 11, Hitpoints: 1697, DamagePerHit: 317, DamagePerSecond: 198},
    {Level: 12, Hitpoints: 1863, DamagePerHit: 348, DamagePerSecond: 217},
    {Level: 13, Hitpoints: 2048, DamagePerHit: 383, DamagePerSecond: 239},
    {Level: 14, Hitpoints: 2247, DamagePerHit: 420, DamagePerSecond: 262},
    {Level: 15, Hitpoints: 2466, DamagePerHit: 461, DamagePerSecond: 288},
}

// GetLevel returns LevelStats for a given level or false if not found.
func GetLevel(level int) (LevelStats, bool) {
    for _, s := range Levels {
        if s.Level == level {
            return s, true
        }
    }
    return LevelStats{}, false
}

