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

## Notes

- Keep module changes small and test in-game.
- Some features are game-specific and may need adjustment per map/version.
