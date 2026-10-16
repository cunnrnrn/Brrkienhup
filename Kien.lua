-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (PHẦN 1/3)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

getgenv().KienState = {
    base1 = nil,
    base2 = nil,
    isMoving = false,
    moveSpeed = 165,
    moveMode = "Fly",
    fixLagActive = false,
    noclipActive = false,
    clickTpActive = false,
    espActive = false,
    autoWalkPlat = false,  -- Chức năng 1: Khối lót dưới chân khi đi ngang
    autoJumpPlat = false,  -- Chức năng 2: Bật nhảy tự sinh khối lót nâng cao
    antiAfkActive = false,
    selectedPos = nil,
    markerPart = nil,
    smartFloor = nil,
    activePlats = {},
    moveConn = nil
}
local S = getgenv().KienState

player.CharacterAdded:Connect(function(nc)
    character = nc
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        S.isMoving = false
        if S.moveConn then S.moveConn:Disconnect() end
    end)
end)

player.Idled:Connect(function()
    if S.antiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "√12kientomato_Gui"
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 110, 0, 32)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "√12kientomato"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 6)
Title.Size = UDim2.new(0, 200, 0, 24)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "√12kientomato Hub Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local FpsLabel = Instance.new("TextLabel", MainFrame)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Position = UDim2.new(1, -110, 0, 6)
FpsLabel.Size = UDim2.new(0, 100, 0, 24)
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
FpsLabel.TextSize = 13
FpsLabel.TextXAlignment = Enum.TextXAlignment.Right

local lastTime, frameCount = tick(), 0
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

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 35)
TabContainer.Size = UDim2.new(0, 100, 0, 290)
local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 118, 0, 35)
ContentContainer.Size = UDim2.new(0, 232, 0, 290)

local tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local page = Instance.new("ScrollingFrame", ContentContainer)
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 420)
    page.ScrollBarThickness = 3
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    table.insert(tabs, {btn = btn, page = page})
    if #tabs == 1 then
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    return page
end

getgenv().KienPages = {
    t1 = createTab("Tele & Bay"),
    t2 = createTab("Tính Năng"),
    t3 = createTab("Cài Đặt")
}

local function createBtn(parent, text, cb)
    local b = Instance.new("TextButton", parent)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Size = UDim2.new(1, -5, 0, 30)
    b.Font = Enum.Font.SourceSansBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(cb)
    return b
end
getgenv().KienCreateBtn = createBtn

local function safeMoveTo(targetCFrame)
    if not humanoidRootPart or not humanoid then return false end
    S.isMoving = true
    local targetPos = targetCFrame.Position
    local completed = false
    if S.moveConn then S.moveConn:Disconnect() end
    
    S.moveConn = RunService.RenderStepped:Connect(function(dt)
        if not S.isMoving or not humanoidRootPart or not humanoid then
            if S.moveConn then S.moveConn:Disconnect() end
            return
        end
        
        local currentPos = humanoidRootPart.Position
        local dist = (currentPos - targetPos).Magnitude
        
        if dist < 3.5 or not S.isMoving then
            if S.moveMode == "Walk" then humanoid:Move(Vector3.zero) end
            completed = true
            S.isMoving = false
            if S.moveConn then S.moveConn:Disconnect() end
        else
            if S.moveMode == "Fly" then
                local step = math.min(S.moveSpeed * dt, dist)
                local newPos = currentPos + (targetPos - currentPos).Unit * step
                humanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            else
                local dir = (targetPos - currentPos)
                humanoid:Move(Vector3.new(dir.X, 0, dir.Z).Unit, false)
            end
        end
    end)
    
    while S.isMoving and not completed do task.wait() end
    return true
end
getgenv().KienSafeMoveTo = safeMoveTo

createBtn(getgenv().KienPages.t1, "Lưu Vị Trí Base 1", function()
    if humanoidRootPart then S.base1 = humanoidRootPart.CFrame print("Lưu Base 1 thành công!") end
end)

