local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

-- SHADOWLANDS
-- DONT FORGET TO ADD ME TO THE OPTIONS

function S:Blizzard_CovenantPreviewUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.CovenantPreview) then return end

	local frame = _G.CovenantPreviewFrame

	-- Fill me
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI')
