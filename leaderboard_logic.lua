-- purpose: leaderboard rebuild, drag, periodic refresh
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local UIS = ctx.UIS

    ctx.buildLB = function()
        for _, c in ipairs(ctx.lbScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local cols, colOrder = {}, {}
        for _, p in ipairs(Players:GetPlayers()) do
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("ValueBase") and not cols[v.Name] then
                        cols[v.Name] = true
                        colOrder[#colOrder + 1] = v.Name
                    end
                end
            end
        end
        if #colOrder == 0 then colOrder = { "Kills", "Deaths", "Score" } end
        local data = {}
        for _, p in ipairs(Players:GetPlayers()) do
            local s = {}
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("ValueBase") then s[v.Name] = v.Value end
                end
            end
            data[#data + 1] = { plr = p, stats = s }
        end
        table.sort(data, function(a, b)
            local sa = a.stats.Score or a.stats.Kills or 0
            local sb = b.stats.Score or b.stats.Kills or 0
            if type(sa) == "number" and type(sb) == "number" and sa ~= sb then return sa > sb end
            return a.plr.Name < b.plr.Name
        end)
        local hdr = string.format("%-3s %-12s", "#", "Player")
        for _, c in ipairs(colOrder) do
            hdr = hdr .. string.format(" %4s", string.upper(string.sub(c, 1, 3)))
        end
        local hr = Instance.new("Frame")
        hr.Size = UDim2.new(1, 0, 0, 16)
        hr.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        hr.BorderSizePixel = 0
        hr.LayoutOrder = 0
        hr.Parent = ctx.lbScroll
        Instance.new("UICorner", hr).CornerRadius = UDim.new(0, 2)
        local hl = Instance.new("TextLabel")
        hl.Size = UDim2.new(1, -6, 1, 0)
        hl.Position = UDim2.new(0, 3, 0, 0)
        hl.BackgroundTransparency = 1
        hl.Text = hdr
        hl.TextColor3 = Color3.fromRGB(180, 180, 200)
        hl.TextSize = 9
        hl.Font = Enum.Font.Code
        hl.TextXAlignment = Enum.TextXAlignment.Left
        hl.Parent = hr
        for rank, e in ipairs(data) do
            if rank > 25 then break end
            local p = e.plr
            local isSelf = (p == LP)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 16)
            row.BorderSizePixel = 0
            row.LayoutOrder = rank
            row.BackgroundColor3 = isSelf and Color3.fromRGB(60, 50, 15) or (rank % 2 == 0 and Color3.fromRGB(25, 25, 38) or Color3.fromRGB(20, 20, 32))
            row.Parent = ctx.lbScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 2)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 5, 0, 5)
            dot.Position = UDim2.new(0, 3, 0.5, -2.5)
            dot.BorderSizePixel = 0
            dot.Parent = row
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            dot.BackgroundColor3 = p.Team and p.TeamColor.Color or Color3.fromRGB(120, 120, 140)
            local nm = p.Name
            if #nm > 12 then nm = nm:sub(1, 11) .. "…" end
            local txt = string.format("%-3d %-12s", rank, nm)
            for _, c in ipairs(colOrder) do
                local v = e.stats[c] or 0
                local sv
                if type(v) == "number" then
                    if v >= 1e6 then sv = string.format("%.1fM", v / 1e6)
                    elseif v >= 1e3 then sv = string.format("%.1fK", v / 1e3)
                    else sv = tostring(math.floor(v)) end
                else
                    sv = tostring(v):sub(1, 4)
                end
                txt = txt .. string.format(" %4s", sv)
            end
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = isSelf and Color3.fromRGB(255, 230, 100) or Color3.fromRGB(210, 210, 225)
            lbl.TextSize = 9
            lbl.Font = Enum.Font.Code
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row
        end
    end

    task.spawn(function()
        while ctx.lbGui.Parent do
            task.wait(1.5)
            if ctx.lbGui.Enabled then pcall(ctx.buildLB) end
        end
    end)

    do
        local d, s, sp = false, nil, nil
        ctx.lbTitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = true
                s = i.Position
                sp = ctx.lbMain.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                ctx.lbMain.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
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