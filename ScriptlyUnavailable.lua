-- SCRIPTLY // 628 — CENTRAL SHUTDOWN SWITCH
-- Run this file in the same client/executor session as Scriptly to disable
-- the local Scriptly instance. To disable the server controller for everyone
-- in this experience, install/run this as a normal Script in ServerScriptService.
--
-- The one authoritative shutdown switch lives here. Other Scriptly entry points
-- only check the flag this file sets; they do not duplicate the shutdown logic.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MESSAGE = "[SCRIPTLY 628] UNAVAILABLE — this archived project has been disabled."

local function setLocalFlag()
    local executorEnv = (type(getgenv) == "function" and getgenv()) or nil
    if type(_G) == "table" then
        _G.Scriptly628Unavailable = true
    end
    if type(executorEnv) == "table" then
        executorEnv.Scriptly628Unavailable = true
    end

    -- Stop a currently running local hub immediately where its cleanup hook exists.
    local cleanup = (type(_G) == "table" and _G.Scriptly628_Cleanup)
        or (type(executorEnv) == "table" and executorEnv.Scriptly628_Cleanup)
    if type(cleanup) == "function" then
        pcall(cleanup)
    end
end

if RunService:IsServer() then
    -- Server-side shutdown: clients receive this replicated attribute and close
    -- their active Scriptly UI; new entry points refuse to start.
    ReplicatedStorage:SetAttribute("Scriptly628Unavailable", true)

    local remotes = ReplicatedStorage:FindFirstChild("Scriptly628Remotes")
    if remotes then remotes:Destroy() end
else
    -- Executor / client-side shutdown: this affects this client session only.
    setLocalFlag()
end

warn(MESSAGE)
return
