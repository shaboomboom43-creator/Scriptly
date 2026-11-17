-- SIX-SCRIPTLY | SERVER-AUTHORISED DEVELOPER TEST CONTROLLER
-- Install as a normal Script in ServerScriptService.
-- User-owned experiences: the Roblox experience creator is authorised automatically.
-- Group-owned experiences: add your Roblox UserId to DEVELOPER_IDS below.
-- Do not put access secrets or API tokens in this public repository.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- Group-owned places only. Use your Roblox UserId, not your GitHub ID.
local DEVELOPER_IDS = {
    -- [YOUR_ROBLOX_USER_ID] = true,
}

local DEFAULT_GRAVITY = workspace.Gravity
local DEFAULT_CLOCK_TIME = Lighting.ClockTime
local frozen, ghosted, ghostTransparency, lastCommandAt = {}, {}, {}, {}
local MIN_COMMAND_INTERVAL = 0.12

local ALLOWED_ACTIONS = {
    SetMovement = true, ResetMovement = true, TeleportSpawn = true,
    TeleportToPlayer = true, Heal = true, Respawn = true,
    FreezeSelf = true, UnfreezeSelf = true, GhostSelf = true,
    UnghostSelf = true, LaunchSelf = true, LowGravityGlobal = true,
    ResetGravityGlobal = true, Day = true, Night = true, ResetTime = true,
    ForceField = true, FlopSelf = true, ServerJumpscare = true,
    ServerConfetti = true, ServerAnnouncement = true,
}

local function isAuthorised(player)
    if DEVELOPER_IDS[player.UserId] == true then return true end
    return game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId
end

