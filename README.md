# Six-Scriptly

**Six-Scriptly** is a reusable Roblox Studio developer and anti-cheat QA package. It has no personal-key prompt. It can be installed in every experience your studio owns or is authorised to test.

## Fast install — one model per experience

1. Download **[Six-Scriptly.rbxmx](https://raw.githubusercontent.com/shaboomboom43-creator/Scriptly/six-scriptly-studio-private/Six-Scriptly.rbxmx)**.
2. In Roblox Studio, insert the model into your place (drag the `.rbxmx` into the viewport or use Studio's model import workflow).
3. Move the root model named `Six-Scriptly` into **ServerScriptService**.
4. Publish and test in a private server first.

The model contains the server controller and both client LocalScript templates. The server controller installs the client scripts into each joining player's `PlayerGui`, and reinstalls them after respawn if needed. You no longer need to place three scripts manually.

## Keep multiple experiences in sync

For your studio's other experiences, insert the same model in each place's `ServerScriptService`. In Studio, convert the model to a Roblox **Package**, enable **AutoUpdate**, and use that package copy in your other games/places. Publish a new package version when you update Six-Scriptly, then use Studio's package update controls to update the copies. Roblox Packages support reusable assets across projects and can update copies across multiple games.

Each independent experience still needs its own installed package copy; Roblox does not allow one place's server scripts to run inside a different place automatically.

## Access and warning behaviour

- The hub opens without a personal key.
- If the server cannot verify the current account, the hub opens in **read-only mode** with a warning.
- In a user-owned experience, the account matching `game.CreatorId` is authorised automatically.
- In a group-owned experience, add your numeric **Roblox UserId** to `DEVELOPER_IDS` in the server Script inside the package. Use the same allowlist in all group-owned games.
- The server independently checks every gameplay-changing command and rate-limits requests. A warning is not treated as permission.

A secret stored in a Roblox LocalScript or client-side config cannot be guaranteed private. Six-Scriptly does not use a client key as an access boundary.

## Included developer tools

- Owner-authorised movement and physics test controls
- Local lighting and camera test controls
- NPC target ESP and camera tests, restricted to models or parts tagged `SixScriptlyTarget`
- Server-authoritative heal, respawn, teleport, freeze, ghost, gravity and lighting controls
- Local/server notifications, confetti and UI effect tests
- Theme customisation and RightShift panel toggle

Player ESP is not included. Visual highlighting is limited to explicitly tagged NPC test targets.

## Responsible testing

Use Six-Scriptly only in experiences you own or have explicit permission to test. This Studio package does not inject into or bypass protections in arbitrary Roblox experiences. For anti-cheat hardening, keep gameplay decisions on the server and validate every client-supplied remote argument.
