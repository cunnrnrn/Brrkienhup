-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (Phần 1/2)
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

getgenv().KienHubState = {
    base1 = nil,
    base2 = nil,
    isMoving = false,
    moveSpeed = 165,
    moveMode = "Fly",
    fixLagActive = false,
    noclipManual = false,
    clickTpActive = false,
    espPlayerActive = false,
    autoPlatformActive = false,
    antiAfkActive = false,
    moveConnection = nil,
    selectedPosition = nil,
    markerPart = nil,
    smartFloorPart = nil,
    activePlatforms = {}
}
local S = getgenv().KienHubState

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        S.isMoving = false
        if S.moveConnection then S.moveConnection:Disconnect() end
    end)
end)

player.Idled:Connect(function()
    if S.antiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt) fireproximityprompt(prompt) end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "√12kientomato_Gui", false

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.BackgroundColor3, ToggleBtn.Position, ToggleBtn.Size = Color3.fromRGB(20, 20, 20), UDim2.new(0.05, 0, 0.1, 0), UDim2.new(0, 110, 0, 32)
ToggleBtn.Font, ToggleBtn.Text, ToggleBtn.TextColor3, ToggleBtn.TextSize, ToggleBtn.Active, ToggleBtn.Draggable = Enum.Font.SourceSansBold, "√12kientomato", Color3.fromRGB(0, 255, 255), 13, true, true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.Position, MainFrame.Size = Color3.fromRGB(15, 15, 15), 0.05, UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0, 360, 0, 340)
MainFrame.Active, MainFrame.Draggable = true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency, Title.Position, Title.Size = true, UDim2.new(0, 10, 0, 6), UDim2.new(0, 200, 0, 24)
Title.Font, Title.Text, Title.TextColor3, Title.TextSize, Title.TextXAlignment = Enum.Font.SourceSansBold, "√12kientomato Hub (Pro Max)", Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left

local FpsLabel = Instance.new("TextLabel", MainFrame)
FpsLabel.BackgroundTransparency, FpsLabel.Position, FpsLabel.Size = true, UDim2.new(1, -110, 0, 6), UDim2.new(0, 100, 0, 24)
FpsLabel.Font, FpsLabel.Text, FpsLabel.TextColor3, FpsLabel.TextSize, FpsLabel.TextXAlignment = Enum.Font.SourceSansBold, "FPS: --", Color3.fromRGB(0, 255, 150), 13, Enum.TextXAlignment.Right

local lastTime, frameCount = tick(), 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if tick() - lastTime >= 1 then
        FpsLabel.Text = "FPS: " .. tostring(frameCount)
        frameCount, lastTime = 0, tick()
    end
end)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TabButtonContainer = Instance.new("Frame", MainFrame)
TabButtonContainer.BackgroundTransparency, TabButtonContainer.Position, TabButtonContainer.Size = true, UDim2.new(0, 10, 0, 35), UDim2.new(0, 100, 0, 290)
local UIListLayoutTabs = Instance.new("UIListLayout", TabButtonContainer)
UIListLayoutTabs.SortOrder, UIListLayoutTabs.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.BackgroundTransparency, ContentContainer.Position, ContentContainer.Size = true, UDim2.new(0, 118, 0, 35), UDim2.new(0, 232, 0, 290)

local tabs = {}
local function createTab(name)
    local tabBtn = Instance.new("TextButton", TabButtonContainer)
    tabBtn.BackgroundColor3, tabBtn.Size = Color3.fromRGB(30, 30, 30), UDim2.new(1, 0, 0, 28)
    tabBtn.Font, tabBtn.Text, tabBtn.TextColor3, tabBtn.TextSize = Enum.Font.SourceSansBold, name, Color3.fromRGB(180, 180, 180), 12
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)
    
    local tabContent = Instance.new("ScrollingFrame", ContentContainer)
    tabContent.BackgroundTransparency, tabContent.Size, tabContent.CanvasSize, tabContent.ScrollBarThickness, tabContent.Visible = true, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 420), 3, false
    local layout = Instance.new("UIListLayout", tabContent)
    layout.SortOrder, layout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.content.Visible = false
            t.btn.TextColor3, t.btn.BackgroundColor3 = Color3.fromRGB(180, 180, 180), Color3.fromRGB(30, 30, 30)
        end
        tabContent.Visible = true
        tabBtn.TextColor3, tabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255), Color3.fromRGB(60, 60, 60)
    end)
    table.insert(tabs, {btn = tabBtn, content = tabContent})
    if #tabs == 1 then
        tabContent.Visible = true
        tabBtn.TextColor3, tabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255), Color3.fromRGB(60, 60, 60)
    end
    return tabContent
