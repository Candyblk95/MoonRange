-- Frost effects ported from the user's original Sleek Casting Bars Particles_Frost.lua.
-- Adapted for a compact mist layer behind the bar and orbiting snowflakes.
local _, MR = ...
local FX = {}
MR.FrostFX = FX
local TEX = MR.path .. "frost\\"
local function rand(a,b) return a+math.random()*(b-a) end
local function rad(deg) return deg*math.pi/180 end
local function lerp(a,b,t) return a+(b-a)*math.max(0,math.min(t,1)) end

-- Original constants, unchanged.
local MIST_W_BASE, MIST_H_BASE = 170,72
local MIST_ALPHA_MAX = .30
local MIST_FADE_IN, MIST_FADE_OUT = 1.8,1.5
local MIST_HOLD_MIN, MIST_HOLD_MAX = 1.2,2.5
local MIST_ROT_SPEED = .04
local PART_COUNT, PART_SIZE_BASE = 40,6
local PART_SPREAD, PART_GRAVITY, PART_SPAWN_RATE = 70,30,.06

local function Rotate(tex,angle)
 local c,s=math.cos(angle),math.sin(angle)
 tex:SetTexCoord(
  .5+(-.5)*c-(-.5)*s,.5+(-.5)*s+(-.5)*c,
  .5+(-.5)*c-( .5)*s,.5+(-.5)*s+( .5)*c,
  .5+( .5)*c-(-.5)*s,.5+( .5)*s+(-.5)*c,
  .5+( .5)*c-( .5)*s,.5+( .5)*s+( .5)*c)
end

local function SpawnMist(m)
 local scale=rand(.85,1.10)
 m.baseW,m.baseH=MIST_W_BASE*scale,MIST_H_BASE*scale
 m.tex:SetSize(m.baseW,m.baseH)
 m.tex:SetAlpha(0)
 m.phase="fadein";m.timer=0;m.duration=MIST_FADE_IN
 m.alpha=0;m.scaleT=0
 m.scaleDir=math.random(2)==1 and 1 or -1
end

local function UpdateMist(m,dt,entry)
 if m.delay>0 then m.delay=m.delay-dt;return end
 if m.phase=="idle" then SpawnMist(m);return end
 -- Keep the mist compact, behind the frame and slightly below its centre.
 local w=entry.lastWidth or entry.bar:GetWidth()
 if not w or w<=0 then w=150 end
 m.tex:ClearAllPoints()
 m.tex:SetPoint("CENTER",entry.frame,"CENTER",(m.xFrac-.5)*w,-12)
 m.timer=m.timer+dt;m.scaleT=m.scaleT+dt
 m.angle=m.angle+MIST_ROT_SPEED*m.rotDir*dt
 local pulse=1+math.sin(m.scaleT*.45*m.scaleDir)*.09
 m.tex:SetSize(m.baseW*pulse,m.baseH*pulse)
 Rotate(m.tex,m.angle)
 if m.phase=="fadein" then
  m.alpha=math.min(m.timer/m.duration,1)*MIST_ALPHA_MAX
  m.tex:SetAlpha(math.max(0,m.alpha+math.sin(m.scaleT*1.8)*.035))
  if m.timer>=m.duration then
   m.phase="hold";m.timer=0;m.duration=rand(MIST_HOLD_MIN,MIST_HOLD_MAX)
  end
 elseif m.phase=="hold" then
  m.tex:SetAlpha(math.max(0,MIST_ALPHA_MAX+math.sin(m.scaleT*1.8)*.06))
  if m.timer>=m.duration then
   m.phase="fadeout";m.timer=0;m.duration=MIST_FADE_OUT
  end
 elseif m.phase=="fadeout" then
  m.alpha=(1-m.timer/m.duration)*MIST_ALPHA_MAX
  m.tex:SetAlpha(math.max(0,m.alpha))
  if m.timer>=m.duration then m.tex:SetAlpha(0);m.phase="idle" end
 end
