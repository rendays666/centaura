-- purpose: armor bypass and tank/vehicle damage (no humanoid required)
local M = {}
function M.setup(ctx)
    ctx.tryBypassArmor = function(model)
        if not ctx.CONFIG.BypassArmorLocal then return end
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p:GetAttribute("Armored") then
                pcall(function() p:SetAttribute("NoProtection", true) end)
            end
            if p.Name == "Plate" then
                local np = p:FindFirstChild("NoPenetration")
                if np and np:IsA("NumberValue") then
                    pcall(function() np.Value = 0 end)
                end
            end
        end
    end

    ctx.pickArmorParts = function(model)
        local pts = {}
        local function add(p)
            if p and p:IsA("BasePart") and p.Parent and not table.find(pts, p) then
                table.insert(pts, p)
            end
        end
        for _, name in ipairs({ "Engine", "EnginePart", "Motor", "Transmission", "Gearbox",
            "FuelTank", "Core", "Hull", "Chassis", "Body", "Turret", "Gun", "Plate",
            "HumanoidRootPart", "Head", "Torso", "UpperTorso" }) do
            add(model:FindFirstChild(name, true))
        end
        if #pts == 0 then
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") and p:GetAttribute("Armored") then add(p) end
            end
        end
        if #pts == 0 then
            add(model.PrimaryPart)
            add(model:FindFirstChildOfClass("BasePart"))
        end
        return pts
    end

    ctx.doArmorKill = function(model)
        if not model or not model.Parent then return false end
        local info = ctx.gunInfo()
        if not info then return false end
        if not ctx.canFire() then return false end

        ctx.tryBypassArmor(model)

        local dmg = ctx.CONFIG.ArmorDamage
        local partsToHit = ctx.pickArmorParts(model)
        local fired = false
        for i = 1, math.min(#partsToHit, 4) do
            local hitPart = partsToHit[i]
            if not ctx.canFire() then break end
            pcall(function() ctx.BR:FireServer(info.barrel.Position, hitPart.Position, info.color, hitPart, false) end)
            ctx.recordFire("Bullet")
            pcall(function() ctx.DR:FireServer(info.gunScript, info.barrel.Position, model, dmg, hitPart, "Bullet") end)
            ctx.recordFire("Damager")
            fired = true
        end
        if fired then
            ctx.STATUS = string.format("TANK %.0f→%s", dmg, model.Name)
            return true
        end
        return false
    end
end
return M