createBtn(getgenv().KienPages.t1, "Lưu Vị Trí Base 2", function()
    if humanoidRootPart then S.base2 = humanoidRootPart.CFrame print("Lưu Base 2 thành công!") end
end)

createBtn(getgenv().KienPages.t1, "Chạy Hành Trình (2 -> 1 -> 2)", function()
    if not S.base1 or not S.base2 then print("Chưa lưu đủ 2 vị trí Base!") return end
    if S.isMoving then return end
    task.spawn(function()
        S.noclipActive = true
        if safeMoveTo(S.base2) then
            task.wait(0.2)
            if safeMoveTo(S.base1) then
                task.wait(0.2)
                safeMoveTo(S.base2)
            end
        end
        S.isMoving = false
        S.noclipActive = false
        print("Hoàn tất hành trình 2 -> 1 -> 2!")
    end)
end)

createBtn(getgenv().KienPages.t1, "DỪNG HÀNH TRÌNH NGAY", function()
    S.isMoving = false
    if S.moveConn then S.moveConn:Disconnect() end
    if humanoid then humanoid:Move(Vector3.zero) end
    if humanoidRootPart then humanoidRootPart.AssemblyLinearVelocity = Vector3.zero end
end)
-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (PHẦN 2/3)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local S = getgenv().KienHubState or getgenv().KienState
local t2 = getgenv().KienPages.t2
local createBtn = getgenv().KienCreateBtn
local safeMoveTo = getgenv().KienSafeMoveTo

local ClickBtn = createBtn(t2, "Chọn Điểm: TẮT", function() end)
ClickBtn.MouseButton1Click:Connect(function()
    S.clickTpActive = not S.clickTpActive
    ClickBtn.Text = S.clickTpActive and "Chọn Điểm: BẬT" or "Chọn Điểm: TẮT"
    ClickBtn.TextColor3 = S.clickTpActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.clickTpActive then
        S.selectedPos = nil
        if S.markerPart then S.markerPart:Destroy() end
    end
end)

mouse.Button1Down:Connect(function()
    if not S.clickTpActive then return end
    local target, hit = mouse.Target, mouse.Hit
    if target and target:IsA("BasePart") and hit then
        S.selectedPos = hit + Vector3.new(0, 3, 0)
        if S.markerPart then S.markerPart:Destroy() end
        S.markerPart = Instance.new("Part", Workspace)
        S.markerPart.Size = Vector3.new(2, 2, 2)
        S.markerPart.Shape = Enum.PartType.Ball
        S.markerPart.Color = Color3.fromRGB(0, 255, 255)
        S.markerPart.Material = Enum.Material.Neon
        S.markerPart.Transparency = 0.3
        S.markerPart.Anchored = true
        S.markerPart.CanCollide = false
        S.markerPart.CFrame = S.selectedPos
    end
end)

createBtn(t2, "✅ NÚT OK (DI CHUYỂN TỚI ĐIỂM)", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not S.selectedPos or not hrp then return end
    if S.markerPart then S.markerPart:Destroy() end
    task.spawn(function()
        S.noclipActive = true
        safeMoveTo(S.selectedPos)
        S.noclipActive = false
    end)
end)

