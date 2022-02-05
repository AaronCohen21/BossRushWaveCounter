local bossRushWaveCounter = RegisterMod("Boss Rush Wave Counter", 1)
local json = require("json")
local MCM = nil
if ModConfigMenu then
   MCM = require("scripts.modconfig")
end

--All code written by Aaron Cohen

local version = 1.6 --change this number every time you update the mod so it will reset the saveX.dat files incase the way data handling is changed and not break the mod for previous users
local isUpdated = nil

local wave = 0  --this number keeps track of what boss rush wave you are on

local editMode = false  --to see if the player is editing the position of the counter
local horizontalAdjustment = 0
local verticalAdjustment = 0

local displayPreset = 1
local textR = 255
local textG = 255
local textB = 255

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
    isUpdated = data[8]  
  end

  if isUpdated ~= version then
    wave = 0
    horizontalAdjustment = 0
    verticalAdjustment = 0
    displayPreset = 1
    textR = 255
    textG = 255
    textB = 255
    isUpdated = version
    bossRushWaveCounter:saveData()  --if the user doesn't have an updated save file, generate a new updated save file and mark it as updated
  end
end

--all the bosses that can spawn in boss rush, true means that they have spawned, false means that they haven't

local larryJr = false
local hollow = false
local monstro = false
local chub = false
local chad = false
local carrionQueen = false
local gurdy = false
local monstro2 = false
local gish = false
local pin = false
local frail = false
local famine = false
local pestilence = false
local war = false
local death = false
local dukeOfFlies = false
local theHusk = false
local peep = false
local bloat = false
local loki = false
local fistula = false
local blastocyst = false
local gemini = false
local steven = false
local blightedOvum = false
local fallen = false
local headlessHorseman = false
local maskOfInfamy = false
local gurdyJr = false
local widow = false
local theWretched = false
local gurglings = false
local turdlings = false
local theHaunt = false
local dingle = false
local dangle = false
local megaMaw = false
local theGate =false
local megaFatty = false
local theCage = false
local darkOne = false
local theAdversary = false
local polycephalus = false
local uriel = false
local gabriel = false
local theStain = false
local brownie = false
local theForsaken = false
local littleHorn = false
local ragMan = false
--Updated Boss Rush
local conquest = false
--Afterbirth+ Bosses
local ragMega = false
local bigHorn = false
local sisterVis = false
local matriarch = false
--Repentance Bosses
local babyPlum = false
local bumbino = false
local reapCreep = false
local thePile = false

local inBossRush = false
function bossRushWaveCounter:checkBossRush()
  if Game():GetRoom():GetType()==RoomType.ROOM_BOSSRUSH then
    inBossRush = true

    --reset stats for the counter if the player re-enters bossrush and it isn't complete
    if wave < 15 then
      bossRushWaveCounter:resetCounter()
    end

  else
    inBossRush = false
  end
end

function bossRushWaveCounter:resetCounter()
  wave = 0
  larryJr = false
  hollow = false
  monstro = false
  chub = false
  chad = false
  carrionQueen = false
  gurdy = false
  monstro2 = false
  gish = false
  pin = false
  frail = false
  famine = false
  pestilence = false
  war = false
  death = false
  dukeOfFlies = false
  theHusk = false
  peep = false
  bloat = false
  loki = false
  fistula = false
  blastocyst = false
  gemini = false
  steven = false
  blightedOvum = false
  fallen = false
  headlessHorseman = false
  maskOfInfamy = false
  gurdyJr = false
  widow = false
  theWretched = false
  gurglings = false
  turdlings = false
  theHaunt = false
  dingle = false
  dangle = false
  megaMaw = false
  theGate =false
  megaFatty = false
  theCage = false
  darkOne = false
  theAdversary = false
  polycephalus = false
  uriel = false
  gabriel = false
  theStain = false
  brownie = false
  theForsaken = false
  littleHorn = false
  ragMan = false
  --Detect if Updated Boss Rush Is Installed
  if UpdatedBossRush then
    conquest = false

    --Afterbirth+ Bosses
    ragMega = false
    bigHorn = false
    sisterVis = false
    matriarch = false

    --Repentance Bosses
    babyPlum = false
    bumbino = false
    reapCreep = false
    thePile = false
  end
