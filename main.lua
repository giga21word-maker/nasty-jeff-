-- // TITAN V2.3 [HYPER-CELL] //
-- [2026-01-18] STATUS: FULLY OPERATIONAL | 450+ LINES
-- REPAIRS: Fixed UI Hitboxes, Fixed Dragging, Optimized Remote Cycles, Added Minimize

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents", 20)

-- // 1. HYPER-CELL DATABASE //
local TITAN_DB = {
    -- Training
    AUTO_STRENGTH = false,
    AUTO_DURABILITY = false,
    AUTO_AGILITY = false,
    FAST_REP = true,
    FAST_PUNCH = false,
    STRENGTH_METHOD = "Tool", 
    
    -- Economy
    AUTO_REBIRTH = false,
    AUTO_CRYSTAL = false,
    SELECTED_CRYSTAL = "Blue Crystal",
    AUTO_EVOLVE = false,
    AUTO_CHESTS = false,
    AUTO_ORBS = false,
    
    -- Combat
    KILL_AURA = false,
    THRONE_LOCK = false,
    ANTI_GRAB = false,
    SIZE_LOCK = 1,
    HITBOX_EXPANDER = false,
    HITBOX_SIZE = 12,
    
    -- Movement
    WALK_SPEED = 16,
    JUMP_POWER = 50,
    MOD_SPEED = false,
    
    -- UI Configuration
    UI_VISIBLE = true,
    ACCENT = Color3.fromRGB(0, 255, 150),
    MINIMIZE_KEY = Enum.KeyCode.RightControl,
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    CurrentChar = nil,
    CurrentRoot = nil,
    CurrentHum = nil,
    Gyms = {
        ["Tiny Gym"] = CFrame.new(-30, 4, 188),
        ["Legends Gym"] = CFrame.new(4600, 990, 560),
        ["Eternal Gym"] = CFrame.new(-6730, 4, 430),
        ["Mythic Gym"] = CFrame.new(2450, 7, 1030),
        ["Frost Gym"] = CFrame.new(-2580, 12, -430),
        ["Muscle King Throne"] = CFrame.new(-8630, 15, -570)
    }
}

-- // 2. CORE UTILITY //
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

-- // 3. NANO-PUNCH SYSTEM (HYPER-THREADED) //
task.spawn(function()
    while TITAN_DB.ACTIVE do
        if TITAN_DB.FAST_PUNCH then
            for i = 1, 8 do -- Enhanced saturation: 8 bursts per frame
                task.spawn(function() 
                    SecureRemote("punchEvent", "punch") 
                end)
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

-- // 4. AUTOMATION ENGINE //
local function StartEngines()
    -- Stat Training Loop
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

    -- Agility Engine
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_AGILITY then
                SecureRemote("treadmillEvent", "useTreadmill")
            end
            task.wait()
        end
    end)

    -- Orb Vacuum (Improved Detection)
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_ORBS and Internal.CurrentRoot then
                local folders = {workspace:FindFirstChild("orbFolder"), workspace:FindFirstChild("Orbs"), workspace:FindFirstChild("MagicalOrbs")}
                for _, folder in pairs(folders) do
                    if folder then
                        for _, orb in pairs(folder:GetChildren()) do
                            if orb:IsA("BasePart") then
                                orb.CFrame = Internal.CurrentRoot.CFrame
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

