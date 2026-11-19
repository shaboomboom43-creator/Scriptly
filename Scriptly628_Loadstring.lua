-- Central Scriptly shutdown flag: ScriptlyUnavailable.lua owns the switch.
local function scriptlyIsUnavailable()
    local executorEnv = (type(getgenv) == "function" and getgenv()) or nil
    local globalFlag = type(_G) == "table" and _G.Scriptly628Unavailable == true
    local executorFlag = type(executorEnv) == "table" and executorEnv.Scriptly628Unavailable == true
    local serverFlag = false
    pcall(function()
        serverFlag = game:GetService("ReplicatedStorage"):GetAttribute("Scriptly628Unavailable") == true
    end)
    return globalFlag or executorFlag or serverFlag
end

if scriptlyIsUnavailable() then
    warn("[SCRIPTLY 628] UNAVAILABLE — disabled by ScriptlyUnavailable.lua.")
    return
end

-- Paste this one line into your executor (repository must be public):
loadstring(game:HttpGet("https://raw.githubusercontent.com/shaboomboom43-creator/Scriptly/main/ScriptlyLoader.lua"))()
