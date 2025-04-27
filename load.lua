local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local VALIDATION_URL = " http://base.0x32.me:6671/validate_key"

local function createGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui.ResetOnSpawn = false

	local startSound = Instance.new("Sound")
	startSound.SoundId = "rbxassetid://131136929849120"
	startSound.Parent = screenGui
	startSound:Play()

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 200)
	frame.Position = UDim2.new(0.5, -150, 0.5, -100)
	frame.BackgroundColor3 = Color3.fromRGB(18, 46, 85)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame

	local dragDetector = Instance.new("UIDragDetector")
	dragDetector.Parent = frame
	dragDetector.Enabled = true
	dragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 280, 0, 40)
	titleLabel.Position = UDim2.new(0.5, -140, 0.1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "World's Silent Aim"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 24
	titleLabel.Font = Enum.Font.SciFi
	titleLabel.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 200, 0, 30)
	textBox.Position = UDim2.new(0.5, -100, 0.35, 0)
	textBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.PlaceholderText = "Enter your key"
	textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	textBox.Text = ""
	textBox.TextSize = 14
	textBox.Font = Enum.Font.SciFi
	textBox.Parent = frame

	local textBoxCorner = Instance.new("UICorner")
	textBoxCorner.CornerRadius = UDim.new(0, 8)
	textBoxCorner.Parent = textBox

	local submitButton = Instance.new("TextButton")
	submitButton.Size = UDim2.new(0, 100, 0, 30)
	submitButton.Position = UDim2.new(0.5, -50, 0.55, 0)
	submitButton.Text = "Submit"
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.TextSize = 14
	submitButton.Font = Enum.Font.SciFi
	submitButton.Parent = frame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = submitButton

	local hoverSound = Instance.new("Sound")
	hoverSound.SoundId = "rbxassetid://78593129520085"
	hoverSound.Parent = screenGui

	local clickSound = Instance.new("Sound")
	clickSound.SoundId = "rbxassetid://132442985525251"
	clickSound.Parent = screenGui

	submitButton.MouseEnter:Connect(function()
		hoverSound:Play()
	end)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 280, 0, 30)
	statusLabel.Position = UDim2.new(0.5, -140, 0.75, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.Text = ""
	statusLabel.TextSize = 14
	statusLabel.Font = Enum.Font.SciFi
	statusLabel.Parent = frame

	local loadingFrame = Instance.new("Frame")
	loadingFrame.Size = UDim2.new(0, 40, 0, 40)
	loadingFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
	loadingFrame.BackgroundTransparency = 1
	loadingFrame.Visible = false
	loadingFrame.Parent = frame

	local loadingImage = Instance.new("ImageLabel")
	loadingImage.Size = UDim2.new(1, 0, 1, 0)
	loadingImage.BackgroundTransparency = 1
	loadingImage.Image = "rbxassetid://5012544693"
	loadingImage.Parent = loadingFrame

	local spinTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local spinTween = TweenService:Create(loadingImage, spinTweenInfo, {Rotation = 360})

	frame.BackgroundTransparency = 1
	local fadeInTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local fadeInTween = TweenService:Create(frame, fadeInTweenInfo, {BackgroundTransparency = 0})
	fadeInTween:Play()

	for _, child in pairs(frame:GetChildren()) do
		if child:IsA("GuiObject") then
			if child:IsA("TextBox") or child:IsA("TextButton") then
				child.BackgroundTransparency = 0
			else
				child.BackgroundTransparency = 1
			end
			local targetTransparency = (child:IsA("TextBox") or child:IsA("TextButton")) and 0 or 1
			local childFadeIn = TweenService:Create(child, fadeInTweenInfo, {BackgroundTransparency = targetTransparency})
			childFadeIn:Play()
		end
	end

	return screenGui, textBox, submitButton, statusLabel, loadingFrame, spinTween, clickSound
end

local function validateKey(key, username)
	local success, response = pcall(function()
		local data = {
			key = key,
			username = username
		}
		local encodedData = HttpService:JSONEncode(data)
		return HttpService:PostAsync(VALIDATION_URL, encodedData, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		local decodedResponse = HttpService:JSONDecode(response)
		if decodedResponse.success then
			return decodedResponse.scriptUrl
		else
			return nil, decodedResponse.message or "Invalid key or username"
		end
	else
		return nil, "Failed to contact server: " .. tostring(response)
	end
end

local function executeScript(scriptUrl)
	local success, scriptContent = pcall(function()
		return HttpService:GetAsync(scriptUrl)
	end)

	if success then
		local execSuccess, result = pcall(function()
			loadstring(scriptContent)()
		end)
		return execSuccess, result
	else
		return false, "Failed to fetch script: " .. tostring(scriptContent)
	end
end

local function main()
	local screenGui, textBox, submitButton, statusLabel, loadingFrame, spinTween, clickSound = createGui()

	submitButton.MouseButton1Click:Connect(function()
		clickSound:Play()
		local key = textBox.Text
		if not key or key == "" then
			statusLabel.Text = "Please enter a key"
			return
		end

		textBox.Visible = false
		submitButton.Visible = false
		loadingFrame.Visible = true
		spinTween:Play()
		statusLabel.Text = "Validating..."

		local username = Players.LocalPlayer.Name
		local scriptUrl, errorMessage = validateKey(key, username)

		if scriptUrl then
			spinTween:Cancel()
			loadingFrame.Visible = false
			statusLabel.Text = "Valid Key"

			local success, result = executeScript(scriptUrl)
			if not success then
				statusLabel.Text = "Error executing script: " .. tostring(result)
			end

			wait(3)
			screenGui:Destroy()
		else
			spinTween:Cancel()
			loadingFrame.Visible = false
			statusLabel.Text = "Invalid Key, Closing Gui"
			wait(2)
			screenGui:Destroy()
		end
	end)
end

main()
