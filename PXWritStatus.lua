-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
PXWritStatusAddon = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
PXWritStatusAddon.name = "PXWritStatus"
PXWritStatusAddon.log = ""
PXWritStatusAddon.logLines = {}
PXWritStatusAddon.logLinesToKeep = 8
PXWritStatusAddon.writNames = {}

---------------------------------------------------------------------------------------------------------
-- E V E N T S
---------------------------------------------------------------------------------------------------------
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function PXWritStatusAddon.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == PXWritStatusAddon.name then
    PXWritStatusAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_CLOSE_BANK,                      function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_CRAFT_COMPLETED,                 function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_END_CRAFTING_STATION_INTERACT,   function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_EXPERIENCE_GAIN,                 function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_INVENTORY_FULL_UPDATE,           function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_ITEM_SLOT_CHANGED,               function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_LOOT_RECEIVED,                   function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_QUEST_ADDED,                     function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_QUEST_COMPLETE,                  function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_SKILL_XP_UPDATE,                 function() PXWritStatusAddon:GetJournal() end)
EVENT_MANAGER:RegisterForEvent('PXWritStatus', EVENT_SMITHING_TRAIT_RESEARCH_STARTED, function() PXWritStatusAddon:GetJournal() end)

function PXWritStatusAddon.OnIndicatorMoveStop()
  PXWritStatusAddon.savedVariables.left = PXWritStatusAddonIndicator:GetLeft()
  PXWritStatusAddon.savedVariables.top = PXWritStatusAddonIndicator:GetTop()
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.name, EVENT_ADD_ON_LOADED, PXWritStatusAddon.OnAddOnLoaded)

---------------------------------------------------------------------------------------------------------
-- H E L P E R    F U N C T I O N S
---------------------------------------------------------------------------------------------------------
function PXWritStatusAddon:GetJournal()
  local journal = {}
  local journalInfo = {}
  local text = ""
  local completedText = ""
  local conditionText = ""

  local questCount = GetNumJournalQuests()
  for questIndex = 1, questCount do
    journalInfo = {}
    if IsValidQuestIndex(questIndex) then
      journalInfo.RepeatType = GetJournalQuestRepeatType(questIndex)
      journalInfo.QuestName, journalInfo.BackgroundText, journalInfo.ActiveStepText, journalInfo.ActiveStepType,
      journalInfo.ActiveStepTrackerOverrideText, journalInfo.Completed, journalInfo.Tracked, journalInfo.QuestLevel,
      journalInfo.Pushed, journalInfo.QuestType, journalInfo.InstanceDisplayType = GetJournalQuestInfo(questIndex)

      local questComplete = GetJournalQuestIsComplete(questIndex)

      if journalInfo.QuestType == QUEST_TYPE_CRAFTING and
         journalInfo.RepeatType == QUEST_REPEAT_DAILY then
        table.insert(journal, journalInfo)

        local steps = GetJournalQuestNumSteps(questIndex)
        stepText, stepVisibility, stepType, stepTrackerOverrideText, conditions = GetJournalQuestStepInfo(questIndex, steps)

        for conditionIndex = 1, conditions do
          conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible = GetJournalQuestConditionInfo(questIndex, steps, conditionIndex)
          local subText = string.sub(conditionText, 1, 7)
          if subText == "Deliver" then
            completedText = "Completed"
          end
        end
        text = text .. journalInfo.QuestName .. " -- " .. completedText .. "\n"
        completedText = ""
      end
      local compl = "No"
      if journalInfo.Completed == true then
        compl = "Yes"
      end
    end
  end
  PXWritStatusAddon:WriteLog(text)
  return journal
end

function PXWritStatusAddon:Initialize()
  self.savedVariables = ZO_SavedVars:New("PXWritStatusSavedVariables", 4, nil, {})
  self.accountVariables = ZO_SavedVars:NewAccountWide("PXWritStatusAccountVariables", 4, nil, {})

  local journal = PXWritStatusAddon:GetJournal()
  self:RestorePosition()
end

function PXWritStatusAddon:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  if left == 0 and top == 0 then
    left = 100
    top = 100
  end
 
  PXWritStatusAddonIndicator:ClearAnchors()
  PXWritStatusAddonIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function PXWritStatusAddon:Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PXWritStatusAddon:WriteLog(textLog)
  local date = GetDate()
  local time = GetTimeString()

  if textLog == "" then
    PXWritStatusAddonIndicatorLabel:SetText("")
  else
    PXWritStatusAddonIndicatorLabel:SetText(date .. " " .. time .. "\n" .. textLog)
  end
end