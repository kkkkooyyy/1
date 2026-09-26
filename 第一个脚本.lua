--[[
    ================================================================
    local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isAuth = false

local secretKeys = {
    ["xiaoyi-1291"] = true,
    ["xiaoyi-5178"] = true,
    ["xiao-91578"] = true,
    ["xiaoyi-9114"] = true,
    ["xiao-9578"] = true,
    ["xiao-9978"] = true,
    ["xiao-9158"] = true,
    ["xiao-9157"] = true,
   ["xiao-9008"] = true,
   ["xiao-9108"] = true,
   ["xiao-7978"] = true,
   ["xiao-9138"] = true, 
   ["xiao-9998"] = true, 
   ["xiao-97778"] = true, 
   ["xiao-91668"] = true, 
   ["xiao-91998"] = true, 
   ["xiao-91178"] = true, 
   ["xiao-91555"] = true, 
   ["xiao-9138"] = true, 
}

local function PlaySound(audioId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"..audioId
    sound.Volume = 1
    sound.Parent = workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function CheckLicense(inputKey)
    if isAuth then return true end
    local input = string.trim(inputKey)
    if secretKeys[input] then
        isAuth = true
        print("✅授权成功")
        PlaySound(8418482985)
        return true
    else
        print("❌卡密无效")
        PlaySound(7172658577)
        return false
    end
end
    xiaoyi 缝合通用脚本 v2.1
    制作人：赤急霸
    QQ：3977491459
    ================================================================
    功能整合 (12大模块 / 14个功能页面):
      [模块1] 防封系统 (AntiBan System v2.0) - 14项保护
      [模块2] 自动加载器 - 检测游戏并自动加载对应脚本
      [模块3] GUI Hub - 完整图形界面 (78个游戏脚本)
      [模块4] 玩家功能 - 速度/跳跃/飞天/传送/玩家列表
      [模块5] ESP透视 - 方框/名称/距离/血量/队伍过滤
      [模块6] 战斗系统 - Aimbot/Hitbox Expander/Kill Aura
      [模块7] 移动增强 - 穿墙Noclip/无敌God Mode/无限体力
      [模块8] 视觉效果 - 全亮/FOV调节/透视X-Ray/夜视/去雾
      [模块9] 服务器工具 - 重连/切换/跳转/JobId复制
      [模块10] Lua执行器 - 自定义代码执行/快速片段
      [模块11] 实用工具 - 防挂机/自动点击器/坐标/FPS/计时器
      [模块12] 设置面板 - FPS优化/防封开关/环境检测/卸载
      [模块13] 快捷面板 - 悬浮快捷面板 (右Shift呼出)

    使用方法：
      直接执行此脚本即可，脚本会自动：
      1. 初始化防封系统
      2. 检测当前游戏并尝试加载对应脚本
      3. 弹出通用Hub菜单 (按右Ctrl显示/隐藏)

    脚本存放地址配置：
      修改下方 BASE_URL 为你的脚本仓库地址
    ================================================================
]]

-- ================================================================
-- >>>>>>>>>> [模块1] 防封系统 AntiBan System v2.0 <<<<<<<<<<
-- ================================================================

local AntiBan = {}
AntiBan.__index = AntiBan

-- ==================== 防封配置 ====================
local AntiBanConfig = {
    SilentMode = true,
    Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    DefaultNameLength = 12,
    MinStartupDelay = 3,
    MaxStartupDelay = 8,
    MinUpdateFrames = 2,
    MaxUpdateFrames = 5,
    TrackCreatedObjects = true,
}

local _initialized = false
local _createdObjects = {}
local _originalPrint = print
local _originalWarn = warn
local _originalError = error

-- 随机字符串
function AntiBan:RandomString(length)
    length = length or AntiBanConfig.DefaultNameLength
    local chars = AntiBanConfig.Charset
    local result = ""
    for i = 1, length do
        local index = math.random(1, #chars)
        result = result .. string.sub(chars, index, index)
    end
    return result
end

-- 随机因子
function AntiBan:RandomFactor(min, max)
    min = min or 0.9
    max = max or 1.1
    return min + math.random() * (max - min)
end

-- 安全调用
function AntiBan:SafeCall(func, ...)
    local args = {...}
    local ok, result = pcall(function()
        return func(unpack(args))
    end)
    if not ok then
        return nil, result
    end
    return result, nil
end

-- 静默模式
function AntiBan:EnableSilentMode()
    if not AntiBanConfig.SilentMode then return end
    if _G.__AntiBanOriginalPrint == nil then
        _G.__AntiBanOriginalPrint = print
        _G.__AntiBanOriginalWarn = warn
        _G.__AntiBanOriginalError = error
    end
    print = function() end
    warn = function() end
end

function AntiBan:DisableSilentMode()
    if _G.__AntiBanOriginalPrint then
        print = _G.__AntiBanOriginalPrint
        warn = _G.__AntiBanOriginalWarn
        error = _G.__AntiBanOriginalError
    end
end

-- 环境检测
function AntiBan:GetEnvironment()
    local env = {
        isSynapse = false, isScriptWare = false, isKrnl = false,
        isElectron = false, isFluxus = false,
        hasGetHui = false, hasProtectGui = false,
    }
    pcall(function()
        if syn and syn.protect_gui then env.isSynapse = true; env.hasProtectGui = true end
    end)
    pcall(function()
        if gethui then env.hasGetHui = true end
    end)
    pcall(function()
        if fluxus then env.isFluxus = true end
    end)
    pcall(function()
        if Krnl then env.isKrnl = true end
    end)
    return env
end

-- 安全父级
function AntiBan:GetSafeParent()
    local candidates = {}
    if gethui then
        table.insert(candidates, function() return gethui() end)
    end
    table.insert(candidates, function() return game:GetService("CoreGui") end)
    table.insert(candidates, function()
        local lp = game:GetService("Players").LocalPlayer
        if lp then return lp:WaitForChild("PlayerGui") end
        return nil
    end)
    for _, getParent in ipairs(candidates) do
        local ok, p = pcall(getParent)
        if ok and p then return p end
    end
    return game:GetService("CoreGui")
end

-- GUI 保护
function AntiBan:ProtectGui(gui)
    if not gui then return end
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
    pcall(function()
        if fluxus and fluxus.protect_gui then fluxus.protect_gui(gui) end
    end)
    return gui
end

-- 创建受保护的 ScreenGui
function AntiBan:CreateProtectedGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = self:RandomString(12)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = self:GetSafeParent()
    self:ProtectGui(gui)
    self:TrackObject(gui)
    return gui
end

-- 对象跟踪
function AntiBan:TrackObject(obj)
    if not AntiBanConfig.TrackCreatedObjects then return end
    if not obj then return end
    table.insert(_createdObjects, obj)
end

function AntiBan:UntrackObject(obj)
    for i, o in ipairs(_createdObjects) do
        if o == obj then table.remove(_createdObjects, i); return true end
    end
    return false
end

-- 清理
function AntiBan:Cleanup()
    local count = 0
    for i = #_createdObjects, 1, -1 do
        local obj = _createdObjects[i]
        if obj and obj.Parent ~= nil then
            pcall(function() obj:Destroy() end)
            count = count + 1
        end
        table.remove(_createdObjects, i)
    end
    self:DisableSilentMode()
    pcall(function()
        _G.__AntiBanOriginalPrint = nil
        _G.__AntiBanOriginalWarn = nil
        _G.__AntiBanOriginalError = nil
        _G.__AntiBanInitialized = nil
    end)
    _initialized = false
    return count
end

-- 随机延迟执行
function AntiBan:DelayedRun(minDelay, maxDelay, callback)
    minDelay = minDelay or AntiBanConfig.MinStartupDelay
    maxDelay = maxDelay or AntiBanConfig.MaxStartupDelay
    local delay = minDelay + math.random() * (maxDelay - minDelay)
    task.spawn(function()
        task.wait(delay)
        self:SafeCall(callback)
    end)
end

-- 随机间隔循环
function AntiBan:CreateRandomLoop(minFrames, maxFrames, callback)
    minFrames = minFrames or AntiBanConfig.MinUpdateFrames
    maxFrames = maxFrames or AntiBanConfig.MaxUpdateFrames
    local RunService = game:GetService("RunService")
    local frameCount = 0
    local nextUpdate = math.random(minFrames, maxFrames)
    local stopped = false
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        if stopped then connection:Disconnect(); return end
        frameCount = frameCount + 1
        if frameCount >= nextUpdate then
            frameCount = 0
            nextUpdate = math.random(minFrames, maxFrames)
            local ok, result = self:SafeCall(callback, dt)
            if result == false then
                stopped = true
                connection:Disconnect()
            end
        end
    end)
    return {
        Stop = function() stopped = true; connection:Disconnect() end,
        IsRunning = function() return not stopped end,
    }
end

-- 频率限制器
function AntiBan:CreateRateLimiter(minInterval)
    local lastTime = 0
    minInterval = minInterval or 1
    return {
        Try = function()
            local now = os.clock()
            if now - lastTime >= minInterval then
                lastTime = now; return true
            end
            return false
        end,
        Reset = function() lastTime = 0 end,
        SetInterval = function(interval) minInterval = interval end,
    }
end

-- 实例伪装
function AntiBan:DisguiseInstance(instance)
    if not instance then return end
    pcall(function()
        if instance.Name == instance.ClassName or instance.Name == "" then
            instance.Name = self:RandomString(10)
        end
        if instance:IsA("GuiObject") then
            pcall(function() instance.BorderSizePixel = 0 end)
        end
    end)
    self:TrackObject(instance)
    return instance
end

-- 心跳混淆器
function AntiBan:CreateJitterTimer(baseInterval, jitterAmount, callback)
    local timer = {
        baseInterval = baseInterval or 5,
        jitter = jitterAmount or 1,
        callback = callback,
        running = false,
    }
    function timer:Start()
        if self.running then return end
        self.running = true
        task.spawn(function()
            while self.running do
                local actualDelay = self.baseInterval + (math.random() - 0.5) * 2 * self.jitter
                actualDelay = math.max(0.1, actualDelay)
                task.wait(actualDelay)
                if self.running and self.callback then
                    AntiBan:SafeCall(self.callback)
                end
            end
        end)
    end
    function timer:Stop() self.running = false end
    return timer
end

-- 内存隐藏
function AntiBan:HideFromMemory()
    pcall(function() if _G and _G.AntiBan then _G.AntiBan = nil end end)
    pcall(function() if shared and shared.AntiBan then shared.AntiBan = nil end end)
end

-- 初始化
function AntiBan:Init(options)
    if _initialized then return self end
    if options then
        for k, v in pairs(options) do
            if AntiBanConfig[k] ~= nil then AntiBanConfig[k] = v end
        end
    end
    self:EnableSilentMode()
    math.randomseed(tick() * 1000)
    for i = 1, 10 do math.random() end
    self:HideFromMemory()
    _initialized = true
    return self
end

function AntiBan:IsInitialized() return _initialized end

-- 安全创建实例
function AntiBan:NewInstance(className, parent)
    local inst = nil
    self:SafeCall(function()
        inst = Instance.new(className)
        inst.Name = self:RandomString(10)
        if parent then inst.Parent = parent end
        self:DisguiseInstance(inst)
    end)
    return inst
end

-- 安全属性读写
function AntiBan:SafeGetAttribute(obj, attrName, default)
    local ok, val = pcall(function() return obj:GetAttribute(attrName) end)
    if ok then return val end
    return default
end

function AntiBan:SafeSetAttribute(obj, attrName, value)
    return self:SafeCall(function() obj:SetAttribute(attrName, value) end)
end

-- 安全服务获取
function AntiBan:GetService(serviceName)
    local ok, svc = pcall(function() return game:GetService(serviceName) end)
    if ok and svc then return svc end
    return nil
end

-- ================================================================
-- >>>>>>>>>> [模块2] 通用工具函数 <<<<<<<<<<
-- ================================================================

-- 服务获取
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 通知
local function notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

-- 加载脚本
local function loadScript(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        return false
    end
    return true
end

-- 随机字符串（快捷方式）
local function randomString(length)
    return AntiBan:RandomString(length)
end

-- ================================================================
-- >>>>>>>>>> [模块3] 自动加载器 <<<<<<<<<<
-- ================================================================

-- ★★★ 把这里改成你的脚本存放地址 ★★★
local BASE_URL = "https://raw.githubusercontent.com/你的用户名/仓库/main/xiaoyi_scripts/"

-- 游戏-脚本匹配表 (78个游戏)
local GameScriptMap = {
    {keywords = {"DOORS", "Doors", "doors"}, file = "DOORS.lua"},
    {keywords = {"GB", "Grand"}, file = "GB.lua"},
    {keywords = {"七日生存", "7 Days"}, file = "七日生存.lua"},
    {keywords = {"不要离开圈子", "Don't Leave"}, file = "不要离开圈子.lua"},
    {keywords = {"中国人能飞", "Chinese Can Fly"}, file = "中国人能飞.lua"},
    {keywords = {"亡命速递", "Rush Delivery"}, file = "亡命速递.lua"},
    {keywords = {"伐木大亨", "Lumber Tycoon"}, file = "伐木大亨2.lua"},
    {keywords = {"俄亥俄", "Ohio"}, file = "俄亥俄州.lua"},
    {keywords = {"战争大亨", "War Tycoon", "WarTycoon"}, file = "战争大亨.lua"},
    {keywords = {"偷一个蛋", "Steal an Egg"}, file = "偷一个蛋.lua"},
    {keywords = {"决斗场", "Duel"}, file = "决斗场.lua"},
    {keywords = {"出售柠檬", "Lemonade"}, file = "出售柠檬.lua"},
    {keywords = {"力量传奇", "Strength Legend"}, file = "力量传奇.lua"},
    {keywords = {"动物医院", "Animal Hospital", "Pet Sim"}, file = "动物医院.lua"},
    {keywords = {"南极探险", "Antarctic"}, file = "南极探险队.lua"},
    {keywords = {"变形升级", "Morph"}, file = "变形升级.lua"},
    {keywords = {"变身躲猫猫", "Prop Hunt"}, file = "变身躲猫猫.lua"},
    {keywords = {"吃吃世界", "Eat World"}, file = "吃吃世界.lua"},
    {keywords = {"吃掉其他人", "Eat Others"}, file = "吃掉其他人来成长.lua"},
    {keywords = {"合成一个核弹", "Nuke"}, file = "合成一个核弹.lua"},
    {keywords = {"国人电梯", "Elevator"}, file = "国人电梯.lua"},
    {keywords = {"圣地亚哥", "San Diego"}, file = "圣地亚哥边境.lua"},
    {keywords = {"圣奥里", "Saint Ory", "SANA"}, file = "圣奥里.lua"},
    {keywords = {"末日生存", "Apocalypse"}, file = "在末日中生存.lua"},
    {keywords = {"超市", "Supermarket"}, file = "在超市生活一周.lua"},
    {keywords = {"地铁冲浪", "Subway"}, file = "地铁冲浪.lua"},
    {keywords = {"墨水游戏", "Ink Game"}, file = "墨水游戏.lua"},
    {keywords = {"巨剑骑士", "Great Sword"}, file = "巨剑骑士.lua"},
    {keywords = {"忍者传奇", "Ninja Legend"}, file = "忍者传奇.lua"},
    {keywords = {"恶魔学", "Demonology"}, file = "恶魔学.lua"},
    {keywords = {"戒网瘾", "Internet Addiction"}, file = "戒网瘾中心.lua"},
    {keywords = {"战斗砖块", "Brick Battle"}, file = "战斗砖块.lua"},
    {keywords = {"手枪竞技场", "Pistol Arena"}, file = "手枪竞技场.lua"},
    {keywords = {"打了一巴掌", "Slap"}, file = "找出谁打了一巴掌.lua"},
    {keywords = {"找到按钮", "Find Button"}, file = "找到按钮.lua"},
    {keywords = {"变形形态", "Morph"}, file = "找到菜鸟的变形形态.lua"},
    {keywords = {"捕捉并驯服", "Catch and Tame"}, file = "捕捉并驯服吧.lua"},
    {keywords = {"最强战场", "Strongest Battleground"}, file = "最强战场.lua"},
    {keywords = {"最终战场", "Final Battleground"}, file = "最终战场.lua"},
    {keywords = {"终极战场", "Ultimate Battleground"}, file = "终极战场.lua"},
    {keywords = {"木筏", "Raft"}, file = "木筏101天生存.lua"},
    {keywords = {"极速传奇", "Speed Legend"}, file = "极速传奇.lua"},
    {keywords = {"99夜", "99 Nights"}, file = "森林中的99夜.lua"},
    {keywords = {"模仿者", "Imposter"}, file = "模仿者.lua"},
    {keywords = {"死亡避难所", "Dead Shelter"}, file = "死亡避难所.lua"},
    {keywords = {"死铁轨", "Dead Rails"}, file = "死铁轨.lua"},
    {keywords = {"沉默的刺客", "Silent Assassin"}, file = "沉默的刺客.lua"},
    {keywords = {"泰坦钓鱼", "Titan Fishing"}, file = "泰坦钓鱼.lua"},
    {keywords = {"烤或死", "Cook or Die"}, file = "烤或死.lua"},
    {keywords = {"生存与杀手", "Survival Killer"}, file = "生存与杀手.lua"},
    {keywords = {"画我", "Draw Me"}, file = "画我.lua"},
    {keywords = {"疯狂电梯", "Crazy Elevator"}, file = "疯狂电梯.lua"},
    {keywords = {"盲射", "Blind Shot"}, file = "盲射.lua"},
    {keywords = {"破坏者谜团", "Saboteur"}, file = "破坏者谜团2.lua"},
    {keywords = {"种植花园", "Grow a Garden"}, file = "种植花园.lua"},
    {keywords = {"紧急汉堡", "Emergency Burger"}, file = "紧急汉堡.lua"},
    {keywords = {"能量爆炸", "Energy Boom"}, file = "能量爆炸幸运方块.lua"},
    {keywords = {"自然灾害", "Natural Disaster"}, file = "自然灾害.lua"},
    {keywords = {"血腥的游乐场", "Bloody Playground"}, file = "血腥的游乐场.lua"},
    {keywords = {"被遗弃", "Abandoned"}, file = "被遗弃.lua"},
    {keywords = {"踢出幸运", "Kick Lucky"}, file = "踢出幸运方块.lua"},
    {keywords = {"血布娃娃", "Ragdoll"}, file = "通用血布娃娃战斗.lua"},
    {keywords = {"通缉", "Wanted"}, file = "通缉.lua"},
    {keywords = {"造船寻宝", "Build Boat"}, file = "造船寻宝.lua"},
    {keywords = {"键盘速度", "Keyboard Speed"}, file = "键盘速度逃脱.lua"},
    {keywords = {"闪光", "Flash"}, file = "闪光.lua"},
    {keywords = {"鲨口求生", "Shark"}, file = "鲨口求生.lua"},
    {keywords = {"种植花园2", "Grow a Garden 2"}, file = "种植花园2.lua"},
    -- 新增脚本
    {keywords = {"chain", "Chain"}, file = "chain.lua"},
    {keywords = {"兵工厂", "Arsenal"}, file = "兵工厂.lua"},
    {keywords = {"播放音乐", "Music"}, file = "播放音乐.lua"},
    {keywords = {"木材大亨", "Lumber"}, file = "木材大亨.lua"},
    {keywords = {"武器库", "Weapon"}, file = "武器库.lua"},
    {keywords = {"死亡球", "Death Ball"}, file = "死亡球.lua"},
    {keywords = {"物体传送", "Object Teleport"}, file = "物体传送.lua"},
    {keywords = {"生存99天", "Survive 99"}, file = "生存99天.lua"},
    {keywords = {"脑叶公司", "Lobotomy"}, file = "脑叶公司.lua"},
    {keywords = {"零售大亨", "Retail Tycoon"}, file = "零售大亨.lua"},
    {keywords = {"餐厅大亨", "Restaurant Tycoon"}, file = "餐厅大亨3.lua"},
}

-- PlaceId 直接匹配表
local PlaceIdMap = {
    [6516141723] = "DOORS.lua",
    [3101667897] = "极速传奇.lua",
    [3276265788] = "极速传奇.lua",
    [3232996272] = "极速传奇.lua",
    [74233625] = "武器库.lua",
    [7367831688] = "森林中的99夜.lua",
    [216280221939] = "生存99天.lua",
}

local function getGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        return info.Name
    end
    return ""
end

local function findScript(gameName)
    local placeId = game.PlaceId
    if PlaceIdMap[placeId] then
        return PlaceIdMap[placeId]
    end
    gameName = string.lower(gameName)
    for _, entry in ipairs(GameScriptMap) do
        for _, keyword in ipairs(entry.keywords) do
            if string.find(gameName, string.lower(keyword)) then
                return entry.file
            end
        end
    end
    return nil
end

-- 自动加载逻辑
local function autoLoad()
    local gameName = getGameName()
    local scriptFile = findScript(gameName)

    if scriptFile then
        notify("xiaoyi", "检测到游戏: " .. gameName .. "\n正在加载: " .. scriptFile, 4)
        task.wait(1)
        local url = BASE_URL .. scriptFile
        local ok = loadScript(url)
        if ok then
            notify("xiaoyi", scriptFile .. " 加载成功！", 3)
        else
            notify("xiaoyi", scriptFile .. " 加载失败\n请检查 BASE_URL 设置", 5)
        end
    else
        notify("xiaoyi", "未检测到匹配的游戏脚本\n游戏名: " .. (gameName ~= "" and gameName or "未知"), 5)
    end
end

-- ================================================================
-- >>>>>>>>>> [模块4] GUI Hub 主界面 <<<<<<<<<<
-- ================================================================

-- ==================== 脚本列表 (78个) ====================
local ScriptList = {
    {name = "DOORS", file = "DOORS.lua"},
    {name = "GB", file = "GB.lua"},
    {name = "七日生存", file = "七日生存.lua"},
    {name = "不要离开圈子", file = "不要离开圈子.lua"},
    {name = "中国人能飞", file = "中国人能飞.lua"},
    {name = "亡命速递", file = "亡命速递.lua"},
    {name = "伐木大亨2", file = "伐木大亨2.lua"},
    {name = "俄亥俄州", file = "俄亥俄州.lua"},
    {name = "战争大亨", file = "战争大亨.lua"},
    {name = "偷一个蛋", file = "偷一个蛋.lua"},
    {name = "决斗场", file = "决斗场.lua"},
    {name = "出售柠檬", file = "出售柠檬.lua"},
    {name = "力量传奇", file = "力量传奇.lua"},
    {name = "动物医院", file = "动物医院.lua"},
    {name = "南极探险队", file = "南极探险队.lua"},
    {name = "变形升级", file = "变形升级.lua"},
    {name = "变身躲猫猫", file = "变身躲猫猫.lua"},
    {name = "吃吃世界", file = "吃吃世界.lua"},
    {name = "吃掉其他人来成长", file = "吃掉其他人来成长.lua"},
    {name = "合成一个核弹", file = "合成一个核弹.lua"},
    {name = "国人电梯", file = "国人电梯.lua"},
    {name = "圣地亚哥边境", file = "圣地亚哥边境.lua"},
    {name = "圣奥里", file = "圣奥里.lua"},
    {name = "在末日中生存", file = "在末日中生存.lua"},
    {name = "在超市生活一周", file = "在超市生活一周.lua"},
    {name = "地铁冲浪", file = "地铁冲浪.lua"},
    {name = "墨水游戏", file = "墨水游戏.lua"},
    {name = "巨剑骑士", file = "巨剑骑士.lua"},
    {name = "忍者传奇", file = "忍者传奇.lua"},
    {name = "恶魔学", file = "恶魔学.lua"},
    {name = "戒网瘾中心", file = "戒网瘾中心.lua"},
    {name = "战斗砖块", file = "战斗砖块.lua"},
    {name = "手枪竞技场", file = "手枪竞技场.lua"},
    {name = "找出谁打了一巴掌", file = "找出谁打了一巴掌.lua"},
    {name = "找到按钮", file = "找到按钮.lua"},
    {name = "找到菜鸟的变形形态", file = "找到菜鸟的变形形态.lua"},
    {name = "捕捉并驯服吧", file = "捕捉并驯服吧.lua"},
    {name = "最强战场", file = "最强战场.lua"},
    {name = "最终战场", file = "最终战场.lua"},
    {name = "终极战场", file = "终极战场.lua"},
    {name = "木筏101天生存", file = "木筏101天生存.lua"},
    {name = "极速传奇", file = "极速传奇.lua"},
    {name = "森林中的99夜", file = "森林中的99夜.lua"},
    {name = "模仿者", file = "模仿者.lua"},
    {name = "死亡避难所", file = "死亡避难所.lua"},
    {name = "死铁轨", file = "死铁轨.lua"},
    {name = "沉默的刺客", file = "沉默的刺客.lua"},
    {name = "泰坦钓鱼", file = "泰坦钓鱼.lua"},
    {name = "烤或死", file = "烤或死.lua"},
    {name = "生存与杀手", file = "生存与杀手.lua"},
    {name = "画我", file = "画我.lua"},
    {name = "疯狂电梯", file = "疯狂电梯.lua"},
    {name = "盲射", file = "盲射.lua"},
    {name = "破坏者谜团2", file = "破坏者谜团2.lua"},
    {name = "种植花园", file = "种植花园.lua"},
    {name = "种植花园2", file = "种植花园2.lua"},
    {name = "紧急汉堡", file = "紧急汉堡.lua"},
    {name = "能量爆炸幸运方块", file = "能量爆炸幸运方块.lua"},
    {name = "自然灾害", file = "自然灾害.lua"},
    {name = "血腥的游乐场", file = "血腥的游乐场.lua"},
    {name = "被遗弃", file = "被遗弃.lua"},
    {name = "踢出幸运方块", file = "踢出幸运方块.lua"},
    {name = "通用血布娃娃战斗", file = "通用血布娃娃战斗.lua"},
    {name = "通缉", file = "通缉.lua"},
    {name = "造船寻宝", file = "造船寻宝.lua"},
    {name = "键盘速度逃脱", file = "键盘速度逃脱.lua"},
    {name = "闪光", file = "闪光.lua"},
    {name = "鲨口求生", file = "鲨口求生.lua"},
    -- 新增
    {name = "chain", file = "chain.lua"},
    {name = "兵工厂", file = "兵工厂.lua"},
    {name = "播放音乐", file = "播放音乐.lua"},
    {name = "木材大亨", file = "木材大亨.lua"},
    {name = "武器库", file = "武器库.lua"},
    {name = "死亡球", file = "死亡球.lua"},
    {name = "物体传送", file = "物体传送.lua"},
    {name = "生存99天", file = "生存99天.lua"},
    {name = "脑叶公司", file = "脑叶公司.lua"},
    {name = "零售大亨", file = "零售大亨.lua"},
    {name = "餐厅大亨3", file = "餐厅大亨3.lua"},
}

-- ==================== 主题颜色 ====================
local Theme = {
    Background = Color3.fromRGB(20, 20, 28),
    Sidebar = Color3.fromRGB(25, 25, 35),
    Content = Color3.fromRGB(30, 30, 40),
    Accent = Color3.fromRGB(100, 130, 255),
    AccentHover = Color3.fromRGB(120, 150, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(160, 160, 175),
    Success = Color3.fromRGB(80, 200, 100),
    Danger = Color3.fromRGB(220, 70, 70),
    Border = Color3.fromRGB(45, 45, 55),
    ButtonBg = Color3.fromRGB(40, 40, 52),
    ButtonHover = Color3.fromRGB(55, 55, 70),
    InputBg = Color3.fromRGB(35, 35, 45),
}

-- ==================== GUI 主框架（使用防封系统保护） ====================
local ScreenGui = AntiBan:CreateProtectedGui()

-- 主窗口
local MainWindow = Instance.new("Frame")
MainWindow.Name = randomString(10)
MainWindow.Size = UDim2.new(0, 680, 0, 460)
MainWindow.Position = UDim2.new(0.5, -340, 0.5, -230)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BorderSizePixel = 0
MainWindow.Parent = ScreenGui
MainWindow.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainWindow

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Border
mainStroke.Thickness = 1
mainStroke.Parent = MainWindow

-- ==================== 顶部栏 ====================
local TopBar = Instance.new("Frame")
TopBar.Name = randomString(8)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainWindow

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = TopBar

local topFill = Instance.new("Frame")
topFill.Size = UDim2.new(1, 0, 0, 10)
topFill.Position = UDim2.new(0, 0, 0, 40)
topFill.BackgroundColor3 = Theme.Sidebar
topFill.BorderSizePixel = 0
topFill.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 0, 50)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "xiaoyi Hub"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0, 200, 0, 50)
SubtitleLabel.Position = UDim2.new(0, 135, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "| 缝合通用 | 赤急霸 制作"
SubtitleLabel.TextColor3 = Theme.TextDim
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 14
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 50)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar

-- ==================== 侧边栏 ====================
local Sidebar = Instance.new("Frame")
Sidebar.Name = randomString(8)
Sidebar.Size = UDim2.new(0, 160, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Theme.Border
sidebarStroke.Thickness = 1
sidebarStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar

-- ==================== 内容区域 ====================
local ContentArea = Instance.new("Frame")
ContentArea.Name = randomString(8)
ContentArea.Size = UDim2.new(1, -160, 1, -50)
ContentArea.Position = UDim2.new(0, 160, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainWindow

-- ==================== 页面容器 ====================
local Pages = {}
local SidebarButtons = {}
local currentPage = nil

local function createPage(name, icon)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    Pages[name] = page

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 38)
    btn.BackgroundTransparency = 1
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn

    SidebarButtons[name] = {btn = btn, indicator = indicator}

    btn.MouseButton1Click:Connect(function()
        for pageName, data in pairs(SidebarButtons) do
            data.btn.TextColor3 = Theme.TextDim
            data.indicator.Visible = false
        end
        btn.TextColor3 = Theme.Text
        indicator.Visible = true

        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
        currentPage = name
    end)

    return page
end

-- ==================== UI 组件工厂 ====================
local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Theme.Content
    section.BorderSizePixel = 0
    section.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = section

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = section

    if title then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Theme.Accent
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
    end

    return section
end

local function createToggle(parent, text, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 32)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 32)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -44, 0.5, -11)
    switch.BackgroundColor3 = defaultState and Theme.Success or Color3.fromRGB(50, 50, 60)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = toggleFrame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = defaultState

    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 60)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end)

    return {
        Set = function(val)
            state = val
            switch.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 60)
            knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        end,
        Get = function() return state end,
    }
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.ButtonBg
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ButtonHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ButtonBg}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function createSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(defaultVal)
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local value = defaultVal

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = track.AbsolutePosition
            local trackSize = track.AbsoluteSize
            local pct = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
            value = math.floor(minVal + pct * (maxVal - minVal))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -7, 0.5, -7)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)

    return {
        Get = function() return value end,
        Set = function(val)
            value = val
            local pct = (val - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -7, 0.5, -7)
            label.Text = text .. ": " .. tostring(val)
        end,
    }
