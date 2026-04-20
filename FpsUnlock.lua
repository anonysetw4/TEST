--[[
    ╔══════════════════════════════════════════╗
    ║   🔓 FPS UNLOCKER v1.0 — iPad/iOS       ║
    ║   Bypass 60 FPS cap · Delta Compatible   ║
    ╚══════════════════════════════════════════╝
]]

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Cleanup previous
local function cleanOld(name)
    pcall(function()
        local g = player.PlayerGui:FindFirstChild(name)
        if g then g:Destroy() end
    end)
    pcall(function()
        local g = game:GetService("CoreGui"):FindFirstChild(name)
        if g then g:Destroy() end
    end)
    pcall(function()
        if gethui then
            local g = gethui():FindFirstChild(name)
            if g then g:Destroy() end
        end
    end)
end
cleanOld("FPSUnlocker")

-- ══════════════════════════════════════════
-- FPS UNLOCK CORE
-- ══════════════════════════════════════════
local TARGET_FPS = 120  -- Default unlock target
local unlocked = false

local function tryUnlock(cap)
    local success = false
    
    -- Method 1: setfpscap (Delta, Fluxus, Arceus, most iOS executors)
    if setfpscap then
        pcall(function()
            setfpscap(cap)
            success = true
        end)
    end
    
    -- Method 2: Alternate naming conventions
    if not success and set_fps_cap then
        pcall(function()
            set_fps_cap(cap)
            success = true
        end)
    end
    
    -- Method 3: via getgenv
    if not success then
        pcall(function()
            if getgenv and getgenv().setfpscap then
                getgenv().setfpscap(cap)
                success = true
            end
        end)
    end
    
    -- Method 4: Direct FPS cap via settings
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    -- Method 5: TaskScheduler framerate (some executors)
    pcall(function()
        local ts = game:GetService("TaskScheduler")
        if ts then
            ts.SchedulerRate = cap
        end
    end)
    
    return success
end

-- ══════════════════════════════════════════
-- UI Setup
-- ══════════════════════════════════════════
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local gui = Instance.new("ScreenGui")
gui.Name = "FPSUnlocker"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9998

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end)
if not gui.Parent then
    gui.Parent = player.PlayerGui
end

-- ══════════════════════════════════════════
-- MAIN CARD
-- ══════════════════════════════════════════
local card = create("Frame", {
    Name = "Card",
    Size = UDim2.new(0, 180, 0, 200),
    Position = UDim2.new(0.5, -90, 0, 190),
    BackgroundColor3 = Color3.fromRGB(12, 12, 18),
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = card })

-- Shadows
for i = 1, 3 do
    create("ImageLabel", {
        Name = "Shadow" .. i,
        Size = UDim2.new(1, 28 + i * 12, 1, 28 + i * 12),
        Position = UDim2.new(0.5, 0, 0.5, 2 + i),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.55 + i * 0.12,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = card.ZIndex - 1,
        Parent = card,
    })
end

-- Border stroke
local borderStroke = create("UIStroke", {
    Thickness = 1.5,
    Color = Color3.fromHSV(0.55, 0.8, 1),
    Transparency = 0.2,
    Parent = card,
})

-- Glow aura
local glowAura = create("ImageLabel", {
    Name = "GlowAura",
    Size = UDim2.new(1, 50, 1, 50),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromHSV(0.55, 0.8, 1),
    ImageTransparency = 0.85,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    ZIndex = card.ZIndex - 1,
    Parent = card,
})

-- Glass highlight
local glass = create("Frame", {
    Size = UDim2.new(1, -2, 0.4, 0),
    Position = UDim2.new(0, 1, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 1,
    Parent = card,
})
create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = glass })

-- ══════════════════════════════════════════
-- HEADER: Icon + Title
-- ══════════════════════════════════════════
local header = create("Frame", {
    Size = UDim2.new(1, -24, 0, 36),
    Position = UDim2.new(0, 12, 0, 10),
    BackgroundTransparency = 1,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})

local lockIcon = create("TextLabel", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "🔓",
    TextSize = 18,
    Font = Enum.Font.SourceSans,
    ZIndex = card.ZIndex + 3,
    Parent = header,
})

local titleLabel = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 16),
    Position = UDim2.new(0, 28, 0, 2),
    BackgroundTransparency = 1,
    Text = "FPS UNLOCKER",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = header,
})

local subtitleLabel = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 11),
    Position = UDim2.new(0, 28, 0, 19),
    BackgroundTransparency = 1,
    Text = "iPad · Bypass 60 FPS limit",
    TextColor3 = Color3.fromRGB(90, 90, 110),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = header,
})

