-- purpose: user config table and derived options/state scalars
local M = {}
function M.setup(ctx)
    ctx.CONFIG = {
        Title = "RENRENHUB CENTAURA",
        Tabs  = { "Combat", "AutoKill", "Aim", "ESP", "Medic", "Display" },

        NoRecoil   = true,
        NoSpread   = true,
        NoCooldown = false,
        NoReload   = false,
        OneHit     = false,

        AutoKill         = false,
        SekaratMode      = false,
        TargetMode       = "Nearest",
        AutoKillCooldown = 1.0,
        AutoKillDamage   = 100,
        SekaratMinHP     = 20,
        MaxFiresPerSec   = 8,

        AutoAim       = true,
        AimFOV        = true,
        AimStrength   = "Smooth",
        AimPriority   = "Nearest",
        AimPart       = "Head",
        AimSmoothness = 0.20,
        FOVRadius     = 30,
        AimEspDistance= 250,

        PlayerESP    = true,
        ESPShowNames = true,
        ESPShowHP    = true,
        ESPShowDist  = true,

        MedicEnabled     = false,
        MedicHPThreshold = 50,
        MedicBelowStuds  = 8,
        MedicTeleportWait= 0.5,
        MedicPositionMode= "Below",
        MedicHumanize    = true,

        DamageArmor        = false,
        ArmorDamage        = 50000,
        ArmorScanInterval  = 0.5,
        MaxArmorDistance   = 400,
        ArmorFireInterval  = 0.15,
        BypassArmorLocal   = true,
    }

    ctx.opts = {
        NoRecoil     = ctx.CONFIG.NoRecoil,
        NoSpread     = ctx.CONFIG.NoSpread,
        NoCooldown   = ctx.CONFIG.NoCooldown,
        NoReload     = ctx.CONFIG.NoReload,
        OneHit       = ctx.CONFIG.OneHit,
        AutoKill     = ctx.CONFIG.AutoKill,
        SekaratMode  = ctx.CONFIG.SekaratMode,
        AutoAim      = ctx.CONFIG.AutoAim,
        AimFOV       = ctx.CONFIG.AimFOV,
        AimStrength  = ctx.CONFIG.AimStrength,
        AimPriority  = ctx.CONFIG.AimPriority,
        AimPart      = ctx.CONFIG.AimPart,
        PlayerESP    = ctx.CONFIG.PlayerESP,
        ESPShowNames = ctx.CONFIG.ESPShowNames,
        ESPShowHP    = ctx.CONFIG.ESPShowHP,
        ESPShowDist  = ctx.CONFIG.ESPShowDist,
        MedicEnabled = ctx.CONFIG.MedicEnabled,
        DamageArmor  = ctx.CONFIG.DamageArmor,
    }

    ctx.autoKillCooldown  = ctx.CONFIG.AutoKillCooldown
    ctx.autoKillDamage    = ctx.CONFIG.AutoKillDamage
    ctx.minHP             = ctx.CONFIG.SekaratMinHP
    ctx.maxFiresPerSec    = ctx.CONFIG.MaxFiresPerSec
    ctx.aimEspDistance    = ctx.CONFIG.AimEspDistance
    ctx.fovRadius         = ctx.CONFIG.FOVRadius
    ctx.aimSmoothness     = ctx.CONFIG.AimSmoothness
    ctx.medicHPThreshold  = ctx.CONFIG.MedicHPThreshold
    ctx.medicBelowStuds   = ctx.CONFIG.MedicBelowStuds
    ctx.medicTeleportWait = ctx.CONFIG.MedicTeleportWait
    ctx.medicPositionMode = ctx.CONFIG.MedicPositionMode
    ctx.medicHumanize     = ctx.CONFIG.MedicHumanize
    ctx.targetMode        = ctx.CONFIG.TargetMode

    ctx.T_COMBAT   = ctx.CONFIG.Tabs[1] or "Combat"
    ctx.T_AUTOKILL = ctx.CONFIG.Tabs[2] or "AutoKill"
    ctx.T_AIM      = ctx.CONFIG.Tabs[3] or "Aim"
    ctx.T_ESP      = ctx.CONFIG.Tabs[4] or "ESP"
    ctx.T_MEDIC    = ctx.CONFIG.Tabs[5] or "Medic"
    ctx.T_DISPLAY  = ctx.CONFIG.Tabs[6] or "Display"
    ctx.tabNames   = { ctx.T_COMBAT, ctx.T_AUTOKILL, ctx.T_AIM, ctx.T_ESP, ctx.T_MEDIC, ctx.T_DISPLAY }
end
return M