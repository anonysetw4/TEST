--[[
    ╔══════════════════════════════════════════════╗
    ║   ⚡ ULTRA PREMIUM FPS COUNTER v2.0          ║
    ║   Chroma · Draggable · Real-Time · iPad      ║
    ║   Glassmorphism + Pulse Ring + FPS Graph      ║
    ╚══════════════════════════════════════════════╝
]]

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Cleanup
local old = player.PlayerGui:FindFirstChild("UltraFPSv2")
if old then old:Destroy() end
pcall(function()
    local cg = game:GetService("CoreGui"):FindFirstChild("UltraFPSv2")
    if cg then cg:Destroy() end
end)
pcall(function()
    if gethui then
        local h = gethui():FindFirstChild("UltraFPSv2")
        if h then h:Destroy() end
    end
end)

-- ══════════════════════════════════════════
-- Config
-- ══════════════════════════════════════════
local CFG = {
    ChromaSpeed     = 1.2,
    SampleRate      = 0.35,
    GraphBars       = 30,
    GraphHeight     = 28,
    PulseSpeed      = 2.5,
}

-- ══════════════════════════════════════════
-- ScreenGui
-- ══════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "UltraFPSv2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999

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
-- Utility: Create Instance with properties
-- ══════════════════════════════════════════
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- ══════════════════════════════════════════
-- MAIN CARD
-- ══════════════════════════════════════════
local card = create("Frame", {
    Name = "Card",
    Size = UDim2.new(0, 200, 0, 120),
    Position = UDim2.new(0.5, -100, 0, 50),
    BackgroundColor3 = Color3.fromRGB(10, 10, 16),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = gui,
})

create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = card })

-- ══════════════════════════════════════════
-- SHADOW LAYERS (depth)
-- ══════════════════════════════════════════
for i = 1, 3 do
    local shadow = create("ImageLabel", {
        Name = "Shadow" .. i,
        Size = UDim2.new(1, 30 + i * 14, 1, 30 + i * 14),
        Position = UDim2.new(0.5, 0, 0.5, 2 + i * 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6 + i * 0.1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = card.ZIndex - 1,
        Parent = card,
    })
end

-- ══════════════════════════════════════════
-- CHROMA BORDER (outer glow stroke)
-- ══════════════════════════════════════════
local chromaStroke = create("UIStroke", {
    Name = "ChromaStroke",
    Thickness = 1.5,
    Color = Color3.fromHSV(0, 0.9, 1),
    Transparency = 0.15,
    Parent = card,
})

-- ══════════════════════════════════════════
-- CHROMA GLOW (soft colored aura behind card)
-- ══════════════════════════════════════════
local chromaGlow = create("ImageLabel", {
    Name = "ChromaGlow",
    Size = UDim2.new(1, 60, 1, 60),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromHSV(0, 0.9, 1),
    ImageTransparency = 0.82,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    ZIndex = card.ZIndex - 1,
    Parent = card,
})

-- ══════════════════════════════════════════
-- INNER GLASS LAYERS
-- ══════════════════════════════════════════
-- Top highlight strip (glass refraction)
local glassHighlight = create("Frame", {
    Name = "GlassHighlight",
    Size = UDim2.new(1, -2, 0.45, 0),
    Position = UDim2.new(0, 1, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 1,
    Parent = card,
})
create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = glassHighlight })

-- Subtle inner gradient
local innerGrad = create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(0.5, 0.97),
        NumberSequenceKeypoint.new(1, 0.95),
    }),
    Rotation = 160,
    Parent = card,
})