end

getgenv().KienTabs = {
    tab1 = createTab("Tele & Bay"),
    tab2 = createTab("Tính Năng"),
    tab3 = createTab("Cài Đặt")
}

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3, btn.Size = Color3.fromRGB(40, 40, 40), UDim2.new(1, -5, 0, 30)
    btn.Font, btn.Text, btn.TextColor3, btn.TextSize = Enum.Font.SourceSansBold, text, Color3.fromRGB(255, 255, 255), 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function customMoveTo(targetCFrame)
    if not humanoidRootPart or not humanoid then return false end
    S.isMoving = true
    local targetPos = targetCFrame.Position
    local completed = false
    if S.moveConnection then S.moveConnection:Disconnect() end
    
    S.moveConnection = RunService.RenderStepped:Connect(function(dt)
        if not S.isMoving or not humanoidRootPart or not humanoid then 
            if S.moveConnection then S.moveConnection:Disconnect() end
            return 
        end
        local currentPos = humanoidRootPart.Position
        local distance = (currentPos - targetPos).Magnitude
        if distance < 3 or not S.isMoving then
            if S.moveMode == "Walk" then humanoid:Move(Vector3.zero) end
            completed, S.isMoving = true, false
            if S.moveConnection then S.moveConnection:Disconnect() end
        else
            if S.moveMode == "Fly" then
                local step = math.min(S.moveSpeed * dt, distance)
                local newPos = currentPos + (targetPos - currentPos).Unit * step
                humanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            else
                local direction = (targetPos - currentPos)
                humanoid:Move(Vector3.new(direction.X, 0, direction.Z).Unit, false)
            end
        end
    end)
    while S.isMoving and not completed do task.wait() end
    return true
end

createButton(getgenv().KienTabs.tab1, "Lưu Vị Trí Base 1", function() if humanoidRootPart then S.base1 = humanoidRootPart.CFrame print("Đã lưu Base 1!") end end)
createButton(getgenv().KienTabs.tab1, "Lưu Vị Trí Base 2", function() if humanoidRootPart then S.base2 = humanoidRootPart.CFrame print("Đã lưu Base 2!") end end)

createButton(getgenv().KienTabs.tab1, "Chạy Hành Trình (2 -> 1 -> 2)", function()
    if not S.base1 or not S.base2 then print("Vui lòng lưu đủ 2 vị trí Base trước!") return end
    if S.isMoving then return end
    task.spawn(function()
        S.noclipManual = true
        if customMoveTo(S.base2) then
            task.wait(0.2)
            if customMoveTo(S.base1) then
                task.wait(0.2)
                customMoveTo(S.base2)
            end
        end
        S.isMoving, S.noclipManual = false, false
        print("Đã hoàn tất hành trình 2 -> 1 -> 2!")
    end)
end)

createButton(getgenv().KienTabs.tab1, "NGỪNG HÀNH TRÌNH NGAY", function()
    S.isMoving = false
    if S.moveConnection then S.moveConnection:Disconnect() end
    if humanoid then humanoid:Move(Vector3.zero) end
    if humanoidRootPart then humanoidRootPart.AssemblyLinearVelocity = Vector3.zero end
end)
-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (Phần 2/2)
-- ==========================================
local S = getgenv().KienHubState
local t2, t3 = getgenv().KienTabs.tab2, getgenv().KienTabs.tab3

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3, btn.Size = Color3.fromRGB(40, 40, 40), UDim2.new(1, -5, 0, 30)
    btn.Font, btn.Text, btn.TextColor3, btn.TextSize = Enum.Font.SourceSansBold, text, Color3.fromRGB(255, 255, 255), 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local ClickTpBtn = createButton(t2, "Chọn Điểm: TẮT", function() end)
ClickTpBtn.MouseButton1Click:Connect(function()
    S.clickTpActive = not S.clickTpActive
    ClickTpBtn.Text, ClickTpBtn.TextColor3 = S.clickTpActive and "Chọn Điểm: BẬT" or "Chọn Điểm: TẮT", S.clickTpActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.clickTpActive then S.selectedPosition = nil if S.markerPart then S.markerPart:Destroy() end end
end)