-- Separator
create("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 48),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})

-- ══════════════════════════════════════════
-- FPS OPTION BUTTONS
-- ══════════════════════════════════════════
local fpsOptions = {120, 144, 165, 240, 0} -- 0 = unlimited
local optionLabels = {"120", "144", "165", "240", "MAX"}
local buttons = {}
local selectedBtn = nil

local btnContainer = create("Frame", {
    Size = UDim2.new(1, -24, 0, 100),
    Position = UDim2.new(0, 12, 0, 56),
    BackgroundTransparency = 1,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})

for i, fps in ipairs(fpsOptions) do
    local row = math.ceil(i / 3)
    local col = ((i - 1) % 3)
    local btnW = 46
    local gap = 7
    local totalW = btnW * 3 + gap * 2
    local offsetX = col * (btnW + gap) + (156 - totalW) / 2

    local btn = create("TextButton", {
        Name = "Btn" .. optionLabels[i],
        Size = UDim2.new(0, btnW, 0, 38),
        Position = UDim2.new(0, offsetX, 0, (row - 1) * 46),
        BackgroundColor3 = Color3.fromRGB(22, 22, 32),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = card.ZIndex + 3,
        Parent = btnContainer,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })

    local btnStroke = create("UIStroke", {
        Thickness = 1,
        Color = Color3.fromRGB(40, 40, 55),
        Transparency = 0.3,
        Parent = btn,
    })

    local btnLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0.5, 0, 0.3, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = optionLabels[i],
        TextColor3 = Color3.fromRGB(180, 180, 195),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = card.ZIndex + 4,
        Parent = btn,
    })

    local btnSub = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0.5, 0, 0.72, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = fps == 0 and "NO CAP" or "FPS",
        TextColor3 = Color3.fromRGB(70, 70, 85),
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        ZIndex = card.ZIndex + 4,
        Parent = btn,
    })

    buttons[i] = {
        frame = btn,
        stroke = btnStroke,
        label = btnLabel,
        sub = btnSub,
        fps = fps,
        displayName = optionLabels[i],
    }

    -- Hover / press feedback
    btn.MouseEnter:Connect(function()
        if selectedBtn ~= i then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 45),
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if selectedBtn ~= i then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(22, 22, 32),
            }):Play()
        end
    end)
end

-- ══════════════════════════════════════════
-- STATUS BAR (bottom)
-- ══════════════════════════════════════════
local statusBar = create("Frame", {
    Size = UDim2.new(1, -24, 0, 28),
    Position = UDim2.new(0, 12, 1, -36),
    BackgroundColor3 = Color3.fromRGB(18, 18, 26),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = statusBar })

local statusDot = create("Frame", {
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(0, 8, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(90, 90, 110),
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 3,
    Parent = statusBar,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = statusDot })

local statusText = create("TextLabel", {
    Size = UDim2.new(1, -22, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    Text = "TAP TO UNLOCK",
    TextColor3 = Color3.fromRGB(100, 100, 120),
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = statusBar,
})

-- ══════════════════════════════════════════
-- BUTTON SELECTION LOGIC
-- ══════════════════════════════════════════
local function selectOption(index)
    local data = buttons[index]
    local cap = data.fps
    
    -- Try to unlock
    local success = tryUnlock(cap)
    unlocked = success
    selectedBtn = index
    
    -- Update all buttons visual state
    for i, b in ipairs(buttons) do
        if i == index then
            -- Selected state: glowing, highlighted
            TweenService:Create(b.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(20, 35, 60),
            }):Play()
            TweenService:Create(b.stroke, TweenInfo.new(0.2), {
                Color = Color3.fromHSV(0.58, 0.8, 1),
                Transparency = 0,
                Thickness = 1.5,
            }):Play()
            TweenService:Create(b.label, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
            TweenService:Create(b.sub, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromHSV(0.58, 0.6, 0.9),
            }):Play()
            
            -- Pop animation
            TweenService:Create(b.frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 49, 0, 40),
            }):Play()
            task.delay(0.1, function()
                TweenService:Create(b.frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 46, 0, 38),
                }):Play()
            end)
        else
            -- Deselected state
            TweenService:Create(b.frame, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(22, 22, 32),
            }):Play()
            TweenService:Create(b.stroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(40, 40, 55),
                Transparency = 0.3,
                Thickness = 1,
            }):Play()
            TweenService:Create(b.label, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(180, 180, 195),
            }):Play()
            TweenService:Create(b.sub, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(70, 70, 85),
            }):Play()
        end
    end
    
    -- Update status bar
    if success then
        local capText = cap == 0 and "UNLIMITED" or (cap .. " FPS")
        statusText.Text = "✓ UNLOCKED → " .. capText
        TweenService:Create(statusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 255, 160),
        }):Play()
        TweenService:Create(statusText, TweenInfo.new(0.3), {
            TextColor3 = Color3.fromRGB(80, 255, 160),
        }):Play()
    else
        statusText.Text = "✗ NOT SUPPORTED"
        TweenService:Create(statusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        }):Play()
        TweenService:Create(statusText, TweenInfo.new(0.3), {
            TextColor3 = Color3.fromRGB(255, 100, 100),
        }):Play()
    end
    
    -- Persistent re-apply loop (game sometimes resets the cap)
    if success then
        task.spawn(function()
            while gui.Parent and selectedBtn == index do
                pcall(function()
                    if setfpscap then setfpscap(cap)
                    elseif set_fps_cap then set_fps_cap(cap)
                    end
                end)
                task.wait(3)
            end
        end)
    end
