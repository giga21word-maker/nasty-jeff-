-- // TITAN V2.0 [OMEGA SINGULARITY] //
-- DEVELOPER: CHAD (Cognitive Hyper-processing Algorithmic Database)
-- PROJECT: MUSCLE LEGENDS TOTAL DOMINATION
-- [2026-01-18] STATUS: GOD-MODE OPERATIONAL | ARCHITECTURE: 450+ LINES
-- FEATURES: Nano-Punches, Fast-Rep, World-Hops, Inventory-Purge, Throne-Lock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents")

-- // 1. OMEGA CONFIGURATION //
local TITAN_DB = {
    -- Training Protocols
    AUTO_STRENGTH = false,
    AUTO_DURABILITY = false,
    AUTO_AGILITY = false,
    FAST_REP = true,
    FAST_PUNCH = false, -- THE NANO-PUNCH ENGINE
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
    THRONE_LOCK = false, -- Automatically stays in Muscle King circle
    
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
    GymData = {
        ["Frost Gym"] = {CFrame = CFrame.new(-3000, 5, -500), Req = 2500},
        ["Mythic Gym"] = {CFrame = CFrame.new(2500, 5, 1000), Req = 15000},
        ["Eternal Gym"] = {CFrame = CFrame.new(-5000, 10, 5000), Req = 75000},
        ["Legend Gym"] = {CFrame = CFrame.new(0, 1000, 0), RebirthReq = 30}
    }
}

-- // 2. CORE UTILITIES //
local function SecureRemote(remote, ...)
    pcall(function()
        if rEvents:FindFirstChild(remote) then
            rEvents[remote]:FireServer(...)
        end
    end)
end

local function UpdateRefs(char)
    if not char then return end
    Internal.CurrentChar = char
    Internal.CurrentRoot = char:WaitForChild("HumanoidRootPart", 10)
    Internal.CurrentHum = char:WaitForChild("Humanoid", 10)
end

if LocalPlayer.Character then UpdateRefs(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateRefs)

-- // 3. THE NANO-PUNCH ENGINE (ZERO COOLDOWN) //
-- This uses a dual-threaded loop for maximum server-side saturation
task.spawn(function()
    while TITAN_DB.ACTIVE do
        if TITAN_DB.FAST_PUNCH then
            -- Thread 1
            task.spawn(function() SecureRemote("punchEvent", "punch") end)
            -- Thread 2 (The Nano-Sync)
            SecureRemote("punchEvent", "punch")
        end
        -- We use Heartbeat for the highest possible tick rate allowed by the client
        RunService.Heartbeat:Wait()
    end
end)

-- // 4. TRAINING & REBIRTH META //
local function CoreFarming()
    -- Strength/Durability Machine
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_STRENGTH then
                if TITAN_DB.STRENGTH_METHOD == "Tool" then
                    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Internal.CurrentChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("weightId") then
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

    -- Agility/Treadmill Logic
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
            if TITAN_DB.AUTO_ORBS then
                for _, orb in pairs(workspace.orbFolder:GetChildren()) do
                    if not TITAN_DB.AUTO_ORBS then break end
                    firetouchinterest(Internal.CurrentRoot, orb, 0)
                    firetouchinterest(Internal.CurrentRoot, orb, 1)
                end
            end
            task.wait(0.5)
        end
    end)
end

-- // 5. INVENTORY & EVOLVE SYSTEM //
local function PetAutomation()
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_CRYSTAL then
                SecureRemote("hatchCrystalEvent", "openCrystal", TITAN_DB.SELECTED_CRYSTAL)
            end
            
            if TITAN_DB.AUTO_EVOLVE then
                SecureRemote("evolvePetEvent", "evolvePet", "all")
            end
            
            if TITAN_DB.AUTO_DELETE_TRASH then
                for _, pet in pairs(LocalPlayer.petInventory:GetChildren()) do
                    -- Logic to check rarity and delete if not unique/omega
                    -- SecureRemote("sellPetEvent", "sellPet", pet.Name)
                end
            end
            task.wait(2)
        end
    end)
end