end

local function createInputBox(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 32)
    box.BackgroundColor3 = Theme.InputBg
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextDim
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = box

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    return box
end

-- ==================== 页面：脚本列表 ====================
local scriptPage = createPage("脚本列表", "")

local searchBox = createInputBox(scriptPage, "搜索脚本名称...", function(text)
    for _, child in ipairs(scriptPage:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "" then
            local scriptName = child:GetAttribute("ScriptName") or ""
            if text == "" or string.find(string.lower(scriptName), string.lower(text)) then
                child.Visible = true
            else
                child.Visible = false
            end
        end
    end
end)

for _, script in ipairs(ScriptList) do
    local btn = createButton(scriptPage, ">  " .. script.name, function()
        notify("xiaoyi", "正在加载: " .. script.name, 3)
        local url = BASE_URL .. script.file
        local ok = loadScript(url)
        if ok then
            notify("xiaoyi", script.name .. " 加载成功！", 3)
        else
            notify("xiaoyi", script.name .. " 加载失败\n请检查 BASE_URL", 4)
        end
    end)
    btn:SetAttribute("ScriptName", script.name)
    btn.TextXAlignment = Enum.TextXAlignment.Left
end

-- ==================== 页面：玩家功能 ====================
local playerPage = createPage("玩家功能", "")

local playerSection = createSection(playerPage, "基础功能")

local flySpeed = 50
local walkSpeedVal = 16
local jumpPowerVal = 50

local speedSlider = createSlider(playerSection, "移动速度", 16, 200, 16, function(val)
    walkSpeedVal = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

local jumpSlider = createSlider(playerSection, "跳跃高度", 50, 300, 50, function(val)
    jumpPowerVal = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = val
            hum.JumpHeight = val / 50
        end
    end
end)

local infJump = createToggle(playerSection, "无限跳跃", false, function(state)
    if state then
        UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

local flySection = createSection(playerPage, "飞天功能")
local flyToggle = createToggle(flySection, "启用飞天", false, function(state)
    if state then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = root
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                bg.CFrame = root.CFrame
                bg.Parent = root

                RunService.RenderStepped:Connect(function()
                    if not state then return end
                    local cam = Camera
                    if cam then
                        local dir = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                        bv.Velocity = dir * flySpeed
                    end
                end)
            end
        end
    end
end)

local flySpeedSlider = createSlider(flySection, "飞天速度", 10, 200, 50, function(val)
    flySpeed = val
end)

local teleportSection = createSection(playerPage, "传送功能")
createButton(teleportSection, "传送到鼠标位置", function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not Camera then return end
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, rp)
    if result then
        root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        notify("xiaoyi", "已传送到鼠标位置", 2)
    end
end)

createButton(teleportSection, "传送到出生点", function()
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and workspace:FindFirstChild("SpawnLocation") then
            root.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
            notify("xiaoyi", "已传送到出生点", 2)
        end
    end
end)

-- 传送到玩家
local tpPlayerSection = createSection(playerPage, "传送到其他玩家")
local tpPlayerList = {}

local function refreshPlayerTPButtons()
    for _, btn in ipairs(tpPlayerList) do
        if btn and btn.Parent then btn:Destroy() end
    end
    tpPlayerList = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = createButton(tpPlayerSection, ">  " .. p.Name, function()
                local myChar = LocalPlayer.Character
                if not myChar then return end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                local targetChar = p.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)
                        notify("xiaoyi", "已传送到: " .. p.Name, 2)
                    else
                        notify("xiaoyi", "目标玩家尚未加载", 2)
                    end
                else
                    notify("xiaoyi", "目标玩家尚未加载", 2)
                end
            end)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(tpPlayerList, btn)
        end
    end
end

createButton(tpPlayerSection, "刷新玩家列表", function()
    refreshPlayerTPButtons()
    notify("xiaoyi", "玩家列表已刷新", 2)
end)

task.spawn(function()
    task.wait(1)
    refreshPlayerTPButtons()
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshPlayerTPButtons()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(1)
    refreshPlayerTPButtons()
end)

-- ==================== 页面：ESP透视 ====================
do
local espPage = createPage("ESP透视", "")

-- ESP 状态
local espState = {
    boxESP = false,
    nameESP = false,
    distanceESP = false,
    tracerESP = false,
    healthESP = false,
    teamCheck = false,
    maxDistance = 5000,
    espColor = Color3.fromRGB(255, 50, 50),
    tracerOrigin = "Bottom",
}

-- ESP 绘制对象存储
local espObjects = {}

local function clearESPForPlayer(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        espObjects[player] = nil
    end
end

local function clearAllESP()
    for player, _ in pairs(espObjects) do
        clearESPForPlayer(player)
    end
    espObjects = {}
end

local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    clearESPForPlayer(player)

    local data = {}

    -- Box ESP (BillboardGui)
    local bg = Instance.new("BillboardGui")
    bg.Name = randomString(10)
    bg.Size = UDim2.new(0, 200, 0, 100)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
    data.billboard = bg

    -- Box frame
    if espState.boxESP then
        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 2
        box.BorderColor3 = espState.espColor
        box.Parent = bg
        data.box = box

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = espState.espColor
        boxStroke.Thickness = 2
        boxStroke.Transparency = 0
        boxStroke.Parent = box
        data.boxStroke = boxStroke
    end

    -- Name ESP
    if espState.nameESP then
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, 0, 0, 20)
        name.Position = UDim2.new(0, 0, 0, -22)
        name.BackgroundTransparency = 1
        name.Text = player.Name
        name.TextColor3 = espState.espColor
        name.Font = Enum.Font.GothamBold
        name.TextSize = 14
        name.TextStrokeTransparency = 0
        name.Parent = bg
        data.nameLabel = name
    end

    -- Distance ESP
    if espState.distanceESP then
        local dist = Instance.new("TextLabel")
        dist.Size = UDim2.new(1, 0, 0, 16)
        dist.Position = UDim2.new(0, 0, 1, 2)
        dist.BackgroundTransparency = 1
        dist.Text = "0m"
        dist.TextColor3 = Color3.fromRGB(200, 200, 200)
        dist.Font = Enum.Font.Gotham
        dist.TextSize = 12
        dist.TextStrokeTransparency = 0.5
        dist.Parent = bg
        data.distLabel = dist
    end

    -- Health ESP
    if espState.healthESP then
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(0, 4, 1, -20)
        healthBar.Position = UDim2.new(0, -8, 0, 10)
        healthBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = bg
        data.healthBarBg = healthBar

        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBar
        data.healthFill = healthFill

        local healthCorner = Instance.new("UICorner")
        healthCorner.CornerRadius = UDim.new(1, 0)
        healthCorner.Parent = healthFill

        local healthBgCorner = Instance.new("UICorner")
        healthBgCorner.CornerRadius = UDim.new(1, 0)
        healthBgCorner.Parent = healthBar
    end

    espObjects[player] = data
    return data
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    local data = espObjects[player]
                    if not data then data = createESPForPlayer(player) end
                    if not data then continue end

                    local lpChar = LocalPlayer.Character
                    if not lpChar then continue end
                    local lpRoot = lpChar:FindFirstChild("HumanoidRootPart")
                    if not lpRoot then continue end

                    local distance = (root.Position - lpRoot.Position).Magnitude

                    -- 超出最大距离
                    if distance > espState.maxDistance then
                        if data.billboard then data.billboard.Parent = nil end
                        continue
                    end

                    -- 队伍检查
                    if espState.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                        if data.billboard then data.billboard.Parent = nil end
                        continue
                    end

                    -- 设置父级
                    if data.billboard and data.billboard.Parent == nil then
                        data.billboard.Parent = root
                    end

                    -- 更新距离
                    if data.distLabel then
                        data.distLabel.Text = string.format("%.0fm", distance)
                    end

                    -- 更新血量
                    if data.healthFill and hum then
                        local hp = hum.Health
                        local maxHp = hum.MaxHealth
                        local pct = math.clamp(hp / maxHp, 0, 1)
                        data.healthFill.Size = UDim2.new(1, 0, pct, 0)
                        local r = math.floor(255 * (1 - pct))
                        local g = math.floor(255 * pct)
                        data.healthFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)
                    end
                end
            end
        end
    end