-- TÍNH NĂNG 1: Khối Theo Chân (Chỉ khi di chuyển ngang trên không/vực mới lót)
local WalkPlatBtn = createBtn(t2, "Khối Đỡ Đi Ngang: TẮT", function() end)
WalkPlatBtn.MouseButton1Click:Connect(function()
    S.autoWalkPlat = not S.autoWalkPlat
    WalkPlatBtn.Text = S.autoWalkPlat and "Khối Đỡ Đi Ngang: BẬT" or "Khối Đỡ Đi Ngang: TẮT"
    WalkPlatBtn.TextColor3 = S.autoWalkPlat and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.autoWalkPlat then
        for _, p in pairs(S.activePlats) do if p then p:Destroy() end end
        S.activePlats = {}
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if S.autoWalkPlat and hrp and hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        local pos = hrp.Position - Vector3.new(0, 3.2, 0)
        local needNew = true
        for _, p in pairs(S.activePlats) do
            if p and (p.Position - pos).Magnitude < 2.5 then needNew = false break end
        end
        if needNew then
            local p = Instance.new("Part", Workspace)
            p.Size = Vector3.new(4, 0.8, 4)
            p.Position = Vector3.new(pos.X, math.floor(pos.Y * 10)/10, pos.Z)
            p.Anchored = true
            p.CanCollide = true
            p.Transparency = 1
            table.insert(S.activePlats, p)
            if #S.activePlats > 20 then
                local old = table.remove(S.activePlats, 1)
                if old then old:Destroy() end
            end
        end
    end
end)

