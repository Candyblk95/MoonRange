-- MoonRange Aim particles adapted from Opulent Casting Bars Particles_Aim.lua.
-- The original two cast fronts are replaced by the remaining-health edge.
local _, MR = ...
local FX = {}
MR.AimFX = FX
local TAU=math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end

local function HealthFraction(entry)
 -- Some WoW clients return protected/secret health values during combat.
 -- Try the real bar fraction first, and never let an unavailable value break FX.
 local ok,v=pcall(function()
  local lo,hi=entry.bar:GetMinMaxValues()
  local value=entry.bar:GetValue()
  if hi>lo then return math.max(0,math.min(1,(value-lo)/(hi-lo))) end
 end)
 if ok and type(v)=="number" then return v end
 local ok2,fraction=pcall(function()
  local texture=entry.bar:GetStatusBarTexture()
  local full=entry.bar:GetWidth()
  if texture and full and full>0 then
   return math.max(0,math.min(1,texture:GetWidth()/full))
  end
 end)
 if ok2 and type(fraction)=="number" then return fraction end
 return nil
end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.frame)
 holder:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 holder:SetScale(entry.particleScale or 1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=holder
 holder:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 holder:EnableMouse(false)
 holder:Hide()
 local sparks,glows,flashes={},{},{}
 -- Original Aim front particles: adapted to erupt near remaining-health edge.
 for i=1,36 do
  local t=holder:CreateTexture(nil,"ARTWORK",nil,1)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD");t:SetVertexColor(1,.34,.10);t:SetAlpha(0)
  sparks[i]={tex=t,active=false}
 end
 -- Original red/orange front glow.
 for i=1,32 do
  local t=holder:CreateTexture(nil,"ARTWORK",nil,2)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD");t:SetVertexColor(1,.18,.05);t:SetAlpha(0)
  glows[i]={tex=t,active=false}
 end
 -- Thunder-style red flashes from the original Aim animation.
 for i=1,4 do
  local t=holder:CreateTexture(nil,"ARTWORK",nil,3)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD");t:SetVertexColor(1,.12,.06);t:SetAlpha(0)
  flashes[i]={tex=t,clock=rand(0,.8),phase=rand(0,TAU)}
 end
 local s={holder=holder,sparks=sparks,glows=glows,flashes=flashes,
  active=false,sparkClock=0,glowClock=0,lastFraction=nil}
 local function spawn(pool,x,glow)
  for _,p in ipairs(pool) do
   if not p.active then
    p.active=true;p.life=0;p.maxLife=glow and rand(.16,.35) or rand(.30,.66)
    p.x=x+rand(-3,3);p.y=rand(-7,7)
    p.vx=glow and rand(-6,6) or rand(-30,30)
    p.vy=glow and rand(-4,4) or rand(16,52)
    p.phase=rand(0,TAU)
    local z=glow and rand(4,9) or rand(3,7)
    p.tex:SetSize(z,z)
    break
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  local fraction=HealthFraction(entry)
  if not fraction then
   -- No reliable health information: hide rather than show misleading FX.
   for _,pool in ipairs({sparks,glows}) do
    for _,p in ipairs(pool) do p.active=false;p.tex:SetAlpha(0) end
   end
   for _,p in ipairs(flashes) do p.tex:SetAlpha(0) end
   return
  end
  local w=entry.lastWidth or entry.bar:GetWidth()
  if not w or w<20 then w=170 end
  local x=(fraction-.5)*w
  -- Smooth tiny changes; jump immediately on major damage/healing.
  s.lastFraction=fraction
  for _,p in ipairs(sparks) do
   if p.active then
    p.life=p.life+dt
    local t=p.life/p.maxLife
    if t>=1 then p.active=false;p.tex:SetAlpha(0)
    else
     p.vy=p.vy-65*dt
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.bar,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.64*math.min(1,(1-t)/.45))
    end
   end
  end
  for _,p in ipairs(glows) do
   if p.active then
    p.life=p.life+dt
    local t=p.life/p.maxLife
    if t>=1 then p.active=false;p.tex:SetAlpha(0)
    else
     p.y=p.y+p.vy*dt+math.sin(p.life*10+p.phase)*.22
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.bar,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.55*math.min(1,t/.2,(1-t)/.2))
    end
   end
  end
  if fraction>0 and fraction<1 then
   s.sparkClock=s.sparkClock+dt
   if s.sparkClock>=.065 then s.sparkClock=s.sparkClock-.065;spawn(sparks,x,false) end
   s.glowClock=s.glowClock+dt
   if s.glowClock>=.045 then s.glowClock=s.glowClock-.045;spawn(glows,x,true) end
  end
  for _,p in ipairs(flashes) do
   p.clock=p.clock+dt
   if p.clock>rand(.65,1.2) then
    p.clock=0;p.x=x+rand(-8,8);p.y=rand(-6,6)
    p.tex:SetSize(rand(6,12),rand(6,12))
   end
   if fraction<=0 or fraction>=1 then p.tex:SetAlpha(0)
   else
    p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.bar,"CENTER",p.x or x,p.y or 0)
    p.tex:SetAlpha(.5*math.max(0,1-p.clock/.24))
   end
  end
 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.aimFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=Make(entry);entry.aimFX=s end
 if s.active then return end
 s.active=true;s.sparkClock=0;s.glowClock=0;s.lastFraction=nil
 for _,pool in ipairs({s.sparks,s.glows}) do
  for _,p in ipairs(pool) do p.active=false;p.tex:SetAlpha(0) end
 end
 for _,p in ipairs(s.flashes) do p.tex:SetAlpha(0) end
 s.holder:Show()
end
