# Centaura

Modular Roblox Lua script for **RENRENHUB CENTAURA**. Entry point is `main.lua`, which wires all modules through a shared context.

## Modules

- **Combat / AutoKill / Targeting**: targeting scan/kill, auto-kill, sekarat mode, fire-rate limiting
- **Aim**: auto-aim, FOV, smoothness, aim part selection
- **ESP**: player names, HP, distance
- **Medic**: heal/teleport helper with humanized timing
- **Armor**: armor detection and armor damage
- **UI**: window, tabs, widgets, number inputs
- **Loops**: render, heartbeat, task loops
- **Services / State / Rate / Config / Log**: shared infrastructure

## Configuration

Edit `config.lua` to change:
- UI tabs and title
- combat, aim, ESP, medic, and armor options
- derived runtime values

## Usage

Load `main.lua` as the script entry point in your Roblox executor/environment. It initializes logging, services, config, state, and all feature modules, then applies the configured options.

## Loadstring (copy-paste)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/rendays666/centaura/main/Centaura.lua"))()
```

Single-file bundle of all modules + entry point. Use this for executors.

Raw `main.lua` only (requires sibling modules in the same folder):
`https://raw.githubusercontent.com/rendays666/centaura/main/main.lua`
