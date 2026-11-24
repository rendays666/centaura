-- purpose: main window, title bar, status bar, drag
local M = {}
function M.setup(ctx)
    local PG = ctx.PG
    local UIS = ctx.UIS
    local Cam = ctx.Cam
    local CONFIG = ctx.CONFIG

    local screenH = Cam.ViewportSize.Y
    local FRAME_W = 240
    local FRAME_H = math.clamp(screenH * 0.72, 400, 600)
    local TITLE_H, TABROW_H, STATUS_H = 24, 44, 40

    ctx.FRAME_W = FRAME_W
    ctx.FRAME_H = FRAME_H
    ctx.TITLE_H = TITLE_H
    ctx.TABROW_H = TABROW_H
    ctx.STATUS_H = STATUS_H

    ctx.gui = Instance.new("ScreenGui")
    ctx.gui.Name = "TREK_Combined"
    ctx.gui.ResetOnSpawn = false
    ctx.gui.IgnoreGuiInset = true
    ctx.gui.DisplayOrder = 999
    ctx.gui.Parent = PG

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
    main.Position = UDim2.new(1, -FRAME_W - 5, 0, 60)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = ctx.gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 160)
    stroke.Thickness = 1.5
    stroke.Parent = main
    ctx.main = main

    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, 0, 0, TITLE_H)
    tb.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    tb.BorderSizePixel = 0
    tb.Active = true
    tb.Parent = main
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 7)
    ctx.tb = tb

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -50, 1, 0)
    tl.Position = UDim2.new(0, 8, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = CONFIG.Title
    tl.TextColor3 = Color3.fromRGB(0, 220, 160)
    tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tb

    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 20, 0, 20)
    mBtn.Position = UDim2.new(1, -44, 0, 2)
    mBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mBtn.Text = "-"
    mBtn.TextColor3 = Color3.new(1, 1, 1)
    mBtn.TextSize = 14
    mBtn.Font = Enum.Font.GothamBold
    mBtn.BorderSizePixel = 0
    mBtn.AutoButtonColor = false
    mBtn.Parent = tb
    Instance.new("UICorner", mBtn).CornerRadius = UDim.new(0, 3)
    ctx.mBtn = mBtn

    local xBtn = Instance.new("TextButton")
    xBtn.Size = UDim2.new(0, 20, 0, 20)
    xBtn.Position = UDim2.new(1, -22, 0, 2)
    xBtn.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
    xBtn.Text = "X"
    xBtn.TextColor3 = Color3.new(1, 1, 1)
    xBtn.TextSize = 11
    xBtn.Font = Enum.Font.GothamBold
    xBtn.BorderSizePixel = 0
    xBtn.AutoButtonColor = false
    xBtn.Parent = tb
    Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0, 3)
    ctx.xBtn = xBtn

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -6, 0, STATUS_H)
    statusBar.Position = UDim2.new(0, 3, 1, -STATUS_H - 2)
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = main
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 4)
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -8, 1, -4)
    statusLbl.Position = UDim2.new(0, 4, 0, 2)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Booting..."
    statusLbl.TextColor3 = Color3.fromRGB(140, 220, 190)
    statusLbl.TextSize = 9
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.TextYAlignment = Enum.TextYAlignment.Top
    statusLbl.TextWrapped = true
    statusLbl.Parent = statusBar
    ctx.statusBar = statusBar
    ctx.statusLbl = statusLbl

    local minimized = false
    mBtn.Activated:Connect(function()
        minimized = not minimized
        main.Size = UDim2.new(0, FRAME_W, 0, minimized and TITLE_H or FRAME_H)
        if ctx.tabBar then ctx.tabBar.Visible = not minimized end
        if ctx.content then ctx.content.Visible = not minimized end
        statusBar.Visible = not minimized
        mBtn.Text = minimized and "+" or "-"
    end)

    xBtn.Activated:Connect(function()
        local opts = ctx.opts
        for k in pairs(opts) do if type(opts[k]) == "boolean" then opts[k] = false end end
        if ctx.MODULES_OK then ctx.apply() end
        for k in pairs(ctx.pending) do ctx.pending[k] = nil end
        ctx.clearPlayerESP()
        if ctx.fovCircle then pcall(function() ctx.fovCircle:Remove() end) end
        ctx.gui:Destroy()
        ctx.lbGui:Destroy()
    end)

    do
        local d, s, sp = false, nil, nil
        tb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = true
                s = i.Position
                sp = main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = false
            end
        end)
    end
end
return M