-- The Strongest Battlegrounds Silent Aim
-- By Mr_Rock20
-- Compatible with Xeno and most executors

print("Loading TSB Silent Aim...")

-- Check for required functions
if not Drawing then
    warn("Drawing API not supported on this executor!")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = true,
    FOV = 150,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetPart = "HumanoidRootPart",
    Smoothness = 0.1
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Color = Settings.FOVColor
FOVCircle.Transparency = 1
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Target Tracer (optional)
local Tracer = Drawing.new("Line")
Tracer.Thickness = 2
Tracer.Color = Color3.fromRGB(255, 0, 0)
Tracer.Transparency = 1
Tracer.Visible = false

-- Functions
local function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    return humanoid and rootPart and humanoid.Health > 0
end

local function GetCharacter(player)
    return player.Character
end

local function GetRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function IsVisible(character)
    if not Settings.VisibleCheck then return true end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    
    local origin = Camera.CFrame.Position
    local target = rootPart.Position
    local direction = (target - origin)
    
    local ray = Ray.new(origin, direction)
    local part, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
    
    return part == nil or part:IsDescendantOf(character)
end

local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team Check
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            if IsAlive(player) then
                local character = GetCharacter(player)
                if character then
                    local targetPart = character:FindFirstChild(Settings.TargetPart) or GetRootPart(character)
                    
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        
                        if onScreen then
                            local screenPosition = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (screenPosition - mousePos).Magnitude
                            
                            if distance < Settings.FOV and distance < shortestDistance then
                                if IsVisible(character) then
                                    closestPlayer = player
                                    shortestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Silent Aim Target
local CurrentTarget = nil

-- Hook for Xeno compatibility
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.Enabled and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(Settings.TargetPart)
        
        if targetPart and (method == "FireServer" or method == "InvokeServer") then
            -- TSB specific hooks
            if tostring(self) == "Slam" or tostring(self) == "Combat" or tostring(self):find("Attack") then
                args[1] = targetPart.Position
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TSBSilentAim"
ScreenGui.ResetOnSpawn = false

-- Try to parent to CoreGui, fallback to PlayerGui
local success = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true

local MainBorder = Instance.new("UIStroke")
MainBorder.Parent = MainFrame
MainBorder.Thickness = 3
MainBorder.Color = Color3.fromRGB(255, 255, 255)
MainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ TSB Silent Aim"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -38, 0, 8)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Content Frame
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 15, 0, 60)
Content.Size = UDim2.new(1, -30, 1, -75)

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Content
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Size = UDim2.new(1, 0, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🎯 Silent Aim: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Team Check
local TeamCheckButton = Instance.new("TextButton")
TeamCheckButton.Parent = Content
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TeamCheckButton.BorderSizePixel = 0
TeamCheckButton.Position = UDim2.new(0, 0, 0, 55)
TeamCheckButton.Size = UDim2.new(1, 0, 0, 38)
TeamCheckButton.Font = Enum.Font.Gotham
TeamCheckButton.Text = "👥 Team Check: OFF"
TeamCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckButton.TextSize = 14

local TeamCheckCorner = Instance.new("UICorner")
TeamCheckCorner.CornerRadius = UDim.new(0, 8)
TeamCheckCorner.Parent = TeamCheckButton

-- Visible Check
local VisibleCheckButton = Instance.new("TextButton")
VisibleCheckButton.Parent = Content
VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
VisibleCheckButton.BorderSizePixel = 0
VisibleCheckButton.Position = UDim2.new(0, 0, 0, 103)
VisibleCheckButton.Size = UDim2.new(1, 0, 0, 38)
VisibleCheckButton.Font = Enum.Font.Gotham
VisibleCheckButton.Text = "👁️ Visible Check: ON"
VisibleCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VisibleCheckButton.TextSize = 14

local VisibleCheckCorner = Instance.new("UICorner")
VisibleCheckCorner.CornerRadius = UDim.new(0, 8)
VisibleCheckCorner.Parent = VisibleCheckButton

-- FOV Toggle
local FOVToggleButton = Instance.new("TextButton")
FOVToggleButton.Parent = Content
FOVToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
FOVToggleButton.BorderSizePixel = 0
FOVToggleButton.Position = UDim2.new(0, 0, 0, 151)
FOVToggleButton.Size = UDim2.new(1, 0, 0, 38)
FOVToggleButton.Font = Enum.Font.Gotham
FOVToggleButton.Text = "⭕ Show FOV: ON"
FOVToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggleButton.TextSize = 14

local FOVToggleCorner = Instance.new("UICorner")
FOVToggleCorner.CornerRadius = UDim.new(0, 8)
FOVToggleCorner.Parent = FOVToggleButton

-- FOV Label
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = Content
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 0, 0, 199)
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.Text = "🎯 FOV Size: " .. Settings.FOV
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 14
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FOV Slider
local FOVSlider = Instance.new("TextButton")
FOVSlider.Parent = Content
FOVSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FOVSlider.BorderSizePixel = 0
FOVSlider.Position = UDim2.new(0, 0, 0, 229)
FOVSlider.Size = UDim2.new(1, 0, 0, 32)
FOVSlider.Text = ""

