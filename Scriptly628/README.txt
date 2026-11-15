SCRIPTLY - 628 | ROBLOX DEVELOPER TEST HUB
==========================================

IMPORTANT
---------
This is a developer hub integrated into YOUR Roblox experience. It is not an executor
script and does not run in other people's games. The client cannot execute arbitrary Lua
on the server. Server commands are fixed, checked on the server, and restricted to your
UserId allowlist / the user-owned experience creator.

INSTALLATION
------------
1. Open your place in Roblox Studio.
2. In ServerScriptService, create a normal Script named:
      ScriptlyServer
   Paste in ScriptlyServer.server.lua.
3. In StarterPlayer > StarterPlayerScripts, create a LocalScript named:
      ScriptlyClient
   Paste in ScriptlyClient.client.lua.
4. In StarterPlayer > StarterPlayerScripts, create a second LocalScript named:
      ScriptlyEffects
   Paste in ScriptlyEffects.client.lua. Keep this enabled for all players so server-wide
   announcements, confetti, and jumpscares display for non-developers too.
5. Open ScriptlyServer.server.lua and replace 123456789 in DEVELOPER_IDS with YOUR
   Roblox UserId. Add any other trusted testers as [theirUserId] = true.
6. Press Play (F5). The hub should load after the server controller starts.
7. Press RightShift to hide/show the hub.

REQUIRED SETTINGS
-----------------
- Keep the server file in ServerScriptService. Do not put it in Workspace or StarterPlayer.
- Keep both client LocalScripts in StarterPlayer > StarterPlayerScripts.
- Do not rename the remote folder/event/function created by the server script.
- The experience creator is automatically allowed only when the experience is user-owned.
  For a group-owned experience, add your personal UserId to DEVELOPER_IDS.

NPC AIM TEST / NPC ESP
----------------------
The NPC-only aim test never targets player characters. To create a test target:
1. Select an NPC Model in Studio.
2. Open View > Tag Editor (or use CollectionService in a setup script).
3. Add the tag: ScriptlyTarget
4. Give the NPC a Head, HumanoidRootPart, or PrimaryPart.

The hub's NPC Aim Test and NPC Target ESP only use objects with that tag.

FEATURES INCLUDED
-----------------
CLIENT / LOCAL:
- Flight (WASD, Space, LeftControl or LeftShift)
- Noclip
- Bunny hop
- Spin test
- Player ESP
- NPC-only target ESP
- NPC-only camera aim test (tagged ScriptlyTarget NPCs only)
- Fullbright
- FOV 90 / reset FOV
- Flashbang screen test
- Local confetti rendering for server-triggered confetti
- Retro green/black UI, loading screen, scanlines, and RightShift toggle
- Matrix Green, Toxic Lime, Cyber Teal, Amber Terminal, and custom hex gradient themes

SERVER / AUTHORITATIVE:
- Set/reset WalkSpeed and JumpPower
- Teleport to spawn
- Teleport to a player by exact username/display name
- Heal and respawn self
- Freeze/unfreeze self
- Server-visible ghost transparency toggle
- Launch self
- Global low gravity / restore gravity
- Set day/night / restore startup time
- Temporary ForceField
- Flop test
- Server-wide jumpscare
- Server-wide confetti
- Server-wide announcement

SECURITY NOTES
--------------
- The server validates the caller's UserId for every command.
- The client sends command names and small data values only; no code strings are evaluated.
- No loadstring, arbitrary RemoteFunction execution, hidden backdoor, or executor API is used.
- This is intended for private development/testing. Remove the scripts or remove test users
  from DEVELOPER_IDS before publishing to a live experience.

TROUBLESHOOTING
---------------
- Hub does not appear: check Output for the warning. Confirm both scripts are in the exact
  locations above and that your UserId is in DEVELOPER_IDS.
- Server buttons do nothing: confirm the server Script is enabled and in ServerScriptService.
- NPC aim/ESP does nothing: add the ScriptlyTarget tag to an NPC Model and ensure it has a
  Head, HumanoidRootPart, or PrimaryPart.
- For group-owned games, the group creator ID is not your personal UserId; add your own
  personal UserId to the allowlist.
