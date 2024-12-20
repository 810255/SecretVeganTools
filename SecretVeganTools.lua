local addonName, NS = ...

-- Table to track active nameplate frames
local nameplateFrames = {}

-- Table to track party member data
local veganPartyData = {};

-- Default Interrupt Frame
local nonAnchoredInterruptFrame = CreateFrame("Frame", nil, UIParent)
nonAnchoredInterruptFrame:SetSize(100, 100)
nonAnchoredInterruptFrame:SetPoint("CENTER", UIParent, "RIGHT", -140, 40)
nonAnchoredInterruptFrame:Show()

local function SetupDefaultInterruptFrame()
    nonAnchoredInterruptFrame.movableTexture = nonAnchoredInterruptFrame:CreateTexture(nil, "BACKGROUND")
    nonAnchoredInterruptFrame.movableTexture:SetSize(100, 100)
    nonAnchoredInterruptFrame.movableTexture:SetPoint("CENTER", nonAnchoredInterruptFrame, "CENTER", 0, 0)
    nonAnchoredInterruptFrame.movableTexture:SetColorTexture(0, 0, 0, 0.5)

    local numberBox = CreateFrame("Frame", nil, nonAnchoredInterruptFrame)
    numberBox:SetSize(30, 30)
    numberBox:SetPoint("CENTER", nonAnchoredInterruptFrame, "CENTER", 0, 0)
    numberBox.bg = numberBox:CreateTexture(nil, "BACKGROUND")
    numberBox.bg:SetSize(30, 30)
    numberBox.bg:SetPoint("BOTTOM")
    numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
    numberBox.text = numberBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    numberBox.text:SetPoint("CENTER")
    numberBox.text:SetTextColor(1, 1, 1)
    numberBox.text:SetText("1")
    numberBox.text2 = numberBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    numberBox.text2:SetPoint("TOP", numberBox, "TOP", 0, 20)
    numberBox.text2:SetTextColor(1, 1, 0)
    numberBox.text3 = nonAnchoredInterruptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    numberBox.text3:SetPoint("BOTTOMRIGHT", nonAnchoredInterruptFrame, "BOTTOMRIGHT", 0, 0)
    numberBox.text3:SetTextColor(1, 1, 0)
    numberBox.text3:SetFont("Fonts\\FRIZQT__.TTF", 10)
    numberBox.text3:SetText()
    nonAnchoredInterruptFrame.numberBox = numberBox
    nonAnchoredInterruptFrame.numberBox:Hide();

    if (SecretVeganToolsDB.InterruptFramePosition ~= nil) then
        local point, relativePoint, offsetX, offsetY = SecretVeganToolsDB.InterruptFramePosition[1], SecretVeganToolsDB.InterruptFramePosition[2], SecretVeganToolsDB.InterruptFramePosition[3], SecretVeganToolsDB.InterruptFramePosition[4]
        nonAnchoredInterruptFrame:SetPoint(point, UIParent, relativePoint, offsetX, offsetY);
    end

    if (SecretVeganToolsDB.ShowInterruptOrderFrame) then
        nonAnchoredInterruptFrame:Show()
    else
        nonAnchoredInterruptFrame:Hide()
    end

    if (SecretVeganToolsDB.DragInterruptOrderFrame) then
        nonAnchoredInterruptFrame:Show()
        nonAnchoredInterruptFrame:SetMovable(true)
        nonAnchoredInterruptFrame:EnableMouse(true)
        nonAnchoredInterruptFrame.movableTexture:Show();
    else
        nonAnchoredInterruptFrame:SetMovable(false)
        nonAnchoredInterruptFrame:EnableMouse(false)
        nonAnchoredInterruptFrame.movableTexture:Hide();
    end

end

nonAnchoredInterruptFrame:RegisterForDrag("LeftButton")
nonAnchoredInterruptFrame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
nonAnchoredInterruptFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
    local point, _, relativePoint, offsetX, offsetY = nonAnchoredInterruptFrame:GetPoint(1)
    SecretVeganToolsDB.InterruptFramePosition = { point, relativePoint, offsetX, offsetY }
end)

NS.nonAnchoredInterruptFrame = nonAnchoredInterruptFrame;

