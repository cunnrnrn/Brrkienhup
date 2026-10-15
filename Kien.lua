-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (Menu OK Click TP & Full ESP)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Biến trạng thái
local base1 = nil
local base2 = nil
local isFlying = false
local flySpeed = 165
local fixLagActive = false
local noclipManual = false
local clickTpActive = false
local espPlayerActive = false
local currentTween = nil

local selectedPosition = nil
local markerPart = nil

-- Nhặt đồ tức thì
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "√12kientomato_Gui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Nút Bật/Tắt Menu
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 110, 0, 32)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "√12kientomato"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 6)
UICornerBtn.Parent = ToggleBtn

-- Bảng điều khiển chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 310)
MainFrame.Active = true
MainFrame.Draggable = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 6)
Title.Size = UDim2.new(0, 200, 0, 24)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "√12kientomato Hub (Pro Max)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Hiển thị FPS
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = MainFrame
FpsLabel.BackgroundTransparency = 1
FpsLabel.Position = UDim2.new(1, -110, 0, 6)
FpsLabel.Size = UDim2.new(0, 100, 0, 24)
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FpsLabel.TextSize = 13
FpsLabel.TextXAlignment = Enum.TextXAlignment.Right

local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if tick() - lastTime >= 1 then
        FpsLabel.Text = "FPS: " .. tostring(frameCount)
        frameCount = 0
        lastTime = tick()
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tab hệ thống
local TabButtonContainer = Instance.new("Frame")
TabButtonContainer.Parent = MainFrame
TabButtonContainer.BackgroundTransparency = 1
TabButtonContainer.Position = UDim2.new(0, 10, 0, 35)
TabButtonContainer.Size = UDim2.new(0, 100, 0, 265)

local UIListLayoutTabs = Instance.new("UIListLayout")
UIListLayoutTabs.Parent = TabButtonContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 118, 0, 35)
ContentContainer.Size = UDim2.new(0, 232, 0, 265)

local tabs = {}
local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = TabButtonContainer
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.Size = UDim2.new(1, 0, 0, 28)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = tabBtn
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Parent = ContentContainer
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 340)
    tabContent.ScrollBarThickness = 3
    tabContent.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tabContent
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.content.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    table.insert(tabs, {btn = tabBtn, content = tabContent})
    if #tabs == 1 then
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    
    return tabContent
end

local tab1 = createTab("Tele & Bay")
local tab2 = createTab("Click TP & ESP")

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Size = UDim2.new(1, -5, 0, 30)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ================= TAB 1 =================
createButton(tab1, "Lưu Vị Trí Base 1", function()
    if humanoidRootPart then
        base1 = humanoidRootPart.CFrame
        print("Đã lưu Base 1!")
    end
end)

createButton(tab1, "Lưu Vị Trí Base 2", function()
    if humanoidRootPart then
        base2 = humanoidRootPart.CFrame
        print("Đã lưu Base 2!")
    end
end)

local function smoothFlyTo(targetCFrame)
    if not humanoidRootPart or not targetCFrame or not isFlying then return false end
    local distance = (humanoidRootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / flySpeed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    
    local completed = false
    local connection
    connection = currentTween.Completed:Connect(function()
        completed = true
        if connection then connection:Disconnect() end
    end)
    
    while not completed and isFlying do
        task.wait()
    end
    
    return isFlying
end

createButton(tab1, "Chạy Bay (2 -> 1 -> 2 Nghỉ)", function()
    if not base1 or not base2 then
        print("Vui lòng lưu đủ 2 vị trí Base trước!")
        return
    end
    
    if isFlying then return end
    isFlying = true
    
    task.spawn(function()
        if smoothFlyTo(base2) then
            task.wait(0.1)
            if smoothFlyTo(base1) then
                task.wait(0.1)
                smoothFlyTo(base2)
            end
        end
        isFlying = false
        print("Đã hoàn tất hành trình 2 -> 1 -> 2 và dừng bay!")
    end)
end)

createButton(tab1, "NGỪNG BAY NGAY LẬP TỨC", function()
    isFlying = false
    if currentTween then
        currentTween:Cancel()
    end
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.zero
    end
    print("Đã dừng bay ngay lập tức!")
end)

-- ================= TAB 2: CLICK TP VÀ NÚT OK TRONG MENU =================
local ClickTpBtn = createButton(tab2, "Chọn Điểm: TẮT", function() end)

ClickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    if clickTpActive then
        ClickTpBtn.Text = "Chọn Điểm: BẬT"
        ClickTpBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        ClickTpBtn.Text = "Chọn Điểm: TẮT"
        ClickTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectedPosition = nil
        if markerPart then markerPart:Destroy() end
    end
end)

