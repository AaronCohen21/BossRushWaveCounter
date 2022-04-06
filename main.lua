local bossRushWaveCounter = RegisterMod("Boss Rush Wave Counter", 1)
local json = require("json")
local MCM = nil
if ModConfigMenu then
	MCM = require("scripts.modconfig")
end

--All code written by Aaron Cohen

local version = 1.12 --change this number every time you update the mod so it will reset the saveX.dat files incase the way data handling is changed and not break the mod for previous users
local isUpdated = nil

local wave = 0  --this number keeps track of what boss rush wave you are on

local editMode = false  --to see if the player is editing the position of the counter
local horizontalAdjustment = 0
local verticalAdjustment = 0

local displayPreset = 1
local textR = 255
local textG = 255
local textB = 255

local barScale = 100
local textScale = 100
local textNudge = 0

function bossRushWaveCounter:loadData()
	if bossRushWaveCounter:HasData()then
		local data = json.decode(Isaac.LoadModData(bossRushWaveCounter))
		wave = data[1]
		horizontalAdjustment = data[2]
		verticalAdjustment = data[3]
		displayPreset = data[4]
		textR = data[5]
		textG = data[6]
		textB = data[7]
		barScale = data[8]
		textScale = data[9]
		textNudge = data[10]
		isUpdated = data[11]
	end

	if isUpdated ~= version then
		wave = 0
		horizontalAdjustment = 0
		verticalAdjustment = 0
		displayPreset = 1
		textR = 255
		textG = 255
		textB = 255
		barScale = 100
		textScale = 100
		textNudge = 0
		isUpdated = version
		bossRushWaveCounter:saveData()  --if the user doesn't have an updated save file, generate a new updated save file and mark it as updated
	end
end

local inBossRush = false
function bossRushWaveCounter:checkBossRush()
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_BOSSRUSH then
		inBossRush = true

		--reset stats for the counter if the player re-enters bossrush and it isn't complete
		if not room:IsAmbushDone() then
			wave = 0
		end

	else
		inBossRush = false
	end
end

local waveChanged = false
function bossRushWaveCounter:update()
	if inBossRush then
		--Check keyboard inputs for editing counter positions
		if Input.IsButtonPressed(Keyboard.KEY_SLASH,0) then
			editMode = true
		else editMode = false end

		if editMode == true then
			if Input.IsButtonPressed(Keyboard.KEY_RIGHT,0) then
				horizontalAdjustment = horizontalAdjustment + 1
			elseif Input.IsButtonPressed(Keyboard.KEY_LEFT,0) then
				horizontalAdjustment = horizontalAdjustment - 1
			elseif Input.IsButtonPressed(Keyboard.KEY_UP,0) then
				verticalAdjustment = verticalAdjustment + 1
			elseif Input.IsButtonPressed(Keyboard.KEY_DOWN,0) then
				verticalAdjustment = verticalAdjustment -1
			end
		end

		if Input.IsButtonPressed(Keyboard.KEY_PERIOD,0) then
			horizontalAdjustment = 0
			verticalAdjustment = 0
		end
		
		if waveChanged then
			wave = wave + 1
			waveChanged = false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc) -- Check for new waves
	local room = Game():GetRoom()
    if inBossRush and room:IsAmbushActive() then
        if not (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET)) then
            local preventCounting
            for _, entity in ipairs(Isaac.FindInRadius(Vector.Zero, 9999, EntityPartition.ENEMY)) do
                if entity:ToNPC() and entity:CanShutDoors() and entity:IsBoss()
                and not (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) or entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET))
                and entity.FrameCount ~= npc.FrameCount then
                    preventCounting = true
                    break
                end
            end

            if not preventCounting then
                waveChanged = true
            end
        end
	end
end)


local waveBar = Sprite()
waveBar:Load("gfx/ui/waveBar.anm2", true)
waveBar:Play("Idle")