-- Function to create interrupt display
local function CreateInterruptAnchor(nameplate)
    if not nameplate.interruptFrame then
        -- Create a frame to display interrupt status
        local interruptFrame = CreateFrame("Frame", nil, nameplate)
        nameplate.interruptFrame = interruptFrame
        interruptFrame:SetSize(50, 20)
        interruptFrame:SetPoint("TOP", nameplate, "TOP", 0, 20)

        local numberBox = CreateFrame("Frame", nil, interruptFrame)
        numberBox:SetSize(30, 30)
        numberBox:SetPoint("CENTER", interruptFrame, "CENTER", 0, 0)
        numberBox.bg = numberBox:CreateTexture(nil, "BACKGROUND")
        numberBox.bg:SetSize(30, 30)
        numberBox.bg:SetPoint("BOTTOM")
        numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
        numberBox.text = numberBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        numberBox.text:SetPoint("CENTER")
        numberBox.text:SetTextColor(1, 1, 1)
        numberBox.text:SetText("1")
        numberBox.text2 = numberBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        numberBox.text2:SetPoint("TOP", numberBox, "TOP", 0, 20)
        numberBox.text2:SetTextColor(1, 1, 0)
        numberBox.text2:SetText()
        interruptFrame.numberBox = numberBox
        local reflectIcon = CreateFrame("Frame", nil, interruptFrame)
        reflectIcon:SetSize(30, 30)
        reflectIcon:SetPoint("RIGHT", interruptFrame, "LEFT", -10, 0)
        reflectIcon.bg = reflectIcon:CreateTexture(nil, "BACKGROUND")
        reflectIcon.bg:SetAllPoints()
        reflectIcon.bg:SetTexture("Interface\\Icons\\ability_warrior_shieldreflection")
        reflectIcon.text = reflectIcon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        reflectIcon.text:SetPoint("RIGHT", reflectIcon, "LEFT", -3, 0)
        reflectIcon.text:SetTextColor(1, 1, 1)
        reflectIcon.text:SetText("Reflect")
        interruptFrame.reflectIcon = reflectIcon
    end
end

-- Function that returns a colored unit name based on class
local function GetColoredUnitClassAndName(unit)
    -- Get the unit's class and name
    local unitName = UnitName(unit)
    local _, class = UnitClass(unit)

    if not unitName or not class then
        return nil
    end

    local classColor = RAID_CLASS_COLORS[class]
    if classColor then
        local colorCode = string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
        return colorCode .. unitName .. "|r"
    else
        return unitName
    end
end


local function IsSpellReflectableAndReflectIsOffCD(caster, target, spellId)
    local veganData = veganPartyData[UnitGUID(target)];

    if (veganData == nil) then
        return false;
    end

    local class, _, _ = UnitClass(target)
    if (class == "Warrior") then
        if (veganData.reflectCooldown ~= nil and veganData.reflectCooldown >= GetTime()) then
            return false
        end

        return NS.g_ReflectionSpells[spellId] ~= nil;
    end

    return false
end

local function IsPartyCooldownReadyBefore(veganData, endTime)
    if (veganData.interruptCooldown == nil) then
        return true
    end

    -- check if the party cooldown is ready within the endtime
    if (veganData.interruptCooldown - endTime <= 0) then
        return true
    end

    return false