end

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

    local mobs = Isaac.GetRoomEntities()

    local newSpawns = 0

    for i, entity in ipairs(mobs) do
      if entity:IsBoss() and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then

        --bosses will spawn in 15 waves of two bosses each, each boss can only spawn once, but bosses some bosses such as larryJr will spawn in as three separate bosses.
        --I cant just check to see if the number of bosses has increased since the last run of the function because some bosses like fistula can split into more bosses and increase the wave number even if the wave hasn't finished.
        --because of this, the loop will only look for each individual type and varient of a boss once, and if it finds one of them, it won't count the possible other copies of the same boss towards the newSpawns integer
        --this will loop through all the bosses that are currently in the room
        --if the loop finds a boss that hasn't spawned before, it will update the newSpawns integer.
        --if the newSpawns integer is 2 (or greater than 2 for whatever reason), that means that a new wave has started and the waves number gets updated

        if entity.Type == 19 and entity.Variant == 0 and larryJr == false then  --sadly I'm going to need to make a copy of this if statement 49 more times for all of the other bosses because I couldn't think of a smarter way to code this
          newSpawns = newSpawns + 1
          larryJr = true
        elseif entity.Type == 19 and entity.Variant == 1 and hollow == false then
          newSpawns = newSpawns + 1
          hollow = true
        elseif entity.Type == 20 and entity.Variant == 0 and monstro == false then
          newSpawns = newSpawns + 1
          monstro = true
        elseif entity.Type == 28 and entity.Variant == 0 and chub == false and entity.SpawnerType == 0 then --If Updated Boss Rush Is Installed, the matriarch can spawn, this makes sure that the chub being spawned does not come from the matriarch
          newSpawns = newSpawns + 1
          chub = true
        elseif entity.Type == 28 and entity.Variant == 1 and chad == false then
          newSpawns = newSpawns + 1
          chad = true
        elseif entity.Type == 28 and entity.Variant == 2 and carrionQueen == false then
          newSpawns = newSpawns + 1
          carrionQueen = true
        elseif entity.Type == 36 and entity.Variant == 0 and gurdy == false then
          newSpawns = newSpawns + 1
          gurdy = true
        elseif entity.Type == 43 and entity.Variant == 0 and monstro2 == false then
          newSpawns = newSpawns + 1
          monstro2 = true
        elseif entity.Type == 43 and entity.Variant == 1 and gish == false then
          newSpawns = newSpawns + 1
          gish = true
        elseif entity.Type == 62 and entity.Variant == 0 and pin == false then
          newSpawns = newSpawns + 1
          pin = true
        elseif entity.Type == 62 and entity.Variant == 2 and frail == false then
          newSpawns = newSpawns + 1
          frail = true
        elseif entity.Type == 63 and entity.Variant == 0 and famine == false then
          newSpawns = newSpawns + 1
          famine = true
        elseif entity.Type == 64 and entity.Variant == 0 and pestilence == false then
          newSpawns = newSpawns + 1
          pestilence = true
        elseif entity.Type == 65 and entity.Variant == 0 and war == false then
          newSpawns = newSpawns + 1
          war = true
        elseif entity.Type == 66 and entity.Variant == 0 and death == false then
          newSpawns = newSpawns + 1
          death = true
        elseif entity.Type == 67 and entity.Variant == 0 and dukeOfFlies == false then
          newSpawns = newSpawns + 1
          dukeOfFlies = true
        elseif entity.Type == 67 and entity.Variant == 1 and theHusk == false then
          newSpawns = newSpawns + 1
          theHusk = true
        elseif entity.Type == 68 and entity.Variant == 0 and peep == false then
          newSpawns = newSpawns + 1
          peep = true
        elseif entity.Type == 68 and entity.Variant == 1 and bloat == false then
          newSpawns = newSpawns + 1
          bloat = true
        elseif entity.Type == 69 and entity.Variant == 0 and loki == false then
          newSpawns = newSpawns + 1
          loki = true
        elseif entity.Type == 71 and entity.Variant == 0 and fistula == false then
          newSpawns = newSpawns + 1
          fistula = true
        elseif entity.Type == 74 and entity.Variant == 0 and blastocyst == false then
          newSpawns = newSpawns + 1
          blastocyst = true
        elseif entity.Type == 79 and entity.Variant == 0 and gemini == false then
          newSpawns = newSpawns + 1
          gemini = true
        elseif entity.Type == 79 and entity.Variant == 1 and steven == false then
          newSpawns = newSpawns + 1
          steven = true
        elseif entity.Type == 79 and entity.Variant == 2 and blightedOvum == false then
          newSpawns = newSpawns + 1
          blightedOvum = true
        elseif entity.Type == 81 and entity.Variant == 0 and fallen == false then
          newSpawns = newSpawns + 1
          fallen = true
        elseif (entity.Type == 82 or entity.Type == 83) and entity.Variant == 0 and headlessHorseman == false then --The head is Type 83 the body is Type 82
          newSpawns = newSpawns + 1
          headlessHorseman = true
        elseif entity.Type == 97 and entity.Variant == 0 and maskOfInfamy == false then
          newSpawns = newSpawns + 1
          maskOfInfamy = true
        elseif entity.Type == 99 and entity.Variant == 0 and gurdyJr == false then
          newSpawns = newSpawns + 1
          gurdyJr = true
        elseif entity.Type == 100 and entity.Variant == 0 and widow == false then
          newSpawns = newSpawns + 1
          widow = true
        elseif entity.Type == 100 and entity.Variant == 1 and theWretched == false then
          newSpawns = newSpawns + 1
          theWretched = true
        elseif entity.Type == 237 and entity.Variant == 1 and gurglings == false then
          newSpawns = newSpawns + 1
          gurglings = true
        elseif entity.Type == 237 and entity.Variant == 2 and turdlings == false then
          newSpawns = newSpawns + 1
          turdlings = true
        elseif entity.Type == 260 and entity.Variant == 0 and theHaunt == false then
          newSpawns = newSpawns + 1
          theHaunt = true
        elseif entity.Type == 261 and entity.Variant == 0 and dingle == false then
          newSpawns = newSpawns + 1
          dingle = true
        elseif entity.Type == 261 and entity.Variant == 1 and dangle == false and entity.HitPoints ~= 75 then  --if brownie spawns, when he is killed he spawns a dangle with 75 hp, this tests to make sure that the dangle that spawns isn't from brownie
          newSpawns = newSpawns + 1
          dangle = true
        elseif entity.Type == 262 and entity.Variant == 0 and megaMaw == false then
          newSpawns = newSpawns + 1
          megaMaw = true
        elseif entity.Type == 263 and entity.Variant == 0 and theGate == false then
          newSpawns = newSpawns + 1
          theGate = true
        elseif entity.Type == 264 and entity.Variant == 0 and megaFatty == false then
          newSpawns = newSpawns + 1
          megaFatty = true
        elseif entity.Type == 265 and entity.Variant == 0 and theCage == false then
          newSpawns = newSpawns + 1
          theCage = true
        elseif entity.Type == 267 and entity.Variant == 0 and darkOne == false then
          newSpawns = newSpawns + 1
          darkOne = true
        elseif entity.Type == 268 and entity.Variant == 0 and theAdversary == false then
          newSpawns = newSpawns + 1
          theAdversary = true
        elseif entity.Type == 269 and entity.Variant == 0 and polycephalus == false then
          newSpawns = newSpawns + 1
          polycephalus = true
        elseif entity.Type == 271 and entity.Variant == 0 and uriel == false then
          newSpawns = newSpawns + 1
          uriel = true
        elseif entity.Type == 272 and entity.Variant == 0 and gabriel == false then
          newSpawns = newSpawns + 1
          gabriel = true
        elseif entity.Type == 401 and entity.Variant == 0 and theStain == false then
          newSpawns = newSpawns + 1
          theStain = true
        elseif entity.Type == 402 and entity.Variant == 0 and brownie == false then
          newSpawns = newSpawns + 1
          brownie = true
        elseif entity.Type == 403 and entity.Variant == 0 and theForsaken == false then
          newSpawns = newSpawns + 1
          theForsaken = true
        elseif entity.Type == 404 and entity.Variant == 0 and littleHorn == false then
          newSpawns = newSpawns + 1
          littleHorn = true
        elseif entity.Type == 405 and entity.Variant == 0 and ragMan == false then
          newSpawns = newSpawns + 1
          ragMan = true
        end

        --If Updated Boss Rush Is Installed
        if UpdatedBossRush then
          --Afterbirth+ Bosses
          if entity.Type == 409 and entity.Variant == 0 and ragMega == false then
            newSpawns = newSpawns + 1
            ragMega = true
          elseif entity.Type == 411 and entity.Variant == 0 and bigHorn == false then
            newSpawns = newSpawns + 1
            bigHorn = true
          elseif entity.Type == 410 and entity.Variant == 0 and sisterVis == false then
            newSpawns = newSpawns + 1
            sisterVis = true
          elseif entity.Type == 413 and entity.Variant == 0 and matriarch == false then
            newSpawns = newSpawns + 1
            matriarch = true

            --Conquest
          elseif entity.Type == 65 and entity.Variant == 1 and conquest == false then
            newSpawns = newSpawns + 1
            conquest = true

            --Repentance Bosses
          elseif entity.Type == 908 and entity.Variant == 0 and babyPlum == false then
            newSpawns = newSpawns + 1
            babyPlum = true
          elseif entity.Type == 916 and entity.Variant == 0 and bumbino == false then
            newSpawns = newSpawns + 1
            bumbino = true
          elseif entity.Type == 900 and entity.Variant == 0 and reapCreep == false then
            newSpawns = newSpawns + 1
            reapCreep = true
          elseif entity.Type == 269 and entity.Variant == 1 and thePile == false then
            newSpawns = newSpawns + 1
            thePile = true
          end
        end
      end
    end
    if newSpawns >= 2 then wave = wave +1 end
  end
