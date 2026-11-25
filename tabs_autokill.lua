-- purpose: AutoKill tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_AUTOKILL]
    ctx.newSection(p, "AUTO KILL")
    ctx.newToggle(p, "Auto Kill", "AutoKill")
    ctx.newToggle(p, "Sekarat Mode", "SekaratMode")
    ctx.newSection(p, "TARGET MODE")
    local modeRow = Instance.new("Frame")
    modeRow.Size = UDim2.new(1, 0, 0, 28)
    modeRow.BackgroundTransparency = 1
    modeRow.LayoutOrder = ctx.nextOrder(p)
    modeRow.Parent = p
    local nBtn = Instance.new("TextButton")
    nBtn.Size = UDim2.new(0.5, -2, 1, 0)
    nBtn.BackgroundColor3 = ctx.targetMode == "Nearest" and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    nBtn.Text = "Nearest"
    nBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    nBtn.TextSize = 11
    nBtn.Font = Enum.Font.GothamSemibold
    nBtn.BorderSizePixel = 0
    nBtn.AutoButtonColor = false
    nBtn.Parent = modeRow
    Instance.new("UICorner", nBtn).CornerRadius = UDim.new(0, 4)
    local qBtn = Instance.new("TextButton")
    qBtn.Size = UDim2.new(0.5, -2, 1, 0)
    qBtn.Position = UDim2.new(0.5, 2, 0, 0)
    qBtn.BackgroundColor3 = ctx.targetMode == "Queue" and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    qBtn.Text = "Queue"
    qBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    qBtn.TextSize = 11
    qBtn.Font = Enum.Font.GothamSemibold
    qBtn.BorderSizePixel = 0
    qBtn.AutoButtonColor = false
    qBtn.Parent = modeRow
    Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0, 4)
    nBtn.Activated:Connect(function()
        ctx.targetMode = "Nearest"
        ctx.lockedTarget = nil
        ctx.lastTargeted = nil
        nBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        qBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        if ctx.requestSave then ctx.requestSave() end
    end)
    qBtn.Activated:Connect(function()
        ctx.targetMode = "Queue"
        ctx.lockedTarget = nil
        ctx.lastTargeted = nil
        nBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        qBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        if ctx.requestSave then ctx.requestSave() end
    end)
    ctx.newSection(p, "KILL VALUES")
    ctx.newNumber(p, "Cooldown (s)", ctx.autoKillCooldown, 0.15, 60, 0.1, 1, function(v) ctx.autoKillCooldown = v end)
    ctx.newNumber(p, "Damage", ctx.autoKillDamage, 1, 999999, 10, 0, function(v) ctx.autoKillDamage = v end)
    ctx.newNumber(p, "Sekarat HP", ctx.minHP, 1, 99999, 5, 0, function(v) ctx.minHP = v end)
    ctx.newNumber(p, "Max fires/s", ctx.maxFiresPerSec, 1, 15, 1, 0, function(v) ctx.maxFiresPerSec = v end)
    ctx.newSection(p, "ACTIONS")
    ctx.newActionRow(p, "Reset Queue", function()
        ctx.lastTargeted = nil
        ctx.lockedTarget = nil
        for k in pairs(ctx.pending) do ctx.pending[k] = nil end
    end, "Clear Blacklist", function()
        for k in pairs(ctx.failCounts) do ctx.failCounts[k] = nil end
        for k in pairs(ctx.blacklist) do ctx.blacklist[k] = nil end
    end)
end
return M