-- purpose: armor bypass and armor kill execution
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

    ctx.doArmorKill = function(model)
        if not model or not model.Parent then return false end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local info = ctx.gunInfo()
        if not info then return false end
        if not ctx.canFire() then return false end

        ctx.tryBypassArmor(model)

        local dmg = ctx.CONFIG.ArmorDamage
        local partsToHit = {}
        local function tryAdd(name)
            local p = model:FindFirstChild(name)
            if p and p:IsA("BasePart") and not table.find(partsToHit, p) then
                table.insert(partsToHit, p)
            end
        end
        tryAdd("HumanoidRootPart")
        tryAdd("Torso")
        tryAdd("UpperTorso")
        tryAdd("Head")

        local fired = false
        for _, hitPart in ipairs(partsToHit) do
            if not hitPart.Parent or hum.Health <= 0 then break end
            if not ctx.canFire() then break end
            pcall(function() ctx.BR:FireServer(info.barrel.Position, hitPart.Position, info.color, hitPart, false) end)
            ctx.recordFire("Bullet")
            pcall(function() ctx.DR:FireServer(info.gunScript, info.barrel.Position, model, dmg, hitPart, "Bullet") end)
            ctx.recordFire("Damager")
            fired = true
        end
        if fired then
            ctx.STATUS = string.format("Armor %.0f→%s", dmg, model.Name)
            return true
        end
        return false
    end
end
return M