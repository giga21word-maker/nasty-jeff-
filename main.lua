-- // TITAN V2.1 [OMEGA] //
-- [2026-01-18] STATUS: OPERATIONAL
-- FEATURES: Nano-Punches, Fast-Rep, World-Hops, Inventory-Purge, Throne-Lock

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents", 10)

-- // 1. OMEGA CONFIGURATION //
local TITAN_DB = {
    -- Training Protocols
    AUTO_STRENGTH = false,
    AUTO_DURABILITY = false,
    AUTO_AGILITY = false,
    FAST_REP = true,
    FAST_PUNCH = false,
    STRENGTH_METHOD = "Tool", 
    
    -- Farming & Economy
    AUTO_REBIRTH = false,
    REBIRTH_LIMIT = 100,
    AUTO_CRYSTAL = false,
    SELECTED_CRYSTAL = "Blue Crystal",
    AUTO_DELETE_TRASH = false,
    AUTO_EVOLVE = false,
    AUTO_CHESTS = true,
    AUTO_QUESTS = true,
    AUTO_ORBS = false,
    
    -- Combat & Throne
    KILL_AURA = false,
    HITBOX_EXPANDER = false,
    HITBOX_SIZE = 15,
    SIZE_LOCK = 1, 
    THRONE_LOCK = false,
    ANTI_GRAB = false,
    
    -- Movement Mods
    WALK_SPEED = 16,
    JUMP_POWER = 50,
    MOD_SPEED = false,
    
    -- World Intelligence
    AUTO_GYM = false,
    ANTI_AFK = true,
    ACCENT = Color3.fromRGB(255, 0, 80),
    UI_OPEN = true,
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    CurrentChar = nil,
    CurrentRoot = nil,
    CurrentHum = nil,
    Gyms = {
        ["Tiny Gym"] = CFrame.new(-30, 4, 188),
        ["Legends Gym"] = CFrame.new(4600, 990, 560),
        ["Eternal Gym"] = CFrame.new(-6730, 4, 430),
        ["Mythic Gym"] = CFrame.new(2450, 7, 1030),
        ["Frost Gym"] = CFrame.new(-2580, 12, -430)
    }
}

-- // 2. CORE UTILITIES //
local function SecureRemote(remote, ...)
    if rEvents and rEvents:FindFirstChild(remote) then
        rEvents[remote]:FireServer(...)
    end
end

local function UpdateRefs(char)
    if not char then return end
    Internal.CurrentChar = char
    Internal.CurrentRoot = char:WaitForChild("HumanoidRootPart", 10)
    Internal.CurrentHum = char:WaitForChild("Humanoid", 10)
end

if LocalPlayer.Character then UpdateRefs(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateRefs)

-- // 3. NANO-PUNCH & FAST-REP //
task.spawn(function()
    while TITAN_DB.ACTIVE do
        if TITAN_DB.FAST_PUNCH then
            -- Double-thread saturation for maximum punch speed
            SecureRemote("punchEvent", "punch")
            task.spawn(function() SecureRemote("punchEvent", "punch") end)
        end
        RunService.RenderStepped:Wait()
    end
end)

