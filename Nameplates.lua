local _, MR = ...
local active, elapsed = {}, 0
local UV_L, UV_R = 129/1024, 886/1024
local UV_T, UV_B = 203/512, 281/512

local function GetBar(plate)
 local f=plate and plate.UnitFrame
 return f and (f.healthBar or (f.HealthBarsContainer and f.HealthBarsContainer.healthBar))
end

local function Setup(plate)
 if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
 local bar=GetBar(plate)
 if not bar then return end
 if plate.moonRangeArt then return plate.moonRangeArt end

 -- Source TGAs are 1024x512 with a lot of transparent padding.
 -- Draw the entire texture at 200x100, centred on the native health bar.
 -- The artwork's central opening is only 74% of the source width.
 local art=CreateFrame("Frame",nil,plate.UnitFrame)
 art:SetSize(200,100)
 art:SetPoint("CENTER",bar,"CENTER",0,0)
 art:SetFrameLevel(math.max(0,bar:GetFrameLevel()-1))
 art:EnableMouse(false)

 local background=art:CreateTexture(nil,"BACKGROUND")
 background:SetAllPoints(art)
 background:SetTexture(MR.path.."BG_Moon.tga")

 local foreground=CreateFrame("Frame",nil,plate.UnitFrame)
 foreground:SetAllPoints(art)
 foreground:SetFrameLevel(bar:GetFrameLevel()+2)
 foreground:EnableMouse(false)
 local border=foreground:CreateTexture(nil,"OVERLAY",nil,2)
 border:SetAllPoints(art)
 border:SetTexture(MR.path.."Frame_NoMoon.tga")

 local light=foreground:CreateTexture(nil,"OVERLAY",nil,3)
 light:SetAllPoints(art)
 light:SetTexture(MR.path.."Frame_Moon_Light.tga")
 light:Hide()

 -- Preserve the Blizzard status bar so it alone handles secret health values.
 -- Crop the huge transparent padding from the bar-fill source image.
 bar:SetSize(148,15)
 bar:SetStatusBarTexture(MR.path.."Fill_Moon.tga")
 bar:SetStatusBarColor(1,1,1,1)
 local texture=bar:GetStatusBarTexture()
 if texture then texture:SetTexCoord(UV_L,UV_R,UV_T,UV_B) end

 if bar.bgTexture then bar.bgTexture:SetAlpha(0) end
 if bar.selectedBorder then bar.selectedBorder:SetAlpha(0) end
 if bar.deselectedOverlay then bar.deselectedOverlay:SetAlpha(0) end
 local frame=plate.UnitFrame
 if frame.PlayerLevelDiffFrame then frame.PlayerLevelDiffFrame:SetAlpha(0) end
 if frame.LevelFrame then frame.LevelFrame:SetAlpha(0) end

 local entry={frame=art,foreground=foreground,border=border,light=light,bar=bar,filename=""}
 plate.moonRangeArt=entry
 return entry
end

local function Update(unit,plate)
 local a=Setup(plate)
 if not a then return end
 if not MR.db.enabled then a.frame:Hide();a.foreground:Hide();return end
 a.frame:Show()
 a.foreground:Show()
 -- Blizzard may restore its own status-bar texture during unit updates.
 local texture=a.bar:GetStatusBarTexture()
 if texture and texture:GetTexture()~=MR.path.."Fill_Moon.tga" then
  a.bar:SetStatusBarTexture(MR.path.."Fill_Moon.tga")
  texture=a.bar:GetStatusBarTexture()
 end
 if texture then texture:SetTexCoord(UV_L,UV_R,UV_T,UV_B) end
 a.bar:SetStatusBarColor(1,1,1,1)
 local selected=UnitExists("target") and UnitIsUnit(unit,"target")
 local range=selected and MR:RangeState()
 local filename=(range==true) and "Frame_Moon.tga" or "Frame_NoMoon.tga"
 if filename~=a.filename then
  a.filename=filename
  a.border:SetTexture(MR.path..filename)
 end
 if range==true then a.light:Show() else a.light:Hide() end
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