-- ══════════════════════════════════════════
-- LEFT SECTION: FPS Ring
-- ══════════════════════════════════════════
local leftSection = create("Frame", {
    Name = "LeftSection",
    Size = UDim2.new(0, 72, 0, 72),
    Position = UDim2.new(0, 14, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})

-- Ring background circle
local ringBg = create("Frame", {
    Name = "RingBg",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 2,
    Parent = leftSection,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ringBg })

-- Ring chroma stroke (the glowing ring)
local ringStroke = create("UIStroke", {
    Name = "RingStroke",
    Thickness = 2.5,
    Color = Color3.fromHSV(0, 0.9, 1),
    Transparency = 0.1,
    Parent = ringBg,
})

-- Ring inner stroke (subtle depth)
local ringInner = create("Frame", {
    Name = "RingInner",
    Size = UDim2.new(1, -10, 1, -10),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(12, 12, 20),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 3,
    Parent = ringBg,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ringInner })

-- FPS number inside ring
local fpsNumber = create("TextLabel", {
    Name = "FPSNumber",
    Size = UDim2.new(1, 0, 0.65, 0),
    Position = UDim2.new(0.5, 0, 0.42, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Text = "60",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 26,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = card.ZIndex + 4,
    Parent = ringBg,
})

-- "FPS" micro label under number
local fpsTag = create("TextLabel", {
    Name = "FPSTag",
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0.5, 0, 0.72, 0),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    Text = "FPS",
    TextColor3 = Color3.fromRGB(130, 130, 150),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = card.ZIndex + 4,
    Parent = ringBg,
})

-- Pulse ring (animated expanding ring)
local pulseRing = create("Frame", {
    Name = "PulseRing",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 1,
    Parent = leftSection,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pulseRing })
local pulseStroke = create("UIStroke", {
    Thickness = 1.5,
    Color = Color3.fromHSV(0, 0.9, 1),
    Transparency = 0.6,
    Parent = pulseRing,
})

-- ══════════════════════════════════════════
-- RIGHT SECTION: Info + Graph
-- ══════════════════════════════════════════
local rightSection = create("Frame", {
    Name = "RightSection",
    Size = UDim2.new(0, 98, 0, 85),
    Position = UDim2.new(1, -14, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1,
    ZIndex = card.ZIndex + 2,
    Parent = card,
})

-- Status label (SMOOTH / STABLE / LOW)
local statusLabel = create("TextLabel", {
    Name = "Status",
    Size = UDim2.new(1, 0, 0, 13),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "● SMOOTH",
    TextColor3 = Color3.fromRGB(80, 255, 160),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = rightSection,
})

-- Min / Max labels
local statsRow = create("Frame", {
    Name = "StatsRow",
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 0, 16),
    BackgroundTransparency = 1,
    ZIndex = card.ZIndex + 3,
    Parent = rightSection,
})

local minLabel = create("TextLabel", {
    Name = "Min",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "MIN 60",
    TextColor3 = Color3.fromRGB(90, 90, 110),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = statsRow,
})

local maxLabel = create("TextLabel", {
    Name = "Max",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "MAX 60",
    TextColor3 = Color3.fromRGB(90, 90, 110),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = card.ZIndex + 3,
    Parent = statsRow,
})

-- Separator line
local separator = create("Frame", {
    Name = "Separator",
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(40, 40, 55),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 3,
    Parent = rightSection,
})

-- ══════════════════════════════════════════
-- FPS GRAPH (live bar visualization)
-- ══════════════════════════════════════════
local graphContainer = create("Frame", {
    Name = "GraphContainer",
    Size = UDim2.new(1, 0, 0, CFG.GraphHeight),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(15, 15, 22),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = card.ZIndex + 3,
    Parent = rightSection,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = graphContainer })

-- Graph baseline
local graphBase = create("Frame", {
    Name = "GraphBase",
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 3,
    Parent = graphContainer,
})

-- Create graph bars
local graphBars = {}
local barWidth = 1 / CFG.GraphBars

for i = 1, CFG.GraphBars do
    local bar = create("Frame", {
        Name = "Bar" .. i,
        Size = UDim2.new(barWidth, -1, 0.3, 0),
        Position = UDim2.new(barWidth * (i - 1), 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromHSV(0.55, 0.8, 0.9),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = card.ZIndex + 4,
        Parent = graphContainer,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = bar })
    
    -- Gradient on each bar (lighter at top)
    create("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.5),
        }),
        Rotation = 90,
        Parent = bar,
    })
    
    graphBars[i] = bar
end

-- Label "GRAPH" tiny watermark
local graphLabel = create("TextLabel", {
    Name = "GraphLabel",
    Size = UDim2.new(1, -4, 0, 8),
    Position = UDim2.new(0, 4, 0, 1),
    BackgroundTransparency = 1,
    Text = "LIVE",
    TextColor3 = Color3.fromRGB(55, 55, 70),
    TextSize = 7,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = card.ZIndex + 5,
    Parent = graphContainer,
})

-- ══════════════════════════════════════════
-- 60 FPS target line
-- ══════════════════════════════════════════
local targetLine = create("Frame", {
    Name = "TargetLine",
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0.5, 0), -- will be set dynamically
    BackgroundColor3 = Color3.fromRGB(255, 255, 100),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 5,
    Parent = graphContainer,
})

