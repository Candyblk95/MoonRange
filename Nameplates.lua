local _,MR=...
local tracked={}
local elapsedScan,elapsedTick=0,0
local function healthBar(frame)
 if not frame or not frame.GetChildren then return nil end
 local children={frame:GetChildren()}
 for _,child in ipairs(children) do
  if child.GetObjectType and child:GetObjectType()=="StatusBar" then return child end
  if child.GetChildren then
   local inner={child:GetChildren()}
   for _,nested in ipairs(inner) do
    if nested.GetObjectType and nested:GetObjectType()=="StatusBar" then return nested end
   end
  end
 end
end
local function addTexture(parent,file,layer)
 local texture=parent:CreateTexture(nil,layer)
 texture:SetAllPoints(parent)
 texture:SetTexture(MR.path..file)
 return texture
end
local function decorate(plate)
 if tracked[plate] then return end
 local bar=healthBar(plate)
 if not bar then return end
 local f=CreateFrame("Frame",nil,plate)
 f:SetSize(MR.db.width,MR.db.height)
 f:SetPoint("CENTER",bar,"CENTER",0,0)
 f:SetFrameLevel(plate:GetFrameLevel()+5)
 f:EnableMouse(false)
 addTexture(f,"BG_Moon.tga","BACKGROUND")
 local fill=f:CreateTexture(nil,"ARTWORK")
 fill:SetTexture(MR.path.."Fill_Moon.tga")
 fill:SetPoint("LEFT",f,"LEFT",0,0)
 fill:SetHeight(MR.db.height)
 local border=addTexture(f,"Frame_NoMoon.tga","OVERLAY")
 local light=addTexture(f,"Frame_Moon_Light.tga","OVERLAY")
 light:SetAlpha(0.8)
 tracked[plate]={holder=f,health=bar,fill=fill,border=border}
end
local function update(plate,art,state)
 if not MR.db.enabled or not plate:IsShown() or not art.health:IsShown() then art.holder:Hide();return end
 art.holder:Show()
 art.holder:SetSize(MR.db.width,MR.db.height)
 art.fill:SetHeight(MR.db.height)
 local low,high=art.health:GetMinMaxValues()
 local value=art.health:GetValue()
 local ratio=(high and low and high>low and value) and math.max(0,math.min(1,(value-low)/(high-low))) or 1
 art.fill:SetWidth(math.max(0.01,MR.db.width*ratio))
 local token=plate.namePlateUnitToken or plate.unit
 local targeted=token and UnitIsUnit and UnitIsUnit(token,"target")
 local file=(targeted and state==true) and "Frame_Moon.tga" or "Frame_NoMoon.tga"
 if art.file~=file then art.file=file;art.border:SetTexture(MR.path..file) end
end
function MR:StartNameplates()
 local ticker=CreateFrame("Frame")
 ticker:SetScript("OnUpdate",function(_,delta)
  elapsedScan=elapsedScan+delta;elapsedTick=elapsedTick+delta
  if elapsedScan>=0.7 then
   elapsedScan=0
   local frames={WorldFrame:GetChildren()}
   for _,plate in ipairs(frames) do
    local name=plate.GetName and plate:GetName()
    if name and name:match("^NamePlate") and plate:IsShown() then decorate(plate) end
   end
  end
  if elapsedTick>=(MR.db.update or 0.15) then
   elapsedTick=0
   local state=MR:RangeState()
   for plate,art in pairs(tracked) do update(plate,art,state) end
  end
 end)
end
