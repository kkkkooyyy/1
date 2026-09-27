-- ============================================================
--  xiaoyi脚本 · 卡密启动器
--  创作者：赤急霸   团队：赤兔
--  远程卡密 + 设备绑定 + 到期 + 次数限制 + 购买二维码
-- ============================================================

local CONFIG = {
    -- ===== 远程卡密（必改） =====
    REMOTE_KEY_URL  = "https://gist.githubusercontent.com/用户名/GISTID/raw/keys.json",
    CACHE_FILE      = "xiaoyi_keys_cache.json",
    ALLOW_OFFLINE   = true,

    -- ===== 本地记录 =====
    BINDS_FILE      = "xiaoyi_binds.json",
    REMEMBER        = true,
    REMEMBER_FILE   = "xiaoyi_key.txt",

    -- ===== 主脚本（必改） =====
    -- 方式 1：填远程直链
    MAIN_SCRIPT_URL = "",
    -- 方式 2：填内联（不填远程时用，见文末说明）
    MAIN_SCRIPT_INLINE = nil,

    -- ===== 购买（必改 QR） =====
    BUY_URL   = "https://buy.jry0.com/shop/A267SFTX",
    BUY_LABEL = "没有卡密？点击购买",
    BUY_QR    = "rbxassetid://1234567890",

    -- ===== UI 文案 =====
    KICKER      = "xiaoyi脚本",
    TITLE       = "身份验证",
    DESC        = "输入授权密钥以继续",
    PLACEHOLDER = "请输入密钥",
    BTN         = "验  证",
    BLUR        = true,
    DOTS        = 6,
    SPIN        = 0.85,
    RADIUS      = 27,
    SPIN_TIME   = 1.15,
}

local Players  = game:GetService("Players")
local Tween    = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Http     = game:GetService("HttpService")
local UIS      = game:GetService("UserInputService")
local LP       = Players.LocalPlayer
local Camera   = workspace.CurrentCamera

local C = {
    overlay = Color3.fromRGB(8, 8, 10),
    card    = Color3.fromRGB(19, 19, 22),
    field   = Color3.fromRGB(27, 27, 31),
    text    = Color3.fromRGB(236, 236, 240),
    dim     = Color3.fromRGB(118, 118, 126),
    faint   = Color3.fromRGB(58, 58, 64),
    accent  = Color3.fromRGB(236, 236, 240),
    ink     = Color3.fromRGB(18, 18, 21),
    bad     = Color3.fromRGB(198, 106, 106),
    good    = Color3.fromRGB(146, 200, 156),
}

-- ==================== 工具 ====================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function round(inst, r)
    if type(r) == "number" then r = UDim.new(0, r) end
    new("UICorner", { CornerRadius = r or UDim.new(0, 10) }, inst)
    return inst
end
local function tw(inst, time, props, style, delay)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0)
    local t = Tween:Create(inst, info, props); t:Play(); return t
end
local function getParent()
    if gethui then
        local ok, h = pcall(gethui); if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end
local function hasFileAPI()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end
local function norm(s) return tostring(s or ""):gsub("%s+", ""):lower() end
local function jDecode(s)
    local ok, r = pcall(function() return Http:JSONDecode(s) end)
    if ok and r then return r end
    ok, r = pcall(function() return game:GetService("HttpService"):JSONDecode(s) end)
    if ok then return r end
    return nil
end
local function jEncode(t)
    local ok, r = pcall(function() return Http:JSONEncode(t) end)
    if ok and r then return r end
    ok, r = pcall(function() return game:GetService("HttpService"):JSONEncode(t) end)
    if ok then return r end
    return "{}"
end
local function copyToClipboard(text)
    return pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        elseif syn and syn.setclipboard then syn.setclipboard(text)
        elseif type(set_clipboard) == "function" then set_clipboard(text) end
    end)
end

