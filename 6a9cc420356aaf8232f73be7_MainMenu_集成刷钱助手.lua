--[[
	主菜单界面模块 + 刷钱助手 + 使用信息上报（集成版）
	包含：游戏标题、开始游戏按钮、设置按钮、商店按钮、刷钱助手、使用上报
	刷钱功能：出租车（接单+传送） / 公交车（站台接客+送达），一键切换
	上报功能：脚本使用记录（用户名、地图、账号年龄、设备、执行时间等）
	放置位置：StarterGui -> MainMenu -> LocalScript
	by Ye Script
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ================== 上报配置 ==================
local REPORT_CONFIG = {
	WEBHOOK_URL = "填写你的dc WebHook",
	SCRIPT_NAME = "xiaoyi刷钱脚本",
	REPORT_INTERVAL = 300,      -- 心跳上报间隔（秒），默认5分钟
	ENABLE_REPORT = true,        -- 总开关
}
-- =============================================

-- 引用 UI 管理器
local UIManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIManager"))

-- ============================================================
-- =====           使用信息上报模块（殺脚本同款）           =====
-- ============================================================

local Reporter = {}
Reporter.__index = Reporter

function Reporter.new(config)
	local self = setmetatable({}, Reporter)
	self.Config = config or REPORT_CONFIG
	self.Player = Players.LocalPlayer
	self.MapName = "未知地图"
	self.IsReporting = false
	self.HeartbeatThread = nil

	-- 预获取地图名
	pcall(function()
		self.MapName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "地图获取错误"
	end)

	return self
end

-- 构建 embed
function Reporter:_BuildEmbed(extraFields)
	local player = self.Player
	local accountAge = player.AccountAge .. "天"

	-- 判断设备
	local device = "PC"
	pcall(function()
		if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
			device = "移动设备"
		elseif UserInputService.GamepadEnabled then
			device = "主机"
		end
	end)

	local fields = {
		{ name = "用户名", value = player.Name, inline = true },
		{ name = "显示名称", value = player.DisplayName or "无", inline = true },
		{ name = "脚本名称", value = self.Config.SCRIPT_NAME, inline = true },
		{ name = "地图", value = self.MapName, inline = true },
		{ name = "账号年龄", value = accountAge, inline = true },
		{ name = "设备", value = device, inline = true },
		{ name = "执行时间", value = os.date("%Y-%m-%d %H:%M:%S", os.time()), inline = false },
	}

	-- 附加字段
	if extraFields then
		for _, f in ipairs(extraFields) do
			table.insert(fields, f)
		end
	end

	local embed = {
		title = "脚本使用记录 by夜脚本团队",
		description = "检测到有人执行了 " .. self.Config.SCRIPT_NAME,
		color = 65280, -- 绿色
		fields = fields,
		thumbnail = {
			url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
		},
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}

	return embed
end

-- 发送上报
function Reporter:Send(reason, extraFields)
	if not self.Config.ENABLE_REPORT then return false end
	if not self.Config.WEBHOOK_URL or self.Config.WEBHOOK_URL == "" or self.Config.WEBHOOK_URL:find("填写") then
		return false
	end

	local embed = self:_BuildEmbed(extraFields)

	-- 如果有原因，加到描述里
	if reason and reason ~= "" then
		embed.description = embed.description .. "\n**事件：** " .. reason
	end

	local data = {
		username = "脚本使用记录",
		embeds = { embed },
		content = "",
	}

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = self.Config.WEBHOOK_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["User-Agent"] = "Roblox/WinInet",
			},
			Body = HttpService:JSONEncode(data),
		})
	end)

	return success and result and result.StatusCode == 204
end

-- 启动心跳上报
function Reporter:StartHeartbeat()
	if self.IsReporting then return end
	self.IsReporting = true

	-- 首次立即上报
	self:Send("脚本启动")

	-- 定时上报
	self.HeartbeatThread = task.spawn(function()
		local count = 0
		while self.IsReporting do
			task.wait(self.Config.REPORT_INTERVAL)
			if not self.IsReporting then break end
			count = count + 1
			self:Send("心跳上报 #" .. count, {
				{ name = "运行时长", value = math.floor(count * self.Config.REPORT_INTERVAL / 60) .. "分钟", inline = true },
			})
		end
	end)
end

-- 停止上报
function Reporter:StopHeartbeat()
	self.IsReporting = false
	if self.HeartbeatThread then
		self.HeartbeatThread = nil
	end
end

-- 自定义上报（便捷方法）
function Reporter:ReportEvent(eventName, extraFields)
	self:Send(eventName, extraFields)
end

-- 上报刷钱启动
function Reporter:ReportMoneyStart(mode)
	self:ReportEvent("刷钱助手启动", {
		{ name = "模式", value = mode == "taxi" and "出租车" or "公交车", inline = true },
	})
end

-- 上报刷钱停止
function Reporter:ReportMoneyStop(mode, stats)
	local statStr = ""
	if mode == "taxi" then
		statStr = "接单: " .. (stats.orders or 0) .. " | 传送: " .. (stats.teleports or 0)
	else
		statStr = "乘客: " .. (stats.passengers or 0) .. " | 站点: " .. (stats.stations or 0)
	end
	self:ReportEvent("刷钱助手停止", {
		{ name = "模式", value = mode == "taxi" and "出租车" or "公交车", inline = true },
		{ name = "统计", value = statStr, inline = false },
	})
end

-- 全局上报实例
local reporter = Reporter.new(REPORT_CONFIG)

local MainMenu = {}
MainMenu.__index = MainMenu

