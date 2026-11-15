-- SCRIPTLY - 628 | SERVER CONTROLLER
-- Install as a normal Script in ServerScriptService.
-- For group-owned games, add your own numeric UserId to DEVELOPER_IDS.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local DEVELOPER_IDS = {
    [123456789] = true, -- REPLACE with your own UserId for group-owned games.
}
local DEFAULT_GRAVITY = workspace.Gravity
local DEFAULT_CLOCK_TIME = Lighting.ClockTime
local frozen = {}
local ghosted = {}
local ghostTransparency = {}

local folder = ReplicatedStorage:FindFirstChild("Scriptly628Remotes") or Instance.new("Folder")
folder.Name = "Scriptly628Remotes"
folder.Parent = ReplicatedStorage
local command = folder:FindFirstChild("Command") or Instance.new("RemoteEvent")
command.Name = "Command"
command.Parent = folder
local access = folder:FindFirstChild("CheckAccess") or Instance.new("RemoteFunction")
access.Name = "CheckAccess"
access.Parent = folder

local function allowed(player)
    if DEVELOPER_IDS[player.UserId] == true then return true end
    return game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId
end
access.OnServerInvoke = allowed

local function characterParts(player)
    local char = player.Character
    if not char then return nil,nil,nil end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end
local function notice(player,message)
    command:FireClient(player,"Announcement",{message=message,by="SCRIPTLY SERVER"})
end
local function spawnCFrame()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation",true)
    if spawn then return spawn.CFrame + Vector3.new(0,4,0) end
    local named = workspace:FindFirstChild("Spawn",true)
    if named and named:IsA("BasePart") then return named.CFrame + Vector3.new(0,4,0) end
    return CFrame.new(0,8,0)
end
local function setFrozen(player,on)
    local _,hum = characterParts(player)
    if not hum then return end
    if on then
        if frozen[player] then return end
        frozen[player]={WalkSpeed=hum.WalkSpeed,JumpPower=hum.JumpPower,JumpHeight=hum.JumpHeight,UseJumpPower=hum.UseJumpPower,AutoRotate=hum.AutoRotate}
        hum.WalkSpeed=0; hum.JumpPower=0; hum.JumpHeight=0; hum.AutoRotate=false
    else
        local old=frozen[player]
        if not old then return end
        hum.WalkSpeed=old.WalkSpeed; hum.JumpPower=old.JumpPower; hum.JumpHeight=old.JumpHeight
        hum.UseJumpPower=old.UseJumpPower; hum.AutoRotate=old.AutoRotate
        frozen[player]=nil
    end
end
local function setGhost(player,on)
    local char=player.Character
    if not char then return end
    if on then
        if ghosted[player] then return end
        ghosted[player]=true; ghostTransparency[player]={}
        for _,obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                ghostTransparency[player][obj]=obj.Transparency
                obj.Transparency=0.78
            end
        end
    else
        ghosted[player]=nil
        for obj,value in pairs(ghostTransparency[player] or {}) do
            if obj and obj.Parent then obj.Transparency=value end
        end
        ghostTransparency[player]=nil
    end
end
local function findPlayer(name)
    if typeof(name)~="string" then return nil end
    local wanted=string.lower(string.sub(name,1,32))
    for _,p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name)==wanted or string.lower(p.DisplayName)==wanted then return p end
    end
end

command.OnServerEvent:Connect(function(player,action,data)
    if not allowed(player) then
        warn("[Scriptly 628] Rejected unauthorised command from "..player.Name)
        return
    end
    if typeof(action)~="string" then return end
    if typeof(data)~="table" then data={} end
    local char,hum,root=characterParts(player)

    if action=="SetMovement" then
        if not hum then return end
        hum.UseJumpPower=true
        hum.WalkSpeed=math.clamp(tonumber(data.speed) or 16,0,150)
        hum.JumpPower=math.clamp(tonumber(data.jump) or 50,0,200)
    elseif action=="ResetMovement" then
        if hum then hum.UseJumpPower=true; hum.WalkSpeed=16; hum.JumpPower=50; hum.JumpHeight=7.2 end
    elseif action=="TeleportSpawn" then
        if root then root.CFrame=spawnCFrame(); root.AssemblyLinearVelocity=Vector3.zero end
    elseif action=="TeleportToPlayer" then
        if not root then return end
        local target=findPlayer(data.target)
        local targetRoot=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and target~=player then root.CFrame=targetRoot.CFrame*CFrame.new(3,0,0); root.AssemblyLinearVelocity=Vector3.zero
        else notice(player,"Target player not found.") end
    elseif action=="Heal" then
        if hum then hum.Health=hum.MaxHealth end
    elseif action=="Respawn" then
        player:LoadCharacter()
    elseif action=="FreezeSelf" then
        setFrozen(player,true)
    elseif action=="UnfreezeSelf" then
        setFrozen(player,false)
    elseif action=="GhostSelf" then
        setGhost(player,true)
    elseif action=="UnghostSelf" then
        setGhost(player,false)
    elseif action=="LaunchSelf" then
        if root then root:ApplyImpulse(Vector3.new(0,root.AssemblyMass*125,0)) end
    elseif action=="LowGravityGlobal" then
        workspace.Gravity=55
        command:FireAllClients("Announcement",{message="GLOBAL GRAVITY: LOW",by="SCRIPTLY SERVER"})
    elseif action=="ResetGravityGlobal" then
        workspace.Gravity=DEFAULT_GRAVITY
        command:FireAllClients("Announcement",{message="Gravity restored.",by="SCRIPTLY SERVER"})
    elseif action=="Day" then
        Lighting.ClockTime=14
    elseif action=="Night" then
        Lighting.ClockTime=0
    elseif action=="ResetTime" then
        Lighting.ClockTime=DEFAULT_CLOCK_TIME
    elseif action=="ForceField" then
        if char and not char:FindFirstChildOfClass("ForceField") then
            local ff=Instance.new("ForceField"); ff.Parent=char; Debris:AddItem(ff,12)
        end
    elseif action=="FlopSelf" then
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics); hum.PlatformStand=true
            task.delay(2,function() if hum and hum.Parent then hum.PlatformStand=false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end)
        end
    elseif action=="ServerJumpscare" then
        command:FireAllClients("Jumpscare",{by=player.DisplayName})
    elseif action=="ServerConfetti" then
        command:FireAllClients("Confetti",{by=player.DisplayName})
    elseif action=="ServerAnnouncement" then
        local message=data.message
        if typeof(message)~="string" then return end
        message=string.sub(message,1,110):gsub("[%c]"," ")
        if message:gsub("%s","")=="" then return end
        command:FireAllClients("Announcement",{message=message,by=player.DisplayName})
    end
end)

Players.PlayerRemoving:Connect(function(p)
    frozen[p]=nil; ghosted[p]=nil; ghostTransparency[p]=nil
end)
print("[Scriptly 628] Server controller ready.")