end

local espLoop = nil

local function startESPLoop()
    if espLoop then espLoop:Stop() end
    espLoop = AntiBan:CreateRandomLoop(2, 5, function()
        updateESP()
    end)
end

local function stopESPLoop()
    if espLoop then
        espLoop:Stop()
        espLoop = nil
    end
    clearAllESP()
end

-- ESP 页面内容
local espSection = createSection(espPage, "ESP 功能开关")

createToggle(espSection, "方框 ESP", false, function(state)
    espState.boxESP = state
    clearAllESP()
    if state and not espLoop then startESPLoop() end
    if not espState.boxESP and not espState.nameESP and not espState.distanceESP and not espState.tracerESP and not espState.healthESP then
        stopESPLoop()
    end
end)

createToggle(espSection, "名称 ESP", false, function(state)
    espState.nameESP = state
    clearAllESP()
    if state and not espLoop then startESPLoop() end
end)

createToggle(espSection, "距离 ESP", false, function(state)
    espState.distanceESP = state
    clearAllESP()
    if state and not espLoop then startESPLoop() end
end)

createToggle(espSection, "血量条 ESP", false, function(state)
    espState.healthESP = state
    clearAllESP()
    if state and not espLoop then startESPLoop() end
end)

createToggle(espSection, "队伍过滤 (不显示队友)", false, function(state)
    espState.teamCheck = state
    clearAllESP()
end)

