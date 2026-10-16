-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (Ultimate Edition)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Biến trạng thái
local base1 = nil
local base2 = nil
local isMoving = false
local moveSpeed = 165
local moveMode = "Fly" -- "Fly" hoặc "Walk"
local fixLagActive = false
local noclipManual = false
local clickTpActive = false
local espPlayerActive = false
local autoPlatformActive = false
local antiAfkActive = false
local moveConnection = nil

local selectedPosition = nil
local markerPart = nil
local activePlatforms = {}
local smartFloorPart = nil

local function setupCharacter(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Died:Connect(function()
        isMoving = false
        if moveConnection then moveConnection:Disconnect() end
    end)
end

player.CharacterAdded:Connect(setupCharacter)

-- Anti-AFK chống văng khi treo máy
player.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

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
MainFrame.Size = UDim2.new(0, 360, 0, 340)
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
TabButtonContainer.Size = UDim2.new(0, 100, 0, 290)

local UIListLayoutTabs = Instance.new("UIListLayout")
UIListLayoutTabs.Parent = TabButtonContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 118, 0, 35)
ContentContainer.Size = UDim2.new(0, 232, 0, 290)

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
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 420)
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
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    table.insert(tabs, {btn = tabBtn, content = tabContent})
    if #tabs == 1 then
        tabContent.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    
    return tabContent
end

local tab1 = createTab("Tele & Bay")
local tab2 = createTab("Tính Năng")
local tab3 = createTab("Cài Đặt")

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

-- ================= HÀM DI CHUYỂN LINH HOẠT (BAY HOẶC GIẢ LẬP KÉO NÚT) =================
local function customMoveTo(targetCFrame)
    if not humanoidRootPart or not humanoid then return false end
    isMoving = true
    
    local targetPos = targetCFrame.Position
    local completed = false
    
    if moveConnection then moveConnection:Disconnect() end
    
    moveConnection = RunService.RenderStepped:Connect(function(dt)
        if not isMoving or not humanoidRootPart or not humanoid then 
            if moveConnection then moveConnection:Disconnect() end
            return 
        end
        
        local currentPos = humanoidRootPart.Position
        local distance = (currentPos - targetPos).Magnitude
        
        if distance < 3 or not isMoving then
            if moveMode == "Walk" then humanoid:Move(Vector3.zero) end
            completed = true
            isMoving = false
            if moveConnection then moveConnection:Disconnect() end
        else
            if moveMode == "Fly" then
                -- Chế độ bay mượt mà với tốc độ tùy chỉnh
                local step = math.min(moveSpeed * dt, distance)
                local newPos = currentPos + (targetPos - currentPos).Unit * step
                humanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            else
                -- Chế độ giả lập kéo nút di chuyển thuần túy hướng về đích
                local direction = (targetPos - currentPos)
                local moveVector = Vector3.new(direction.X, 0, direction.Z).Unit
                humanoid:Move(moveVector, false)
            end
        end
    end)
    
    while isMoving and not completed do
        task.wait()
    end
    return true
end

-- ================= TAB 1: TELE & HÀNH TRÌNH 2 -> 1 -> 2 =================
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

createButton(tab1, "Chạy Hành Trình (2 -> 1 -> 2)", function()
    if not base1 or not base2 then
        print("Vui lòng lưu đủ 2 vị trí Base trước!")
        return
    end
    
    if isMoving then return end
    
    task.spawn(function()
        noclipManual = true
        
        print("Đang di chuyển đến Base 2...")
        if customMoveTo(base2) then
            task.wait(0.2)
            print("Đang di chuyển sang Base 1...")
            if customMoveTo(base1) then
                task.wait(0.2)
                print("Đang quay về lại Base 2...")
                customMoveTo(base2)
            end
        end
        
        isMoving = false
        noclipManual = false
        print("Đã hoàn tất hành trình 2 -> 1 -> 2 thành công!")
    end)
end)