-- 创建主菜单
function MainMenu.new()
	local self = setmetatable({}, MainMenu)

	self.Layer = "Main"
	self.Instance = self:Build()

	-- 刷钱相关状态
	self.MoneyMode = "taxi"        -- "taxi" 或 "bus"
	self.MoneyRunning = false
	self.MoneyLoopThread = nil
	self.OrderCount = 0
	self.TeleportCount = 0
	self.PassengerCount = 0
	self.StationCount = 0
	self.CurrentPassengers = {}
	self.BusStops = {}
	self.CurrentStopIndex = 1

	-- 配置
	self.TaxiConfig = {
		ORDER_INTERVAL = 10,
		TELEPORT_INTERVAL = 3,
	}
	self.BusConfig = {
		MAX_PASSENGERS = 5,
		PICKUP_INTERVAL = 3,
		DELIVER_INTERVAL = 5,
		CLICK_COUNT = 5,
		DESTINATION_OFFSET = 100,
		TIMEOUT_SECONDS = 10,
	}

	return self
end

-- 构建界面
function MainMenu:Build()
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainMenu"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1

	-- ===== 背景 =====
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(15, 17, 28)
	bg.Parent = mainFrame

	-- 渐变遮罩
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 17, 28)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 28, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 17, 28)),
	})
	gradient.Rotation = 90
	gradient.Parent = bg

	-- 装饰光斑
	local glow1 = Instance.new("Frame")
	glow1.Name = "Glow1"
	glow1.Size = UDim2.new(0, 600, 0, 600)
	glow1.Position = UDim2.new(0.2, 0, 0.3, 0)
	glow1.AnchorPoint = Vector2.new(0.5, 0.5)
	glow1.BackgroundColor3 = Color3.fromRGB(120, 70, 200)
	glow1.BackgroundTransparency = 0.85
	glow1.Parent = bg

	local glow2 = Instance.new("Frame")
	glow2.Name = "Glow2"
	glow2.Size = UDim2.new(0, 500, 0, 500)
	glow2.Position = UDim2.new(0.8, 0, 0.7, 0)
	glow2.AnchorPoint = Vector2.new(0.5, 0.5)
	glow2.BackgroundColor3 = Color3.fromRGB(0, 180, 200)
	glow2.BackgroundTransparency = 0.9
	glow2.Parent = bg

	for _, glow in ipairs({glow1, glow2}) do
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = glow

		-- 缓慢漂浮动画
		local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(glow, tweenInfo, {
			Position = glow.Position + UDim2.new(0, 30, 0, -20),
		}):Play()
	end

	-- ===== 中央内容区 =====
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(0, 500, 0, 520)
	content.Position = UDim2.new(0.5, 0, 0.5, 0)
	content.AnchorPoint = Vector2.new(0.5, 0.5)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	-- 游戏 Logo / 标题
	local gameTitle = Instance.new("TextLabel")
	gameTitle.Name = "GameTitle"
	gameTitle.Text = "暗夜传说"
	gameTitle.Font = Enum.Font.GothamBlack
	gameTitle.TextSize = 64
	gameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	gameTitle.Size = UDim2.new(1, 0, 0, 80)
	gameTitle.Position = UDim2.new(0, 0, 0, 20)
	gameTitle.BackgroundTransparency = 1
	gameTitle.Parent = content

	-- 标题渐变效果
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 140, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255)),
	})
	titleGradient.Parent = gameTitle

	-- 副标题
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Text = "NIGHT LEGEND"
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 16
	subtitle.TextColor3 = Color3.fromRGB(150, 160, 200)
	subtitle.Size = UDim2.new(1, 0, 0, 24)
	subtitle.Position = UDim2.new(0, 0, 0, 100)
	subtitle.BackgroundTransparency = 1
	subtitle.Parent = content

	-- 版本号
	local version = Instance.new("TextLabel")
	version.Name = "Version"
	version.Text = "版本 v1.2.0"
	version.Font = Enum.Font.Gotham
	version.TextSize = 12
	version.TextColor3 = Color3.fromRGB(100, 110, 140)
	version.Size = UDim2.new(1, 0, 0, 20)
	version.Position = UDim2.new(0, 0, 0, 128)
	version.BackgroundTransparency = 1
	version.Parent = content

	-- ===== 按钮组 =====
	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Name = "Buttons"
	buttonsFrame.Size = UDim2.new(0, 280, 0, 340)
	buttonsFrame.Position = UDim2.new(0.5, 0, 0.52, 0)
	buttonsFrame.AnchorPoint = Vector2.new(0.5, 0)
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.Parent = content

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = buttonsFrame

	-- 开始游戏按钮
	local playBtn = self:CreateMenuButton("PlayBtn", "▶  开始游戏", buttonsFrame, Color3.fromRGB(120, 70, 220))
	playBtn.MouseButton1Click:Connect(function()
		self:OnPlayClick()
	end)

	-- 刷钱助手按钮（新增）
	local moneyBtn = self:CreateMenuButton("MoneyBtn", "💰  刷钱助手", buttonsFrame, Color3.fromRGB(60, 170, 90))
	moneyBtn.MouseButton1Click:Connect(function()
		self:OpenMoneyPanel()
	end)

	-- 商店按钮
	local shopBtn = self:CreateMenuButton("ShopBtn", "🛒  道具商店", buttonsFrame, Color3.fromRGB(240, 160, 50))
	shopBtn.MouseButton1Click:Connect(function()
		UIManager:ShowUI("Shop")
	end)

	-- 设置按钮
	local settingsBtn = self:CreateMenuButton("SettingsBtn", "⚙  游戏设置", buttonsFrame, Color3.fromRGB(70, 130, 200))
	settingsBtn.MouseButton1Click:Connect(function()
		UIManager:ShowUI("Settings")
	end)

	-- 退出按钮
	local quitBtn = self:CreateMenuButton("QuitBtn", "🚪  离开游戏", buttonsFrame, Color3.fromRGB(200, 70, 70))
	quitBtn.MouseButton1Click:Connect(function()
		self:OnQuitClick()
	end)

	-- ===== 底部信息 =====
	local bottomInfo = Instance.new("Frame")
	bottomInfo.Name = "BottomInfo"
	bottomInfo.Size = UDim2.new(1, -60, 0, 40)
	bottomInfo.Position = UDim2.new(0, 30, 1, -50)
	bottomInfo.BackgroundTransparency = 1
	bottomInfo.Parent = mainFrame

	local playerInfo = Instance.new("TextLabel")
	playerInfo.Text = "玩家: " .. Players.LocalPlayer.Name
	playerInfo.Font = Enum.Font.Gotham
	playerInfo.TextSize = 13
	playerInfo.TextColor3 = Color3.fromRGB(150, 160, 200)
	playerInfo.Size = UDim2.new(0, 200, 1, 0)
	playerInfo.TextXAlignment = Enum.TextXAlignment.Left
	playerInfo.BackgroundTransparency = 1
	playerInfo.Parent = bottomInfo

	local serverInfo = Instance.new("TextLabel")
	serverInfo.Text = "服务器: 正式服 #1024"
	serverInfo.Font = Enum.Font.Gotham
	serverInfo.TextSize = 13
	serverInfo.TextColor3 = Color3.fromRGB(150, 160, 200)
	serverInfo.Size = UDim2.new(0, 200, 1, 0)
	serverInfo.Position = UDim2.new(1, 0, 0, 0)
	serverInfo.TextXAlignment = Enum.TextXAlignment.Right
	serverInfo.BackgroundTransparency = 1
	serverInfo.Parent = bottomInfo

	-- ============================================================
	-- =====           刷钱助手面板（MobileCoolUI 风格）       =====
	-- ============================================================

	self.MoneyPanel = {}

	-- 悬浮按钮（右上角圆形）
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "MoneyToggleBtn"
	toggleButton.Size = UDim2.new(0, 56, 0, 56)
	toggleButton.Position = UDim2.new(1, -76, 0, 20)
	toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "💰"
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.TextScaled = true
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Active = true
	toggleButton.Draggable = true
	toggleButton.Visible = false
	toggleButton.Parent = mainFrame
	Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

	self.MoneyPanel.ToggleButton = toggleButton

	-- 主面板
	local moneyMain = Instance.new("Frame")
	moneyMain.Name = "MoneyPanel"
	moneyMain.Size = UDim2.new(0, 250, 0, 370)
	moneyMain.Position = UDim2.new(0.5, -125, 0.5, -185)
	moneyMain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	moneyMain.BorderSizePixel = 0
	moneyMain.Active = true
	moneyMain.Visible = false
	moneyMain.ZIndex = 10
	moneyMain.Parent = mainFrame
	Instance.new("UICorner", moneyMain).CornerRadius = UDim.new(0, 10)

	self.MoneyPanel.MainFrame = moneyMain

	-- 标题栏
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = moneyMain

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -70, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = "💰 刷钱助手"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	self.MoneyPanel.TitleLabel = titleLabel

	-- 最小化按钮
	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Size = UDim2.new(0, 25, 0, 25)
	minimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	minimizeButton.Text = "-"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.TextScaled = true
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Parent = titleBar
	Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

	self.MoneyPanel.MinimizeButton = minimizeButton

	-- 关闭按钮
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 25, 0, 25)
	closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.BorderSizePixel = 0
	closeButton.Parent = titleBar
	Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 4)

	self.MoneyPanel.CloseButton = closeButton

	-- 内容区（按钮列表）
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -40)
	contentFrame.Position = UDim2.new(0, 0, 0, 40)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = moneyMain

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Parent = contentFrame
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- 状态行（状态点 + 状态文字）
	local statusRow = Instance.new("Frame")
	statusRow.Size = UDim2.new(1, -20, 0, 24)
	statusRow.BackgroundTransparency = 1
	statusRow.LayoutOrder = 1
	statusRow.Parent = contentFrame

	local moneyDot = Instance.new("Frame")
	moneyDot.Size = UDim2.new(0, 10, 0, 10)
	moneyDot.Position = UDim2.new(0, 0, 0.5, -5)
	moneyDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	moneyDot.BorderSizePixel = 0
	moneyDot.Parent = statusRow
	Instance.new("UICorner", moneyDot).CornerRadius = UDim.new(1, 0)

	self.MoneyPanel.Dot = moneyDot
	self.MoneyPanel.DotGlow = moneyDot

	local moneyStatus = Instance.new("TextLabel")
	moneyStatus.Size = UDim2.new(1, -18, 1, 0)
	moneyStatus.Position = UDim2.new(0, 18, 0, 0)
	moneyStatus.BackgroundTransparency = 1
	moneyStatus.Text = "⏸ 已停止"
	moneyStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
	moneyStatus.TextScaled = true
	moneyStatus.TextXAlignment = Enum.TextXAlignment.Left
	moneyStatus.Font = Enum.Font.Gotham
	moneyStatus.Parent = statusRow

	self.MoneyPanel.StatusLabel = moneyStatus

	-- 统计行
	local statRow = Instance.new("Frame")
	statRow.Size = UDim2.new(1, -20, 0, 26)
	statRow.BackgroundTransparency = 1
	statRow.LayoutOrder = 2
	statRow.Parent = contentFrame

	local moneyStat1 = Instance.new("TextLabel")
	moneyStat1.Size = UDim2.new(0.5, -5, 1, 0)
	moneyStat1.Position = UDim2.new(0, 0, 0, 0)
	moneyStat1.BackgroundTransparency = 1
	moneyStat1.Text = "📦 接单: 0"
	moneyStat1.TextColor3 = Color3.fromRGB(255, 180, 180)
	moneyStat1.TextScaled = true
	moneyStat1.TextXAlignment = Enum.TextXAlignment.Left
	moneyStat1.Font = Enum.Font.GothamBold
	moneyStat1.Parent = statRow

	self.MoneyPanel.StatLabel1 = moneyStat1

	local moneyStat2 = Instance.new("TextLabel")
	moneyStat2.Size = UDim2.new(0.5, -5, 1, 0)
	moneyStat2.Position = UDim2.new(0.5, 5, 0, 0)
	moneyStat2.BackgroundTransparency = 1
	moneyStat2.Text = "🚗 传送: 0"
	moneyStat2.TextColor3 = Color3.fromRGB(150, 220, 255)
	moneyStat2.TextScaled = true
	moneyStat2.TextXAlignment = Enum.TextXAlignment.Left
	moneyStat2.Font = Enum.Font.GothamBold
	moneyStat2.Parent = statRow

	self.MoneyPanel.StatLabel2 = moneyStat2

	-- 操作状态
	local moneyOrderStatus = Instance.new("TextLabel")
	moneyOrderStatus.Size = UDim2.new(1, -20, 0, 22)
	moneyOrderStatus.BackgroundTransparency = 1
	moneyOrderStatus.Text = "🔄 等待启动..."
	moneyOrderStatus.TextColor3 = Color3.fromRGB(180, 180, 200)
	moneyOrderStatus.TextScaled = true
	moneyOrderStatus.TextXAlignment = Enum.TextXAlignment.Left
	moneyOrderStatus.Font = Enum.Font.Gotham
	moneyOrderStatus.LayoutOrder = 3
	moneyOrderStatus.Parent = contentFrame

	self.MoneyPanel.OrderStatusLabel = moneyOrderStatus

	-- 站台信息（公交车专用）
	local moneyStationInfo = Instance.new("TextLabel")
	moneyStationInfo.Size = UDim2.new(1, -20, 0, 22)
	moneyStationInfo.BackgroundTransparency = 1
	moneyStationInfo.Text = ""
	moneyStationInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
	moneyStationInfo.TextScaled = true
	moneyStationInfo.TextXAlignment = Enum.TextXAlignment.Left
	moneyStationInfo.Font = Enum.Font.Gotham
	moneyStationInfo.LayoutOrder = 4
	moneyStationInfo.Parent = contentFrame

	self.MoneyPanel.StationInfoLabel = moneyStationInfo

	-- 警告标签
	local moneyWarn = Instance.new("TextLabel")
	moneyWarn.Size = UDim2.new(1, -20, 0, 20)
	moneyWarn.BackgroundTransparency = 1
	moneyWarn.Text = "⚠ 请配合防检测使用"
	moneyWarn.TextColor3 = Color3.fromRGB(255, 80, 80)
	moneyWarn.TextScaled = true
	moneyWarn.TextXAlignment = Enum.TextXAlignment.Left
	moneyWarn.Font = Enum.Font.GothamBold
	moneyWarn.LayoutOrder = 5
	moneyWarn.Parent = contentFrame

	-- 辅助：创建功能按钮
	local function createMoneyButton(name, text, layoutOrder, bgColor, parent)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(1, -20, 0, 40)
		btn.BackgroundColor3 = bgColor or Color3.fromRGB(50, 50, 50)
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.BorderSizePixel = 0
		btn.LayoutOrder = layoutOrder
		btn.Parent = parent or contentFrame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		-- 悬停效果
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.new(
				math.min(btn.BackgroundColor3.R + 0.08, 1),
				math.min(btn.BackgroundColor3.G + 0.08, 1),
				math.min(btn.BackgroundColor3.B + 0.08, 1)
			)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = bgColor or Color3.fromRGB(50, 50, 50)
		end)

		return btn
	end

	-- 模式切换按钮
	local moneyModeBtn = createMoneyButton("ModeBtn", "🚕 切换到公交车", 10, Color3.fromRGB(70, 70, 70))
	self.MoneyPanel.ModeButton = moneyModeBtn

	-- 启动/停止按钮
	local moneyStartBtn = createMoneyButton("StartBtn", "▶ 启动", 20, Color3.fromRGB(60, 140, 70))
	self.MoneyPanel.StartButton = moneyStartBtn
	self.MoneyPanel.StartBtnGlow = moneyStartBtn

	-- 复制脚本按钮
	local moneyCopyBtn = createMoneyButton("CopyBtn", "📋 复制脚本", 30, Color3.fromRGB(50, 50, 50))
	self.MoneyPanel.CopyButton = moneyCopyBtn

	-- 重置按钮
	local moneyResetBtn = createMoneyButton("ResetBtn", "🔄 重置统计", 40, Color3.fromRGB(50, 50, 50))
	self.MoneyPanel.ResetButton = moneyResetBtn

	-- 拖拽支持（标题栏拖动）
	local dragging = false
	local dragInput, dragStart, startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		moneyMain.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = moneyMain.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
			updateDrag(input)
		end
	end)

	self.MoneyPanel.TitleBar = titleBar
	self.MoneyPanel.ContentFrame = contentFrame

	-- ===== 刷钱面板 事件绑定 =====
	local function ToggleMoneyPanel()
		moneyMain.Visible = not moneyMain.Visible

	end

	toggleButton.MouseButton1Click:Connect(function()
		ToggleMoneyPanel()
	end)

	closeButton.MouseButton1Click:Connect(function()
		ToggleMoneyPanel()
	end)

	-- 最小化 / 还原
	local isMinimized = false
	minimizeButton.MouseButton1Click:Connect(function()
		if isMinimized then
			moneyMain.Size = UDim2.new(0, 250, 0, 370)
			contentFrame.Visible = true
			minimizeButton.Text = "-"
		else
			moneyMain.Size = UDim2.new(0, 250, 0, 40)
			contentFrame.Visible = false
			minimizeButton.Text = "+"
		end
		isMinimized = not isMinimized
	end)

	moneyModeBtn.MouseButton1Click:Connect(function()
		self:SwitchMoneyMode(self.MoneyMode == "taxi" and "bus" or "taxi")
	end)

	moneyCopyBtn.MouseButton1Click:Connect(function()
		local scriptToCopy = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/idkidevthings/improved-octo-chainsaw/refs/heads/main/sanx.lua"))()'
		setclipboard(scriptToCopy)
		moneyCopyBtn.Text = "✅ 已复制"
		task.wait(1.5)
		moneyCopyBtn.Text = "📋 复制"
	end)

	moneyStartBtn.MouseButton1Click:Connect(function()
		if self.MoneyRunning then
			self:StopMoneyLoop()
		else
			self:StartMoneyLoop()
		end
	end)

	moneyResetBtn.MouseButton1Click:Connect(function()
		self:ResetMoneyStats()
	end)

	-- 快捷键 F1 启动/停止，F2 重置
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not toggleButton.Visible then return end
		if input.KeyCode == Enum.KeyCode.F1 then
			if self.MoneyRunning then self:StopMoneyLoop() else self:StartMoneyLoop() end
		elseif input.KeyCode == Enum.KeyCode.F2 then
			self:ResetMoneyStats()
		end
	end)

	-- 动态光效
	self._MoneyHue = 0
	self._MoneyGlowConnection = nil

	return mainFrame
