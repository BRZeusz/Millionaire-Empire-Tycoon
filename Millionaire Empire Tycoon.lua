-- Millionaire Empire Tycoon (corrigido e melhorado)
-- Execute no cliente (executor / LocalScript). Não inclua blocos de markdown ou backticks no arquivo.

-- Variáveis básicas
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- Se LocalPlayer for nil (alguns contexts), tenta obter quando estiver disponível
if not LocalPlayer then
	Players.PlayerAdded:Wait()
	LocalPlayer = Players.LocalPlayer
end

-- Criar ScreenGui (usa PlayerGui quando possível)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "_zeusx77 farme"

-- tenta parentar ao PlayerGui; se falhar, tenta CoreGui com pcall (fallback seguro)
local successParent = false
pcall(function()
	if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
		screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		successParent = true
	end
end)
if not successParent then
	pcall(function()
		screenGui.Parent = game:FindFirstChild("CoreGui") or game:GetService("CoreGui")
	end)
end

-- Variável controle menu aberto
local menuOpen = true
local toggleKey = Enum.KeyCode.Insert -- tecla padrão para abrir/fechar menu

-- Função para mostrar mensagens (simples)
local function showMessage(text)
	pcall(function()
		local msg = Instance.new("TextLabel")
		msg.Size = UDim2.new(0, 320, 0, 40)
		msg.Position = UDim2.new(0.5, -160, 0.82, 0)
		msg.BackgroundColor3 = Color3.fromRGB(40,40,50)
		msg.TextColor3 = Color3.fromRGB(220,220,220)
		msg.Font = Enum.Font.GothamBold
		msg.TextSize = 18
		msg.Text = text
		msg.Parent = screenGui
		msg.ZIndex = 1000
		game.Debris:AddItem(msg, 3)
	end)
end

-- Criar o menu principal (frame base)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 460, 0, 380)
menuFrame.Position = UDim2.new(0.5, -230, 0.35, -190)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menuFrame.BorderSizePixel = 0
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.Parent = screenGui
menuFrame.Visible = menuOpen
menuFrame.ClipsDescendants = true

-- título (serve como área de drag)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
titleBar.Parent = menuFrame
titleBar.Name = "TitleBar"

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "_zeusx77 farme"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- manual drag (mais confiável que Draggable)
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = menuFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging and dragStart and startPos then
		local delta = input.Position - dragStart
		menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Criar abas buttons container
local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(1, 0, 0, 40)
tabsContainer.Position = UDim2.new(0, 0, 0, 44)
tabsContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
tabsContainer.Parent = menuFrame

local tabNames = {"Movimento", "Teleporte", "Farme", "Config"}
local tabButtons = {}
local tabFrames = {}

local function hideAllTabs()
	for _, frame in pairs(tabFrames) do
		frame.Visible = false
	end
	for _, btn in pairs(tabButtons) do
		btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
		btn.TextColor3 = Color3.fromRGB(160,160,190)
	end
end

local function createTabButton(name, index)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 110, 1, 0)
	btn.Position = UDim2.new(0, (index-1)*110, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	btn.TextColor3 = Color3.fromRGB(160,160,190)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.Text = name
	btn.Parent = tabsContainer
	return btn
end

local function createTabFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 1, -120)
	frame.Position = UDim2.new(0, 10, 0, 100)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	frame.BorderSizePixel = 0
	frame.Parent = menuFrame
	frame.Visible = false
	return frame
end

-- Criar frames para cada aba
for i, name in ipairs(tabNames) do
	tabButtons[i] = createTabButton(name, i)
	tabFrames[i] = createTabFrame()
end

-- Abrir a primeira aba por padrão (Movimento)
tabButtons[1].BackgroundColor3 = Color3.fromRGB(90, 90, 130)
tabButtons[1].TextColor3 = Color3.fromRGB(220, 220, 255)
tabFrames[1].Visible = true