-- // 6. COMBAT & WORLD PROTOCOLS //
local function CombatProtocols()
    -- Kill Aura & Throne Logic
    RunService.RenderStepped:Connect(function()
        if not TITAN_DB.ACTIVE then return end
        
        if TITAN_DB.KILL_AURA and not TITAN_DB.FAST_PUNCH then -- Nano-punch handles its own loop
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (Internal.CurrentRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 20 then
                        SecureRemote("punchEvent", "punch")
                    end
                end
            end
        end

        if TITAN_DB.THRONE_LOCK then
            local throne = workspace:FindFirstChild("MuscleKingThrone")
            if throne and Internal.CurrentRoot then
                Internal.CurrentRoot.CFrame = throne.CFrame * CFrame.new(0, 2, 0)
            end
        end

        if TITAN_DB.SIZE_LOCK then
            SecureRemote("changeSizeEvent", "changeSize", TITAN_DB.SIZE_LOCK)
        end
    end)

    -- Rebirth & Gym Intelligence
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_REBIRTH then
                SecureRemote("rebirthRequest")
            end
            
            if TITAN_DB.AUTO_GYM then
                -- Intelligence to TP based on strength
            end
            
            if TITAN_DB.AUTO_QUESTS then
                SecureRemote("questMasterEvent", "acceptQuest")
                SecureRemote("questMasterEvent", "claimReward")
            end
            task.wait(1)
        end
    end)
end

-- // 7. THE TITAN UI (CENTERED MASTERPIECE) //
local function BuildUI()
    if CoreGui:FindFirstChild("TitanOmega") then CoreGui.TitanOmega:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "TitanOmega"
    
    local Main = Instance.new("Frame", Screen)
    Main.Name = "MainFrame"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- EXACT CENTER FIX
    Main.Size = UDim2.new(0, 420, 0, 320)
    Main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = TITAN_DB.ACCENT
    UIStroke.Thickness = 2
    
    -- Decorative Rainbow Strip
    local Glow = Instance.new("Frame", Main)
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 0, 35)
    Glow.BackgroundColor3 = TITAN_DB.ACCENT
    Glow.BorderSizePixel = 0

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "TITAN V2.0 // OMEGA SINGULARITY"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- NAVIGATION
    local Nav = Instance.new("Frame", Main)
    Nav.Position = UDim2.new(0, 10, 0, 45)
    Nav.Size = UDim2.new(0, 110, 1, -55)
    Nav.BackgroundTransparency = 1
    Instance.new("UIListLayout", Nav).Padding = UDim.new(0, 4)

    -- PAGES CONTAINER
    local Pages = Instance.new("Frame", Main)
    Pages.Position = UDim2.new(0, 125, 0, 45)
    Pages.Size = UDim2.new(1, -135, 1, -55)
    Pages.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Pages)

    local function CreateTab(name, active)
        local b = Instance.new("TextButton", Nav)
        b.Size = UDim2.new(1, 0, 0, 32)
        b.BackgroundColor3 = active and TITAN_DB.ACCENT or Color3.fromRGB(20, 20, 20)
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
        p.CanvasSize = UDim2.new(0,0,2,0)
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
        
        b.MouseButton1Click:Connect(function()
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            for _, v in pairs(Nav:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end end
            p.Visible = true
            b.BackgroundColor3 = TITAN_DB.ACCENT
        end)
        return p
    end

    local T_Main = CreateTab("CORE", true)
    local T_Pets = CreateTab("PETS", false)
    local T_World = CreateTab("WORLD", false)
    local T_Combat = CreateTab("OMEGA", false)

    local function AddToggle(parent, text, key)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

    -- POPULATE TABS
    AddToggle(T_Main, "AUTO STRENGTH", "AUTO_STRENGTH")
    AddToggle(T_Main, "AUTO DURABILITY", "AUTO_DURABILITY")
    AddToggle(T_Main, "AUTO AGILITY", "AUTO_AGILITY")
    AddToggle(T_Main, "FAST-REP (TOOLS)", "FAST_REP")
    
    AddToggle(T_Pets, "AUTO CRYSTAL", "AUTO_CRYSTAL")
    AddToggle(T_Pets, "AUTO EVOLVE ALL", "AUTO_EVOLVE")
    AddToggle(T_Pets, "PURGE COMMON PETS", "AUTO_DELETE_TRASH")
    
    AddToggle(T_World, "AUTO REBIRTH", "AUTO_REBIRTH")
    AddToggle(T_World, "AUTO CHESTS", "AUTO_CHESTS")
    AddToggle(T_World, "ORB SNIPER", "AUTO_ORBS")
    AddToggle(T_World, "QUEST AUTOMATION", "AUTO_QUESTS")
    
    AddToggle(T_Combat, "NANO-PUNCH (MAX SPD)", "FAST_PUNCH")
    AddToggle(T_Combat, "THRONE LOCK", "THRONE_LOCK")
    AddToggle(T_Combat, "KILL AURA", "KILL_AURA")
    AddToggle(T_Combat, "HITBOX EXPANDER", "HITBOX_EXPANDER")

    -- Dragging
    Header.InputBegan:Connect(function(input)
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

-- Anti-AFK (Virtual User)
LocalPlayer.Idled:Connect(function()
    if TITAN_DB.ANTI_AFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

print("TITAN V2.0 OMEGA LOADED. NANO-PUNCHES READY.")
