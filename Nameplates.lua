local _, MR = ...
local active, elapsed = {}, 0
local THEMES={Moon=true,Herbalism=true}
local function Theme() return MR.db and THEMES[MR.db.theme] and MR.db.theme or "Moon" end
local function Asset(theme,file) return MR.path..theme.."\\"..file..".tga" end
local FONT_PATHS={FRIZQT="Fonts\\FRIZQT__.TTF", ARIAL="Fonts\\FRIZQT__.TTF", MORPHEUS="Fonts\\MORPHEUS.TTF", SKURRI="Fonts\\SKURRI.TTF"}
local function Plain(v) return not (issecretvalue and issecretvalue(v)) end
local function IsObject(unit)
 if not unit or not UnitExists(unit) then return true end
 if UnitIsGameObject and UnitIsGameObject(unit) then return true end
 local guid=UnitGUID(unit)
 if guid and Plain(guid) and (guid:match("^GameObject") or guid:match("^Vignette")) then return true end
 return false
end

local BLUE = {0.10, 0.40, 0.68, 1}
local PURPLE = {0.45, 0.22, 0.65, 1}
local PINK = {0.70, 0.09, 0.39, 1}
local ORANGE_PINK = {0.78, 0.30, 0.34, 1}
-- Herbalism uses forest/jewel tones so its green-and-gold frame stays cohesive.
local HERB_BLUE = {190/255, 147/255, 57/255, 1} -- neutral NPC muted antique gold #BE9339
local HERB_PURPLE = {62/255, 102/255, 65/255, 1} -- friendly player deep forest green #3E6641
local HERB_PINK = {117/255, 70/255, 67/255, 1} -- hostile NPC dark rosewood #754643
local HERB_CORAL = {225/255, 141/255, 1/255, 1} -- hostile player #E18D01

local function UnitColour(unit)
 if not unit or not UnitExists(unit) then return BLUE end
 -- PvP opponents take precedence over NPC reaction colours.
 if UnitIsPlayer(unit) then
  if UnitCanAttack("player", unit) then return ORANGE_PINK end
  return PURPLE
 end
 local reaction = UnitReaction("player", unit)
 if reaction and not (issecretvalue and issecretvalue(reaction)) then
  if reaction <= 3 then return PINK end
  return BLUE
 end
 if UnitCanAttack("player", unit) then return PINK end
 return BLUE
end

local function GetBar(plate)
 local f = plate and plate.UnitFrame
 return f and (f.healthBar or (f.HealthBarsContainer and f.HealthBarsContainer.healthBar))
end

local function SafeWidth(bar)
 local width = bar:GetWidth()
 if issecretvalue and issecretvalue(width) then return nil end
 if type(width) ~= "number" or width <= 0 then return nil end
 return width
end

local function SetMoonColour(entry, unit)
 local colour = UnitColour(unit)
 if entry.theme=="Herbalism" then
  if colour==BLUE then colour=HERB_BLUE
  elseif colour==PURPLE then colour=HERB_PURPLE
  elseif colour==PINK then colour=HERB_PINK
  else colour=HERB_CORAL end
 end
 local texture = entry.bar:GetStatusBarTexture()
 if texture then texture:SetVertexColor(unpack(colour)) end
 -- Tint the Herbalism artwork too: at 88% opacity its original green
 -- otherwise masks the unit-type colour on the Blizzard fill below.
 if entry.shimmer then
  if entry.theme=="Herbalism" then entry.shimmer:SetVertexColor(unpack(colour))
  else entry.shimmer:SetVertexColor(1,1,1,1) end
 end
end

local function Resize(entry)
 local width = SafeWidth(entry.bar)
 if not width then return end
 -- The inner opening spans 757 of the 1024 pixels in the original TGA.
 local canvasWidth = width * 1024 / 757
 if entry.lastWidth == width then return end
 entry.lastWidth = width
 entry.frame:SetSize(canvasWidth, canvasWidth / 2)
end

local function FindCastBar(frame)
 return frame.castBar or frame.CastBar or
  (frame.castBarContainer and frame.castBarContainer.castBar) or
  (frame.CastBarContainer and frame.CastBarContainer.CastBar)
end

local function PositionCastBar(entry)
 local cast=entry.castBar
 if not cast or (cast.IsForbidden and cast:IsForbidden()) then return end
 local db=MR.db
 local w=db.castWidth or 130
 local h=db.castHeight or 10
 -- Only change geometry: Blizzard retains casting progress and spell state.
 if entry.castWidth~=w or entry.castHeight~=h then
  entry.castWidth=w;entry.castHeight=h
  cast:SetSize(w,h)
 end
 local x,y=db.castX or 0,db.castY or -32
 if entry.castX~=x or entry.castY~=y then
  entry.castX=x;entry.castY=y
  cast:ClearAllPoints()
  cast:SetPoint("CENTER",entry.frame,"CENTER",x,y)
 end
end

