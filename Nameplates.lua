local _, MR = ...
local active, elapsed = {}, 0
local THEMES={Moon=true,Herbalism=true,Shadow=true,Arcaneum=true,Earth=true,Frost=true,Ice=true,Holy=true,Nature=true,Aim=true,Alliance=true,Arcane=true,Arctic=true}
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
 if entry.theme=="Arcane" then
  if colour==BLUE then colour={.58,.43,.85,1}
  elseif colour==PURPLE then colour={.34,.68,.86,1}
  elseif colour==PINK then colour={.84,.32,.67,1}
  else colour={.92,.54,.32,1} end
 elseif entry.theme=="Arcaneum" then
  if colour==BLUE then colour={.52,.43,.79,1}
  elseif colour==PURPLE then colour={.37,.72,.83,1}
  elseif colour==PINK then colour={.78,.33,.69,1}
  else colour={.91,.56,.34,1} end
 elseif entry.theme=="Shadow" then
  if colour==BLUE then colour={134/255,112/255,200/255,1}
  elseif colour==PURPLE then colour={66/255,169/255,167/255,1}
  elseif colour==PINK then colour={193/255,61/255,130/255,1}
  else colour={225/255,107/255,80/255,1} end
 elseif entry.theme=="Earth" then
  if colour==BLUE then colour={197/255,160/255,106/255,1} -- sandstone neutral
  elseif colour==PURPLE then colour={93/255,140/255,99/255,1} -- moss friendly player
  elseif colour==PINK then colour={166/255,76/255,56/255,1} -- terracotta hostile mob
  else colour={217/255,129/255,61/255,1} end -- copper hostile player
 elseif entry.theme=="Frost" then
  if colour==BLUE then colour={113/255,158/255,240/255,1} -- neutral: previous hostile blue
  elseif colour==PURPLE then colour={105/255,216/255,206/255,1} -- friendly: turquoise
  elseif colour==PINK then colour={213/255,108/255,131/255,1} -- hostile mob: dusty rose #BA9D9B
  else colour={230/255,195/255,173/255,1} end -- hostile player: peach #E6C3AD
 elseif entry.theme=="Arctic" then
  if colour==BLUE then colour={.52,.72,.84,1}
  elseif colour==PURPLE then colour={.39,.78,.76,1}
  elseif colour==PINK then colour={.74,.37,.52,1}
  else colour={.63,.50,.73,1} end
 elseif entry.theme=="Ice" then
  if colour==BLUE then colour={52/255,84/255,163/255,1} -- neutral: previous hostile blue
  elseif colour==PURPLE then colour={35/255,127/255,133/255,1} -- friendly: deep turquoise
  elseif colour==PINK then colour={150/255,61/255,92/255,1} -- hostile mob: deeper dusty rose
  else colour={169/255,119/255,104/255,1} end -- hostile player: deeper peach
 elseif entry.theme=="Holy" then
  if colour==BLUE then colour={201/255,163/255,91/255,1} -- champagne neutral
  elseif colour==PURPLE then colour={61/255,89/255,109/255,1} -- antique gold friendly player
  elseif colour==PINK then colour={143/255,77/255,64/255,1} -- rose bronze hostile mob
  else colour={93/255,23/255,9/255,1} end -- deep bronze hostile player
 elseif entry.theme=="Alliance" then
  if colour==BLUE then colour={.73,.62,.35,1} -- heraldic gold, neutral NPC
  elseif colour==PURPLE then colour={.31,.57,.83,1} -- sapphire blue, friendly player
  elseif colour==PINK then colour={.70,.29,.32,1} -- royal crimson, hostile NPC
  else colour={.56,.37,.66,1} end -- regal violet, hostile player
 elseif entry.theme=="Nature" then
  if colour==BLUE then colour={185/255,163/255,90/255,1} -- Golden Moss neutral
  elseif colour==PURPLE then colour={66/255,127/255,114/255,1} -- Forest Teal friendly player
  elseif colour==PINK then colour={166/255,93/255,70/255,1} -- Autumn Rosewood hostile mob
  else colour={121/255,83/255,108/255,1} end -- Wild Plum hostile player
 elseif entry.theme=="Herbalism" then
  if colour==BLUE then colour=HERB_BLUE
  elseif colour==PURPLE then colour=HERB_PURPLE
  elseif colour==PINK then colour=HERB_PINK
  else colour=HERB_CORAL end
 end
 if entry.theme=="Aim" then
  -- Aim ships four finished fills: preserve their baked-in colours.
  local kind=UnitColour(unit)
  local file=kind==BLUE and "Fill_Aim_Neuteral_Mob"
    or kind==PINK and "Fill_Aim_Hostile_Mob"
    or kind==PURPLE and "Fill_Aim_Friendly_Player"
    or "Fill_Aim_Hostile_Player"
  if entry.shimmer and entry.aimFill~=file then
   entry.aimFill=file
   entry.shimmer:SetTexture(Asset("Aim",file))
  end
  local native=entry.bar:GetStatusBarTexture()
  if native then native:SetVertexColor(.12,.12,.12,1) end
  if entry.shimmer then entry.shimmer:SetVertexColor(1,1,1,1) end
  return
 end
 local texture = entry.bar:GetStatusBarTexture()
 if texture then texture:SetVertexColor(unpack(colour)) end
 -- Tint the Herbalism artwork too: at 88% opacity its original green
 -- otherwise masks the unit-type colour on the Blizzard fill below.
 if entry.shimmer then
  if entry.theme=="Herbalism" or entry.theme=="Shadow" or entry.theme=="Arcaneum" or entry.theme=="Earth" or entry.theme=="Frost" or entry.theme=="Ice" or entry.theme=="Holy" or entry.theme=="Nature" or entry.theme=="Alliance" or entry.theme=="Arcane" or entry.theme=="Arctic" then entry.shimmer:SetVertexColor(unpack(colour))
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
 if not frame then return nil end
 -- Forever's Blizzard nameplates can expose the bar directly or in a container.
 local containers={frame,frame.CastBarsContainer,frame.castBarsContainer,frame.castBarContainer,frame.CastBarContainer,frame.SpellCastBarContainer}
 for _,owner in pairs(containers) do
  if owner then
   for _,key in ipairs({"castBar","CastBar","spellCastBar","SpellCastBar","castingBar","CastingBar"}) do
    local candidate=owner[key]
    if candidate and candidate.SetSize and candidate.SetPoint then return candidate end
   end
  end
 end
 return nil