createButton(tab1, "NGỪNG HÀNH TRÌNH NGAY", function()
    isMoving = false
    if moveConnection then moveConnection:Disconnect() end
    if humanoid then humanoid:Move(Vector3.zero) end
    if humanoidRootPart then humanoidRootPart.AssemblyLinearVelocity = Vector3.zero end
    print("Đã dừng hành trình!")
end)

-- ================= TAB 2: TÍNH NĂNG =================
local ClickTpBtn = createButton(tab2, "Chọn Điểm: TẮT", function() end)

ClickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    ClickTpBtn.Text = clickTpActive and "Chọn Điểm: BẬT" or "Chọn Điểm: TẮT"
    ClickTpBtn.TextColor3 = clickTpActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not clickTpActive then
        selectedPosition = nil
        if markerPart then markerPart:Destroy() end
    end
end)

mouse.Button1Down:Connect(function()
    if not clickTpActive then return end
    local target = mouse.Target
    local hitPos = mouse.Hit
    
    if target and target:IsA("BasePart") and hitPos then
        selectedPosition = hitPos + Vector3.new(0, 3, 0)
        if markerPart then markerPart:Destroy() end
        markerPart = Instance.new("Part")
        markerPart.Size = Vector3.new(2, 2, 2)
        markerPart.Shape = Enum.PartType.Ball
        markerPart.Color = Color3.fromRGB(0, 255, 255)
        markerPart.Material = Enum.Material.Neon
        markerPart.Transparency = 0.3
        markerPart.Anchored = true
        markerPart.CanCollide = false
        markerPart.CFrame = selectedPosition
        markerPart.Parent = Workspace
    end
end)

createButton(tab2, "✅ NÚT OK (DI CHUYỂN TỚI ĐIỂM)", function()
    if not selectedPosition or not humanoidRootPart then return end
    if markerPart then markerPart:Destroy() end
    
    task.spawn(function()
        noclipManual = true
        customMoveTo(selectedPosition)
        noclipManual = false
    end)
end)

local AutoPlatformBtn = createButton(tab2, "Khối Theo Chân: TẮT", function() end)

AutoPlatformBtn.MouseButton1Click:Connect(function()
    autoPlatformActive = not autoPlatformActive
    AutoPlatformBtn.Text = autoPlatformActive and "Khối Theo Chân: BẬT" or "Khối Theo Chân: TẮT"
    AutoPlatformBtn.TextColor3 = autoPlatformActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not autoPlatformActive then
        for _, p in pairs(activePlatforms) do if p then p:Destroy() end end
        activePlatforms = {}
    end
end)