end
-- Get the unitid of the player with the highest priority
local function GetNextKickerUnitID(castEndTime, nextGuessCastTime)
    local sortedVeganData = {};

    for i = 0, 50 do
        for guid, veganData in pairs(veganPartyData) do
            if (veganData.interruptOrder == i) then
                sortedVeganData[#sortedVeganData + 1] = veganData
            end
        end
    end

    local resultUnitID = nil;
    local resultNextUnitID = nil;
    local resultOrder = 0;

    -- iterate veganPartyData
    for i = 1, #sortedVeganData do
        if (IsPartyCooldownReadyBefore(sortedVeganData[i], castEndTime)) then
            resultUnitID = sortedVeganData[i].unitID;
            resultOrder = i;
            break;
        end
    end

    local guessNextCastTime = castEndTime + (nextGuessCastTime or 0.0);

    -- find the next kicker and their order after this one
    for i = 1, #sortedVeganData do
        local l_VeganData = sortedVeganData[i];
        local l_GuessCastEndTimeWithLockout = guessNextCastTime + l_VeganData.lockoutDuration;
        if (l_VeganData.unitID ~= resultUnitID and IsPartyCooldownReadyBefore(l_VeganData, l_GuessCastEndTimeWithLockout)) then
            resultNextUnitID = l_VeganData.unitID;
            break;
        end
    end

    return resultUnitID, resultOrder, resultNextUnitID
end

local function GetUnitIDInPartyOrSelfByGuid(guid)
    if UnitGUID("player") == guid then
        return "player"
    end
    for i = 1, GetNumGroupMembers() do
        if UnitExists("party" .. i) and UnitGUID("party" .. i) == guid then
            return "party" .. i
        end
    end
    return nil
end

local function IterateSelfAndPartyMembers()
    local i = 0
    return function()
        i = i + 1
        if i == 1 then
            return "player"
        elseif i <= GetNumGroupMembers() + 1 then
            return "party" .. (i - 1)
        end
    end
end

-- UnitID that is being tracked for global interrupt order
local unitIdToTrack = nil;
-- Group Interrupt Orders
local groupInterruptOrders = {};

local function IsNamePlateFirstCastThatCanReflect(p_NamePlate, p_EndTime, p_TargetGUID)
    for unitID, nameplate in pairs(nameplateFrames) do
        local castName, _, _, startTime, endTime, _, _, notInterruptible, spellId = UnitCastingInfo(unitID)
        if (castName ~= nil and spellId ~= nil and spellId > 0 and endTime ~= nil and UnitGUID(unitID.."-target") == p_TargetGUID) then
            if (GetTime() < endTime / 1000) then
                if (endTime < p_EndTime) then
                    return false;
                end
            end
        end
    end

    return true;
end

-- /dump _G.VMRT.Note.Text1
local function GetMRTNoteData()
    if (_G.VMRT == nil) then
        return nil;
    end

    if (_G.VMRT.Note == nil) then
        return nil;
    end

    local mrtText = _G.VMRT.Note.Text1
    return mrtText;
end

local function SplitResponse(input, delimiter)
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

local function ParsePlayerName(coloredPlayerName)
    local playerName = string.match(coloredPlayerName, "|c%x%x%x%x%x%x%x%x(.-)|")
    return playerName
end

local function ParseMRTNoteGroups()
    local mrtText = GetMRTNoteData();
    if (mrtText == nil) then
        return nil;
    end
    
    local kickOrderGroups = {};

    -- parse the text as lines
    local lines = SplitResponse(mrtText, "\n")

    local foundStart = false;
    local foundEnd = false

    for i = 1, #lines do
        local line = lines[i]
        if (not foundStart) then
            if (line == "svtStart") then
                foundStart = true;
            end
        else
            if (line == "svtEnd") then
                foundEnd = true;
                break;
            end
            
            local splitLine = SplitResponse(line, " ")

            local groupNumber = tonumber(splitLine[1])

            if (kickOrderGroups[groupNumber] == nil) then
                kickOrderGroups[groupNumber] = {}
                kickOrderGroups[groupNumber].kickers = {}
            end

            for j = 2, #splitLine do
                local playerName = ParsePlayerName(splitLine[j])
                if (playerName ~= nil) then
                    kickOrderGroups[groupNumber].kickers[j-1] = playerName
                end
            end
        end
    end

    return kickOrderGroups;
end

local function GetRaidIconText(unitID)
    local icon = GetRaidTargetIndex(unitID);

    if (icon == nil) then
        return "";
    end
    
    return " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. icon .. ":0|t";
end

-- Function to update interrupt information
local function UpdateInterruptInfo(unitID)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)

    if nameplate and nameplate.interruptFrame then
        local castName, _, _, startTime, endTime, _, castID, notInterruptible, spellId = UnitCastingInfo(unitID)

        local warrHasReflectAuraUp = false
        local canReflectIt = false;

        if (not unitIdToTrack or not UnitCanAttack("player", unitID)) then
            nameplate.interruptFrame:Hide();
            nameplate.interruptFrame.numberBox:Hide()
            nonAnchoredInterruptFrame.numberBox:Hide()
        end

        -- handle relfect
        if (castName ~= nil and spellId ~= nil and spellId > 0 and endTime ~= nil) then
            if (castID ~= nameplate.lastTrackedCastID) then
                nameplate.lastTrackedCastID = castID
                nameplate.endLockoutTime = nil;
            end

            if (castID == nameplate.failedCastID) then
                nameplate.interruptFrame:Hide()
                return
            end
    
            if (GetTime() >= (endTime / 1000)) then
                nameplate.interruptFrame:Hide()
                return
            end

            -- track last duration of cast to guess future kick order
            nameplate.lastCastDuration = (endTime - startTime) / 1000.0

            local targetGuid = UnitGUID(unitID.."-target")
            if (targetGuid ~= nil) then
                local reflectInfo = veganPartyData[targetGuid]
                if (UnitClass(unitID.."-target") == "Warrior") then
                    if (reflectInfo == nil) then
                        veganPartyData[targetGuid] = {};
                        veganPartyData[targetGuid].unitID = GetUnitIDInPartyOrSelfByGuid(targetGuid)
                        reflectInfo = veganPartyData[targetGuid];
                    end
                end
                if (NS.g_ReflectionSpells[spellId] ~= nil and IsNamePlateFirstCastThatCanReflect(nameplate, endTime, targetGuid)) then
                    nameplate.interruptFrame:Show();
                    if (reflectInfo ~= nil and reflectInfo.hasReflect and reflectInfo.reflectEndTime > (endTime / 1000) and reflectInfo.reflectEndTime > GetTime()) then
                        warrHasReflectAuraUp = true
                    end

                    local isReflectAvailable = IsSpellReflectableAndReflectIsOffCD(unitID, unitID.."-target", spellId);
                    if (not nameplate.interruptFrame.reflectIcon:IsShown() and (isReflectAvailable or warrHasReflectAuraUp)) then
                        nameplate.interruptFrame.reflectIcon:Show()
                        canReflectIt = true;
                    elseif (not isReflectAvailable and not warrHasReflectAuraUp) then
                        nameplate.interruptFrame.reflectIcon:Hide()
                    end

                    if (warrHasReflectAuraUp) then
                        nameplate.interruptFrame.reflectIcon.text:SetText("Reflecting");

                        if (SecretVeganToolsDB.PlaySoundOnReflect) then
                            if (nameplate.reflectAnnTimer == nil or GetTime() > nameplate.reflectAnnTimer) then
                                nameplate.reflectAnnTimer = GetTime() + 5;
                                C_VoiceChat.SpeakText(1, "Reflect", Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
                            end
                        end
                    else
                        nameplate.interruptFrame.reflectIcon.text:SetText("Reflect?");
                        
                        if (SecretVeganToolsDB.PlaySoundOnCanReflect and isReflectAvailable) then
                            if (nameplate.canReflectAnnTimer == nil or GetTime() > nameplate.canReflectAnnTimer) then
                                nameplate.canReflectAnnTimer = GetTime() + 5;

                                local icon = GetRaidTargetIndex(unitID);

                                if (icon ~= nil) then
                                    local checkReflectOn = "CheckReflectOn";

                                    if (icon == 1) then
                                        checkReflectOn = checkReflectOn .. "Star";
                                    elseif (icon == 2) then
                                        checkReflectOn = checkReflectOn .. "Circle";
                                    elseif (icon == 3) then
                                        checkReflectOn = checkReflectOn .. "Purple";
                                    elseif (icon == 4) then
                                        checkReflectOn = checkReflectOn .. "Triangle";
                                    elseif (icon == 5) then
                                        checkReflectOn = checkReflectOn .. "Moon";
                                    elseif (icon == 6) then
                                        checkReflectOn = checkReflectOn .. "Square";
                                    elseif (icon == 7) then
                                        checkReflectOn = checkReflectOn .. "Cross";
                                    elseif (icon == 8) then
                                        checkReflectOn = checkReflectOn .. "Skull";
                                    end

                                    C_VoiceChat.SpeakText(1, checkReflectOn, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
                                else
                                    C_VoiceChat.SpeakText(1, "CheckReflect", Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
                                end

                            end
                        end
                    end

                elseif nameplate.interruptFrame.reflectIcon:IsShown() then
                    nameplate.interruptFrame.reflectIcon:Hide()
                end
            elseif nameplate.interruptFrame.reflectIcon:IsShown() then
                nameplate.interruptFrame.reflectIcon:Hide()
            end

        elseif nameplate.interruptFrame.reflectIcon:IsShown() then
                nameplate.interruptFrame.reflectIcon:Hide()
        end
        
        -- handle interrupt order

        if (not SecretVeganToolsDB.ShowInterruptOrderFrameNameplates) then
            nameplate.interruptFrame.numberBox:Hide();
        end

        if (not unitIdToTrack) then
            return;
        end

        local unitGuid = UnitGUID(unitID);
        if (unitGuid == unitIdToTrack) then
            if (SecretVeganToolsDB.ShowInterruptOrderFrame) then
                nonAnchoredInterruptFrame.numberBox:Show()
            else
                nonAnchoredInterruptFrame.numberBox:Hide()
            end

            if castName and not notInterruptible then
                local kicker, order, nextKicker = GetNextKickerUnitID(endTime / 1000, nameplate.lastCastDuration)
                if (kicker ~= nil) then
                    local text2 = "";
                    local text3 = "";
                    if (warrHasReflectAuraUp == true) then
                        text2 = GetColoredUnitClassAndName(kicker) .. "|cffFFFFFF|R [REFLECT!]";
                    else
                        text2 = GetColoredUnitClassAndName(kicker);
                    end

                    if (nextKicker ~= nil) then
                        text3 = "Next: " .. GetColoredUnitClassAndName(nextKicker);
                    else
                        text3 = "Next: |cffFF0000N/A|R";
                    end

                    nameplate.interruptFrame.numberBox.text2:SetText(text2);
                    nonAnchoredInterruptFrame.numberBox.text2:SetText(GetRaidIconText(unitID) .. text2);
                    nonAnchoredInterruptFrame.numberBox.text3:SetText(text3);

                    nameplate.interruptFrame.numberBox.text:SetText(tostring(order));
                    nonAnchoredInterruptFrame.numberBox.text:SetText(tostring(order));

                    if (UnitGUID(kicker) == UnitGUID("player")) then
                        nameplate.interruptFrame.numberBox.bg:SetColorTexture(0, 1, 0, 0.5)
                        nonAnchoredInterruptFrame.numberBox.bg:SetColorTexture(0, 1, 0, 0.5)
                        if (nameplate.kickAnnTimer == nil or GetTime() > nameplate.kickAnnTimer and not canReflectIt) then
                            nameplate.kickAnnTimer = GetTime() + 5;

                            if (SecretVeganToolsDB.PlaySoundOnInterruptTurn) then
                                C_VoiceChat.SpeakText(1, "Kick", Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
                            end
                        end
                    else
                        nameplate.interruptFrame.numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
                        nonAnchoredInterruptFrame.numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
                    end
                else
                    nameplate.interruptFrame.numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
                    nameplate.interruptFrame.numberBox.text2:SetText("STOP?");
                    nonAnchoredInterruptFrame.numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
                    nonAnchoredInterruptFrame.numberBox.text2:SetText("STOP?");
                end

                if (SecretVeganToolsDB.ShowInterruptOrderFrameNameplates) then
                    nameplate.interruptFrame.numberBox:Show();
                end

            else -- if not casting
                nameplate.interruptFrame.numberBox.text2:SetText("")
                nameplate.interruptFrame.numberBox:Hide()

                if (SecretVeganToolsDB.ShowInterruptOrderFrame) then

                    local endTimeToUse = GetTime() + (nameplate.lastCastDuration or 3.0);
                    if (nameplate.endLockoutTime ~= nil) then
                        if (nameplate.endLockoutTime > GetTime()) then
                            endTimeToUse = nameplate.endLockoutTime;
                        end
                    end

                    local kicker, order, nextKicker = GetNextKickerUnitID(endTimeToUse, (nameplate.lastCastDuration or 3.0))

                    
                    local text2 = "";
                    local text3 = "";

                    if (kicker ~= nil) then
                        text2 = GetColoredUnitClassAndName(kicker);
                    end

                    if (nextKicker ~= nil) then
                        text3 = "Next: " .. GetColoredUnitClassAndName(nextKicker);
                    else
                        text3 = "Next: |cffFF0000N/A|R";
                    end

                    nonAnchoredInterruptFrame.numberBox.text2:SetText(GetRaidIconText(unitID) .. text2);
                    nonAnchoredInterruptFrame.numberBox.text3:SetText(text3);
                    nonAnchoredInterruptFrame.numberBox.text:SetText(tostring(order));

                    
                    if (kicker ~= nil and UnitGUID(kicker) == UnitGUID("player")) then
                        nonAnchoredInterruptFrame.numberBox.bg:SetColorTexture(0, 1, 0, 0.5)
                    else
                        nonAnchoredInterruptFrame.numberBox.bg:SetColorTexture(1, 0, 0, 0.5)
                    end
                end
            end
        else
            if nameplate.interruptFrame.numberBox:IsShown() then
                nameplate.interruptFrame.numberBox.text2:SetText("")
                nonAnchoredInterruptFrame.numberBox.text2:SetText("")
                nameplate.interruptFrame.numberBox:Hide()
            end
        end
    end
end

local function UpdateCooldowns()
    -- cleanup cooldowns that are expired
    for guid, veganData in pairs(veganPartyData) do
        if (veganData.interruptCooldown ~= nil) then
            if (veganData.interruptCooldown - GetTime() <= 0) then
                veganData.interruptCooldown = nil
            end
        end
    end

    for unitID, nameplate in pairs(nameplateFrames) do
        UpdateInterruptInfo(unitID)
    end
end

local requestLock = false;

local function SendAndRequestInitialData()

    if (requestLock) then
        return;
    end

    requestLock = true;

    C_Timer.After(1.0, function()
        local myGuid = UnitGUID("player")
        if not veganPartyData[myGuid] then
            veganPartyData[myGuid] = {} -- initalize player data
        end
        veganPartyData[myGuid].unitID = "player"

        local currentSpec = GetSpecialization()
        if currentSpec then
            local specId, currentSpecName = GetSpecializationInfo(currentSpec)
            local msg = "SPECINFORESPONSE|" .. specId .. "|" .. myGuid .. "|";

            for i = 1, GetNumGroupMembers() do
                if (UnitExists("party" .. i)) then
                    C_ChatInfo.SendAddonMessage("SVTG1", msg, "WHISPER", UnitName("party" .. i));
                    -- request party data from other party members so we can initialize the data on response
                    C_ChatInfo.SendAddonMessage("SVTG1", "REQSPECINFO|", "WHISPER", UnitName("party" .. i));
                end
            end

            if (NS.interruptSpecInfoTable[specId] ~= nil) then
                local specData = NS.interruptSpecInfoTable[specId]
                veganPartyData[myGuid].specId = specId
                veganPartyData[myGuid].interruptSpellId = specData.InterruptSpell
                veganPartyData[myGuid].interruptOrder = specData.InterruptOrder
                veganPartyData[myGuid].lockoutDuration = specData.Lockout or 3.0;
            end
        end

        requestLock = false;
    end)
end

local function PartyHandler(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent = CombatLogGetCurrentEventInfo()
        if (subevent == "SPELL_CAST_SUCCESS") then
            local sourceGUID = select(4, CombatLogGetCurrentEventInfo())
            local spellID = select(12, CombatLogGetCurrentEventInfo())
            local veganData = veganPartyData[sourceGUID];
            if (not veganData) then
                return;
            end
            if (veganData.interruptSpellId == spellID) then
                local cooldown = GetSpellBaseCooldown(spellID) / 1000
                veganData.interruptCooldown = GetTime() + cooldown
            elseif spellID == 23920 then
                veganData.reflectCooldown = GetTime() + 25
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Clean up partyCooldowns table for missing members
        for unit in IterateSelfAndPartyMembers() do
            if (UnitExists(unit)) then
                local guid = UnitGUID(unit)
                if (not veganPartyData[guid]) then
                    veganPartyData[guid] = {}
                    veganPartyData[guid].unitID = unit
                end
            end
        end

        -- cleanup any veganData that is not in the party
        for guid, veganData in pairs(veganPartyData) do
            local unitId = GetUnitIDInPartyOrSelfByGuid(guid)
            if (unitId == nil) then
                veganPartyData[guid] = nil
            end
        end

        -- refresh data
        SendAndRequestInitialData();
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = ...
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
        if nameplate then
            CreateInterruptAnchor(nameplate)
            nameplateFrames[unitID] = {};
            nameplateFrames[unitID].nameplate = nameplate
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        if nameplateFrames[unitID] and nameplateFrames[unitID].nameplate.interruptFrame then
            nameplateFrames[unitID].nameplate.interruptFrame:Hide()
            nameplateFrames[unitID] = nil
        end
    elseif (event == "UNIT_AURA") then
        local unit, info = ...
        local guid = UnitGUID(unit)
        if (veganPartyData[guid] == nil) then
            return;
        end
        if info.addedAuras then
            for _, v in pairs(info.addedAuras) do
                if (v.spellId == 23920) then
                    veganPartyData[guid].reflectAuraInstanceId = v.auraInstanceID
                    veganPartyData[guid].hasReflect = true
                    veganPartyData[guid].reflectEndTime = v.expirationTime;
                end
            end
        end
        if info.removedAuraInstanceIDs and veganPartyData[guid]  then
            for _, v in pairs(info.removedAuraInstanceIDs) do
                if (veganPartyData[guid].reflectAuraInstanceId == v) then
                    veganPartyData[guid].hasReflect = false
                    veganPartyData[guid].reflectEndTime = nil
                end
            end
        end
    elseif (event == "CHAT_MSG_ADDON") then
        local prefix, message, channel, sender = ...
        if (prefix == "SVTG1") then
            local msgBuffer = SplitResponse(message, "|")
            local msgType = msgBuffer[1]
            if (msgType == "KICKMOB") then
                local unitId = msgBuffer[2];
                unitIdToTrack = unitId
                print ("new interrupt order found sent by " .. sender);
            elseif (msgType == "REQSPECINFO") then
                local currentSpec = GetSpecialization()
                if currentSpec then
                    local specId, currentSpecName = GetSpecializationInfo(currentSpec)
                    local msg = "SPECINFORESPONSE|" .. specId .. "|" .. UnitGUID("player") .. "|";
                    C_ChatInfo.SendAddonMessage("SVTG1", msg, "WHISPER", sender);
                end
            elseif (msgType == "SPECINFORESPONSE") then
                local specId = tonumber(msgBuffer[2])
                local guid = msgBuffer[3];

                if (veganPartyData[guid] == nil) then
                    veganPartyData[guid] = {}
                    veganPartyData[guid].unitID = GetUnitIDInPartyOrSelfByGuid(guid)
                end

                veganPartyData[guid].specId = specId

                if (NS.interruptSpecInfoTable[specId] ~= nil) then
                    local specData = NS.interruptSpecInfoTable[specId]
                    veganPartyData[guid].interruptSpellId = specData.InterruptSpell
                    veganPartyData[guid].interruptOrder = specData.InterruptOrder
                    veganPartyData[guid].lockoutDuration = specData.Lockout or 3.0;
                end
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        SendAndRequestInitialData();
    elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
        SendAndRequestInitialData();
    elseif (event == "GROUP_JOINED") then
        SendAndRequestInitialData();
    elseif (event == "ADDON_LOADED") then
        local addonName = ...

        if addonName == "SecretVeganTools" then
            if not SecretVeganToolsDB then
                SecretVeganToolsDB = {}
            end

            NS.InitAddonSettings()
            SetupDefaultInterruptFrame();
        end
    elseif (event == "UNIT_SPELLCAST_FAILED") then
        local unitTarget, castGUID, spellID = ...
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitTarget)
        if nameplate then
            nameplate.failedCastID = castGUID

            if (nameplate.lastTrackedCastID == castGUID) then
                nameplate.lastTrackedCastID = nil;
                nameplate.endLockoutTime = GetTime() + 3.0;
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
frame:RegisterEvent("GROUP_JOINED");
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:SetScript("OnUpdate", UpdateCooldowns)
frame:SetScript("OnEvent", PartyHandler)

local function IteratePartyMembers()
    local i = 0
    return function()
        i = i + 1
        if i <= GetNumGroupMembers() then
            return "party" .. i
        end
    end
end

-- Slash command handler function
local function MarkKickRotationHandler(msg, editBox)
    -- print (ParseMRTNoteGroups());
    -- Logic for handling the command
    local unitId = nil;
    if msg == "focus" then
        unitId = UnitGUID("focus")
    elseif msg == "target" then
        unitId = UnitGUID("target")
    else
        unitId = UnitGUID("focus")
    end

    if unitId == nil then
        unitId = UnitGUID("target")
    end

    if unitId == nil then
        print ("No target or focus")
        return
    end

    local addonMsg = "KICKMOB|" .. unitId .. "|";

    for player in IteratePartyMembers() do
        if (player ~= nil and UnitExists(player)) then
            C_ChatInfo.SendAddonMessage("SVTG1", addonMsg, "WHISPER", UnitName(player));
        end
    end

    unitIdToTrack = unitId;
    print ("Tracking " .. unitId);
end

-- Register the slash command
SLASH_MARKKICKROTATION1 = "/MARKKICKROTATION" -- Main slash command
SLASH_MARKKICKROTATION2 = "/mkr"             -- Optional shorter alias

SlashCmdList["MARKKICKROTATION"] = MarkKickRotationHandler

C_ChatInfo.RegisterAddonMessagePrefix("SVTG1");