-- ══════════════════════════════════════════
-- CHROMA DOT (tiny indicator top-right)
-- ══════════════════════════════════════════
local chromaDot = create("Frame", {
    Name = "ChromaDot",
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(1, -14, 0, 10),
    BackgroundColor3 = Color3.fromHSV(0, 0.9, 1),
    BorderSizePixel = 0,
    ZIndex = card.ZIndex + 5,
    Parent = card,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chromaDot })

-- ══════════════════════════════════════════
-- DRAGGABLE (touch + mouse)
-- ══════════════════════════════════════════
local dragging = false
local dragStart, startPos

card.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = card.Position
        
        -- Press feedback
        TweenService:Create(card, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 195, 0, 117),
            BackgroundTransparency = 0.04,
        }):Play()
        TweenService:Create(chromaStroke, TweenInfo.new(0.12), {
            Thickness = 2,
            Transparency = 0.05,
        }):Play()
    end
end)

card.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 120),
            BackgroundTransparency = 0.08,
        }):Play()
        TweenService:Create(chromaStroke, TweenInfo.new(0.2), {
            Thickness = 1.5,
            Transparency = 0.15,
        }):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(card, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        }):Play()
    end
end)

-- ══════════════════════════════════════════
-- FPS ENGINE
-- ══════════════════════════════════════════
local frameCount = 0
local lastSample = tick()
local currentFPS = 60
local fpsHistory = {}
local minFPS = 999
local maxFPS = 0

-- Pre-fill graph
for i = 1, CFG.GraphBars do
    fpsHistory[i] = 60
end

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    local elapsed = now - lastSample
    
    if elapsed >= CFG.SampleRate then
        currentFPS = math.floor(frameCount / elapsed + 0.5)
        frameCount = 0
        lastSample = now
        
        -- Clamp
        currentFPS = math.clamp(currentFPS, 0, 240)
        
        -- Track min/max
        if currentFPS < minFPS then minFPS = currentFPS end
        if currentFPS > maxFPS then maxFPS = currentFPS end
        
        -- Update display
        fpsNumber.Text = tostring(currentFPS)
        minLabel.Text = "MIN " .. minFPS
        maxLabel.Text = "MAX " .. maxFPS
        
        -- Status text
        if currentFPS >= 55 then
            statusLabel.Text = "● SMOOTH"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 160)
        elseif currentFPS >= 40 then
            statusLabel.Text = "● STABLE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
        elseif currentFPS >= 25 then
            statusLabel.Text = "● DROPPING"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
        else
            statusLabel.Text = "● CRITICAL"
            statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        end
        
        -- FPS number color (white when good, warm when struggling)
        if currentFPS >= 50 then
            fpsNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
        elseif currentFPS >= 30 then
            fpsNumber.TextColor3 = Color3.fromRGB(255, 230, 140)
        else
            fpsNumber.TextColor3 = Color3.fromRGB(255, 110, 110)
        end
        
        -- Push to history
        table.remove(fpsHistory, 1)
        table.insert(fpsHistory, currentFPS)
        
        -- Update graph bars
        local maxRef = 80 -- reference max for graph scaling
        for i, bar in ipairs(graphBars) do
            local val = fpsHistory[i] or 60
            local height = math.clamp(val / maxRef, 0.05, 1)
            
            -- Color bar based on value
            local barHue
            if val >= 55 then
                barHue = 0.4 -- green
            elseif val >= 35 then
                barHue = 0.13 -- yellow/orange
            else
                barHue = 0.0 -- red
            end
            
            TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(barWidth, -1, height, 0),
                BackgroundColor3 = Color3.fromHSV(barHue, 0.7, 0.85),
            }):Play()
        end
    end
end)

-- ══════════════════════════════════════════
-- CHROMA ENGINE
-- ══════════════════════════════════════════
local hue = 0

RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * CFG.ChromaSpeed) % 1
    
    local c1 = Color3.fromHSV(hue, 0.85, 1)
    local c2 = Color3.fromHSV((hue + 0.15) % 1, 0.85, 1)
    local cDim = Color3.fromHSV(hue, 0.6, 0.7)
    
    -- Border
    chromaStroke.Color = c1
    
    -- Glow
    chromaGlow.ImageColor3 = c1
    
    -- Ring
    ringStroke.Color = c1
    
    -- Pulse ring
    pulseStroke.Color = c1
    
    -- Chroma dot
    chromaDot.BackgroundColor3 = c1
    
    -- Separator subtle tint
    separator.BackgroundColor3 = cDim
