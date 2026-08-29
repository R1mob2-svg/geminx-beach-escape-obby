# 🌴 GeminX Caribbean Beach Escape Obby

A **colorful Caribbean beach survival escape** Roblox Obby built as a real,
testable **Rojo project** (`Luau` source, filesystem <-> Roblox Studio sync).

> This is a GeminX template artifact for the Roblox Creator target. It uses only
> original code and Roblox primitives/services — no trademark/brand cloning, no
> ripped assets.

## 🏝️ The Story
You wash up on a tropical island overrun by villains. Fight your way down a
colorful beach obstacle course past **killer crabs**, dodge the **giant octopus**
tentacles, outrun **pirates**, grab **coins**, hit **checkpoints**, and finally
board the **rescue boat** to escape.

## 🎮 Gameplay mechanics
| Mechanic | Where |
|---|---|
| Obby obstacle course (spinning platforms, traps, bridge gaps) | ServeRenderingService map |
| **Killer crabs** patrolling the beach (touch = damage) | `Src/Servers/Crabs` |
| **Giant octopus** tentacle slam + spawn shockwave | `Src/Servers/Octopus` |
| **Pirates** patrolling/walking that capture you (`Cornered` minigame) | `Src/Servers/Pirates` |
| **Rescue boat** final objective → win sequence | `Src/Servers/RescueBoat` |
| Checkpoints | `Checkpoint` instances |
| Coins / score | `Coins` folder + leaderstats |
| Respawn + spawn-selection | `RespawnHandler` |
| Leaderboard (leaderstats.score/time) | `Src/Servers/Leaderboard` |
| Loudout HUD (health, timer, coins, current objective) | `Src/Client/HUD` |
| Replicated state (finish order callbacks) | `Src/Shared` via RemoteEvents |

## 🧱 Project layout (Rojo convention)
```
default.project.json   # Rojo project contract (syncs src/ -> Roblox services)
selene.toml            # Luau linter config
stylua.toml            # Luau formatter config
LICENSE                # MIT
src/
  ServerScriptService/
  ServerStorage/
  ReplicatedStorage/
  StarterPlayer/StarterPlayerScripts/
tests/                 # headless Node harness that runs the shared Luau logic
```

## ✅ Verification law
This project is **MECHANICAL_VERIFICATION_GREEN** where the automated tests run.
It is **NOT PUBLISHED** and (without a connected Roblox Studio MCP runtime)
Studio playtest remains the honest next step, not claimed as done.

To open in Studio:
1. `rojo build --output build.rbxlx` (or use the Rojo VS Code plugin)
2. Open the produced place file in Roblox Studio and Hit Play.

## 🔧 How to test (headless)
```bash
npm install
npm test   # runs the mechanical proof suite over shared Luau game logic
npm run lint   # selene-style checks (see scripts)
```

## Run with Rojo (sync to Studio)
```bash
rojo serve     # connect Rojo VS Code plugin, or
rojo build --output build.rbxlx   # produce a standalone place file
```
