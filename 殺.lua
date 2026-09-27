local success, library = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu-ui/heads/main/mainUI.lua"))()
end)

if not success then
	warn("加载UI发生错误")
	return
end

-- ====================== 新增卡密验证代码开始 ======================
local expireTime = os.time({year=9999, month=12, day=31, hour=24, min=60, sec=60})

local function getRemainingTime()
	local now = os.time()
	local diff = expireTime - now
	if diff <= 0 then
		return "已过期"
	end
	local days = math.floor(diff / 86400)
	diff = diff % 86400
	local hours = math.floor(diff / 3600)
	diff = diff % 3600
	local minutes = math.floor(diff / 60)
	local seconds = diff % 60
	return string.format("%d天%d小时%d分%d秒", days, hours, minutes, seconds)
end

--卡密校验
if ScriptKey == "WOWFREEKey" then
	print("WOW FREE loder 100%")
	local remaining = getRemainingTime()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "xiaoyi脚本",
		Text = "当前卡密: ".. ScriptKey .. " 距离过期时间还有: " .. remaining,
		Duration = 5
	})
	task.spawn(function()
		while true do
			require(game.ReplicatedStorage.devv).load("makeToast")("购买xiaoyi脚本卡密前往卡网https://buy.jry0.com/shop/A267SFTX", 1)
			task.wait(1)
		end
	end)
	task.wait(1.5)
	do
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "xiaoyi脚本",
			Text = "初始化完成",
			Duration = 1,
		})
	end
	task.wait(1)
else
    --卡密错误就停止运行下面全部脚本
    return
end
-- ====================== 新增卡密验证代码结束 ======================

local Blacklist = {
	Users = {
		"aja_2244",
		"hxkbd769",
		"linluqw",
		"woshidasab91666"
		"WIFITJob"
		"Biblestudy"
		"helps"
		"there"
		"weregonna"
		"mkfifo"
	}
}

local localPlayer = game.Players.LocalPlayer
local playerName = localPlayer.Name
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local isBanned = false

local ragdollEnabled = false
local isRagdolled = false
local motorBackup = {}

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function toggleRagdoll()
	local character = getCharacter()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not isRagdolled then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.AutoRotate = false
		motorBackup = {}

		for _, joint in ipairs(character:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = Instance.new("BallSocketConstraint")
				local a1 = Instance.new("Attachment")
				local a2 = Instance.new("Attachment")

				a1.CFrame = joint.C0
				a2.CFrame = joint.C1
				a1.Parent = joint.Part0
				a2.Parent = joint.Part1

				socket.Attachment0 = a1
				socket.Attachment1 = a2
				socket.Parent = joint.Parent
				socket.LimitsEnabled = true
				socket.TwistLimitsEnabled = true

				motorBackup[joint.Name .. "_" .. joint:GetFullName()] = {
					Part0 = joint.Part0,
					Part1 = joint.Part1,
					C0 = joint.C0,
					C1 = joint.C1,
					Parent = joint.Parent,
				}
				joint:Destroy()
			end
		end

		root.Velocity = Vector3.new(0, 15, 0)
		isRagdolled = true
	else
		for _, data in pairs(motorBackup) do
			local motor = Instance.new("Motor6D")
			motor.Name = "RestoredMotor"
			motor.Part0 = data.Part0
			motor.Part1 = data.Part1
			motor.C0 = data.C0
			motor.C1 = data.C1
			motor.Parent = data.Parent
		end
		motorBackup = {}

		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		humanoid.AutoRotate = true

		for _, item in ipairs(character:GetDescendants()) do
			if item:IsA("BallSocketConstraint") or item:IsA("Attachment") then
				item:Destroy()
			end
		end
		isRagdolled = false
	end
end


player.CharacterAdded:Connect(function(char)
    isRagdolled = false
    motorBackup = {}
end)

for _, bannedName in pairs(Blacklist.Users) do
    if string.lower(playerName) == string.lower(bannedName) then
        isBanned = true
        break
    end
end

if isBanned then
    
    wait(5)
    game.Players.LocalPlayer:Kick("用户： " .. playerName .. " ┃你已被列入xiaoyi脚本黑名单 \n\n（错误代码: 赤兔团队已把你拉黑）")
    return
end

local FengY3 = {
    "xiaoyi脚本", "赤急霸制作", "FengYu Hub", "爆打所有人", 
}

local randomName = FengY3[math.random(1, #FengY3)]
local window = library:new(randomName)
local tag1 = window:AddTag("xiaoyi脚本 v3", Color3.fromRGB(100, 200, 255))
local tag2 = window:AddTag("赤兔团队", Color3.fromRGB(100, 255, 100))
--殺用户服务
local FY = window:card("个人信息", "你自己的信息", "115654494819611")

local FengYu = FY:Tab("〖玩家使用信息】",'84830962019412')

local about = FengYu:section("〖个人信息】",true)

about:Image({Type = "Player", UserId = game.Players.LocalPlayer.UserId}, 150, 150)
about:Label("用户名：" .. game.Players.LocalPlayer.Name)
about:Label("用户ID:" .. tostring(game.Players.LocalPlayer.UserId))
about:Button("复制用户ID", function()
    setclipboard(tostring(game.Players.LocalPlayer.UserId))
end)
about:Label("你的注入器:" .. identifyexecutor())
about:Label("注册账号：" ..game.Players.LocalPlayer.AccountAge .. "天")
about:Label("地区：" .. game:GetService("LocalizationService").RobloxLocaleId)
about:Label("客户端ID:" .. game:GetService("RbxAnalyticsService"):GetClientId())
local FengYu = FY:Tab("〖玩家使用信息】",'84830962019412')
local about = FengYu:section("〖服务器信息】",true)
about:Image({Type = "Game", PlaceId = game.PlaceId}, 150, 150)
about:Label("服务器名字:"..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
about:Label("服务器ID:"..tostring(game.GameId))

about:Button("复制游戏ID", function()
    setclipboard(tostring(game.GameId))
end)

local FY = window:card("全局通用", "毫无疑问就是通用", "132419977785712")

local FengYu = FY:Tab("〖本地玩家】",'84830962019412')

local Feng = FengYu:section("〖修改权限※】",true)
            Feng:Toggle("速度 (开/关)","开关",false,function(v)
                if v == true then
                    sudu = game:GetService("RunService").Heartbeat:Connect(function()
                        if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Humanoid and game:GetService("Players").LocalPlayer.Character.Humanoid.Parent then
                            if game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                                game:GetService("Players").LocalPlayer.Character:TranslateBy(game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * Speed / 10)
                            end
                        end
                    end)
                elseif not v and sudu then
                    sudu:Disconnect()
                    sudu = nil
                end
            end)

            Feng:Slider('速度设置', '拉条',  1, 1, 1000,false, function(v)
                Speed = v
            end)

Feng:Textbox("快速跑步", "tpwalking", "推荐调2", function(king)
local tspeed = king
local hb = game:GetService("RunService").Heartbeat
local tpwalking = true
local player = game:GetService("Players")
local lplr = player.LocalPlayer
local chr = lplr.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
while tpwalking and hb:Wait() and chr and hum and hum.Parent do
  if hum.MoveDirection.Magnitude > 0 then
    if tspeed then
      chr:TranslateBy(hum.MoveDirection * tonumber(tspeed))
    else
      chr:TranslateBy(hum.MoveDirection)
    end
  end
end
end)
    
Feng:Textbox("漂移加速", "", "输入", function(Value)
    if tonumber(Value) then
        speed = tonumber(Value)
        tpwalkingspeed = true
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        
        if humanoid then
            RunService:UnbindFromRenderStep("TPWalk")

            RunService:BindToRenderStep("TPWalk", Enum.RenderPriority.Character.Value, function(delta)
                if tpwalkingspeed and character and humanoid and humanoid.Parent then
                    if humanoid.MoveDirection.Magnitude > 0 then
                        character:TranslateBy(humanoid.MoveDirection * speed * delta * 10)
                    end
                end
            end)
        end
    else
        print("感觉自己好帅呀")
    end
end)

Feng:Button("点击即可漂移加速关闭",function()
    tpwalkingspeed = false
    RunService:UnbindFromRenderStep("TPWalk")
end)
  
Feng:Slider('修改跳跃', 'JumpPowerSlider', 50, 50, 99999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)
    
Feng:Slider('修改生命值', 'Sliderflag',  100, 100, 999999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.Health = Value
end)
 
Feng:Slider('相机焦距上限', 'ZOOOOOM OUT!',  20, 0, 200000,false, function(Value)
    game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = Value
end)
    
local FengYu = FY:Tab("〖通用】",'84830962019412')

local Feng = FengYu:section("〖精选通用※】",true)
  
Feng:Toggle("人物不可见状态(隐身)", "Invisible Character", false, function(enabled)
  
  local localPlayer = game.Players.LocalPlayer
  for _, child in pairs((localPlayer.Character or localPlayer.CharacterAdded:Wait()):GetChildren()) do
    local isBasePart = child:IsA("BasePart")
    if isBasePart then
      if enabled then
        isBasePart = 1
      else
        isBasePart = 0
      end
      child.Transparency = isBasePart
      child.CanCollide = not enabled
    elseif child:IsA("Accessory") then
      local handle = child.Handle
      local transparency = nil	
      if enabled then
        transparency = 1
      else
        transparency = 0
      end
      handle.Transparency = transparency
    end
  end
end)

Feng:Toggle("隐身〖实用】", "FengYu", false, function(state)
    if state then
        local savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        wait()
        game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
        wait(.15)
        local Seat = Instance.new('Seat', game.Workspace)
        Seat.Anchored = false
        Seat.CanCollide = false
        Seat.Name = 'invischair'
        Seat.Transparency = 1
        Seat.Position = Vector3.new(-25.95, 84, 3537.55)
        local Weld = Instance.new("Weld", Seat)
        Weld.Part0 = Seat
        Weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character.UpperTorso
        wait()
        Seat.CFrame = savedpos
        
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0.5
            end
        end
    else
        local invisChair = workspace:FindFirstChild('invischair')
        if invisChair then
            invisChair:Destroy()
        end
        
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end
end)
  
Feng:Toggle("穿墙", "FengYu", false, function(Value)
    if Value then
        Noclip = true
        Stepped = game.RunService.Stepped:Connect(function()
            if Noclip == true then
                for a, b in pairs(game.Workspace:GetChildren()) do
                    if b.Name == game.Players.LocalPlayer.Name then
                        for i, v in pairs(game.Workspace[game.Players.LocalPlayer.Name]:GetChildren()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end
            else
                Stepped:Disconnect()
            end
        end)
    else
        Noclip = false
    end
end)
 
Feng:Toggle("自动互动","AutoInteract",false, function(state)
    if state then
        autoInteract = true
        while autoInteract do
            for _,descendant in pairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    fireproximityprompt(descendant)
                end
            end
            task.wait(0.25)
        end
    else
        autoInteract = false
    end
end)

Feng:Button("快速互动", function() 
    game.ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    
    prompt.HoldDuration = 0
  end)
end)

Feng:Toggle("快速交互", "Faster", false, function(Fast)
    Faster = Fast
end)

Feng:Toggle("夜视", "FengYu", false, function(state)
        if state then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end)
    
Feng:Toggle("无限跳","Toggle",false,function(Value)
        Jump = Value
        game.UserInputService.JumpRequest:Connect(function()
            if Jump then
                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    end)

Feng:Toggle("无敌", "FengYu", false, function(Value)
    if Value then
        local Cam = workspace.CurrentCamera
        local Pos, Char = Cam.CFrame, speaker.Character
        local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
        local nHuman = Human:Clone()
        nHuman.Parent = Char
        nHuman:SetStateEnabled(Enum.HumanoidStateType.Health, false)
        nHuman:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        nHuman:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()
        speaker.Character = nil
        speaker.Character = Char
        Cam.CameraSubject = nHuman
        Cam.CFrame = wait() and Pos or Cam.CFrame
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local Script = Char:FindFirstChild("Animate")
        if Script then
            Script.Disabled = true
            wait()
            Script.Disabled = false
        end
        nHuman.Health = nHuman.MaxHealth
    else
        game.Players.LocalPlayer.Character.Humanoid.Health = 100
    end
end)

Feng:Toggle("停止移动", "Fake flag", false, function(enabled)
  
  local localPlayer = game.Players.LocalPlayer
  local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
  if enabled then
    for _, child in pairs(character:GetChildren()) do
      if child:IsA("BasePart") then
        child.Anchored = true
      end
    end
  else
    for _, child in pairs(character:GetChildren()) do
      if child:IsA("BasePart") then
        child.Anchored = false
      end
    end
  end
end)

Feng:Toggle('上帝模式', 'No Description', false, function(Value)
        if Value then
            local LP = game:GetService"Players".LocalPlayer
            local HRP = LP.Character.HumanoidRootPart
            local Clone = HRP:Clone()
            Clone.Parent = LP.Character
        else
            game.Players.LocalPlayer.Character.Head:Destroy()
        end
    end)
 
Feng:Toggle("子弹追踪", "silent", false, function(enabled)
  
  local camera = nil	
  local Players = nil	
  local localPlayer = nil	
  local originalNamecall = nil	
  local originalIndex = nil	
  if enabled then
    camera = workspace.CurrentCamera
    Players = game.Players
    localPlayer = Players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    function ClosestPlayer()
      
      local closestDistance = math.huge
      local closestPlayer = nil
      for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character then
          local head = player.Character:FindFirstChild("Head")
          if head then
            local screenPoint, isVisible = camera:WorldToScreenPoint(head.Position)
            if isVisible then
              local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)).Magnitude
              if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
              end
            end
          end
        end
      end
      return closestPlayer
    end
    local metatable = getrawmetatable(game)
    originalNamecall = metatable.__namecall
    originalIndex = metatable.__index
    setreadonly(metatable, false)
    metatable.__namecall = newcclosure(function(self, ...)
      
      local args = {
        ...
      }
      if getnamecallmethod() == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local targetPlayer = ClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
          args[1] = Ray.new(camera.CFrame.Position, ((targetPlayer.Character.Head.Position - camera.CFrame.Position)).Unit * 1000)
          return originalNamecall(self, unpack(args))
        end
      end
      return originalNamecall(self, ...)
    end)
    metatable.__index = newcclosure(function(self, key)
      
      if key == "Clips" then
        return workspace.Map
      end
      return originalIndex(self, key)
    end)
    setreadonly(metatable, true)
    
  else
    camera = workspace.CurrentCamera
    Players = game.Players
    localPlayer = Players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    function ClosestPlayer()
      
      local closestDistance = math.huge
      local closestPlayer = nil
      for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character then
          local head = player.Character:FindFirstChild("Head")
          if head then
            local screenPoint, isVisible = camera:WorldToScreenPoint(head.Position)
            if isVisible then
              local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)).Magnitude
              if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
              end
            end
          end
        end
      end
      return closestPlayer
    end
    local gameInstance = game
    local metatable = getrawmetatable(gameInstance)
    originalNamecall = metatable.__namecall
    originalIndex = metatable.__index
    setreadonly(metatable, false)
    metatable.__namecall = newcclosure(function(self, ...)
      
      local args = {
        ...
      }
      if getnamecallmethod() == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local targetPlayer = ClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
          args[1] = Ray.new(camera.CFrame.Position, ((targetPlayer.Character.Head.Position - camera.CFrame.Position)).Unit * 1000)
          return originalNamecall(self, unpack(args))
        end
      end
      return originalNamecall(self, ...)
    end)
    metatable.__index = newcclosure(function(self, key)
      
      if key == "Clips" then
        return workspace.Map
      end
      return originalIndex(self, key)
    end)
    setreadonly(metatable, true)
    
  end
end)

Feng:Button("xiaoyi飞行",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/fly.lua"))()
end)
    
Feng:Button("无敌少侠",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414"))()
end)

Feng:Button("飞车",function()  
local Flymguiv2 = Instance.new("ScreenGui")
local Drag = Instance.new("Frame")
local FlyFrame = Instance.new("Frame")
local ddnsfbfwewefe = Instance.new("TextButton")
local Speed = Instance.new("TextBox")
local Fly = Instance.new("TextButton")
local Speeed = Instance.new("TextLabel")
local Stat = Instance.new("TextLabel")
local Stat2 = Instance.new("TextLabel")
local Unfly = Instance.new("TextButton")
local Vfly = Instance.new("TextLabel")
local Close = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local Flyon = Instance.new("Frame")
local W = Instance.new("TextButton")
local S = Instance.new("TextButton")

--Properties:

Flymguiv2.Name = "Flym gui v2"
Flymguiv2.Parent = game.CoreGui
Flymguiv2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Drag.Name = "Drag"
Drag.Parent = Flymguiv2
Drag.Active = true
Drag.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Drag.BorderSizePixel = 0
Drag.Draggable = true
Drag.Position = UDim2.new(0.482438415, 0, 0.454874992, 0)
Drag.Size = UDim2.new(0, 237, 0, 27)

FlyFrame.Name = "FlyFrame"
FlyFrame.Parent = Drag
FlyFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FlyFrame.BorderSizePixel = 0
FlyFrame.Draggable = true
FlyFrame.Position = UDim2.new(-0.00200000009, 0, 0.989000022, 0)
FlyFrame.Size = UDim2.new(0, 237, 0, 139)

ddnsfbfwewefe.Name = "ddnsfbfwewefe"
ddnsfbfwewefe.Parent = FlyFrame
ddnsfbfwewefe.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
ddnsfbfwewefe.BorderSizePixel = 0
ddnsfbfwewefe.Position = UDim2.new(-0.000210968778, 0, -0.00395679474, 0)
ddnsfbfwewefe.Size = UDim2.new(0, 237, 0, 27)
ddnsfbfwewefe.Font = Enum.Font.SourceSans
ddnsfbfwewefe.Text = "xiaoyi脚本"
ddnsfbfwewefe.TextColor3 = Color3.fromRGB(255, 255, 255)
ddnsfbfwewefe.TextScaled = true
ddnsfbfwewefe.TextSize = 14.000
ddnsfbfwewefe.TextWrapped = true

Speed.Name = "Speed"
Speed.Parent = FlyFrame
Speed.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
Speed.BorderColor3 = Color3.fromRGB(0, 0, 191)
Speed.BorderSizePixel = 0
Speed.Position = UDim2.new(0.445025861, 0, 0.402877688, 0)
Speed.Size = UDim2.new(0, 111, 0, 33)
Speed.Font = Enum.Font.SourceSans
Speed.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
Speed.Text = "50"
Speed.TextColor3 = Color3.fromRGB(255, 255, 255)
Speed.TextScaled = true
Speed.TextSize = 14.000
Speed.TextWrapped = true

Fly.Name = "Fly"
Fly.Parent = FlyFrame
Fly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Fly.BorderSizePixel = 0
Fly.Position = UDim2.new(0.0759493634, 0, 0.705797076, 0)
Fly.Size = UDim2.new(0, 199, 0, 32)
Fly.Font = Enum.Font.SourceSans
Fly.Text = "开启"
Fly.TextColor3 = Color3.fromRGB(255, 255, 255)
Fly.TextScaled = true
Fly.TextSize = 14.000
Fly.TextWrapped = true
Fly.MouseButton1Click:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        Fly.Visible = false
        Stat2.Text = "开启"
        Stat2.TextColor3 = Color3.fromRGB(0, 255, 0)
        Unfly.Visible = true
        Flyon.Visible = true
        local BV = Instance.new("BodyVelocity",HumanoidRP)
        local BG = Instance.new("BodyGyro",HumanoidRP)
        BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        game:GetService('RunService').RenderStepped:connect(function()
        BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
        BG.D = 5000
        BG.P = 100000
        BG.CFrame = game.Workspace.CurrentCamera.CFrame
        end)
end)

Speeed.Name = "Speeed"
Speeed.Parent = FlyFrame
Speeed.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Speeed.BorderSizePixel = 0
Speeed.Position = UDim2.new(0.0759493634, 0, 0.402877688, 0)
Speeed.Size = UDim2.new(0, 87, 0, 32)
Speeed.ZIndex = 0
Speeed.Font = Enum.Font.SourceSans
Speeed.Text = "速度:"
Speeed.TextColor3 = Color3.fromRGB(255, 255, 255)
Speeed.TextScaled = true
Speeed.TextSize = 14.000
Speeed.TextWrapped = true

Stat.Name = "Stat"
Stat.Parent = FlyFrame
Stat.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Stat.BorderSizePixel = 0
Stat.Position = UDim2.new(0.299983799, 0, 0.239817441, 0)
Stat.Size = UDim2.new(0, 85, 0, 15)
Stat.Font = Enum.Font.SourceSans
Stat.Text = "状态:"
Stat.TextColor3 = Color3.fromRGB(255, 255, 255)
Stat.TextScaled = true
Stat.TextSize = 14.000
Stat.TextWrapped = true

Stat2.Name = "Stat2"
Stat2.Parent = FlyFrame
Stat2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Stat2.BorderSizePixel = 0
Stat2.Position = UDim2.new(0.546535194, 0, 0.239817441, 0)
Stat2.Size = UDim2.new(0, 27, 0, 15)
Stat2.Font = Enum.Font.SourceSans
Stat2.Text = "关闭"
Stat2.TextColor3 = Color3.fromRGB(255, 0, 0)
Stat2.TextScaled = true
Stat2.TextSize = 14.000
Stat2.TextWrapped = true

Unfly.Name = "Unfly"
Unfly.Parent = FlyFrame
Unfly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Unfly.BorderSizePixel = 0
Unfly.Position = UDim2.new(0.0759493634, 0, 0.705797076, 0)
Unfly.Size = UDim2.new(0, 199, 0, 32)
Unfly.Visible = false
Unfly.Font = Enum.Font.SourceSans
Unfly.Text = "停止"
Unfly.TextColor3 = Color3.fromRGB(255, 255, 255)
Unfly.TextScaled = true
Unfly.TextSize = 14.000
Unfly.TextWrapped = true
Unfly.MouseButton1Click:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        Fly.Visible = true
        Stat2.Text = "关闭"
        Stat2.TextColor3 = Color3.fromRGB(255, 0, 0)
        wait()
        Unfly.Visible = false
        Flyon.Visible = false
        HumanoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
        HumanoidRP:FindFirstChildOfClass("BodyGyro"):Destroy()
end)