end

-- 创建菜单按钮
function MainMenu:CreateMenuButton(name, text, parent, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = color
	button.Size = UDim2.new(0, 280, 0, 48)
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = button

	-- 悬停效果
	button.MouseEnter:Connect(function()
		TweenService:Create(button, UIManager.DefaultTweenInfo, {
			BackgroundColor3 = Color3.new(
				math.min(color.R + 0.1, 1),
				math.min(color.G + 0.1, 1),
				math.min(color.B + 0.1, 1)
			),
			Size = UDim2.new(0, 288, 0, 54),
		}):Play()
		stroke.Transparency = 0.4
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, UIManager.DefaultTweenInfo, {
			BackgroundColor3 = color,
			Size = UDim2.new(0, 280, 0, 48),
		}):Play()
		stroke.Transparency = 0.7
	end)

	-- 点击效果
	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {
			Size = UDim2.new(0, 272, 0, 44),
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			Size = UDim2.new(0, 280, 0, 48),
		}):Play()
	end)

	return button
end

-- ============================================================
-- =====              刷钱助手 - 公开方法                  =====
-- ============================================================

-- 打开刷钱面板
function MainMenu:OpenMoneyPanel()
	UIManager:Notify("刷钱助手", "正在加载刷钱面板...", "info", 1.5)

	-- 上报：打开刷钱面板
	reporter:ReportEvent("刷钱助手面板打开")

	task.delay(0.8, function()
		self.MoneyPanel.ToggleButton.Visible = true
		self.MoneyPanel.MainFrame.Visible = true
		self:SwitchMoneyMode("taxi")
		self:UpdateMoneyUI(false)

		-- 启动动态光效
		if not self._MoneyGlowConnection then
			self._MoneyHue = 0
			self._MoneyGlowConnection = RunService.Heartbeat:Connect(function()
				self:UpdateMoneyGlow()
			end)
		end

		print("[MainMenu] 刷钱助手面板已打开")
	end)