local function GetScreenSize() -- By Kilburn himself.
	local room = Game():GetRoom()
	local pos = Isaac.WorldToScreen(Vector(0, 0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)

	return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

local posx, posy = GetScreenSize()

function bossRushWaveCounter.renderWave()
	local editText = Font()
	if editMode then
		editText:Load("font/terminus.fnt")
		editText:DrawString("Edit Mode",posx * 0.5,posy * 0.5,KColor(1,0,0,1),12,true)
	elseif editMode == false then
		editText:Unload()
	end
	if inBossRush then
		--presets: 1 = Default, 2 = Found HUD, 3 = Boss Bar
		if displayPreset == 1 then
			waveBar.Scale = Vector(barScale/100, barScale/100)
			waveBar:Render(Vector(390 + horizontalAdjustment, 29 - verticalAdjustment), Vector(0,0), Vector(0,0))

			local f = Font()
			f:Load("font/terminus.fnt")
			f:DrawStringScaled(wave.."/15",390 + horizontalAdjustment + ((barScale/100)*6),29 + textNudge - verticalAdjustment - ((barScale/100)*22),0.7 * (textScale/100),0.7 * (textScale/100),KColor(textR/255,textG/255,textB/255,1),7,true)

		elseif displayPreset == 2 then
			waveBar.Scale = Vector(barScale/100, barScale/100)
			waveBar:Render(Vector(29 + horizontalAdjustment, 237 - verticalAdjustment), Vector(0,0), Vector(0,0))

			local f = Font()
			f:Load("font/terminus.fnt")
			f:DrawStringScaled(wave.."/15",29 + horizontalAdjustment + ((barScale/100)*6),237 + textNudge - verticalAdjustment - ((barScale/100)*22),0.7 * (textScale/100),0.7 * (textScale/100),KColor(textR/255,textG/255,textB/255,1),7,true)

		else
			if Isaac.CountBosses() >= 1 then
				waveBar.Scale = Vector(barScale/100, barScale/100)
				waveBar:Render(Vector(136 + horizontalAdjustment, 304 - verticalAdjustment), Vector(0,0), Vector(0,0))

				local f = Font()
				f:Load("font/terminus.fnt")
				f:DrawStringScaled(wave.."/15",136 + horizontalAdjustment + ((barScale/100)*6),304 + textNudge - verticalAdjustment - ((barScale/100)*22),0.7 * (textScale/100),0.7 * (textScale/100),KColor(textR/255,textG/255,textB/255,1),7,true)
			else
				waveBar.Scale = Vector(barScale/100, barScale/100)
				waveBar:Render(Vector(posx*0.5, 304 - verticalAdjustment), Vector(0,0), Vector(0,0))

				local f = Font()
				f:Load("font/terminus.fnt")
				f:DrawStringScaled(wave.."/15",posx*0.5 + ((barScale/100)*6),304 + textNudge - verticalAdjustment - ((barScale/100)*22),0.7 * (textScale/100),0.7 * (textScale/100),KColor(textR/255,textG/255,textB/255,1),7,true)
			end
		end
	end
end

function bossRushWaveCounter:saveData()
	if wave < 15 and wave ~= 0 then
		bossRushWaveCounter.SaveData(bossRushWaveCounter, json.encode(table))
		local table= {wave-1, horizontalAdjustment, verticalAdjustment, displayPreset, textR, textG, textB, barScale, textScale, textNudge, isUpdated}
	else 
		local table= {wave, horizontalAdjustment, verticalAdjustment, displayPreset, textR, textG, textB, barScale, textScale, textNudge, isUpdated}
		bossRushWaveCounter.SaveData(bossRushWaveCounter, json.encode(table))
	end
end

bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, bossRushWaveCounter.loadData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, bossRushWaveCounter.saveData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, bossRushWaveCounter.checkBossRush)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_UPDATE, bossRushWaveCounter.update)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_RENDER, bossRushWaveCounter.renderWave)

--Mod Config Menu
local resetSettings = false
if ModConfigMenu then
  local category = "Wave Counter"
  MCM.UpdateCategory(category, {
    Info = "A Simple Wave Counter For Boss Rush!",
  })

  MCM.AddSpace(category)

  MCM.AddTitle(category, "Hold '/' and use the arrow keys")
  MCM.AddTitle(category, "To move the counter, press '.'")
  MCM.AddTitle(category, "To reset the counters position")

  MCM.AddSpace(category)
  
  local presetOptions = {"Default", "Found HUD", "Boss Bar"}  --For changing the preset
  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return displayPreset end,

    Minimum = 1,
    Maximum = 3,

    Display = function() return "Preset: " .. presetOptions[displayPreset] end,

    OnChange = function(i)
      displayPreset = i
      horizontalAdjustment = 0
      verticalAdjustment = 0
    end,

    Info = {"Use a preset for the position of the counter"}
  })

  MCM.AddSpace(category)
  MCM.AddTitle(category, "Counter RGB Values")
  MCM.AddSpace(category)

  --RGB Values
  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return textR end,

    Minimum = 0,
    Maximum = 255,

    Display = function() return "Counter R : " .. textR end,

    OnChange = function(i) textR = i end,

    Info = {"Change the Red Value in the counters text"}
  })

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return textG end,

    Minimum = 0,
    Maximum = 255,

    Display = function() return "Counter G : " .. textG end,

    OnChange = function(i) textG = i end,

    Info = {"Change the Green Value in the counters text"}
  })

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return textB end,

    Minimum = 0,
    Maximum = 255,

    Display = function() return "Counter B : " .. textB end,

    OnChange = function(i) textB = i end,

    Info = {"Change the Blue Value in the counters text"}
  })

  MCM.AddSpace(category)
  MCM.AddTitle(category, "UI Scaling")
  MCM.AddSpace(category)

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return barScale end,

    Minimum = 50,
    Maximum = 200,

    Display = function() return "Bar Scale : " .. barScale end,

    OnChange = function(i) barScale = i end,

    Info = {"Change the scale at which the Bar Sprite should be rendered"}
  })

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return textScale end,

    Minimum = 50,
    Maximum = 200,

    Display = function() return "Font Scale : " .. textScale end,

    OnChange = function(i) textScale = i end,

    Info = {"Change the scale at which the Font should be rendered"}
  })

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.NUMBER,

    CurrentSetting = function() return textNudge end,

    Minimum = -20,
    Maximum = 20,

    Display = function() return "Vertical Adjustment : " .. textNudge end,

    OnChange = function(i) textNudge = i end,

    Info = {"Nudge the Counter Text up or down"}
  })

  MCM.AddSpace(category)

  MCM.AddSetting(category, {

    Type = ModConfigMenu.OptionType.BOOLEAN,

    CurrentSetting = function() return resetSettings end,

    Display = function() return "RESET ALL SETTINGS" end,

    OnChange = function(boolean) 
      resetSettings = boolean

      displayPreset = 1
      textR = 255
      textG = 255
      textB = 255

      barScale = 100
      textScale = 100
      textNudge = 0

      horizontalAdjustment = 0
      verticalAdjustment = 0

      bossRushWaveCounter:saveData()
    end,

    Info = {"RESET ALL SETTINGS TO DEFAULT"}
  })
end