-- ==================== 设备指纹 ====================
local DEVICE_ID
local function getDeviceId()
    if DEVICE_ID then return DEVICE_ID end
    local parts = {
        tostring(LP.UserId or 0),
        tostring(game.PlaceId or 0),
        tostring(LP.AccountAge or 0),
        tostring(UIS:GetPlatform()),
    }
    local s = table.concat(parts, "|")
    local h = 5381
    for i = 1, #s do
        h = ((h * 33) + s:byte(i)) % 2147483647
    end
    DEVICE_ID = string.format("%08x", h)
    return DEVICE_ID
end

-- ==================== 卡密存储 ====================
local KeyStore = { keys = {}, source = "none" }
local Binds    = {}

local function parseKeys(raw)
    local data = jDecode(raw)
    if type(data) ~= "table" then return nil end
    local list = data.keys or data
    if type(list) ~= "table" then return nil end
    local store = {}
    for _, item in ipairs(list) do
        if type(item) == "string" then
            store[norm(item)] = { exp = "never" }
        elseif type(item) == "table" and item.k then
            store[norm(item.k)] = { exp = item.exp or "never", note = item.note }
        end
    end
    return store
end
local function saveCache(raw)
    if not hasFileAPI() then return end
    pcall(writefile, CONFIG.CACHE_FILE, jEncode({ ts = os.time(), raw = raw }))
end
local function loadCache()
    if not hasFileAPI() or not isfile(CONFIG.CACHE_FILE) then return nil end
    local ok, content = pcall(readfile, CONFIG.CACHE_FILE)
    if not ok or not content then return nil end
    local data = jDecode(content)
    if type(data) ~= "table" or not data.raw then return nil end
    return data
end
local function fetchRemote()
    local ok, raw = pcall(function() return game:HttpGet(CONFIG.REMOTE_KEY_URL) end)
    if not ok or type(raw) ~= "string" or #raw < 2 then return nil end
    return raw
end
local function refreshKeys()
    local raw = fetchRemote()
    if raw then
        local store = parseKeys(raw)
        if store and next(store) ~= nil then
            KeyStore.keys = store; KeyStore.source = "remote"
            saveCache(raw)
            return true
        end
    end
    if CONFIG.ALLOW_OFFLINE then
        local cache = loadCache()
        if cache then
            local store = parseKeys(cache.raw)
            if store and next(store) ~= nil then
                KeyStore.keys = store; KeyStore.source = "cache"
                return true
            end
        end
    end
    return false
end

-- ==================== 本地绑定 ====================
local function loadBinds()
    if not hasFileAPI() or not isfile(CONFIG.BINDS_FILE) then return end
    local ok, content = pcall(readfile, CONFIG.BINDS_FILE)
    if not ok or not content then return end
    local data = jDecode(content)
    if type(data) == "table" then Binds = data end
end
local function saveBinds()
    if not hasFileAPI() then return end
    pcall(writefile, CONFIG.BINDS_FILE, jEncode(Binds))
end

-- ==================== 卡密校验 ====================
local function isKeyValid(input)
    local n = norm(input)
    if n == "" then return false, "空卡密" end
    local info = KeyStore.keys[n]
    if not info then return false, "卡密不存在" end

    local exp = tostring(info.exp or "never")

    if exp ~= "never" and not exp:find(":") then
        local y, m, d = exp:match("(%d+)-(%d+)-(%d+)")
        if y then
            local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 23, min = 59, sec = 59 })
            if os.time() > t then return false, "卡密已过期" end
        end
    end

    local bind = Binds[n]
    local deviceId = getDeviceId()

    if bind then
        if bind.device and bind.device ~= deviceId then
            return false, "卡密已绑定其他设备"
        end
        local dayMatch = exp:match("^days:(%d+)$")
        if dayMatch then
            local days = tonumber(dayMatch)
            local elapsed = (os.time() - (tonumber(bind.activatedAt) or os.time())) / 86400
            if elapsed > days then return false, "卡密已到期" end
        end
        local useMatch = exp:match("^uses:(%d+)$")
        if useMatch then
            local limit = tonumber(useMatch)
            if (tonumber(bind.uses) or 0) >= limit then return false, "卡密次数已用完" end
        end
    end

    return true
