-- purpose: ESP tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_ESP]
    ctx.newSection(p, "PLAYER ESP")
    ctx.newToggle(p, "Player ESP", "PlayerESP")
    ctx.newToggle(p, "Show Names", "ESPShowNames")
    ctx.newToggle(p, "Show HP", "ESPShowHP")
    ctx.newToggle(p, "Show Distance", "ESPShowDist")
    ctx.newSection(p, "ARMOR / VEHICLE ESP")
    ctx.newToggle(p, "Tank/Armor ESP", "ArmorESP")
    ctx.newToggle(p, "Armor Distance", "ArmorESPShowDist")
end
return M