Vfly.Name = "Vfly"
Vfly.Parent = Drag
Vfly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Vfly.BorderSizePixel = 0
Vfly.Size = UDim2.new(0, 57, 0, 27)
Vfly.Font = Enum.Font.SourceSans
Vfly.Text = "飞车"
Vfly.TextColor3 = Color3.fromRGB(255, 255, 255)
Vfly.TextScaled = true
Vfly.TextSize = 14.000
Vfly.TextWrapped = true

Close.Name = "Close"
Close.Parent = Drag
Close.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.875, 0, 0, 0)
Close.Size = UDim2.new(0, 27, 0, 27)
Close.Font = Enum.Font.SourceSans
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextScaled = true
Close.TextSize = 14.000
Close.TextWrapped = true
Close.MouseButton1Click:Connect(function()
        Flymguiv2:Destroy()
end)

Minimize.Name = "Minimize"
Minimize.Parent = Drag
Minimize.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.75, 0, 0, 0)
Minimize.Size = UDim2.new(0, 27, 0, 27)
Minimize.Font = Enum.Font.SourceSans
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextScaled = true
Minimize.TextSize = 14.000
Minimize.TextWrapped = true
function Mini()
        if Minimize.Text == "-" then
                Minimize.Text = "+"
                FlyFrame.Visible = false
        elseif Minimize.Text == "+" then
                Minimize.Text = "-"
                FlyFrame.Visible = true
        end
end
Minimize.MouseButton1Click:Connect(Mini)

Flyon.Name = "Fly on"
Flyon.Parent = Flymguiv2
Flyon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Flyon.BorderSizePixel = 0
Flyon.Position = UDim2.new(0.117647067, 0, 0.550284624, 0)
Flyon.Size = UDim2.new(0.148000002, 0, 0.314999998, 0)
Flyon.Visible = false
Flyon.Active = true
Flyon.Draggable = true

W.Name = "W"
W.Parent = Flyon
W.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
W.BorderSizePixel = 0
W.Position = UDim2.new(0.134719521, 0, 0.0152013302, 0)
W.Size = UDim2.new(0.708999991, 0, 0.499000013, 0)
W.Font = Enum.Font.SourceSans
W.Text = "^"
W.TextColor3 = Color3.fromRGB(255, 255, 255)
W.TextScaled = true
W.TextSize = 14.000
W.TextWrapped = true
W.TouchLongPress:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

W.MouseButton1Click:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

S.Name = "S"
S.Parent = Flyon
S.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
S.BorderSizePixel = 0
S.Position = UDim2.new(0.134000003, 0, 0.479999989, 0)
S.Rotation = 180.000
S.Size = UDim2.new(0.708999991, 0, 0.499000013, 0)
S.Font = Enum.Font.SourceSans
S.Text = "^"
S.TextColor3 = Color3.fromRGB(255, 255, 255)
S.TextScaled = true
S.TextSize = 14.000
S.TextWrapped = true
S.TouchLongPress:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

S.MouseButton1Click:Connect(function()
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
        wait(.1)
        HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)
end)

    Feng:Button(
        "自杀",
        function()
            game.Players.LocalPlayer.Character.Humanoid.Health=0
HumanDied = true
        end
    )    

    Feng:Toggle("FPS显示", "FengYu", false, function(state)
    if state then

        local ScreenGui = Instance.new("ScreenGui")
        local FpsLabel = Instance.new("TextLabel")

        ScreenGui.Name = "FPSGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        FpsLabel.Name = "FPSLabel"
        FpsLabel.Size = UDim2.new(0, 100, 0, 50)
        FpsLabel.Position = UDim2.new(0.75,20,0.075,20)--位置
        FpsLabel.BackgroundTransparency = 1
        FpsLabel.Font = Enum.Font.SourceSansBold
        FpsLabel.Text = "FPS: 0"
        FpsLabel.TextSize = 30
        FpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0) --颜色
        FpsLabel.Parent = ScreenGui

        local frameCounter = 0

        local function updateFpsLabel()
            frameCounter = frameCounter + 1
            if frameCounter >= 20 then
                local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
                FpsLabel.Text = "赤兔FPS: " .. fps
                frameCounter = 0
            end
        end

        local connection = game:GetService("RunService").RenderStepped:Connect(updateFpsLabel)

        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        getgenv().FPS_Toggle = {
            ScreenGui = ScreenGui,
            connection = connection
        }
    else

        if getgenv().FPS_Toggle then
            if getgenv().FPS_Toggle.connection then
                getgenv().FPS_Toggle.connection:Disconnect()
            end
            if getgenv().FPS_Toggle.ScreenGui then
                getgenv().FPS_Toggle.ScreenGui:Destroy()
            end
            getgenv().FPS_Toggle = nil
        end
    end
    end)
    
Feng:Button(
        "动态模糊",
        function()
            local camera = workspace.CurrentCamera
local blurAmount = 10
local blurAmplifier = 5
local lastVector = camera.CFrame.LookVector

local motionBlur = Instance.new("BlurEffect", camera)

local runService = game:GetService("RunService")

workspace.Changed:Connect(function(property)
 if property == "CurrentCamera" then
  print("Changed")
  local camera = workspace.CurrentCamera
  if motionBlur and motionBlur.Parent then
   motionBlur.Parent = camera
  else
   motionBlur = Instance.new("BlurEffect", camera)
  end
 end
end)

runService.Heartbeat:Connect(function()
 if not motionBlur or motionBlur.Parent == nil then
  motionBlur = Instance.new("BlurEffect", camera)
 end
 
 local magnitude = (camera.CFrame.LookVector - lastVector).magnitude
 motionBlur.Size = math.abs(magnitude)*blurAmount*blurAmplifier/2
 lastVector = camera.CFrame.LookVector
end)
        end
    )
    
