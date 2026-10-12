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
  MR.spellEdit=edit
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

-- Spellbook selection: hook the spellbook's click handler without replacing it.
-- Classic spellbook buttons use an index within the active spellbook tab.
local function chooseSpell(button, mouseButton)
 if not panel or not panel:IsShown() or not IsShiftKeyDown or not IsShiftKeyDown() then return end
 if mouseButton and mouseButton~="LeftButton" then return end
 if not button then return end
 local slot
 if SpellBook_GetSpellBookSlot then
  local ok,value=pcall(SpellBook_GetSpellBookSlot,button)
  if ok then slot=value end
 end
 if not slot and button.GetID then
  local index=button:GetID()
  local tab=SpellBookFrame and SpellBookFrame.selectedSkillLine
  if tab and GetSpellTabInfo then
   local _,_,offset=GetSpellTabInfo(tab)
   if offset then slot=offset+index end
  end
 end
 if not slot then return end
 local name=GetSpellBookItemName(slot,BOOKTYPE_SPELL or "spell")
 if name and MR:IsKnownSpell(name) then
  MR:SetSpell(name)
  if MR.spellEdit then MR.spellEdit:SetText(name) end
 end
end
if hooksecurefunc then
 if type(SpellButton_OnClick)=="function" then
  hooksecurefunc("SpellButton_OnClick",function(button,mouseButton) chooseSpell(button,mouseButton) end)
 end
 if type(SpellButton_OnModifiedClick)=="function" then
  hooksecurefunc("SpellButton_OnModifiedClick",function(button,mouseButton) chooseSpell(button,mouseButton) end)
 end
 -- Some Forever clients route modified spell clicks through the chat-link handler.
 if type(ChatEdit_InsertLink)=="function" then
  hooksecurefunc("ChatEdit_InsertLink",function(link)
   if not panel or not panel:IsShown() or not IsShiftKeyDown or not IsShiftKeyDown() then return end
   if type(link)~="string" then return end
   local name=link:match("%[([^%]]+)%]")
   if name and MR:IsKnownSpell(name) then
    MR:SetSpell(name)
    if MR.spellEdit then MR.spellEdit:SetText(name) end
   end
  end)
 end
end
