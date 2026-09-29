local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local u10 = LocalPlayer:WaitForChild("PlayerGui")

-- Gold theme colors
local color3 = Color3.fromRGB(255, 190, 40)
local color3_2 = Color3.fromRGB(255, 220, 100)
local color3_3 = Color3.fromRGB(120, 75, 10)
local color3_4 = Color3.fromRGB(18, 12, 5)
local color3_5 = Color3.fromRGB(50, 35, 12)

-- Escape positions (anti chase teleport path)
local t1 = {
	CFrame.new(4747.71, 70.57, -335.25),
	CFrame.new(3520.94, 70.73, -343.74),
	CFrame.new(2446.02, 70.88, -351.18),
	CFrame.new(1352.11, 71.02, -358.75),
	CFrame.new(544.49, 71.13, -364.34)
}

-- State variables
local connection = nil
local t2 = {} -- stores original HoldDuration of prompts
local t3 = {} -- stores connections for prompt system
local t4 = {} -- intro letter labels
local u18 = false -- toggle state (Anti Chase on/off)
local n3 = 0 -- stroke gradient rotation
local n4 = 0 -- scan line position
local u72 = false -- dragging flag
local u73 = nil -- current drag input

-- Anti Chase core: teleports player through safe positions when prompt is triggered
local function v22()
	local Character = LocalPlayer.Character
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumanoidRootPart then
		return
	end

	local CFrame2 = CurrentCamera.CFrame
	local CameraType = CurrentCamera.CameraType
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.CFrame = CFrame2

	Humanoid.BreakJointsOnDeath = false
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			v.Enabled = true
		end
	end

	HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	for _, v in ipairs(t1) do
		Humanoid.PlatformStand = true
		Humanoid.Health = 100
		HumanoidRootPart.CFrame = v
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		CurrentCamera.CFrame = CFrame2
		task.wait(0.02)
	end

	local elapsed = os.clock()
	local connection2
	connection2 = RunService.Heartbeat:Connect(function()
		if os.clock() - elapsed > 0.35 then
			connection2:Disconnect()
			return
		end
		Humanoid.Health = 100
		Humanoid.PlatformStand = true
		HumanoidRootPart.CFrame = t1[#t1]
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		CurrentCamera.CFrame = CFrame2
	end)

	task.wait(0.35)
	Humanoid.PlatformStand = false
	CurrentCamera.CameraType = CameraType
end

-- Modify a single ProximityPrompt (make instant when enabled)
local function u23(p1, enable)
	if not p1 or typeof(p1) ~= "Instance" or not p1:IsA("ProximityPrompt") then
		return
	end
	if enable then
		if t2[p1] == nil then
			t2[p1] = p1.HoldDuration
		end
		p1.HoldDuration = 0
		p1.RequiresLineOfSight = false
	else
		if t2[p1] ~= nil then
			p1.HoldDuration = t2[p1]
			t2[p1] = nil
		end
	end
end

-- Enable / disable the instant prompt system
local function v24(enable)
	if enable then
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			u23(descendant, true)
		end
		table.insert(t3, Workspace.DescendantAdded:Connect(function(desc)
			u23(desc, true)
		end))
		table.insert(t3, ProximityPromptService.PromptShown:Connect(function(prompt)
			u23(prompt, true)
		end))
	else
		for _, v in ipairs(t3) do
			v:Disconnect()
		end
		t3 = {}
		for k, v in pairs(t2) do
			if k and k.Parent then
				k.HoldDuration = v
			end
		end
		t2 = {}
	end
end

-- ==================== INTRO ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VyreIntro"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = u10

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.ZIndex = 10
Frame.Parent = ScreenGui

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 12, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 0))
})
UIGradient.Rotation = 90
UIGradient.Parent = Frame

local Frame2 = Instance.new("Frame")
Frame2.AnchorPoint = Vector2.new(0.5, 0.5)
Frame2.Position = UDim2.new(0.5, 0, 0.46, 0)
Frame2.Size = UDim2.new(0, 320, 0, 90)
Frame2.BackgroundTransparency = 1
Frame2.ZIndex = 11
Frame2.Parent = Frame

