local _, MR = ...
local panel, dropdown, spellLabel
local selectedIndex = 1
local spells = {}

local function RefreshSpells()
 spells = MR:KnownSpells()
 -- All spellbook tabs are scanned, including General, where ranged attacks live.
 if spellLabel then spellLabel:SetText("Selected: "..(MR.db.spell ~= "" and MR.db.spell or "None")) end
 if dropdown and UIDropDownMenu_SetText then
  UIDropDownMenu_SetText(dropdown, MR.db.spell ~= "" and MR.db.spell or "Choose a known spell...")
 end
end

function MR:ToggleConfig()
 if not self.db then return end
 if not panel then
  panel=CreateFrame("Frame","MoonRangeConfig",UIParent)
  panel:SetSize(420,230)
  panel:SetPoint("CENTER")
  panel:SetFrameStrata("DIALOG")
  panel:SetMovable(true)
  panel:EnableMouse(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart",panel.StartMoving)
  panel:SetScript("OnDragStop",panel.StopMovingOrSizing)
  if panel.SetBackdrop then
   panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize=24})
  end
  local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  title:SetPoint("TOP",0,-23)
  title:SetText("MoonRange | "..(MR.className or "Class"))
  local instruction=panel:CreateFontString(nil,"OVERLAY","GameFontNormal")
  instruction:SetPoint("TOPLEFT",24,-62)
  instruction:SetText("Choose a spell you know:")
  dropdown=CreateFrame("Frame","MoonRangeSpellDropdown",panel,"UIDropDownMenuTemplate")
  dropdown:SetPoint("TOPLEFT",5,-79)
  UIDropDownMenu_SetWidth(dropdown,305)
  UIDropDownMenu_Initialize(dropdown,function(_,level)
   if level~=1 then return end
   RefreshSpells()
   if #spells==0 then
    local info=UIDropDownMenu_CreateInfo()
    info.text="No spells found in spellbook"
    info.disabled=true
    UIDropDownMenu_AddButton(info,level)
    return
   end
   for _,spell in ipairs(spells) do
    local name=spell
    local info=UIDropDownMenu_CreateInfo()
    info.text=name
    info.value=name
    info.checked=(MR.db.spell==name)
    info.func=function()
     MR:SetSpell(name)
     RefreshSpells()
     CloseDropDownMenus()
    end
    UIDropDownMenu_AddButton(info,level)
   end
  end)
  spellLabel=panel:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  spellLabel:SetPoint("TOPLEFT",25,-137)
  spellLabel:SetWidth(365)
  spellLabel:SetJustifyH("LEFT")
  local hint=panel:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
  hint:SetPoint("TOPLEFT",25,-164)
  hint:SetText("Includes General tab attacks such as Throw and Shoot.")
  local close=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
  close:SetSize(90,24)
  close:SetPoint("BOTTOMRIGHT",-22,18)
  close:SetText("Close")
  close:SetScript("OnClick",function() panel:Hide() end)
  panel:SetScript("OnShow",RefreshSpells)
 end
 if panel:IsShown() then panel:Hide() else RefreshSpells();panel:Show() end
end