Feng:Textbox("旋转速度", "SpinSpeed", "输入", function(Value)
    local speed = tonumber(Value)
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")
    humanoid.AutoRotate = false

    if not spinVelocity then
        spinVelocity = Instance.new("AngularVelocity")
        spinVelocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
        spinVelocity.MaxTorque = math.huge
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
        spinVelocity.Parent = humRoot
        spinVelocity.Name = "Spinbot"
    else
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
    end
end)

Feng:Button("停止旋转", function()
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")

    local spinbot = humRoot:FindFirstChild("Spinbot")
    if spinbot then
        spinbot:Destroy()
        spinVelocity = nil
    end
    humanoid.AutoRotate = true 
end)
  
local FengYu = FY:Tab("〖玩家透视】",'84830962019412')

local Feng = FengYu:section("〖ESP系统※】", 
true)

local function GetPlayerWeapon(character)
    local tool = character:FindFirstChildOfClass("Tool")
    return tool and tool.Name or "没武器"
end

local function GetPlayerBackpackWeapons(player)
    local weapons = {}
    if player:FindFirstChild("Backpack") then
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(weapons, tool.Name)
            end
        end
    end
    return #weapons > 0 and table.concat(weapons, ", ") or "没武器"
end

local ESPConfig = {
    Enabled = false,
    
    ShowName = true,
    ShowHealth = false,
    ShowDistance = false,
    ShowWeapon = false,
    ShowTeam = false,
    ShowBackpack = false,
    
    FillTransparency = 0.5,
    OutlineTransparency = 0.2,
    TextSize = 14,
    TextOutline = true,
    
    TeammateColor = Color3.fromRGB(0, 255, 100),
    EnemyColor = Color3.fromRGB(255, 50, 50),
    RainbowSpeed = 2,
    
    MaxDistance = 2000,
    UseDistanceFade = true,
    
    TeamCheck = true,
    
    HighlightEnabled = true,
    BoxOutlineEnabled = true,
    
    WallhackEnabled = false,
    ChamsEnabled = false,
    NameTagSize = 1.0,
    HealthBarEnabled = true,
    DistanceScale = true,
    
    UpdateRate = 30,
    PerformanceMode = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ESPCache = {}
local LastUpdateTime = 0

local function CalculateVisibility(distance, maxDistance)
    if distance > maxDistance then return 0 end
    local fadeStart = maxDistance * 0.8
    if distance > fadeStart then
        return 1 - ((distance - fadeStart) / (maxDistance - fadeStart))
    end
    return 1
end

local function CalculatePlayerColor(esp, humanoid, distance)
    local isTeammate = ESPConfig.TeamCheck and esp.Player.Team == LocalPlayer.Team
    return isTeammate and ESPConfig.TeammateColor or ESPConfig.EnemyColor
end

local function IsBehindWall(character)
    if not ESPConfig.WallhackEnabled then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return true end
    
    local ray = Ray.new(Camera.CFrame.Position, (humanoidRootPart.Position - Camera.CFrame.Position).Unit * 100)
    local part, position = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, LocalPlayer.Character, character})
    
    return part ~= nil
end

local function CreateESP(character, player)
    if not character or not character.Parent or ESPCache[character] then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local esp = {
        Character = character,
        Player = player,
        Highlight = nil,
        Billboard = nil,
        HealthBar = nil,
        Connections = {}
    }
    
    esp.Highlight = Instance.new("Highlight")
    esp.Highlight.Name = "ESP_Highlight"
    esp.Highlight.FillColor = Color3.new(1, 1, 1)
    esp.Highlight.OutlineColor = Color3.new(0, 0, 0)
    esp.Highlight.FillTransparency = ESPConfig.FillTransparency
    esp.Highlight.OutlineTransparency = ESPConfig.OutlineTransparency
    esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    esp.Highlight.Enabled = ESPConfig.Enabled and ESPConfig.HighlightEnabled
    esp.Highlight.Parent = character
    
    esp.Billboard = Instance.new("BillboardGui")
    esp.Billboard.Name = "ESP_Billboard"
    esp.Billboard.AlwaysOnTop = true
    esp.Billboard.Size = UDim2.new(0, 200 * ESPConfig.NameTagSize, 0, 60 * ESPConfig.NameTagSize)
    esp.Billboard.StudsOffset = Vector3.new(0, 3, 0)
    esp.Billboard.Adornee = humanoidRootPart
    esp.Billboard.Enabled = ESPConfig.Enabled
    esp.Billboard.MaxDistance = ESPConfig.MaxDistance
    esp.Billboard.Parent = character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESP_TextLabel"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = ESPConfig.TextSize * ESPConfig.NameTagSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = ESPConfig.TextOutline and 0.5 or 1
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Text = ""
    textLabel.ZIndex = 10
    textLabel.Parent = esp.Billboard
    
    if ESPConfig.HealthBarEnabled then
        local healthBar = Instance.new("Frame")
        healthBar.Name = "ESP_HealthBar"
        healthBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        healthBar.BorderSizePixel = 0
        healthBar.Size = UDim2.new(1, 0, 0, 4 * ESPConfig.NameTagSize)
        healthBar.Position = UDim2.new(0, 0, 1, 0)
        healthBar.ZIndex = 11
        healthBar.Parent = esp.Billboard
        
        local healthFill = Instance.new("Frame")
        healthFill.Name = "ESP_HealthFill"
        healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
        healthFill.BorderSizePixel = 0
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.ZIndex = 12
        healthFill.Parent = healthBar
        
        esp.HealthBar = healthFill
    end
    
    esp.Connections.CharacterRemoving = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            CleanupESP(character)
        end
    end)
    
    ESPCache[character] = esp
end

local function CleanupESP(character)
    local esp = ESPCache[character]
    if esp then
        for _, conn in pairs(esp.Connections) do
            conn:Disconnect()
        end
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        ESPCache[character] = nil
    end
end

local function UpdateESP()
    local currentTime = tick()
    if currentTime - LastUpdateTime < (1 / ESPConfig.UpdateRate) then
        return
    end
    LastUpdateTime = currentTime
    
    if not ESPConfig.Enabled then 
        for character, esp in pairs(ESPCache) do
            if esp.Highlight then esp.Highlight.Enabled = false end
            if esp.Billboard then esp.Billboard.Enabled = false end
        end
        return 
    end
    
    for character, esp in pairs(ESPCache) do
        if not character or not character.Parent then
            CleanupESP(character)
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            if esp.Highlight then esp.Highlight.Enabled = false end
            if esp.Billboard then esp.Billboard.Enabled = false end
            continue
        end
        
        local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        local visibility = CalculateVisibility(distance, ESPConfig.MaxDistance)
        
        if visibility <= 0 then
            if esp.Highlight then esp.Highlight.Enabled = false end
            if esp.Billboard then esp.Billboard.Enabled = false end
            continue
        end
        
        local color = CalculatePlayerColor(esp, humanoid, distance)
        local alphaMultiplier = ESPConfig.UseDistanceFade and visibility or 1
        local isBehindWall = IsBehindWall(character)
        
        if esp.Highlight then
            esp.Highlight.FillColor = color
            esp.Highlight.OutlineColor = Color3.new(0, 0, 0)
            
            esp.Highlight.FillTransparency = ESPConfig.FillTransparency + (0.3 * (1 - alphaMultiplier))
            
            if ESPConfig.BoxOutlineEnabled then
                esp.Highlight.OutlineTransparency = ESPConfig.OutlineTransparency + (0.3 * (1 - alphaMultiplier))
            else
                esp.Highlight.OutlineTransparency = 1
            end
            
            esp.Highlight.Enabled = ESPConfig.HighlightEnabled and (not isBehindWall or ESPConfig.WallhackEnabled)
        end
        
        local textLabel = esp.Billboard:FindFirstChildOfClass("TextLabel")
        if textLabel then
            local textParts = {}
            
            if ESPConfig.ShowName then
                table.insert(textParts, esp.Player.Name)
            end
            
            if ESPConfig.ShowHealth then
                table.insert(textParts, string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
            end
            
            if ESPConfig.ShowDistance then
                table.insert(textParts, string.format("%dm", math.floor(distance)))
            end
            
            if ESPConfig.ShowWeapon then
                table.insert(textParts, GetPlayerWeapon(character))
            end
            
            if ESPConfig.ShowBackpack then
                local backpackWeapons = GetPlayerBackpackWeapons(esp.Player)
                if backpackWeapons ~= "没武器" then
                    table.insert(textParts, "背包: " .. backpackWeapons)
                end
            end
            
            if ESPConfig.ShowTeam then
                local isTeammate = ESPConfig.TeamCheck and esp.Player.Team == LocalPlayer.Team
                table.insert(textParts, isTeammate and "队友" or "敌人")
            end
            
            if isBehindWall and ESPConfig.WallhackEnabled then
                table.insert(textParts, "[墙后的某个地方☠️]")
            end
            
            textLabel.Text = table.concat(textParts, " | ")
            textLabel.TextColor3 = color
            textLabel.TextTransparency = ESPConfig.UseDistanceFade and (0.3 * (1 - alphaMultiplier)) or 0
            textLabel.TextSize = ESPConfig.TextSize * (ESPConfig.DistanceScale and math.clamp(1.5 - (distance / 1000) * 0.5, 0.8, 1.5) or 1) * ESPConfig.NameTagSize
            esp.Billboard.Enabled = #textParts > 0 and (not isBehindWall or ESPConfig.WallhackEnabled)
        end
        
        if esp.HealthBar then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            esp.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
            esp.HealthBar.BackgroundColor3 = Color3.new(1 - healthPercent, healthPercent, 0)
        end
    end
end

local function RecreateAllESP()
    for character, esp in pairs(ESPCache) do
        CleanupESP(character)
    end
    
    if ESPConfig.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateESP(player.Character, player)
            end
        end
    end
    UpdateESP()
end

local function InitializePlayerESP(player)
    if player == LocalPlayer then return end
    
    local function CharacterAdded(character)
        task.wait(0.5)
        if ESPConfig.Enabled then
            CreateESP(character, player)
        end
    end
    
    if player.Character and ESPConfig.Enabled then
        task.spawn(CharacterAdded, player.Character)
    end
    
    player.CharacterAdded:Connect(CharacterAdded)
    player.CharacterRemoving:Connect(function(character)
        CleanupESP(character)
    end)
end

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    pcall(UpdateESP)
end)

if ESPConfig.Enabled then
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            InitializePlayerESP(player)
        end
    end
end

Players.PlayerAdded:Connect(InitializePlayerESP)

Feng:Toggle("开启ESP", "FengYu", false, function(state)
    ESPConfig.Enabled = state
    if state then
        RecreateAllESP()
    else
        for character, esp in pairs(ESPCache) do
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Billboard then esp.Billboard:Destroy() end
        end
        ESPCache = {}
    end
end)

Feng:Toggle("内部发光", "FengYu", false, function(state)
    ESPConfig.HighlightEnabled = state
    for _, esp in pairs(ESPCache) do
        if esp.Highlight then
            esp.Highlight.Enabled = state and ESPConfig.Enabled
        end
    end
end)

Feng:Toggle("方框描边", "FengYu", false, function(state)
    ESPConfig.BoxOutlineEnabled = state
    for _, esp in pairs(ESPCache) do
        if esp.Highlight then
            esp.Highlight.OutlineTransparency = state and ESPConfig.OutlineTransparency or 1
        end
    end
end)

Feng:Toggle("显示玩家名字", "FengYu", false, function(state)
    ESPConfig.ShowName = state
    UpdateESP()
end)

Feng:ColorPicker("队友颜色", "FengYu", Color3.fromRGB(0, 255, 100), function(color)
    ESPConfig.TeammateColor = color
    UpdateESP()
end)

Feng:Toggle("显示血量", "FengYu", false, function(state)
    ESPConfig.ShowHealth = state
    UpdateESP()
end)

Feng:Toggle("显示距离", "FengYu", false, function(state)
    ESPConfig.ShowDistance = state
    UpdateESP()
end)

Feng:Toggle("显示武器", "FengYu", false, function(state)
    ESPConfig.ShowWeapon = state
    UpdateESP()
end)

Feng:Toggle("显示背包", "FengYu", false, function(state)
    ESPConfig.ShowBackpack = state
    UpdateESP()
end)

Feng:ColorPicker("敌人颜色", "FengYu", Color3.fromRGB(255, 50, 50), function(color)
    ESPConfig.EnemyColor = color
    UpdateESP()
end)

Feng:Toggle("显示队伍", "FengYu", false, function(state)
    ESPConfig.ShowTeam = state
    UpdateESP()
end)

Feng:Toggle("队伍检测", "FengYu", false, function(state)
    ESPConfig.TeamCheck = state
    UpdateESP()
end)

Feng:Toggle("穿墙显示", "FengYu", false, function(state)
    ESPConfig.WallhackEnabled = state
    UpdateESP()
end)

Feng:Toggle("距离缩放", "FengYu", false, function(state)
    ESPConfig.DistanceScale = state
    UpdateESP()
end)

local FengYu = FY:Tab("〖自瞄】",'84830962019412')

local isAiming = false
local isPredicting = false
local isWallCheck = false
local isTeamCheck = true
local isFriendCheck = true
local isAliveCheck = true
local isRainbowFOV = false
local isDistanceCheck = false
local isLockSpecific = false
local lockTargets = {}
local predictMode = "自动追随"
local predictDistance = 1.2
local predictHorizontalOffset = 0.5
local maxDistance = 500
local fov = 50
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local attackStrategy = "最近玩家"
local forceAutoDistance = false
local autoDistanceThreshold = 45

local currentTarget = nil
local targetStability = 0
local maxStability = 10
local targetSwitchCooldown = 0
local targetSwitchDelay = 0.3
local lastSwitchTime = 0

