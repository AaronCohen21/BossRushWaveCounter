local variables = require("bossrushwavecounter.variables")
local json = require("json")

local save = {}

function save:resetSettings()
    variables.horizontalAdjustment = 0
    variables.verticalAdjustment = 0
    variables.displayPreset = 1
    variables.textR = 255
    variables.textG = 255
    variables.textB = 255
    variables.barScale = 100
    variables.textScale = 100
    variables.textNudge = 0
end

function save:loadData()
    if save.modRef:HasData() then
        local data = json.decode(Isaac.LoadModData(save.modRef))
        variables.wave = data[1]
        variables.horizontalAdjustment = data[2]
        variables.verticalAdjustment = data[3]
        variables.displayPreset = data[4]
        variables.textR = data[5]
        variables.textG = data[6]
        variables.textB = data[7]
        variables.barScale = data[8]
        variables.textScale = data[9]
        variables.textNudge = data[10]
        variables.isUpdated = data[11]
    end

    if isUpdated ~= version then
        variables.wave = 0
        variables.horizontalAdjustment = 0
        variables.verticalAdjustment = 0
        variables.displayPreset = 1
        variables.textR = 255
        variables.textG = 255
        variables.textB = 255
        variables.barScale = 100
        variables.textScale = 100
        variables.textNudge = 0
        variables.isUpdated = version
        save:saveData() -- if the user doesn't have an updated save file, generate a new updated save file and mark it as updated
    end
end

function save:saveData()
    if variables.wave < 15 and variables.wave ~= 0 then
        local table = { variables.wave - 1, variables.horizontalAdjustment, variables.verticalAdjustment, variables.displayPreset, variables.textR, variables.textG, variables.textB, variables.barScale, variables.textScale, variables.textNudge, variables.isUpdated }
        save.modRef.SaveData(save.modRef, json.encode(table))
    else
        local table = { variables.wave, variables.horizontalAdjustment, variables.verticalAdjustment, variables.displayPreset, variables.textR, variables.textG, variables.textB, variables.barScale, variables.textScale, variables.textNudge, variables.isUpdated }
        save.modRef.SaveData(save.modRef, json.encode(table))
    end
end

return save
