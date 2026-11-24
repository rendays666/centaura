-- purpose: ESP tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_ESP]
    ctx.newSection(p, "PLAYER ESP")
    ctx.newToggle(p, "Player ESP", "PlayerESP")
    ctx.newToggle(p, "Show Names", "ESPShowNames")
    ctx.newToggle(p, "Show HP", "ESPShowHP")
    ctx.newToggle(p, "Show Distance", "ESPShowDist")
end
return M