-- Função pra trocar abas
for i, btn in ipairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		hideAllTabs()
		tabFrames[i].Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(90, 90, 130)
		btn.TextColor3 = Color3.fromRGB(220, 220, 255)
	end)
end

-- Declarar variáveis usadas por disableAllFunctions em escopo superior
local flyEnabled, seedEnabled, jumpInfiniteEnabled, godModeEnabled, farmActive = false, false, false, false, false
local farmLoop

-- FUNÇÕES GLOBAIS PARA DESATIVAR TUDO AO "DESEJETAR" MENU
local function disableAllFunctions()
	-- Fly
	if flyEnabled then
		pcall(function() disableFly() end)
	end
	-- Seed
	if seedEnabled then
		pcall(function() disableSeed() end)
	end
	-- Jump infinito
	if jumpInfiniteEnabled then
		pcall(function() disableJumpInfinite() end)
	end
	-- Godmode
	if godModeEnabled then
		pcall(function() disableGodMode() end)
	end
	-- Farme
	if farmActive then
		farmActive = false
		if farmBtn then farmBtn.Text = "Ativar Farme" end
		if farmLoop then
			farmLoop:Disconnect()
			farmLoop = nil
		end
	end
end

--[[==========================
ABA MOVIMENTO
==========================]]--

local movimentoFrame = tabFrames[1]

-- === Fly ===
local flySpeed = 50
local bodyVelocity, bodyGyro, flyLoop

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 160, 0, 36)
flyBtn.Position = UDim2.new(0, 20, 0, 20)
flyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 230)
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 18
flyBtn.Text = "Fly DESLIGADO"
flyBtn.Parent = movimentoFrame

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0, 100, 0, 30)
flySpeedLabel.Position = UDim2.new(0, 200, 0, 24)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.TextColor3 = Color3.fromRGB(220,220,220)
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.TextSize = 16
flySpeedLabel.Text = "Velocidade: 50"
flySpeedLabel.Parent = movimentoFrame

local flySpeedSlider = Instance.new("TextBox")
flySpeedSlider.Size = UDim2.new(0, 80, 0, 30)
flySpeedSlider.Position = UDim2.new(0, 310, 0, 22)
flySpeedSlider.BackgroundColor3 = Color3.fromRGB(60,60,90)
flySpeedSlider.TextColor3 = Color3.fromRGB(220,220,220)
flySpeedSlider.Font = Enum.Font.GothamBold
flySpeedSlider.TextSize = 18
flySpeedSlider.Text = tostring(flySpeed)
flySpeedSlider.ClearTextOnFocus = false
flySpeedSlider.Parent = movimentoFrame

flySpeedSlider.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(flySpeedSlider.Text)
		if val and val >= 1 and val <= 2000 then
			flySpeed = val
			flySpeedLabel.Text = "Velocidade: "..val
		else
			flySpeedSlider.Text = tostring(flySpeed)
		end
	end
end)

local function applyFlyPhysics(root)
	-- limpa caso exista
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.CFrame = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or root.CFrame
	bodyGyro.Parent = root
end

function enableFly()
	local character = LocalPlayer.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	applyFlyPhysics(root)

	-- Loop mais estável com Heartbeat
	flyLoop = RunService.Heartbeat:Connect(function()
		if not flyEnabled or not root or not root.Parent then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local moveVec = Vector3.new(0,0,0)
		local forward = cam.CFrame.LookVector
		local right = cam.CFrame.RightVector
		if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + forward end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - forward end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0,1,0) end
		if moveVec.Magnitude > 0 then
			moveVec = moveVec.Unit * flySpeed
		else
			moveVec = Vector3.new(0,0,0)
		end
		if bodyVelocity then bodyVelocity.Velocity = moveVec end
		if bodyGyro and cam then bodyGyro.CFrame = cam.CFrame end
	end)
end

function disableFly()
	if flyLoop then
		flyLoop:Disconnect()
		flyLoop = nil
	end
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	flyEnabled = false
	flyBtn.Text = "Fly DESLIGADO"