local espDistSection = createSection(espPage, "ESP 距设置")
createSlider(espDistSection, "最大显示距离", 100, 10000, 5000, function(val)
    espState.maxDistance = val
end)

local espActionSection = createSection(espPage, "ESP 操作")
createButton(espActionSection, "清除所有 ESP", function()
    clearAllESP()
    notify("xiaoyi", "所有 ESP 已清除", 2)
end)

createButton(espActionSection, "关闭 ESP 功能", function()
    stopESPLoop()
    espState.boxESP = false
    espState.nameESP = false
    espState.distanceESP = false
    espState.tracerESP = false
    espState.healthESP = false
    notify("xiaoyi", "ESP 功能已全部关闭", 3)
end)

-- ==================== 页面：战斗 ====================
local combatPage = createPage("战斗", "")

-- Aimbot 状态
local aimbotState = {
    enabled = false,
    FOV = 150,
    smoothing = 0.15,
    targetPart = "Head",
    teamCheck = true,
    visibleCheck = false,
}

local aimbotLoop = nil
local aimbotTarget = nil

local function getClosestPlayer()
    local closest = nil
    local shortestDist = aimbotState.FOV
    local mousePos = UserInputService:GetMouseLocation()
    local viewportSize = Camera.ViewportSize

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if aimbotState.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                continue
            end
            local char = player.Character
            if char then
                local part = char:FindFirstChild(aimbotState.targetPart)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function startAimbot()
    if aimbotLoop then aimbotLoop:Stop() end
    aimbotLoop = AntiBan:CreateRandomLoop(1, 2, function()
        if not aimbotState.enabled then return false end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(aimbotState.targetPart)
            if part and Camera then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                local smoothed = Camera.CFrame:Lerp(targetCFrame, aimbotState.smoothing)
                Camera.CFrame = smoothed
            end
        end
    end)
end

local combatSection = createSection(combatPage, "Aimbot 瞄准")

local aimbotToggle = createToggle(combatSection, "启用 Aimbot (右键瞄准)", false, function(state)
    aimbotState.enabled = state
    if state then
        startAimbot()
    elseif aimbotLoop then
        aimbotLoop:Stop()
        aimbotLoop = nil
    end
end)

createSlider(combatSection, "Aimbot FOV", 50, 1000, 150, function(val)
    aimbotState.FOV = val
end)

createSlider(combatSection, "平滑度", 5, 100, 15, function(val)
    aimbotState.smoothing = val / 100
end)

local aimTargetSection = createSection(combatPage, "瞄准部位")

createButton(aimTargetSection, "瞄准: 头部", function()
    aimbotState.targetPart = "Head"
    notify("xiaoyi", "已切换到头部瞄准", 2)
end)

createButton(aimTargetSection, "瞄准: 身体", function()
    aimbotState.targetPart = "HumanoidRootPart"
    notify("xiaoyi", "已切换到身体瞄准", 2)
end)