end

-- 关闭刷钱面板
function MainMenu:CloseMoneyPanel()
	if self.MoneyRunning then
		self:StopMoneyLoop()
	end
	self.MoneyPanel.ToggleButton.Visible = false
	self.MoneyPanel.MainFrame.Visible = false
	if self._MoneyGlowConnection then
		self._MoneyGlowConnection:Disconnect()
		self._MoneyGlowConnection = nil
	end
	print("[MainMenu] 刷钱助手面板已关闭")
end

-- 更新刷钱面板光效（标题栏呼吸效果）
function MainMenu:UpdateMoneyGlow()
	self._MoneyHue = (self._MoneyHue + 0.02) % (math.pi * 2)
	local alpha = math.sin(self._MoneyHue) * 0.5 + 0.5
	-- 标题栏亮度呼吸
	if self.MoneyPanel.TitleBar then
		local base = 45
		local current = base + alpha * 15
		self.MoneyPanel.TitleBar.BackgroundColor3 = Color3.fromRGB(current, current, current)
	end
	-- 运行时状态点呼吸
	if self.MoneyRunning and self.MoneyPanel.Dot then
		local dotAlpha = math.sin(self._MoneyHue * 3) * 0.3 + 0.7
		self.MoneyPanel.Dot.BackgroundTransparency = 1 - dotAlpha
	end
