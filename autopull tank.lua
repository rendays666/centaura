-- [[ CENTAURA - PULL TANKS (CLIENT-SIDE) + ANTI-WRECK ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Config = {
    PullTanks = false,
    ESP = false,
    PullDistance = 15 -- Jarak tank di depan kita (studs)
}

---------------------------------------------------------
-- UI & LOGGER SETUP
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CentauraPull"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Centaura - Pull Tank (Clean)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(1, -20, 0, 40)
BtnContainer.Position = UDim2.new(0, 10, 0, 45)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = MainFrame

local PullBtn = Instance.new("TextButton")
PullBtn.Size = UDim2.new(0.48, 0, 1, 0)
PullBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
PullBtn.Text = "PULL: OFF"
PullBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PullBtn.Font = Enum.Font.GothamBold
PullBtn.TextSize = 12
PullBtn.Parent = BtnContainer
Instance.new("UICorner", PullBtn).CornerRadius = UDim.new(0, 6)

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.48, 0, 1, 0)
EspBtn.Position = UDim2.new(0.52, 0, 0, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
EspBtn.Text = "ESP: OFF"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextSize = 12
EspBtn.Parent = BtnContainer
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 40)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 95)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Bangkai tank akan dibuang otomatis agar tidak menutupi pandangan."
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextWrapped = true
InfoLabel.Parent = MainFrame

---------------------------------------------------------
-- FUNGSI CEK BANGKAI (WRECK)
---------------------------------------------------------
local function isTankDestroyed(vehicleModel, vehicle)
    -- 1. Cek Health/HP
    local hpVal = vehicle:FindFirstChild("Health") or vehicle:FindFirstChild("HP") or vehicleModel:FindFirstChild("Health")
    if hpVal and hpVal:IsA("ValueBase") and hpVal.Value <= 0 then return true end
    
    -- 2. Cek Attribute
    if vehicle:GetAttribute("Health") and vehicle:GetAttribute("Health") <= 0 then return true end
    if vehicle:GetAttribute("Destroyed") or vehicleModel:GetAttribute("Destroyed") then return true end

    -- 3. Cek Humanoid (jika tank pakai sistem Humanoid)
    local hum = vehicle:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.Health <= 0 then return true end

    -- 4. Cek Nama
    if string.find(string.lower(vehicleModel.Name), "wreck") or string.find(string.lower(vehicleModel.Name), "destroyed") then
        return true
    end

    -- 5. Cek Api/Asap (Tanda tank hancur)
    local fire = vehicle:FindFirstChildWhichIsA("Fire", true) or vehicle:FindFirstChildWhichIsA("Smoke", true)
    if fire then return true end

    return false
end

---------------------------------------------------------
-- LOGIKA ESP
---------------------------------------------------------
local Highlights = {}
local function updateESP()
    for vehicle, highlight in pairs(Highlights) do
        if not vehicle.Parent or not Config.ESP then
            highlight:Destroy()
            Highlights[vehicle] = nil
        end
    end
    if not Config.ESP then return end

    local vehiclesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Map") and workspace.Map.Map:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, vehicleModel in pairs(vehiclesFolder:GetChildren()) do
            local vehicle = vehicleModel:FindFirstChild("Vehicle")
            -- Hanya beri ESP pada tank yang masih hidup
            if vehicle and not Highlights[vehicle] and not isTankDestroyed(vehicleModel, vehicle) then
                local hl = Instance.new("Highlight")
                hl.Adornee = vehicle
                hl.FillColor = Color3.fromRGB(255, 50, 50)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.6
                hl.Parent = vehicle
                Highlights[vehicle] = hl
            end
        end
    end
end

task.spawn(function() while task.wait(1) do pcall(updateESP) end end)

---------------------------------------------------------
-- FUNGSI FILTER TIM
---------------------------------------------------------
local function isFriendlyVehicle(vehicleModel, vehicle)
    local myTeam = LocalPlayer.Team
    if not myTeam then return false end

    if string.find(string.lower(vehicleModel.Name), string.lower(myTeam.Name)) then
        return true
    end

    local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat and seat.Occupant then
        local driverPlayer = Players:GetPlayerFromCharacter(seat.Occupant.Parent)
        if driverPlayer and driverPlayer.Team == myTeam then
            return true
        end
    end

    return false
end

---------------------------------------------------------
-- LOGIKA PULL TANK & AUTO RETURN WRECK
---------------------------------------------------------
PullBtn.MouseButton1Click:Connect(function()
    Config.PullTanks = not Config.PullTanks
    PullBtn.BackgroundColor3 = Config.PullTanks and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    PullBtn.Text = Config.PullTanks and "PULL: ON" or "PULL: OFF"
end)

EspBtn.MouseButton1Click:Connect(function()
    Config.ESP = not Config.ESP
    EspBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    EspBtn.Text = Config.ESP and "ESP: ON" or "ESP: OFF"
end)

-- Loop Penarik Tank
task.spawn(function()
    while task.wait(0.2) do 
        if not Config.PullTanks then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local vehiclesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Map") and workspace.Map.Map:FindFirstChild("Vehicles")
        
        if vehiclesFolder then
            for _, vehicleModel in pairs(vehiclesFolder:GetChildren()) do
                local vehicle = vehicleModel:FindFirstChild("Vehicle")
                
                if vehicle then
                    -- 1. JANGAN TARIK TANK KAWAN
                    if isFriendlyVehicle(vehicleModel, vehicle) then continue end
                    
                    -- 2. JIKA BANGKAI, BUANG JAUH KE BAWAH TANAH (Client-Side)
                    if isTankDestroyed(vehicleModel, vehicle) then
                        local currentPos = vehicle:GetPivot()
                        if currentPos.Y > -500 then -- Cek apakah belum dibuang
                            -- Buang 500 studs ke bawah
                            vehicle:PivotTo(currentPos * CFrame.new(0, -500, 0))
                            for _, part in pairs(vehicle:GetDescendants()) do
                                if part:IsA("BasePart") then part.Anchored = true end
                            end
                        end
                        continue -- Skip, jangan ditarik ke depan
                    end
                    
                    -- 3. TARIK TANK YANG MASIH SEHAT
                    local dist = (hrp.Position - vehicle:GetPivot().Position).Magnitude
                    
                    if dist > 20 then
                        local targetPos = hrp.CFrame * CFrame.new(0, 0, -Config.PullDistance) 
                        
                        pcall(function()
                            vehicle:PivotTo(targetPos)
                            for _, part in pairs(vehicle:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = true
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)
