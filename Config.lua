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
  panel=CreateFrame("Frame","MoonRangeConfig",UIParent,"BackdropTemplate")
  panel:SetSize(460,900)
  panel:SetScale(0.82) -- fit the expanded controls on shorter displays
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
  if not panel.SetBackdrop then
   local background=panel:CreateTexture(nil,"BACKGROUND")
   background:SetAllPoints(panel)
   background:SetColorTexture(0.035,0.06,0.13,0.96)
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
  local themeLabel=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  themeLabel:SetPoint("TOPLEFT",25,-195)
  themeLabel:SetText("Nameplate Theme")
  local themeDrop=CreateFrame("Frame","MoonRangeThemeDropdown",panel,"UIDropDownMenuTemplate")
  themeDrop:SetPoint("TOPLEFT",4,-215)
  UIDropDownMenu_SetWidth(themeDrop,210)
  UIDropDownMenu_Initialize(themeDrop,function(_,level)
   for _,theme in ipairs({"Moon","Herbalism"}) do
    local choice=theme
    local info=UIDropDownMenu_CreateInfo()
    info.text=choice
    info.checked=MR.db.theme==choice
    info.func=function()
     MR.db.theme=choice
     UIDropDownMenu_SetText(themeDrop,choice)
     CloseDropDownMenus()
    end
    UIDropDownMenu_AddButton(info,level)
   end
  end)
  local section=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  section:SetPoint("TOPLEFT",25,-277)
  section:SetText("Nameplate Text")
  local fonts={{id="FRIZQT",label="Friz Quadrata"},{id="ARIAL",label="Arial Narrow"},{id="MORPHEUS",label="Morpheus"},{id="SKURRI",label="Skurri"}}
  local fontDrop=CreateFrame("Frame","MoonRangeFontDropdown",panel,"UIDropDownMenuTemplate")
  fontDrop:SetPoint("TOPLEFT",4,-298)
  UIDropDownMenu_SetWidth(fontDrop,210)
  UIDropDownMenu_Initialize(fontDrop,function(_,level)
   for _,f in ipairs(fonts) do
    local choice=f
    local info=UIDropDownMenu_CreateInfo()
    info.text=choice.label
    info.checked=MR.db.nameFont==choice.id
    info.func=function()
     MR.db.nameFont=choice.id
     UIDropDownMenu_SetText(fontDrop,choice.label)
    end
    UIDropDownMenu_AddButton(info,level)
   end
  end)
  local function Slider(key,label,min,max,step,x,y)
   local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormal")
   title:SetPoint("TOPLEFT",x,y)
   title:SetText(label)
   local slide=CreateFrame("Slider","MoonRangeSlider"..key,panel,"OptionsSliderTemplate")
   slide:SetPoint("TOPLEFT",x+8,y-22)
   slide:SetSize(175,16)
   slide:SetMinMaxValues(min,max)
   slide:SetValueStep(step)
   if slide.SetObeyStepOnDrag then slide:SetObeyStepOnDrag(true) end
   _G[slide:GetName().."Low"]:SetText(tostring(min))
   _G[slide:GetName().."High"]:SetText(tostring(max))
   local value=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
   value:SetPoint("LEFT",slide,"RIGHT",12,0)
   slide:SetScript("OnValueChanged",function(_,v)
    v=math.floor(v+0.5)
    MR.db[key]=v
    value:SetText(tostring(v))
   end)
   slide:SetValue(MR.db[key] or min)
   return slide
  end
  Slider("nameSize","Name font size",8,26,1,26,-364)
  Slider("nameX","Name horizontal", -60,60,1,254,-364)
  Slider("nameY","Name vertical", -40,75,1,26,-437)
  Slider("levelSize","Level font size",8,22,1,254,-437)
  -- Live layout preview; it is deliberately a mock, not a real nameplate.
  local previewLabel=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  previewLabel:SetPoint("TOPLEFT",25,-508)
  previewLabel:SetText("Live Layout Preview")
  local preview=CreateFrame("Frame",nil,panel)
  preview:SetSize(405,125)
  preview:SetPoint("TOP",0,-530)
  local previewBG=preview:CreateTexture(nil,"BACKGROUND")
  previewBG:SetAllPoints(preview)
  previewBG:SetColorTexture(0.06,0.09,0.10,0.8)
  local plate=CreateFrame("Frame",nil,preview)
  plate:SetSize(200,100)
  plate:SetPoint("CENTER",preview,"CENTER",0,-4)
  local art=plate:CreateTexture(nil,"ARTWORK")
  art:SetAllPoints(plate)
  local previewName=plate:CreateFontString(nil,"OVERLAY")
  previewName:SetWidth(350)
  local previewLevel=plate:CreateFontString(nil,"OVERLAY")
  local previewCast=CreateFrame("StatusBar",nil,plate)
  previewCast:SetStatusBarTexture("Interface\\\\TargetingFrame\\\\UI-StatusBar")
  previewCast:SetMinMaxValues(0,1)
  previewCast:SetValue(0.65)
  previewCast:SetStatusBarColor(0.78,0.45,0.20,1)
  local previewCastText=previewCast:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  previewCastText:SetPoint("CENTER")
  previewCastText:SetText("Wrath")
  local castTitle=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  castTitle:SetPoint("TOPLEFT",25,-667)
  castTitle:SetText("Nameplate Cast Bar")
  Slider("castWidth","Cast width",60,250,1,26,-698)
  Slider("castHeight","Cast height",4,30,1,254,-698)
  Slider("castX","Cast horizontal",-100,100,1,26,-773)
  Slider("castY","Cast vertical",-90,50,1,254,-773)
  local lastPreview=""
  preview:SetScript("OnUpdate",function()
   if not MR.db then return end
   local db=MR.db
   local theme=db.theme=="Herbalism" and "Herbalism" or "Moon"
   local frameName=theme=="Moon" and "Frame_Moon" or "Frame_Herbalism_01"
   local font=({FRIZQT="Fonts\\FRIZQT__.TTF",ARIAL="Fonts\\FRIZQT__.TTF",MORPHEUS="Fonts\\MORPHEUS.TTF",SKURRI="Fonts\\SKURRI.TTF"})[db.nameFont] or "Fonts\\FRIZQT__.TTF"
   if frameName~=lastPreview then
    lastPreview=frameName
    art:SetTexture(MR.path..theme.."\\\\"..frameName..".tga")
   end
   if not previewName:SetFont(font,db.nameSize or 14,"OUTLINE") then previewName:SetFont("Fonts\\FRIZQT__.TTF",db.nameSize or 14,"OUTLINE") end
   previewName:SetText("Timberling")
   previewName:ClearAllPoints()
   previewName:SetPoint("CENTER",plate,"CENTER",db.nameX or 0,db.nameY or 24)
   if not previewLevel:SetFont(font,db.levelSize or 11,"OUTLINE") then previewLevel:SetFont("Fonts\\FRIZQT__.TTF",db.levelSize or 11,"OUTLINE") end
   previewLevel:SetText(db.showLevel and "6" or "")
   previewLevel:ClearAllPoints()
   previewLevel:SetPoint("CENTER",plate,"CENTER",db.levelX or 0,db.levelY or -12)
   previewCast:SetSize(db.castWidth or 130,db.castHeight or 10)
   previewCast:ClearAllPoints()
   previewCast:SetPoint("CENTER",plate,"CENTER",db.castX or 0,db.castY or -32)
  end)
  local levelCheck=CreateFrame("CheckButton",nil,panel,"UICheckButtonTemplate")
  levelCheck:SetPoint("BOTTOMLEFT",22,48)
  levelCheck:SetChecked(MR.db.showLevel)
  levelCheck:SetScript("OnClick",function(self) MR.db.showLevel=self:GetChecked() end)
  local levelLabel=panel:CreateFontString(nil,"OVERLAY","GameFontNormal")
  levelLabel:SetPoint("LEFT",levelCheck,"RIGHT",2,0)
  levelLabel:SetText("Show unit level")
  local hint2=panel:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
  hint2:SetPoint("BOTTOMLEFT",26,18)
  hint2:SetText("Text updates live. /reload if Blizzard resets a nameplate.")
  panel:SetScript("OnShow",function()
   RefreshSpells()
   UIDropDownMenu_SetText(themeDrop,MR.db.theme or "Moon")
   for _,f in ipairs(fonts) do
    if MR.db.nameFont==f.id then UIDropDownMenu_SetText(fontDrop,f.label) end
   end
   levelCheck:SetChecked(MR.db.showLevel)
  end)
  local close=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
  close:SetSize(90,24)
  close:SetPoint("BOTTOMRIGHT",-22,18)
  close:SetText("Close")
  close:SetScript("OnClick",function() panel:Hide() end)

 end
 if panel:IsShown() then panel:Hide() else panel:Show();RefreshSpells() end
end