end

local function PositionCastBar(entry)
 local cast=entry.castBar
 if not cast or (cast.IsForbidden and cast:IsForbidden()) or entry.castBarRestricted then return end
 local db=MR.db
 local w,h=db.castWidth or 130,db.castHeight or 10
 local x,y=db.castX or 0,db.castY or -32
 -- Never query protected cast-bar anchors or dimensions (GetPoint/GetSize).
 -- Attempt geometry only when settings change, and stop if Forever restricts it.
 -- Blizzard can reset the cast bar's anchor when casting begins.
 -- Reapply geometry while visible; protected frames are handled by pcall below.
 local ok=pcall(function()
  cast:SetSize(w,h)
  cast:ClearAllPoints()
  cast:SetPoint("CENTER",entry.frame,"CENTER",x,y)
 end)
 if not ok then
  entry.castBarRestricted=true
  if not MR.castRestrictionWarned then
   MR.castRestrictionWarned=true
   MR:Print("Blizzard protects cast-bar geometry on this client; leaving its native placement intact.")
  end
  return
 end
 entry.castAppliedBar,entry.castAppliedW,entry.castAppliedH=cast,w,h
 entry.castAppliedX,entry.castAppliedY=x,y
end

local function Setup(plate)
 if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
 local bar = GetBar(plate)
 if not bar then return end
 if plate.moonRangeArt then
  local existing=plate.moonRangeArt
  existing.castBar=FindCastBar(plate.UnitFrame) or existing.castBar
  return existing
 end

 -- Never force the native bar's dimensions. Blizzard owns the size slider.
 local art = CreateFrame("Frame", nil, plate.UnitFrame)
 art:SetSize(200, 100)
 art:SetPoint("CENTER", bar, "CENTER")
 art:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
 art:EnableMouse(false)

 -- Extra Arctic frost backdrop for Frost and Ice, behind native health and frame.
 local frostBackdrop = art:CreateTexture(nil, "BACKGROUND", nil, 1)
 frostBackdrop:SetPoint("CENTER",art,"CENTER",0,0)
 frostBackdrop:SetTexture(Asset("arctic","FrostBG_Arctic"))
 frostBackdrop:SetBlendMode("BLEND")
 frostBackdrop:SetAlpha(0)
 frostBackdrop:Hide()
 -- A one-shot frost bloom whenever the nameplate appears.
 local frostBloomTime=0
 local frostBloomDuration=2.4
 local function UpdateFrostBloom()
  local progress=math.min(1,frostBloomTime/frostBloomDuration)
  local eased=1-(1-progress)^3
  local width,height=art:GetSize()
  frostBackdrop:SetSize(width*(.86+.30*eased),height*(.86+.30*eased))
  frostBackdrop:SetAlpha(.38*eased)
 end
 art:HookScript("OnShow",function()
  frostBloomTime=0
  if frostBackdrop:IsShown() then UpdateFrostBloom() end
 end)
 art:SetScript("OnUpdate",function(_,dt)
  if not frostBackdrop:IsShown() or frostBloomTime>=frostBloomDuration then return end
  frostBloomTime=math.min(frostBloomDuration,frostBloomTime+math.min(dt,.1))
  UpdateFrostBloom()
 end)

 -- Arctic selected-target frost and light grow outward once, without alpha fading.
 local arcticBloom=CreateFrame("Frame",nil,art)
 arcticBloom:SetAllPoints(art)
 arcticBloom:SetFrameLevel(art:GetFrameLevel())
 arcticBloom:EnableMouse(false)
 local arcticFrost=arcticBloom:CreateTexture(nil,"ARTWORK",nil,1)
 arcticFrost:SetTexture(Asset("arctic","FrostBG_Arctic"))
 arcticFrost:SetBlendMode("BLEND")
 arcticFrost:SetAlpha(1)
 arcticFrost:SetPoint("CENTER",art,"CENTER",0,0)
 -- Separate foreground frame: the light must overlay Frame_Arctic,
 -- while the frost remains behind the health bar and frame.
 local arcticLightLayer=CreateFrame("Frame",nil,plate.UnitFrame)
 arcticLightLayer:SetAllPoints(art)
 arcticLightLayer:SetFrameLevel(bar:GetFrameLevel()+3)
 arcticLightLayer:EnableMouse(false)
 local arcticLight=arcticLightLayer:CreateTexture(nil,"OVERLAY",nil,1)
 arcticLight:SetTexture(Asset("arctic","Frame_Arctic_Light"))
 arcticLight:SetBlendMode("BLEND")
 arcticLight:SetAlpha(1)
 arcticLight:SetPoint("CENTER",art,"CENTER",0,0)
 arcticLightLayer:Hide()
 arcticBloom:Hide()
 local arcticBloomTime=0
 local function UpdateArcticBloom()
  local t=math.min(1,arcticBloomTime/2.4)
  local eased=1-(1-t)^3
  local w,h=art:GetSize()
  arcticFrost:SetSize(w*(.82+.34*eased),h*(.82+.34*eased))
  arcticLight:SetSize(math.max(.01,w*eased),math.max(.01,h*eased)) -- grow from zero to exactly the base frame size
 end
 local function SetArcticBloom(active)
  if active then
   if not arcticBloom:IsShown() then
    arcticBloomTime=0
    UpdateArcticBloom()
    arcticBloom:Show()
    arcticLightLayer:Show()
   end
  else arcticBloom:Hide();arcticLightLayer:Hide() end
 end
 arcticBloom:SetScript("OnUpdate",function(_,dt)
  if arcticBloomTime>=2.4 then return end
  arcticBloomTime=math.min(2.4,arcticBloomTime+math.min(dt,.1))
  UpdateArcticBloom()
 end)
 art:HookScript("OnShow",function()
  if arcticBloom:IsShown() then arcticBloomTime=0;UpdateArcticBloom() end
 end)

 local background = art:CreateTexture(nil, "BACKGROUND", nil, 0)
 background:SetAllPoints(art)
 background:SetTexture(Asset("Moon","BG_Moon"))

 local foreground = CreateFrame("Frame", nil, plate.UnitFrame)
 foreground:SetAllPoints(art)
 foreground:SetFrameLevel(bar:GetFrameLevel() + 2)
 foreground:EnableMouse(false)

 -- Arcane Rune_Back is part of the base frame, not target-only particles.
 -- Rune_Back sits BEHIND the health bar, raised so its circle crowns the bar.
 local arcaneRuneBack=art:CreateTexture(nil,"ARTWORK",nil,1)
 arcaneRuneBack:SetSize(200,70) -- preserve original width; reduce excessive height
 arcaneRuneBack:SetPoint("CENTER",art,"CENTER",0,28)
 arcaneRuneBack:SetTexture(Asset("arcane","Rune_Back"))
 arcaneRuneBack:SetBlendMode("ADD")
 arcaneRuneBack:SetVertexColor(1,.75,1)
 arcaneRuneBack:SetAlpha(.88)
 arcaneRuneBack:Hide()
 local border = foreground:CreateTexture(nil, "OVERLAY", nil, 2)
 border:SetAllPoints(art)
 border:SetTexture(Asset("Moon","Frame_NoMoon"))

 local contour = foreground:CreateTexture(nil,"OVERLAY",nil,3)
 contour:SetAllPoints(art);contour:Hide()
 local flame = foreground:CreateTexture(nil,"OVERLAY",nil,1)
 flame:SetAllPoints(art);flame:Hide()
 local rangeLayer = CreateFrame("Frame", nil, foreground)
 rangeLayer:SetAllPoints(art)
 rangeLayer:SetFrameLevel(foreground:GetFrameLevel()+8)
 rangeLayer:EnableMouse(false)
 local light = rangeLayer:CreateTexture(nil, "OVERLAY", nil, 3)
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

 -- Alliance-only selected-target accents. Keep both beneath the range layer.
 local allianceAccents=CreateFrame("Frame",nil,foreground)
 allianceAccents:SetAllPoints(art)
 allianceAccents:SetFrameLevel(foreground:GetFrameLevel()+1)
 allianceAccents:EnableMouse(false)
 local allianceLight=allianceAccents:CreateTexture(nil,"ARTWORK",nil,1)
 allianceLight:SetAllPoints(art)
 allianceLight:SetTexture(Asset("alliance","BG_Alliance_Light"))
 allianceLight:SetBlendMode("ADD")
 local allianceSapphire=allianceAccents:CreateTexture(nil,"ARTWORK",nil,2)
 allianceSapphire:SetAllPoints(art)
 allianceSapphire:SetTexture(Asset("alliance","Saphir_Alliance"))
 allianceSapphire:SetBlendMode("BLEND")
 local allianceSapphireGlow=allianceAccents:CreateTexture(nil,"ARTWORK",nil,3)
 allianceSapphireGlow:SetAllPoints(art)
 allianceSapphireGlow:SetTexture(Asset("alliance","Saphir_Alliance"))
 allianceSapphireGlow:SetBlendMode("ADD")
 allianceSapphireGlow:SetVertexColor(.34,.68,1)
 allianceAccents:Hide()
 local allianceClock=0
 allianceAccents:SetScript("OnUpdate",function(_,dt)
  allianceClock=allianceClock+math.min(dt,.05)
  local wave=.5+.5*math.sin(allianceClock*2.7)
  allianceLight:SetAlpha(.13+.16*wave)
  allianceSapphire:SetAlpha(.76+.20*wave)
  allianceSapphireGlow:SetAlpha(.10+.24*wave)
 end)

 local entry = {frame=art, foreground=foreground, border=border, background=background, frostBackdrop=frostBackdrop, arcticBloom=arcticBloom, setArcticBloom=SetArcticBloom, resetFrostBloom=function() frostBloomTime=0;UpdateFrostBloom() end, shimmer=shimmer,
                allianceAccents=allianceAccents, arcaneRuneBack=arcaneRuneBack,
                light=light, flame=flame, contour=contour, bar=bar, filename="", unit=nil}
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
 -- Arcane artwork sits slightly high relative to Blizzard's health fill.
 -- Shift the entire art canvas (and its attached rune/effect layers), not the bar.
 entry.frame:ClearAllPoints()
 entry.frame:SetPoint("CENTER",entry.bar,"CENTER",0,theme=="Arcane" and -5 or 0)
 entry.filename=""
 entry.flame:SetShown(theme=="Shadow")
 entry.contour:SetShown(theme=="Frost" or theme=="Ice")
 if entry.frostBackdrop then
  entry.frostBackdrop:SetShown(theme=="Frost" or theme=="Ice")
  if theme=="Frost" or theme=="Ice" then entry.resetFrostBloom() end
 end
 if theme=="Frost" or theme=="Ice" then entry.contour:SetTexture(Asset("frost",theme=="Frost" and "Contour_Frost" or "Contour_Ice")) end
 entry.background:SetTexture(theme=="Arcaneum" and Asset("Moon","BG_Moon") or Asset((theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Holy" and "holy" or theme=="Nature" and "nature" or theme=="Arctic" and "arctic" or theme,theme=="Moon" and "BG_Moon" or theme=="Shadow" and "BG_Shadow" or theme=="Earth" and "BG_Earth" or (theme=="Frost" or theme=="Ice") and "BG_Frost" or theme=="Holy" and "BG_Holy" or theme=="Nature" and "BG_Nature" or theme=="Aim" and "BG_Aim" or theme=="Alliance" and "BG_Alliance" or theme=="Arctic" and "BG_Arctic" or theme=="Arcane" and "BG_Arcane" or "BG_Herbalism"))
 if entry.shimmer then
  entry.shimmer:SetTexture(Asset((theme=="Frost" or theme=="Ice") and "frost" or theme=="Earth" and "earth" or theme=="Nature" and "nature" or theme=="Arctic" and "arctic" or theme=="Arcane" and "Moon" or theme,theme=="Moon" and "Fill_Moon" or theme=="Shadow" and "Fill_Shadow" or theme=="Arcaneum" and "Fill_Arcaneum" or theme=="Earth" and "Fill_Earth" or (theme=="Frost" or theme=="Ice") and "Fill_Frost" or theme=="Holy" and "Fill_Holy" or theme=="Nature" and "Fill_Nature" or theme=="Alliance" and "Fill_Alliance" or theme=="Arctic" and "Fill_Arctic" or theme=="Arcane" and "Fill_Moon" or theme=="Aim" and "Fill_Aim_Neuteral_Mob" or "Fill_Herbalism"))
  if theme=="Moon" then
   entry.shimmer:SetBlendMode("ADD")
   entry.shimmer:SetAlpha(0.45)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Arcaneum" then
   entry.shimmer:SetBlendMode("ADD")
   entry.shimmer:SetAlpha(0.65)
   entry.shimmer:SetTexCoord(182/1024,850/1024,201/512,271/512)
  elseif theme=="Shadow" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(0.32)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Frost" or theme=="Ice" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.35)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Holy" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.40)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Arctic" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.45)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Arcane" then
   entry.shimmer:SetBlendMode("ADD")
   entry.shimmer:SetAlpha(.20)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Alliance" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.38)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Aim" then
   entry.aimFill=nil
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(1)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Nature" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.35)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  elseif theme=="Earth" then
   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(.35)
   entry.shimmer:SetTexCoord(129/1024,886/1024,203/512,281/512)
  else
   -- The original Herbalism fill is green artwork. Blend it over a dark\n   -- green native fill instead of adding it over pink/purple solid colours.\n   entry.shimmer:SetBlendMode("BLEND")
   entry.shimmer:SetAlpha(0.20)
   entry.shimmer:SetTexCoord(144/1024,905/1024,175/512,305/512)
  end
 end
 entry.light:ClearAllPoints()
 entry.light:SetAllPoints(entry.frame)
 entry.light:SetTexCoord(0,1,0,1)
 if theme=="Moon" then
  entry.light:SetTexture(Asset("Moon","Frame_Moon_Light"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Arcaneum" then
  entry.light:SetTexture(Asset("Arcaneum","Frame_Arcaneum_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Frost" or theme=="Ice" then
  entry.light:SetTexture(Asset("frost",theme=="Frost" and "Contour_Frost_range" or "Contour_Ice_range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Holy" then
  entry.light:SetTexture(Asset("holy","Light_Holy"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Arctic" then
  entry.light:SetTexture(Asset("arctic","Frame_Arctic_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Arcane" then
  entry.light:SetTexture(Asset("Arcaneum","Frame_Arcaneum_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Alliance" then
  entry.light:SetTexture(Asset("alliance","Frame_Alliance_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Aim" then
  entry.light:SetTexture(Asset("Aim","Frame_Aim_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Nature" then
  entry.light:SetTexture(Asset("nature","Frame_Nature_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Earth" then
  entry.light:SetTexture(Asset("earth","Frame_Earth_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 elseif theme=="Shadow" then
  entry.light:SetTexture(Asset("Arcaneum","Frame_Arcaneum_Range"))
  -- The actual icon occupies only the left quarter of this 1024x512 image.
  -- Crop the transparent canvas and anchor the icon to the left bar endpoint.
  entry.light:ClearAllPoints()
  entry.light:SetPoint("CENTER",entry.bar,"LEFT",0,0)
  entry.light:SetSize(32,32)
  entry.light:SetTexCoord(0,1,0,1)
  entry.light:SetBlendMode("ADD")
  entry.light:SetAlpha(1)
 else
  -- User-supplied standalone range indicator, above all animation frames.
  entry.light:SetTexture(Asset("Herbalism","Frame_Range"))
  entry.light:SetBlendMode("BLEND")
  entry.light:SetAlpha(1)
 end
end

local function HexRGB(hex)
 if type(hex)~="string" or not hex:match("^%x%x%x%x%x%x$") then return 1,1,1 end
 return tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255
end

local function UpdateText(entry,unit)
 local db=MR.db
 local font=FONT_PATHS[db.nameFont] or FONT_PATHS.FRIZQT
 if not entry.nameText:SetFont(font,db.nameSize or 14,"OUTLINE") then entry.nameText:SetFont(FONT_PATHS.FRIZQT,db.nameSize or 14,"OUTLINE") end
 entry.nameText:SetTextColor(HexRGB(db.nameColor))
 entry.nameText:ClearAllPoints()
 entry.nameText:SetPoint("CENTER",entry.frame,"CENTER",db.nameX or 0,db.nameY or 24)
 local name=UnitName(unit)
 if name and Plain(name) then entry.nameText:SetText(name) else entry.nameText:SetText("") end
 if not entry.levelText:SetFont(font,db.levelSize or 11,"OUTLINE") then entry.levelText:SetFont(FONT_PATHS.FRIZQT,db.levelSize or 11,"OUTLINE") end
 entry.levelText:SetTextColor(HexRGB(db.levelColor))
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
  if MR.ArcaneumFX then MR.ArcaneumFX:SetActive(entry,false) end
  if MR.ShadowFX then MR.ShadowFX:SetActive(entry,false) end
  if MR.HerbalismFX then MR.HerbalismFX:SetActive(entry,false) end
  if MR.MoonFX then MR.MoonFX:SetActive(entry,false) end
  if MR.FrostFX then MR.FrostFX:SetActive(entry,nil) end
  if MR.HolyFX then MR.HolyFX:SetActive(entry,false) end
    if MR.NatureFX then MR.NatureFX:SetActive(entry,false) end
  if MR.AimFX then MR.AimFX:SetActive(entry,false) end
  if MR.ArcaneFX then MR.ArcaneFX:SetActive(entry,false) end
   if MR.EarthFX then MR.EarthFX:SetActive(entry,false) end
  if entry.shimmer then entry.shimmer:Hide() end
  if entry.allianceAccents then entry.allianceAccents:Hide() end
  if entry.setArcticBloom then entry.setArcticBloom(false) end
  if entry.arcaneRuneBack then entry.arcaneRuneBack:Hide() end
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
 if entry.arcaneRuneBack then
  if entry.theme=="Arcane" then entry.arcaneRuneBack:Show() else entry.arcaneRuneBack:Hide() end
 end
 RefreshShimmer(entry)
 Resize(entry)
 SetMoonColour(entry, unit)
 PositionCastBar(entry)

 local selected = UnitExists("target") and UnitIsUnit(unit, "target")
 if entry.allianceAccents then
  if entry.theme=="Alliance" and selected==true then entry.allianceAccents:Show()
  else entry.allianceAccents:Hide() end
 end
 if entry.setArcticBloom then entry.setArcticBloom(entry.theme=="Arctic" and selected==true) end
 local inRange = selected and MR:RangeState()
 if MR.ArcaneumFX then MR.ArcaneumFX:SetActive(entry,entry.theme=="Arcaneum" and selected==true) end
 if MR.ShadowFX then MR.ShadowFX:SetActive(entry,entry.theme=="Shadow" and selected==true and inRange==true) end
 if MR.HerbalismFX then MR.HerbalismFX:SetActive(entry,entry.theme=="Herbalism" and selected==true) end
 if MR.MoonFX then MR.MoonFX:SetActive(entry,entry.theme=="Moon" and selected==true) end
 if MR.EarthFX then MR.EarthFX:SetActive(entry,entry.theme=="Earth" and selected==true) end
 if MR.FrostFX then MR.FrostFX:SetActive(entry,selected==true and (entry.theme=="Frost" or entry.theme=="Ice") and entry.theme or nil) end
 if MR.HolyFX then MR.HolyFX:SetActive(entry,entry.theme=="Holy" and selected==true) end
 if MR.NatureFX then MR.NatureFX:SetActive(entry,entry.theme=="Nature" and selected==true) end
 if MR.AimFX then MR.AimFX:SetActive(entry,entry.theme=="Aim" and selected==true) end
 if MR.ArcaneFX then MR.ArcaneFX:SetActive(entry,entry.theme=="Arcane" and selected==true) end
 if entry.theme=="Arcaneum" then
  if entry.filename~="Frame_Arcaneum_Light" then
   entry.filename="Frame_Arcaneum_Light"
   entry.border:SetTexture(Asset("Arcaneum","Frame_Arcaneum_Light"))
  end
 elseif entry.theme=="Shadow" then
  entry.border:SetTexture(Asset("Shadow","Frame_Shadow"))
  local flameName=string.format("Flame_Shadow_%02d",math.floor((GetTime()*8)%5)+1)
  if entry.filename~=flameName then
   entry.filename=flameName
   entry.flame:SetTexture(Asset("Shadow",flameName))
  end
 elseif entry.theme=="Frost" or entry.theme=="Ice" then
  if entry.filename~="Frame_Frost" then
   entry.filename="Frame_Frost"
   entry.border:SetTexture(Asset("frost","Frame_Frost"))
  end
 elseif entry.theme=="Holy" then
  if entry.filename~="Frame_Holy" then
   entry.filename="Frame_Holy"
   entry.border:SetTexture(Asset("holy","Frame_Holy"))
  end
 elseif entry.theme=="Arctic" then
  if entry.filename~="Frame_Arctic" then
   entry.filename="Frame_Arctic"
   entry.border:SetTexture(Asset("arctic","Frame_Arctic"))
  end
 elseif entry.theme=="Arcane" then
  if entry.filename~="Frame_Arcane" then
   entry.filename="Frame_Arcane"
   entry.border:SetTexture(Asset("arcane","Frame_Arcane"))
  end
 elseif entry.theme=="Alliance" then
  if entry.filename~="Frame_Alliance" then
   entry.filename="Frame_Alliance"
   entry.border:SetTexture(Asset("alliance","Frame_Alliance"))
  end
 elseif entry.theme=="Aim" then
  if entry.filename~="Frame_Aim" then
   entry.filename="Frame_Aim"
   entry.border:SetTexture(Asset("Aim","Frame_Aim"))
  end
 elseif entry.theme=="Nature" then
  local frameSequence={1,2,3,2}
  local frameNumber=frameSequence[math.floor(GetTime()*7)%4+1]
  local frameName=string.format("Frame_Nature_%02d",frameNumber)
  if entry.filename~=frameName then
   entry.filename=frameName
   entry.border:SetTexture(Asset("nature",frameName))
  end
 elseif entry.theme=="Earth" then
  if entry.filename~="Frame_Earth" then
   entry.filename="Frame_Earth"
   entry.border:SetTexture(Asset("earth","Frame_Earth"))
  end
 elseif entry.theme=="Herbalism" then
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

-- Diagnostic only: reports nameplate frame structure without modifying Blizzard UI.
function MR:DebugCastBars()
 local unit="target"
 local plate=C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit(unit)
 if not plate then self:Print("Target a visible casting mob with its nameplate showing, then /mr castdebug");return end
 local root=plate.UnitFrame
 if not root then self:Print("No UnitFrame on target nameplate");return end
 local function Describe(obj)
  if not obj then return "nil" end
  local ok,name=pcall(function() return obj:GetName() end)
  local ok2,kind=pcall(function() return obj:GetObjectType() end)
  return tostring(ok2 and kind or "?").." "..tostring(ok and name or "?")
 end
 self:Print("Cast debug: UnitFrame="..Describe(root))
 local found=0
 local function Walk(parent,path,depth)
  if depth>3 or found>=25 then return end
  local ok,children=pcall(function() return {parent:GetChildren()} end)
  if not ok then return end
  for i,child in ipairs(children) do
   local label=path.."/"..i
   local name=child.GetName and child:GetName() or ""
   local lower=tostring(name):lower()
   local isStatus=child.IsObjectType and child:IsObjectType("StatusBar")
   if isStatus or lower:find("cast") or lower:find("spell") then
    found=found+1
    local w,h=child:GetSize()
    if Plain(w) and Plain(h) then
     self:Print(label.." "..Describe(child).." "..math.floor(w).."x"..math.floor(h))
    else self:Print(label.." "..Describe(child).." (protected dimensions)") end
   end
   Walk(child,label,depth+1)
  end
 end
 Walk(root,"UnitFrame",0)
 for _,key in ipairs({"castBar","CastBar","spellCastBar","SpellCastBar","castingBar","CastingBar","healthBar"}) do
  local obj=root[key]
  if obj then self:Print("field "..key.." = "..Describe(obj)) end
 end
 self:Print("Cast debug complete; "..found.." candidate frames.")
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
    if MR.ArcaneumFX then MR.ArcaneumFX:SetActive(e,false) end
    if MR.ShadowFX then MR.ShadowFX:SetActive(e,false) end
    if MR.HerbalismFX then MR.HerbalismFX:SetActive(e,false) end
    if MR.MoonFX then MR.MoonFX:SetActive(e,false) end
    if MR.FrostFX then MR.FrostFX:SetActive(e,nil) end
    if MR.HolyFX then MR.HolyFX:SetActive(e,false) end
    if MR.NatureFX then MR.NatureFX:SetActive(e,false) end
    if MR.AimFX then MR.AimFX:SetActive(e,false) end
    if MR.ArcaneFX then MR.ArcaneFX:SetActive(e,false) end
    if MR.EarthFX then MR.EarthFX:SetActive(e,false) end
    if e.shimmer then e.shimmer:Hide() end
    if e.allianceAccents then e.allianceAccents:Hide() end
    if e.setArcticBloom then e.setArcticBloom(false) end
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