end

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
      waveBar:Render(Vector(390 + horizontalAdjustment, 29 - verticalAdjustment), Vector(0,0), Vector(0,0))

      local f = Font()
      f:Load("font/terminus.fnt")
      f:DrawStringScaled(wave.."/15",396 + horizontalAdjustment,7 - verticalAdjustment,0.7,0.7,KColor(textR/255,textG/255,textB/255,1),7,true)

    elseif displayPreset == 2 then
      waveBar:Render(Vector(29 + horizontalAdjustment, 237 - verticalAdjustment), Vector(0,0), Vector(0,0))

      local f = Font()
      f:Load("font/terminus.fnt")
      f:DrawStringScaled(wave.."/15",35 + horizontalAdjustment,215 - verticalAdjustment,0.7,0.7,KColor(textR/255,textG/255,textB/255,1),7,true)

    else
      if Isaac.CountBosses() >= 1 then
        waveBar:Render(Vector(136 + horizontalAdjustment, 304 - verticalAdjustment), Vector(0,0), Vector(0,0))

        local f = Font()
        f:Load("font/terminus.fnt")
        f:DrawStringScaled(wave.."/15",142 + horizontalAdjustment,282 - verticalAdjustment,0.7,0.7,KColor(textR/255,textG/255,textB/255,1),7,true)
      else
        waveBar:Render(Vector(posx*0.5, 304 - verticalAdjustment), Vector(0,0), Vector(0,0))

        local f = Font()
        f:Load("font/terminus.fnt")
        f:DrawStringScaled(wave.."/15",posx*0.5 + 6,282 - verticalAdjustment,0.7,0.7,KColor(textR/255,textG/255,textB/255,1),7,true)
      end
    end
  end
end

function bossRushWaveCounter:saveData()
  if wave < 15 and wave ~= 0 then
    local table= {wave-1, horizontalAdjustment, verticalAdjustment, displayPreset, textR, textG, textB, isUpdated}
    bossRushWaveCounter.SaveData(bossRushWaveCounter, json.encode(table))
  else 
    local table= {wave, horizontalAdjustment, verticalAdjustment, displayPreset, textR, textG, textB, isUpdated}
    bossRushWaveCounter.SaveData(bossRushWaveCounter, json.encode(table))
  end
end

bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, bossRushWaveCounter.loadData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, bossRushWaveCounter.saveData)
bossRushWaveCounter:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bossRushWaveCounter.resetCounter)
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

      horizontalAdjustment = 0
      verticalAdjustment = 0

      bossRushWaveCounter:saveData()
    end,

    Info = {"RESET ALL SETTINGS TO DEFAULT"}
  })
end