RunService.Heartbeat:Connect(function()
    if autoPlatformActive and humanoidRootPart then
        local pos = humanoidRootPart.Position - Vector3.new(0, 3.5, 0)
        local createNew = true
        for _, p in pairs(activePlatforms) do
            if p and (p.Position - pos).Magnitude < 2 then
                createNew = false
                break
            end
        end
        
        if createNew then
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(4, 1, 4)
            plat.Position = pos
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 1
            plat.Parent = Workspace
            table.insert(activePlatforms, plat)
            if #activePlatforms > 30 then
                local oldPlat = table.remove(activePlatforms, 1)
                if oldPlat then oldPlat:Destroy() end
            end
        end
    end
end)

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
        if espPlayerActive then applyEsp(newChar) end
    end)
    if p.Character then applyEsp(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do setupPlayerEsp(p) end
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

-- ================= TAB 3: CÀI ĐẶT =================

-- Nút đổi chế độ di chuyển (Bay / Giả lập kéo nút)
local ModeBtn = createButton(tab3, "Kiểu Di Chuyển: BAY (Fly)", function() end)
ModeBtn.MouseButton1Click:Connect(function()
    if moveMode == "Fly" then
        moveMode = "Walk"
        ModeBtn.Text = "Kiểu Di Chuyển: KÉO NÚT (Walk)"
        ModeBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        moveMode = "Fly"
        ModeBtn.Text = "Kiểu Di Chuyển: BAY (Fly)"
        ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Ô nhập tốc độ
local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Parent = tab3
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Size = UDim2.new(1, -5, 0, 20)
SpeedTitle.Font = Enum.Font.SourceSansBold
SpeedTitle.Text = "Tốc độ (Max: 165):"
SpeedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedTitle.TextSize = 12
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = tab3
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.Size = UDim2.new(1, -5, 0, 28)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.Text = tostring(moveSpeed)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedBox.TextSize = 14
SpeedBox.ClearTextOnFocus = false

local cornerBox = Instance.new("UICorner")
cornerBox.CornerRadius = UDim.new(0, 5)
cornerBox.Parent = SpeedBox

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        if val > 165 then val = 165 end
        if val < 1 then val = 1 end
        moveSpeed = val
        SpeedBox.Text = tostring(moveSpeed)
    else
        SpeedBox.Text = tostring(moveSpeed)
    end
end)

-- Noclip Bất Tử kết hợp Chống Rơi Thông Minh (Smart Anti-Fall)
local NoclipBtn = createButton(tab3, "Noclip & Chống Rơi: TẮT", function() end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipManual = not noclipManual
    NoclipBtn.Text = noclipManual and "Noclip & Chống Rơi: BẬT" or "Noclip & Chống Rơi: TẮT"
    NoclipBtn.TextColor3 = noclipManual and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    
    if not noclipManual and smartFloorPart then
        smartFloorPart:Destroy()
        smartFloorPart = nil
    end
end)

-- Vòng lặp Noclip và tự động tạo khối đỡ dưới chân khi không có khối
RunService.Heartbeat:Connect(function()
    if (isMoving or noclipManual) and character and humanoidRootPart then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Tính năng chống rơi: Quét xem dưới chân có khối thực sự không, nếu không có tạo sàn tàng hình đỡ ngay
        if noclipManual then
            local rayOrigin = humanoidRootPart.Position
            local rayDirection = Vector3.new(0, -15, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {character}
            
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastPateButton(tab2, "Chọn Điểm: TẮT", function() end)

ClickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    ClickTpBtn.Text = clickTpActive and "Chọn Điểm: BẬT" or "Chọn Điểm: TẮT"
    ClickTpBtn.TextColor3 = clickTpActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not clickTpActive then
        selectedPosition = nil
        if markerPart then markerPart:Destroy() end
    end
end)

mouse.Button1Down:Connect(function()
    if not clickTpActive then return end
    local target = mouse.Target
    local hitPos = mouse.Hit
    
    if target and target:IsA("BasePart") and hitPos then
        selectedPosition = hitPos + Vector3.new(0, 3, 0)
        if markerPart then markerPart:Destroy() end
        markerPart = Instance.new("Part")
        markerPart.Size = Vector3.new(2, 2, 2)
        markerPart.Shape = Enum.PartType.Ball
        markerPart.Color = Color3.fromRGB(0, 255, 255)
        markerPart.Material = Enum.Material.Neon
        markerPart.Transparency = 0.3
        markerPart.Anchored = true
        markerPart.CanCollide = false
        markerPart.CFrame = selectedPosition
        markerPart.Parent = Workspace
    end
end)

createButton(tab2, "✅ NÚT OK (BẤM ĐỂ BAY)", function()
    if not selectedPosition or not humanoidRootPart then return end
    if markerPart then markerPart:Destroy() end
    
    task.spawn(function()
        noclipManual = true
        smoothFlyTo(selectedPosition)
        noclipManual = false
    end)
end)

local AutoPlatformBtn = createButton(tab2, "Khối Theo Chân: TẮT", function() end)

AutoPlatformBtn.MouseButton1Click:Connect(function()
    autoPlatformActive = not autoPlatformActive
    AutoPlatformBtn.Text = autoPlatformActive and "Khối Theo Chân: BẬT" or "Khối Theo Chân: TẮT"
    AutoPlatformBtn.TextColor3 = autoPlatformActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not autoPlatformActive then
        for _, p in pairs(activePlatforms) do if p then p:Destroy() end end
        activePlatforms = {}
    end
end)

RunService.Heartbeat:Connect(function()
    if autoPlatformActive and humanoidRootPart then
        local pos = humanoidRootPart.Position - Vector3.new(0, 3.5, 0)
        local createNew = true
        for _, p in pairs(activePlatforms) do
            if p and (p.Position - pos).Magnitude < 2 then
                createNew = false
                break
            end
        end
        
        if createNew then
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(4, 1, 4)
            plat.Position = pos
            plat.Anchored = true
            plat.CanCollide = true
            plat.Transparency = 1
            plat.Parent = Workspace
            table.insert(activePlatforms, plat)
            if #activePlatforms > 30 then
                local oldPlat = table.remove(activePlatforms, 1)
                if oldPlat then oldPlat:Destroy() end
            end
        end
    end
end)

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
        if espPlayerActive then applyEsp(newChar) end
    end)
    if p.Character then applyEsp(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do setupPlayerEsp(p) end
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

-- ================= TAB 3: CÀI ĐẶT =================
local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Parent = tab3
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Size = UDim2.new(1, -5, 0, 22)
SpeedTitle.Font = Enum.Font.SourceSansBold
SpeedTitle.Text = "Tốc độ bay (Max: 165):"
SpeedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedTitle.TextSize = 12
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = tab3
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.Size = UDim2.new(1, -5, 0, 30)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.Text = tostring(flySpeed)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedBox.TextSize = 14
SpeedBox.ClearTextOnFocus = false

local cornerBox = Instance.new("UICorner")
cornerBox.CornerRadius = UDim.new(0, 5)
cornerBox.Parent = SpeedBox

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        if val > 165 then val = 165 end
        if val < 1 then val = 1 end
        flySpeed = val
        SpeedBox.Text = tostring(flySpeed)
    else
        SpeedBox.Text = tostring(flySpeed)
    end
end)

-- Noclip Cực Mạnh (Xuyên mọi vật thể, chống rớt lòng đất)
local NoclipBtn = createButton(tab3, "Noclip Cực Mạnh: TẮT", function() end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipManual = not noclipManual
    NoclipBtn.Text = noclipManual and "Noclip Cực Mạnh: BẬT" or "Noclip Cực Mạnh: TẮT"
    NoclipBtn.TextColor3 = noclipManual and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    
    if noclipManual then
        if not antiVoidPart then
            antiVoidPart = Instance.new("Part")
            antiVoidPart.Name = "AntiVoidFloor"
            antiVoidPart.Size = Vector3.new(20000, 5, 20000)
            antiVoidPart.Position = Vector3.new(0, -30, 0)
            antiVoidPart.Anchored = true
            antiVoidPart.CanCollide = true
            antiVoidPart.Transparency = 1
            antiVoidPart.Parent = Workspace
        end
    else
        if antiVoidPart then
            antiVoidPart:Destroy()
            antiVoidPart = nil
        end
    end
end)

-- Vòng lặp Noclip xử lý toàn bộ các phần cơ thể nhân vật không bao giờ bị va chạm kẹt tường
RunService.Stepped:Connect(function()
    if (isFlying or noclipManual) and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fix Lag Ultra Nâng Cao
createButton(tab3, "Fix Lag Ultra (Bật/Tắt)", function()
    fixLagActive = not fixLagActive
    if fixLagActive then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Explosion") then
                obj.Enabled = false
            end
        end
        print("Đã bật Fix Lag Ultra!")
    else
        print("Đã tắt Fix Lag Ultra.")
    end
end)
