local _, MR = ...
local panel, pages, currentPage, refreshAll, navButtons
local spells = {}
local C = { ice={0.48,0.82,1}, gold={0.91,0.79,0.54}, muted={0.59,0.73,0.84} }
local function Font(parent, text, size, x, y, width, color)
 local f=parent:CreateFontString(nil,"OVERLAY")
 f:SetFont("Fonts\\FRIZQT__.TTF",size or 13,"OUTLINE")
 f:SetText(text or "")
 f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
 f:SetWidth(width or 410);f:SetJustifyH("LEFT")
 local c=color or C.ice;f:SetTextColor(c[1],c[2],c[3])
 return f
end
local function Section(parent,title,y)
 Font(parent,title,21,30,y,345,C.ice)
 local line=parent:CreateTexture(nil,"ARTWORK")
 line:SetColorTexture(0.29,0.62,0.86,0.55)
 line:SetPoint("TOPLEFT",parent,"TOPLEFT",30,y-30);line:SetSize(375,1)
end
local function Button(parent,label,x,y,w,fn)
 local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
 b:SetSize(w or 130,30);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
 b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
 b:SetBackdropColor(0.025,0.10,0.22,0.88);b:SetBackdropBorderColor(0.31,0.65,0.91,0.85)
 local t=b:CreateFontString(nil,"OVERLAY","GameFontNormal");t:SetPoint("CENTER");t:SetText(label);t:SetTextColor(0.71,0.87,1)
 b:SetScript("OnEnter",function(self)self:SetBackdropColor(0.09,0.25,0.42,0.96);t:SetTextColor(1,1,1)end)
 b:SetScript("OnLeave",function(self)self:SetBackdropColor(0.025,0.10,0.22,0.88);t:SetTextColor(0.71,0.87,1)end)
 b:SetScript("OnClick",fn)
 b.label=t
 return b
end
local function Dropdown(parent,name,x,y,width,options,get,set)
 local d=CreateFrame("Frame","MoonRange"..name,parent,"UIDropDownMenuTemplate")
 d:SetPoint("TOPLEFT",parent,"TOPLEFT",x-18,y+4)
 UIDropDownMenu_SetWidth(d,math.min(width or 225,330))
 UIDropDownMenu_Initialize(d,function(_,level)
  if level~=1 then return end
  for _,item in ipairs(type(options)=="function" and options() or options) do
   local v=item.value or item.label
   local info=UIDropDownMenu_CreateInfo()
   info.text=item.label;info.checked=get()==v
   info.func=function()set(v);UIDropDownMenu_SetText(d,item.label);CloseDropDownMenus()end
   UIDropDownMenu_AddButton(info,level)
  end
 end)
 local function refresh()
  local value=get()
  for _,item in ipairs(type(options)=="function" and options() or options) do
   if (item.value or item.label)==value then UIDropDownMenu_SetText(d,item.label);return end
  end
  UIDropDownMenu_SetText(d,value and value~="" and value or "Select...")
 end
 local textRegion=_G[d:GetName().."Text"]
 if textRegion then
  textRegion:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
  textRegion:SetTextColor(C.ice[1],C.ice[2],C.ice[3])
 end
 return refresh
