-- purpose: ESP tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_ESP]
    ctx.newSection(p, "PLAYER ESP")
    ctx.newToggle(p, "Player ESP", "PlayerESP", nil,
        "Draws a box around enemy players through walls. The options below choose what the box shows.")
    ctx.newToggle(p, "Show Names", "ESPShowNames", nil,
        "Shows the enemy player's name on the ESP box.")
    ctx.newToggle(p, "Show HP", "ESPShowHP", nil,
        "Shows the enemy's current HP on the ESP box.")
    ctx.newToggle(p, "Show Distance", "ESPShowDist", nil,
        "Shows how far the enemy is from you on the ESP box.")
    ctx.newSection(p, "ARMOR / VEHICLE ESP")
    ctx.newToggle(p, "Tank/Armor ESP", "ArmorESP", nil,
        "Highlights tanks and armored vehicles and shows their armor status.")
end
return M
