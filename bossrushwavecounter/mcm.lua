local MCM = require("scripts.modconfig")
local variables = require("bossrushwavecounter.variables")
local save = require("bossrushwavecounter.save")

local resetSettings = false

local category = "Wave Counter"
MCM.UpdateCategory(category, {
    Info = "A Simple Wave Counter For Boss Rush!",
})

MCM.AddSpace(category)

MCM.AddTitle(category, "Hold '/' and use the arrow keys")
MCM.AddTitle(category, "To move the counter, press '.'")
MCM.AddTitle(category, "To reset the counters position")

MCM.AddSpace(category)

local presetOptions = { "Default", "Found HUD", "Boss Bar" } -- For changing the preset
MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.displayPreset
    end,

    Minimum = 1,
    Maximum = 3,

    Display = function()
        return "Preset: " .. presetOptions[variables.displayPreset]
    end,

    OnChange = function(i)
        variables.displayPreset = i
        variables.horizontalAdjustment = 0
        variables.verticalAdjustment = 0
    end,

    Info = { "Use a preset for the position of the counter" }
})

MCM.AddSpace(category)
MCM.AddTitle(category, "Counter RGB Values")
MCM.AddSpace(category)

-- RGB Values
MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.textR
    end,

    Minimum = 0,
    Maximum = 255,

    Display = function()
        return "Counter R : " .. variables.textR
    end,

    OnChange = function(i)
        variables.textR = i
    end,

    Info = { "Change the Red Value in the counters text" }
})

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.textG
    end,

    Minimum = 0,
    Maximum = 255,

    Display = function()
        return "Counter G : " .. variables.textG
    end,

    OnChange = function(i)
        variables.textG = i
    end,

    Info = { "Change the Green Value in the counters text" }
})

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.textB
    end,

    Minimum = 0,
    Maximum = 255,

    Display = function()
        return "Counter B : " .. variables.textB
    end,

    OnChange = function(i)
        variables.textB = i
    end,

    Info = { "Change the Blue Value in the counters text" }
})

MCM.AddSpace(category)
MCM.AddTitle(category, "UI Scaling")
MCM.AddSpace(category)

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.barScale
    end,

    Minimum = 50,
    Maximum = 200,

    Display = function()
        return "Bar Scale : " .. variables.barScale
    end,

    OnChange = function(i)
        variables.barScale = i
    end,

    Info = { "Change the scale at which the Bar Sprite should be rendered" }
})

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.textScale
    end,

    Minimum = 50,
    Maximum = 200,

    Display = function()
        return "Font Scale : " .. variables.textScale
    end,

    OnChange = function(i)
        variables.textScale = i
    end,

    Info = { "Change the scale at which the Font should be rendered" }
})

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function()
        return variables.textNudge
    end,

    Minimum = -20,
    Maximum = 20,

    Display = function()
        return "Vertical Adjustment : " .. variables.textNudge
    end,

    OnChange = function(i)
        variables.textNudge = i
    end,

    Info = { "Nudge the Counter Text up or down" }
})

MCM.AddSpace(category)

MCM.AddSetting(category, {
    Type = ModConfigMenu.OptionType.BOOLEAN,

    CurrentSetting = function()
        return resetSettings
    end,

    Display = function()
        return "RESET ALL SETTINGS"
    end,

    OnChange = function(boolean)
        resetSettings = boolean

        save.resetSettings()
        save.saveData()
    end,

    Info = { "RESET ALL SETTINGS TO DEFAULT" }
})