end

local function activateKey(input)
    local n = norm(input)
    local deviceId = getDeviceId()
    if not Binds[n] then
        Binds[n] = { device = deviceId, activatedAt = os.time(), uses = 0 }
    end
    Binds[n].device   = Binds[n].device or deviceId
    Binds[n].uses     = (tonumber(Binds[n].uses) or 0) + 1
    Binds[n].lastUsed = os.time()
    saveBinds()
end

-- ==================== 主脚本加载 ====================
local function loadMainScript()
    if CONFIG.MAIN_SCRIPT_URL and CONFIG.MAIN_SCRIPT_URL ~= "" then
        local ok, err = pcall(function()
            local src = game:HttpGet(CONFIG.MAIN_SCRIPT_URL)
            loadstring(src)()
        end)
        if ok then return end
        warn("[xiaoyi] 主脚本远程加载失败: " .. tostring(err))
    end
    if CONFIG.MAIN_SCRIPT_INLINE then
        local ok, err = pcall(function()
            loadstring(CONFIG.MAIN_SCRIPT_INLINE)()
        end)
        if not ok then
            warn("[xiaoyi] 内联主脚本执行失败: " .. tostring(err))
        end
    else
        warn("[xiaoyi] 未配置 MAIN_SCRIPT_URL 或 MAIN_SCRIPT_INLINE，主脚本未加载")
    end
end

-- ==================== 验证成功 ====================
local function onSuccess()
    print(" xiaoyi脚本 卡密验证通过 ✔  (来源: " .. KeyStore.source .. ")")
    task.spawn(loadMainScript)

    local g = new("ScreenGui", {
        Name = "case_unlocked", IgnoreGuiInset = true,
        ResetOnSpawn = false, DisplayOrder = 9999, Parent = getParent(),
    })
    local pill = new("Frame", {
        Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(210, 38),
        BackgroundColor3 = C.card, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = g,
    })
    round(pill, 10)
    local st = new("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255), Transparency = 1, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = pill,
    })
    local dot = new("Frame", {
        Position = UDim2.fromOffset(15, 15), Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = C.good, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pill,
    })
    round(dot, UDim.new(1, 0))
    local lbl = new("TextLabel", {
        Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "已解锁  ·  xiaoyi脚本", TextTransparency = 1, Parent = pill,
    })
    tw(pill, 0.3, { BackgroundTransparency = 0 })
    tw(st, 0.3, { Transparency = 0.86 })
    tw(dot, 0.3, { BackgroundTransparency = 0 })
    tw(lbl, 0.3, { TextTransparency = 0 })
    task.delay(2.6, function()
        tw(pill, 0.35, { BackgroundTransparency = 1 })
        tw(st, 0.35, { Transparency = 1 })
        tw(dot, 0.35, { BackgroundTransparency = 1 })
        tw(lbl, 0.35, { TextTransparency = 1 })
        task.wait(0.45); g:Destroy()
    end)
end

