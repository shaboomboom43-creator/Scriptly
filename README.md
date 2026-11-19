# SCRIPTLY // 628 — ARCHIVED / UNAVAILABLE

**This project is intentionally disabled.** All Scriptly entry points now stop immediately and print:

```
[SCRIPTLY 628] UNAVAILABLE — this project is archived and disabled.
```

The shutdown is applied to the executor loader, loadstring entry point, client script, server script, and effects LocalScript. The standalone `ScriptlyUnavailable.lua` file contains the same shutdown notice.

No Scriptly interface, gameplay tools, server remotes, or effects are started by the current files on the `main` branch.

## Important

- This commit disables the current project files; it does not erase earlier versions from Git history.
- The repository was public when these changes were made. Change its visibility to **Private** in GitHub repository settings to restrict future access.
- A private GitHub repository cannot be fetched anonymously by the old public raw-file loadstring. The project is now deliberately offline, so the current loader does not attempt a download.
- The earlier private access-key prompt is no longer needed for this disabled build. Keep or discard your separate key file as you prefer.