end

local TAU=math.pi*2
local function SpawnParticle(state)
 for _,p in ipairs(state.parts) do
  if not p.active then
   p.active=true;p.life=0;p.maxLife=rand(1.8,3.3)
   p.angle=rand(0,TAU)
   p.speed=rand(.7,1.5)*(math.random(2)==1 and 1 or -1)
   p.rx=rand(.40,.62)
   p.ry=rand(19,35)
   p.phase=rand(0,TAU)
   local size=rand(5,8)
   p.tex:SetSize(size,size);p.tex:SetAlpha(0)
   return
  end
 end
end

local function UpdateParticle(p,dt,entry)
 if not p.active then return end
 p.life=p.life+dt
 local t=p.life/p.maxLife
 if t>=1 then p.active=false;p.tex:SetAlpha(0);return end
 p.angle=p.angle+p.speed*dt
 local w=entry.lastWidth or 150
 local x=math.cos(p.angle)*w*p.rx
 local y=math.sin(p.angle)*p.ry+math.sin(p.angle*2+p.phase)*5
 p.tex:ClearAllPoints()
 p.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
 local fade=math.min(1,t/.22,(1-t)/.28)
 p.tex:SetAlpha(math.max(0,fade)*.67)
end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.frame)
 holder:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 holder:SetScale(1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=holder
 holder:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 holder:EnableMouse(false);holder:Hide()
 local state={holder=holder,entry=entry,mists={},parts={},spawn=0}
 for i=1,PART_COUNT do
  local tex=holder:CreateTexture(nil,"OVERLAY",nil,2)
  tex:SetTexture(TEX..((i%2)==0 and "Particle_Frost_01.tga" or "Particle_Frost_02.tga"))
  tex:SetBlendMode("ADD");tex:SetAlpha(0)
  state.parts[i]={tex=tex,active=false,life=0}
 end
 -- Three staggered mist textures, now below the frame in draw order.
 for i,xFrac in ipairs({2/8,4/8,6/8}) do
  local tex=holder:CreateTexture(nil,"BACKGROUND",nil,-1)
  tex:SetTexture(TEX.."Mist_Frost_01.tga")
  tex:SetSize(MIST_W_BASE,MIST_H_BASE)
  tex:SetAlpha(0);tex:SetBlendMode("ADD")
  state.mists[i]={tex=tex,xFrac=xFrac,phase="idle",timer=0,duration=0,
   alpha=0,scaleT=0,scaleDir=1,angle=0,rotDir=i%2==0 and 1 or -1,
   baseW=MIST_W_BASE,baseH=MIST_H_BASE,delay=(i-1)*.8}
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  for _,m in ipairs(state.mists) do UpdateMist(m,dt,entry) end
  for _,p in ipairs(state.parts) do UpdateParticle(p,dt,entry) end
  state.spawn=state.spawn+dt
  if state.spawn>=PART_SPAWN_RATE then
   state.spawn=0
   for i=1,math.random(1,2) do SpawnParticle(state) end
  end
 end)
 return state
end

function FX:SetActive(entry,theme)
 if not entry.frostFX then
  if not theme then return end
  entry.frostFX=Make(entry)
 end
 local state=entry.frostFX
 if theme then
  if not state.holder:IsShown() then
   state.spawn=0
   for i,m in ipairs(state.mists) do
    m.phase="idle";m.delay=(i-1)*.8;m.tex:SetAlpha(0);m.angle=0
   end
   for _,p in ipairs(state.parts) do p.active=false;p.tex:SetAlpha(0) end
   state.holder:Show()
  end
 elseif state.holder:IsShown() then
  state.holder:Hide()
  for _,m in ipairs(state.mists) do m.tex:SetAlpha(0) end
  for _,p in ipairs(state.parts) do p.active=false;p.tex:SetAlpha(0) end
 end
end