local FOVSliderCorner = Instance.new("UICorner")
FOVSliderCorner.CornerRadius = UDim.new(0, 8)
FOVSliderCorner.Parent = FOVSlider

local FOVSliderFill = Instance.new("Frame")
FOVSliderFill.Parent = FOVSlider
FOVSliderFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
FOVSliderFill.BorderSizePixel = 0
FOVSliderFill.Size = UDim2.new(Settings.FOV / 400, 0, 1, 0)

local FOVSliderFillCorner = Instance.new("UICorner")
FOVSliderFillCorner.CornerRadius = UDim.new(0, 8)
FOVSliderFillCorner.Parent = FOVSliderFill

-- Credits
local Credits = Instance.new("TextLabel")
Credits.Parent = Content
Credits.BackgroundTransparency = 1
Credits.Position = UDim2.new(0, 0, 1, -20)
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Font = Enum.Font.Gotham
Credits.Text = "By Mr_Rock20"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.TextSize = 12

-- Button Events
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleButton.Text = "🎯 Silent Aim: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        ToggleButton.Text = "🎯 Silent Aim: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

TeamCheckButton.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    if Settings.TeamCheck then
        TeamCheckButton.Text = "👥 Team Check: ON"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        TeamCheckButton.Text = "👥 Team Check: OFF"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

VisibleCheckButton.MouseButton1Click:Connect(function()
    Settings.VisibleCheck = not Settings.VisibleCheck
    if Settings.VisibleCheck then
        VisibleCheckButton.Text = "👁️ Visible Check: ON"
        VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        VisibleCheckButton.Text = "👁️ Visible Check: OFF"
        VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

FOVToggleButton.MouseButton1Click:Connect(function()
    Settings.ShowFOV = not Settings.ShowFOV
    FOVCircle.Visible = Settings.ShowFOV
    if Settings.ShowFOV then
        FOVToggleButton.Text = "⭕ Show FOV: ON"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        FOVToggleButton.Text = "⭕ Show FOV: OFF"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    Tracer:Remove()
end)

-- FOV Slider
local dragging = false
FOVSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.FOV
    
    -- Handle FOV Slider
    if dragging then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = FOVSlider.AbsolutePosition
        local sliderSize = FOVSlider.AbsoluteSize
        
        local relativePos = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
        local percentage = relativePos / sliderSize.X
        
        Settings.FOV = math.floor(percentage * 400)
        FOVLabel.Text = "🎯 FOV Size: " .. Settings.FOV
        FOVSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    end
    
    -- Update Target
    if Settings.Enabled then
        CurrentTarget = GetClosestPlayerInFOV()
    else
        CurrentTarget = nil
    end
end)

-- Rainbow Border
spawn(function()
    while wait() do
        for i = 0, 1, 0.01 do
            MainBorder.Color = Color3.fromHSV(i, 1, 1)
            wait(0.05)
        end
    end
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ TSB Silent Aim Loaded!")
print("👨‍💻 By Mr_Rock20")
print("🎮 Executor: Xeno Compatible")
print("🎯 Game: The Strongest Battlegrounds")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
