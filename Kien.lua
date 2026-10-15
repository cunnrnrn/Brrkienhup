-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (Click TP & Persistent ESP)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")

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

-- Biến cho tính năng Click TP
local selectedPosition = nil
local targetPart = nil
local guiBillboard = nil

-- Tự động nhặt đồ tức thì
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

-- Tạo GUI Giao Diện
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
MainFrame.Size = UDim2.new(0, 360, 0, 280)
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

-- Bảng hiển thị FPS Live
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

-- Quản lý Tab
local TabButtonContainer = Instance.new("Frame")
TabButtonContainer.Parent = MainFrame
TabButtonContainer.BackgroundTransparency = 1
TabButtonContainer.Position = UDim2.new(0, 10, 0, 35)
TabButtonContainer.Size = UDim2.new(0, 100, 0, 235)

local UIListLayoutTabs = Instance.new("UIListLayout")
UIListLayoutTabs.Parent = TabButtonContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 118, 0, 35)
ContentContainer.Size = UDim2.new(0, 232, 0, 235)

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
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 320)
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

-- ================= TAB 1: BASE & BAY =================
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

-- ================= TAB 2: CLICK TP & ESP NGƯỜI CHƠI =================
local ClickTpBtn = createButton(tab2, "Click TP: TẮT", function() end)

ClickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    if clickTpActive then
        ClickTpBtn.Text = "Click TP: BẬT"
        ClickTpBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        ClickTpBtn.Text = "Click TP: TẮT"
        ClickTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if guiBillboard then guiBillboard:Destroy() end
    end
end)

-- Sự kiện bắt click chuột/chạm màn hình để chọn điểm TP
mouse.Button1Down:Connect(function()
    if not clickTpActive then return end
    local hitPos = mouse.Hit
    if not hitPos then return end
    
    selectedPosition = hitPos + Vector3.new(0, 3, 0) -- Nâng lên một chút tránh kẹt đất
    
    -- Xóa bảng cũ nếu có
    if guiBillboard then guiBillboard:Destroy() end
    
    -- Tạo một Part ẩn tại điểm chọn để gán BillboardGUI chứa nút OK
    targetPart = Instance.new("Part")
    targetPart.Size = Vector3.new(1, 1, 1)
    targetPart.Transparency = 1
    targetPart.Anchored = true
    targetPart.CanCollide = false
    targetPart.CFrame = selectedPosition
    targetPart.Parent = Workspace
    
    guiBillboard = Instance.new("BillboardGui")
    guiBillboard.Size = UDim2.new(0, 160, 0, 70)
    guiBillboard.AlwaysOnTop = true
    guiBillboard.Adornee = targetPart
    guiBillboard.Parent = targetPart
    
    -- Khung hiển thị khoảng cách & nút OK
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.SourceSansBold
    infoLabel.TextSize = 13
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    infoLabel.Parent = guiBillboard
    
    -- Cập nhật khoảng cách liên tục
    task.spawn(function()
        while guiBillboard and guiBillboard.Parent and humanoidRootPart do
            local dist = math.floor((humanoidRootPart.Position - selectedPosition.Position).Magnitude)
            infoLabel.Text = "Khoảng cách: " .. dist .. "m"
            task.wait(0.2)
        end
    end)
    
    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(1, 0, 0, 35)
    okBtn.Position = UDim2.new(0, 0, 0, 32)
    okBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    okBtn.Font = Enum.Font.SourceSansBold
    okBtn.Text = "BẤM ĐỂ BAY (OK)"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.TextSize = 13
    okBtn.Parent = guiBillboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = okBtn
    
    -- Khi bấm nút OK -> Bay tới điểm đó tốc độ 165
    okBtn.MouseButton1Click:Connect(function()
        if not selectedPosition or not humanoidRootPart then return end
        
        if guiBillboard then guiBillboard:Destroy() end
        if targetPart then targetPart:Destroy() end
        
        local distance = (humanoidRootPart.Position - selectedPosition.Position).Magnitude
        local duration = distance / flySpeed
        
        isFlying = true
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        currentTween = TweenService:Create(otherPart or humanoidRootPart, tweenInfo, {CFrame = selectedPosition})
        
        -- Dùng trực tiếp cho RootPart
        local activeTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = selectedPosition})
        activeTween:Play()
        
        activeTween.Completed:Connect(function()
            isFlying = false
            print("Đã bay đến điểm chọn thành công!")
        end)
    end)
end)

-- ================= ESP NGƯỜI CHƠI VĨNH VIỄN (KỂ CẢ KHI HỒI SINH) =================
local EspBtn = createButton(tab2, "ESP Người Chơi: TẮT", function() end)

EspBtn.MouseButton1Click:Connect(function()
    espPlayeractive = not espPlayeractive
    if espPlayeractive then
        EspBtn.Text = "ESP Người Chơi: BẬT"
        EspBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        EspBtn.Text = "ESP Người Chơi: TẮT"
        EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Hàm tạo/duy trì ESP cho mỗi người chơi
local function setupPlayerEsp(p)
    if p == player then return end
    
    local function applyEsp(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        
        -- Tránh tạo trùng ESP nếu đã có
        if hrp:FindFirstChild("KienEspBox") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "KienEspBox"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = hrp
    end
    
    -- Theo dõi khi nhân vật xuất hiện hoặc hồi sinh (CharacterAdded)
    p.CharacterAdded:Connect(function(newChar)
        if espPlayeractive then
            applyEsp(newChar)
        end
    end)
    
    if p.Character then
        applyEsp(p.Character)
    end
end

-- Quét toàn bộ người chơi hiện tại và người mới vào
for _, p in pairs(Players:GetPlayers()) do
    setupPlayerEsp(p)
end
Players.PlayerAdded:Connect(setupPlayerEsp)

-- Vòng lặp bật/tắt trạng thái ESP vĩnh viễn
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local highlight = hrp:FindFirstChild("KienEspBox")
                if espPlayeractive and not highlight then
                    setupPlayerEsp(p)
                elseif not espPlayeractive and highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end)

-- Noclip & Fix Lag cơ bản
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