-- TÍNH NĂNG 2: Nhảy Tự Đẻ Khối Lót Đứng Từng Bậc
local JumpPlatBtn = createBtn(t2, "Bật Nhảy Sinh Khối Lót: TẮT", function() end)
JumpPlatBtn.MouseButton1Click:Connect(function()
    S.autoJumpPlat = not S.autoJumpPlat
    JumpPlatBtn.Text = S.autoJumpPlat and "Bật Nhảy Sinh Khối Lót: BẬT" or "Bật Nhảy Sinh Khối Lót: TẮT"
    JumpPlatBtn.TextColor3 = S.autoJumpPlat and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

UserInputService.JumpRequest:Connect(function()
    if S.autoJumpPlat then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            task.wait(0.15)
            local pos = hrp.Position - Vector3.new(0, 3.2, 0)
            local p = Instance.new("Part", Workspace)
            p.Size = Vector3.new(4, 1, 4)
            p.Position = pos
            p.Anchored = true
            p.CanCollide = true
            p.Transparency = 0.6
            p.Material = Enum.Material.SmoothPlastic
            p.Color = Color3.fromRGB(0, 255, 255)
            task.delay(10, function() if p then p:Destroy() end end)
        end
    end
end)

local EspBtn = createBtn(t2, "ESP Player: TẮT", function() end)
EspBtn.MouseButton1Click:Connect(function()
    S.espActive = not S.espActive
    EspBtn.Text = S.espActive and "ESP Player: BẬT" or "ESP Player: TẮT"
    EspBtn.TextColor3 = S.espActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

local function applyEsp(p)
    if p == player then return end
    local function addHighlights(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if not hrp or not head or hrp:FindFirstChild("KienHL") then return end
        
        local hl = Instance.new("Highlight", hrp)
        hl.Name = "KienHL"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        
        local bb = Instance.new("BillboardGui", hrp)
        bb.Name = "KienName"
        bb.Size = UDim2.new(0, 200, 0, 50)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 14
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeTransparency = 0
        
        task.spawn(function()
            while bb and bb.Parent do
                local myChar = player.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHrp and hrp then
                    local d = math.floor((myHrp.Position - hrp.Position).Magnitude)
                    txt.Text = p.Name .. " [" .. d .. "m]"
                end
                task.wait(0.2)
            end
        end)
    end
    p.CharacterAdded:Connect(function(c) if S.espActive then addHighlights(c) end end)
    if p.Character then addHighlights(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do applyEsp(p) end
Players.PlayerAdded:Connect(applyEsp)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hl = hrp:FindFirstChild("KienHL")
                if S.espActive and not hl then applyEsp(p)
                elseif not S.espActive and hl then
                    hl:Destroy()
                    local bb = hrp:FindFirstChild("KienName")
                    if bb then bb:Destroy() end
                end
            end
        end
    end
end)
-- ==========================================
-- SCRIPT: √12kientomato Hub Pro Max (PHẦN 3/3)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local S = getgenv().KienHubState or getgenv().KienState
local t3 = getgenv().KienPages.t3
local createBtn = getgenv().KienCreateBtn

local ModeBtn = createBtn(t3, "Kiểu Di Chuyển: BAY (Fly)", function() end)
ModeBtn.MouseButton1Click:Connect(function()
    if S.moveMode == "Fly" then
        S.moveMode = "Walk"
        ModeBtn.Text = "Kiểu Di Chuyển: KÉO NÚT (Walk)"
        ModeBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        S.moveMode = "Fly"
        ModeBtn.Text = "Kiểu Di Chuyển: BAY (Fly)"
        ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

local SpeedTitle = Instance.new("TextLabel", t3)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Size = UDim2.new(1, -5, 0, 20)
SpeedTitle.Font = Enum.Font.SourceSansBold
SpeedTitle.Text = "Tốc độ di chuyển (Max: 165):"
SpeedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedTitle.TextSize = 12
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left

local SpeedBox = Instance.new("TextBox", t3)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.Size = UDim2.new(1, -5, 0, 28)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.Text = tostring(S.moveSpeed)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedBox.TextSize = 14
SpeedBox.ClearTextOnFocus = false
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 5)

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        S.moveSpeed = math.clamp(val, 1, 165)
        SpeedBox.Text = tostring(S.moveSpeed)
    else
        SpeedBox.Text = tostring(S.moveSpeed)
    end
end)

local NoclipBtn = createBtn(t3, "Noclip & Tạo Khung Bảo Vệ: TẮT", function() end)
NoclipBtn.MouseButton1Click:Connect(function()
    S.noclipActive = not S.noclipActive
    NoclipBtn.Text = S.noclipActive and "Noclip & Tạo Khung Bảo Vệ: BẬT" or "Noclip & Tạo Khung Bảo Vệ: TẮT"
    NoclipBtn.TextColor3 = S.noclipActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
    if not S.noclipActive and S.smartFloor then
        S.smartFloor:Destroy()
        S.smartFloor = nil
    end
end)

-- Quét vị trí trống quanh nhân vật để tự sinh vách tường/sàn trong suốt ngăn việc lọt hố/rớt khỏi map
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if (S.isMoving or S.noclipActive) and char and hrp then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        if S.noclipActive then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}
            
            local downRay = Workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0), rayParams)
            local forwardRay = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, rayParams)
            
            if not downRay or forwardRay then
                if not S.smartFloor then
                    S.smartFloor = Instance.new("Part", Workspace)
                    S.smartFloor.Name = "SmartProtectBarrier"
                    S.smartFloor.Size = Vector3.new(12, 1, 12)
                    S.smartFloor.Anchored = true
                    S.smartFloor.CanCollide = true
                    S.smartFloor.Transparency = 1
                end
                S.smartFloor.Position = hrp.Position - Vector3.new(0, 3.5, 0)
            else
                if S.smartFloor then
                    S.smartFloor:Destroy()
                    S.smartFloor = nil
                end
            end
        end
    else
        if S.smartFloor then
            S.smartFloor:Destroy()
            S.smartFloor = nil
        end
    end
end)

local AfkBtn = createBtn(t3, "Anti-AFK (Treo máy): TẮT", function() end)
AfkBtn.MouseButton1Click:Connect(function()
    S.antiAfkActive = not S.antiAfkActive
    AfkBtn.Text = S.antiAfkActive and "Anti-AFK (Treo máy): BẬT" or "Anti-AFK (Treo máy): TẮT"
    AfkBtn.TextColor3 = S.antiAfkActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 255, 255)
end)

createBtn(t3, "FIX LAG ULTRA CỰC MẠNH", function()
    S.fixLagActive = not S.fixLagActive
    if S.fixLagActive then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v:Destroy()
            end
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                obj.Enabled = false
            end
        end
        print("Bật Fix Lag Ultra thành công!")
    else
        print("Tắt Fix Lag.")
    end
end)
