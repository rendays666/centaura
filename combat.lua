-- purpose: weapon module stat apply/reapply and reequip
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local GS = ctx.GS
    local opts = ctx.opts
    local originals = ctx.originals

    ctx.apply = function()
        if not GS then return 0 end
        local hit = 0
        for _, inst in ipairs(GS:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                local okR, s = pcall(require, inst)
                if okR and type(s) == "table" then
                    if not originals[inst] then
                        originals[inst] = {
                            Recoil = s.Recoil, MinDamage = s.MinDamage, MaxDamage = s.MaxDamage,
                            HeadshotMultiplier = s.HeadshotMultiplier, LimbMultiplier = s.LimbMultiplier,
                            AmmoCount = s.AmmoCount, ChargeSpeed = s.ChargeSpeed, ReloadSpeed = s.ReloadSpeed,
                            spread = s.spread, minimumSpread = s.minimumSpread, firerate = s.firerate,
                        }
                    end
                    local o = originals[inst]
                    local function ss(k, v)
                        if rawget(s, k) ~= nil then pcall(function() s[k] = v end) end
                    end
                    ss("Recoil", opts.NoRecoil and 0 or o.Recoil)
                    ss("MinDamage", opts.OneHit and 999999 or o.MinDamage)
                    ss("MaxDamage", opts.OneHit and 999999 or o.MaxDamage)
                    ss("HeadshotMultiplier", opts.OneHit and 1 or o.HeadshotMultiplier)
                    ss("LimbMultiplier", opts.OneHit and 1 or o.LimbMultiplier)
                    ss("spread", opts.NoSpread and 0 or o.spread)
                    ss("minimumSpread", opts.NoSpread and 0 or o.minimumSpread)
                    ss("firerate", opts.NoCooldown and ctx.INSTANT_FIRERATE or o.firerate)
                    ss("ChargeSpeed", opts.NoReload and 0.001 or o.ChargeSpeed)
                    ss("ReloadSpeed", opts.NoReload and 0.001 or o.ReloadSpeed)
                    ss("AmmoCount", opts.NoReload and 9999 or o.AmmoCount)
                    hit = hit + 1
                end
            end
        end
        return hit
    end

    ctx.reequip = function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        local t = c:FindFirstChildOfClass("Tool")
        if h and t then
            task.spawn(function()
                pcall(function() h:UnequipTools() end)
                task.wait(0.12)
                pcall(function() h:EquipTool(t) end)
            end)
        end
    end
end
return M