-- // 4. FARMING ENGINE //
local function CoreFarming()
    -- Strength/Durability Machine
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_STRENGTH then
                if TITAN_DB.STRENGTH_METHOD == "Tool" then
                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or (Internal.CurrentChar and Internal.CurrentChar:FindFirstChildOfClass("Tool"))
                    if tool and (tool.Name:find("Weight") or tool.Name:find("Barbell")) then
                        tool.Parent = Internal.CurrentChar
                        if TITAN_DB.FAST_REP then
                            SecureRemote("repEvent", "rep")
                        else
                            tool:Activate()
                        end
                    end
                else
                    SecureRemote("pushupsEvent", "usePushups")
                end
            end
            
            if TITAN_DB.AUTO_DURABILITY then
                SecureRemote("pushupsEvent", "usePushups")
            end
            task.wait()
        end
    end)

    -- Agility Treadmill Logic
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_AGILITY then
                SecureRemote("treadmillEvent", "useTreadmill")
            end
            task.wait()
        end
    end)

    -- Orb/Gem Sniper
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_ORBS and Internal.CurrentRoot then
                local folder = workspace:FindFirstChild("orbFolder") or workspace:FindFirstChild("Orbs")
                if folder then
                    for _, orb in pairs(folder:GetChildren()) do
                        if not TITAN_DB.AUTO_ORBS then break end
                        if orb:IsA("BasePart") then
                            orb.CFrame = Internal.CurrentRoot.CFrame
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- // 5. PET & ECONOMY //
local function PetAutomation()
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_CRYSTAL then
                SecureRemote("hatchCrystalEvent", "openCrystal", TITAN_DB.SELECTED_CRYSTAL)
            end
            
            if TITAN_DB.AUTO_EVOLVE then
                SecureRemote("evolvePetEvent", "evolvePet", "all")
            end
            task.wait(1)
        end
    end)
end

-- // 6. COMBAT & WORLD //
local function CombatProtocols()
    RunService.Heartbeat:Connect(function()
        if not TITAN_DB.ACTIVE then return end
        
        -- Movement Modifiers
        if TITAN_DB.MOD_SPEED and Internal.CurrentHum then
            Internal.CurrentHum.WalkSpeed = TITAN_DB.WALK_SPEED
            Internal.CurrentHum.JumpPower = TITAN_DB.JUMP_POWER
        end

        -- Kill Aura
        if TITAN_DB.KILL_AURA and not TITAN_DB.FAST_PUNCH then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (Internal.CurrentRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 18 then
                        SecureRemote("punchEvent", "punch")
                    end
                end
            end
        end

        -- Throne Lock (Muscle King)
        if TITAN_DB.THRONE_LOCK then
            local throne = workspace:FindFirstChild("throne") or workspace:FindFirstChild("MuscleKingThrone")
            if throne and Internal.CurrentRoot then
                Internal.CurrentRoot.CFrame = throne.CFrame * CFrame.new(0, 3, 0)
            end
        end

        -- Anti-Grab (Keeps you grounded)
        if TITAN_DB.ANTI_GRAB and Internal.CurrentRoot then
            for _, v in pairs(Internal.CurrentChar:GetChildren()) do
                if v:IsA("BodyMovingObject") or v:IsA("RocketPropulsion") then
                    v:Destroy()
                end
            end
        end

        if TITAN_DB.SIZE_LOCK then
            SecureRemote("changeSizeEvent", "changeSize", TITAN_DB.SIZE_LOCK)
        end
    end)

    -- Global Loops (Rebirth, Chests, Quests)
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_REBIRTH then
                SecureRemote("rebirthEvent", "rebirthRequest")
            end
            
            if TITAN_DB.AUTO_CHESTS then
                local chests = {"Daily Chest", "Group Rewards", "Magma Chest", "Legends Chest"}
                for _, c in pairs(chests) do SecureRemote("checkChestEvent", c) end
            end
            
            if TITAN_DB.AUTO_QUESTS then
                SecureRemote("questMasterEvent", "acceptQuest")
                SecureRemote("questMasterEvent", "claimReward")
            end
            task.wait(1)
        end
    end)
end

