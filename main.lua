local bossRushWaveCounter = RegisterMod("Boss Rush Wave Counter", 1)

local variables = require("bossrushwavecounter.variables")
local save = require("bossrushwavecounter.save")
local utils = require("bossrushwavecounter.utils")

save.modRef = bossRushWaveCounter

if ModConfigMenu then
    require("bossrushwavecounter.mcm")
end

-- All code written by Aaron Cohen

local version = 1.12 -- change this number every time you update the mod so it will reset the saveX.dat files in case the way data handling is changed and not break the mod for previous users
local editMode = false -- to see if the player is editing the position of the counter

local waveHasStarted = false -- to be able to know whether a wave is in progress
local currentNumberOfBosses = 0 -- the current number of bosses in the room
local inBossRush = false -- indicates if the current room is a boss rush room

-- Constants
local MAX_BOSS_RUSH_WAVES = 15 -- max number of boss rush waves

function checkEditModeAdjustments()
    if Input.IsButtonPressed(Keyboard.KEY_SLASH, 0) then
        editMode = true
    else
        editMode = false
    end

    if editMode == true then
        if Input.IsButtonPressed(Keyboard.KEY_RIGHT, 0) then
            variables.horizontalAdjustment = variables.horizontalAdjustment + 1
        elseif Input.IsButtonPressed(Keyboard.KEY_LEFT, 0) then
            variables.horizontalAdjustment = variables.horizontalAdjustment - 1
        elseif Input.IsButtonPressed(Keyboard.KEY_UP, 0) then
            variables.verticalAdjustment = variables.verticalAdjustment + 1
        elseif Input.IsButtonPressed(Keyboard.KEY_DOWN, 0) then
            variables.verticalAdjustment = variables.verticalAdjustment - 1
        end
    end

    if Input.IsButtonPressed(Keyboard.KEY_PERIOD, 0) then
        variables.horizontalAdjustment = 0
        variables.verticalAdjustment = 0
    end
end

function bossRushWaveCounter:loadData()
    save.loadData()
end

function bossRushWaveCounter:saveData()
    save.saveData()
end

function bossRushWaveCounter:checkBossRush()
    if Game():GetRoom():GetType() == RoomType.ROOM_BOSSRUSH then
        inBossRush = true

        -- reset stats for the counter if the player re-enters bossrush and it isn't complete
        if variables.wave < MAX_BOSS_RUSH_WAVES then
            bossRushWaveCounter:resetCounter()
        end
    else
        inBossRush = false
    end
end

function bossRushWaveCounter:resetCounter()
    variables.wave = 0
    waveHasStarted = false
    currentNumberOfBosses = 0
end

function bossRushWaveCounter:update()
    if inBossRush then
        -- Check keyboard inputs for editing counter positions
        checkEditModeAdjustments()

        local aliveBossesCount = Game():GetRoom():GetAliveBossesCount()
        local waveInProgress = aliveBossesCount > 0

        if aliveBossesCount - currentNumberOfBosses ~= 0 then
            Isaac.DebugString("Number of alive bosses: " .. aliveBossesCount)
        end

        if not waveHasStarted and waveInProgress then
            Isaac.DebugString("Increase wave number")
            waveHasStarted = true
            variables.wave = variables.wave + 1
        end

        if waveHasStarted and not waveInProgress then
            Isaac.DebugString("Wave has finished")
            waveHasStarted = false
        end

        currentNumberOfBosses = aliveBossesCount
    end
end

local waveBar = Sprite()
waveBar:Load("gfx/ui/waveBar.anm2", true)
waveBar:Play("Idle")

local font = Font()
font:Load("font/terminus.fnt")

local posx, posy = utils.getScreenSize()

function bossRushWaveCounter:renderWave()
    if editMode then
        font:DrawString("Edit Mode", posx * 0.5, posy * 0.5, KColor(1, 0, 0, 1), 12, true)
    end

    if inBossRush then
        local waveBarV1
        local positionX = 0
        local positionYOffset = 0

        -- presets: 1 = Default, 2 = Found HUD, 3 = Boss Bar
        if variables.displayPreset == 1 then
            waveBarV1 = Vector(390 + variables.horizontalAdjustment, 29 - variables.verticalAdjustment)
            positionX = 390 + variables.horizontalAdjustment + ((variables.barScale / 100) * 6)
            positionYOffset = 29
        elseif variables.displayPreset == 2 then
            waveBarV1 = Vector(29 + variables.horizontalAdjustment, 237 - variables.verticalAdjustment)
            positionX = 29 + variables.horizontalAdjustment + ((variables.barScale / 100) * 6)
            positionYOffset = 237
        else
            if Isaac.CountBosses() >= 1 then
                waveBarV1 = Vector(136 + variables.horizontalAdjustment, 304 - variables.verticalAdjustment)
                positionX = 136 + variables.horizontalAdjustment + ((variables.barScale / 100) * 6)
                positionYOffset = 304
            else
                waveBarV1 = Vector(posx * 0.5, 304 - variables.verticalAdjustment)
                positionX = posx * 0.5 + ((variables.barScale / 100) * 6)
                positionYOffset = 304
            end
        end

        local text = variables.wave .. "/" .. MAX_BOSS_RUSH_WAVES
        local positionY = positionYOffset + variables.textNudge - variables.verticalAdjustment - ((variables.barScale / 100) * 22)
        local scaleX = 0.7 * (variables.textScale / 100)
        local scaleY = 0.7 * (variables.textScale / 100)
        local renderColor = KColor(variables.textR / 255, variables.textG / 255, variables.textB / 255, 1)
        local boxWidth = 7
        local center = true

        waveBar.Scale = Vector(variables.barScale / 100, variables.barScale / 100)
        waveBar:Render(waveBarV1, Vector(0, 0), Vector(0, 0))

        font:DrawStringScaled(text, positionX, positionY, scaleX, scaleY, renderColor, boxWidth, center)
    end
end

bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, bossRushWaveCounter.loadData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, bossRushWaveCounter.saveData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bossRushWaveCounter.resetCounter)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, bossRushWaveCounter.checkBossRush)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_UPDATE, bossRushWaveCounter.update)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_RENDER, bossRushWaveCounter.renderWave)