end

-- 切换刷钱模式
function MainMenu:SwitchMoneyMode(newMode)
	if newMode == self.MoneyMode then return end
	if self.MoneyRunning then
		self.MoneyRunning = false
		task.wait(0.2)
	end
	self.MoneyMode = newMode

	local p = self.MoneyPanel
	if self.MoneyMode == "taxi" then
		p.StatLabel1.Text = "📦 接单: " .. self.OrderCount
		p.StatLabel2.Text = "🚗 传送: " .. self.TeleportCount
		p.StationInfoLabel.Text = ""
		p.ModeButton.Text = "🚕 切换到公交车"
	else
		p.StatLabel1.Text = "👥 乘客: " .. #self.CurrentPassengers .. "/" .. self.BusConfig.MAX_PASSENGERS
		p.StatLabel2.Text = "🚏 站点: " .. self.StationCount
		p.StationInfoLabel.Text = "📍 站台: 无"
		p.ModeButton.Text = "🚌 切换到出租车"
	end
	self:UpdateMoneyUI(false)
	print("[Money] 切换到 " .. (self.MoneyMode == "taxi" and "出租车" or "公交车") .. " 模式")
end

-- 更新刷钱UI状态
function MainMenu:UpdateMoneyUI(isActive)
	local p = self.MoneyPanel
	if isActive then
		p.StatusLabel.Text = "▶ 运行中"
		p.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
		p.StartButton.Text = "⏹ 停止"
		p.StartButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		p.Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		p.DotGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	else
		p.StatusLabel.Text = "⏸ 已停止"
		p.StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		p.StartButton.Text = "▶ 启动"
		p.StartButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
		p.Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		p.DotGlow.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		if self.MoneyMode == "taxi" then
			p.OrderStatusLabel.Text = "🔄 等待启动（出租车）..."
		else
			p.OrderStatusLabel.Text = "🔄 等待启动（公交车）..."
		end
	end
