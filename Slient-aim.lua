-- The Strongest Battlegrounds Silent Aim
-- By Mr_Rock20

print("Loading TSB Silent Aim...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = false,
    FOV = 200,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetPart = "HumanoidRootPart", -- HumanoidRootPart, Head, UpperTorso
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Color = Settings.FOVColor
FOVCircle.Transparency = 1
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Functions
local function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsVisible(targetPart)
    if not Settings.VisibleCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local rayResult = Workspace:Raycast(origin, direction, raycastParams)
    
    return rayResult == nil
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            -- Team Check
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local targetPart = character:FindFirstChild(Settings.TargetPart)
            
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        if IsVisible(targetPart) then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Namecall Hook for Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.Enabled and method == "FireServer" then
        local closestPlayer = GetClosestPlayer()
        
        if closestPlayer and closestPlayer.Character then
            local targetPart = closestPlayer.Character:FindFirstChild(Settings.TargetPart)
            
            if targetPart then
                -- Modify arguments to target the closest player
                args[1] = targetPart.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TSBSilentAim"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

local MainBorder = Instance.new("UIStroke")
MainBorder.Parent = MainFrame
MainBorder.Thickness = 2
MainBorder.Color = Color3.fromRGB(255, 255, 255)
MainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "TSB Silent Aim"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 5)
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
Content.Position = UDim2.new(0, 10, 0, 50)
Content.Size = UDim2.new(1, -20, 1, -60)

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Content
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Size = UDim2.new(1, 0, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Team Check Toggle
local TeamCheckButton = Instance.new("TextButton")
TeamCheckButton.Parent = Content
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TeamCheckButton.BorderSizePixel = 0
TeamCheckButton.Position = UDim2.new(0, 0, 0, 50)
TeamCheckButton.Size = UDim2.new(1, 0, 0, 35)
TeamCheckButton.Font = Enum.Font.Gotham
TeamCheckButton.Text = "Team Check: OFF"
TeamCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamCheckButton.TextSize = 14

local TeamCheckCorner = Instance.new("UICorner")
TeamCheckCorner.CornerRadius = UDim.new(0, 8)
TeamCheckCorner.Parent = TeamCheckButton

-- Visible Check Toggle
local VisibleCheckButton = Instance.new("TextButton")
VisibleCheckButton.Parent = Content
VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
VisibleCheckButton.BorderSizePixel = 0
VisibleCheckButton.Position = UDim2.new(0, 0, 0, 95)
VisibleCheckButton.Size = UDim2.new(1, 0, 0, 35)
VisibleCheckButton.Font = Enum.Font.Gotham
VisibleCheckButton.Text = "Visible Check: OFF"
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
FOVToggleButton.Position = UDim2.new(0, 0, 0, 140)
FOVToggleButton.Size = UDim2.new(1, 0, 0, 35)
FOVToggleButton.Font = Enum.Font.Gotham
FOVToggleButton.Text = "Show FOV: ON"
FOVToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggleButton.TextSize = 14

local FOVToggleCorner = Instance.new("UICorner")
FOVToggleCorner.CornerRadius = UDim.new(0, 8)
FOVToggleCorner.Parent = FOVToggleButton

-- FOV Slider Label
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = Content
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 0, 0, 185)
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.Text = "FOV Size: " .. Settings.FOV
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 14

-- FOV Slider
local FOVSlider = Instance.new("TextButton")
FOVSlider.Parent = Content
FOVSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FOVSlider.BorderSizePixel = 0
FOVSlider.Position = UDim2.new(0, 0, 0, 210)
FOVSlider.Size = UDim2.new(1, 0, 0, 30)
FOVSlider.Text = ""

local FOVSliderCorner = Instance.new("UICorner")
FOVSliderCorner.CornerRadius = UDim.new(0, 8)
FOVSliderCorner.Parent = FOVSlider

local FOVSliderFill = Instance.new("Frame")
FOVSliderFill.Parent = FOVSlider
FOVSliderFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
FOVSliderFill.BorderSizePixel = 0
FOVSliderFill.Size = UDim2.new(Settings.FOV / 500, 0, 1, 0)

local FOVSliderFillCorner = Instance.new("UICorner")
FOVSliderFillCorner.CornerRadius = UDim.new(0, 8)
FOVSliderFillCorner.Parent = FOVSliderFill

-- Button Events
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleButton.Text = "Silent Aim: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        ToggleButton.Text = "Silent Aim: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

TeamCheckButton.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    if Settings.TeamCheck then
        TeamCheckButton.Text = "Team Check: ON"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        TeamCheckButton.Text = "Team Check: OFF"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

VisibleCheckButton.MouseButton1Click:Connect(function()
    Settings.VisibleCheck = not Settings.VisibleCheck
    if Settings.VisibleCheck then
        VisibleCheckButton.Text = "Visible Check: ON"
        VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        VisibleCheckButton.Text = "Visible Check: OFF"
        VisibleCheckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

FOVToggleButton.MouseButton1Click:Connect(function()
    Settings.ShowFOV = not Settings.ShowFOV
    FOVCircle.Visible = Settings.ShowFOV
    if Settings.ShowFOV then
        FOVToggleButton.Text = "Show FOV: ON"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        FOVToggleButton.Text = "Show FOV: OFF"
        FOVToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
end)

-- FOV Slider Logic
local dragging = false
FOVSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = FOVSlider.AbsolutePosition
        local sliderSize = FOVSlider.AbsoluteSize
        
        local relativePos = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
        local percentage = relativePos / sliderSize.X
        
        Settings.FOV = math.floor(percentage * 500)
        FOVLabel.Text = "FOV Size: " .. Settings.FOV
        FOVSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        FOVCircle.Radius = Settings.FOV
    end
    
    -- Update FOV Circle Position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

print("✅ TSB Silent Aim Loaded!")
print("Toggle with the GUI")
