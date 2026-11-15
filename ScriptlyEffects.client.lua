-- SCRIPTLY - 628 | CLIENT-WIDE EFFECT RECEIVER
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="Scriptly628Effects"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false
gui.DisplayOrder=950; gui.Parent=player:WaitForChild("PlayerGui")
local GREEN=Color3.fromRGB(0,255,125)
local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p end
local function stroke(p) local s=Instance.new("UIStroke"); s.Color=GREEN; s.Thickness=1.5; s.Parent=p end
local function announce(message,by)
    local f=Instance.new("Frame"); f.AnchorPoint=Vector2.new(.5,0); f.Position=UDim2.new(.5,0,0,-80)
    f.Size=UDim2.fromOffset(460,66); f.BackgroundColor3=Color3.fromRGB(4,19,11); f.Parent=gui; corner(f,8); stroke(f)
    local a=Instance.new("TextLabel"); a.BackgroundTransparency=1; a.Position=UDim2.fromOffset(12,4); a.Size=UDim2.new(1,-24,0,18)
    a.Font=Enum.Font.Code; a.TextSize=10; a.TextColor3=GREEN; a.TextXAlignment=Enum.TextXAlignment.Left
    a.Text=tostring(by or "SCRIPTLY SERVER"); a.Parent=f
    local b=Instance.new("TextLabel"); b.BackgroundTransparency=1; b.Position=UDim2.fromOffset(12,24); b.Size=UDim2.new(1,-24,0,34)
    b.Font=Enum.Font.Code; b.TextSize=13; b.TextWrapped=true; b.TextColor3=Color3.fromRGB(225,255,235)
    b.TextXAlignment=Enum.TextXAlignment.Left; b.Text=tostring(message or ""); b.Parent=f
    TweenService:Create(f,TweenInfo.new(.25),{Position=UDim2.new(.5,0,0,18)}):Play()
    task.delay(3.2,function() if f.Parent then TweenService:Create(f,TweenInfo.new(.2),{Position=UDim2.new(.5,0,0,-80)}):Play(); task.wait(.25); f:Destroy() end end)
end
local function jumpscare(by)
    local f=Instance.new("Frame"); f.Name="ScriptlyJumpscare"; f.Size=UDim2.fromScale(1,1)
    f.BackgroundColor3=Color3.fromRGB(30,0,4); f.Parent=gui
    local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,1)
    t.Font=Enum.Font.Code; t.TextSize=48; t.TextColor3=Color3.fromRGB(255,230,230)
    t.Text="◉     ◉\n\n   ▄▄▄\n  ▀█████▀\n\nYOU HAVE BEEN SCRIPTLY'D // 628"
    t.TextWrapped=true; t.Parent=f
    task.delay(1.8,function() if f.Parent then TweenService:Create(f,TweenInfo.new(.3),{BackgroundTransparency=1}):Play(); task.wait(.35); f:Destroy() end end)
end
local function confetti()
    local colors={Color3.fromRGB(0,255,130),Color3.fromRGB(120,255,190),Color3.fromRGB(0,150,90),Color3.fromRGB(210,255,225)}
    for i=1,42 do
        local p=Instance.new("Frame"); p.BorderSizePixel=0; p.BackgroundColor3=colors[math.random(1,#colors)]
        p.Size=UDim2.fromOffset(math.random(4,9),math.random(7,15)); p.Position=UDim2.new(math.random(),0,-.08,0)
        p.Parent=gui
        local dest=UDim2.new(p.Position.X.Scale+math.random(-15,15)/100,0,1.1,0)
        TweenService:Create(p,TweenInfo.new(2.4),{Position=dest,Rotation=math.random(240,620)}):Play()
        task.delay(3,function() if p.Parent then p:Destroy() end end)
    end
end
local remotes=ReplicatedStorage:WaitForChild("Scriptly628Remotes",30)
if not remotes then warn("[Scriptly 628 Effects] Server bridge not found."); return end
local event=remotes:WaitForChild("Command",10)
if not event then warn("[Scriptly 628 Effects] Command event missing."); return end
event.OnClientEvent:Connect(function(action,data)
    if typeof(data)~="table" then data={} end
    if action=="Announcement" then announce(data.message,data.by)
    elseif action=="Jumpscare" then jumpscare(data.by)
    elseif action=="Confetti" then confetti() end
end)
print("[Scriptly 628 Effects] Receiver ready for "..player.Name)