end

flyBtn.MouseButton1Click:Connect(function()
	if flyEnabled then
		disableFly()
	else
		flyEnabled = true
		flyBtn.Text = "Fly LIGADO"
		pcall(enableFly)
	end
end)

-- reaplica fly em respawn se estiver ativo
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if flyEnabled then
		if char:FindFirstChild("HumanoidRootPart") then
			pcall(enableFly)
		end
	end
end)

-- === Seed === (manter posição/rotacao)
local seedBtn = Instance.new("TextButton")
seedBtn.Size = UDim2.new(0, 160, 0, 36)
seedBtn.Position = UDim2.new(0, 20, 0, 70)
seedBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 230)
seedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
seedBtn.Font = Enum.Font.GothamBold
seedBtn.TextSize = 18
seedBtn.Text = "Seed DESLIGADO"
seedBtn.Parent = movimentoFrame

local seedRootVelocity, seedRootGyro

local function enableSeed()
	local character = LocalPlayer.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- remove se já existir
	if seedRootVelocity then seedRootVelocity:Destroy() end
	if seedRootGyro then seedRootGyro:Destroy() end

	seedRootVelocity = Instance.new("BodyVelocity")
	seedRootVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	seedRootVelocity.Velocity = Vector3.new(0,0,0)
	seedRootVelocity.Parent = root

	seedRootGyro = Instance.new("BodyGyro")
	seedRootGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	seedRootGyro.CFrame = root.CFrame
	seedRootGyro.Parent = root

	seedRootVelocity.Velocity = Vector3.new(0,0,0)
end

local function disableSeed()
	if seedRootVelocity then
		seedRootVelocity:Destroy()
		seedRootVelocity = nil
	end
	if seedRootGyro then
		seedRootGyro:Destroy()
		seedRootGyro = nil
	end
	seedEnabled = false
	seedBtn.Text = "Seed DESLIGADO"
end

seedBtn.MouseButton1Click:Connect(function()
	if seedEnabled then
		disableSeed()
	else
		seedEnabled = true
		seedBtn.Text = "Seed LIGADO"
		pcall(enableSeed)
	end
end)

-- === Jump Infinito ===
local jumpInfiniteBtn = Instance.new("TextButton")
jumpInfiniteBtn.Size = UDim2.new(0, 160, 0, 36)
jumpInfiniteBtn.Position = UDim2.new(0, 200, 0, 70)
jumpInfiniteBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 230)
jumpInfiniteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInfiniteBtn.Font = Enum.Font.GothamBold
jumpInfiniteBtn.TextSize = 18
jumpInfiniteBtn.Text = "Jump Inf. DESLIGADO"
jumpInfiniteBtn.Parent = movimentoFrame

local jumpConnection

local function enableJumpInfinite()
	jumpConnection = UIS.JumpRequest:Connect(function()
		if jumpInfiniteEnabled then
			local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Jump = true
			end
		end
	end)
end

local function disableJumpInfinite()
	if jumpConnection then
		jumpConnection:Disconnect()
		jumpConnection = nil
	end
	jumpInfiniteEnabled = false
	jumpInfiniteBtn.Text = "Jump Inf. DESLIGADO"
end

jumpInfiniteBtn.MouseButton1Click:Connect(function()
	if jumpInfiniteEnabled then
		disableJumpInfinite()
	else
		jumpInfiniteEnabled = true
		jumpInfiniteBtn.Text = "Jump Inf. LIGADO"
		pcall(enableJumpInfinite)
	end
end)

-- === Godmode ===
local godModeBtn = Instance.new("TextButton")
godModeBtn.Size = UDim2.new(0, 160, 0, 36)
godModeBtn.Position = UDim2.new(0, 380, 0, 70)
godModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 230)
godModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
godModeBtn.Font = Enum.Font.GothamBold
godModeBtn.TextSize = 18
godModeBtn.Text = "Godmode DESLIGADO"
godModeBtn.Parent = movimentoFrame

