-- purpose: client-side tank pulling + wreck cleanup (replaces auto damage tank)
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local workspace = ctx.workspace

    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    ctx.scanEnemyArmor = function()
        local list = {}
        local root = vehiclesRoot()
        if not root then return list end
        for _, child in ipairs(root:GetChildren()) do
            local veh = child:FindFirstChild("Vehicle")
            if veh then list[#list + 1] = veh end
        end
        return list
    end
    ctx.scanVehicles = ctx.scanEnemyArmor

    local function isTankDestroyed(vehicleModel, vehicle)
        local hpVal = vehicle:FindFirstChild("Health") or vehicle:FindFirstChild("HP") or vehicleModel:FindFirstChild("Health")
        if hpVal and hpVal:IsA("ValueBase") and hpVal.Value <= 0 then return true end

        local hpAttr = vehicle:GetAttribute("Health")
        if hpAttr and hpAttr <= 0 then return true end
        if vehicle:GetAttribute("Destroyed") or vehicleModel:GetAttribute("Destroyed") then return true end

        local hum = vehicle:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health <= 0 then return true end

        local n = string.lower(vehicleModel.Name)
        if string.find(n, "wreck") or string.find(n, "destroyed") then return true end

        local fire = vehicle:FindFirstChildWhichIsA("Fire", true) or vehicle:FindFirstChildWhichIsA("Smoke", true)
        if fire then return true end

        return false
    end
    ctx.isTankDestroyed = isTankDestroyed

    local function isFriendlyVehicle(vehicleModel, vehicle)
        local myTeam = LP.Team
        if not myTeam then return false end
        if string.find(string.lower(vehicleModel.Name), string.lower(myTeam.Name)) then return true end

        local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        if seat and seat.Occupant then
            local driver = ctx.Players:GetPlayerFromCharacter(seat.Occupant.Parent)
            if driver and driver.Team == myTeam then return true end
        end
        return false
    end

    -- Pulls enemy tanks to the player; destroyed tanks are dropped far below.
    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.2)
            ctx.armorCache = ctx.scanEnemyArmor()
            if ctx.opts.PullTanks then
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local root = vehiclesRoot()
                if hrp and root then
                    local pullDist = ctx.pullDistance or 15
                    for _, vehicleModel in ipairs(root:GetChildren()) do
                        local vehicle = vehicleModel:FindFirstChild("Vehicle")
                        if vehicle and not isFriendlyVehicle(vehicleModel, vehicle) then
                            if isTankDestroyed(vehicleModel, vehicle) then
                                pcall(function()
                                    local pos = vehicle:GetPivot()
                                    if pos.Y > -500 then
                                        vehicle:PivotTo(pos * CFrame.new(0, -500, 0))
                                        for _, part in ipairs(vehicle:GetDescendants()) do
                                            if part:IsA("BasePart") then part.Anchored = true end
                                        end
                                    end
                                end)
                            else
                                local dist = (hrp.Position - vehicle:GetPivot().Position).Magnitude
                                if dist > 20 then
                                    local targetPos = hrp.CFrame * CFrame.new(0, 0, -pullDist)
                                    pcall(function()
                                        vehicle:PivotTo(targetPos)
                                        for _, part in ipairs(vehicle:GetDescendants()) do
                                            if part:IsA("BasePart") then part.Anchored = true end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
return M