end

-- 重置统计
function MainMenu:ResetMoneyStats()
	if self.MoneyRunning then
		print("[Money] 请先停止运行再重置")
		return
	end
	self.OrderCount = 0
	self.TeleportCount = 0
	self.PassengerCount = 0
	self.StationCount = 0
	self.CurrentPassengers = {}

	local p = self.MoneyPanel
	if self.MoneyMode == "taxi" then
		p.StatLabel1.Text = "📦 接单: 0"
		p.StatLabel2.Text = "🚗 传送: 0"
		p.OrderStatusLabel.Text = "🔄 统计已重置（出租车）"
	else
		p.StatLabel1.Text = "👥 乘客: 0/" .. self.BusConfig.MAX_PASSENGERS
		p.StatLabel2.Text = "🚏 站点: 0"
		p.OrderStatusLabel.Text = "🔄 统计已重置（公交车）"
	end
	print("[Money] 统计已重置")
end

-- ============================================================
-- =====           刷钱助手 - 核心功能（内部）              =====
-- ============================================================

-- 工具：点击
function MainMenu:_ClickAt(x, y)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- 出租车：接单
function MainMenu:_TaxiAcceptOrder()
	local screenSize = workspace.CurrentCamera.ViewportSize
	local phoneX = screenSize.X * 0.85
	local phoneY = screenSize.Y * 0.35

	print("[Money][Taxi] 📱 执行接单点击...")
	self:_ClickAt(phoneX, phoneY)
	task.wait(0.3)
	self:_ClickAt(phoneX, phoneY + 100)
	task.wait(0.3)
	self:_ClickAt(phoneX, phoneY + 160)
	task.wait(0.3)
	self:_ClickAt(phoneX, phoneY + 240)
	task.wait(0.3)

	self.OrderCount = self.OrderCount + 1
	self.MoneyPanel.StatLabel1.Text = "📦 接单: " .. self.OrderCount
	print("[Money][Taxi] ✅ 接单操作完成 (#" .. self.OrderCount .. ")")
end

-- 获取目标位置
function MainMenu:_GetTargetPosition()
	local success, result = pcall(function()
		local targetFolder = workspace.Gameplay.Entities.ClientContent
		if not targetFolder then return nil end
		for _, child in ipairs(targetFolder:GetDescendants()) do
			if child:IsA("BasePart") then
				return child.Position + Vector3.new(0, 3, 0)
			end
		end
		return nil
	end)
	if not success then
		print("[Money][Taxi] ⚠ 获取目标位置出错，跳过本次传送")
		return nil
	end
	return result
end

-- 出租车：传送
function MainMenu:_TaxiTeleport(pos)
	local Player = Players.LocalPlayer
	local char = Player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local humanoid = char:FindFirstChild("Humanoid")
	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end
	hrp.CFrame = CFrame.new(pos)
	hrp.Velocity = Vector3.new(0, 0, 0)
	hrp.RotVelocity = Vector3.new(0, 0, 0)
	return true
end

