-- purpose: Combat tab UI (weapon mods, armor damage, actions)
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_COMBAT]
    ctx.newSection(p, "WEAPON MODS")
    ctx.newToggle(p, "No Recoil", "NoRecoil")
    ctx.newToggle(p, "No Spread", "NoSpread")
    ctx.newToggle(p, "No Cooldown", "NoCooldown")
    ctx.newToggle(p, "No Reload", "NoReload")
    ctx.newToggle(p, "One Hit Kill", "OneHit")
    ctx.newSection(p, "TANK / VEHICLE")
    ctx.newToggle(p, "Auto Damage Tank", "DamageArmor")
    ctx.newNumber(p, "Armor Damage", ctx.CONFIG.ArmorDamage, 100, 999999, 100, 0, function(v)
        ctx.CONFIG.ArmorDamage = v
    end)
    ctx.newNumber(p, "Max Dist (m)", ctx.CONFIG.MaxArmorDistance, 50, 2000, 50, 0, function(v)
        ctx.CONFIG.MaxArmorDistance = v
    end)
    ctx.newNumber(p, "Scan Rate (s)", ctx.CONFIG.ArmorScanInterval, 0.2, 5, 0.1, 1, function(v)
        ctx.CONFIG.ArmorScanInterval = v
    end)
    ctx.newSection(p, "ACTIONS")
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
    b.Text = "Reapply Mods"
    b.TextColor3 = Color3.fromRGB(220, 220, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamSemibold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.LayoutOrder = ctx.nextOrder(p)
    b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.Activated:Connect(function()
        if ctx.MODULES_OK then ctx.apply(); ctx.reequip() end
    end)
end
return M