local function Setup(plate)
 if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
 local bar = GetBar(plate)
 if not bar then return end
 if plate.moonRangeArt then return plate.moonRangeArt end

 -- Never force the native bar's dimensions. Blizzard owns the size slider.
 local art = CreateFrame("Frame", nil, plate.UnitFrame)
 art:SetSize(200, 100)
 art:SetPoint("CENTER", bar, "CENTER")
 art:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
 art:EnableMouse(false)

 local background = art:CreateTexture(nil, "BACKGROUND")
 background:SetAllPoints(art)
 background:SetTexture(Asset("Moon","BG_Moon"))

 local foreground = CreateFrame("Frame", nil, plate.UnitFrame)
 foreground:SetAllPoints(art)
 foreground:SetFrameLevel(bar:GetFrameLevel() + 2)
 foreground:EnableMouse(false)

 local border = foreground:CreateTexture(nil, "OVERLAY", nil, 2)
 border:SetAllPoints(art)
 border:SetTexture(Asset("Moon","Frame_NoMoon"))

 local light = foreground:CreateTexture(nil, "OVERLAY", nil, 3)
 light:SetAllPoints(art)
 light:SetTexture(Asset("Moon","Frame_Moon_Light"))
 light:Hide()

 -- Experimental shimmer: follow the native StatusBar fill texture geometry.
 -- This is decorative only; Blizzard still controls the health amount.
 local nativeFill=bar:GetStatusBarTexture()
 local shimmer
 if nativeFill then
  shimmer=bar:CreateTexture(nil,"ARTWORK",nil,2)
  shimmer:SetTexture(Asset("Moon","Fill_Moon"))
  shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  shimmer:SetAllPoints(nativeFill)
  shimmer:SetAlpha(0.45)
  shimmer:SetBlendMode("ADD")
 end

 local entry = {frame=art, foreground=foreground, border=border, background=background, shimmer=shimmer,
                light=light, bar=bar, filename="", unit=nil}
 entry.castBar=FindCastBar(plate.UnitFrame)
 plate.moonRangeArt = entry

 if bar.bgTexture then bar.bgTexture:SetAlpha(0) end
 if bar.selectedBorder then bar.selectedBorder:SetAlpha(0) end
 if bar.deselectedOverlay then bar.deselectedOverlay:SetAlpha(0) end
 local frame = plate.UnitFrame
 if frame.PlayerLevelDiffFrame then frame.PlayerLevelDiffFrame:SetAlpha(0) end
 if frame.LevelFrame then frame.LevelFrame:SetAlpha(0) end

 -- Keep Blizzard's original animated fill. Reapply only its colour.
 if hooksecurefunc then
  hooksecurefunc(bar, "SetStatusBarColor", function()
   SetMoonColour(entry, entry.unit)
  end)
 end

 -- MoonRange owns the text; Blizzard's name and level stay invisible.
 local oldName=bar.unitNameFontString or frame.name or frame.Name
 entry.blizzardName=oldName
 entry.blizzardLevel=frame.LevelFrame
 local textLayer=CreateFrame("Frame",nil,plate.UnitFrame)
 textLayer:SetAllPoints(art)
 textLayer:SetFrameLevel(bar:GetFrameLevel()+5)
 entry.textLayer=textLayer
 entry.nameText=textLayer:CreateFontString(nil,"OVERLAY")
 entry.nameText:SetJustifyH("CENTER")
 entry.nameText:SetWidth(400)
 entry.nameText:SetWordWrap(false)
 entry.levelText=textLayer:CreateFontString(nil,"OVERLAY")
 entry.levelText:SetJustifyH("CENTER")
 entry.levelText:SetWidth(80)
 if oldName then oldName:SetAlpha(0) end
 if frame.LevelFrame then frame.LevelFrame:SetAlpha(0) end

 Resize(entry)
 return entry
end

local function RefreshShimmer(entry)
 local shimmer=entry.shimmer
 if not shimmer then return end
 local fill=entry.bar:GetStatusBarTexture()
 if not fill then shimmer:Hide();return end
 if fill~=entry.shimmerSource then
  entry.shimmerSource=fill
  shimmer:ClearAllPoints()
  shimmer:SetAllPoints(fill)
 end
 -- Some Blizzard layouts reuse the fill texture and reset its geometry.
 -- Keep the overlay tied to the live fill rather than to a fixed bar width.
 if not fill:IsShown() then shimmer:Hide() else shimmer:Show() end
end