local selectedPlayers = {}
local playerSelectionBoxes = {}
local selectionBoxFolder = Instance.new("Folder")
selectionBoxFolder.Name = "PlayerSelectionBoxes"
selectionBoxFolder.Parent = workspace

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(255, 0, 0)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

local FOVCircles = 1
local FOVrings = {}
for i = 1, 10 do
    local ring = Drawing.new("Circle")
    ring.Visible = false
    ring.Thickness = 2
    ring.Color = Color3.fromRGB(255, 0, 0)
    ring.Filled = false
    ring.Radius = fov + (i-1) * 10
    ring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    FOVrings[i] = ring
end

local targetPart = "Head"
local aimSmoothness = 5
local lastAimPosition = nil

local hue = 0
local function getRainbowColor()
    hue = (hue + 0.01) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function isSameTeam(player)
    if not isTeamCheck then
        return false
    end
    
    if plr.Team and player.Team then
        return plr.Team == player.Team
    end
    
    if plr.TeamColor and player.TeamColor then
        return plr.TeamColor == player.TeamColor
    end
    
    return false
end

local function getFriends()
    local friends = {}
    local success, result = pcall(function()
        return Players:GetFriendsAsync(plr.UserId)
    end)
    
    if success and result then
        for _, friend in pairs(result:GetCurrentPage()) do
            friends[friend.Username] = true
        end
    end
    
    success, result = pcall(function()
        return plr:GetFriendsOnline()
    end)
    
    if success and result then
        for _, friend in pairs(result) do
            friends[friend.Username] = true
        end
    end
    
    return friends
end

local function getBestTarget(playersList)
    if #playersList == 0 then
        return nil
    end
    
    if currentTarget and targetStability > maxStability / 2 then
        for _, candidate in ipairs(playersList) do
            if candidate.Player == currentTarget then
                local stabilityBonus = targetStability * 0.2
                candidate.Score = candidate.Score + stabilityBonus
                break
            end
        end
    end
    
    if attackStrategy == "最近玩家" then
        table.sort(playersList, function(a, b)
            return a.ScreenDistance < b.ScreenDistance
        end)
    elseif attackStrategy == "血量最高" then
        table.sort(playersList, function(a, b)
            if a.Health == b.Health then
                return a.WorldDistance < b.WorldDistance
            end
            return a.Health > b.Health
        end)
    elseif attackStrategy == "血量最低" then
        table.sort(playersList, function(a, b)
            if a.Health == b.Health then
                return a.WorldDistance < b.WorldDistance
            end
            return a.Health < b.Health
        end)
    end
    
    local timeSinceLastSwitch = tick() - lastSwitchTime
    if timeSinceLastSwitch < targetSwitchDelay and currentTarget then
        for _, candidate in ipairs(playersList) do
            if candidate.Player == currentTarget then
                return currentTarget
            end
        end
    end
    
    return playersList[1].Player
end

local function calculateTargetPosition(player, targetPart, deltaTime)
    local character = player.Character
    if not character or not character:FindFirstChild(targetPart) then 
        return nil 
    end

    local part = character[targetPart]
    local currentPosition = part.Position
    
    if not isPredicting then
        return currentPosition
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart or not humanoidRootPart.Velocity then
        return currentPosition
    end
    
    local velocity = humanoidRootPart.Velocity
    
    if velocity.Magnitude < 0.1 then
        return currentPosition
    end
    
    if predictMode == "自动追随" then
        local nextPosition = currentPosition + velocity * deltaTime * predictDistance
        return nextPosition
        
    elseif predictMode == "偏左" then
        local moveDirection = velocity.Unit
        local moveSpeed = velocity.Magnitude
        
        local leftDirection = (moveDirection:Cross(Vector3.new(0, 1, 0))).Unit
        
        local nextPosition = currentPosition + 
                            moveDirection * moveSpeed * deltaTime * predictDistance +
                            leftDirection * predictHorizontalOffset
        return nextPosition
        
    elseif predictMode == "偏右" then
        local moveDirection = velocity.Unit
        local moveSpeed = velocity.Magnitude
        
        local rightDirection = -(moveDirection:Cross(Vector3.new(0, 1, 0))).Unit
        
        local nextPosition = currentPosition + 
                            moveDirection * moveSpeed * deltaTime * predictDistance +
                            rightDirection * predictHorizontalOffset
        return nextPosition
    end
    
    return currentPosition
end

local function isVisibleFromCamera(targetPosition)
    if not isWallCheck then
        return true
    end
    
    local origin = Cam.CFrame.Position
    local direction = (targetPosition - origin).Unit
    local distance = (targetPosition - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local filterList = {plr.Character}
    if plr.Character then
        for _, item in ipairs(plr.Character:GetDescendants()) do
            if item:IsA("BasePart") then
                table.insert(filterList, item)
            end
        end
    end
    
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if not raycastResult then
        return true
    end
    
    local hitPart = raycastResult.Instance
    if hitPart then
        local model = hitPart:FindFirstAncestorOfClass("Model")
        if model then
            local hitPlayer = Players:GetPlayerFromCharacter(model)
            if hitPlayer then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character == model then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

local function shouldEnableDistanceCheck()
    if isDistanceCheck then
        return true
    end
    
    if forceAutoDistance then
        return true
    end
    
    if attackStrategy == "最近玩家" then
        return true
    elseif attackStrategy == "血量最高" or attackStrategy == "血量最低" then
        if fov >= autoDistanceThreshold then
            return true
        end
    end
    
    return false
end

local function smoothLookAt(target, alpha)
    local currentCFrame = Cam.CFrame
    local currentPosition = currentCFrame.Position
    
    local targetDirection = (target - currentPosition).Unit
    
    local newLookVector = nil
    if lastAimPosition then
        local lastDirection = (lastAimPosition - currentPosition).Unit
        
        local smoothAlpha = math.min(alpha * (0.05 + aimSmoothness * 0.01), 0.3)
        
        local dotProduct = lastDirection:Dot(targetDirection)
        local angle = math.acos(math.clamp(dotProduct, -1, 1))
        
        if angle > math.rad(30) then
            smoothAlpha = math.min(smoothAlpha * 3, 0.8)
        end
        
        newLookVector = lastDirection:Lerp(targetDirection, smoothAlpha)
    else
        newLookVector = targetDirection
    end
    
    lastAimPosition = target
    local newCFrame = CFrame.new(currentPosition, currentPosition + newLookVector)
    
    if aimSmoothness > 3 then
        TweenService:Create(Cam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = newCFrame}):Play()
    else
        Cam.CFrame = newCFrame
    end
end

local function getTargetPlayer()
    local playerMousePos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local friends = isFriendCheck and getFriends() or {}
    local candidates = {}
    
    if next(selectedPlayers) ~= nil then
        for player in pairs(selectedPlayers) do
            if player and player.Parent and player.Character then
                local character = player.Character
                if character and character:FindFirstChild(targetPart) then
                    if isAliveCheck then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            continue
                        end
                    end
                    
                    if isFriendCheck and friends[player.Name] then
                        continue
                    end
                    
                    if isTeamCheck and isSameTeam(player) then
                        continue
                    end
                    
                    local part = character[targetPart]
                    local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                    local screenDistance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude
                    
                    local effectiveDistanceCheck = shouldEnableDistanceCheck()
                    if effectiveDistanceCheck then
                        local distance = (part.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                        if distance > maxDistance then
                            continue
                        end
                    end
                    
                    local isBehindWall = false
                    if isWallCheck then
                        isBehindWall = not isVisibleFromCamera(part.Position)
                    end
                    
                    if isVisible and not isBehindWall and screenDistance < fov then
                        local candidateInfo = {
                            Player = player,
                            ScreenDistance = screenDistance,
                            WorldDistance = (part.Position - plr.Character.HumanoidRootPart.Position).Magnitude,
                            Health = 100,
                            Score = 100 - screenDistance
                        }
                        
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            candidateInfo.Health = humanoid.Health
                        end
                        
                        table.insert(candidates, candidateInfo)
                    end
                end
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            if selectedPlayers[player] then
                continue
            end
            
            if isFriendCheck and friends[player.Name] then
                continue
            end
            
            if isTeamCheck and isSameTeam(player) then
                continue
            end
            
            local character = player.Character
            if character and character:FindFirstChild(targetPart) then
                if isAliveCheck then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        continue
                    end
                end
                
                local part = character[targetPart]
                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                local screenDistance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude
                
                local effectiveDistanceCheck = shouldEnableDistanceCheck()
                if effectiveDistanceCheck then
                    local distance = (part.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if distance > maxDistance then
                        continue
                    end
                end
                
                local isBehindWall = false
                if isWallCheck then
                    isBehindWall = not isVisibleFromCamera(part.Position)
                end
                
                if isVisible and not isBehindWall and screenDistance < fov then
                    local candidateInfo = {
                        Player = player,
                        ScreenDistance = screenDistance,
                        WorldDistance = (part.Position - plr.Character.HumanoidRootPart.Position).Magnitude,
                        Health = 100,
                        Score = 100 - screenDistance
                    }
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        candidateInfo.Health = humanoid.Health
                    end
                    
                    table.insert(candidates, candidateInfo)
                end
            end
        end
    end
    
    return getBestTarget(candidates)
end

local function updateDrawings()
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    
    if isRainbowFOV then
        local rainbowColor = getRainbowColor()
        FOVring.Color = rainbowColor
        for i = 1, FOVCircles do
            if FOVrings[i] then
                FOVrings[i].Color = rainbowColor
                FOVrings[i].Position = center
            end
        end
    else
        for i = 1, FOVCircles do
            if FOVrings[i] then
                FOVrings[i].Position = center
            end
        end
    end
    
    FOVring.Position = center
end

local function removeFOVring()
    FOVring.Visible = false
    for i = 1, #FOVrings do
        if FOVrings[i] then
            FOVrings[i].Visible = false
        end
    end
end

local function showFOVrings()
    FOVring.Visible = true
    for i = 1, FOVCircles do
        if FOVrings[i] then
            FOVrings[i].Visible = true
            FOVrings[i].Radius = fov + (i-1) * 10
        end
    end
    for i = FOVCircles + 1, #FOVrings do
        if FOVrings[i] then
            FOVrings[i].Visible = false
        end
    end
end

local function toggleAiming(v)
    if v then 
        isAiming = true
        showFOVrings()
        
        targetPart = "Head"
        lastAimPosition = nil
        currentTarget = nil
        targetStability = 0
        
        FOVring.Connection = RunService.RenderStepped:Connect(function(dt)
            updateDrawings()
            
            local targetPlayer = getTargetPlayer()
            
            if targetPlayer then
                if targetPlayer == currentTarget then
                    targetStability = math.min(targetStability + 1, maxStability)
                else
                    local timeSinceLastSwitch = tick() - lastSwitchTime
                    if timeSinceLastSwitch >= targetSwitchDelay then
                        currentTarget = targetPlayer
                        targetStability = 1
                        lastSwitchTime = tick()
                    end
                end
            else
                currentTarget = nil
                targetStability = 0
            end
            
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(targetPart) then
                local part = currentTarget.Character[targetPart]
                local targetPosition = calculateTargetPosition(currentTarget, targetPart, dt)
                
                if targetPosition then
                    smoothLookAt(targetPosition, dt)
                end
            else
                lastAimPosition = nil
            end
        end)
    else 
        isAiming = false
        lastAimPosition = nil
        currentTarget = nil
        targetStability = 0
        removeFOVring()
        
        if FOVring.Connection then
            FOVring.Connection:Disconnect()
            FOVring.Connection = nil
        end
        
        targetPart = nil 
    end
end

local Feng = FengYu:section("〖自瞄核心设置※】",true)

Feng:Toggle("开启/关闭自瞄", "AimbotToggle", false, function(v)
    toggleAiming(v)
end)

Feng:Toggle("预判自瞄", "PredictAim", false, function(v)
    isPredicting = v
    if v then
        print("预判功能已开启，模式: " .. predictMode)
    else
        print("预判功能已关闭")
    end
end)

local attackStrategyOptions = {"最近玩家", "血量最高", "血量最低"}
Feng:Dropdown("攻击策略", "AttackStrategy", attackStrategyOptions, function(option)
    attackStrategy = option
    print("攻击策略已设置为: " .. option)
end)

local predictModeOptions = {"自动追随", "偏左", "偏右"}
Feng:Dropdown("预判模式", "PredictMode", predictModeOptions, function(option)
    predictMode = option
    print("预判模式已设置为: " .. option)
end)

local Feng = FengYu:section("〖检测设置※】",true)

Feng:Toggle("墙壁检测", "WallCheck", false, function(v)
    isWallCheck = v
end)

Feng:Toggle("队伍检测", "TeamCheck", true, function(v)
    isTeamCheck = v
end)

Feng:Toggle("好友检测", "FriendCheck", true, function(v)
    isFriendCheck = v
end)

Feng:Toggle("活体检测", "AliveCheck", true, function(v)
    isAliveCheck = v
end)

Feng:Toggle("距离检测", "DistanceCheck", false, function(v)
    isDistanceCheck = v
end)

Feng:Toggle("强制距离检测", "ForceDistance", false, function(v)
    forceAutoDistance = v
end)

local Feng = FengYu:section("〖瞄准设置※】",true)

Feng:Slider("最大瞄准距离", "MaxDistance", 500, 10, 2000, true, function(value)
    maxDistance = value
end)

Feng:Slider("自瞄圈大小", "FOVSize", 50, 1, 600, true, function(value)
    fov = value
    if isAiming then
        FOVring.Radius = fov
        for i = 1, FOVCircles do
            if FOVrings[i] then
                FOVrings[i].Radius = fov + (i-1) * 10
            end
        end
    end
end)

Feng:Slider("自瞄平滑度", "Smoothness", 5, 1, 10, true, function(value)
    aimSmoothness = value
end)

local partOptions = {
    "头",
    "上躯干", 
    "下躯干",
    "左上臂",
    "右上臂",
    "左大腿",
    "右大腿",
    "左手",
    "右手", 
    "左脚",
    "右脚",
    "身体中心"
}

local partMap = {
    ["头"] = "Head",
    ["上躯干"] = "UpperTorso", 
    ["下躯干"] = "LowerTorso",
    ["左上臂"] = "LeftUpperArm",
    ["右上臂"] = "RightUpperArm",
    ["左大腿"] = "LeftUpperLeg", 
    ["右大腿"] = "RightUpperLeg",
    ["左手"] = "LeftHand",
    ["右手"] = "RightHand",
    ["左脚"] = "LeftFoot",
    ["右脚"] = "RightFoot",
    ["身体中心"] = "HumanoidRootPart"
}

Feng:Dropdown("自瞄部位", "AimPart", partOptions, function(option)
    targetPart = partMap[option]
    print("自瞄部位已切换为: " .. option)
end)

local Feng = FengYu:section("〖预判设置※】",true)

Feng:Slider("预判距离系数", "PredictDistance", 1.2, 0.5, 3.0, true, function(value)
    predictDistance = math.floor(value * 10 + 0.5) / 10
end)

Feng:Slider("水平偏移量", "HorizontalOffset", 0.5, 0.1, 2.0, true, function(value)
    predictHorizontalOffset = math.floor(value * 10 + 0.5) / 10
end)

Feng:Slider("自动距离阈值", "AutoThreshold", 45, 10, 100, true, function(value)
    autoDistanceThreshold = value
end)

local Feng = FengYu:section("〖视觉效果※】",true)

Feng:Toggle("彩虹自瞄圈", "RainbowFOV", false, function(v)
    isRainbowFOV = v
end)

Feng:ColorPicker("自瞄圈颜色", "FOVColor", Color3.fromRGB(255, 0, 0), function(color)
    if isAiming and not isRainbowFOV then
        FOVring.Color = color
        for i = 1, FOVCircles do
            if FOVrings[i] then
                FOVrings[i].Color = color
            end
        end
    end
end)

Feng:Slider("自瞄圈数量", "FOVCircles", 1, 1, 10, true, function(value)
    FOVCircles = value
    if isAiming then
        showFOVrings()
    end
end)

Feng:Slider("自瞄圈厚度", "FOVThickness", 2, 1, 10, true, function(value)
    if isAiming then
        FOVring.Thickness = value
        for i = 1, FOVCircles do
            if FOVrings[i] then
                FOVrings[i].Thickness = value
            end
        end
    end
end)

local Feng = FengYu:section("〖玩家选择※】",true)

local function refreshPlayerList()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            table.insert(players, player.Name)
        end
    end
    return players
end

local playerList = refreshPlayerList()
local selectedPlayer = ""

local playerDropdown = Feng:Dropdown("选择玩家", "PlayerSelect", playerList, function(value)
    selectedPlayer = value
end)

Feng:Button("刷新玩家列表", function()
    playerList = refreshPlayerList()
    playerDropdown:SetOptions(playerList)
end)

Feng:Toggle("锁定选择玩家", "LockPlayer", false, function(v)
    if v and selectedPlayer ~= "" then
        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if targetPlayer then
            selectedPlayers[targetPlayer] = true
            isLockSpecific = true
            lockTargets[targetPlayer] = true
            print("已锁定玩家: " .. selectedPlayer)
        end
    else
        if selectedPlayer ~= "" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer then
                selectedPlayers[targetPlayer] = nil
                lockTargets[targetPlayer] = nil
            end
        end
        isLockSpecific = false
        lockTargets = {}
        print("已取消锁定玩家")
    end
end)

Feng:Button("清除所有锁定", function()
    selectedPlayers = {}
    lockTargets = {}
    isLockSpecific = false
    print("已清除所有锁定的玩家")
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if isAiming then
        currentTarget = nil
        targetStability = 0
        lastAimPosition = nil
    end
end)

local function cleanup()
    if FOVring then
        FOVring:Remove()
    end
    for i = 1, #FOVrings do
        if FOVrings[i] then
            FOVrings[i]:Remove()
        end
    end
    if FOVring.Connection then
        FOVring.Connection:Disconnect()
    end
    if selectionBoxFolder then
        selectionBoxFolder:Destroy()
    end
end

local connection
connection = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == window then
        cleanup()
        connection:Disconnect()
    end
end)
local FengYu = FY:Tab("〖传送与甩飞】",'84830962019412')

local Feng = FengYu:section("〖传送和与甩飞※】",true)

local dropdown = {}
local playernamedied = ""

for i, player in pairs(game.Players:GetPlayers()) do
    dropdown[i] = player.Name
end
local LS = {
    playernamedied = "",
    dropdown = {},
    sayCount = 1,
    sayFast = false,
    autoSay = false,
}

--传送与甩飞玩家
function shuaxinlb(zji)
    LS.dropdown = {}
    if zji == true then
        for _, player in pairs(game.Players:GetPlayers()) do
            table.insert(LS.dropdown, player.Name)
        end
    else
        local lp = game.Players.LocalPlayer
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= lp then
                table.insert(LS.dropdown, player.Name)
            end
        end
    end
end
shuaxinlb(true)

function Notify(top, text, ico, dur)
  game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = top,
    Text = text,
    Icon = ico,
    Duration = dur,
  })
