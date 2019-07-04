-----------------
---- Globals ----
-----------------
OnlyMyBoneyard = OnlyMyBoneyard or {}
local OnlyMyBoneyard = OnlyMyBoneyard

OnlyMyBoneyard.name = "OnlyMyBoneyard"
OnlyMyBoneyard.version = "1"
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

---------------------------
---- Variables Default ----
---------------------------
OnlyMyBoneyard.Default = {
	Enable = true,
}

function OnlyMyBoneyard.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "OnlyMyBoneyard",
		displayName = "OnlyMy|c1eg0ffBoneyard|r",
		author = "Floliroy",
		version = OnlyMyBoneyard.version,
		slashCommand = "/ombone",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("OnlyMyBoneyard_Settings", panelData)
	
	local optionsData = {
		{	type = "description",
			text = " ",
		},
		{	type = "checkbox",
			name = "Enable",
			tooltip = "Use this so you can enable or not the synergy blocking.",
			default = true,
			getFunc = function() return OnlyMyBoneyard.savedVariables.Enable end,
			setFunc = function(newValue) 
				OnlyMyBoneyard.savedVariables.Enable = newValue
				OnlyMyBoneyard.Enable = newValue
			end,
		},
	}

	LAM2:RegisterOptionControls("OnlyMyBoneyard_Settings", optionsData)
end

-------------------
---- Functions ----
-------------------
local enableSynergy = false
function OnlyMyBoneyard.Enable(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)	
	--d("Enable")
	EVENT_MANAGER:UnregisterForUpdate(OnlyMyBoneyard.name .. "Disable")
	enableSynergy = true
	EVENT_MANAGER:RegisterForUpdate(OnlyMyBoneyard.name .. "Disable", 10000, OnlyMyBoneyard.Disable)
end

function OnlyMyBoneyard.Disable()
	--d("Disable")
	enableSynergy = false
	EVENT_MANAGER:UnregisterForUpdate(OnlyMyBoneyard.name .. "Disable")
end

function ZO_Synergy:OnSynergyAbilityChanged()
    local synergyName, iconFilename = GetSynergyInfo()

    if synergyName and iconFilename then
		if self.lastSynergyName ~= synergyName then
			if synergyName == GetString(SI_SYNERGY_ABILITY_BONEYARD) then
				if enableSynergy then
					PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
				end
			else
				PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
			end

            self.action:SetText(zo_strformat(SI_USE_SYNERGY, synergyName))
        end
        
        self.icon:SetTexture(iconFilename)
		if synergyName == GetString(SI_SYNERGY_ABILITY_BONEYARD) then
			SHARED_INFORMATION_AREA:SetHidden(self, not enableSynergy)
		else
			SHARED_INFORMATION_AREA:SetHidden(self, false)
		end
    else
           SHARED_INFORMATION_AREA:SetHidden(self, true)
    end

    self.lastSynergyName = synergyName
end

function OnlyMyBoneyard:Initialize()	
	--Settings
	OnlyMyBoneyard.CreateSettingsWindow()

	--Saved Variables
	OnlyMyBoneyard.savedVariables = ZO_SavedVars:New("OnlyMyBoneyardVariables", 1, nil, OnlyMyBoneyard.Default)

	--Events
	EVENT_MANAGER:RegisterForEvent(OnlyMyBoneyard.name .. "Enable", EVENT_COMBAT_EVENT, OnlyMyBoneyard.Enable)
	EVENT_MANAGER:AddFilterForEvent(OnlyMyBoneyard.name .. "Enable", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 117850, REGISTER_FILTER_UNIT_TAG, "player")

	EVENT_MANAGER:UnregisterForEvent(OnlyMyBoneyard.name, EVENT_ADD_ON_LOADED)
	
end
 
function OnlyMyBoneyard.OnAddOnLoaded(event, addonName)
	if addonName ~= OnlyMyBoneyard.name then return end
		OnlyMyBoneyard:Initialize()
end

EVENT_MANAGER:RegisterForEvent(OnlyMyBoneyard.name, EVENT_ADD_ON_LOADED, OnlyMyBoneyard.OnAddOnLoaded)