local function enableGodMode()
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Name = "godmodeHumanoid"
		humanoid:SetAttribute("GodmodeEnabled", true)
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid.HealthChanged:Connect(function()
			if humanoid:GetAttribute("GodmodeEnabled") then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	end
end

local function disableGodMode()
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChild("godmodeHumanoid") or character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:SetAttribute("GodmodeEnabled", false)
		pcall(function()
			humanoid.MaxHealth = 100
			if humanoid.Health > 100 then
				humanoid.Health = 100
			end
			humanoid.Name = "Humanoid"
		end)
	end
	godModeEnabled = false
	godModeBtn.Text = "Godmode DESLIGADO"
end

godModeBtn.MouseButton1Click:Connect(function()
	if godModeEnabled then
		disableGodMode()
	else
		godModeEnabled = true
		godModeBtn.Text = "Godmode LIGADO"
		pcall(enableGodMode)
	end
end)

--[[==========================
ABA TELEPORTE
==========================]]--

local teleporteFrame = tabFrames[2]

local playersListFrame = Instance.new("ScrollingFrame")
playersListFrame.Size = UDim2.new(1, -20, 1, -20)
playersListFrame.Position = UDim2.new(0, 10, 0, 10)
playersListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playersListFrame.ScrollBarThickness = 6
playersListFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
playersListFrame.Parent = teleporteFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = playersListFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local function refreshPlayersList()
	-- remove filhos exceto UIListLayout
	for _, child in pairs(playersListFrame:GetChildren()) do
		if child ~= UIListLayout then
			child:Destroy()
		end
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			btn.TextColor3 = Color3.fromRGB(220,220,220)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 18
			btn.Text = plr.Name
			btn.Parent = playersListFrame

			btn.MouseButton1Click:Connect(function()
				local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp and LocalPlayer.Character then
					local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.CFrame = hrp.CFrame + Vector3.new(0,3,0)
						showMessage("Teleportado para "..plr.Name)
					end
				end
			end)
		end
	end
	-- atualizar CanvasSize após criação (usar AbsoluteContentSize)
	playersListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

refreshPlayersList()
Players.PlayerAdded:Connect(refreshPlayersList)
Players.PlayerRemoving:Connect(refreshPlayersList)

--[[==========================
ABA FARME
==========================]]--

local farmeFrame = tabFrames[3]

local farmLabel = Instance.new("TextLabel")
farmLabel.Size = UDim2.new(1, -20, 0, 30)
farmLabel.Position = UDim2.new(0, 10, 0, 10)
farmLabel.BackgroundTransparency = 1
farmLabel.Font = Enum.Font.GothamBold
farmLabel.TextSize = 22
farmLabel.TextColor3 = Color3.fromRGB(220,220,220)
farmLabel.Text = "Digite o valor para farm (max 9999999999):"
farmLabel.Parent = farmeFrame

local farmInput = Instance.new("TextBox")
farmInput.Size = UDim2.new(0, 200, 0, 30)
farmInput.Position = UDim2.new(0, 10, 0, 50)
farmInput.BackgroundColor3 = Color3.fromRGB(50,50,60)
farmInput.TextColor3 = Color3.fromRGB(220,220,220)
farmInput.Font = Enum.Font.GothamBold
farmInput.TextSize = 20
farmInput.Text = "9999999999"
farmInput.ClearTextOnFocus = false
farmInput.Parent = farmeFrame

local farmBtn = Instance.new("TextButton")
farmBtn.Size = UDim2.new(0, 150, 0, 40)
farmBtn.Position = UDim2.new(0, 220, 0, 45)
farmBtn.BackgroundColor3 = Color3.fromRGB(100,100,230)
farmBtn.TextColor3 = Color3.fromRGB(255,255,255)
farmBtn.Font = Enum.Font.GothamBold
farmBtn.TextSize = 18
farmBtn.Text = "Ativar Farme"
farmBtn.Parent = farmeFrame

farmActive = false
farmLoop = nil

farmBtn.MouseButton1Click:Connect(function()
	if farmActive then
		farmActive = false
		farmBtn.Text = "Ativar Farme"
		if farmLoop then
			farmLoop:Disconnect()
			farmLoop = nil
		end
		showMessage("Farme desativado.")
	else
		local val = tonumber(farmInput.Text)
		if val and val > 0 and val <= 9999999999 then
			farmActive = true
			farmBtn.Text = "Desativar Farme"
			farmLoop = RunService.Heartbeat:Connect(function()
				if farmActive then
					local remote = RS:FindFirstChild("fewjnfejwb3")
					if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
						pcall(function()
							if remote:IsA("RemoteEvent") then
								remote:FireServer(val)
							else
								remote:InvokeServer(val)
							end
						end)
					end
				end
			end)
			showMessage("Farme ativado com valor: "..val)
		else
			showMessage("Valor inválido para farme.")
		end
	end
end)

--[[==========================
ABA CONFIG
==========================]]--

local configFrame = tabFrames[4]

-- Label Discord
local discordLabel = Instance.new("TextLabel")
discordLabel.Size = UDim2.new(1, -20, 0, 40)
discordLabel.Position = UDim2.new(0, 10, 0, 10)
discordLabel.BackgroundTransparency = 1
discordLabel.Font = Enum.Font.GothamBold
discordLabel.TextSize = 20
discordLabel.TextColor3 = Color3.fromRGB(180, 180, 250)
discordLabel.Text = "X77 Community\nhttps://discord.gg/x77community"
discordLabel.TextWrapped = true
discordLabel.Parent = configFrame

-- Botão abrir Discord
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 260, 0, 40)
discordBtn.Position = UDim2.new(0, 10, 0, 60)
discordBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 140)
discordBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 18
discordBtn.Text = "ABRIR DISCORD X77 COMMUNITY (copiar link)"
discordBtn.Parent = configFrame