end
local function Slider(parent,key,label,min,max,x,y,width)
 Font(parent,label,16,x,y,width or 195,C.ice)
 local s=CreateFrame("Slider","MoonRangeNewSlider"..key,parent,"OptionsSliderTemplate")
 s:SetSize((width or 195)-42,16);s:SetPoint("TOPLEFT",parent,"TOPLEFT",x+8,y-25)
 s:SetMinMaxValues(min,max);s:SetValueStep(1)
 if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true)end
 _G[s:GetName().."Low"]:SetText("");_G[s:GetName().."High"]:SetText("")
 -- Editable number alongside the slider for precise pixel placement.
 local edit=CreateFrame("EditBox",nil,parent,"InputBoxTemplate")
 edit:SetSize(43,22)
 edit:SetPoint("TOPLEFT",parent,"TOPLEFT",x+(width or 195)-36,y-19)
 edit:SetAutoFocus(false)
 edit:SetMaxLetters(5)
 edit:SetNumeric(false) -- negative offsets must be allowed
 edit:SetTextInsets(3,3,0,0)
 local function Commit()
  local n=tonumber(edit:GetText())
  if n then
   n=math.max(min,math.min(max,math.floor(n+0.5)))
   s:SetValue(n)
  end
  edit:SetText(tostring(math.floor(s:GetValue()+0.5)))
  edit:ClearFocus()
 end
 local apply=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
 apply:SetSize(51,19)
 apply:SetPoint("TOPLEFT",parent,"TOPLEFT",x+(width or 195)-44,y-42)
 apply:SetText("Apply")
 apply:SetScript("OnClick",Commit)
 edit:SetScript("OnEnterPressed",Commit)
 edit:SetScript("OnEscapePressed",function(self)
  self:SetText(tostring(math.floor(s:GetValue()+0.5)))
  self:ClearFocus()
 end)
 edit:SetScript("OnEditFocusLost",Commit)
 s:SetScript("OnValueChanged",function(_,v)
  v=math.floor(v+0.5)
  if MR.db then MR.db[key]=v end
  if not edit:HasFocus() then edit:SetText(tostring(v)) end
 end)
 return function()
  local v=MR.db[key]
  if v==nil then v=min end
  s:SetValue(v)
  if not edit:HasFocus() then edit:SetText(tostring(v)) end
 end
end
local function MakePage(name)
 if name=="Nameplates" then
  local scroll=CreateFrame("ScrollFrame","MoonRangeSettingsScroll",panel,"UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT",panel,"TOPLEFT",165,-215);scroll:SetSize(435,690);scroll:SetScale(0.88)
  local content=CreateFrame("Frame",nil,scroll);content:SetSize(448,1230)
  scroll:SetScrollChild(content);pages[name]=scroll
  return content
 end
 local p=CreateFrame("Frame",nil,panel)
 p:SetPoint("TOPLEFT",panel,"TOPLEFT",165,-215);p:SetSize(405,690);p:SetScale(0.88)
 pages[name]=p;return p