local s1 = "VYRE"
local n1 = 20
local n2 = 60
local v33 = #s1 * n2 + (#s1 - 1) * n1

for i = 1, #s1 do
	local TextLabel = Instance.new("TextLabel")
	TextLabel.Size = UDim2.new(0, n2, 1, 0)
	local v36 = Frame2.Size.X.Offset / 2 - v33 / 2 + (i - 1) * (n2 + n1)
	TextLabel.Position = UDim2.new(0, v36, 0, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = s1:sub(i, i)
	TextLabel.Font = Enum.Font.GothamBlack
	TextLabel.TextSize = 64
	TextLabel.TextColor3 = color3
	TextLabel.TextTransparency = 1
	TextLabel.TextStrokeTransparency = 1
	TextLabel.TextStrokeColor3 = color3_3
	TextLabel.ZIndex = 11
	TextLabel.Parent = Frame2
	t4[i] = TextLabel
end

local Frame3 = Instance.new("Frame")
Frame3.AnchorPoint = Vector2.new(0.5, 0.5)
Frame3.Position = UDim2.new(0.5, 0, 0.46, 58)
Frame3.Size = UDim2.new(0, 0, 0, 2)
Frame3.BackgroundColor3 = color3
Frame3.BorderSizePixel = 0
Frame3.BackgroundTransparency = 0.15
Frame3.ZIndex = 11
Frame3.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Frame3

local UIGradient2 = Instance.new("UIGradient")
UIGradient2.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 30)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 230, 140)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 30))
})
UIGradient2.Parent = Frame3

local TextLabel = Instance.new("TextLabel")
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.new(0.5, 0, 0.46, 84)
TextLabel.Size = UDim2.new(0, 400, 0, 20)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "V Y R E   S C R I P T S"
TextLabel.Font = Enum.Font.GothamMedium
TextLabel.TextSize = 14
TextLabel.TextColor3 = Color3.fromRGB(230, 180, 60)
TextLabel.TextTransparency = 1
TextLabel.ZIndex = 11
TextLabel.Parent = Frame

for i, v in ipairs(t4) do
	task.delay(0.25 + (i - 1) * 0.22, function()
		TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			TextTransparency = 0,
			TextStrokeTransparency = 0.55
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Back), {
			TextSize = 72
		}):Play()
		task.delay(0.18, function()
			TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
				TextSize = 64
			}):Play()
		end)
	end)
end

task.delay(1.15, function()
	TweenService:Create(Frame3, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
		Size = UDim2.new(0, 300, 0, 2)
	}):Play()
end)

task.delay(1.45, function()
	TweenService:Create(TextLabel, TweenInfo.new(0.5), {
		TextTransparency = 0
	}):Play()
end)