mouse.Button1Down:Connect(function()
    if not S.clickTpActive then return end
    local target, hitPos = mouse.Target, mouse.Hit
    if target and target:IsA("BasePart") and hitPos then
        S.selectedPosition = hitPos + Vector3.new(0, 3, 0)
        if S.markerPart then S.markerPart:Destroy() end
        S.markerPart = Instance.new("Part", Workspace)
        S.markerPart.Size, S.markerPart.Shape, S.markerPart.Color, S.markerPart.Material, S.markerPart.Transparency, S.markerPart.Anchored, S.markerPart.CanCollide, S.markerPart.CFrame = Vector3.new(2, 2, 2), Enum.PartType.Ball, Color3.fromRGB(0, 255, 255), Enum.Material.Neon, 0.3, true, false, S.selectedPosition
    end
end)

createButton(t2, "✅ NÚT OK (DI CHUYỂN TỚI ĐIỂM)", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not S.selectedPosition or not hrp then return end
    if S.markerPart then S.markerPart:Destroy() end
    task.spawn(function() S.noclipManual = true customMoveTo(S.selectedPosition) S.noclipManual = false end)
end)

local AutoPlatformBtn = createButton(t2, "Khối Theo Chân: TẮT", function() end)
AutoPlatformBtn.MouseButton1Click:Connect(function()
    S.autoPlatformActive = not S.autoPlatformActive
    AutoPlatformBtn.Text, AutoPlatformBtn.TextColor3 = S.autoPlatformActive and "Khối Theo Chân: BẬT" or "Khối Theo Chân: TẮT", S.autoPlatformActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.autoPlatformActive then for _, p in pairs(S.activePlatforms) do if p then p:Destroy() end end S.activePlatforms = {} end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if S.autoPlatformActive and hrp then
        local pos = hrp.Position - Vector3.new(0, 3.5, 0)
        local createNew = true
        for _, p in pairs(S.activePlatforms) do if p and (p.Position - pos).Magnitude < 2 then createNew = false break end end
        if createNew then
            local plat = Instance.new("Part", Workspace)
            plat.Size, plat.Position, plat.Anchored, plat.CanCollide, plat.Transparency = Vector3.new(4, 1, 4), pos, true, true, 1
            table.insert(S.activePlatforms, plat)
            if #S.activePlatforms > 30 then local old = table.remove(S.activePlatforms, 1) if old then old:Destroy() end end
        end
    end
end)

local EspBtn = createButton(t2, "ESP Tên & Khoảng Cách: TẮT", function() end)
EspBtn.MouseButton1Click:Connect(function()
    S.espPlayerActive = not S.espPlayerActive
    EspBtn.Text, EspBtn.TextColor3 = S.espPlayerActive and "ESP Tên & Khoảng Cách: BẬT" or "ESP Tên & Khoảng Cách: TẮT", S.espPlayerActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

local function setupPlayerEsp(p)
    if p == player then return end
    local function applyEsp(char)
        if not char then return end
        local hrp, head = char:WaitForChild("HumanoidRootPart", 5), char:WaitForChild("Head", 5)
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not hrp or not head or hrp:FindFirstChild("KienHighlight") then return end
        local hl = Instance.new("Highlight", hrp)
        hl.Name, hl.Adornee, hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.OutlineTransparency = "KienHighlight", char, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 255), 0.5, 0
        local bb = Instance.new("BillboardGui", hrp)
        bb.Name, bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Adornee = "KienNameEsp", UDim2.new(0, 200, 0, 50), Vector3.new(0, 2.5, 0), true, head
        local txt = Instance.new("TextLabel", bb)
        txt.Size, txt.BackgroundTransparency, txt.Font, txt.TextSize, txt.TextColor3, txt.TextStrokeTransparency = UDim2.new(1,0,1,0), true, Enum.Font.SourceSansBold, 14, Color3.fromRGB(255, 255, 255), 0
        task.spawn(function() while bb and bb.Parent and myHrp and hrp do txt.Text = p.Name .. " [" .. math.floor((myHrp.Position - hrp.Position).Magnitude) .. "m]" task.wait(0.2) end end)
    end
    p.CharacterAdded:Connect(function(newChar) if S.espPlayerActive then applyEsp(newChar) end end)
    if p.Character then applyEsp(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do setupPlayerEsp(p) end
Players.PlayerAdded:Connect(setupPlayerEsp)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hl = hrp:FindFirstChild("KienHighlight")
                if S.espPlayerActive and not hl then setupPlayerEsp(p)
                elseif not S.espPlayerActive and hl then hl:Destroy() local bb = hrp:FindFirstChild("KienNameEsp") if bb then bb:Destroy() end end
            end
        end
    end
end)

