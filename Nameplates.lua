local _, MR = ...
local active = {}
local elapsed = 0

local function GetBar(plate)
 local frame = plate and plate.UnitFrame
 return frame and (frame.healthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar))
end

local function Setup(plate)
 if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
 local bar = GetBar(plate)
 if not bar then return end
 if plate.moonRangeArt then return plate.moonRangeArt end

 -- Decorate Blizzard's actual status bar, not a second health bar.
 -- The native bar owns its protected health values and fill width.
 local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
 bg:SetAllPoints(bar)
 bg:SetTexture(MR.path.."BG_Moon.tga")

 local border = bar:CreateTexture(nil, "OVERLAY", nil, 6)
 border:SetPoint("TOPLEFT", bar, "TOPLEFT", -6, 5)
 border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 6, -5)
 border:SetTexture(MR.path.."Frame_NoMoon.tga")

 local light = bar:CreateTexture(nil, "OVERLAY", nil, 7)
 light:SetAllPoints(border)
 light:SetTexture(MR.path.."Frame_Moon_Light.tga")
 light:Hide()

 -- Replace Blizzard's bar fill without reading protected health values.
 bar:SetStatusBarTexture(MR.path.."Fill_Moon.tga")
 if bar.bgTexture then bar.bgTexture:SetAlpha(0) end
 -- Suppress Blizzard's default border/selection art on this exact bar.
 if bar.selectedBorder then bar.selectedBorder:SetAlpha(0) end
 if bar.deselectedOverlay then bar.deselectedOverlay:SetAlpha(0) end
 local frame=plate.UnitFrame
 if frame.PlayerLevelDiffFrame then frame.PlayerLevelDiffFrame:SetAlpha(0) end
 if frame.LevelFrame then frame.LevelFrame:SetAlpha(0) end
 if frame.HealthBarsContainer and frame.HealthBarsContainer.border then
  frame.HealthBarsContainer.border:SetAlpha(0)
 end

 local art = {bar=bar, bg=bg, border=border, light=light, filename=""}
 plate.moonRangeArt=art
 return art
end

local function Update(unit, plate)
 local art=Setup(plate)
 if not art then return end
 if not MR.db.enabled then
  art.bg:Hide(); art.border:Hide(); art.light:Hide()
  return
 end
 art.bg:Show()
 art.border:Show()
 local selected=UnitExists("target") and UnitIsUnit(unit,"target")
 local inRange=selected and MR:RangeState()
 local filename=(inRange==true) and "Frame_Moon.tga" or "Frame_NoMoon.tga"
 if art.filename~=filename then
  art.filename=filename
  art.border:SetTexture(MR.path..filename)
 end
 if inRange==true then art.light:Show() else art.light:Hide() end
end

function MR:StartNameplates()
 local driver=CreateFrame("Frame")
 driver:RegisterEvent("NAME_PLATE_UNIT_ADDED")
 driver:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
 driver:RegisterEvent("PLAYER_TARGET_CHANGED")
 driver:SetScript("OnEvent",function(_,event,unit)
  if event=="NAME_PLATE_UNIT_ADDED" and C_NamePlate then
   local plate=C_NamePlate.GetNamePlateForUnit(unit)
   if plate then active[unit]=plate;Update(unit,plate) end
  elseif event=="NAME_PLATE_UNIT_REMOVED" then
   active[unit]=nil
  elseif event=="PLAYER_TARGET_CHANGED" then
   for token,plate in pairs(active) do Update(token,plate) end
  end
 end)
 driver:SetScript("OnUpdate",function(_,dt)
  elapsed=elapsed+dt
  if elapsed<(MR.db.update or .15) then return end
  elapsed=0
  for unit,plate in pairs(active) do Update(unit,plate) end
 end)
end