-- 出租车循环
function MainMenu:_TaxiLoop()
	while self.MoneyRunning and self.MoneyMode == "taxi" do
		self.MoneyPanel.OrderStatusLabel.Text = "📱 正在接单..."
		self:_TaxiAcceptOrder()
		self.MoneyPanel.OrderStatusLabel.Text = "⏳ 等待 " .. self.TaxiConfig.ORDER_INTERVAL .. "秒后接单..."
		task.wait(self.TaxiConfig.ORDER_INTERVAL)
		if not self.MoneyRunning then break end

		self.MoneyPanel.OrderStatusLabel.Text = "🚗 正在传送..."
		local pos = self:_GetTargetPosition()
		if pos and self:_TaxiTeleport(pos) then
			self.TeleportCount = self.TeleportCount + 1
			self.MoneyPanel.StatLabel2.Text = "🚗 传送: " .. self.TeleportCount
			print("[Money][Taxi] ✅ 传送完成 (#" .. self.TeleportCount .. ")")
		else
			print("[Money][Taxi] ⚠ 传送失败")
		end
		self.MoneyPanel.OrderStatusLabel.Text = "⏳ 等待 " .. self.TaxiConfig.TELEPORT_INTERVAL .. "秒后传送..."
		task.wait(self.TaxiConfig.TELEPORT_INTERVAL)
	end
end

-- 公交车：查找站台
function MainMenu:_FindBusStops()
	local stops = {}
	local added = {}

	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") then
			local name = part.Name:lower()
			if name:find("busstop") or name:find("station") or part.BrickColor == BrickColor.new("Bright blue") then
				local pos = part.Position
				local key = tostring(pos)
				if not added[key] then
					added[key] = true
					table.insert(stops, pos + Vector3.new(0, 3, 0))
				end
			end
		end
	end

	if #stops == 0 then
		local targetFolder = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Entities") and workspace.Gameplay.Entities:FindFirstChild("ClientContent")
		if targetFolder then
			for _, child in ipairs(targetFolder:GetDescendants()) do
				if child:IsA("BasePart") then
					local pos = child.Position
					local key = tostring(pos)
					if not added[key] then
						added[key] = true
						table.insert(stops, pos + Vector3.new(0, 3, 0))
					end
				end
			end
		end
	end

	return stops
end