local function ApplyTheme(entry)
 local theme=Theme()
 if entry.theme==theme then return end
 entry.theme=theme
 entry.filename=""
 entry.background:SetTexture(Asset(theme,theme=="Moon" and "BG_Moon" or "BG_Herbalism"))
 if entry.shimmer then
  entry.shimmer:SetTexture(Asset(theme,theme=="Moon" and "Fill_Moon" or "Fill_Herbalism"))
  if theme=="Moon" then
   entry.shimmer:SetBlendMode("ADD")
   entry.shimmer:SetAlpha(0.45)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  else
   -- The original Herbalism fill is green artwork. Blend it over a dark\n   -- green native fill instead of adding it over pink/purple solid colours.\n   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(0.20)
   entry.shimmer:SetTexCoord(144/1024,905/1024,175/512,305/512)
  end
 end
 if theme=="Moon" then
  entry.light:SetTexture(Asset("Moon","Frame_Moon_Light"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 else
  -- User-supplied standalone range indicator, above all animation frames.
  entry.light:SetTexture(Asset("Herbalism","Frame_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 end
end

local function UpdateText(entry,unit)
 local db=MR.db
 local font=FONT_PATHS[db.nameFont] or FONT_PATHS.FRIZQT
 if not entry.nameText:SetFont(font,db.nameSize or 14,"OUTLINE") then entry.nameText:SetFont(FONT_PATHS.FRIZQT,db.nameSize or 14,"OUTLINE") end
 entry.nameText:ClearAllPoints()
 entry.nameText:SetPoint("CENTER",entry.frame,"CENTER",db.nameX or 0,db.nameY or 24)
 local name=UnitName(unit)
 if name and Plain(name) then entry.nameText:SetText(name) else entry.nameText:SetText("") end
 if not entry.levelText:SetFont(font,db.levelSize or 11,"OUTLINE") then entry.levelText:SetFont(FONT_PATHS.FRIZQT,db.levelSize or 11,"OUTLINE") end
 entry.levelText:ClearAllPoints()
 entry.levelText:SetPoint("CENTER",entry.frame,"CENTER",db.levelX or 0,db.levelY or -12)
 local level=UnitLevel(unit)
 if db.showLevel and level and Plain(level) then
  entry.levelText:SetText(level < 0 and "??" or tostring(level))
 else entry.levelText:SetText("") end
end

local function Update(unit, plate)
 local entry = Setup(plate)
 if not entry then return end
 entry.unit = unit
 local object=IsObject(unit)
 if object or not MR.db.enabled then
  entry.frame:Hide();entry.foreground:Hide();entry.textLayer:Hide()
  if entry.shimmer then entry.shimmer:Hide() end
  if entry.blizzardName then entry.blizzardName:SetAlpha(1) end
  if entry.blizzardLevel then entry.blizzardLevel:SetAlpha(1) end
  return
 end
 if entry.blizzardName then entry.blizzardName:SetAlpha(0) end
 if entry.blizzardLevel then entry.blizzardLevel:SetAlpha(0) end
 entry.textLayer:Show()
 UpdateText(entry,unit)
 if not MR.db.enabled then
  entry.frame:Hide()
  entry.foreground:Hide()
  return
 end
 entry.frame:Show()
 entry.foreground:Show()
 ApplyTheme(entry)
 RefreshShimmer(entry)
 Resize(entry)
 SetMoonColour(entry, unit)
 PositionCastBar(entry)

 local selected = UnitExists("target") and UnitIsUnit(unit, "target")
 local inRange = selected and MR:RangeState()
 if entry.theme=="Herbalism" then
  -- Three supplied animation frames, cycling in order.
  local frameNumber=math.floor((GetTime()*6)%3)+1
  local frameName=string.format("Frame_Herbalism_%02d",frameNumber)
  if entry.filename~=frameName then
   entry.filename=frameName
   local texture=Asset("Herbalism",frameName)
   entry.border:SetTexture(texture)
  end
 else
  local filename=inRange==true and "Frame_Moon" or "Frame_NoMoon"
  if entry.filename~=filename then
   entry.filename=filename
   entry.border:SetTexture(Asset("Moon",filename))
  end
 end
 if inRange==true then entry.light:Show() else entry.light:Hide() end
end

function MR:StartNameplates()
 local driver = CreateFrame("Frame")
 driver:RegisterEvent("NAME_PLATE_UNIT_ADDED")
 driver:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
 driver:RegisterEvent("PLAYER_TARGET_CHANGED")
 driver:SetScript("OnEvent", function(_, event, unit)
  if event == "NAME_PLATE_UNIT_ADDED" and C_NamePlate then
   local plate = C_NamePlate.GetNamePlateForUnit(unit)
   if plate then active[unit] = plate; Update(unit, plate) end
  elseif event == "NAME_PLATE_UNIT_REMOVED" then
   local plate=active[unit]
   if plate and plate.moonRangeArt then
    local e=plate.moonRangeArt
    e.frame:Hide();e.foreground:Hide();e.textLayer:Hide()
    if e.shimmer then e.shimmer:Hide() end
   end
   active[unit] = nil
  elseif event == "PLAYER_TARGET_CHANGED" then
   for token, plate in pairs(active) do Update(token, plate) end
  end
 end)
 driver:SetScript("OnUpdate", function(_, dt)
  elapsed = elapsed + dt
  if elapsed < (MR.db.update or .15) then return end
  elapsed = 0
  for unit, plate in pairs(active) do Update(unit, plate) end
 end)
end