task.delay(2.9, function()
	for _, v in ipairs(t4) do
		TweenService:Create(v, TweenInfo.new(0.4), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	end
	TweenService:Create(TextLabel, TweenInfo.new(0.4), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(Frame3, TweenInfo.new(0.4), {
		Size = UDim2.new(0, 0, 0, 2),
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(Frame, TweenInfo.new(0.7), {
		BackgroundTransparency = 1
	}):Play()
end)

task.delay(3.7, function()
	ScreenGui:Destroy()
end)

-- ==================== MAIN GUI ====================
if u10:FindFirstChild("VyreScripts") then
	u10.VyreScripts:Destroy()
end

local ScreenGui2 = Instance.new("ScreenGui")
ScreenGui2.Name = "VyreScripts"
ScreenGui2.ResetOnSpawn = false
ScreenGui2.IgnoreGuiInset = true
ScreenGui2.DisplayOrder = 1000
ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui2.Parent = u10

-- Floating V logo toggle
local VLogo = Instance.new("TextButton")
VLogo.Name = "VLogoToggle"
VLogo.Size = UDim2.fromOffset(52, 52)
VLogo.Position = UDim2.new(0, 18, 0.5, -26)
VLogo.BackgroundColor3 = color3_4
VLogo.BorderSizePixel = 0
VLogo.Text = "V"
VLogo.TextColor3 = color3_2
VLogo.Font = Enum.Font.GothamBlack
VLogo.TextSize = 24
VLogo.AutoButtonColor = false
VLogo.Active = true
VLogo.Visible = true
VLogo.ZIndex = 100
VLogo.Parent = ScreenGui2

local VLogoCorner = Instance.new("UICorner")
VLogoCorner.CornerRadius = UDim.new(1, 0)
VLogoCorner.Parent = VLogo

local VLogoStroke = Instance.new("UIStroke")
VLogoStroke.Color = color3
VLogoStroke.Thickness = 2
VLogoStroke.Parent = VLogo

local VLogoScale = Instance.new("UIScale")
VLogoScale.Parent = VLogo

local mainUIVisible = true
local Frame4
local Frame5

-- V logo toggle + mobile-friendly dragging
local logoDragging = false
local logoDragInput = nil
local logoDragStart = nil
local logoStartPosition = nil
local logoMoved = false

local function setMainUIVisible(state)
	mainUIVisible = state
	if Frame4 then Frame4.Visible = state end
	if Frame5 then Frame5.Visible = state end
end

local function beginLogoDrag(input)
	logoDragging = true
	logoMoved = false
	logoDragStart = input.Position
	logoStartPosition = VLogo.Position
	logoDragInput = input
end

VLogo.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		beginLogoDrag(input)
	end
end)

VLogo.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		logoDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not logoDragging or input ~= logoDragInput then
		return
	end
	local delta = input.Position - logoDragStart
	if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
		logoMoved = true
	end
	VLogo.Position = UDim2.new(
		logoStartPosition.X.Scale,
		logoStartPosition.X.Offset + delta.X,
		logoStartPosition.Y.Scale,
		logoStartPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if logoDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		logoDragging = false
		logoDragInput = nil
	end
end)

VLogo.Activated:Connect(function()
	if logoMoved then
		logoMoved = false
		return
	end
	setMainUIVisible(not mainUIVisible)
end)

Frame4 = Instance.new("Frame")
Frame4.Size = UDim2.new(0, 244, 0, 164)
Frame4.Position = UDim2.new(0.5, -122, 0.4, -82)
Frame4.BackgroundColor3 = color3
Frame4.BackgroundTransparency = 0.85
Frame4.BorderSizePixel = 0
Frame4.ZIndex = 1
Frame4.Parent = ScreenGui2

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 20)
UICorner2.Parent = Frame4

task.spawn(function()
	while Frame4.Parent do
		TweenService:Create(Frame4, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			BackgroundTransparency = 0.72
		}):Play()
		task.wait(1.5)
		if not Frame4.Parent then
			return
		end
		TweenService:Create(Frame4, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			BackgroundTransparency = 0.88
		}):Play()
		task.wait(1.5)
	end
end)

Frame5 = Instance.new("Frame")
Frame5.Size = UDim2.new(0, 220, 0, 140)
Frame5.Position = UDim2.new(0.5, -110, 0.4, -70)
Frame5.BackgroundColor3 = color3_4
Frame5.BorderSizePixel = 0
Frame5.ClipsDescendants = true
Frame5.Active = true
Frame5.ZIndex = 2
Frame5.Parent = ScreenGui2

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 12)
UICorner3.Parent = Frame5

local UIGradient3 = Instance.new("UIGradient")
UIGradient3.Color = ColorSequence.new(Color3.fromRGB(28, 20, 8), Color3.fromRGB(12, 8, 3))
UIGradient3.Rotation = 135
UIGradient3.Parent = Frame5

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = color3
UIStroke.Thickness = 1.6
UIStroke.Transparency = 0.1
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Frame5

local UIGradient4 = Instance.new("UIGradient")
UIGradient4.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 40)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90, 55, 10)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 220, 100)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(90, 55, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 190, 40))
})
UIGradient4.Parent = UIStroke