end

local dropdown = {}
local playernamedied = ""
local teleportConnection
local behindTeleportDistance = 3 
local headTeleportHeight = 4 


for i, player in pairs(game.Players:GetPlayers()) do
    dropdown[i] = player.Name
end


function Notify(top, text, ico, dur)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = top,
        Text = text,
        Icon = ico,
        Duration = dur,
    })
end

local Players = Feng:Dropdown("选择玩家的名称", 'Dropdown', LS.dropdown, function(v)
    LS.playernamedied = v
end)

Feng:Button("刷新玩家名称", function()
    shuaxinlb(true)
    Players:SetOptions(LS.dropdown)
end)

Feng:Button("传送到玩家旁边", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("殺脚本", "已传送到玩家旁边", "rbxassetid://84830962019412", 5)
    else
        Notify("殺脚本", "无法传送 玩家已消失", "rbxassetid://84830962019412", 5)
    end
end)

Feng:Toggle("锁定传送", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("殺脚本", "已开启循环传送", "rbxassetid://84830962019412", 5)
        while LS.LoopTeleport do
            local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
            local tp_player = game.Players:FindFirstChild(LS.playernamedied)
            if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
                HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
            wait()
        end
    else
        LS.LoopTeleport = false
        Notify("殺脚本", "已关闭循环传送", "rbxassetid://84830962019412", 5)
    end
end)

Feng:Button("把玩家传送过来", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
        Notify("xiaoyi脚本", "已将玩家传送过来", "rbxassetid://84830962019412", 5)
    else
        Notify("xiaoyi脚本", "无法传送 玩家已消失", "rbxassetid://84830962019412", 5)
    end
end)

Feng:Toggle("循环传送玩家过来", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("xiaoyi脚本", "已开启循环传送玩家过来", "rbxassetid://84830962019412", 5)
        while LS.LoopTeleport do
            local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
            local tp_player = game.Players:FindFirstChild(LS.playernamedied)
            if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
                tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
            end
            wait()
        end
    else
        LS.LoopTeleport = false
        Notify("xiaoyi脚本", "已关闭循环传送玩家过来", "rbxassetid://84830962019412", 5)
    end
end)

Feng:Toggle("查看玩家", "look player", false, function(state)
    if state then
        game:GetService('Workspace').CurrentCamera.CameraSubject =
            game:GetService('Players'):FindFirstChild(LS.playernamedied).Character.Humanoid
        Notify("xiaoyi脚本", "已开启查看玩家", "rbxassetid://84830962019412", 5)
    else
        local lp = game.Players.LocalPlayer
        game:GetService('Workspace').CurrentCamera.CameraSubject = lp.Character.Humanoid
        Notify("xiaoyi脚本", "已关闭查看玩家", "rbxassetid://84830962019412", 5)
    end
end)   
 
Feng:Toggle("循环甩飞", "AutoFling",false, function(t)
if LS.playernamedied == nil then
 elseif LS.playernamedied ~= nil then
getgenv().autofling = t
spawn(function()
while autofling do wait()
pcall(function()
local Targets = {LS.playernamedied}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AllBool = false

local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end

local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("错误", "xiaoyi脚本", 5)
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0

            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0/0

        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("已开/关", "xiaoyi脚本", 5)
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("玩家消失", "已停止", 5)
    end
end

if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end

if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end

for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 1414978355 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("检测到玩家消失", "已停止", 5)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("未获取到玩家或工具", "已停止", 5)
    end
end
end)
end
end)
end
end)
 
Feng:Toggle("自瞄选择目标", "Aimbot", false, function(Aimbot)
    if Aimbot then
        while Aimbot do
            local Cam = workspace.CurrentCamera
            local targetPlayer = game.Players:FindFirstChild(LS.playernamedied)
            local target = targetPlayer and targetPlayer.Character and targetPlayer.Character.HumanoidRootPart
            if target and Cam then
                local lookVector = (target.Position - Cam.CFrame.Position).unit
                local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
                Cam.CFrame = newCFrame
                wait()
            else
                break
            end
        end
    end
end)

Feng:Toggle("吸选中玩家", "PullPlayer", false, function(state)
    LS.LoopPull = state
    while LS.LoopPull do
        local selfRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetPlayer = game:GetService("Players"):FindFirstChild(LS.playernamedied)
        local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if selfRoot and targetRoot then
            local direction = (selfRoot.Position - targetRoot.Position).Unit
            targetRoot.CFrame = targetRoot.CFrame + direction * 1.5
        end
        task.wait()
    end
end)
  
Feng:Toggle("吸全部玩家", "TpAll", false, function(state)
    while state do
        local selfRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if selfRoot then
            local direction = selfRoot.CFrame.lookVector
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        targetRoot.CFrame = CFrame.new(selfRoot.Position + direction * 3, selfRoot.Position + direction * 4)
                    end
                end
            end
        end
        task.wait()
    end
end)
 
local FengYu = FY:Tab("〖碰撞箱】",'84830962019412')

local Feng = FengYu:section("〖碰撞箱系统※】",true)

local HitboxEnabled = false
local HitboxSize = 25
local HitboxTransparency = 0.7
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxMaterial = "Neon"
local HitboxCanCollide = false
local HitboxShowOnlyEnemies = false
local HitboxTeamCheck = true
local HitboxRainbowEffect = false
local HitboxPulseEffect = false
local HitboxGlowEffect = false
local HitboxOutline = true
local HitboxAutoResize = false
local HitboxResizeSpeed = 1
local HitboxConnection = nil

local materialOptions = {
    "霓虹",
    "塑料",
    "木头",
    "石板",
    "混凝土",
    "腐蚀金属",
    "钻石板",
    "箔",
    "草地",
    "冰",
    "大理石",
    "花岗岩",
    "砖块",
    "鹅卵石",
    "沙子",
    "织物",
    "光滑塑料",
    "金属",
    "木板",
    "鹅卵石路"
}

Feng:Toggle("Hitbox 开关", "HitboxToggle", false, function(Value)
    HitboxEnabled = Value
    if Value then
        startHitbox()
    else
        stopHitbox()
    end
end)

Feng:Textbox("Hitbox 大小", "HitboxSize", "25", function(Value)
    HitboxSize = tonumber(Value) or 25
end)

Feng:Slider('Hitbox 透明度', 'HitboxTransparency', 0.7, 0, 1, false, function(Value)
    HitboxTransparency = Value
end)

local colorPicker = Feng:ColorPicker("选择颜色", "MyColor", Color3.fromRGB(255, 0, 0), function(color)
    HitboxColor = color
end)

Feng:Dropdown("Hitbox 材质", "HitboxMaterial", materialOptions, function(Value)
    HitboxMaterial = Value
end)

Feng:Toggle("禁用碰撞", "HitboxCanCollide", false, function(Value)
    HitboxCanCollide = not Value
end)

Feng:Toggle("仅显示敌人", "HitboxShowOnlyEnemies", false, function(Value)
    HitboxShowOnlyEnemies = Value
end)

Feng:Toggle("队伍检查", "HitboxTeamCheck", true, function(Value)
    HitboxTeamCheck = Value
end)
local FengYu = FY:Tab("〖甩飞功能】",'84830962019412')

local Feng = FengYu:section("〖甩飞欠打的人※】",true)

