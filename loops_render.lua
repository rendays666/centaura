-- purpose: render-stepped UI updates
local M = {}
function M.setup(ctx)
    local Run = ctx.Run
    Run.RenderStepped:Connect(function()
        if ctx.fovCircle then
            pcall(function()
                local vp = ctx.Cam.ViewportSize
                local d = ctx.fovRadius * 2
                ctx.fovCircle.Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2)
                ctx.fovCircle.Size = UDim2.fromOffset(d, d)
                ctx.fovCircle.Visible = ctx.opts.AutoAim and ctx.opts.AimFOV
            end)
        end
        if ctx.opts.AutoAim then
            local t = ctx.getBestAimEnemy()
            if t then
                local part = ctx.getTargetPart(t)
                if part then ctx.applyAimAt(part.Position) end
            end
        end
        pcall(ctx.updatePlayerESP)
    end)
end
return M