task.spawn(function()
	local connection3
	connection3 = RunService.RenderStepped:Connect(function(dt)
		if not UIGradient4.Parent then
			connection3:Disconnect()
			return
		end
		n3 = (n3 + dt * 110) % 360
		UIGradient4.Rotation = n3
	end)
end)

local Frame6 = Instance.new("Frame")
Frame6.Size = UDim2.new(1, 0, 1, 0)
Frame6.BackgroundTransparency = 1
Frame6.ZIndex = 2
Frame6.Parent = Frame5

for i = 1, 6 do
	local Frame7 = Instance.new("Frame")
	Frame7.Size = UDim2.new(1, 0, 0, 1)
	Frame7.Position = UDim2.new(0, 0, i * 0.16, 0)
	Frame7.BackgroundColor3 = color3
	Frame7.BackgroundTransparency = 0.94
	Frame7.BorderSizePixel = 0
	Frame7.ZIndex = 2
	Frame7.Parent = Frame6
end

local Frame8 = Instance.new("Frame")
Frame8.Size = UDim2.new(1, 0, 0, 14)
Frame8.Position = UDim2.new(0, 0, 0, -20)
Frame8.BackgroundColor3 = color3
Frame8.BackgroundTransparency = 0.82
Frame8.BorderSizePixel = 0
Frame8.ZIndex = 3
Frame8.Parent = Frame5

local UIGradient5 = Instance.new("UIGradient")
UIGradient5.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 40)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 230, 140)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 190, 40))
})
UIGradient5.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.3),
	NumberSequenceKeypoint.new(1, 1)
})
UIGradient5.Rotation = 90
UIGradient5.Parent = Frame8

task.spawn(function()
	local connection4
	connection4 = RunService.RenderStepped:Connect(function(dt)
		if not Frame8.Parent then
			connection4:Disconnect()
			return
		end
		n4 = (n4 + dt * 0.28) % 1.3
		Frame8.Position = UDim2.new(0, 0, n4, 0)
	end)
end)

local Frame9 = Instance.new("Frame")
Frame9.Size = UDim2.new(1, 0, 0, 36)
Frame9.Position = UDim2.new(0, 0, 0, 0)
Frame9.BackgroundTransparency = 1
Frame9.ZIndex = 7
Frame9.Parent = Frame5

local TextLabel2 = Instance.new("TextLabel")
TextLabel2.Size = UDim2.new(1, 0, 0, 22)
TextLabel2.Position = UDim2.new(0, 0, 0, 6)
TextLabel2.BackgroundTransparency = 1
TextLabel2.Text = "V     Y      R       E"
TextLabel2.TextColor3 = Color3.fromRGB(255, 240, 242)
TextLabel2.Font = Enum.Font.GothamBlack
TextLabel2.TextSize = 14
TextLabel2.TextXAlignment = Enum.TextXAlignment.Center
TextLabel2.ZIndex = 5
TextLabel2.Parent = Frame5

task.spawn(function()
	while TextLabel2.Parent do
		TweenService:Create(TextLabel2, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextColor3 = color3_2
		}):Play()
		task.wait(1.2)
		if not TextLabel2.Parent then
			return
		end
		TweenService:Create(TextLabel2, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextColor3 = Color3.fromRGB(255, 240, 242)
		}):Play()
		task.wait(1.2)
	end
end)

local Frame10 = Instance.new("Frame")
Frame10.Size = UDim2.new(1, -24, 0, 2)
Frame10.Position = UDim2.new(0, 12, 0, 32)
Frame10.BackgroundColor3 = color3
Frame10.BorderSizePixel = 0
Frame10.ZIndex = 4
Frame10.Parent = Frame5

local UIGradient6 = Instance.new("UIGradient")
UIGradient6.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 45, 10)),
	ColorSequenceKeypoint.new(0.5, color3),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 45, 10))
})
UIGradient6.Parent = Frame10

local TextLabel3 = Instance.new("TextLabel")
TextLabel3.Size = UDim2.new(0, 120, 0, 16)
TextLabel3.Position = UDim2.new(0, 12, 0, 42)
TextLabel3.BackgroundTransparency = 1
TextLabel3.Text = "ANTI CHASE"
TextLabel3.TextColor3 = Color3.fromRGB(255, 235, 180)
TextLabel3.Font = Enum.Font.GothamBlack
TextLabel3.TextSize = 13
TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
TextLabel3.ZIndex = 4
TextLabel3.Parent = Frame5