function MainMenu:_RefreshBusStops()
	self.BusStops = self:_FindBusStops()
	if #self.BusStops == 0 then
		warn("[Money][Bus] ⚠ 未找到任何公交站台！")
	else
		print("[Money][Bus] 🚏 找到 " .. #self.BusStops .. " 个站台")
	end
	self.CurrentStopIndex = 1
end

-- 公交车：传送
function MainMenu:_BusTeleport(pos)
	local Player = Players.LocalPlayer
	local char = Player.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local humanoid = char:FindFirstChild("Humanoid")
	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end
	local offset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
	hrp.CFrame = CFrame.new(pos + offset) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
	hrp.Velocity = Vector3.zero
	hrp.RotVelocity = Vector3.zero
	return true
end

-- 公交车：接客
function MainMenu:_BusPickup()
	local screenSize = workspace.CurrentCamera.ViewportSize
	local phoneX = screenSize.X * 0.85
	local phoneY = screenSize.Y * 0.35

	for i = 1, self.BusConfig.CLICK_COUNT do
		self:_ClickAt(phoneX, phoneY + (i - 1) * 50)
		task.wait(0.2 + math.random() * 0.2)
	end
	self.PassengerCount = self.PassengerCount + 1
	table.insert(self.CurrentPassengers, { id = self.PassengerCount, time = os.time() })
	self.MoneyPanel.StatLabel1.Text = "👥 乘客: " .. #self.CurrentPassengers .. "/" .. self.BusConfig.MAX_PASSENGERS
	self.MoneyPanel.OrderStatusLabel.Text = "👤 接载乘客 #" .. self.PassengerCount
	print("[Money][Bus] ✅ 接载乘客成功 (#" .. self.PassengerCount .. ") 当前载客: " .. #self.CurrentPassengers)
end

-- 公交车：送达
function MainMenu:_BusDeliver()
	if #self.CurrentPassengers == 0 then
		self.MoneyPanel.OrderStatusLabel.Text = "⚠ 没有乘客可送"
		return
	end
	local screenSize = workspace.CurrentCamera.ViewportSize
	local phoneX = screenSize.X * 0.85
	local phoneY = screenSize.Y * 0.35
	local destY = phoneY + self.BusConfig.DESTINATION_OFFSET

	for i = 1, 3 do
		self:_ClickAt(phoneX, destY + i * 60)
		task.wait(0.3 + math.random() * 0.2)
	end

	local delivered = #self.CurrentPassengers
	self.CurrentPassengers = {}
	self.StationCount = self.StationCount + 1
	self.MoneyPanel.StatLabel1.Text = "👥 乘客: 0/" .. self.BusConfig.MAX_PASSENGERS
	self.MoneyPanel.StatLabel2.Text = "🚏 站点: " .. self.StationCount
	self.MoneyPanel.OrderStatusLabel.Text = "✅ 送达 " .. delivered .. " 名乘客到站点 #" .. self.StationCount
	print("[Money][Bus] ✅ 送达 " .. delivered .. " 名乘客到站点 #" .. self.StationCount)
end

function MainMenu:_CheckPassengerIncrease(prevCount, timeout)
	local startTime = tick()
	while tick() - startTime < timeout do
		task.wait(0.5)
		if #self.CurrentPassengers > prevCount then
			return true
		end
	end
	return false
end

-- 公交车循环
function MainMenu:_BusLoop()
	self:_RefreshBusStops()
	if #self.BusStops == 0 then
		self.MoneyPanel.OrderStatusLabel.Text = "❌ 无可用站台，停止"
		print("[Money][Bus] ❌ 无可用站台，停止循环")
		self.MoneyRunning = false
		self:UpdateMoneyUI(false)
		return
	end

	while self.MoneyRunning and self.MoneyMode == "bus" do
		local targetPos = self.BusStops[self.CurrentStopIndex]
		if not targetPos then
			self.CurrentStopIndex = 1
			targetPos = self.BusStops[self.CurrentStopIndex]
		end

		self.MoneyPanel.StationInfoLabel.Text = "📍 站台 " .. self.CurrentStopIndex .. "/" .. #self.BusStops
		self.MoneyPanel.OrderStatusLabel.Text = "🚌 传送到站台 " .. self.CurrentStopIndex

		if not self:_BusTeleport(targetPos) then
			self.MoneyPanel.OrderStatusLabel.Text = "⚠ 传送失败，跳过此站台"
			self.CurrentStopIndex = self.CurrentStopIndex + 1
			task.wait(1)
			if self.CurrentStopIndex > #self.BusStops then self.CurrentStopIndex = 1 end
			continue
		end
		task.wait(0.5)

		local prevCount = #self.CurrentPassengers
		self.MoneyPanel.OrderStatusLabel.Text = "🔄 尝试接客 (站台 " .. self.CurrentStopIndex .. ")"
		self:_BusPickup()

		local gotPassenger = self:_CheckPassengerIncrease(prevCount, self.BusConfig.TIMEOUT_SECONDS)

		if gotPassenger then
			self.MoneyPanel.OrderStatusLabel.Text = "✅ 成功接到乘客！"
			print("[Money][Bus] ✅ 站台 " .. self.CurrentStopIndex .. " 接客成功")
			if #self.CurrentPassengers >= self.BusConfig.MAX_PASSENGERS then
				self.MoneyPanel.OrderStatusLabel.Text = "🚌 满员，准备送达..."
				task.wait(1)
				self:_BusDeliver()
				task.wait(self.BusConfig.DELIVER_INTERVAL)
			else
				task.wait(self.BusConfig.PICKUP_INTERVAL)
			end
		else
			self.MoneyPanel.OrderStatusLabel.Text = "⏱ " .. self.BusConfig.TIMEOUT_SECONDS .. "秒未接客，切换站台"
			print("[Money][Bus] ⏱ 站台 " .. self.CurrentStopIndex .. " 超时，切换到下一个")
			self.CurrentStopIndex = self.CurrentStopIndex + 1
			if self.CurrentStopIndex > #self.BusStops then self.CurrentStopIndex = 1 end
			if #self.CurrentPassengers > prevCount then
				for i = #self.CurrentPassengers, prevCount + 1, -1 do
					table.remove(self.CurrentPassengers, i)
				end
				self.MoneyPanel.StatLabel1.Text = "👥 乘客: " .. #self.CurrentPassengers .. "/" .. self.BusConfig.MAX_PASSENGERS
			end
			task.wait(1)
		end
	end
end

-- 启动刷钱循环
function MainMenu:StartMoneyLoop()
	if self.MoneyRunning then return end
	self.MoneyRunning = true
	self:UpdateMoneyUI(true)

	-- 上报：刷钱启动
	reporter:ReportMoneyStart(self.MoneyMode)

	if self.MoneyMode == "taxi" then
		print("[Money] 🚖 出租车模式启动")
		self.MoneyPanel.OrderStatusLabel.Text = "🚖 出租车运行中..."
		self.MoneyLoopThread = task.spawn(function()
			self:_TaxiLoop()
		end)
	else
		print("[Money] 🚌 公交车模式启动")
		self.MoneyPanel.OrderStatusLabel.Text = "🚌 公交车运行中..."
		self.MoneyLoopThread = task.spawn(function()
			self:_BusLoop()
		end)
	end
end

-- 停止刷钱循环
function MainMenu:StopMoneyLoop()
	if not self.MoneyRunning then return end
	self.MoneyRunning = false
	self.MoneyLoopThread = nil
	self:UpdateMoneyUI(false)
	print("[Money] ⏹ 已停止")

	-- 上报：刷钱停止 + 统计
	local stats
	if self.MoneyMode == "taxi" then
		print("[Money] 📊 统计 - 接单: " .. self.OrderCount .. " | 传送: " .. self.TeleportCount)
		stats = { orders = self.OrderCount, teleports = self.TeleportCount }
	else
		print("[Money] 📊 统计 - 乘客: " .. self.PassengerCount .. " | 站点: " .. self.StationCount)
		stats = { passengers = self.PassengerCount, stations = self.StationCount }
	end
	reporter:ReportMoneyStop(self.MoneyMode, stats)
end

-- ============================================================
-- =====              主菜单原有功能                         =====
-- ============================================================

-- 开始游戏
function MainMenu:OnPlayClick()
	UIManager:Notify("开始游戏", "正在进入游戏世界...", "success", 2)

	-- 延迟后隐藏主菜单，显示 HUD
	task.delay(1.5, function()
		UIManager:HideUI("MainMenu")
		UIManager:ShowUI("HUD")
	end)
end

-- 退出游戏
function MainMenu:OnQuitClick()
	-- 实际项目中可以用 game.Shutdown:Fire() 或 teleport
	UIManager:Notify("提示", "感谢游玩！", "info", 2)
end

-- 界面显示时调用
function MainMenu:OnShow()
	print("[MainMenu] 主菜单已显示")
	-- 启动使用信息上报心跳
	reporter:StartHeartbeat()
end

-- 界面隐藏时调用
function MainMenu:OnHide()
	print("[MainMenu] 主菜单已隐藏")
	-- 隐藏时也关闭刷钱面板
	if self.MoneyPanel and self.MoneyPanel.ToggleButton and self.MoneyPanel.ToggleButton.Visible then
		self:CloseMoneyPanel()
	end
	-- 停止上报心跳
	reporter:StopHeartbeat()
end

return MainMenu