local ModeBtn = createButton(t3, "Kiểu Di Chuyển: BAY (Fly)", function() end)
ModeBtn.MouseButton1Click:Connect(function()
    if S.moveMode == "Fly" then
        S.moveMode = "Walk"
        ModeBtn.Text, ModeBtn.TextColor3 = "Kiểu Di Chuyển: KÉO NÚT (Walk)", Color3.fromRGB(0, 255, 150)
    else
        S.moveMode = "Fly"
        ModeBtn.Text, ModeBtn.TextColor3 = "Kiểu Di Chuyển: BAY (Fly)", Color3.fromRGB(255, 255, 255)
    end
end)

local SpeedTitle = Instance.new("TextLabel", t3)
SpeedTitle.BackgroundTransparency, SpeedTitle.Size = true, UDim2.new(1, -5, 0, 20)
SpeedTitle.Font, SpeedTitle.Text, SpeedTitle.TextColor3, SpeedTitle.TextSize, SpeedTitle.TextXAlignment = Enum.Font.SourceSansBold, "Tốc độ (Max: 165):", Color3.fromRGB(200, 200, 200), 12, Enum.TextXAlignment.Left

local SpeedBox = Instance.new("TextBox", t3)
SpeedBox.BackgroundColor3, SpeedBox.Size = Color3.fromRGB(30, 30, 30), UDim2.new(1, -5, 0, 28)
SpeedBox.Font, SpeedBox.Text, SpeedBox.TextColor3, SpeedBox.TextSize, SpeedBox.ClearTextOnFocus = Enum.Font.SourceSansBold, tostring(S.moveSpeed), Color3.fromRGB(0, 255, 255), 14, false
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 5)
SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then S.moveSpeed = math.clamp(val, 1, 165) SpeedBox.Text = tostring(S.moveSpeed) end
end)

local NoclipBtn = createButton(t3, "Noclip & Chống Rơi: TẮT", function() end)
NoclipBtn.MouseButton1Click:Connect(function()
    S.noclipManual = not S.noclipManual
    NoclipBtn.Text, NoclipBtn.TextColor3 = S.noclipManual and "Noclip & Chống Rơi: BẬT" or "Noclip & Chống Rơi: TẮT", S.noclipManual and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.noclipManual and S.smartFloorPart then S.smartFloorPart:Destroy() S.smartFloorPart = nil end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if (S.isMoving or S.noclipManual) and char and hrp then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        if S.noclipManual then
            local rayRes = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), RaycastParams.new({FilterType = RaycastFilterType.Exclude, FilterDescendantsInstances = {char}}))
            if not rayRes then
                if not S.smartFloorPart then
                    S.smartFloorPart = Instance.new("Part", Workspace)
                    S.smartFloorPart.Name, S.smartFloorPart.Size, S.smartFloorPart.Anchored, S.smartFloorPart.CanCollide, S.smartFloorPart.Transparency = "SmartAntiFallFloor", Vector3.new(10, 1, 10), true, true, 1
                end
                S.smartFloorPart.Position = hrp.Position - Vector3.new(0, 4, 0)
            else
                if S.smartFloorPart then S.smartFloorPart:Destroy() S.smartFloorPart = nil end
            end
        end
    else
        if S.smartFloorPart then S.smartFloorPart:Destroy() S.smartFloorPart = nil end
    end
end)

local AfkBtn = createButton(t3, "Anti-AFK (Treo máy): TẮT", function() end)
AfkBtn.MouseButton1Click:Connect(function()
    S.antiAfkActive = not S.antiAfkActive
    AfkBtn.Text, AfkBtn.TextColor3 = S.antiAfkActive and "Anti-AFK (Treo máy): BẬT" or "Anti-AFK (Treo máy): TẮT", S.antiAfkActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

createButton(t3, "Fix Lag Siêu Mạnh (Bật/Tắt)", function()
    S.fixLagActive = not S.fixLagActive
    if S.fixLagActive then
        Lighting.GlobalShadows, Lighting.FogEnd, Lighting.Brightness, Lighting.ClockTime = false, 9e9, 1, 12
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material, obj.Reflectance, obj.CastShadow = Enum.Material.SmoothPlastic, 0, false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Explosion") then obj.Enabled = false end
        end
    end
end)
