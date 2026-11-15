-- SCRIPTLY - 628 | GITHUB LOADER
-- Use only in your own Roblox experience or an experience you are authorised to test.
-- This downloads the client source fragments and joins them before compilation.
local BASE = "https://raw.githubusercontent.com/shaboomboom43-creator/Scriptly/main/parts/"
if type(loadstring) ~= "function" then
    warn("[Scriptly 628] loadstring() is unavailable in this executor.")
    return
end
local fragments = {}
for i = 1, 6 do
    local url = BASE .. string.format("client_%02d.lua", i)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok or type(body) ~= "string" or body == "" then
        warn("[Scriptly 628] Could not download source fragment " .. i .. ". Check that the GitHub repository is PUBLIC.")
        return
    end
    fragments[i] = body
end
local source = table.concat(fragments, "\n")
local compiled, chunk = pcall(loadstring, source)
if not compiled or type(chunk) ~= "function" then
    warn("[Scriptly 628] Compilation failed:", chunk)
    return
end
local ran, err = pcall(chunk)
if not ran then warn("[Scriptly 628] Startup failed:", err) end