Feng:Toggle("防甩飞", "FengYu", false, function(state)
    if state then
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        
        local ANTI_FLING_FORCE = 1e6
        local UPDATE_RATE = 0.01
        
        local ActiveHandles = {
            Connections = {},
            Constraints = {},
            Alignments = {}
        }
        
        local function CreateSuperConstraint(part)
            local bodyPos = Instance.new("BodyPosition")
            bodyPos.P = ANTI_FLING_FORCE
            bodyPos.D = ANTI_FLING_FORCE/10
            bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyPos.Position = part.Position
            bodyPos.Parent = part
            
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = ANTI_FLING_FORCE
            bodyGyro.D = ANTI_FLING_FORCE/10
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.CFrame = part.CFrame
            bodyGyro.Parent = part
            
            local alignPos = Instance.new("AlignPosition")
            alignPos.RigidityEnabled = true
            alignPos.MaxForce = ANTI_FLING_FORCE
            alignPos.Responsiveness = ANTI_FLING_FORCE
            alignPos.Parent = part
            
            local alignOri = Instance.new("AlignOrientation")
            alignOri.RigidityEnabled = true
            alignOri.MaxTorque = ANTI_FLING_FORCE
            alignOri.Responsiveness = ANTI_FLING_FORCE
            alignOri.Parent = part
            
            table.insert(ActiveHandles.Constraints, bodyPos)
            table.insert(ActiveHandles.Constraints, bodyGyro)
            table.insert(ActiveHandles.Alignments, alignPos)
            table.insert(ActiveHandles.Alignments, alignOri)
            
            return bodyPos, bodyGyro, alignPos, alignOri
        end
        
        local function ApplyUltimateProtection(character)
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
            if not rootPart then return end
            
            local bodyPos, bodyGyro, alignPos, alignOri = CreateSuperConstraint(rootPart)
            
            local updateConn = RunService.Heartbeat:Connect(function()
                if not character:IsDescendantOf(workspace) then return end
                
                bodyPos.Position = rootPart.Position
                bodyGyro.CFrame = rootPart.CFrame
                
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new()
                        part.AssemblyLinearVelocity = Vector3.new()
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                        
                        part:SetAttribute("LastPosition", part.Position)
                    end
                end
            end)
            table.insert(ActiveHandles.Connections, updateConn)
            
            local velConn = rootPart:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
                rootPart.AssemblyLinearVelocity = Vector3.new()
                rootPart.Velocity = Vector3.new()
            end)
            table.insert(ActiveHandles.Connections, velConn)
            
            local rotConn = rootPart:GetPropertyChangedSignal("AssemblyAngularVelocity"):Connect(function()
                rootPart.AssemblyAngularVelocity = Vector3.new()
                rootPart.RotVelocity = Vector3.new()
            end)
            table.insert(ActiveHandles.Connections, rotConn)
            
            local posCheck = RunService.Heartbeat:Connect(function()
                if not character:IsDescendantOf(workspace) then return end
                
                local lastPos = rootPart:GetAttribute("LastPosition")
                if lastPos then
                    local dist = (rootPart.Position - lastPos).Magnitude
                    if dist > 5 then
                        rootPart.CFrame = CFrame.new(lastPos)
                    end
                end
                rootPart:SetAttribute("LastPosition", rootPart.Position)
            end)
            table.insert(ActiveHandles.Connections, posCheck)
        end
        
        local function MonitorPlayer(player)
            if player == LocalPlayer then return end
            
            local function HandleCharacter(character)
                if not character then return end
                repeat task.wait() until character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
                ApplyUltimateProtection(character)
            end
            
            if player.Character then
                HandleCharacter(player.Character)
            end
            
            local charConn = player.CharacterAdded:Connect(HandleCharacter)
            table.insert(ActiveHandles.Connections, charConn)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            MonitorPlayer(player)
        end
        
        local playerConn = Players.PlayerAdded:Connect(MonitorPlayer)
        table.insert(ActiveHandles.Connections, playerConn)
        
    else
        for _, conn in ipairs(ActiveHandles.Connections or {}) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        
        for _, constraint in ipairs(ActiveHandles.Constraints or {}) do
            if constraint and constraint.Parent then
                constraint:Destroy()
            end
        end
        
        for _, align in ipairs(ActiveHandles.Alignments or {}) do
            if align and align.Parent then
                align:Destroy()
            end
        end
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.CustomPhysicalProperties = nil
                        part.AssemblyAngularVelocity = Vector3.new()
                        part.AssemblyLinearVelocity = Vector3.new()
                        part:SetAttribute("LastPosition", nil)
                    end
                end
            end
        end
        
        ActiveHandles = {
            Connections = {},
            Constraints = {},
            Alignments = {}
        }
    end
end)

Feng:Button("旋转甩飞",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%97%8B%E8%BD%AC.lua"))()
end)
    
Feng:Button("碰到就飞",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI"))()
end)
    
Feng:Button("甩飞全部人",function()
    local Targets = {"All"}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AllBool = false

local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end

local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5)
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0

            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Occurred", "Random error", 5)
    end
end

if not Welcome then Message("xiaoyi脚本甩飞提示", "已开启甩飞后面不会再提示", "rbxassetid://84830962019412", 5)
    end
getgenv().Welcome = true
if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end

if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end

for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 1414978355 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("Error Occurred", "This user is whitelisted! (Owner)", 5)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("Error Occurred", "Username Invalid", 5)
    end
end
end)
   
Feng:Button("铁拳",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
end)
    
local FengYu = FY:Tab("〖其他脚本中心】",'84830962019412')

local Feng = FengYu:section("〖其他※】",true)

Feng:Button("控制NPC", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/fe-source/refs/heads/main/NPC/source/main.Luau"))()
end)

Feng:Button("IY指令", function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
end)

local FY = window:card("FE中心", "动画恶搞或其他", "108446823535062")

local FengYu = FY:Tab("〖恶搞】",'84830962019412')

local Feng = FengYu:section("〖魔丸※】",true)

local fakeLagEnabled = false
local fakeLagCoroutine = nil
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(newChar)
    char = newChar
end)

Feng:Toggle("慢移动/人物快速移动", "FengYu", false, function(state)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    local runAnimId = "rbxassetid://913376220"
    local runTrack = nil
    local runConnection = nil
    
    local function playRunAnimation(humanoid)
        local animator = humanoid:FindFirstChildWhichIsA("Animator")
        if not animator then
            animator = Instance.new("Animator", humanoid)
        end

        local runAnim = Instance.new("Animation")
        runAnim.AnimationId = runAnimId
        runTrack = animator:LoadAnimation(runAnim)
        runTrack.Priority = Enum.AnimationPriority.Movement
        runTrack:AdjustSpeed(6)
        runTrack:Play()

        runConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if humanoid.MoveDirection.Magnitude == 0 then
                if runTrack.IsPlaying then runTrack:Stop() end
            else
                if not runTrack.IsPlaying then
                    runTrack:Play()
                    runTrack:AdjustSpeed(6)
                end
            end
        end)
    end

    local function stopRunAnimation()
        if runTrack then runTrack:Stop() end
        if runConnection then runConnection:Disconnect() end
    end

    local function enableEgor()
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        humanoid.WalkSpeed = 3
        playRunAnimation(humanoid)
    end

    local function disableEgor()
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        humanoid.WalkSpeed = 16
        stopRunAnimation()
    end

    local function onCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid")
        char:WaitForChild("Animate")
        task.wait(0.5)

        if state then
            enableEgor()
        else
            disableEgor()
        end
    end

    if state then
        if player.Character then
            onCharacterAdded(player.Character)
        end
        player.CharacterAdded:Connect(onCharacterAdded)
    else
        if player.Character then
            disableEgor()
        end
        player.CharacterAdded:Disconnect()
    end
end)
  
Feng:Toggle("假延迟开关", "FakeLagToggle", false, function(state)
    fakeLagEnabled = state
    
    if fakeLagEnabled then
        fakeLagCoroutine = coroutine.create(function()
            while fakeLagEnabled and char do
                if char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.Anchored = true
                    wait(fakeLagDelay or 2)
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.Anchored = false
                    end
                end
                wait(0.05)
            end
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
        end)
        coroutine.resume(fakeLagCoroutine)
    else
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
    end
end)

local fakeLagDelay = 0.1
Feng:Textbox("假延迟延迟", "FengYu", "0.1", function(text)
    fakeLagDelay = tonumber(text) or 0.1
end)

Feng:Toggle("假死开关", "FengYu", false, function(state)
    ragdollEnabled = state
    
    if state then
        if not isRagdolled then
            toggleRagdoll()
        end
    else
        if isRagdolled then
            toggleRagdoll()
        end
    end
end)

    Feng:Button(
        "直升机",
        function()
            if game.Players.LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://27432686"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=165113352"
hi.Volume = 2
hi.Looped = true
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()

local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)

end)
else
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://507776043"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=165113352"
hi.Volume = 2
hi.Looped = true
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()

local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)


end)    
end
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local u = game.Players.LocalPlayer
local urchar = u.Character

task.spawn(function()


qUp = Mouse.KeyUp:Connect(function(KEY)
if KEY == 'q' then
urchar.Humanoid.HipHeight = urchar.Humanoid.HipHeight - 3
end
end)
eUp = Mouse.KeyUp:Connect(function(KEY)
if KEY == 'e' then
urchar.Humanoid.HipHeight = urchar.Humanoid.HipHeight + 3
end
end)


end)
        end
    )    
    
Feng:Button("坐下❗",function()
    game.Players.LocalPlayer.Character.Humanoid.Sit = true
end)

Feng:Button("奇怪的舞蹈",function()
    local Players = game:GetService("Players")
local player = Players.LocalPlayer

local originalRot
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:FindFirstChild("HumanoidRootPart")

local function loadAnimation(char)
	local humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://136720812089001"
	return animator:LoadAnimation(anim)
end

local function rotateCharacter(char, degrees)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(degrees), 0)
	end
end

if hrp then
	originalRot = hrp.CFrame - hrp.Position
end

local currentTrack = loadAnimation(char)
currentTrack.Looped = true
currentTrack.Priority = Enum.AnimationPriority.Action
currentTrack:Play(0, 99)
currentTrack:AdjustSpeed(1)
rotateCharacter(char, 180)
end)

  Feng:Button("人物螺旋上天",function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://27432686"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=8114290584"
hi.Volume = 2
hi.Looped = false
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()
wait(1.5)
local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
wait(3.5)
while speaker.Character.Humanoid.Health > 0 do
   wait(0.1)
speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 1
end
end)
else
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://507776043"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=8114290584"
hi.Volume = 2
hi.Looped = false
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()
wait(1.5)
local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
wait(3.5)
while speaker.Character.Humanoid.Health > 0 do
   wait(0.1)
speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 1
end
end)    
end
end)
  
Feng:Button("撸管r6",function()
    loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
end)
    
Feng:Button("撸管r15",function()
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end)
    
    
local FengYu = FY:Tab("〖动画】",'84830962019412')

local Feng = FengYu:section("〖动画※】",true)

Feng:Button("FE-R15动作",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/FE_R15.lua"))()
end)

Feng:Button("VR视角",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty45.lua"))()
end)

local FengYu = FY:DualTab("〖物品】",'84830962019412')

local Feng = FengYu:section("〖R15专用※】", "Left", true)

Feng:Button("可口可乐",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Coca-Cola-Tool-34866"))()
end)

Feng:Button("AK-47",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/AK-47.lua"))()
end)

Feng:Button("FE抓取",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty1.lua"))()
end)
 
Feng:Button("F3X",function()
    loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()
end)

    Feng:Button("FE传送",function()
    mouse = game.Players.LocalPlayer:GetMouse() tool = Instance.new("Tool") tool.RequiresHandle = false tool.Name = "风御传送" tool.Activated:connect(function() local pos = mouse.Hit+Vector3.new(0,2.5,0) pos = CFrame.new(pos.X,pos.Y,pos.Z) game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos end) tool.Parent = game.Players.LocalPlayer.Backpack
end)
    
Feng:Button("前后空翻动作", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E5%89%8D%E5%90%8E%E7%A9%BA%E7%BF%BB.txt"))()
end)

local Feng = FengYu:section("〖R6专用※】", "Left", true)

Feng:Button("打架",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-no-more-games-tool-not-fe-80285"))()
end)

Feng:Button("光剑",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Crucible-Sword-only-R6-87032"))()
end)

local FengYu = FY:Tab("〖变型】",'84830962019412')

local Feng = FengYu:section("〖FE变型※】", true)

Feng:Button("John Doe（只支持R6形象）",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/john%20Doe.lua"))()
end)

Feng:Button("John Doe[脚本生成器]（只支持R6形象）",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/mMCS4Zne"))()
end)

Feng:Button("审判者（只支持R6形象）",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Caducus-the-fallen-god-script-53019"))()
end)

Feng:Button("史蒂夫（只支持R6形象）",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Steve"))()
end)

Feng:Button("1×1×1×1 Hacklord魔王",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-1x1x1x1-lord-by-White-Hat-71150"))()
end)