-- Hitbox Expander
local hitboxState = {
    enabled = false,
    size = 10,
    transparency = 0.7,
    color = Color3.fromRGB(255, 255, 0),
    targetPart = "HumanoidRootPart",
}

local hitboxConnections = {}

local function expandHitboxes()
    for _, conn in pairs(hitboxConnections) do
        pcall(function() conn:Disconnect() end)
    end
    hitboxConnections = {}

    local function applyHitbox(player)
        if player == LocalPlayer then return end
        local conn
        conn = player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            local part = char:FindFirstChild(hitboxState.targetPart)
            if part and hitboxState.enabled then
                pcall(function()
                    part.Size = Vector3.new(hitboxState.size, hitboxState.size, hitboxState.size)
                    part.Transparency = hitboxState.transparency
                    part.Color = hitboxState.color
                    part.Material = Enum.Material.Neon
                    part.CanCollide = false
                end)
            end
        end)
        if player.Character then
            local char = player.Character
            local part = char:FindFirstChild(hitboxState.targetPart)
            if part and hitboxState.enabled then
                pcall(function()
                    part.Size = Vector3.new(hitboxState.size, hitboxState.size, hitboxState.size)
                    part.Transparency = hitboxState.transparency
                    part.Color = hitboxState.color
                    part.Material = Enum.Material.Neon
                    part.CanCollide = false
                end)
            end
        end
        table.insert(hitboxConnections, conn)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        applyHitbox(player)
    end
    table.insert(hitboxConnections, Players.PlayerAdded:Connect(applyHitbox))
end

local hitboxSection = createSection(combatPage, "Hitbox Expander 命中框")

local hbToggle = createToggle(hitboxSection, "启用命中框扩大", false, function(state)
    hitboxState.enabled = state
    if state then
        expandHitboxes()
    else
        for _, conn in pairs(hitboxConnections) do
            pcall(function() conn:Disconnect() end)
        end
        hitboxConnections = {}
        -- 恢复原始大小
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local part = player.Character:FindFirstChild(hitboxState.targetPart)
                if part then
                    pcall(function()
                        part.Size = Vector3.new(2, 2, 1)
                        part.Transparency = 1
                        part.Material = Enum.Material.Plastic
                        part.CanCollide = true
                    end)
                end
            end
        end
    end
end)

createSlider(hitboxSection, "命中框大小", 1, 50, 10, function(val)
    hitboxState.size = val
    if hitboxState.enabled then expandHitboxes() end
end)

createSlider(hitboxSection, "命中框透明度", 0, 100, 70, function(val)
    hitboxState.transparency = val / 100
    if hitboxState.enabled then expandHitboxes() end
end)

-- Kill Aura
local killAuraState = {
    enabled = false,
    range = 15,
    damage = 20,
    hitSpeed = 0.3,
    teamCheck = true,
}

local killAuraLoop = nil

local function startKillAura()
    if killAuraLoop then killAuraLoop:Stop() end
    killAuraLoop = AntiBan:CreateJitterTimer(killAuraState.hitSpeed, 0.1, function()
        if not killAuraState.enabled then return end
        local lpChar = LocalPlayer.Character
        if not lpChar then return end
        local lpRoot = lpChar:FindFirstChild("HumanoidRootPart")
        if not lpRoot then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if killAuraState.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    continue
                end
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local dist = (root.Position - lpRoot.Position).Magnitude
                        if dist <= killAuraState.range then
                            -- 模拟攻击
                            pcall(function()
                                local args = {
                                    [1] = 1,
                                    [2] = char,
                                    [3] = Vector3.new(root.Position.X, root.Position.Y, root.Position.Z),
                                }
                                -- 尝试常见的 RemoteEvent
                                local remotes = {"Hit", "Attack", "Damage", "Strike", "Punch"}
                                for _, name in ipairs(remotes) do
                                    pcall(function()
                                        local remote = game.ReplicatedStorage:FindFirstChild(name)
                                        if remote and remote:IsA("RemoteEvent") then
                                            remote:FireServer(unpack(args))
                                        end
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
    killAuraLoop:Start()
end

local auraSection = createSection(combatPage, "Kill Aura 范围攻击")

local auraToggle = createToggle(auraSection, "启用 Kill Aura", false, function(state)
    killAuraState.enabled = state
    if state then
        startKillAura()
    elseif killAuraLoop then
        killAuraLoop:Stop()
        killAuraLoop = nil
    end
end)

createSlider(auraSection, "攻击范围", 5, 100, 15, function(val)
    killAuraState.range = val
end)

createSlider(auraSection, "攻击间隔(秒x100)", 10, 100, 30, function(val)
    killAuraState.hitSpeed = val / 100
    if killAuraState.enabled then startKillAura() end
end)

-- ==================== 页面：移动增强 ====================
local movePage = createPage("移动增强", "")

-- Noclip
local noclipState = {enabled = false}
local noclipLoop = nil

local function startNoclip()
    if noclipLoop then noclipLoop:Stop() end
    noclipLoop = AntiBan:CreateRandomLoop(1, 2, function()
        if not noclipState.enabled then return false end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
end

local moveNoclipSection = createSection(movePage, "穿墙 Noclip")

local noclipToggle = createToggle(moveNoclipSection, "启用穿墙", false, function(state)
    noclipState.enabled = state
    if state then
        startNoclip()
    elseif noclipLoop then
        noclipLoop:Stop()
        noclipLoop = nil
        -- 恢复碰撞
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = true end)
                end
            end
        end
    end
end)

-- God Mode
local godModeState = {enabled = false}
local godModeLoop = nil

local function startGodMode()
    if godModeLoop then godModeLoop:Stop() end
    godModeLoop = AntiBan:CreateJitterTimer(0.1, 0.05, function()
        if not godModeState.enabled then return end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.Health = hum.MaxHealth
                end)
                pcall(function()
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end)
            end
        end
    end)
    godModeLoop:Start()
end

local godSection = createSection(movePage, "无敌模式")

local godToggle = createToggle(godSection, "启用无敌", false, function(state)
    godModeState.enabled = state
    if state then
        startGodMode()
    elseif godModeLoop then
        godModeLoop:Stop()
        godModeLoop = nil
        -- 恢复正常血量
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.MaxHealth = 100
                    hum.Health = 100
                end)
            end
        end
    end
end)

-- Infinite Stamina
local staminaState = {enabled = false}
local staminaLoop = nil

local function startStamina()
    if staminaLoop then staminaLoop:Stop() end
    staminaLoop = AntiBan:CreateJitterTimer(0.2, 0.05, function()
        if not staminaState.enabled then return end
        local char = LocalPlayer.Character
        if char then
            pcall(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetAttribute("Stamina") then
                    hum:SetAttribute("Stamina", 100)
                end
            end)
            -- 尝试常见 Stamina 值
            pcall(function()
                local staminaVal = LocalPlayer:FindFirstChild("Stamina")
                if staminaVal and staminaVal:IsA("IntValue") then
                    staminaVal.Value = 100
                end
            end)
        end
    end)
    staminaLoop:Start()
end

local staminaSection = createSection(movePage, "无限体力")

local staminaToggle = createToggle(staminaSection, "启用无限体力", false, function(state)
    staminaState.enabled = state
    if state then
        startStamina()
    elseif staminaLoop then
        staminaLoop:Stop()
        staminaLoop = nil
    end
end)

-- Walk to point
local walkToState = {enabled = false, speed = 16}

local walkSection = createSection(movePage, "自动行走")

createButton(walkSection, "走到鼠标位置", function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or not Camera then return end
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, rp)
    if result then
        hum:MoveTo(result.Position)
        notify("xiaoyi", "正在走向目标位置", 2)
    end
end)

createSlider(walkSection, "行走速度", 16, 100, 16, function(val)
    walkToState.speed = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

createButton(walkSection, "停止行走", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(char:GetPivot().Position) end
    end
end)

-- ==================== 页面：视觉效果 ====================
local visualPage = createPage("视觉效果", "")

-- Fullbright
local fullbrightState = {enabled = false}
local origLighting = {}

local function enableFullbright()
    local lighting = game:GetService("Lighting")
    origLighting.Brightness = lighting.Brightness
    origLighting.ClockTime = lighting.ClockTime
    origLighting.FogEnd = lighting.FogEnd
    origLighting.GlobalShadows = lighting.GlobalShadows
    origLighting.Ambient = lighting.Ambient

    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.fromRGB(178, 178, 178)
end

local function disableFullbright()
    local lighting = game:GetService("Lighting")
    if origLighting.Brightness then lighting.Brightness = origLighting.Brightness end
    if origLighting.ClockTime then lighting.ClockTime = origLighting.ClockTime end
    if origLighting.FogEnd then lighting.FogEnd = origLighting.FogEnd end
    if origLighting.GlobalShadows ~= nil then lighting.GlobalShadows = origLighting.GlobalShadows end
    if origLighting.Ambient then lighting.Ambient = origLighting.Ambient end
    origLighting = {}
end

local visualSection = createSection(visualPage, "光照效果")

local fbToggle = createToggle(visualSection, "全亮 Fullbright", false, function(state)
    fullbrightState.enabled = state
    if state then enableFullbright() else disableFullbright() end
end)

createToggle(visualSection, "移除雾", false, function(state)
    local lighting = game:GetService("Lighting")
    if state then
        lighting.FogEnd = 100000
    else
        lighting.FogEnd = 1000
    end
end)

-- FOV Changer
local fovState = {current = 70}

local fovSection = createSection(visualPage, "视野 FOV")

createSlider(fovSection, "视野角度", 1, 120, 70, function(val)
    fovState.current = val
    pcall(function()
        Camera.FieldOfView = val
    end)
end)

createButton(fovSection, "重置 FOV", function()
    pcall(function() Camera.FieldOfView = 70 end)
    notify("xiaoyi", "FOV 已重置为 70", 2)
end)

-- X-Ray
local xrayState = {enabled = false}

local function setTransparencyRecursive(parent, trans)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("BasePart") then
            if not obj:IsDescendantOf(LocalPlayer.Character or nil) then
                obj.LocalTransparencyModifier = trans
            end
        end
        if #obj:GetChildren() > 0 then
            setTransparencyRecursive(obj, trans)
        end
    end
end

local xraySection = createSection(visualPage, "透视 X-Ray")

local xrayToggle = createToggle(xraySection, "启用 X-Ray", false, function(state)
    xrayState.enabled = state
    if state then
        setTransparencyRecursive(workspace, 0.7)
    else
        setTransparencyRecursive(workspace, 0)
    end
end)

-- Night Vision (增加曝光)
local nvState = {enabled = false}

local nvSection = createSection(visualPage, "夜视")

createToggle(nvSection, "启用夜视", false, function(state)
    nvState.enabled = state
    local lighting = game:GetService("Lighting")
    if state then
        lighting.Brightness = 3
        lighting.ExposureCompensation = 2
        lighting.ClockTime = 0
    else
        lighting.ExposureCompensation = 0
        if not fullbrightState.enabled then
            lighting.Brightness = 1
            lighting.ClockTime = 14
        end
    end
end)

-- ==================== 页面：服务器工具 ====================
local serverPage = createPage("服务器", "")

local serverInfoSection = createSection(serverPage, "服务器信息")

local jobIdLabel = Instance.new("TextLabel")
jobIdLabel.Size = UDim2.new(1, 0, 0, 24)
jobIdLabel.BackgroundTransparency = 1
jobIdLabel.Text = "JobId: " .. tostring(game.JobId)
jobIdLabel.TextColor3 = Theme.TextDim
jobIdLabel.Font = Enum.Font.Gotham
jobIdLabel.TextSize = 12
jobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
jobIdLabel.Parent = serverInfoSection

local placeIdLabel2 = Instance.new("TextLabel")
placeIdLabel2.Size = UDim2.new(1, 0, 0, 24)
placeIdLabel2.BackgroundTransparency = 1
placeIdLabel2.Text = "PlaceId: " .. tostring(game.PlaceId)
placeIdLabel2.TextColor3 = Theme.TextDim
placeIdLabel2.Font = Enum.Font.Gotham
placeIdLabel2.TextSize = 12
placeIdLabel2.TextXAlignment = Enum.TextXAlignment.Left
placeIdLabel2.Parent = serverInfoSection

local playerCountLabel = Instance.new("TextLabel")
playerCountLabel.Size = UDim2.new(1, 0, 0, 24)
playerCountLabel.BackgroundTransparency = 1
playerCountLabel.Text = "玩家数: " .. #Players:GetPlayers()
playerCountLabel.TextColor3 = Theme.Text
playerCountLabel.Font = Enum.Font.Gotham
playerCountLabel.TextSize = 12
playerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
playerCountLabel.Parent = serverInfoSection

-- 自动刷新玩家数
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            playerCountLabel.Text = "玩家数: " .. #Players:GetPlayers()
        end)
    end