local folder = ReplicatedStorage:FindFirstChild("SixScriptlyRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "SixScriptlyRemotes"
    folder.Parent = ReplicatedStorage
end

local command = folder:FindFirstChild("Command")
if not command then
    command = Instance.new("RemoteEvent")
    command.Name = "Command"
    command.Parent = folder
end

local access = folder:FindFirstChild("CheckAccess")
if not access then
    access = Instance.new("RemoteFunction")
    access.Name = "CheckAccess"
    access.Parent = folder
end
access.OnServerInvoke = function(player)
    return isAuthorised(player)
end

local function characterParts(player)
    local character = player.Character
    if not character then return nil, nil, nil end
    return character, character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function notice(player, message)
    command:FireClient(player, "Announcement", {message = message, by = "SIX-SCRIPTLY SERVER"})
end

local function spawnCFrame()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawn then return spawn.CFrame + Vector3.new(0, 4, 0) end
    local named = workspace:FindFirstChild("Spawn", true)
    if named and named:IsA("BasePart") then return named.CFrame + Vector3.new(0, 4, 0) end
    return CFrame.new(0, 8, 0)
end

local function setFrozen(player, enabled)
    local _, humanoid = characterParts(player)
    if not humanoid then return end
    if enabled then
        if frozen[player] then return end
        frozen[player] = {
            WalkSpeed = humanoid.WalkSpeed, JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight, UseJumpPower = humanoid.UseJumpPower,
            AutoRotate = humanoid.AutoRotate,
        }
        humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 0, 0, 0
        humanoid.AutoRotate = false
    else
        local previous = frozen[player]
        if not previous then return end
        humanoid.WalkSpeed, humanoid.JumpPower = previous.WalkSpeed, previous.JumpPower
        humanoid.JumpHeight, humanoid.UseJumpPower = previous.JumpHeight, previous.UseJumpPower
        humanoid.AutoRotate = previous.AutoRotate
        frozen[player] = nil
    end
end

local function setGhost(player, enabled)
    local character = player.Character
    if not character then return end
    if enabled then
        if ghosted[player] then return end
        ghosted[player], ghostTransparency[player] = true, {}
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") or object:IsA("Decal") or object:IsA("Texture") then
                ghostTransparency[player][object] = object.Transparency
                object.Transparency = 0.78
            end
        end
    else
        ghosted[player] = nil
        for object, transparency in pairs(ghostTransparency[player] or {}) do
            if object and object.Parent then object.Transparency = transparency end
        end
        ghostTransparency[player] = nil
    end
end

local function findPlayer(name)
    if typeof(name) ~= "string" then return nil end
    local wanted = string.lower(string.sub(name, 1, 32))
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if string.lower(otherPlayer.Name) == wanted or string.lower(otherPlayer.DisplayName) == wanted then
            return otherPlayer
        end
    end
    return nil
end

command.OnServerEvent:Connect(function(player, action, data)
    if not isAuthorised(player) then return end
    if typeof(action) ~= "string" or not ALLOWED_ACTIONS[action] then return end
    local now = os.clock()
    if now - (lastCommandAt[player] or 0) < MIN_COMMAND_INTERVAL then return end
    lastCommandAt[player] = now

    if typeof(data) ~= "table" then data = {} end
    local character, humanoid, root = characterParts(player)

    if action == "SetMovement" then
        if not humanoid then return end
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = math.clamp(tonumber(data.speed) or 16, 0, 150)
        humanoid.JumpPower = math.clamp(tonumber(data.jump) or 50, 0, 200)
    elseif action == "ResetMovement" then
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 16, 50, 7.2
        end
    elseif action == "TeleportSpawn" then
        if root then root.CFrame = spawnCFrame(); root.AssemblyLinearVelocity = Vector3.zero end
    elseif action == "TeleportToPlayer" then
        if not root then return end
        local target = findPlayer(data.target)
        local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and target ~= player then
            root.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
            root.AssemblyLinearVelocity = Vector3.zero
        else
            notice(player, "Target player not found.")
        end
    elseif action == "Heal" then
        if humanoid then humanoid.Health = humanoid.MaxHealth end
    elseif action == "Respawn" then
        player:LoadCharacter()
    elseif action == "FreezeSelf" then
        setFrozen(player, true)
    elseif action == "UnfreezeSelf" then
        setFrozen(player, false)
    elseif action == "GhostSelf" then
        setGhost(player, true)
    elseif action == "UnghostSelf" then
        setGhost(player, false)
    elseif action == "LaunchSelf" then
        if root then root:ApplyImpulse(Vector3.new(0, root.AssemblyMass * 125, 0)) end
    elseif action == "LowGravityGlobal" then
        workspace.Gravity = 55
        command:FireAllClients("Announcement", {message = "GLOBAL GRAVITY: LOW", by = "SIX-SCRIPTLY SERVER"})
    elseif action == "ResetGravityGlobal" then
        workspace.Gravity = DEFAULT_GRAVITY
        command:FireAllClients("Announcement", {message = "Gravity restored.", by = "SIX-SCRIPTLY SERVER"})
    elseif action == "Day" then
        Lighting.ClockTime = 14
    elseif action == "Night" then
        Lighting.ClockTime = 0
    elseif action == "ResetTime" then
        Lighting.ClockTime = DEFAULT_CLOCK_TIME
    elseif action == "ForceField" then
        if character and not character:FindFirstChildOfClass("ForceField") then
            local forceField = Instance.new("ForceField")
            forceField.Parent = character
            Debris:AddItem(forceField, 12)
        end
    elseif action == "FlopSelf" then
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid.PlatformStand = true
            task.delay(2, function()
                if humanoid and humanoid.Parent then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    elseif action == "ServerJumpscare" then
        command:FireAllClients("Jumpscare", {by = player.DisplayName})
    elseif action == "ServerConfetti" then
        command:FireAllClients("Confetti", {by = player.DisplayName})
    elseif action == "ServerAnnouncement" then
        local message = data.message
        if typeof(message) ~= "string" then return end
        message = string.sub(message, 1, 110):gsub("[%c]", " ")
        if message:gsub("%s", "") == "" then return end
        command:FireAllClients("Announcement", {message = message, by = player.DisplayName})
    end
end)

Players.PlayerRemoving:Connect(function(player)
    frozen[player], ghosted[player], ghostTransparency[player], lastCommandAt[player] = nil, nil, nil, nil
end)

print("[Six-Scriptly] Owner-authorised server controller ready.")
