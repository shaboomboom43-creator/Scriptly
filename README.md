# Six-Scriptly

**Six-Scriptly** is an owner-authorised Roblox Studio testing panel. Install it only into experiences you own or are explicitly authorised to test.

## Installation

1. Open your experience in Roblox Studio.
2. Add `Six-ScriptlyServer.server.lua` as a normal **Script** under `ServerScriptService`.
3. Add `Six-Scriptly.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
4. Add `Six-ScriptlyEffects.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
5. Publish and test in a private server first.

Six-Scriptly checks server-side authorisation before showing the console. This Studio package has no executor entry point, no loadstring loader and no arbitrary client-supplied Lua execution.

## Owner-only access

- In a user-owned experience, only the Roblox account matching `game.CreatorId` is authorised automatically.
- In a group-owned experience, add your numeric **Roblox UserId** to `DEVELOPER_IDS` in `Six-ScriptlyServer.server.lua`.
- The server re-checks access for every command and rate-limits requests.
- Keep the server controller in `ServerScriptService`; never move it into `ReplicatedStorage` or `StarterPlayer`.

A secret stored in a Roblox LocalScript or client-side config cannot be guaranteed private: client code and values can be inspected or copied. Six-Scriptly uses Roblox account identity and a server-side allowlist rather than pretending a client key is device-bound. This restricts use to the authorised Roblox account, but does not prove that account is being used on one physical device only.

## Included developer tools

- Owner-only movement and physics test controls
- Local lighting and camera test controls
- NPC target ESP and camera tests, restricted to models or parts tagged `SixScriptlyTarget`
- Server-authoritative heal, respawn, teleport, freeze, ghost, gravity and lighting controls
- Local/server notifications, confetti and UI effect tests
- Theme customisation and RightShift panel toggle

Player ESP has been removed. Visual highlighting is limited to explicitly tagged NPC test targets.

## Responsible use

Use Six-Scriptly only in experiences you own or have explicit permission to test. Using exploit tools in another creator's experience may violate their rules and can result in account moderation or bans. The in-game warning is informational; server-side owner validation is the actual access control.

## Repository visibility

The repository was public when this update was prepared. These changes remove executor/loadstring launchers, but source in a public repository remains viewable. Change the repository visibility to **Private** in GitHub repository settings to keep the source private. Do not store a private key, password or API token in client source.
