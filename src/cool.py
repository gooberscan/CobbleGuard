
"""
This is intentionally tolerant (best-effort parsing) and safe (doesn't import external deps).
"""

import re
import math
import struct
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # workspace root (src/.. -> ..)
SRC = ROOT / "src"

def fast_inverse_sqrt(x: float) -> float:
    """Python reimplementation of the classic Quake 3 fast inverse sqrt
    matching 0x5f3759df magic used in app.ts and src/api.py."""
    if x == 0:
        return float("inf")
    threehalfs = 1.5
    packed = struct.pack("f", float(x))
    i = struct.unpack("I", packed)[0]
    i = 0x5f3759df - (i >> 1)
    packed_i = struct.pack("I", i)
    y = struct.unpack("f", packed_i)[0]
    # one Newton iteration
    y = y * (threehalfs - (0.5 * x * y * y))
    return y

def read_file(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return f"<unreadable: {e}>"

def extract_server_config_from_ts(ts_text: str):
    # naive object literal extractor for serverGrapefruit in src/app.ts
    m = re.search(r"const\s+serverGrapefruit\s*=\s*{([^}]+)};", ts_text, re.S)
    if not m:
        return {}
    body = m.group(1)
    pairs = re.findall(r"(\w+)\s*:\s*['\"]?([^,'\n]+)['\"]?", body)
    return {k.strip(): v.strip() for k, v in pairs}

def extract_confusedsiren_from_api(api_text: str):
    # parse confusedsiren56 dict from src/api.py
    m = re.search(r"confusedsiren56\s*=\s*{([^}]+)}", api_text, re.S)
    if not m:
        return {}
    body = m.group(1)
    pairs = re.findall(r"['\"]([^'\"]+)['\"]\s*:\s*['\"]?([^,'\n]+)['\"]?", body)
    return {k: v for k, v in pairs}

def parse_hog_levels(levels_text: str):
    # parse lines like {Level: 3, Hitpoints: 802, DamagePerHit: 150, DamagePerSecond: 93},
    entries = re.findall(r"\{([^}]+)\}", levels_text)
    levels = []
    for e in entries:
        # extract ints
        kv = {}
        for k, v in re.findall(r"(\w+)\s*:\s*([0-9]+)", e):
            kv[k] = int(v)
        if kv:
            levels.append(kv)
    return levels

def parse_base_stats(stats_text: str):
    # grab numeric first-hit and hit-speed from src/hog/stats.go
    fh = re.search(r"FirstHitSeconds:\s*([0-9.]+),", stats_text)
    hs = re.search(r"HitSpeedSeconds:\s*([0-9.]+),", stats_text)
    name = re.search(r'Name:\s*"([^"]+)"', stats_text)
    return {
        "Name": name.group(1) if name else "Hog Rider",
        "FirstHitSeconds": float(fh.group(1)) if fh else 0.6,
        "HitSpeedSeconds": float(hs.group(1)) if hs else 1.6,
    }

def hits_to_destroy(damage_per_hit: int, hp: int) -> int:
    if damage_per_hit <= 0:
        return math.inf
    return int(math.ceil(hp / damage_per_hit))

def time_to_destroy(first_hit: float, hit_speed: float, hits: int) -> float:
    if hits == math.inf:
        return float("inf")
    if hits <= 0:
        return 0.0
    return first_hit + float(max(hits - 1, 0)) * hit_speed

def make_report():
    # read files
    ts = read_file(SRC / "app.ts")
    api_py = read_file(SRC / "api.py")
    video_py = read_file(SRC / "video.py")
    levels_go = read_file(SRC / "hog" / "levels.go")
    stats_go = read_file(SRC / "hog" / "stats.go")
    sim_go = read_file(SRC / "hog" / "sim.go")
    bee_script = read_file(ROOT / "docs" / "bee movie script")
    zoomer_rs = read_file(ROOT / "best_language" / "zoomer.rs")
    zoomer_doc = read_file(ROOT / "docs" / "ongodnocapfr.zoomer")
    readme = read_file(ROOT / "README.md")
    pkg = read_file(ROOT / "package.json")

    server_cfg = extract_server_config_from_ts(ts)
    api_cfg = extract_confusedsiren_from_api(api_py)

    base = parse_base_stats(stats_go)
    levels = parse_hog_levels(levels_go)

    # compute a demonstration science value
    demo_seed = 42.42
    invsqrt = fast_inverse_sqrt(demo_seed)

    # pick a mid-level hog and compute time to destroy a 4000 HP tower as in cmd
    sample_level = levels[8] if len(levels) > 8 else (levels[0] if levels else {})
    sample_damage = sample_level.get("DamagePerHit", 317)
    sample_level_num = sample_level.get("Level", 11)

    hits = hits_to_destroy(sample_damage, 4000)
    ttd = time_to_destroy(base["FirstHitSeconds"], base["HitSpeedSeconds"], hits)

    narrative = (
        "In this tiny universe:\n"
        f"- The bot config from src/app.ts says host={server_cfg.get('coconut', api_cfg.get('coconut','<unknown>'))}\n"
        f"- The Broshan/fast-inverse-sqrt trick computes 1/sqrt({demo_seed}) ≈ {invsqrt:.6f}\n"
        f"- Hog Rider L{sample_level_num} does {sample_damage} dmg/hit -> {hits} hits vs 4000 HP, ~{ttd:.1f}s (no walk)\n"
        f"- The Bee Movie (docs/bee movie script) offers philosophical commentary:\n    \"{bee_script.splitlines()[0][:80]}...\"\n"
        f"- A tiny zoomer program lives in docs/ongodnocapfr.zoomer and a parser sketch lives in {ROOT/'best_language'/'zoomer.rs'}\n"
    )

    report = {
        "server_config_ts": server_cfg,
        "server_config_api": api_cfg,
        "fast_inverse_sqrt_demo": {"input": demo_seed, "result": invsqrt},
        "hog_sample": {
            "level": sample_level_num,
            "damage_per_hit": sample_damage,
            "hits_vs_4000": hits,
            "time_seconds": ttd,
        },
        "narrative": narrative,
        "files_examined": [
            "src/app.ts",
            "src/api.py",
            "src/video.py",
            "src/hog/levels.go",
            "src/hog/stats.go",
            "docs/bee movie script",
            "best_language/zoomer.rs",
            "docs/ongodnocapfr.zoomer",
            "package.json",
            "README.md",
        ],
    }

    out_txt = (ROOT / "workspace_unify_report.txt")
    out_json = (ROOT / "workspace_unify_report.json")
    out_txt.write_text(narrative + "\n\n(For details see JSON output)", encoding="utf-8")
    out_json.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report, out_txt, out_json

if __name__ == "__main__":
    report, tfile, jfile = make_report()
    print("Wrote narrative to", tfile)
    print("Wrote JSON report to", jfile)
    print("--- summary ---")
    print(report["narrative"])
# ...existing code...