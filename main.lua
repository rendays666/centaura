-- main entry point
-- purpose: entry point wiring all modules
local function req(name)
    if script and script.Parent then
        return require(script.Parent:WaitForChild(name))
    end
    return require(name)
end

local ctx
local function fatal(e)
    if ctx and ctx.FATAL then ctx.FATAL(e) else print("[TREK] FATAL: " .. tostring(e)) end
    pcall(function()
        local pg = (ctx and ctx.PG) or (ctx and ctx.LP and ctx.LP:FindFirstChild("PlayerGui")) or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("TREK_Combined")
        if old then old:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name = "TREK_Combined"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.DisplayOrder = 999
        g.Parent = pg
        local m = Instance.new("Frame")
        m.Size = UDim2.new(0, 240, 0, 120)
        m.Position = UDim2.new(0, 10, 0, 60)
        m.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        m.BorderSizePixel = 0
        m.Parent = g
        Instance.new("UICorner", m).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, -10)
        lbl.Position = UDim2.new(0, 5, 0, 5)
        lbl.BackgroundTransparency = 1
        lbl.Text = "TREK Crash\n" .. tostring(e)
        lbl.TextColor3 = Color3.new(1, 0.7, 0.7)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true
        lbl.Parent = m
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(1, -10, 0, 20)
        cb.Position = UDim2.new(0, 5, 1, -25)
        cb.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
        cb.Text = "Copy log"
        cb.TextColor3 = Color3.fromRGB(255, 230, 150)
        cb.TextSize = 10
        cb.Font = Enum.Font.GothamBold
        cb.BorderSizePixel = 0
        cb.Parent = m
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 3)
        cb.Activated:Connect(function()
            if ctx and ctx.saveLogToClipboard then ctx.saveLogToClipboard() end
        end)
    end)
    if ctx and ctx.saveLogToClipboard then ctx.saveLogToClipboard() end
end

local ok, err = xpcall(function()
    ctx = {}
    req("log").setup(ctx)
    ctx.L("=== START ===")
    req("services").setup(ctx)
    req("config").setup(ctx)
    req("state").setup(ctx)
    req("rate").setup(ctx)
    req("armor_detect").setup(ctx)
    req("armor_damage").setup(ctx)
    req("esp").setup(ctx)
    req("esp_vehicle").setup(ctx)
    req("aim").setup(ctx)
    req("medic_core").setup(ctx)
    req("medic_loop").setup(ctx)
    req("combat").setup(ctx)
    req("targeting_scan").setup(ctx)
    req("targeting_kill").setup(ctx)
    req("leaderboard_ui").setup(ctx)
    req("leaderboard_logic").setup(ctx)
    req("ui_window").setup(ctx)
    req("ui_tabs").setup(ctx)
    req("ui_widgets").setup(ctx)
    req("ui_number").setup(ctx)
    req("ui_widgets_extra").setup(ctx)
    req("tabs_combat").setup(ctx)
    req("tabs_autokill").setup(ctx)
    req("tabs_aim").setup(ctx)
    req("tabs_esp").setup(ctx)
    req("tabs_medic").setup(ctx)
    req("tabs_display").setup(ctx)
    req("loops_render").setup(ctx)
    req("loops_heartbeat").setup(ctx)
    req("loops_tasks").setup(ctx)

    local n = 0
    if ctx.MODULES_OK then
        local okA, res = pcall(ctx.apply)
        n = okA and res or 0
    end
    ctx.STATUS = ctx.MODULES_OK and ("Ready " .. n .. "g") or "No modules"
    ctx.L("=== READY === modules=" .. tostring(ctx.MODULES_OK) .. " guns=" .. n)
end, fatal)

if not ok then
    print("[TREK] Crash: " .. tostring(err))
end