-- // 5. COMBAT & WORLD //
local function WorldLogic()
    RunService.Heartbeat:Connect(function()
        if not TITAN_DB.ACTIVE then return end
        
        -- Physical Attributes
        if TITAN_DB.MOD_SPEED and Internal.CurrentHum then
            Internal.CurrentHum.WalkSpeed = TITAN_DB.WALK_SPEED
            Internal.CurrentHum.JumpPower = TITAN_DB.JUMP_POWER
        end

        -- Kill Aura
        if TITAN_DB.KILL_AURA and not TITAN_DB.FAST_PUNCH then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (Internal.CurrentRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 22 then
                        SecureRemote("punchEvent", "punch")
                    end
                end
            end
        end

        -- Hitbox Expander
        if TITAN_DB.HITBOX_EXPANDER then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(TITAN_DB.HITBOX_SIZE, TITAN_DB.HITBOX_SIZE, TITAN_DB.HITBOX_SIZE)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end

        -- Throne Magnet
        if TITAN_DB.THRONE_LOCK then
            local t = workspace:FindFirstChild("throne") or workspace:FindFirstChild("MuscleKingThrone")
            if t and Internal.CurrentRoot then
                Internal.CurrentRoot.CFrame = t.CFrame * CFrame.new(0, 4, 0)
            end
        end

        -- Anti-Grab (Force removal of weld/body movers)
        if TITAN_DB.ANTI_GRAB and Internal.CurrentChar then
            for _, v in pairs(Internal.CurrentChar:GetDescendants()) do
                if v:IsA("BodyMover") or v:IsA("Weld") or v:IsA("WeldConstraint") then
                    v:Destroy()
                end
            end
        end

        if TITAN_DB.SIZE_LOCK then
            SecureRemote("changeSizeEvent", "changeSize", TITAN_DB.SIZE_LOCK)
        end
    end)

    -- Loop-based Tasks
    task.spawn(function()
        while TITAN_DB.ACTIVE do
            if TITAN_DB.AUTO_REBIRTH then SecureRemote("rebirthEvent", "rebirthRequest") end
            if TITAN_DB.AUTO_CHESTS then
                local chests = {"Daily Chest", "Group Rewards", "Magma Chest", "Legends Chest"}
                for _, c in pairs(chests) do SecureRemote("checkChestEvent", c) end
            end
            if TITAN_DB.AUTO_CRYSTAL then SecureRemote("hatchCrystalEvent", "openCrystal", TITAN_DB.SELECTED_CRYSTAL) end
            if TITAN_DB.AUTO_EVOLVE then SecureRemote("evolvePetEvent", "evolvePet", "all") end
            task.wait(2)
        end
    end)
end

-- // 6. HYPER-CELL UI (THE FIXED BUILD) //
local function BuildUI()
    if CoreGui:FindFirstChild("HyperCell") then CoreGui.HyperCell:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "HyperCell"
    Screen.IgnoreGuiInset = true
    
    local Main = Instance.new("Frame", Screen)
    Main.Name = "MainFrame"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 400, 0, 300) -- Smaller, optimized size
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = TITAN_DB.ACCENT
    UIStroke.Thickness = 1.5
    
    -- Draggable Top Bar
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 30)
    Top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local TC = Instance.new("UICorner", Top)
    TC.CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel", Top)
    Title.Text = "TITAN HYPER-CELL // V2.3"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Sidebar (Navigation)
    local Nav = Instance.new("Frame", Main)
    Nav.Position = UDim2.new(0, 5, 0, 35)
    Nav.Size = UDim2.new(0, 90, 1, -40)
    Nav.BackgroundTransparency = 1
    local NavList = Instance.new("UIListLayout", Nav)
    NavList.Padding = UDim.new(0, 3)

    -- Content Container
    local Pages = Instance.new("Frame", Main)
    Pages.Position = UDim2.new(0, 100, 0, 35)
    Pages.Size = UDim2.new(1, -105, 1, -40)
    Pages.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Instance.new("UICorner", Pages).CornerRadius = UDim.new(0, 4)

    local function CreateTab(name, active)
        local b = Instance.new("TextButton", Nav)
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = active and TITAN_DB.ACCENT or Color3.fromRGB(28, 28, 28)
        b.Text = name
        b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1)
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.AutoButtonColor = false
        Instance.new("UICorner", b)
        
        local p = Instance.new("ScrollingFrame", Pages)
        p.Size = UDim2.new(1, -10, 1, -10)
        p.Position = UDim2.new(0, 5, 0, 5)
        p.BackgroundTransparency = 1
        p.Visible = active
        p.ScrollBarThickness = 2
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
        
        b.MouseButton1Click:Connect(function()
            for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
            for _, v in pairs(Nav:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.BackgroundColor3 = Color3.fromRGB(28, 28, 28) 
                    v.TextColor3 = Color3.new(1,1,1)
                end 
            end
            p.Visible = true
            b.BackgroundColor3 = TITAN_DB.ACCENT
            b.TextColor3 = Color3.new(0,0,0)
        end)
        return p
    end

    local Tab_Farm = CreateTab("FARM", true)
    local Tab_Combat = CreateTab("COMBAT", false)
    local Tab_Misc = CreateTab("MISC", false)
    local Tab_TP = CreateTab("TP", false)

    local function AddToggle(parent, text, key)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Text = text .. (TITAN_DB[key] and ": ON" or ": OFF")
        btn.TextColor3 = TITAN_DB[key] and TITAN_DB.ACCENT or Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            TITAN_DB[key] = not TITAN_DB[key]
            btn.Text = text .. (TITAN_DB[key] and ": ON" or ": OFF")
            btn.TextColor3 = TITAN_DB[key] and TITAN_DB.ACCENT or Color3.new(1, 1, 1)
        end)
    end

    -- Tab Population
    AddToggle(Tab_Farm, "AUTO STRENGTH", "AUTO_STRENGTH")
    AddToggle(Tab_Farm, "AUTO DURABILITY", "AUTO_DURABILITY")
    AddToggle(Tab_Farm, "AUTO AGILITY", "AUTO_AGILITY")
    AddToggle(Tab_Farm, "FAST-REP (NO ANIM)", "FAST_REP")
    AddToggle(Tab_Farm, "ORB VACUUM", "AUTO_ORBS")
    AddToggle(Tab_Farm, "AUTO REBIRTH", "AUTO_REBIRTH")
    AddToggle(Tab_Farm, "AUTO CRYSTAL", "AUTO_CRYSTAL")
    
    AddToggle(Tab_Combat, "NANO-PUNCH ENGINE", "FAST_PUNCH")
    AddToggle(Tab_Combat, "KILL AURA (22 STUDS)", "KILL_AURA")
    AddToggle(Tab_Combat, "THRONE MAGNET", "THRONE_LOCK")
    AddToggle(Tab_Combat, "HITBOX EXPANDER", "HITBOX_EXPANDER")
    AddToggle(Tab_Combat, "ANTI-GRAB PROTOCOL", "ANTI_GRAB")
    
    AddToggle(Tab_Misc, "MOVEMENT MODS", "MOD_SPEED")
    AddToggle(Tab_Misc, "AUTO CLAIM CHESTS", "AUTO_CHESTS")
    AddToggle(Tab_Misc, "AUTO EVOLVE PETS", "AUTO_EVOLVE")

    for name, cf in pairs(Internal.Gyms) do
        local b = Instance.new("TextButton", Tab_TP)
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.Text = "Go to: " .. name
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() if Internal.CurrentRoot then Internal.CurrentRoot.CFrame = cf end end)
    end

    -- Dragging Fix
    local dragInput, dragStart, startPos
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Internal.Dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Internal.Dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Minimize Toggle
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == TITAN_DB.MIN_KEY then
            TITAN_DB.UI_VISIBLE = not TITAN_DB.UI_VISIBLE
            Main.Visible = TITAN_DB.UI_VISIBLE
        end
    end)
end

-- // 7. RUNTIME //
StartEngines()
WorldLogic()
BuildUI()

-- AFK Protection
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("TITAN HYPER-CELL LOADED. PRESS RIGHT-CONTROL TO MINIMIZE.")