end)

local serverActionSection = createSection(serverPage, "服务器操作")

createButton(serverActionSection, "重新加入服务器", function()
    notify("xiaoyi", "正在重新加入...", 2)
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

createButton(serverActionSection, "切换到其他服务器", function()
    notify("xiaoyi", "正在切换服务器...", 2)
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end)

createButton(serverActionSection, "复制 JobId", function()
    pcall(function()
        if setclipboard then
            setclipboard(game.JobId)
            notify("xiaoyi", "JobId 已复制到剪贴板", 2)
        else
            notify("xiaoyi", "JobId: " .. game.JobId, 5)
        end
    end)
end)

createButton(serverActionSection, "复制 PlaceId", function()
    pcall(function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
            notify("xiaoyi", "PlaceId 已复制到剪贴板", 2)
        else
            notify("xiaoyi", "PlaceId: " .. game.PlaceId, 5)
        end
    end)
end)

local serverHopSection = createSection(serverPage, "服务器跳转")
local hopInput = createInputBox(serverHopSection, "输入 PlaceId 跳转...", function(text)
    if text and text ~= "" then
        local pid = tonumber(text)
        if pid then
            notify("xiaoyi", "正在跳转到 PlaceId: " .. pid, 3)
            pcall(function()
                game:GetService("TeleportService"):Teleport(pid, LocalPlayer)
            end)
        end
    end
end)

-- ==================== 页面：Lua执行器 ====================
local execPage = createPage("执行器", "")

local execSection = createSection(execPage, "Lua 代码执行器")

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, 0, 0, 150)
codeBox.BackgroundColor3 = Theme.InputBg
codeBox.Text = ""
codeBox.PlaceholderText = "在此输入 Lua 代码...\n例如: print('Hello')\n或: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100"
codeBox.TextColor3 = Theme.Text
codeBox.PlaceholderColor3 = Theme.TextDim
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 13
codeBox.TextWrapped = true
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.BorderSizePixel = 0
codeBox.Parent = execSection

local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 6)
codeCorner.Parent = codeBox

local codePadding = Instance.new("UIPadding")
codePadding.PaddingLeft = UDim.new(0, 8)
codePadding.PaddingRight = UDim.new(0, 8)
codePadding.PaddingTop = UDim.new(0, 8)
codePadding.PaddingBottom = UDim.new(0, 8)
codePadding.Parent = codeBox

local function executeLua(code)
    if not code or code == "" then
        notify("xiaoyi", "请输入代码", 2)
        return
    end
    local fn, err = loadstring(code)
    if fn then
        local ok, result = pcall(fn)
        if ok then
            notify("xiaoyi", "执行成功", 2)
        else
            notify("xiaoyi", "执行错误: " .. tostring(result), 5)
        end
    else
        notify("xiaoyi", "语法错误: " .. tostring(err), 5)
    end
end

local execBtnRow = Instance.new("Frame")
execBtnRow.Size = UDim2.new(1, 0, 0, 36)
execBtnRow.BackgroundTransparency = 1
execBtnRow.Parent = execSection

local execLayout = Instance.new("UIListLayout")
execLayout.FillDirection = Enum.FillDirection.Horizontal
execLayout.Padding = UDim.new(0, 8)
execLayout.Parent = execBtnRow

local runBtn = Instance.new("TextButton")
runBtn.Size = UDim2.new(0.5, -4, 0, 34)
runBtn.BackgroundColor3 = Theme.Success
runBtn.Text = "执行代码"
runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 13
runBtn.BorderSizePixel = 0
runBtn.Parent = execBtnRow

local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0, 6)
runCorner.Parent = runBtn

runBtn.MouseButton1Click:Connect(function()
    executeLua(codeBox.Text)
end)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.5, -4, 0, 34)
clearBtn.BackgroundColor3 = Theme.Danger
clearBtn.Text = "清空"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 13
clearBtn.BorderSizePixel = 0
clearBtn.Parent = execBtnRow

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    codeBox.Text = ""
end)

-- 快速代码片段
local snippetSection = createSection(execPage, "快速代码片段")

createButton(snippetSection, 'print("Hello World")', function()
    executeLua('print("Hello from xiaoyi Hub!")')
end)

createButton(snippetSection, "速度设为100", function()
    executeLua([[
local p = game.Players.LocalPlayer
local c = p.Character
if c then
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 100 end
end
]])
end)

createButton(snippetSection, "获取所有RemoteEvent", function()
    executeLua([[
local count = 0
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        count = count + 1
    end
end
print("找到 " .. count .. " 个 Remote")
]])
end)

createButton(snippetSection, "显示当前FPS", function()
    executeLua([[
local fps = workspace:GetRealPhysicsFPS()
print("当前FPS: " .. math.floor(fps))
]])
end)

createButton(snippetSection, "获取游戏所有服务", function()
    executeLua([[
local services = {}
pcall(function()
    for _, s in ipairs(game:GetChildren()) do
        table.insert(services, s.Name)
    end
end)
print(table.concat(services, "\n"))
]])
end)

-- ==================== 页面：实用工具 ====================
local utilPage = createPage("实用工具", "")

-- Anti-AFK
local antiAfkState = {enabled = false}
local antiAfkConn = nil

local function startAntiAfk()
    if antiAfkConn then antiAfkConn:Disconnect() end
    antiAfkConn = UserInputService.Idle:Connect(function()
        if antiAfkState.enabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        local bv = Instance.new("BodyAngularVelocity")
                        bv.AngularVelocity = Vector3.new(0, 0.1, 0)
                        bv.MaxTorque = Vector3.new(0, 1e5, 0)
                        bv.Parent = hum.RootPart
                        task.wait(0.1)
                        bv:Destroy()
                    end)
                end
            end
        end
    end)
end

local afkSection = createSection(utilPage, "防挂机 Anti-AFK")

local afkToggle = createToggle(afkSection, "启用防挂机", false, function(state)
    antiAfkState.enabled = state
    if state then
        startAntiAfk()
        notify("xiaoyi", "防挂机已开启", 2)
    elseif antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
end)

-- Auto-Clicker
local autoClickState = {enabled = false, speed = 10}
local autoClickLoop = nil

local function startAutoClick()
    if autoClickLoop then autoClickLoop:Stop() end
    autoClickLoop = AntiBan:CreateJitterTimer(1 / autoClickState.speed, 0.02, function()
        if not autoClickState.enabled then return end
        pcall(function()
            if mouse1click then
                mouse1click()
            elseif tap then
                tap()
            end
        end)
    end)
    autoClickLoop:Start()
end

local clickSection = createSection(utilPage, "自动点击器")

local clickToggle = createToggle(clickSection, "启用自动点击", false, function(state)
    autoClickState.enabled = state
    if state then
        startAutoClick()
    elseif autoClickLoop then
        autoClickLoop:Stop()
        autoClickLoop = nil
    end
end)

createSlider(clickSection, "点击速度(次/秒)", 1, 50, 10, function(val)
    autoClickState.speed = val
    if autoClickState.enabled then startAutoClick() end
end)

-- Rejoin on disconnect
local rejoinState = {enabled = false}

local rejoinSection = createSection(utilPage, "断线重连")

local rejoinToggle = createToggle(rejoinSection, "断线自动重连", false, function(state)
    rejoinState.enabled = state
    if state then
        task.spawn(function()
            while rejoinState.enabled do
                task.wait(5)
                local char = LocalPlayer.Character
                if not char then
                    notify("xiaoyi", "检测到断线，正在重连...", 3)
                    pcall(function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end)
                end
            end
        end)
    end
end)

-- 坐标显示
local coordSection = createSection(utilPage, "坐标显示")

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, 0, 0, 24)
coordLabel.BackgroundTransparency = 1
coordLabel.Text = "X: 0 | Y: 0 | Z: 0"
coordLabel.TextColor3 = Theme.Text
coordLabel.Font = Enum.Font.Code
coordLabel.TextSize = 12
coordLabel.TextXAlignment = Enum.TextXAlignment.Left
coordLabel.Parent = coordSection

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    coordLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
                end
            end
        end)
    end
end)

createButton(coordSection, "复制当前坐标", function()
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            local str = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            pcall(function()
                if setclipboard then setclipboard(str) end
            end)
            notify("xiaoyi", "坐标已复制: " .. str, 3)
        end
    end
end)

-- 计时器
local timerSection = createSection(utilPage, "游戏计时器")

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 30)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00:00"
timerLabel.TextColor3 = Theme.Accent
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 20
timerLabel.TextXAlignment = Enum.TextXAlignment.Center
timerLabel.Parent = timerSection

local startTime = os.time()
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local elapsed = os.time() - startTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            timerLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
        end)
    end
end)

-- FPS 显示
local fpsSection = createSection(utilPage, "FPS 监控")

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 24)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 计算中..."
fpsLabel.TextColor3 = Theme.Success
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsSection

