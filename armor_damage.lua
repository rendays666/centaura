-- purpose: dynamic vehicle damage via DamagerRemote (no hardcoded tank/weapon names)
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local workspace = ctx.workspace

    -- workspace.Map.Map.Vehicles holds the tank/armored-car models.
    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    -- Each Vehicles child owns a "Vehicle" folder/model with "HullModel" inside.
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

    -- Random BasePart from HullModel:GetChildren(); falls back to any BasePart.
    ctx.pickArmorParts = function(veh)
        local pts = {}
        if not veh or not veh.Parent then return pts end
        local hull = veh:FindFirstChild("HullModel")
        if hull then
            for _, p in ipairs(hull:GetChildren()) do
                if p:IsA("BasePart") then pts[#pts + 1] = p end
            end
        end
        if #pts == 0 then
            for _, p in ipairs(veh:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent then pts[#pts + 1] = p end
            end
        end
        return pts
    end

    local function vehicleRef(veh)
        local hull = veh and veh:FindFirstChild("HullModel")
        if hull then
            return hull.PrimaryPart or hull:FindFirstChildOfClass("BasePart")
        end
        return veh.PrimaryPart or veh:FindFirstChildOfClass("BasePart")
    end
    ctx.vehicleRef = vehicleRef

    ctx.getEquippedTool = function()
        local c = LP.Character
        return c and c:FindFirstChildOfClass("Tool") or nil
    end

    ctx.getNearestVehicle = function()
        local root = vehiclesRoot()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root or not hrp then return nil end
        local my = hrp.Position
        local best, bestD = nil, math.huge
        for _, child in ipairs(root:GetChildren()) do
            local veh = child:FindFirstChild("Vehicle")
            local ref = veh and vehicleRef(veh)
            if ref and ref.Parent then
                local d = (ref.Position - my).Magnitude
                if d < bestD and d <= ctx.CONFIG.MaxArmorDistance then
                    best, bestD = veh, d
                end
            end
        end
        return best
    end

    -- DamagerRemote(tool,Vector3,vehicle,damage,part,weaponName)
    ctx.doArmorKill = function(veh)
        if not veh or not veh.Parent then return false end
        local tool = ctx.getEquippedTool()
        if not tool then return false end
        if not ctx.canFire() then return false end

        local parts = ctx.pickArmorParts(veh)
        if #parts == 0 then return false end
        local part = parts[math.random(1, #parts)]

        local barrel = tool:FindFirstChild("Barrel")
        local handle = tool:FindFirstChild("Handle")
        local pos = (barrel and barrel.Position) or (handle and handle.Position) or part.Position
        local dmg = math.floor(ctx.CONFIG.ArmorDamage)
        if dmg < 1 then dmg = 1 end

        local okF = pcall(function()
            ctx.DR:FireServer(tool, pos, veh, dmg, part, tool.Name)
        end)
        ctx.recordFire("Damager")
        if okF then
            ctx.STATUS = string.format("VEH %.0f→%s", dmg, (veh.Parent and veh.Parent.Name) or veh.Name)
            return true
        end
        return false
    end

    -- Auto damage runs alongside the vehicle ESP loop (0.1s between attempts).
    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.1)
            if ctx.MODULES_OK and (ctx.opts.DamageArmor or ctx.opts.ArmorESP) then
                ctx.armorCache = ctx.scanEnemyArmor()
            end
            if ctx.MODULES_OK and ctx.opts.DamageArmor then
                local veh = ctx.getNearestVehicle()
                if veh then pcall(ctx.doArmorKill, veh) end
            end
        end
    end)
end
return M