Feng:Button("酷小孩",function()
    _G.Config = {
    ["HatCollide"]     = false,
    ["ReClaim"]        = true,
    ["Fling"]          = true,
    ["HideCharacter"]  = true,

    ["FlingOption"] = {
        ["HatFling"]        = false,
        ["Highlight"]       = true,
        ["PredictionFling"] = true,
        ["ToolFling"]       = false
    }
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/qwertys/refs/heads/main/qwerty2.lua"))()
end)

Feng:Button("人形汽车",function()
    loadstring(game:HttpGet("https://pastefy.app/UqDEIOpO/raw"))()
end)

Feng:Button("百吨王",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/3LD4D0/Crazy-Man-R6/36ec60d16bf8d208c40807aa0fd2662af76a5385/Crazy%20Man%20R6"))()
end)

Feng:Button("索尼克2011 X",function()
    local Title = "Roblox:Kodeythegamer"
local Text = "credits to noli-i6l"
local ButtonText = "thumbs up"
local Button2Text = "thumbs down"
local IconId = "96454773485145"

local HaveIcon = true
local HaveButton1 = true
local HaveButton2 = true
local Duration = 5

local function Button1Code()
  -- optional code
end

local function Button2Code()
  -- optional code
end

loadstring(game:HttpGet("https://pastebin.com/raw/FUPBRUuY"))()(
 Title,
 Text,
 ButtonText,
 Button2Text,
 IconId,
 HaveIcon,
 HaveButton1,
 HaveButton2,
 Duration,
 Button1Code,
 Button2Code
)

--==================== SETTINGS ====================--

local KEY_MOVESET1 = Enum.KeyCode.Z
local KEY_MOVESET2 = Enum.KeyCode.X
local KEY_MOVESET3 = Enum.KeyCode.C
local KEY_DASH     = Enum.KeyCode.V

local BUTTON1_IMAGE = "rbxassetid://93523968251431"
local BUTTON2_IMAGE = "rbxassetid://80441123059484"
local BUTTON3_IMAGE = "rbxassetid://80456535274123"
local DASH_BUTTON_IMAGE = "rbxassetid://111897103699531"

-- Animations
local SpawnAnimId = "rbxassetid://73844251271714"
local IdleAnimId  = "rbxassetid://130912259300899"
local WalkAnimId  = "rbxassetid://102622695004986"   -- Slow/normal walk
local RunAnimId   = "rbxassetid://99694231408564"    -- Fast Sonic run

local Move1AnimId = "rbxassetid://127415121971326"
local Move2AnimId = "rbxassetid://110361063508944"
local Move3AnimId = "rbxassetid://126801473720398"
local DashAnimId  = "rbxassetid://119889021060156"

local JumpAnimId = "rbxassetid://119889021060156"  -- Replace with your jump animation ID
local DoubleJumpAnimId = "rbxassetid://119889021060156"  -- Replace with your double jump animation ID

-- Spindash settings
local MIN_DASH_SPEED = 100
local MAX_DASH_SPEED = 300
local DASH_UP = 0
local DASH_TIME = 0.2           -- Slightly shorter for snappier feel
local SPINDASH_CHARGE_TIME = 3

-- Winding up settings
local NORMAL_SPEED = 12
local BOOST_SPEED = 150
local WINDUP_TIME = 2.25
local FORWARD_DOT_THRESHOLD = 0.3
local SPEED_DELAY_AFTER_WINDUP = 0.1

-- Transition smoothness
local ACCEL_TIME = 0.6
local DECEL_TIME = 0.4
local ANIM_FADE_TIME = 0.5

-- Camera & Effects
local BASE_FOV = 70
local SLOW_FOV = 80
local FAST_FOV = 95
local ZOOM_IN_FOV = 60
local CAMERA_SMOOTHNESS = 8

-- Charge bar customization (now oval)
local CHARGE_BAR_POSITION = UDim2.new(0.96, 0, 0.28, 0)
local CHARGE_BAR_SIZE = UDim2.new(0.025, 0, 0.45, 0)   -- Taller & narrower for oval
local CHARGE_BAR_BG_COLOR = Color3.new(0.15, 0.15, 0.15)
local CHARGE_BAR_FILL_COLOR = Color3.new(138, 0, 0)

--==================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local PlayMove1, PlayMove2, PlayMove3, PlayDashStart, PlayDashRelease

----------------------------------------------------
-- GUI (Persistent)
----------------------------------------------------

local gui = player.PlayerGui:FindFirstChild("MovesetGui")
if not gui then
  gui = Instance.new("ScreenGui")
  gui.Name = "MovesetGui"
  gui.ResetOnSpawn = false
  gui.Parent = player.PlayerGui
end

local function MakeButton(name, image, pos)
  local btn = gui:FindFirstChild(name)
  if btn then return btn end
  btn = Instance.new("ImageButton")
  btn.Name = name
  btn.Size = UDim2.new(0,90,0,90)
  btn.Position = pos
  btn.Image = image
  btn.BackgroundTransparency = 1
  btn.Parent = gui
  return btn
end

local btn1 = MakeButton("Move1", BUTTON1_IMAGE, UDim2.new(0.05,0,0.75,0))
local btn2 = MakeButton("Move2", BUTTON2_IMAGE, UDim2.new(0.17,0,0.75,0))
local btn3 = MakeButton("Move3", BUTTON3_IMAGE, UDim2.new(0.29,0,0.75,0))
local btnD = MakeButton("Dash",  DASH_BUTTON_IMAGE, UDim2.new(0.41,0,0.75,0))

-- Oval charge bar
local chargeBar = gui:FindFirstChild("ChargeBar")
if not chargeBar then
  chargeBar = Instance.new("Frame")
  chargeBar.Name = "ChargeBar"
  chargeBar.Size = CHARGE_BAR_SIZE
  chargeBar.Position = CHARGE_BAR_POSITION
  chargeBar.BackgroundColor3 = CHARGE_BAR_BG_COLOR
  chargeBar.BackgroundTransparency = 0.3
  chargeBar.Visible = false
  chargeBar.Parent = gui

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(1, 0)  -- Full round → makes it pill/oval shaped
  corner.Parent = chargeBar

  local fill = Instance.new("Frame")
  fill.Name = "Fill"
  fill.Size = UDim2.new(1, 0, 0, 0)
  fill.Position = UDim2.new(0, 0, 1, 0)
  fill.AnchorPoint = Vector2.new(0, 1)
  fill.BackgroundColor3 = CHARGE_BAR_FILL_COLOR
  fill.Parent = chargeBar

  local fillCorner = Instance.new("UICorner")
  fillCorner.CornerRadius = UDim.new(1, 0)
  fillCorner.Parent = fill
end

local function ConnectButtons()
    btn1.MouseButton1Click:Connect(function() if PlayMove1 then PlayMove1() end end)
    btn2.MouseButton1Click:Connect(function() if PlayMove2 then PlayMove2() end end)
    btn3.MouseButton1Click:Connect(function() if PlayMove3 then PlayMove3() end end)
    btnD.MouseButton1Down:Connect(function() if PlayDashStart then PlayDashStart() end end)
    btnD.MouseButton1Up:Connect(function() if PlayDashRelease then PlayDashRelease() end end)
end

ConnectButtons()

----------------------------------------------------
-- CHARACTER SETUP
----------------------------------------------------

local function SetupCharacter(char)
  local humanoid = char:WaitForChild("Humanoid")
  local hrp = char:WaitForChild("HumanoidRootPart")
  local cam = workspace.CurrentCamera

  local animate = char:FindFirstChild("Animate")
  if animate then animate.Disabled = true end

  local function loadAnim(id, looped, priority)
    local a = Instance.new("Animation")
    a.AnimationId = id
    local t = humanoid:LoadAnimation(a)
    t.Looped = looped
    if priority then t.Priority = priority end
    return t
  end

  local idle   = loadAnim(IdleAnimId,  true,  Enum.AnimationPriority.Idle)
  local walk   = loadAnim(WalkAnimId,  true,  Enum.AnimationPriority.Movement)
  local run    = loadAnim(RunAnimId,   true,  Enum.AnimationPriority.Movement)
  local spawn  = loadAnim(SpawnAnimId, false, Enum.AnimationPriority.Action)

  local m2     = loadAnim(Move2AnimId, false, Enum.AnimationPriority.Action)
  local m3     = loadAnim(Move3AnimId, false, Enum.AnimationPriority.Action)
  local dashTrack = loadAnim(DashAnimId, true, Enum.AnimationPriority.Action)

  local jumpTrack = loadAnim(JumpAnimId, false, Enum.AnimationPriority.Movement)
  local doubleJumpTrack = loadAnim(DoubleJumpAnimId, false, Enum.AnimationPriority.Movement)

  spawn:Play()
  spawn.Stopped:Wait()
  idle:Play()

  local using = false
  local ready = {true,true,true,true}
  local isCharging = false
  local chargeStart = 0
  local chargeBV
  local canDoubleJump = false

  -- Movement state
  local isBoosted = false
  local windupStart = 0

  humanoid.WalkSpeed = NORMAL_SPEED

  local function tweenSpeed(targetSpeed, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {WalkSpeed = targetSpeed}
    local tween = TweenService:Create(humanoid, tweenInfo, goal)
    tween:Play()
    return tween
  end

  -- Red flicker GUI
  local flickerGui = Instance.new("ScreenGui")
  flickerGui.Name = "FlickerGui"
  flickerGui.ResetOnSpawn = false
  flickerGui.Parent = player.PlayerGui
  local flickerFrame = Instance.new("Frame")
  flickerFrame.Size = UDim2.new(1,0,1,0)
  flickerFrame.BackgroundColor3 = Color3.new(1,0,0)
  flickerFrame.BackgroundTransparency = 1
  flickerFrame.Parent = flickerGui

  -- Red trail
  local leftFoot = char:WaitForChild("LeftFoot", 5)
  local rightFoot = char:WaitForChild("RightFoot", 5)

  local attachLeft = Instance.new("Attachment")
  attachLeft.Parent = leftFoot or hrp
  attachLeft.Position = Vector3.new(0, -0.3, 0)

  local attachRight = Instance.new("Attachment")
  attachRight.Parent = rightFoot or hrp
  attachRight.Position = Vector3.new(0, -0.3, 0)

  local trail = Instance.new("Trail")
  trail.Attachment0 = attachLeft
  trail.Attachment1 = attachRight
  trail.Color = ColorSequence.new(Color3.new(1,0,0))
  trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(1,1)})
  trail.Lifetime = 0.7
  trail.MinLength = 0.1
  trail.FaceCamera = true
  trail.Enabled = false
  trail.Parent = hrp

  local prevPos = hrp.Position
  local fovTweening = false

  local moveConn = RunService.Heartbeat:Connect(function(dt)
    if isCharging then
      local progress = math.clamp((tick() - chargeStart) / SPINDASH_CHARGE_TIME, 0, 1)
      chargeBar.Fill.Size = UDim2.new(1, 0, progress, 0)
    end

    if using then return end

    local moveDir = humanoid.MoveDirection
    local moving = moveDir.Magnitude > 0.1

    if moving then
      local lookDir = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
      local forwardDot = moveDir:Dot(lookDir)

      if forwardDot > FORWARD_DOT_THRESHOLD then
        if windupStart == 0 then windupStart = tick() end

        local timeHeld = tick() - windupStart
        local progress = math.clamp(timeHeld / WINDUP_TIME, 0, 1)

        if progress >= 1 and not isBoosted then
          isBoosted = true
          walk:Stop(ANIM_FADE_TIME)
          run:Play(ANIM_FADE_TIME)

          task.spawn(function()
            for i = 1, 3 do
              flickerFrame.BackgroundTransparency = 0.6
              task.wait(0.06)
              flickerFrame.BackgroundTransparency = 1
              task.wait(0.06)
            end
          end)

          if not fovTweening then
            fovTweening = true
            local tweenIn = TweenService:Create(cam, TweenInfo.new(0.12), {FieldOfView = ZOOM_IN_FOV})
            tweenIn:Play()
            tweenIn.Completed:Connect(function()
              local tweenOut = TweenService:Create(cam, TweenInfo.new(0.25), {FieldOfView = FAST_FOV})
              tweenOut:Play()
              tweenOut.Completed:Connect(function() fovTweening = false end)
            end)
          end

          trail.Enabled = true

          task.delay(SPEED_DELAY_AFTER_WINDUP, function()
            if isBoosted then
              tweenSpeed(BOOST_SPEED, ACCEL_TIME)
            end
          end)
        end
      else
        windupStart = 0
        if isBoosted then
          isBoosted = false
          tweenSpeed(NORMAL_SPEED, DECEL_TIME)
          run:Stop(ANIM_FADE_TIME)
          walk:Play(ANIM_FADE_TIME)
          trail.Enabled = false
        end
      end
    else
      windupStart = 0
      if isBoosted then
        isBoosted = false
        tweenSpeed(NORMAL_SPEED, DECEL_TIME * 1.2)
        run:Stop(ANIM_FADE_TIME)
        walk:Stop(ANIM_FADE_TIME)
        trail.Enabled = false
      end
    end

    local currentPos = hrp.Position
    prevPos = currentPos

    if not fovTweening then
      local targetFOV = isBoosted and FAST_FOV or (humanoid.WalkSpeed > NORMAL_SPEED + 10 and SLOW_FOV or BASE_FOV)
      cam.FieldOfView = cam.FieldOfView + (targetFOV - cam.FieldOfView) * (dt * CAMERA_SMOOTHNESS)
    end
  end)

  humanoid.Running:Connect(function(speed)
    if using then return end
    if speed > 0.1 then
      if not (walk.IsPlaying or run.IsPlaying) then
        idle:Stop(0.2)
        if isBoosted then run:Play(ANIM_FADE_TIME) else walk:Play(ANIM_FADE_TIME) end
      end
    else
      if walk.IsPlaying or run.IsPlaying then
        walk:Stop(0.3)
        run:Stop(0.3)
        idle:Play(0.3)
      end
    end
  end)

  humanoid.StateChanged:Connect(function(old, new)
    if new == Enum.HumanoidStateType.Jumping then
      if not using then
        idle:Stop(0.1)
        walk:Stop(0.1)
        run:Stop(0.1)
        jumpTrack:Play()
      end
      canDoubleJump = true
    elseif new == Enum.HumanoidStateType.Landed then
      canDoubleJump = false
      if not using then
        jumpTrack:Stop(0.2)
        doubleJumpTrack:Stop(0.2)
        finish()
      end
    end
  end)

  humanoid.Jumping:Connect(function(active)
    if active and humanoid:GetState() == Enum.HumanoidStateType.Freefall and canDoubleJump and not using then
      canDoubleJump = false
      local jumpDir = humanoid.MoveDirection * 10
      hrp.Velocity = Vector3.new(hrp.Velocity.X, humanoid.JumpPower, hrp.Velocity.Z) + jumpDir
      idle:Stop(0.1)
      walk:Stop(0.1)
      run:Stop(0.1)
      jumpTrack:Stop(0.1)
      doubleJumpTrack:Play()
    end
  end)

  local function finish()
    using = false
    if humanoid.MoveDirection.Magnitude > 0 then
      if isBoosted then
        run:Play(ANIM_FADE_TIME)
      else
        walk:Play(ANIM_FADE_TIME)
      end
    else
      idle:Play(0.3)
    end
  end

  PlayMove1 = function()
    if using or not ready[1] then return end
    using = true
    ready[1] = false
    idle:Stop(0.2); walk:Stop(0.2); run:Stop(0.2)
    local a = Instance.new("Animation")
    a.AnimationId = Move1AnimId
    local track = humanoid:LoadAnimation(a)
    track.Looped = true
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    task.delay(2, function()
      track:Stop()
      ready[1] = true
      finish()
    end)
  end

  PlayMove2 = function()
    if using or not ready[2] then return end
    using = true
    ready[2] = false
    idle:Stop(0.2); walk:Stop(0.2); run:Stop(0.2)
    m2:Play()
    m2.Stopped:Wait()
    ready[2] = true
    finish()
  end

  PlayMove3 = function()
    if using or not ready[3] then return end
    using = true
    ready[3] = false
    idle:Stop(0.2); walk:Stop(0.2); run:Stop(0.2)
    m3:Play()
    m3.Stopped:Wait()
    ready[3] = true
    finish()
  end

  PlayDashStart = function()
    if using or not ready[4] or isCharging then return end
    using = true
    isCharging = true
    ready[4] = false
    idle:Stop(0.2); walk:Stop(0.2); run:Stop(0.2)
    dashTrack:Play()
    humanoid.WalkSpeed = 0
    chargeStart = tick()
    chargeBar.Visible = true
    chargeBar.Fill.Size = UDim2.new(1, 0, 0, 0)

    chargeBV = Instance.new("BodyVelocity")
    chargeBV.Velocity = Vector3.new(0, 0, 0)
    chargeBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    chargeBV.Parent = hrp
    Debris:AddItem(chargeBV, 10)
  end

  PlayDashRelease = function()
    if not isCharging then return end
    isCharging = false
    local chargeTime = tick() - chargeStart
    local progress = math.clamp(chargeTime / SPINDASH_CHARGE_TIME, 0, 1)
    local speed = MIN_DASH_SPEED + progress * (MAX_DASH_SPEED - MIN_DASH_SPEED)
    local dir = hrp.CFrame.LookVector
    chargeBV.Velocity = Vector3.new(dir.X * speed, DASH_UP, dir.Z * speed)

    task.delay(DASH_TIME, function()
      if chargeBV then chargeBV:Destroy() end
      dashTrack:Stop(0.1)  -- Faster fade-out for snappier spindash animation transition
      chargeBar.Visible = false
      isBoosted = true
      trail.Enabled = true

      -- Red flicker on release (same as boost activation)
      task.spawn(function()
        for i = 1, 3 do
          flickerFrame.BackgroundTransparency = 0.6
          task.wait(0.06)
          flickerFrame.BackgroundTransparency = 1
          task.wait(0.06)
        end
      end)

      tweenSpeed(BOOST_SPEED, ACCEL_TIME)
      ready[4] = true
      finish()
    end)
  end

  ConnectButtons()
end

----------------------------------------------------
-- KEYS
----------------------------------------------------

UIS.InputBegan:Connect(function(input,gp)
  if gp then return end
  if input.KeyCode == KEY_MOVESET1 and PlayMove1 then PlayMove1()
  elseif input.KeyCode == KEY_MOVESET2 and PlayMove2 then PlayMove2()
  elseif input.KeyCode == KEY_MOVESET3 and PlayMove3 then PlayMove3()
  elseif input.KeyCode == KEY_DASH and PlayDashStart then PlayDashStart()
  end
end)

UIS.InputEnded:Connect(function(input,gp)
  if gp then return end
  if input.KeyCode == KEY_DASH and PlayDashRelease then PlayDashRelease()
  end
end)

----------------------------------------------------
-- RUN
----------------------------------------------------

player.CharacterAdded:Connect(SetupCharacter)
if player.Character then
  SetupCharacter(player.Character)
end
end)