local fpsFrames = 0
local fpsLastTime = os.clock()
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    if now - fpsLastTime >= 1 then
        local fps = math.floor(fpsFrames / (now - fpsLastTime))
        fpsLabel.Text = "FPS: " .. fps
        if fps >= 50 then
            fpsLabel.TextColor3 = Theme.Success
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            fpsLabel.TextColor3 = Theme.Danger
        end
        fpsFrames = 0
        fpsLastTime = now
    end
end)

-- ==================== MobileCoolUI 快捷面板 ====================
local redTacticalGui = nil
local redTacticalVisible = false

local function createRedTacticalPanel()
    if redTacticalGui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileCoolUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = AntiBan:GetSafeParent()
    AntiBan:ProtectGui(screenGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = randomString(10)
    mainFrame.Size = UDim2.new(0, 250, 0, 350)
    mainFrame.Position = UDim2.new(0.55, 0, 0.52, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -65, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = "xiaoyi 快捷面板"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = false
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

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

    local buttonsFrame = Instance.new("ScrollingFrame")
    buttonsFrame.Size = UDim2.new(1, 0, 1, -40)
    buttonsFrame.Position = UDim2.new(0, 0, 0, 40)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.BorderSizePixel = 0
    buttonsFrame.ScrollBarThickness = 3
    buttonsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    buttonsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    buttonsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    buttonsFrame.Parent = mainFrame

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Parent = buttonsFrame
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 8)

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingTop = UDim.new(0, 10)
    btnPadding.PaddingBottom = UDim.new(0, 10)
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.PaddingRight = UDim.new(0, 10)
    btnPadding.Parent = buttonsFrame

    -- 分类标签
    local function createSectionLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = "— " .. text .. " —"
        label.TextColor3 = Color3.fromRGB(160, 160, 160)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = buttonsFrame
        return label
    end

    -- 创建按钮
    local function createButton(name, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextScaled = false
        button.TextSize = 12
        button.BorderSizePixel = 0
        button.Parent = buttonsFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return button
    end

    -- 创建开关按钮（带状态指示）
    local function createToggleBtn(name, defaultState, callback)
        local state = defaultState or false

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = state and Color3.fromRGB(60, 120, 70) or Color3.fromRGB(50, 50, 50)
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextScaled = false
        button.TextSize = 12
        button.BorderSizePixel = 0
        button.Parent = buttonsFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button

        button.MouseEnter:Connect(function()
            local target = state and Color3.fromRGB(75, 140, 85) or Color3.fromRGB(75, 75, 75)
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = target
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            local target = state and Color3.fromRGB(60, 120, 70) or Color3.fromRGB(50, 50, 50)
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = target
            }):Play()
        end)

        button.MouseButton1Click:Connect(function()
            state = not state
            local target = state and Color3.fromRGB(60, 120, 70) or Color3.fromRGB(50, 50, 50)
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = target
            }):Play()
            if callback then callback(state) end
        end)

        return {
            Set = function(val)
                state = val
                button.BackgroundColor3 = state and Color3.fromRGB(60, 120, 70) or Color3.fromRGB(50, 50, 50)
            end,
            Get = function() return state end,
        }
    end

    -- ===== 玩家功能 =====
    createSectionLabel("玩家功能")

    createToggleBtn("速度 50", false, function(state)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = state and 50 or 16
            end
        end
    end)

    createToggleBtn("跳跃 100", false, function(state)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = state and 100 or 50
                hum.JumpHeight = state and 2 or 7.2
            end
        end
    end)

    createToggleBtn("飞天", false, function(state)
        if state then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "CoolUIFly"
                    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = root
                    local bg = Instance.new("BodyGyro")
                    bg.Name = "CoolUIFlyGyro"
                    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                    bg.CFrame = root.CFrame
                    bg.Parent = root

                    local flyConn
                    flyConn = RunService.RenderStepped:Connect(function()
                        local char2 = LocalPlayer.Character
                        if not char2 then flyConn:Disconnect(); return end
                        local root2 = char2:FindFirstChild("HumanoidRootPart")
                        local bv2 = root2 and root2:FindFirstChild("CoolUIFly")
                        if not bv2 then flyConn:Disconnect(); return end
                        local cam = Camera
                        if cam then
                            local dir = Vector3.new(0, 0, 0)
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                            bv2.Velocity = dir * 50
                        end
                    end)
                end
            end
        else
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = root:FindFirstChild("CoolUIFly")
                    local bg = root:FindFirstChild("CoolUIFlyGyro")
                    if bv then bv:Destroy() end
                    if bg then bg:Destroy() end
                end
            end
        end
    end)

    createToggleBtn("穿墙", false, function(state)
        if state then
            noclipState.enabled = true
            startNoclip()
        else
            noclipState.enabled = false
            if noclipLoop then noclipLoop:Stop(); noclipLoop = nil end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
        end
    end)

    createToggleBtn("无敌", false, function(state)
        godModeState.enabled = state
        if state then
            startGodMode()
        elseif godModeLoop then
            godModeLoop:Stop()
            godModeLoop = nil
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum.MaxHealth = 100; hum.Health = 100 end)
                end
            end
        end
    end)

    createToggleBtn("连跳", false, function(state)
        if state then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end)

    -- ===== 战斗 =====
    createSectionLabel("战斗")

    createToggleBtn("Aimbot", false, function(state)
        aimbotState.enabled = state
        if state then startAimbot()
        elseif aimbotLoop then aimbotLoop:Stop(); aimbotLoop = nil end
    end)

    createToggleBtn("ESP 透视", false, function(state)
        espState.boxESP = state
        espState.nameESP = state
        espState.distanceESP = state
        clearAllESP()
        if state then startESPLoop()
        else stopESPLoop() end
    end)

    createToggleBtn("命中框扩大", false, function(state)
        hitboxState.enabled = state
        if state then expandHitboxes()
        else
            for _, conn in pairs(hitboxConnections) do pcall(function() conn:Disconnect() end) end
            hitboxConnections = {}
        end
    end)

    -- ===== 服务器 =====
    createSectionLabel("服务器")

    createButton("重新加入", function()
        notify("xiaoyi", "正在重新加入...", 2)
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)

    createButton("切换服务器", function()
        notify("xiaoyi", "正在切换...", 2)
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end)

    createButton("复制 JobId", function()
        pcall(function()
            if setclipboard then
                setclipboard(game.JobId)
                notify("xiaoyi", "JobId 已复制", 2)
            end
        end)
    end)

    -- ===== 其他 =====
    createSectionLabel("其他")

    createToggleBtn("FPS 提升", false, function(state)
        if state then
            pcall(function()
                settings().Rendering.QualityLevel = 1
                game:GetService("Lighting").GlobalShadows = false
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                game:GetService("Lighting").GlobalShadows = true
            end)
        end
    end)

    createToggleBtn("防挂机", false, function(state)
        antiAfkState.enabled = state
        if state then startAntiAfk()
        elseif antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
    end)

    createButton("打开主菜单", function()
        uiVisible = true
        MainWindow.Visible = true
        TweenService:Create(MainWindow, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 680, 0, 460),
            Position = UDim2.new(0.5, -340, 0.5, -230)
        }):Play()
    end)

    -- 拖动
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
            update(input)
        end
    end)

    -- 最小化
    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 250, 0, 350)
            buttonsFrame.Visible = true
            minimizeButton.Text = "-"
        else
            mainFrame.Size = UDim2.new(0, 250, 0, 40)
            buttonsFrame.Visible = false
            minimizeButton.Text = "+"
        end
        isMinimized = not isMinimized
    end)

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        redTacticalVisible = false
    end)

    redTacticalGui = {
        gui = screenGui,
        window = mainFrame,
        content = buttonsFrame,
        Show = function()
            mainFrame.Visible = true
            redTacticalVisible = true
        end,
        Hide = function()
            mainFrame.Visible = false
            redTacticalVisible = false
        end,
        Toggle = function()
            mainFrame.Visible = not mainFrame.Visible
            redTacticalVisible = mainFrame.Visible
        end,
        IsVisible = function() return redTacticalVisible end,
    }

    return redTacticalGui
end

end -- 结束 ESP+战斗+移动+视觉+服务器+执行器+实用工具 do块

-- ==================== 页面：自动加载 ====================
local autoPage = createPage("自动加载", "")

local autoSection = createSection(autoPage, "游戏检测")

local gameNameLabel = Instance.new("TextLabel")
gameNameLabel.Size = UDim2.new(1, 0, 0, 24)
gameNameLabel.BackgroundTransparency = 1
gameNameLabel.Text = "当前游戏: 检测中..."
gameNameLabel.TextColor3 = Theme.Text
gameNameLabel.Font = Enum.Font.Gotham
gameNameLabel.TextSize = 13
gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
gameNameLabel.Parent = autoSection

local detectedScriptLabel = Instance.new("TextLabel")
detectedScriptLabel.Size = UDim2.new(1, 0, 0, 24)
detectedScriptLabel.BackgroundTransparency = 1
detectedScriptLabel.Text = "匹配脚本: 无"
detectedScriptLabel.TextColor3 = Theme.TextDim
detectedScriptLabel.Font = Enum.Font.Gotham
detectedScriptLabel.TextSize = 13
detectedScriptLabel.TextXAlignment = Enum.TextXAlignment.Left
detectedScriptLabel.Parent = autoSection

local placeIdLabel = Instance.new("TextLabel")
placeIdLabel.Size = UDim2.new(1, 0, 0, 24)
placeIdLabel.BackgroundTransparency = 1
placeIdLabel.Text = "PlaceId: " .. tostring(game.PlaceId)
placeIdLabel.TextColor3 = Theme.TextDim
placeIdLabel.Font = Enum.Font.Gotham
placeIdLabel.TextSize = 13
placeIdLabel.TextXAlignment = Enum.TextXAlignment.Left
placeIdLabel.Parent = autoSection

createButton(autoSection, "重新检测并加载", function()
    notify("xiaoyi", "正在重新检测游戏...", 2)
    task.spawn(function()
        autoLoad()
    end)
end)

local urlSection = createSection(autoPage, "脚本地址配置")
local urlInput = createInputBox(urlSection, "输入脚本仓库地址...", function(text)
    if text and text ~= "" then
        BASE_URL = text
        if not string.find(BASE_URL, "/$") then
            BASE_URL = BASE_URL .. "/"
        end
        notify("xiaoyi", "脚本地址已更新", 2)
    end
end)

-- ==================== 页面：设置 ====================
local settingsPage = createPage("设置", "")

local fpsSection = createSection(settingsPage, "性能优化")

local fpsBoost = createToggle(fpsSection, "FPS 提升", false, function(state)
    if state then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Material == Enum.Material.Glass then
                    v.Material = Enum.Material.Plastic
                end
            end
        end)
        notify("xiaoyi", "FPS 提升已开启", 2)
    end
end)

local removeShadows = createToggle(fpsSection, "移除阴影", false, function(state)
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = not state
    end)
end)

local removeTerrain = createToggle(fpsSection, "降低画质", false, function(state)
    pcall(function()
        game:GetService("Lighting").FogEnd = state and 100 or 100000
    end)
end)

local antiSection = createSection(settingsPage, "防封设置")