-- Bấm vào màn hình game để lấy vị trí lưu lại
mouse.Button1Down:Connect(function()
    if not clickTpActive then return end
    local hitPos = mouse.Hit
    if not hitPos then return end
    
    selectedPosition = hitPos + Vector3.new(0, 3, 0)
    
    if markerPart then markerPart:Destroy() end
    markerPart = Instance.new("Part")
    markerPart.Size = Instance.new("Vector3", {2, 2, 2})
    markerPart.Size = Vector3.new(2, 2, 2)
    markerPart.Shape = Enum.PartType.Ball
    markerPart.Color = Color3.fromRGB(0, 255, 255)
    markerPart.Material = Enum.Material.Neon
    markerPart.Transparency = 0.3
    markerPart.Anchored = true
    markerPart.CanCollide = false
    markerPart.CFrame = selectedPosition
    markerPart.Parent = Workspace
    
    print("Đã lưu tọa độ điểm! Giờ chỉ việc bấm nút OK trong Menu.")
end)

-- NÚT OK CHÍNH THỨC NẰM TRONG MENU ĐỂ BẤM BAY
createButton(tab2, "✅ NÚT OK (BẤM ĐỂ BAY TỚI ĐIỂM)", function()
    if not selectedPosition or not humanoidRootPart then
        print("Bạn chưa chọn vị trí trên bản đồ!")
        return
    end
    
    if markerPart then markerPart:Destroy() end
    
    local distance = (humanoidRootPart.Position - selectedPosition.Position).Magnitude
    local duration = distance / flySpeed
    
    isFlying = true
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = selectedPosition})
    currentTween:Play()
    
    currentTween.Completed:Connect(function()
        isFlying = false
        print("Đã bay đến điểm chọn bằng nút OK thành công!")
    end)
end)

-- ================= ESP TÊN + KHOẢNG CÁCH NGƯỜI CHƠI =================
local EspBtn = createButton(tab2, "ESP Tên & Khoảng Cách: TẮT", function() end)

EspBtn.MouseButton1Click:Connect(function()
    espPlayerActive = not espPlayerActive
    EspBtn.Text = espPlayerActive and "ESP Tên & Khoảng Cách: BẬT" or "ESP Tên & Khoảng Cách: TẮT"
    EspBtn.TextColor3 = espPlayerActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

local function setupPlayerEsp(p)
    if p == player then return end
    
    local function applyEsp(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if not hrp or not head then return end
        
        if hrp:FindFirstChild("KienHighlight") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "KienHighlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = hrp
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "KienNameEsp"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = hrp
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.Parent = billboard
        
        task.spawn(function()
            while billboard and billboard.Parent and humanoidRootPart and hrp do
                local dist = math.floor((humanoidRootPart.Position - hrp.Position).Magnitude)
                textLabel.Text = p.Name .. " [" .. dist .. "m]"
                task.wait(0.2)
            end
        end)
    end
    
    p.CharacterAdded:Connect(function(newChar)
        if espPlayerActive then
            applyEsp(newChar)
        end
    end)
    
    if p.Character then
        applyEsp(p.Character)
    end
end

for _, p in pairs(Players:GetPlayers()) do
    setupPlayerEsp(p)
end
Players.PlayerAdded:Connect(setupPlayerEsp)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local highlight = hrp:FindFirstChild("KienHighlight")
                if espPlayerActive and not highlight then
                    setupPlayerEsp(p)
                elseif not espPlayerActive and highlight then
                    highlight:Destroy()
                    local billboard = hrp:FindFirstChild("KienNameEsp")
                    if billboard then billboard:Destroy() end
                end
            end
        end
    end
end)

-- Noclip & Fix Lag
local NoclipBtn = createButton(tab2, "Noclip: TẮT", function() end)
NoclipBtn.MouseButton1Click:Connect(function()
    noclipManual = not noclipManual
    NoclipBtn.Text = noclipManual and "Noclip: BẬT" or "Noclip: TẮT"
    NoclipBtn.TextColor3 = noclipManual and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

RunService.Stepped:Connect(function()
    if (isFlying or noclipManual) and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

createButton(tab2, "Fix Lag Nâng Cao (Bật/Tắt)", function()
    fixLagActive = not fixLagActive
    if fixLagActive then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
        print("Đã bật Fix Lag!")
    else
        print("Đã tắt Fix Lag.")
    end
end)