end

-- Connect button clicks
for i, b in ipairs(buttons) do
    b.frame.MouseButton1Click:Connect(function()
        selectOption(i)
    end)
    
    -- Touch support for iPad
    b.frame.TouchTap:Connect(function()
        selectOption(i)
    end)
end

-- ══════════════════════════════════════════
-- DRAGGABLE
-- ══════════════════════════════════════════
local dragging = false
local dragStart, startPos

-- Only drag from header area
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = card.Position
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(card, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        }):Play()
    end
end)

-- ══════════════════════════════════════════
-- CHROMA ENGINE
-- ══════════════════════════════════════════
local hue = 0

RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * 1.2) % 1
    
    local c = Color3.fromHSV(hue, 0.8, 1)
    
    borderStroke.Color = c
    glowAura.ImageColor3 = c
    
    -- Selected button follows chroma
    if selectedBtn then
        local b = buttons[selectedBtn]
        b.stroke.Color = c
        b.sub.TextColor3 = Color3.fromHSV(hue, 0.5, 0.9)
        b.frame.BackgroundColor3 = Color3.fromHSV(hue, 0.35, 0.15)
    end
    
    -- Status dot pulses when unlocked
    if unlocked then
        local pulse = math.abs(math.sin(tick() * 2))
        statusDot.BackgroundTransparency = pulse * 0.3
    end
end)

-- ══════════════════════════════════════════
-- ENTRANCE ANIMATION
-- ══════════════════════════════════════════
card.BackgroundTransparency = 1
borderStroke.Transparency = 1
glowAura.ImageTransparency = 1
glass.BackgroundTransparency = 1

-- Hide all children text/frames
for _, desc in ipairs(card:GetDescendants()) do
    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
        if desc:IsA("TextLabel") then
            desc.TextTransparency = 1
        end
    end
    if desc:IsA("Frame") and desc.Name ~= "Card" then
        if desc.BackgroundTransparency < 0.9 then
            desc.BackgroundTransparency = 1
        end
    end
end

-- Also hide button frames
for _, b in ipairs(buttons) do
    b.frame.BackgroundTransparency = 1
    b.label.TextTransparency = 1
    b.sub.TextTransparency = 1
    b.stroke.Transparency = 1
end

statusDot.BackgroundTransparency = 1
statusBar.BackgroundTransparency = 1
statusText.TextTransparency = 1

card.Size = UDim2.new(0, 60, 0, 40)
card.Position = UDim2.new(0.5, -30, 0, 200)

task.delay(0.1, function()
    -- Card expands
    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 180, 0, 200),
        Position = UDim2.new(0.5, -90, 0, 190),
        BackgroundTransparency = 0.06,
    }):Play()
    
    TweenService:Create(borderStroke, TweenInfo.new(0.3), { Transparency = 0.2 }):Play()
    TweenService:Create(glowAura, TweenInfo.new(0.4), { ImageTransparency = 0.85 }):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), { BackgroundTransparency = 0.94 }):Play()

    task.delay(0.2, function()
        -- Header
        TweenService:Create(titleLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        TweenService:Create(subtitleLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        TweenService:Create(lockIcon, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    end)

    task.delay(0.3, function()
        -- Buttons stagger in
        for i, b in ipairs(buttons) do
            task.delay(i * 0.06, function()
                TweenService:Create(b.frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0,
                }):Play()
                TweenService:Create(b.label, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
                TweenService:Create(b.sub, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
                TweenService:Create(b.stroke, TweenInfo.new(0.2), { Transparency = 0.3 }):Play()
            end)
        end
    end)

    task.delay(0.6, function()
        -- Status bar
        TweenService:Create(statusBar, TweenInfo.new(0.2), { BackgroundTransparency = 0.3 }):Play()
        TweenService:Create(statusDot, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
        TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    end)
end)

-- ══════════════════════════════════════════
-- AUTO-UNLOCK on load (default 120 FPS)
-- ══════════════════════════════════════════
task.delay(1, function()
    selectOption(1) -- Auto-select 120 FPS
end)

print("🔓 FPS Unlocker loaded — select your target FPS!")
