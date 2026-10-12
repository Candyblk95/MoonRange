local _,MR=...
local panel
function MR:ToggleConfig()
 if not self.db then return end
 if not panel then
  panel=CreateFrame("Frame","MoonRangeConfig",UIParent,"BackdropTemplate")
  panel:SetSize(390,225);panel:SetPoint("CENTER");panel:SetFrameStrata("DIALOG")
  panel:EnableMouse(true);panel:SetMovable(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart",panel.StartMoving)
  panel:SetScript("OnDragStop",panel.StopMovingOrSizing)
  if panel.SetBackdrop then panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize=24}) end
  local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  title:SetPoint("TOP",0,-20);title:SetText("MoonRange - "..(MR.className or "Class"))
  local label=panel:CreateFontString(nil,"OVERLAY","GameFontNormal")
  label:SetPoint("TOPLEFT",25,-60);label:SetText("Choose a spell from your spellbook:")
  local edit=CreateFrame("EditBox",nil,panel,"InputBoxTemplate")
  edit:SetSize(220,24);edit:SetPoint("TOPLEFT",30,-85);edit:SetAutoFocus(false)
  local index=0
  local function button(text,x,y,width,fn)
   local b=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
   b:SetSize(width,24);b:SetPoint("TOPLEFT",x,y);b:SetText(text);b:SetScript("OnClick",fn)
  end
  button("Set spell",265,-85,90,function() MR:SetSpell(edit:GetText());edit:ClearFocus() end)
  button("<",30,-126,45,function()
   local spells=MR:KnownSpells()
   if #spells>0 then index=((index-2)%#spells)+1;edit:SetText(spells[index]) end
  end)
  button(">",83,-126,45,function()
   local spells=MR:KnownSpells()
   if #spells>0 then index=(index%#spells)+1;edit:SetText(spells[index]) end
  end)
  button("Use shown spell",135,-126,145,function() MR:SetSpell(edit:GetText()) end)
  button("Close",275,-179,80,function() panel:Hide() end)
  panel:SetScript("OnShow",function() edit:SetText(MR.db.spell or "") end)
 else end
 if panel:IsShown() then panel:Hide() else panel:Show() end
end