Feng:Button("巨人",function()
    _G.HideCharacter = true
_G.FlingEnabled = true
_G.TransparentRig = true
_G.ToolFling = false
_G.AntiFling = false
_G.CustomHats = true
_G.Scale = 4.2
_G.CH = {
    Torso = {
        Name= "Accessory (Torso)",
        TextureId = "83269599235494",
        Orientation= CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
    },
    RightArm = {
        Name= "Accessory (BIGGEST RIGHT ARMAccessory)",
        TextureId = "117484156735788", 
         Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    LeftArm = {
        Name= "Accessory (BIGGEST LEFT ARMAccessory)",
        TextureId = "117484156735788", 
        Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    RightLeg = {
        Name= "Accessory (RLeg)",
        TextureId = "83269599235494", 
        Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    LeftLeg = {
        Name= "Accessory (LLeg)",
        TextureId = "83269599235494", 
        Orientation= CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    },
    Head = {
        Name = "Accessory (big head)",
        Orientation = CFrame.new(),
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nitro-GT/Oxide/refs/heads/main/LoadstringPerma"))()
task.wait(20)
  loadstring(game:HttpGet("https://raw.githubusercontent.com/Nitro-GT/OxideReanim/refs/heads/main/KrystalDance3"))()
end)

Feng:Button("地精",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_rTvXTs8F16D8D2oiLxZ62E1E9jT1we312yUyJr2h72Vwqr32l37rirU1S89hqRV7.lua.txt"))()
end)

Feng:Button("Nico？",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/o7-Fire/Roblox/refs/heads/master/FE_Scripts/FE_Neko.lua"))()
end)

local FengYu = FY:Tab("〖其他】",'84830962019412')

local Feng = FengYu:section("〖其他FE※】", true)

Feng:Button("自由视角",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/sKQ1mSGy"))()
end)

Feng:Button("核弹",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/FE%E6%A0%B8%E5%BC%B9.lua.txt"))()
end)

Feng:Button("变成R6",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/uddpLUvu"))()
end)

Feng:Button("动作大片",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Azizanzz0/Scripts/refs/heads/main/Haram.lua"))()
end)

Feng:Button("滚球",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KaterHub-Inc/scripts/refs/heads/main/unofficial-Projects/FEHamsterBall.lua"))()
end)
Feng:Button("聊天画画",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BidoSkinsYT/BidoSkinsYT/main/Fe%20Chat%20Draw"))()
end)

Feng:Button("幻影忍者",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_11l7Y131YqJjZ31QmV5L8pI23V02b3191sEg26E75472Wl78Vi8870jRv5txZyL1.lua.txt"))()
end)

Feng:Button("飞檐走壁",function()
    loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Walk-On-Walls-Script!-2753"))()
end)

local FengYu = FY:Tab("修改天空盒", "96338123345158")

local Feng = FengYu:section("参考", true)
Feng:Button("复制数字ID",function()
setclipboard("96338123345158")
end)
Feng:Label("参考图片ID可以使用")
Feng:Label("把刚刚复制在剪贴板的数字ID放在输入框里")
local Feng = FengYu:section("修改天空", true)

local skyboxId = ""
Feng:Textbox("天空贴图ID", "SkyboxID", "输入贴图ID", function(text)
    skyboxId = text
end)

Feng:Button("换掉原天空贴图", function()
    if skyboxId ~= "" then
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local pos = hrp.Position

        local part = Instance.new("Part")
        part.Name = "SkyBoxPart"
        part.Size = Vector3.new(1,1,1)
        part.Anchored = true
        part.CanCollide = false
        part.Position = pos + Vector3.new(0,6,0)
        part.Parent = workspace

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://111891702759441"
        mesh.TextureId = "rbxassetid://"..skyboxId
        mesh.Scale = Vector3.new(99999,99999,99999)
        mesh.Parent = part

        local faces = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Top, Enum.NormalId.Bottom}
        for _, face in ipairs(faces) do
            task.wait(0.1)
            local decal = Instance.new("Decal")
            decal.Texture = "rbxassetid://"..skyboxId
            decal.Face = face
            decal.Parent = part
        end
    end
end)

local Feng = FengYu:section("修改工具", true)

local decalId = ""
Feng:Textbox("工具贴图ID", "DecalID", "输入贴图ID", function(text)
    decalId = text
end)

Feng:Button("换掉地图内所有贴图", function()
    if decalId ~= "" then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                    local decal = Instance.new("Decal")
                    decal.Texture = "rbxassetid://"..decalId
                    decal.Face = face
                    decal.Parent = part
                end
            end
        end
    end
end)

local Feng = FengYu:section("显示消息", true)

local messageText = ""
Feng:Textbox("消息内容", "Message", "输入消息", function(text)
    messageText = text
end)

Feng:Button("显示消息", function()
    if messageText ~= "" then
        local player = game.Players.LocalPlayer
        local msgGui = Instance.new("ScreenGui")
        msgGui.Parent = player:WaitForChild("PlayerGui")

        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1,0,1,0)
        msgLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
        msgLabel.BackgroundTransparency = 0.5
        msgLabel.Text = messageText
        msgLabel.TextColor3 = Color3.new(1,1,1)
        msgLabel.Font = Enum.Font.SourceSansBold
        msgLabel.TextSize = 50
        msgLabel.Parent = msgGui

        game:GetService("Debris"):AddItem(msgGui,3)
    end
end)

local FY = window:card("光影设置", "类似于材质包", "110417460216040")

local FengYu = FY:Tab("〖光影】",'84830962019412')
local Feng = FengYu:section("『画质』", true)
Feng:Button(
        "画质光影",
        function()
            loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))()
        end
    )   
   
   Feng:Button(
        "深色光影",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
        end
    )
    
local FY = window:card("服务器功能", "根据对应的服务器来找到", "87032069041923")

local FengYu = FY:Tab("〖服务器功能】",'84830962019412')

local Feng =FengYu:section("〖其他脚本功能】",true)

local gameScripts = {
    [6331902150] = {
        {
            name = "SNT-被遗弃",
            url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/SNT.lua"
        },
        {
            name = "xiaoyi脚本-被遗弃",
            url = "https://raw.githubusercontent.com/FengYu-X/Max/refs/heads/X/fsk.lua"
        }
    },
    [7344582593] = {
        name = "xiaoyi脚本-死亡之死☠️",
        url = "https://raw.githubusercontent.com/FengYu-X/Max/refs/heads/X/DOD.lua"
    },
    [1526814825] = {
        name = "战争大亨",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E6%88%98%E4%BA%89%E5%A4%A7%E4%BA%A8.txt"
    },
    [8305240030] = {
        name = "成为乞丐",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/NEGA.lua"
    },
    [4777817887] = {
        name = "刀刃球",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Kalitor.lua"
    },
    [111958650] = {
        name = "兵工厂",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Tbao.lua"
    },
    [7326934954] = {
        name = "99夜",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/99%E5%A4%9C%E8%99%9A%E7%A9%BA.txt"
    },
    [5980808883] = {
        name = "活了七天",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/bf.txt"
    },
    [3085257211] = {
        name = "彩虹朋友2",
        url = "https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/BestRainbowFriendsTwo"
    },
    [65241] = {
        {
            name = "自然灾害",
            url = "https://raw.githubusercontent.com/9NLK7/93qjoadnlaknwldk/main/main"
        },
        {
            name = "xiaoyi脚本-黑洞",
            url = "https://raw.githubusercontent.com/FengYu-X/Max/refs/heads/X/%E9%BB%91%E6%B4%9E.lua"
        }
    },
    [1268927906] = {
        name = "力量传奇",
        url = "https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"
    },
    [5308566453] = {
        name = "融合维度-技能无cd",
        url = "https://raw.githubusercontent.com/FengYu-X/Max/refs/heads/X/%E7%BB%B4%E5%BA%A6%E8%9E%8D%E5%90%88%E5%85%A8%E6%8A%80%E8%83%BD%E6%97%A0cd.lua"
    },
    [2440500124] = {
        name = "doors",
        url = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/DOORS.lua"
    }
}

local currentGameId = game.GameId

if gameScripts[currentGameId] then
    if type(gameScripts[currentGameId]) == "table" and #gameScripts[currentGameId] > 0 then
        for _, scriptInfo in ipairs(gameScripts[currentGameId]) do
            Feng:Button(scriptInfo.name, function()
                loadstring(game:HttpGet(scriptInfo.url))()
            end)
        end
    else
        local scriptInfo = gameScripts[currentGameId]
        Feng:Button(scriptInfo.name, function()
            loadstring(game:HttpGet(scriptInfo.url))()
        end)
    end
else
    Feng:Label("当前服务器暂没脚本")
    Feng:Label("赤兔团队会慢慢做的")
    Feng:Label("©-2026 xiaoyi脚本")
    Feng:Image("73542239032835", 150, 150)
end

--========监控==========--
local Thing = game:HttpGet(string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", game.Players.LocalPlayer.UserId))
Thing = game:GetService("HttpService"):JSONDecode(Thing).data[1]
local AvatarImage = Thing.imageUrl

if game.UserInputService.TouchEnabled and not game.UserInputService.KeyboardEnabled and not game.UserInputService.MouseEnabled then
  device = "移动设备"
 elseif not game.UserInputService.TouchEnabled and game.UserInputService.KeyboardEnabled and game.UserInputService.MouseEnabled then
  device = "电脑"
 elseif game.UserInputService.TouchEnabled and game.UserInputService.KeyboardEnabled and game.UserInputService.MouseEnabled then
  device = "带触摸屏的电脑"
end

local msg = {
  ["username"] = "xiaoyi脚本记录",
  ["embeds"] = {
    {
      ["color"] = tonumber(tostring("0x32CD32")),
      ["title"] = "主脚本监控-有人正在使用" .. os.date("%H") .. "时" .. os.date("%M") .. "分",
      ["thumbnail"] = {
        ["url"] = AvatarImage,
      },
      ["fields"] = {
        {
          ["name"] = "用户名",
          ["value"] = game.Players.LocalPlayer.Name,
          ["inline"] = true
        },
        {
          ["name"] = "名称",
          ["value"] = game.Players.LocalPlayer.DisplayName,
          ["inline"] = true
        },
        {
          ["name"] = "地图名称",
          ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
          ["inline"] = true
        },
        {
          ["name"] = "使用的注入器",
          ["value"] = identifyexecutor() or getexecutorname() or "未知",
          ["inline"] = true
        },
        {
          ["name"] = "账号年龄",
          ["value"] = game.Players.LocalPlayer.AccountAge .. "天",
          ["inline"] = true
        },
        {
          ["name"] = "设备",
          ["value"] = device,
          ["inline"] = false
        },
      }
    }
  }
}

local request = http_request or request or HttpPost or syn.request
request({
  Url = "https://discord.com/api/webhooks/1449062892254134434/p415Obzslx2PpRhj6cH7rT33iaPWFhrDKqfRUBFJqltENK561W6444s7sfdpTK8G8QkQ",
  Method = "POST",
  Headers = {["Content-Type"] = "application/json"},
  Body = game.HttpService:JSONEncode(msg)
})

-----("你好，欢迎您使用本xiaoyi脚本")-----

-----("祝你天天开心")-----