local silentModeToggle = createToggle(antiSection, "静默模式", true, function(state)
    if state then
        AntiBan:EnableSilentMode()
    else
        AntiBan:DisableSilentMode()
    end
end)

local randomNamesToggle = createToggle(antiSection, "随机实例名", true, function(state)
    -- 由 AntiBan 自动处理
end)

local guiProtectionToggle = createToggle(antiSection, "GUI 保护", true, function(state)
    -- 由 AntiBan 自动处理
end)

local randomDelayToggle = createToggle(antiSection, "随机启动延迟", true, function(state)
    -- 由 AntiBan 自动处理
end)

local envSection = createSection(settingsPage, "环境信息")
local env = AntiBan:GetEnvironment()
local envText = "执行器: "
if env.isSynapse then envText = envText .. "Synapse" end
if env.isKrnl then envText = envText .. "Krnl" end
if env.isFluxus then envText = envText .. "Fluxus" end
if env.isElectron then envText = envText .. "Electron" end
if envText == "执行器: " then envText = envText .. "未知" end

local envLabel = Instance.new("TextLabel")
envLabel.Size = UDim2.new(1, 0, 0, 24)
envLabel.BackgroundTransparency = 1
envLabel.Text = envText
envLabel.TextColor3 = Theme.TextDim
envLabel.Font = Enum.Font.Gotham
envLabel.TextSize = 13
envLabel.TextXAlignment = Enum.TextXAlignment.Left
envLabel.Parent = envSection

local getHuiLabel = Instance.new("TextLabel")
getHuiLabel.Size = UDim2.new(1, 0, 0, 24)
getHuiLabel.BackgroundTransparency = 1
getHuiLabel.Text = "gethui: " .. (env.hasGetHui and "可用" or "不可用")
getHuiLabel.TextColor3 = env.hasGetHui and Theme.Success or Theme.Danger
getHuiLabel.Font = Enum.Font.Gotham
getHuiLabel.TextSize = 13
getHuiLabel.TextXAlignment = Enum.TextXAlignment.Left
getHuiLabel.Parent = envSection

local uiSection = createSection(settingsPage, "界面设置")

createButton(uiSection, "快捷键: 右Ctrl 显示/隐藏主菜单", function()
    notify("xiaoyi", "按 右Ctrl 显示/隐藏主菜单\n按 右Shift 显示/隐藏快捷面板", 4)
end)

createButton(uiSection, "快捷键: 右Shift 快捷面板", function()
    notify("xiaoyi", "按 右Shift 显示/隐藏快捷面板", 3)
end)

createToggle(uiSection, "启用快捷面板", false, function(state)
    if state then
        if not redTacticalGui then
            createRedTacticalPanel()
        end
        if redTacticalGui then
            redTacticalGui.Show()
        end
    else
        if redTacticalGui then
            redTacticalGui.Hide()
        end
    end
end)

createButton(uiSection, "清理痕迹并卸载", function()
    AntiBan:Cleanup()
end)

-- ==================== 页面：关于 ====================
local aboutPage = createPage("关于", "")

local aboutSection = createSection(aboutPage, nil)

local aboutTitle = Instance.new("TextLabel")
aboutTitle.Size = UDim2.new(1, 0, 0, 40)
aboutTitle.BackgroundTransparency = 1
aboutTitle.Text = "xiaoyi Hub"
aboutTitle.TextColor3 = Theme.Accent
aboutTitle.Font = Enum.Font.GothamBold
aboutTitle.TextSize = 24
aboutTitle.Parent = aboutSection

local aboutSub = Instance.new("TextLabel")
aboutSub.Size = UDim2.new(1, 0, 0, 24)
aboutSub.BackgroundTransparency = 1
aboutSub.Text = "版本: 缝合通用 v2.1 | 2026-09-05"
aboutSub.TextColor3 = Theme.TextDim
aboutSub.Font = Enum.Font.Gotham
aboutSub.TextSize = 13
aboutSub.TextXAlignment = Enum.TextXAlignment.Left
aboutSub.Parent = aboutSection

local spacer1 = Instance.new("Frame")
spacer1.Size = UDim2.new(1, 0, 0, 8)
spacer1.BackgroundTransparency = 1
spacer1.Parent = aboutSection

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, 0, 0, 24)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "制作人：赤急霸"
authorLabel.TextColor3 = Theme.Text
authorLabel.Font = Enum.Font.GothamBold
authorLabel.TextSize = 16
authorLabel.TextXAlignment = Enum.TextXAlignment.Left
authorLabel.Parent = aboutSection

local qqLabel = Instance.new("TextLabel")
qqLabel.Size = UDim2.new(1, 0, 0, 24)
qqLabel.BackgroundTransparency = 1
qqLabel.Text = "QQ：QQ禁止泄露"
qqLabel.TextColor3 = Theme.TextDim
qqLabel.Font = Enum.Font.Gotham
qqLabel.TextSize = 14
qqLabel.TextXAlignment = Enum.TextXAlignment.Left
qqLabel.Parent = aboutSection

local spacer2 = Instance.new("Frame")
spacer2.Size = UDim2.new(1, 0, 0, 8)
spacer2.BackgroundTransparency = 1
spacer2.Parent = aboutSection

local descLabel = Instance.new("TextLabel")
descLabel.Size = UDim2.new(1, 0, 0, 80)
descLabel.BackgroundTransparency = 1
descLabel.Text = "缝合通用脚本 - 集成防封系统、自动加载器、GUI Hub\n收录 78 个游戏脚本，13个功能页面\n包含 ESP/Aimbot/穿墙/无敌/执行器等\n仅供学习交流使用"
descLabel.TextColor3 = Theme.TextDim
descLabel.Font = Enum.Font.Gotham
descLabel.TextSize = 13
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.TextYAlignment = Enum.TextYAlignment.Top
descLabel.Parent = aboutSection

local gamesLabel = Instance.new("TextLabel")
gamesLabel.Size = UDim2.new(1, 0, 0, 24)
gamesLabel.BackgroundTransparency = 1
gamesLabel.Text = "收录游戏: 78 个 | 防封: 14项 | 功能页: 13 个"
gamesLabel.TextColor3 = Theme.Success
gamesLabel.Font = Enum.Font.GothamBold
gamesLabel.TextSize = 14
gamesLabel.TextXAlignment = Enum.TextXAlignment.Left
gamesLabel.Parent = aboutSection

local featureSpacer = Instance.new("Frame")
featureSpacer.Size = UDim2.new(1, 0, 0, 8)
featureSpacer.BackgroundTransparency = 1
featureSpacer.Parent = aboutSection

local featuresLabel = Instance.new("TextLabel")
featuresLabel.Size = UDim2.new(1, 0, 0, 120)
featuresLabel.BackgroundTransparency = 1
featuresLabel.Text = [[
集成模块:
  [1] 防封系统 - 14项保护功能
  [2] 自动加载器 - 游戏检测与脚本匹配
  [3] GUI Hub - 78个游戏脚本菜单
  [4] 玩家功能 - 速度/跳跃/飞天/传送
  [5] ESP透视 - 方框/名称/距离/血量
  [6] 战斗 - Aimbot/命中框/Kill Aura
  [7] 移动增强 - 穿墙/无敌/无限体力
  [8] 视觉效果 - 全亮/FOV/透视/夜视
  [9] 服务器 - 重连/切换/跳转
  [10] Lua执行器 - 代码执行/片段
  [11] 实用工具 - 防挂机/点击器/坐标/FPS
  [12] 设置 - FPS优化/防封开关/环境
]]
featuresLabel.TextColor3 = Theme.TextDim
featuresLabel.Font = Enum.Font.Gotham
featuresLabel.TextSize = 12
featuresLabel.TextXAlignment = Enum.TextXAlignment.Left
featuresLabel.TextYAlignment = Enum.TextYAlignment.Top
featuresLabel.Parent = aboutSection

-- ==================== 拖动功能 ====================
do
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ==================== 关闭/隐藏 ====================
local uiVisible = true

CloseBtn.MouseButton1Click:Connect(function()
    uiVisible = false
    TweenService:Create(MainWindow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.3)
    MainWindow.Visible = false
    notify("xiaoyi", "菜单已隐藏，按 右Ctrl 重新打开", 3)
end)

-- ==================== 快捷键 ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.RightControl then
        uiVisible = not uiVisible
        if uiVisible then
            MainWindow.Visible = true
            MainWindow.Size = UDim2.new(0, 0, 0, 0)
            MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(MainWindow, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 680, 0, 460),
                Position = UDim2.new(0.5, -340, 0.5, -230)
            }):Play()
        else
            TweenService:Create(MainWindow, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            task.wait(0.3)
            MainWindow.Visible = false
        end
    end

    -- 右Shift 切换快捷面板
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not redTacticalGui then
            createRedTacticalPanel()
        end
        if redTacticalGui then
            redTacticalGui.Toggle()
        end
    end
end)

-- ==================== 启动 ====================

-- 默认打开脚本列表页
SidebarButtons["脚本列表"].btn.TextColor3 = Theme.Text
SidebarButtons["脚本列表"].indicator.Visible = true
Pages["脚本列表"].Visible = true
currentPage = "脚本列表"

-- ================================================================
-- >>>>>>>>>> [模块5] 主执行流程 <<<<<<<<<<
-- ================================================================

-- 1. 初始化防封系统
AntiBan:Init()

-- 2. 启动通知
notify("xiaoyi", "制作人：赤急霸\n缝合通用脚本已加载\n按 右Ctrl 显示/隐藏菜单", 5)

-- 3. 后台自动检测并加载游戏脚本
task.spawn(function()
    task.wait(3)

    -- 检测游戏信息
    local gameName = getGameName()
    local scriptFile = findScript(gameName)

    -- 更新自动加载页面信息
    if gameName and gameName ~= "" then
        pcall(function()
            gameNameLabel.Text = "当前游戏: " .. gameName
        end)
    else
        pcall(function()
            gameNameLabel.Text = "当前游戏: 未知"
        end)
    end

    if scriptFile then
        pcall(function()
            detectedScriptLabel.Text = "匹配脚本: " .. scriptFile
            detectedScriptLabel.TextColor3 = Theme.Success
        end)

        -- 自动加载匹配的脚本
        notify("xiaoyi", "检测到游戏: " .. gameName .. "\n正在加载: " .. scriptFile, 4)
        task.wait(1)

        local url = BASE_URL .. scriptFile
        local ok = loadScript(url)

        if ok then
            notify("xiaoyi", scriptFile .. " 加载成功！", 3)
        else
            notify("xiaoyi", scriptFile .. " 加载失败\n请在设置中检查 BASE_URL", 5)
        end
    else
        pcall(function()
            detectedScriptLabel.Text = "匹配脚本: 无 (未找到)"
            detectedScriptLabel.TextColor3 = Theme.Danger
        end)
        notify("xiaoyi", "未检测到匹配的游戏脚本\n可在脚本列表中手动选择", 5)
    end
end)
