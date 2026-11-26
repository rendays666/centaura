-- purpose: Combat tab UI (weapon mods, armor damage, actions)
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_COMBAT]
    ctx.newSection(p, "WEAPON MODS")
    ctx.newToggle(p, "No Recoil", "NoRecoil", nil,
        "Removes vertical and horizontal recoil from your shots.")
    ctx.newToggle(p, "No Spread", "NoSpread", nil,
        "Removes bullet spread so every shot flies straight.")
    ctx.newToggle(p, "No Cooldown", "NoCooldown", nil,
        "Removes the delay between shots.")
    ctx.newToggle(p, "No Reload", "NoReload", nil,
        "Removes reload time and keeps your magazine full.")
    ctx.newToggle(p, "One Hit Kill", "OneHit", nil,
        "Raises weapon damage to a very high value so a single shot kills.")
    ctx.newSection(p, "TANK / VEHICLE")
    ctx.newToggle(p, "Auto Pull Tank", "PullTanks", nil,
        "Pulls nearby tanks and vehicles toward you on the client.")
    ctx.newNumber(p, "Pull Distance", ctx.pullDistance, 5, 50, 1, 0, function(v)
        ctx.pullDistance = v
        ctx.CONFIG.PullDistance = v
    end, "How far away a tank can be when Auto Pull Tank is ON.")
    ctx.newSection(p, "ACTIONS")
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -22, 0, 28)
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
    local bInfo = ctx.newInfoButton("Reapply Mods",
        "Re-applies every weapon modification and re-equips your current gun.")
    bInfo.Position = UDim2.new(1, -20, 0, 5)
    bInfo.Parent = b
    b.Activated:Connect(function()
        if ctx.MODULES_OK then ctx.apply(); ctx.reequip() end
    end)
end
return M