end
local function SelectPage(name)
 currentPage=name
 for id,p in pairs(pages) do if id==name then p:Show()else p:Hide()end end
 if navButtons then
  local others={}
  for _,id in ipairs({"Spells","Nameplates","Profiles"}) do
   if id~=name then others[#others+1]=id end
  end
  for i,b in ipairs(navButtons) do
   b.label:SetText(others[i])
   b.destination=others[i]
  end
 end
 if refreshAll then refreshAll()end
end
-- Standalone test plate: never touches real Blizzard nameplates.
local testPlate, testButton
local function StopTest()
 if testPlate then testPlate:Hide() end
 if testButton then testButton.label:SetText("Test In Game") end
end
local function ToggleTest()
 if testPlate and testPlate:IsShown() then StopTest();return end
 if not MR.db then return end
 if not testPlate then
  local root=CreateFrame("Frame","MoonRangeTestPlate",UIParent)
  root:SetSize(300,165);root:SetPoint("CENTER",UIParent,"CENTER",0,145)
  root:SetFrameStrata("DIALOG");root:SetMovable(true);root:EnableMouse(true)
  root:RegisterForDrag("LeftButton")
  root:SetScript("OnDragStart",root.StartMoving)
  root:SetScript("OnDragStop",root.StopMovingOrSizing)
  local art=CreateFrame("Frame",nil,root);art:SetSize(260,130);art:SetPoint("TOP",root,"TOP",0,0)
  local background=art:CreateTexture(nil,"BACKGROUND");background:SetAllPoints()
  local hp=CreateFrame("StatusBar",nil,art)
  hp:SetSize(185,19);hp:SetPoint("CENTER",art,"CENTER",0,0)
  hp:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  hp:SetMinMaxValues(0,100);hp:SetValue(75)
  local border=art:CreateTexture(nil,"OVERLAY");border:SetAllPoints()
   local contour=art:CreateTexture(nil,"OVERLAY",nil,1);contour:SetAllPoints();contour:Hide()
  local name=art:CreateFontString(nil,"OVERLAY")
  name:SetWidth(280);name:SetJustifyH("CENTER")
  local level=art:CreateFontString(nil,"OVERLAY")
  level:SetWidth(80);level:SetJustifyH("CENTER")
  local cast=CreateFrame("StatusBar",nil,root)
  cast:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  cast:SetStatusBarColor(0.42,0.72,1)
  cast:SetMinMaxValues(0,1)
  local castText=cast:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  castText:SetPoint("CENTER");castText:SetText("Preview Cast")
  local castBack=cast:CreateTexture(nil,"BACKGROUND")
  castBack:SetAllPoints();castBack:SetColorTexture(0.02,0.06,0.16,0.85)
  local hint=root:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  hint:SetPoint("BOTTOM",root,"BOTTOM",0,0)
  hint:SetText("MoonRange test  -  drag to move")
  root.art=art;root.background=background;root.hp=hp;root.border=border;root.contour=contour
  root.nameText=name;root.levelText=level;root.cast=cast
  root.clock=0;root.lastTheme=nil
  root:SetScript("OnUpdate",function(self,dt)
   if not MR.db then return end
   local d=MR.db
   local theme=(d.theme=="Herbalism" or d.theme=="Shadow" or d.theme=="Arcaneum" or d.theme=="Earth" or d.theme=="Frost" or d.theme=="Ice" or d.theme=="Holy" or d.theme=="Nature" or d.theme=="Aim" or d.theme=="Alliance" or d.theme=="Arcane" or d.theme=="Arctic") and d.theme or "Moon"
   if theme~=self.lastTheme then
    self.lastTheme=theme
    self.contour:SetShown(theme=="Frost" or theme=="Ice")
    if theme=="Frost" or theme=="Ice" then self.contour:SetTexture(MR.path.."frost\\"..(theme=="Frost" and "Contour_Frost" or "Contour_Ice")..".tga") end
    self.background:SetTexture(MR.path..(theme=="Arcaneum" and "Moon" or (theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Alliance" and "alliance" or theme=="Arcane" and "arcane" or theme=="Arctic" and "arctic" or theme).."\\"..((theme=="Moon" or theme=="Arcaneum") and "BG_Moon" or (theme=="Shadow" and "BG_Shadow" or theme=="Earth" and "BG_Earth" or (theme=="Frost" or theme=="Ice") and "BG_Frost" or theme=="Holy" and "BG_Holy" or theme=="Nature" and "BG_Nature" or theme=="Aim" and "BG_Aim" or theme=="Alliance" and "BG_Alliance" or theme=="Arcane" and "BG_Arcane" or theme=="Arctic" and "BG_Arctic" or "BG_Herbalism"))..".tga")
    self.border:SetTexture(MR.path..((theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Alliance" and "alliance" or theme).."\\"..(theme=="Moon" and "Frame_Moon" or theme=="Shadow" and "Frame_Shadow" or theme=="Arcaneum" and "Frame_Arcaneum_Light" or theme=="Earth" and "Frame_Earth" or (theme=="Frost" or theme=="Ice") and "Frame_Frost" or theme=="Holy" and "Frame_Holy" or theme=="Nature" and "Frame_Nature_01" or theme=="Aim" and "Frame_Aim" or theme=="Alliance" and "Frame_Alliance" or theme=="Arcane" and "Frame_Arcane" or theme=="Arctic" and "Frame_Arctic" or "Frame_Herbalism_01")..".tga")
    self.hp:SetStatusBarColor((theme=="Frost" or theme=="Ice") and .67 or theme=="Moon" and .20 or theme=="Shadow" and .50 or theme=="Arcaneum" and .52 or .35,(theme=="Frost" or theme=="Ice") and .79 or theme=="Moon" and .50 or theme=="Shadow" and .22 or theme=="Arcaneum" and .43 or .55,(theme=="Frost" or theme=="Ice") and .88 or theme=="Moon" and .80 or theme=="Shadow" and .66 or theme=="Arcaneum" and .79 or .25)
   end
   self.clock=(self.clock+dt)%3
   self.cast:SetValue(self.clock/3)
   local font=({FRIZQT="Fonts\\FRIZQT__.TTF",ARIAL="Fonts\\FRIZQT__.TTF",MORPHEUS="Fonts\\MORPHEUS.TTF",SKURRI="Fonts\\SKURRI.TTF"})[d.nameFont] or "Fonts\\FRIZQT__.TTF"
   self.nameText:SetFont(font,d.nameSize or 14,"OUTLINE")
   self.levelText:SetFont(font,d.levelSize or 11,"OUTLINE")
   local function rgb(hex)
    if type(hex)~="string" or not hex:match("^%x%x%x%x%x%x$") then return 1,1,1 end
    return tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255
   end
   self.nameText:SetTextColor(rgb(d.nameColor))
   self.levelText:SetTextColor(rgb(d.levelColor))
   self.nameText:SetText("MoonRange Test")
   self.levelText:SetText(d.showLevel and "30" or "")
   self.nameText:ClearAllPoints()
   self.nameText:SetPoint("CENTER",self.art,"CENTER",d.nameX or 0,d.nameY or 24)
   self.levelText:ClearAllPoints()
   self.levelText:SetPoint("CENTER",self.art,"CENTER",d.levelX or 0,d.levelY or -12)
   self.cast:SetSize(d.castWidth or 130,d.castHeight or 10)
   self.cast:ClearAllPoints()
   self.cast:SetPoint("CENTER",self.art,"CENTER",d.castX or 0,d.castY or -32)
  end)
  testPlate=root
 end
 testPlate.clock=0
 testPlate:Show()
 if testButton then testButton.label:SetText("Stop Preview") end
end

local function Build()
 panel=CreateFrame("Frame","MoonRangeConfig",UIParent,"BackdropTemplate")
 panel:SetSize(650,1000);panel:SetScale(0.75);panel:SetPoint("CENTER")
 panel:SetFrameStrata("DIALOG");panel:SetMovable(true);panel:EnableMouse(true)
 panel:RegisterForDrag("LeftButton");panel:SetScript("OnDragStart",panel.StartMoving)
 panel:SetScript("OnDragStop",panel.StopMovingOrSizing)
 panel:SetClampedToScreen(true)
 local art=panel:CreateTexture(nil,"BACKGROUND")
 art:SetAllPoints(panel);art:SetTexture("Interface\\AddOns\\MoonRange\\Textures\\MoonRange_GUI.tga")
 local fallback=panel:CreateTexture(nil,"BACKGROUND",nil,-1)
 fallback:SetPoint("TOPLEFT",panel,"TOPLEFT",65,-100);fallback:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-65,90)
 fallback:SetColorTexture(0.01,0.04,0.10,0.85)
 local title=Font(panel,"M O O N R A N G E",20,157,-117,320,C.ice);title:SetJustifyH("CENTER")
 local subtitle=Font(panel,"NamePlater made by Candy Black",15,175,-169,350,C.muted);subtitle:SetJustifyH("CENTER")
 local close=CreateFrame("Button","MoonRangeArtworkCloseButton",panel)
 close:SetSize(46,46)
 close:SetPoint("TOPLEFT",panel,"TOPLEFT",518,-102)
 close:SetFrameStrata("TOOLTIP")
 close:SetFrameLevel(panel:GetFrameLevel()+100)
 close:EnableMouse(true)
 close:RegisterForClicks("LeftButtonUp","LeftButtonDown")
 local closeArt=close:CreateTexture(nil,"ARTWORK")
 closeArt:SetAllPoints(close)
 closeArt:SetTexture("Interface\\AddOns\\MoonRange\\Textures\\Gui-exitbutton.tga")
 closeArt:SetTexCoord(518/650,564/650,102/1000,148/1000)
 close:SetNormalTexture(closeArt)
 close:SetScript("OnMouseUp",function(self,button) if button=="LeftButton" then panel:Hide() end end)
 close:SetScript("OnClick",function() panel:Hide() end)
 if UISpecialFrames then table.insert(UISpecialFrames,"MoonRangeConfig") end
 pages={};local refreshers={}
 local function Register(f)refreshers[#refreshers+1]=f end
 local spell=MakePage("Spells")
 Section(spell,"- Range Detection",-12)
 local function Body(parent,message,y,color)
  local f=Font(parent,message,17,30,y,350,color or C.muted)
  f:SetWordWrap(true)
  f:SetNonSpaceWrap(true)
  f:SetJustifyH("LEFT")
  return f
 end
 Body(spell,"Choose a spell from this character's spellbook.",-62)
 Font(spell,"Selected range spell",17,30,-142,350,C.ice)
 local spellRefresh=Dropdown(spell,"SpellPage",30,-172,290,function()
  spells=MR:KnownSpells();local list={{label="None",value=""}}
  for _,s in ipairs(spells) do list[#list+1]={label=s,value=s}end
  return list
 end,function()return MR.db.spell end,function(v)MR:SetSpell(v)end)
 Register(spellRefresh)
 Body(spell,"The glowing nameplate reacts to your chosen spell's range.",-255)
 Body(spell,"Your spell selection is saved for this character.",-336)
 Button(spell,"Refresh spellbook",30,-425,185,function()spellRefresh()end)
 testButton=Button(spell,"Test In Game",30,-485,185,ToggleTest)
 local nameplate=MakePage("Nameplates")
 Section(nameplate,"- Nameplate Atelier",-8)
 Font(nameplate,"Theme",17,30,-55,355,C.ice)
 local themeRefresh=Dropdown(nameplate,"ThemePage",30,-80,290,{{label="Moon"},{label="Herbalism"},{label="Shadow"},{label="Arcaneum"},{label="Earth"},{label="Frost"},{label="Ice"},{label="Holy"},{label="Nature"},{label="Aim"},{label="Alliance"},{label="Arcane"},{label="Arctic"}},function()return MR.db.theme end,function(v)MR.db.theme=v end)
 Register(themeRefresh)
 Font(nameplate,"Font",17,30,-139,355,C.ice)
 local fonts={{label="Friz Quadrata",value="FRIZQT"},{label="Arial Narrow",value="ARIAL"},{label="Morpheus",value="MORPHEUS"},{label="Skurri",value="SKURRI"}}
 Register(Dropdown(nameplate,"FontPage",30,-164,290,fonts,function()return MR.db.nameFont end,function(v)MR.db.nameFont=v end))
 Section(nameplate,"- Live Preview",-230)
 Font(nameplate,"Preview target",16,30,-275,350,C.ice)
 local preview=CreateFrame("Frame",nil,nameplate)
 preview:SetSize(375,175);preview:SetPoint("TOPLEFT",nameplate,"TOPLEFT",30,-352)
 local previewBG=preview:CreateTexture(nil,"BACKGROUND");previewBG:SetAllPoints();previewBG:SetColorTexture(0.015,0.05,0.12,0.65)
 local plate=CreateFrame("Frame",nil,preview);plate:SetSize(260,130);plate:SetPoint("CENTER",0,-3)
 local bg=plate:CreateTexture(nil,"BACKGROUND");bg:SetAllPoints()
 local health=CreateFrame("StatusBar",nil,plate);health:SetSize(185,19);health:SetPoint("CENTER");health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");health:SetMinMaxValues(0,100);health:SetValue(70)
 local fill=health:CreateTexture(nil,"ARTWORK",nil,1);fill:SetAllPoints(health:GetStatusBarTexture());fill:SetAlpha(.3)
 local border=plate:CreateTexture(nil,"OVERLAY");border:SetAllPoints()
  local contour=plate:CreateTexture(nil,"OVERLAY",nil,1);contour:SetAllPoints();contour:Hide()
 local name=plate:CreateFontString(nil,"OVERLAY");name:SetWidth(350);name:SetJustifyH("CENTER")
 local level=plate:CreateFontString(nil,"OVERLAY");level:SetWidth(90)
 local cast=CreateFrame("StatusBar",nil,plate);cast:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");cast:SetMinMaxValues(0,100);cast:SetValue(65);cast:SetStatusBarColor(.8,.5,.2)
 local castText=cast:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");castText:SetPoint("CENTER");castText:SetText("Wrath")
 local mode="hostile"
 local modes={{label="Hostile NPC",value="hostile"},{label="Neutral NPC",value="neutral"},{label="Friendly Player",value="friendly"},{label="Hostile Player",value="enemy"}}
 Register(Dropdown(nameplate,"PreviewMode",30,-298,290,modes,function()return mode end,function(v)mode=v end))
 local colors={Arctic={hostile={.74,.37,.52},neutral={.52,.72,.84},friendly={.39,.78,.76},enemy={.63,.50,.73}},Arcane={hostile={.84,.32,.67},neutral={.58,.43,.85},friendly={.34,.68,.86},enemy={.92,.54,.32}},Alliance={hostile={.70,.29,.32},neutral={.73,.62,.35},friendly={.31,.57,.83},enemy={.56,.37,.66}},Aim={hostile={1,1,1},neutral={1,1,1},friendly={1,1,1},enemy={1,1,1}},Nature={hostile={166/255,93/255,70/255},neutral={185/255,163/255,90/255},friendly={66/255,127/255,114/255},enemy={121/255,83/255,108/255}},Holy={hostile={143/255,77/255,64/255},neutral={201/255,163/255,91/255},friendly={61/255,89/255,109/255},enemy={93/255,23/255,9/255}},Frost={hostile={213/255,108/255,131/255},neutral={113/255,158/255,240/255},friendly={105/255,216/255,206/255},enemy={230/255,195/255,173/255}},Ice={hostile={150/255,61/255,92/255},neutral={52/255,84/255,163/255},friendly={35/255,127/255,133/255},enemy={169/255,119/255,104/255}},Earth={hostile={166/255,76/255,56/255},neutral={197/255,160/255,106/255},friendly={93/255,140/255,99/255},enemy={217/255,129/255,61/255}},Arcaneum={hostile={.78,.33,.69},neutral={.52,.43,.79},friendly={.37,.72,.83},enemy={.91,.56,.34}},Shadow={hostile={193/255,61/255,130/255},neutral={134/255,112/255,200/255},friendly={66/255,169/255,167/255},enemy={225/255,107/255,80/255}},Herbalism={hostile={117/255,70/255,67/255},neutral={190/255,147/255,57/255},friendly={62/255,102/255,65/255},enemy={225/255,141/255,1/255}},Moon={hostile={.70,.09,.39},neutral={.10,.40,.68},friendly={.45,.22,.65},enemy={.78,.30,.34}}}
 local fontPaths={FRIZQT="Fonts\\FRIZQT__.TTF",ARIAL="Fonts\\FRIZQT__.TTF",MORPHEUS="Fonts\\MORPHEUS.TTF",SKURRI="Fonts\\SKURRI.TTF"}
 local lastTheme,lastFont,lastNameSize,lastLevelSize
 local function UpdatePreview()
  if not MR.db then return end
  local d=MR.db;local theme=colors[d.theme] and d.theme or "Moon"
  if theme~=lastTheme then
   lastTheme=theme
   contour:SetShown(theme=="Frost" or theme=="Ice")
   if theme=="Frost" or theme=="Ice" then contour:SetTexture(MR.path.."frost\\"..(theme=="Frost" and "Contour_Frost" or "Contour_Ice")..".tga") end
   bg:SetTexture(MR.path..(theme=="Arcaneum" and "Moon" or (theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Alliance" and "alliance" or theme=="Arcane" and "arcane" or theme).."\\"..((theme=="Moon" or theme=="Arcaneum") and "BG_Moon" or (theme=="Shadow" and "BG_Shadow" or theme=="Earth" and "BG_Earth" or (theme=="Frost" or theme=="Ice") and "BG_Frost" or theme=="Holy" and "BG_Holy" or theme=="Nature" and "BG_Nature" or "BG_Herbalism"))..".tga")
   border:SetTexture(MR.path..((theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Alliance" and "alliance" or theme=="Arcane" and "arcane" or theme).."\\"..(theme=="Moon" and "Frame_NoMoon" or theme=="Shadow" and "Frame_Shadow" or theme=="Arcaneum" and "Frame_Arcaneum_Light" or theme=="Earth" and "Frame_Earth" or (theme=="Frost" or theme=="Ice") and "Frame_Frost" or theme=="Holy" and "Frame_Holy" or theme=="Nature" and "Frame_Nature_01" or theme=="Aim" and "Frame_Aim" or theme=="Alliance" and "Frame_Alliance" or theme=="Arcane" and "Frame_Arcane" or "Frame_Herbalism_01")..".tga")
   fill:SetTexture(MR.path..((theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Alliance" and "alliance" or theme=="Arcane" and "Moon" or theme).."\\"..(theme=="Moon" and "Fill_Moon" or theme=="Shadow" and "Fill_Shadow" or theme=="Arcaneum" and "Fill_Arcaneum" or theme=="Earth" and "Fill_Earth" or (theme=="Frost" or theme=="Ice") and "Fill_Frost" or theme=="Holy" and "Fill_Holy" or theme=="Nature" and "Fill_Nature" or theme=="Aim" and "Fill_Aim_Neuteral_Mob" or theme=="Alliance" and "Fill_Alliance" or theme=="Arcane" and "Fill_Moon" or theme=="Arctic" and "Fill_Arctic" or "Fill_Herbalism")..".tga")
   if theme=="Moon" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("ADD");fill:SetAlpha(.45)
   elseif theme=="Arcaneum" then fill:SetTexCoord(182/1024,850/1024,201/512,271/512);fill:SetBlendMode("ADD");fill:SetAlpha(.65)
    elseif theme=="Frost" or theme=="Ice" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.35)
    elseif theme=="Holy" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.40)
    elseif theme=="Arctic" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.45)
    elseif theme=="Arcane" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("ADD");fill:SetAlpha(.20)
    elseif theme=="Alliance" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.38)
    elseif theme=="Aim" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(1)
    elseif theme=="Nature" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.35)
    elseif theme=="Earth" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.35)
     elseif theme=="Shadow" then fill:SetTexCoord(129/1024,886/1024,203/512,281/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.32)
   else fill:SetTexCoord(144/1024,905/1024,175/512,305/512);fill:SetBlendMode("BLEND");fill:SetAlpha(.20)end
  end
  local c=colors[theme][mode]
  if theme=="Aim" then
   local files={neutral="Fill_Aim_Neuteral_Mob",hostile="Fill_Aim_Hostile_Mob",friendly="Fill_Aim_Friendly_Player",enemy="Fill_Aim_Hostile_Player"}
   fill:SetTexture(MR.path.."Aim\\"..files[mode]..".tga")
   health:SetStatusBarColor(.12,.12,.12)
   fill:SetVertexColor(1,1,1)
  else
   health:SetStatusBarColor(c[1],c[2],c[3])
   fill:SetVertexColor(theme~="Moon" and c[1] or 1,theme~="Moon" and c[2] or 1,theme~="Moon" and c[3] or 1)
  end
  local font=fontPaths[d.nameFont] or fontPaths.FRIZQT
  if font~=lastFont or d.nameSize~=lastNameSize then if not name:SetFont(font,d.nameSize or 14,"OUTLINE")then name:SetFont(fontPaths.FRIZQT,d.nameSize or 14,"OUTLINE")end;lastNameSize=d.nameSize end
  if font~=lastFont or d.levelSize~=lastLevelSize then if not level:SetFont(font,d.levelSize or 11,"OUTLINE")then level:SetFont(fontPaths.FRIZQT,d.levelSize or 11,"OUTLINE")end;lastLevelSize=d.levelSize end
  lastFont=font
  local function rgb(hex)
   if type(hex)~="string" or not hex:match("^%x%x%x%x%x%x$") then return 1,1,1 end
   return tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255
  end
  name:SetTextColor(rgb(d.nameColor));level:SetTextColor(rgb(d.levelColor))
  name:SetText(mode=="friendly" and "Moonwhisper" or "Timberling");name:ClearAllPoints();name:SetPoint("CENTER",plate,"CENTER",d.nameX or 0,d.nameY or 24)
  level:SetText(d.showLevel and "6" or "");level:ClearAllPoints();level:SetPoint("CENTER",plate,"CENTER",d.levelX or 0,d.levelY or -12)
  cast:SetSize(d.castWidth or 130,d.castHeight or 10);cast:ClearAllPoints();cast:SetPoint("CENTER",plate,"CENTER",d.castX or 0,d.castY or -32)
 end
 preview:SetScript("OnUpdate",UpdatePreview)
 Section(nameplate,"- Name & Level",-552)
 Register(Slider(nameplate,"nameSize","Name font size",8,26,30,-595,170))
 Register(Slider(nameplate,"nameX","Name horizontal",-60,60,210,-595,165))
 Register(Slider(nameplate,"nameY","Name vertical",-40,75,30,-662,170))
 Register(Slider(nameplate,"levelSize","Level font size",8,22,210,-662,165))
 Register(Slider(nameplate,"levelX","Level horizontal",-60,60,30,-729,170))
 Register(Slider(nameplate,"levelY","Level vertical",-60,60,210,-729,165))
 local check=CreateFrame("CheckButton",nil,nameplate,"UICheckButtonTemplate");check:SetPoint("TOPLEFT",nameplate,"TOPLEFT",24,-790)
 check:SetScript("OnClick",function(self)MR.db.showLevel=self:GetChecked()end)
 Font(nameplate,"Show unit level",16,65,-797,230,C.muted)
 Register(function()check:SetChecked(MR.db.showLevel)end)
 local function ColourField(key,label,x,y)
  Font(nameplate,label,16,x,y,165,C.ice)
  local edit=CreateFrame("EditBox",nil,nameplate,"InputBoxTemplate")
  edit:SetSize(112,24);edit:SetPoint("TOPLEFT",nameplate,"TOPLEFT",x+6,y-26)
  edit:SetAutoFocus(false);edit:SetMaxLetters(7)
  local swatch=nameplate:CreateTexture(nil,"ARTWORK")
  swatch:SetSize(23,23);swatch:SetPoint("LEFT",edit,"RIGHT",12,0)
  local function Refresh()
   local hex=MR.db[key] or "FFFFFF"
   edit:SetText("#"..hex)
   swatch:SetColorTexture(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,1)
  end
  local function Apply()
   local hex=(edit:GetText() or ""):gsub("#",""):upper()
   if hex:match("^%x%x%x%x%x%x$") then MR.db[key]=hex end
   edit:ClearFocus();Refresh()
  end
  edit:SetScript("OnEnterPressed",Apply)
  edit:SetScript("OnEscapePressed",function(self)self:ClearFocus();Refresh()end)
  Button(nameplate,"Apply",x+4,y-57,112,Apply)
  Register(Refresh)
 end
 Section(nameplate,"- Text Colours",-840)
 ColourField("nameColor","Name colour (hex)",30,-884)
 ColourField("levelColor","Level colour (hex)",210,-884)
 local castPage=CreateFrame("Frame",nil,nameplate)
 castPage:SetSize(448,245);castPage:SetPoint("TOPLEFT",nameplate,"TOPLEFT",0,-1010)
 Section(castPage,"- Blizzard Cast Bar",0)
 Register(Slider(castPage,"castWidth","Cast width",60,250,30,-42,170))
 Register(Slider(castPage,"castHeight","Cast height",4,30,210,-42,165))
 Register(Slider(castPage,"castX","Cast horizontal",-100,100,30,-105,170))
 Register(Slider(castPage,"castY","Cast vertical",-90,50,210,-105,165))
 local profile=MakePage("Profiles")
 Section(profile,"- Character Profiles",-12)
 Body(profile,"Each character has its own MoonRange settings.",-62)
 local who=Font(profile,"",18,30,-145,350,C.ice)
 who:SetWordWrap(true);who:SetNonSpaceWrap(true)
 local info=Font(profile,"",17,30,-210,350,C.ice)
 info:SetWordWrap(true);info:SetNonSpaceWrap(true)
 Body(profile,"Your Rogue can use Herbalism while your Druid uses Moon.",-300)
 Body(profile,"Switch characters and MoonRange loads their settings automatically.",-390)
 Body(profile,"Profile copying and a character list can be added next.",-495)
 Register(function()
  local character=UnitName("player") or "Current character"
  local realm=GetRealmName and GetRealmName() or ""
  who:SetText(character..(realm~="" and " - "..realm or ""))
  info:SetText("Theme: "..(MR.db.theme or "Moon").."\nSpell: "..(MR.db.spell~="" and MR.db.spell or "None"))
 end)
 navButtons={}
 for i,x in ipairs({127,376}) do
  local b=CreateFrame("Button",nil,panel)
  b:SetSize(153,46)
  b:SetPoint("TOPLEFT",panel,"TOPLEFT",x,-854)
  local label=b:CreateFontString(nil,"OVERLAY","GameFontNormal")
  label:SetPoint("CENTER");label:SetFont("Fonts\\FRIZQT__.TTF",18,"OUTLINE");label:SetTextColor(0.73,0.89,1)
  b.label=label
  b:SetScript("OnEnter",function(self)self.label:SetTextColor(1,1,1)end)
  b:SetScript("OnLeave",function(self)self.label:SetTextColor(0.73,0.89,1)end)
  b:SetScript("OnClick",function(self)if self.destination then SelectPage(self.destination)end end)
  navButtons[i]=b
 end
 refreshAll=function()for _,fn in ipairs(refreshers) do fn()end end
 panel:SetScript("OnShow",function()SelectPage(currentPage or "Nameplates")end)
 panel:Hide()
end
function MR:ToggleConfig()
 if not self.db then return end
 if not panel then Build()end
 if panel:IsShown()then panel:Hide()else panel:Show()end
end