-- // 7. UI CONSTRUCTION //
local function BuildUI()
    if CoreGui:FindFirstChild("TitanOmega") then CoreGui.TitanOmega:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "TitanOmega"
    
    local Main = Instance.new("Frame", Screen)
    Main.Name = "MainFrame"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 450, 0, 350)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = TITAN_DB.ACCENT
    UIStroke.Thickness = 2
    
    -- Decorative Top Bar
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 35)
    Top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local TC = Instance.new("UICorner", Top)
    
    local Title = Instance.new("TextLabel", Top)
    Title.Text = "TITAN OMEGA // MUSCLE LEGENDS"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Sidebar
    local Nav = Instance.new("Frame", Main)
    Nav.Position = UDim2.new(0, 10, 0, 45)
    Nav.Size = UDim2.new(0, 110, 1, -55)
    Nav.BackgroundTransparency = 1
    Instance.new("UIListLayout", Nav).Padding = UDim.new(0, 4)

    -- Page Area
    local Pages = Instance.new("Frame", Main)
    Pages.Position = UDim2.new(0, 125, 0, 45)
    Pages.Size = UDim2.new(1, -135, 1, -55)
    Pages.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Pages)

    local function CreateTab(name, active)
        local b = Instance.new("TextButton", Nav)
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = active and TITAN_DB.ACCENT or Color3.fromRGB(25, 25, 25)
        b.Text = name
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Code
        b.TextSize = 13
        Instance.new("UICorner", b)
        
        local p = Instance.new("ScrollingFrame", Pages)
        p.Size = UDim2.new(1, -10, 1, -10)
        p.Position = UDim2.new(0, 5, 0, 5)
        p.BackgroundTransparency = 1
        p.Visible = active
        p.ScrollBarThickness = 2
        p.CanvasSize = UDim2.new(0,0,0,0)
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
        
        b.MouseButton1Click:Connect(function()
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            for _, v in pairs(Nav:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end end
            p.Visible = true
            b.BackgroundColor3 = TITAN_DB.ACCENT
        end)
        return p
    end

    local T_Core = CreateTab("FARMING", true)
    local T_Combat = CreateTab("COMBAT", false)
    local T_World = CreateTab("WORLD", false)
    local T_Teleport = CreateTab("GYMS", false)

    local function AddToggle(parent, text, key)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = text .. (TITAN_DB[key] and ": ON" or ": OFF")
        btn.TextColor3 = TITAN_DB[key] and TITAN_DB.ACCENT or Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            TITAN_DB[key] = not TITAN_DB[key]
            btn.Text = text .. (TITAN_DB[key] and ": ON" or ": OFF")
            btn.TextColor3 = TITAN_DB[key] and TITAN_DB.ACCENT or Color3.new(1, 1, 1)
        end)
    end
    
    local function AddButton(parent, text, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
    end

    -- Populate Farming
    AddToggle(T_Core, "AUTO STRENGTH", "AUTO_STRENGTH")
    AddToggle(T_Core, "AUTO DURABILITY", "AUTO_DURABILITY")
    AddToggle(T_Core, "AUTO AGILITY", "AUTO_AGILITY")
    AddToggle(T_Core, "FAST-REP (BYPASS)", "FAST_REP")
    AddToggle(T_Core, "ORB SNIPER", "AUTO_ORBS")
    
    -- Populate Combat
    AddToggle(T_Combat, "NANO-PUNCH (MAX)", "FAST_PUNCH")
    AddToggle(T_Combat, "KILL AURA", "KILL_AURA")
    AddToggle(T_Combat, "THRONE LOCK", "THRONE_LOCK")
    AddToggle(T_Combat, "ANTI-GRAB", "ANTI_GRAB")
    AddToggle(T_Combat, "WALK SPEED MOD", "MOD_SPEED")
    
    -- Populate World
    AddToggle(T_World, "AUTO REBIRTH", "AUTO_REBIRTH")
    AddToggle(T_World, "AUTO CHESTS", "AUTO_CHESTS")
    AddToggle(T_World, "AUTO QUESTS", "AUTO_QUESTS")
    AddToggle(T_World, "AUTO EVOLVE ALL", "AUTO_EVOLVE")
    
    -- Populate Teleports
    for name, cf in pairs(Internal.Gyms) do
        AddButton(T_Teleport, name, function()
            if Internal.CurrentRoot then Internal.CurrentRoot.CFrame = cf end
        end)
    end

    -- Dragging Logic
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Internal.Dragging = false end
    end)
end

-- // 8. INITIALIZATION //
CoreFarming()
PetAutomation()
CombatProtocols()
BuildUI()

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if TITAN_DB.ANTI_AFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

print("TITAN SYSTEM INITIALIZED")