end)

-- ══════════════════════════════════════════
-- PULSE ANIMATION (looping ring expansion)
-- ══════════════════════════════════════════
local function doPulse()
    pulseRing.Size = UDim2.new(1, 0, 1, 0)
    pulseStroke.Transparency = 0.4
    
    local expandTween = TweenService:Create(pulseRing, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 20, 1, 20),
    })
    local fadeTween = TweenService:Create(pulseStroke, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
    })
    
    expandTween:Play()
    fadeTween:Play()
    
    expandTween.Completed:Connect(function()
        task.delay(0.3, doPulse)
    end)
end

-- ══════════════════════════════════════════
-- ENTRANCE ANIMATION
-- ══════════════════════════════════════════
-- Start invisible
card.BackgroundTransparency = 1
chromaStroke.Transparency = 1
chromaGlow.ImageTransparency = 1
glassHighlight.BackgroundTransparency = 1
fpsNumber.TextTransparency = 1
fpsTag.TextTransparency = 1
statusLabel.TextTransparency = 1
minLabel.TextTransparency = 1
maxLabel.TextTransparency = 1
separator.BackgroundTransparency = 1
graphContainer.BackgroundTransparency = 1
ringBg.BackgroundTransparency = 1
ringInner.BackgroundTransparency = 1
chromaDot.BackgroundTransparency = 1
graphLabel.TextTransparency = 1
targetLine.BackgroundTransparency = 1

for _, bar in ipairs(graphBars) do
    bar.BackgroundTransparency = 1
end

-- Scale in from small
card.Size = UDim2.new(0, 50, 0, 30)
card.Position = UDim2.new(0.5, -25, 0, 60)

task.delay(0.1, function()
    -- Card expand
    TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 200, 0, 120),
        Position = UDim2.new(0.5, -100, 0, 50),
        BackgroundTransparency = 0.08,
    }):Play()
    
    task.delay(0.15, function()
        TweenService:Create(chromaStroke, TweenInfo.new(0.3), { Transparency = 0.15 }):Play()
        TweenService:Create(chromaGlow, TweenInfo.new(0.4), { ImageTransparency = 0.82 }):Play()
        TweenService:Create(glassHighlight, TweenInfo.new(0.3), { BackgroundTransparency = 0.94 }):Play()
    end)
    
    task.delay(0.25, function()
        -- Ring appears
        TweenService:Create(ringBg, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3,
        }):Play()
        TweenService:Create(ringInner, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()
        
        TweenService:Create(fpsNumber, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
        TweenService:Create(fpsTag, TweenInfo.new(0.3), { TextTransparency = 0.3 }):Play()
    end)
    
    task.delay(0.35, function()
        -- Right section fades in
        TweenService:Create(statusLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        TweenService:Create(minLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        TweenService:Create(maxLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        TweenService:Create(separator, TweenInfo.new(0.25), { BackgroundTransparency = 0.4 }):Play()
    end)
    
    task.delay(0.45, function()
        -- Graph appears bar by bar
        TweenService:Create(graphContainer, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 }):Play()
        TweenService:Create(graphLabel, TweenInfo.new(0.2), { TextTransparency = 0.5 }):Play()
        TweenService:Create(targetLine, TweenInfo.new(0.2), { BackgroundTransparency = 0.7 }):Play()
        
        for i, bar in ipairs(graphBars) do
            task.delay(i * 0.015, function()
                TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.25,
                }):Play()
            end)
        end
    end)
    
    task.delay(0.55, function()
        -- Chroma dot blinks in
        TweenService:Create(chromaDot, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
        
        -- Start pulse loop
        doPulse()
    end)
end)

-- ══════════════════════════════════════════
-- Shadow chroma tint (very subtle)
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    for i = 1, 3 do
        local shadow = card:FindFirstChild("Shadow" .. i)
        if shadow then
            shadow.ImageColor3 = Color3.fromHSV(hue, 0.3, 0.15)
        end
    end
end)

print("⚡ Ultra Premium FPS Counter v2.0 loaded — drag anywhere!")
