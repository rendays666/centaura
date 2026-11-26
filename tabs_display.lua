-- purpose: Display tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_DISPLAY]
    ctx.newSection(p, "PANELS",
        "- Leaderboard: shows or hides the in-game leaderboard panel.")
    local lbBtn = Instance.new("TextButton")
    lbBtn.Size = UDim2.new(1, 0, 0, 28)
    lbBtn.BackgroundColor3 = ctx.lbGui.Enabled and Color3.fromRGB(180, 140, 20) or Color3.fromRGB(40, 40, 58)
    lbBtn.Text = "Leaderboard  [" .. (ctx.lbGui.Enabled and "ON" or "OFF") .. "]"
    lbBtn.TextColor3 = Color3.fromRGB(255, 220, 120)
    lbBtn.TextSize = 11
    lbBtn.Font = Enum.Font.GothamSemibold
    lbBtn.BorderSizePixel = 0
    lbBtn.AutoButtonColor = false
    lbBtn.LayoutOrder = ctx.nextOrder(p)
    lbBtn.Parent = p
    Instance.new("UICorner", lbBtn).CornerRadius = UDim.new(0, 4)
    lbBtn.Activated:Connect(function()
        ctx.lbGui.Enabled = not ctx.lbGui.Enabled
        lbBtn.BackgroundColor3 = ctx.lbGui.Enabled and Color3.fromRGB(180, 140, 20) or Color3.fromRGB(40, 40, 58)
        lbBtn.Text = "Leaderboard  [" .. (ctx.lbGui.Enabled and "ON" or "OFF") .. "]"
        if ctx.lbGui.Enabled then pcall(ctx.buildLB) end
    end)
    ctx.newSection(p, "TOOLS",
        "- Copy Error Log: copies the script log to your clipboard so you can report a bug.")
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, 0, 0, 28)
    copyBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
    copyBtn.Text = "Copy Error Log"
    copyBtn.TextColor3 = Color3.fromRGB(255, 230, 150)
    copyBtn.TextSize = 11
    copyBtn.Font = Enum.Font.GothamSemibold
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.LayoutOrder = ctx.nextOrder(p)
    copyBtn.Parent = p
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
    copyBtn.Activated:Connect(function()
        local o = ctx.saveLogToClipboard()
        copyBtn.Text = o and "Copied!" or "Copy Failed"
        task.wait(1.5)
        copyBtn.Text = "Copy Error Log"
    end)
    ctx.newSection(p, "MODULE STATUS",
        "Read-only script status.\n" ..
        "- Modules: OK or MISSING.\n" ..
        "- Guns: number of gun modules found.\n" ..
        "- Remotes: Bullet / Damager remote status.")
    local modInfo = Instance.new("TextLabel")
    modInfo.Size = UDim2.new(1, 0, 0, 50)
    modInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    modInfo.Text = "Checking..."
    modInfo.TextColor3 = Color3.fromRGB(140, 220, 180)
    modInfo.TextSize = 10
    modInfo.Font = Enum.Font.Code
    modInfo.TextXAlignment = Enum.TextXAlignment.Left
    modInfo.TextYAlignment = Enum.TextYAlignment.Top
    modInfo.TextWrapped = true
    modInfo.LayoutOrder = ctx.nextOrder(p)
    modInfo.Parent = p
    Instance.new("UICorner", modInfo).CornerRadius = UDim.new(0, 4)
    task.spawn(function()
        task.wait(0.5)
        local gunCount = 0
        if ctx.GS then
            for _, inst in ipairs(ctx.GS:GetDescendants()) do
                if inst:IsA("ModuleScript") then gunCount = gunCount + 1 end
            end
        end
        while ctx.gui.Parent do
            modInfo.Text = string.format("Modules: %s\nGuns: %d\nRemotes: %s",
                ctx.MODULES_OK and "OK" or "MISSING", gunCount,
                (ctx.BR and "OK" or "NO") .. " / " .. (ctx.DR and "OK" or "NO"))
            task.wait(3)
        end
    end)
end
return M