-- ==================== 验证 UI ====================
local function startKeyCheck(done)
    local gui = new("ScreenGui", {
        Name = "case_verify", IgnoreGuiInset = true, ResetOnSpawn = false,
        DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = getParent(),
    })
    local overlay = new("Frame", {
        Name = "Overlay", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.overlay, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 1, Parent = gui,
    })
    local scaleObj = new("UIScale", { Scale = 1, Parent = overlay })
    local function updateScale() scaleObj.Scale = math.clamp(Camera.ViewportSize.X / 440, 0.7, 1) end
    updateScale()
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

    local card = new("Frame", {
        Name = "Card", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 300),
        BackgroundColor3 = C.card, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 2, Parent = overlay,
    })
    round(card, 16)
    local cardStroke = new("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card,
    })

    local pad = new("Frame", {
        Size = UDim2.new(1, -56, 1, -52), Position = UDim2.fromOffset(28, 26),
        BackgroundTransparency = 1, ZIndex = 3, Parent = card,
    })
    local mark = new("Frame", { Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, ZIndex = 3, Parent = pad })
    local bars = {}
    for _, ang in ipairs({ 0, 60, 120 }) do
        local bar = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 2), BackgroundColor3 = C.dim, BackgroundTransparency = 1,
            BorderSizePixel = 0, Rotation = 0, ZIndex = 3, Parent = mark,
        })
        round(bar, UDim.new(1, 0))
        table.insert(bars, { bar = bar, ang = ang })
    end
    local kicker = new("TextLabel", {
        Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -28, 0, 18),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = CONFIG.KICKER, TextTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local title = new("TextLabel", {
        Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 24,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = CONFIG.TITLE, TextTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local desc = new("TextLabel", {
        Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = CONFIG.DESC, TextTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local div = new("Frame", {
        Position = UDim2.fromOffset(0, 98), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 3, Parent = pad,
    })
    local field = new("Frame", {
        Position = UDim2.fromOffset(0, 114), Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.field, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 3, Parent = pad,
    })
    round(field, 10)
    local fieldStroke = new("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = field,
    })
    local box = new("TextBox", {
        Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15,
        TextColor3 = C.text, Text = "", PlaceholderText = CONFIG.PLACEHOLDER,
        PlaceholderColor3 = C.faint, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
        ZIndex = 4, Parent = field,
    })
    local btnWrap = new("Frame", {
        Position = UDim2.fromOffset(0, 174), Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local btn = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.accent, BackgroundTransparency = 1,
        Text = CONFIG.BTN, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = C.ink, TextTransparency = 1, AutoButtonColor = false,
        ZIndex = 4, Parent = btnWrap,
    })
    local btnCorner = new("UICorner", { CornerRadius = UDim.new(0, 10) }, btn)
    local btnScale  = new("UIScale", { Scale = 1, Parent = btn })
    local check = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 24, Text = "✓",
        TextColor3 = C.ink, TextTransparency = 1, ZIndex = 7, Parent = btn,
    })
    local checkScale = new("UIScale", { Scale = 0.7, Parent = check })
    local spin = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
        ZIndex = 6, Parent = btnWrap,
    })
    local status = new("TextLabel", {
        Position = UDim2.fromOffset(0, 228), Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "等待输入…", TextTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local hint = new("TextLabel", {
        Position = UDim2.fromOffset(0, 228), Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.faint, TextXAlignment = Enum.TextXAlignment.Right,
        Text = "ENTER ", TextTransparency = 1, ZIndex = 3, Parent = pad,
    })
    local buyBtn = new("TextButton", {
        Position = UDim2.fromOffset(0, 252), Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Center,
        Text = CONFIG.BUY_LABEL, TextTransparency = 1,
        AutoButtonColor = false, ZIndex = 3, Parent = pad,
    })
    buyBtn.MouseEnter:Connect(function() tw(buyBtn, 0.15, { TextColor3 = C.text }) end)
    buyBtn.MouseLeave:Connect(function() tw(buyBtn, 0.15, { TextColor3 = C.dim }) end)

    local blur
    if CONFIG.BLUR then
        blur = new("BlurEffect", { Size = 0, Parent = Lighting })
        tw(blur, 0.5, { Size = 14 })
    end

    tw(overlay, 0.35, { BackgroundTransparency = 0.45 })
    tw(card, 0.5, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
    tw(cardStroke, 0.5, { Transparency = 0.86 })
    for i, b in ipairs(bars) do
        tw(b.bar, 0.5, { Rotation = b.ang, BackgroundTransparency = 0.45 }, Enum.EasingStyle.Quint, i * 0.06)
    end
    task.delay(0.12, function()
        tw(kicker, 0.4, { TextTransparency = 0.25 })
        tw(title, 0.45, { TextTransparency = 0 })
        tw(desc, 0.45, { TextTransparency = 0 }, nil, 0.06)
        tw(div, 0.45, { BackgroundTransparency = 0.9 }, nil, 0.1)
        tw(field, 0.45, { BackgroundTransparency = 0 })
        tw(fieldStroke, 0.45, { Transparency = 0.9 })
        tw(box, 0.45, { TextTransparency = 0 })
        tw(btn, 0.45, { BackgroundTransparency = 0 }, nil, 0.08)
        tw(btn, 0.45, { TextTransparency = 0 }, nil, 0.08)
        tw(status, 0.45, { TextTransparency = 0.1 }, nil, 0.14)
        tw(hint, 0.45, { TextTransparency = 0.5 }, nil, 0.14)
        tw(buyBtn, 0.45, { TextTransparency = 0.15 }, nil, 0.18)
    end)

    -- ===== 二维码弹窗 =====
    local qrOverlay = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100, Visible = false,
        Parent = overlay,
    })
    local qrCard = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 380), BackgroundColor3 = C.card,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 101, Parent = qrOverlay,
    })
    round(qrCard, 16)
    local qrStroke = new("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255), Transparency = 1, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = qrCard,
    })
    local qrTitle = new("TextLabel", {
        Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 17,
        TextColor3 = C.text, Text = "扫码购买", TextTransparency = 1, ZIndex = 102, Parent = qrCard,
    })
    local qrSub = new("TextLabel", {
        Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = C.dim, Text = "手机扫码 或 复制链接打开", TextTransparency = 1, ZIndex = 102, Parent = qrCard,
    })
    local qrFrame = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 72),
        Size = UDim2.fromOffset(200, 200), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 102, Parent = qrCard,
    })
    round(qrFrame, 12)
    local qrImg = new("ImageLabel", {
        Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1, Image = CONFIG.BUY_QR,
        ImageTransparency = 1, ZIndex = 103, Parent = qrFrame,
    })
    local urlBox = new("TextLabel", {
        Position = UDim2.fromOffset(20, 284), Size = UDim2.new(1, -40, 0, 30),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = C.dim, Text = CONFIG.BUY_URL, TextWrapped = true,
        TextTransparency = 1, ZIndex = 102, Parent = qrCard,
    })
    local copyBtn = new("TextButton", {
        Position = UDim2.fromOffset(20, 322), Size = UDim2.new(0.5, -26, 0, 34),
        BackgroundColor3 = C.accent, BackgroundTransparency = 1,
        Text = "复制链接", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.ink, TextTransparency = 1, AutoButtonColor = false,
        ZIndex = 102, Parent = qrCard,
    })
    round(copyBtn, 8)
    local closeQrBtn = new("TextButton", {
        Position = UDim2.fromOffset(150, 322), Size = UDim2.new(0.5, -26, 0, 34),
        BackgroundColor3 = C.field, BackgroundTransparency = 1,
        Text = "关闭", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.text, TextTransparency = 1, AutoButtonColor = false,
        ZIndex = 102, Parent = qrCard,
    })
    round(closeQrBtn, 8)

    local qrOpen = false
    local function openQr()
        if qrOpen then return end
        qrOpen = true
        qrOverlay.Visible = true
        tw(qrOverlay, 0.25, { BackgroundTransparency = 0.35 })
        tw(qrCard, 0.35, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
        tw(qrStroke, 0.35, { Transparency = 0.86 })
        tw(qrTitle, 0.35, { TextTransparency = 0 }, nil, 0.05)
        tw(qrSub, 0.35, { TextTransparency = 0.2 }, nil, 0.08)
        tw(qrFrame, 0.35, { BackgroundTransparency = 0 }, nil, 0.1)
        tw(qrImg, 0.35, { ImageTransparency = 0 }, nil, 0.12)
        tw(urlBox, 0.35, { TextTransparency = 0.2 }, nil, 0.15)
        tw(copyBtn, 0.35, { BackgroundTransparency = 0 }, nil, 0.18)
        tw(copyBtn, 0.35, { TextTransparency = 0 }, nil, 0.18)
        tw(closeQrBtn, 0.35, { BackgroundTransparency = 0 }, nil, 0.2)
        tw(closeQrBtn, 0.35, { TextTransparency = 0 }, nil, 0.2)
    end
    local function closeQr()
        if not qrOpen then return end
        qrOpen = false
        tw(qrOverlay, 0.2, { BackgroundTransparency = 1 })
        tw(qrCard, 0.2, { BackgroundTransparency = 1 })
        tw(qrStroke, 0.2, { Transparency = 1 })
        tw(qrTitle, 0.2, { TextTransparency = 1 })
        tw(qrSub, 0.2, { TextTransparency = 1 })
        tw(qrFrame, 0.2, { BackgroundTransparency = 1 })
        tw(qrImg, 0.2, { ImageTransparency = 1 })
        tw(urlBox, 0.2, { TextTransparency = 1 })
        tw(copyBtn, 0.2, { BackgroundTransparency = 1 }); tw(copyBtn, 0.2, { TextTransparency = 1 })
        tw(closeQrBtn, 0.2, { BackgroundTransparency = 1 }); tw(closeQrBtn, 0.2, { TextTransparency = 1 })
        task.delay(0.25, function() qrOverlay.Visible = false end)
    end
    copyBtn.MouseButton1Click:Connect(function()
        local ok = copyToClipboard(CONFIG.BUY_URL)
        copyBtn.Text = ok and "已复制 ✔" or "复制失败"
        tw(copyBtn, 0.15, { BackgroundColor3 = ok and C.good or C.bad })
        task.delay(1.2, function()
            copyBtn.Text = "复制链接"
            tw(copyBtn, 0.25, { BackgroundColor3 = C.accent })
        end)
    end)
    closeQrBtn.MouseButton1Click:Connect(closeQr)
    buyBtn.MouseButton1Click:Connect(function()
        openQr()
        task.spawn(function()
            local ok = copyToClipboard(CONFIG.BUY_URL)
            if ok then setStatus("购买链接已复制，可扫码或粘贴打开", C.good)
            else setStatus("请扫码购买", C.dim) end
            task.delay(2, function()
                if status.Text == "购买链接已复制，可扫码或粘贴打开" then
                    setStatus("等待输入…", C.dim)
                end
            end)
        end)
    end)

    -- ===== 状态 =====
    local busy = false
    local function setStatus(text, color) status.Text = text; status.TextColor3 = color or C.dim end

    local shaking = false
    local function shake()
        if shaking then return end
        shaking = true
        local seq = { 0.013, -0.013, 0.009, -0.009, 0.005, 0 }
        for i, dx in ipairs(seq) do
            task.delay(i * 0.045, function()
                tw(card, 0.06, { Position = UDim2.new(0.5 + dx, 0, 0.5, 0) }, Enum.EasingStyle.Linear)
            end)
        end
        task.delay(#seq * 0.045 + 0.12, function() shaking = false end)
    end
    local flashToken = 0
    local function flash(color)
        flashToken = flashToken + 1
        local mine = flashToken
        fieldStroke.Color = color; fieldStroke.Transparency = 0.35
        task.delay(0.9, function()
            if mine ~= flashToken then return end
            fieldStroke.Color = Color3.fromRGB(255, 255, 255)
            tw(fieldStroke, 0.4, { Transparency = 0.9 })
        end)
    end
    local spinActive, spinTween = false, nil
    local function stopSpin()
        spinActive = false
        if spinTween then pcall(function() spinTween:Cancel() end); spinTween = nil end
    end
    local function startSpin()
        stopSpin(); spinActive = true
        task.spawn(function()
            while spinActive do
                if not spin.Parent then break end
                local cur = spin.Rotation % 360
                spin.Rotation = cur - 360
                local okT, t = pcall(function()
                    return tw(spin, CONFIG.SPIN, { Rotation = cur }, Enum.EasingStyle.Linear)
                end)
                if not okT or not t then break end
                spinTween = t
                local okW = pcall(function() t.Completed:Wait() end)
                spinTween = nil
                if not okW then break end
            end
            spinActive = false
        end)
    end
    local function clearDots()
        for _, d in ipairs(spin:GetChildren()) do
            if d:IsA("Frame") then d:Destroy() end
        end
    end
    local function fadeOut()
        stopSpin()
        for _, d in ipairs(pad:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextBox") then tw(d, 0.3, { TextTransparency = 1 })
            elseif d:IsA("Frame") then tw(d, 0.3, { BackgroundTransparency = 1 })
            elseif d:IsA("UIStroke") then tw(d, 0.3, { Transparency = 1 }) end
        end
        tw(card, 0.4, { BackgroundTransparency = 1 })
        tw(cardStroke, 0.4, { Transparency = 1 })
        tw(overlay, 0.4, { BackgroundTransparency = 1 })
        if blur then tw(blur, 0.4, { Size = 0 }) end
        task.wait(0.45)
        if blur then blur:Destroy() end
        gui:Destroy()
    end

    local function playMorph(success, reason)
        busy = true
        box.TextEditable = false
        stopSpin(); clearDots(); spin.Rotation = 0
        check.Text = success and "✓" or "X"
        check.TextTransparency = 1
        checkScale.Scale = 0.7
        setStatus("验证中…", C.dim)

        tw(btn, 0.14, { TextTransparency = 1 }, Enum.EasingStyle.Sine)
        task.wait(0.16)
        tw(btn, 0.40, { Size = UDim2.new(0, 44, 0, 44) }, Enum.EasingStyle.Quint)
        tw(btnCorner, 0.40, { CornerRadius = UDim.new(1, 0) }, Enum.EasingStyle.Quint)
        task.wait(0.42)
        tw(btnScale, 0.15, { Scale = 1.14 }, Enum.EasingStyle.Sine)
        task.wait(0.15)
        tw(btnScale, 0.26, { Scale = 1 }, Enum.EasingStyle.Sine)

        local dots = {}
        for i = 1, CONFIG.DOTS do
            local rad = math.rad((i - 1) * (360 / CONFIG.DOTS))
            local dot = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromOffset(math.cos(rad) * CONFIG.RADIUS, math.sin(rad) * CONFIG.RADIUS),
                Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.accent,
                BackgroundTransparency = 0, BorderSizePixel = 0,
                ZIndex = 6, Parent = spin,
            })
            round(dot, UDim.new(1, 0))
            local s = new("UIScale", { Scale = 0, Parent = dot })
            tw(s, 0.28, { Scale = 1 }, Enum.EasingStyle.Back, i * 0.05)
            table.insert(dots, dot)
        end
        startSpin()
        task.wait(CONFIG.SPIN_TIME)

        if success then
            stopSpin()
            for _, d in ipairs(dots) do
                tw(d, 0.32, {
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromOffset(0, 0),
                    BackgroundColor3 = C.good,
                }, Enum.EasingStyle.Quint)
            end
            tw(btn, 0.32, { BackgroundColor3 = C.good })
            task.wait(0.18)
            tw(check, 0.26, { TextTransparency = 0 }, Enum.EasingStyle.Back)
            tw(checkScale, 0.32, { Scale = 1 }, Enum.EasingStyle.Back)
            setStatus("验证通过", C.good)
            activateKey(box.Text)
            if CONFIG.REMEMBER and hasFileAPI() then
                pcall(writefile, CONFIG.REMEMBER_FILE, norm(box.Text))
            end
            task.wait(0.75)
            fadeOut()
            if done then done() end
        else
            for _, d in ipairs(dots) do
                tw(d, 0.24, { BackgroundColor3 = C.bad, Size = UDim2.fromOffset(11, 11) })
            end
            tw(btn, 0.22, { BackgroundColor3 = C.bad })
            task.wait(0.2)
            tw(check, 0.22, { TextTransparency = 0 }, Enum.EasingStyle.Back)
            tw(checkScale, 0.26, { Scale = 1 }, Enum.EasingStyle.Back)
            setStatus(reason or "密钥无效", C.bad)
            task.wait(0.55)
            tw(check, 0.16, { TextTransparency = 1 })
            tw(checkScale, 0.16, { Scale = 0.6 })
            for _, d in ipairs(dots) do
                local p = d.Position
                tw(d, 0.32, {
                    Position = UDim2.fromOffset(p.X.Offset * 1.9, p.Y.Offset * 1.9),
                    Size = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                }, Enum.EasingStyle.Quint)
            end
            task.wait(0.3)
            stopSpin(); clearDots(); spin.Rotation = 0
            tw(btn, 0.36, { BackgroundColor3 = C.accent, Size = UDim2.new(1, 0, 0, 44) }, Enum.EasingStyle.Quint)
            tw(btnCorner, 0.36, { CornerRadius = UDim.new(0, 10) }, Enum.EasingStyle.Quint)
            task.wait(0.38)
            tw(btn, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
            flash(C.bad); shake()
            setStatus((reason or "密钥无效") .. " · 请重试", C.bad)
            tw(buyBtn, 0.2, { TextColor3 = C.bad })
            task.delay(1.0, function()
                tw(buyBtn, 0.35, { TextColor3 = C.dim })
            end)
            box.TextEditable = true
            busy = false
        end
    end

    local verify
    box.Focused:Connect(function() tw(fieldStroke, 0.2, { Transparency = 0.7 }) end)
    box.FocusLost:Connect(function(enter)
        tw(fieldStroke, 0.2, { Transparency = 0.9 })
        if enter and verify then verify() end
    end)
    btn.MouseEnter:Connect(function() if not busy then tw(btn, 0.16, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end end)
    btn.MouseLeave:Connect(function() if not busy then tw(btn, 0.16, { BackgroundColor3 = C.accent }) end end)
    btn.MouseButton1Down:Connect(function() if not busy then tw(btn, 0.08, { BackgroundColor3 = Color3.fromRGB(206, 206, 212) }) end end)
    btn.MouseButton1Up:Connect(function() if not busy then tw(btn, 0.12, { BackgroundColor3 = C.accent }) end end)
    btn.MouseButton1Click:Connect(function() if verify then verify() end)

    verify = function()
        if busy then return end
        local v = norm(box.Text)
        if v == "" then
            setStatus("请先输入密钥", C.dim)
            shake(); flash(C.bad)
            return
        end
        local ok, reason = isKeyValid(v)
        playMorph(ok, reason)
    end
end

-- ==================== 缓存卡密检查 ====================
local function hasCachedKey()
    if not (CONFIG.REMEMBER and hasFileAPI()) then return false end
    local ok, saved = pcall(function()
        if isfile(CONFIG.REMEMBER_FILE) then return readfile(CONFIG.REMEMBER_FILE) end
    end)
    if not (ok and type(saved) == "string") then return false end
    return isKeyValid(saved)
end

-- ==================== 启动 ====================
loadBinds()
local ok = refreshKeys()
if not ok then
    warn("[xiaoyi] 无法获取卡密列表（远程+缓存均失败）")
end

if hasCachedKey() then
    print(" 已记住有效卡密, 跳过验证")
    if hasFileAPI() then
        local saved = readfile(CONFIG.REMEMBER_FILE)
        if saved then activateKey(saved) end
    end
    onSuccess()
else
    startKeyCheck(onSuccess)
end