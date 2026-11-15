# Scriptly - 628

Retro green/black Roblox developer testing hub.

## GitHub loader

After making this repository **public**, paste this one-line command into Xeno while in your own experience:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/shaboomboom43-creator/Scriptly/main/ScriptlyLoader.lua"))()
```

The loader downloads six client source fragments from `parts/`, joins them, compiles the complete client hub, and starts it. The UI no longer exits if `Scriptly628Remotes` is missing.

## Client tools

- Full-screen retro loading screen and Scriptly - 628 branding
- Flight, noclip, bunny hop, spin, local speed and jump tests
- Player ESP
- NPC-only ESP and aim test for NPCs tagged `ScriptlyTarget`
- Fullbright, FOV and flash test
- Local jumpscare, confetti and announcements
- Matrix Green, Toxic Lime, Cyber Teal, Amber Terminal and custom gradients
- RightShift toggles the UI

## Server tools (one-time Studio setup)

A client loadstring cannot install trusted server code. Install the bundled `ScriptlyServer.server.lua` as a normal Script in `ServerScriptService`. Install `ScriptlyEffects.client.lua` as a LocalScript in `StarterPlayer > StarterPlayerScripts` so all players can render server-wide effects.

The server automatically authorizes the creator only in user-owned experiences. For group-owned experiences, add your own numeric Roblox UserId to `DEVELOPER_IDS` in the server file.

Server actions include heal, respawn, teleport, freeze/unfreeze, ghost, ForceField, flop, global gravity, day/night, server-wide jumpscare/confetti and announcements.

## Important

- Use only in an experience you own or are authorised to test.
- Server commands are fixed and validated; arbitrary client-supplied Lua is never executed.
- Aim assistance is restricted to explicitly tagged NPC test dummies, not player characters.
- This repository must be public for anonymous `raw.githubusercontent.com` access. Do not put a GitHub token in the loader.
- Test in a private Studio server first; runtime behaviour has not been verified in your specific place.
