-- purpose: main window, title bar, status bar, drag, floating toggle logo
local M = {}
function M.setup(ctx)
    local UIS = ctx.UIS
    local Cam = ctx.Cam
    local CONFIG = ctx.CONFIG

    local screenH = Cam.ViewportSize.Y
    local FRAME_W = 240
    local FRAME_H = math.clamp(screenH * 0.72, 400, 600) * 0.6
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
    ctx.gui.Parent = ctx.PG

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
    tl.Size = UDim2.new(1, -28, 1, 0)
    tl.Position = UDim2.new(0, 8, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = CONFIG.Title
    tl.TextColor3 = Color3.fromRGB(0, 220, 160)
    tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tb

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

    do -- title bar drag
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

    do -- resize handle (bottom-right corner): drag to resize the window
        local MIN_W, MIN_H = 200, 220
        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 22, 0, 22)
        handle.Position = UDim2.new(1, -22, 1, -22)
        handle.BackgroundTransparency = 1
        handle.Text = "◢"
        handle.TextColor3 = Color3.fromRGB(0, 220, 160)
        handle.TextSize = 16
        handle.Font = Enum.Font.GothamBold
        handle.BorderSizePixel = 0
        handle.AutoButtonColor = false
        handle.ZIndex = 50
        handle.Parent = main
        ctx.resizeHandle = handle

        local d, s, sw, sh = false, nil, 0, 0
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = true
                s = i.Position
                sw, sh = main.AbsoluteSize.X, main.AbsoluteSize.Y
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local vp = Cam.ViewportSize
                local ap = main.AbsolutePosition
                local dd = i.Position - s
                local maxW = math.max(MIN_W, vp.X - ap.X - 2)
                local maxH = math.max(MIN_H, vp.Y - ap.Y - 2)
                main.Size = UDim2.fromOffset(
                    math.clamp(sw + dd.X, MIN_W, maxW),
                    math.clamp(sh + dd.Y, MIN_H, maxH)
                )
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = false
            end
        end)
    end

    do -- floating logo at left-middle: drag to move, tap to show/hide the GUI
        local tog = Instance.new("TextButton")
        tog.Size = UDim2.new(0, 34, 0, 34)
        tog.Position = UDim2.new(0, 12, 0.5, -17)
        tog.BackgroundColor3 = Color3.fromRGB(0, 170, 130)
        tog.Text = "T"
        tog.TextColor3 = Color3.new(1, 1, 1)
        tog.TextSize = 16
        tog.Font = Enum.Font.GothamBlack
        tog.BorderSizePixel = 0
        tog.AutoButtonColor = false
        tog.Parent = ctx.gui
        Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)
        local tstroke = Instance.new("UIStroke")
        tstroke.Color = Color3.fromRGB(0, 255, 200)
        tstroke.Thickness = 1.5
        tstroke.Parent = tog
        ctx.togBtn = tog

        local d, s, sp, moved = false, nil, nil, false
        tog.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d, moved = true, false
                s = i.Position
                sp = tog.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                if math.abs(dd.X) > 6 or math.abs(dd.Y) > 6 then moved = true end
                if moved then
                    local vp = Cam.ViewportSize
                    local x = sp.X.Scale * vp.X + sp.X.Offset + dd.X
                    local y = sp.Y.Scale * vp.Y + sp.Y.Offset + dd.Y
                    x = math.clamp(x, 0, math.max(0, vp.X - 34))
                    y = math.clamp(y, 0, math.max(0, vp.Y - 34))
                    tog.Position = UDim2.fromOffset(x, y)
                end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                if d and not moved then
                    main.Visible = not main.Visible
                    tog.BackgroundColor3 = main.Visible and Color3.fromRGB(0, 170, 130) or Color3.fromRGB(120, 120, 130)
                end
                d = false
            end
        end)
    end
end
return M