local TextLabel4 = Instance.new("TextLabel")
TextLabel4.Size = UDim2.new(1, -24, 0, 36)
TextLabel4.Position = UDim2.new(0, 12, 0, 60)
TextLabel4.BackgroundTransparency = 1
TextLabel4.Text = "When you activate this feature, monsters will never chase you."
TextLabel4.TextColor3 = Color3.fromRGB(210, 170, 90)
TextLabel4.Font = Enum.Font.GothamBold
TextLabel4.TextSize = 11
TextLabel4.TextWrapped = true
TextLabel4.TextXAlignment = Enum.TextXAlignment.Left
TextLabel4.TextYAlignment = Enum.TextYAlignment.Top
TextLabel4.ZIndex = 4
TextLabel4.Parent = Frame5

-- Toggle switch
local Frame11 = Instance.new("Frame")
Frame11.Size = UDim2.new(0, 44, 0, 22)
Frame11.Position = UDim2.new(1, -56, 0, 40)
Frame11.BackgroundColor3 = color3_5
Frame11.BorderSizePixel = 0
Frame11.ZIndex = 4
Frame11.Parent = Frame5

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(1, 0)
UICorner4.Parent = Frame11

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Color = Color3.fromRGB(120, 80, 20)
UIStroke2.Thickness = 1.2
UIStroke2.Parent = Frame11

local TextButton = Instance.new("TextButton")
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.BackgroundTransparency = 1
TextButton.Text = ""
TextButton.ZIndex = 6
TextButton.Parent = Frame11

local Frame12 = Instance.new("Frame")
Frame12.Size = UDim2.new(0, 16, 0, 16)
Frame12.Position = UDim2.new(0, 3, 0.5, -8)
Frame12.BackgroundColor3 = Color3.fromRGB(220, 200, 160)
Frame12.BorderSizePixel = 0
Frame12.ZIndex = 5
Frame12.Parent = Frame11

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(1, 0)
UICorner5.Parent = Frame12

local UIStroke3 = Instance.new("UIStroke")
UIStroke3.Color = Color3.fromRGB(255, 255, 255)
UIStroke3.Thickness = 1
UIStroke3.Transparency = 0.4
UIStroke3.Parent = Frame12

-- Toggle visual
local function v70(enabled)
	if enabled then
		TweenService:Create(Frame11, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			BackgroundColor3 = color3
		}):Play()
		TweenService:Create(UIStroke2, TweenInfo.new(0.25), {
			Color = color3_2
		}):Play()
		TweenService:Create(Frame12, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -19, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	else
		TweenService:Create(Frame11, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			BackgroundColor3 = color3_5
		}):Play()
		TweenService:Create(UIStroke2, TweenInfo.new(0.25), {
			Color = Color3.fromRGB(120, 80, 20)
		}):Play()
		TweenService:Create(Frame12, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(220, 200, 160)
		}):Play()
	end
end

-- Toggle click
TextButton.MouseButton1Click:Connect(function()
	u18 = not u18
	v70(u18)
	v24(u18)

	if u18 then
		if not connection then
			connection = ProximityPromptService.PromptTriggered:Connect(function(_, p5)
				if p5 == LocalPlayer then
					v22()
				end
			end)
		end
	else
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end)

local TextLabel5 = Instance.new("TextLabel")
TextLabel5.Size = UDim2.new(1, 0, 0, 14)
TextLabel5.Position = UDim2.new(0, 0, 1, -18)
TextLabel5.BackgroundTransparency = 1
TextLabel5.Text = "VYRE SCRIPTS - FREE ONLY"
TextLabel5.TextColor3 = Color3.fromRGB(170, 130, 50)
TextLabel5.Font = Enum.Font.GothamBold
TextLabel5.TextSize = 8.5
TextLabel5.TextXAlignm
