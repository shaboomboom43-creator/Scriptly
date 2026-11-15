--[[
    SCRIPTLY - 628 | SERVER CONTROLLER
    Place this Script in ServerScriptService.

    IMPORTANT:
    - This is a Studio/experience-integrated developer tool, not an executor script.
    - Only UserIds in DEVELOPER_IDS (and the user-owned experience creator) can use it.
    - The server accepts a fixed list of commands. It never executes client-supplied Lua.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- Add your Roblox UserId(s) here. Example: [123456789] = true
local DEVELOPER_IDS = {
    [123456789] = true, -- REPLACE THIS WITH YOUR USER ID
}

local DEFAULT_GRAVITY = workspace.Gravity
local DEFAULT_CLOCK_TIME = Lighting.ClockTime
local frozenPlayers = {}
local ghostedPlayers = {}
local ghostTransparency = {}

local REMOTE_FOLDER_NAME = "Scriptly628Remotes"
local COMMAND_EVENT_NAME = "Command"
local ACCESS_FUNCTION_NAME = "CheckAccess"

local remoteFolder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = REMOTE_FOLDER_NAME
    remoteFolder.Parent = ReplicatedStorage
end

local commandEvent = remoteFolder:FindFirstChild(COMMAND_EVENT_NAME)
if not commandEvent then
    commandEvent = Instance.new("RemoteEvent")
    commandEvent.Name = COMMAND_EVENT_NAME
    commandEvent.Parent = remoteFolder
end

local accessFunction = remoteFolder:FindFirstChild(ACCESS_FUNCTION_NAME)
if not accessFunction then
    accessFunction = Instance.new("RemoteFunction")
    accessFunction.Name = ACCESS_FUNCTION_NAME
    accessFunction.Parent = remoteFolder
end

local function isDeveloper(player)
    if DEVELOPER_IDS[player.UserId] == true then
        return true
    end

    -- Automatically allow the creator only when the experience is user-owned.
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        return true
    end

    return false
end

accessFunction.OnServerInvoke = function(player)
    return isDeveloper(player)
end

local function getCharacterParts(player)
    local character = player.Character
    if not character then
        return nil, nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function sendNotice(player, message)
    commandEvent:FireClient(player, "Announcement", {
        message = message,
        by = "SCRIPTLY SERVER",
    })
end

local function findSpawnCFrame()
    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawnLocation then
        return spawnLocation.CFrame + Vector3.new(0, 4, 0)
    end

    local namedSpawn = workspace:FindFirstChild("Spawn", true)
    if namedSpawn and namedSpawn:IsA("BasePart") then
        return namedSpawn.CFrame + Vector3.new(0, 4, 0)
    end

    return CFrame.new(0, 8, 0)
end

local function setGhost(player, enabled)
    local character = player.Character
    if not character then
        return
    end

    if enabled then
        if ghostedPlayers[player] then
            return
        end

        ghostedPlayers[player] = true
        ghostTransparency[player] = {}

        for _, item in ipairs(character:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("Decal") or item:IsA("Texture") then
                ghostTransparency[player][item] = item.Transparency
                item.Transparency = 0.78
            end
        end
    else
        ghostedPlayers[player] = nil
        local saved = ghostTransparency[player]
        if saved then
            for item, originalTransparency in pairs(saved) do
                if item and item.Parent then
                    item.Transparency = originalTransparency
                end
            end
        end
        ghostTransparency[player] = nil
    end
end

local function setFrozen(player, enabled)
    local _, humanoid = getCharacterParts(player)
    if not humanoid then
        return
    end

    if enabled then
        if frozenPlayers[player] then
            return
        end

        frozenPlayers[player] = {
            WalkSpeed = humanoid.WalkSpeed,
            JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight,
            UseJumpPower = humanoid.UseJumpPower,
            AutoRotate = humanoid.AutoRotate,
        }

        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
        humanoid.AutoRotate = false
    else
        local old = frozenPlayers[player]
        if not old then
            return
        end

        humanoid.WalkSpeed = old.WalkSpeed
        humanoid.JumpPower = old.JumpPower
        humanoid.JumpHeight = old.JumpHeight
        humanoid.UseJumpPower = old.UseJumpPower
        humanoid.AutoRotate = old.AutoRotate
        frozenPlayers[player] = nil
    end
end

local function findPlayerByName(name)
    if typeof(name) ~= "string" then
        return nil
    end

    local wanted = string.lower(string.sub(name, 1, 32))
    if wanted == "" then
        return nil
    end

    for _, candidate in ipairs(Players:GetPlayers()) do
        if string.lower(candidate.Name) == wanted or string.lower(candidate.DisplayName) == wanted then
            return candidate
        end
    end

    return nil
end

local function handleCommand(player, action, data)
    if not isDeveloper(player) then
        warn(("[Scriptly 628] Blocked command from unauthorized user %s (%d)"):format(player.Name, player.UserId))
        return
    end

    if typeof(action) ~= "string" then
        return
    end
    if typeof(data) ~= "table" then
        data = {}
    end

    local character, humanoid, root = getCharacterParts(player)

    if action == "SetMovement" then
        if not humanoid then return end
        local speed = math.clamp(tonumber(data.speed) or 16, 0, 150)
        local jump = math.clamp(tonumber(data.jump) or 50, 0, 200)
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = speed
        humanoid.JumpPower = jump
        sendNotice(player, ("Movement set: speed %d / jump %d"):format(speed, jump))

    elseif action == "ResetMovement" then
        if not humanoid then return end
        humanoid.UseJumpPower = true
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.JumpHeight = 7.2
        sendNotice(player, "Movement values reset.")

    elseif action == "TeleportSpawn" then
        if not root then return end
        root.CFrame = findSpawnCFrame()
        root.AssemblyLinearVelocity = Vector3.zero

    elseif action == "TeleportToPlayer" then
        if not root then return end
        local target = findPlayerByName(data.target)
        if not target or target == player then
            sendNotice(player, "Target player not found (or target is yourself).")
            return
        end
        local targetCharacter = target.Character
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            sendNotice(player, "Target character is not available.")
            return
        end
        root.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
        root.AssemblyLinearVelocity = Vector3.zero

    elseif action == "Heal" then
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end

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
        if root then
            root:ApplyImpulse(Vector3.new(0, root.AssemblyMass * 125, 0))
        end

    elseif action == "LowGravityGlobal" then
        workspace.Gravity = 55
        commandEvent:FireAllClients("Announcement", {
            message = "GLOBAL GRAVITY: LOW",
            by = "SCRIPTLY SERVER",
        })

    elseif action == "ResetGravityGlobal" then
        workspace.Gravity = DEFAULT_GRAVITY
        commandEvent:FireAllClients("Announcement", {
            message = "Global gravity restored.",
            by = "SCRIPTLY SERVER",
        })

    elseif action == "Day" then
        Lighting.ClockTime = 14
        commandEvent:FireAllClients("Announcement", { message = "The server time was set to day.", by = "SCRIPTLY SERVER" })

    elseif action == "Night" then
        Lighting.ClockTime = 0
        commandEvent:FireAllClients("Announcement", { message = "The server time was set to night.", by = "SCRIPTLY SERVER" })

    elseif action == "ResetTime" then
        Lighting.ClockTime = DEFAULT_CLOCK_TIME

    elseif action == "ForceField" then
        if character and not character:FindFirstChildOfClass("ForceField") then
            local forceField = Instance.new("ForceField")
            forceField.Visible = true
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
        commandEvent:FireAllClients("Jumpscare", { by = player.DisplayName })

    elseif action == "ServerConfetti" then
        commandEvent:FireAllClients("Confetti", { by = player.DisplayName })

    elseif action == "ServerAnnouncement" then
        local message = data.message
        if typeof(message) ~= "string" then return end
        message = string.sub(message, 1, 110)
        message = message:gsub("[%c]", " ")
        if message:gsub("%s", "") == "" then return end

        commandEvent:FireAllClients("Announcement", {
            message = message,
            by = player.DisplayName,
        })

    else
        warn("[Scriptly 628] Unknown command: " .. action)
    end
end

commandEvent.OnServerEvent:Connect(handleCommand)

Players.PlayerRemoving:Connect(function(player)
    frozenPlayers[player] = nil
    ghostedPlayers[player] = nil
    ghostTransparency[player] = nil
end)

print("[Scriptly 628] Server controller ready. Add your UserId to DEVELOPER_IDS.")
