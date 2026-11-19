# SCRIPTLY // 628

Scriptly's normal entry points are restored. The shutdown logic is centralized in **`ScriptlyUnavailable.lua`**.

## Disable Scriptly

- **Current client only:** execute `ScriptlyUnavailable.lua` in the same executor/client session. It sets one shared flag and calls the current hub's cleanup hook when available. Subsequent Scriptly entry points in that session print **UNAVAILABLE** and stop.
- **Everyone in one experience server:** install `ScriptlyUnavailable.lua` as a normal Script in `ServerScriptService`. It sets a replicated shutdown attribute and removes the Scriptly remotes. Connected clients close the active UI, and new Scriptly entry points stop.

The local shutdown flag is session-scoped. Restarting the client clears the local flag. The server shutdown attribute lasts for that server's lifetime; restarting the server clears it.

## Normal setup

The ordinary Scriptly authorization model remains in place: local/server tools are limited to the experience owner, Studio, and configured developer/group permissions. Each experience that needs server-side functionality still needs `ScriptlyServer.server.lua` installed in `ServerScriptService`; server-wide client effects use `ScriptlyEffects.client.lua`.

For executor loading, `ScriptlyLoader.lua` downloads `ScriptlyClient.lua`. Anonymous raw GitHub access requires the repository to be public. A private repository needs a different authenticated distribution method; do not put a GitHub token in a client script.

## Archive note

The shutdown file is a convenience kill switch, not a tamper-proof security boundary. It does not erase older file versions from Git history.
