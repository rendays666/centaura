-- purpose: Medic tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_MEDIC]
    ctx.newSection(p, "STATUS")
    local medicStatus = Instance.new("TextLabel")
    medicStatus.Size = UDim2.new(1, 0, 0, 44)
    medicStatus.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    medicStatus.Text = "Medic: OFF"
    medicStatus.TextColor3 = Color3.fromRGB(140, 220, 180)
    medicStatus.TextSize = 10
    medicStatus.Font = Enum.Font.Code
    medicStatus.TextXAlignment = Enum.TextXAlignment.Left
    medicStatus.TextYAlignment = Enum.TextYAlignment.Top
    medicStatus.TextWrapped = true
    medicStatus.LayoutOrder = ctx.nextOrder(p)
    medicStatus.Parent = p
    Instance.new("UICorner", medicStatus).CornerRadius = UDim.new(0, 4)
    task.spawn(function()
        while ctx.gui.Parent do
            task.wait(0.3)
            if ctx.opts.MedicEnabled then
                local bandage = ctx.isBandageReady() and "READY" or "CD"
                medicStatus.Text = string.format("State: %s\nQueue: %d | %s | %s",
                    ctx.medicState, #ctx.medicQueue, bandage,
                    ctx.medicCurrentPatient and ctx.medicCurrentPatient.Name or "-")
            else
                medicStatus.Text = "Medic: OFF"
            end
        end
    end)
    ctx.newSection(p, "MEDIC MODE")
    ctx.newToggle(p, "Medic Enabled", "MedicEnabled", function(v)
        if v then ctx.medicSaveLocation() end
        ctx.medicState = "IDLE"
        ctx.medicQueue = {}
    end)
    ctx.newSection(p, "SETTINGS")
    ctx.newNumber(p, "HP Threshold %", ctx.medicHPThreshold, 5, 95, 5, 0, function(v) ctx.medicHPThreshold = v end)
    ctx.newNumber(p, "Below Studs", ctx.medicBelowStuds, 2, 50, 1, 0, function(v) ctx.medicBelowStuds = v end)
    ctx.newNumber(p, "Teleport Wait", ctx.medicTeleportWait, 0.1, 5, 0.1, 1, function(v) ctx.medicTeleportWait = v end)
    ctx.newDropdown(p, "Position", { "Below", "Front" }, ctx.medicPositionMode, function(v) ctx.medicPositionMode = v end)
    local humBtn = Instance.new("TextButton")
    humBtn.Size = UDim2.new(1, 0, 0, 28)
    humBtn.BackgroundColor3 = ctx.medicHumanize and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    humBtn.Text = "Humanize  [" .. (ctx.medicHumanize and "ON" or "OFF") .. "]"
    humBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    humBtn.TextSize = 11
    humBtn.Font = Enum.Font.GothamSemibold
    humBtn.BorderSizePixel = 0
    humBtn.AutoButtonColor = false
    humBtn.LayoutOrder = ctx.nextOrder(p)
    humBtn.Parent = p
    Instance.new("UICorner", humBtn).CornerRadius = UDim.new(0, 4)
    humBtn.Activated:Connect(function()
        ctx.medicHumanize = not ctx.medicHumanize
        humBtn.BackgroundColor3 = ctx.medicHumanize and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        humBtn.Text = "Humanize  [" .. (ctx.medicHumanize and "ON" or "OFF") .. "]"
        if ctx.requestSave then ctx.requestSave() end
    end)
end
return M