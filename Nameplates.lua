local _,MR=...
local active={}
local elapsed=0

local function GetBar(plate)
 local frame=plate and plate.UnitFrame
 return frame and (frame.healthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar))
end

local function Setup(plate)
 if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
 local bar=GetBar(plate)
 if not bar then return end
 if plate.moonRangeArt then return plate.moonRangeArt end
 local art=CreateFrame("Frame",nil,plate.UnitFrame)
 art:SetPoint("CENTER",bar,"CENTER",0,0)
 art:SetSize(MR.db.width,MR.db.height)
 art:SetFrameLevel(bar:GetFrameLevel()+3)
 art:EnableMouse(false)
 local bg=art:CreateTexture(nil,"BACKGROUND")
 bg:SetAllPoints(art)
 bg:SetTexture(MR.path.."BG_Moon.tga")
 local fill=art:CreateTexture(nil,"ARTWORK")
 fill:SetTexture(MR.path.."Fill_Moon.tga")
 fill:SetPoint("LEFT",art,"LEFT")
 fill:SetHeight(MR.db.height)
 local border=art:CreateTexture(nil,"OVERLAY")
 border:SetAllPoints(art)
 border:SetTexture(MR.path.."Frame_NoMoon.tga")
 local light=art:CreateTexture(nil,"OVERLAY")
 light:SetAllPoints(art)
 light:SetTexture(MR.path.."Frame_Moon_Light.tga")
 local entry={frame=art,bar=bar,fill=fill,border=border,filename=""}
 plate.moonRangeArt=entry
 return entry
end

local function Update(unit,plate)
 local art=Setup(plate)
 if not art then return end
 if not MR.db.enabled then art.frame:Hide();return end
 art.frame:Show()
 local low,high=art.bar:GetMinMaxValues()
 local current=art.bar:GetValue()
 local fraction=high and low and high>low and current and math.max(0,math.min(1,(current-low)/(high-low))) or 1
 art.fill:SetWidth(math.max(.01,MR.db.width*fraction))
 local selected=UnitExists("target") and UnitIsUnit(unit,"target")
 local filename=selected and MR:RangeState()==true and "Frame_Moon.tga" or "Frame_NoMoon.tga"
 if filename~=art.filename then
  art.filename=filename
  art.border:SetTexture(MR.path..filename)
 end
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
   local plate=active[unit]
   if plate and plate.moonRangeArt then plate.moonRangeArt.frame:Hide() end
   active[unit]=nil
  end
 end)
 if C_NamePlate and C_NamePlate.GetNamePlates then
  for _,plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
   local unit=plate.UnitFrame and plate.UnitFrame.unit
   if unit then active[unit]=plate;Update(unit,plate) end
  end
 end
 driver:SetScript("OnUpdate",function(_,dt)
  elapsed=elapsed+dt
  if elapsed<(MR.db.update or .15) then return end
  elapsed=0
  for unit,plate in pairs(active) do Update(unit,plate) end
 end)
end
