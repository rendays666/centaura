-- purpose: Combat tab UI (weapon mods, armor damage, actions)
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_COMBAT]
    ctx.newSection(p, "WEAPON MODS",
        "Applies only while a gun is equipped.\n" ..
        "- No Recoil: removes gun recoil.\n" ..
        "- No Spread: shots fly straight.\n" ..
        "- No Cooldown: removes the delay between shots.\n" ..
        "- No Reload: full magazine, no reload.\n" ..
        "- One Hit Kill: raises damage so one shot kills.")
    ctx.newToggle(p, "No Recoil", "NoRecoil")
    ctx.newToggle(p, "No Spread", "NoSpread")
    ctx.newToggle(p, "No Cooldown", "NoCooldown")
    ctx.newToggle(p, "No Reload", "NoReload")
    ctx.newToggle(p, "One Hit Kill", "OneHit")
    ctx.newSection(p, "TANK / VEHICLE",
        "- Auto Pull Tank: pulls nearby tanks and vehicles toward you on the client.\n" ..
        "- Pull Distance: how far away a tank can be when pulling.")
    ctx.newToggle(p, "Auto Pull Tank", "PullTanks")
    ctx.newNumber(p, "Pull Distance", ctx.pullDistance, 5, 50, 1, 0, function(v)
        ctx.pullDistance = v
        ctx.CONFIG.PullDistance = v
    end)
    ctx.newSection(p, "ACTIONS",
        "- Reapply Mods: re-applies every weapon modification and re-equips your current gun.")
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
