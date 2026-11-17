# Six-Scriptly

**Six-Scriptly** is an installable Roblox Studio developer and anti-cheat QA panel. It has no personal-key prompt or client-side key lock.

## Installation

1. Open an experience you own or are explicitly authorised to test in Roblox Studio.
2. Add `Six-ScriptlyServer.server.lua` as a normal **Script** under `ServerScriptService`.
3. Add `Six-Scriptly.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
4. Add `Six-ScriptlyEffects.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
5. Publish and test in a private server first.

This is a Studio package, not a universal executor or loadstring. To use it in each of your studio's experiences, install the three scripts in that experience (or distribute them through your own trusted Studio package workflow).

## Access and warning behaviour

- The hub UI opens without asking for a personal key.
- The client checks the server controller. If it cannot verify that the current Roblox account is authorised, it still shows the panel in **read-only mode** and displays a usage warning.
- In a user-owned experience, the Roblox account matching `game.CreatorId` is authorised automatically.
- In a group-owned experience, add your numeric **Roblox UserId** to `DEVELOPER_IDS` in `Six-ScriptlyServer.server.lua`.
- The server independently checks permission for every gameplay-changing command and rate-limits requests. A warning is not treated as permission.
- Keep the server controller in `ServerScriptService`; never move it into `ReplicatedStorage` or `StarterPlayer`.

A secret stored in a Roblox LocalScript or client-side config cannot be guaranteed private. Six-Scriptly therefore does not use a client key as an access boundary.

## Included developer tools

- Owner-authorised movement and physics test controls
- Local lighting and camera test controls
- NPC target ESP and camera tests, restricted to models or parts tagged `SixScriptlyTarget`
- Server-authoritative heal, respawn, teleport, freeze, ghost, gravity and lighting controls
- Local/server notifications, confetti and UI effect tests
- Theme customisation and RightShift panel toggle

Player ESP has been removed. Visual highlighting is limited to explicitly tagged NPC test targets.

## Responsible use

Use Six-Scriptly only in experiences you own or have explicit permission to test. It does not inject into, bypass protections in, or grant permissions inside arbitrary Roblox experiences. The unauthorised/read-only notice is informational; server-side owner validation is the permission check for gameplay-changing actions.