discordBtn.MouseButton1Click:Connect(function()
	local link = "https://discord.gg/x77community"
	pcall(function()
		setclipboard(link)
	end)
	pcall(function()
		game:GetService("GuiService"):OpenBrowserWindow(link)
	end)
	showMessage("Link do Discord copiado e navegador aberto (se possível).")
end)

-- Label para info de bugs
local bugInfoLabel = Instance.new("TextLabel")
bugInfoLabel.Size = UDim2.new(1, -20, 0, 40)
bugInfoLabel.Position = UDim2.new(0, 10, 0, 110)
bugInfoLabel.BackgroundTransparency = 1
bugInfoLabel.Font = Enum.Font.GothamItalic
bugInfoLabel.TextSize = 16
bugInfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
bugInfoLabel.Text = "Relate bugs no Discord para correção."
bugInfoLabel.Parent = configFrame

-- Botão Desejetar (fecha menu e desativa tudo)
local desejetarBtn = Instance.new("TextButton")
desejetarBtn.Size = UDim2.new(0, 150, 0, 40)
desejetarBtn.Position = UDim2.new(0, 10, 0, 160)
desejetarBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
desejetarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
desejetarBtn.Font = Enum.Font.GothamBold
desejetarBtn.TextSize = 18
desejetarBtn.Text = "Desejetar"
desejetarBtn.Parent = configFrame

desejetarBtn.MouseButton1Click:Connect(function()
	disableAllFunctions()
	menuFrame.Visible = false
	menuOpen = false
	showMessage("Menu fechado e funções desativadas.")
end)

--[[==========================
TECLA DE ATIVAÇÃO / DESATIVAÇÃO DO MENU
==========================]]--

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == toggleKey then
		menuOpen = not menuOpen
		menuFrame.Visible = menuOpen
		if menuOpen then
			refreshPlayersList()
		end
	end
end)

-- Mostrar menu aberto inicialmente
menuFrame.Visible = menuOpen
