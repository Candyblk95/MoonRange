-- Frost effects ported from the user's original Sleek Casting Bars Particles_Frost.lua.
-- The only structural changes are per-nameplate state and a stationary health-bar
-- emission point instead of the original moving cast-progress front.
local _, MR = ...
local FX = {}
MR.FrostFX = FX
local TEX = MR.path .. "frost\\"
local function rand(a,b) return a+math.random()*(b-a) end
local function rad(deg) return deg*math.pi/180 end
local function lerp(a,b,t) return a+(b-a)*math.max(0,math.min(t,1)) end

-- Original constants, unchanged.
local MIST_W_BASE, MIST_H_BASE = 338,169
local MIST_ALPHA_MAX = .50
local MIST_FADE_IN, MIST_FADE_OUT = 1.8,1.5
local MIST_HOLD_MIN, MIST_HOLD_MAX = 1.2,2.5
local MIST_ROT_SPEED = .04
local PART_COUNT, PART_SIZE_BASE = 40,10
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
 local scale=rand(.75,1.30)
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
 -- Original three positions at 2/8, 4/8, 6/8 across the bar.
 -- Crucially, mist is CENTERED vertically on the bar, so the large texture
 -- extends above AND below it. Do not offset into upper/lower cloud bands.
 local w=entry.lastWidth or entry.bar:GetWidth()
 if not w or w<=0 then w=150 end
 m.tex:ClearAllPoints()
 m.tex:SetPoint("CENTER",entry.frame,"CENTER",(m.xFrac-.5)*w,0)
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

local function SpawnParticle(state)
 local speedMin=lerp(90,40,1)
 local speedMax=lerp(180,110,1)
 local lifeMin=lerp(.25,.6,1)
 local lifeMax=lerp(.55,1.4,1)
 for _,p in ipairs(state.parts) do
  if not p.active then
   local angle=rad(90+rand(-PART_SPREAD,PART_SPREAD))
   local speed=rand(speedMin,speedMax)
   local size=PART_SIZE_BASE+rand(-3,5)
   p.active=true;p.life=0;p.maxLife=rand(lifeMin,lifeMax)
   -- The cast front is unavailable on a health bar: distribute its original
   -- upward spray along the fill instead of concentrating it at one endpoint.
   local w=state.entry.lastWidth or 150
   p.x=rand(-w*.40,w*.40)+rand(-4,4)
   p.y=rand(-6,6)
   p.vx=math.cos(angle)*speed;p.vy=math.sin(angle)*speed
   p.tex:SetSize(size,size);p.tex:SetAlpha(1)
   return
  end
 end
end

local function UpdateParticle(p,dt,entry)
 if not p.active then return end
 p.life=p.life+dt
 local t=p.life/p.maxLife
 if t>=1 then p.active=false;p.tex:SetAlpha(0);return end
 p.vy=p.vy-PART_GRAVITY*dt
 p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
 p.tex:ClearAllPoints()
 p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
 local alpha=t<.4 and 1 or (1-(t-.4)/.6)
 p.tex:SetAlpha(math.max(0,alpha)*.63)
end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 holder:EnableMouse(false);holder:Hide()
 local state={holder=holder,entry=entry,mists={},parts={},spawn=0}
 for i=1,PART_COUNT do
  local tex=holder:CreateTexture(nil,"OVERLAY",nil,2)
  tex:SetTexture(TEX..((i%2)==0 and "Particle_Frost_01.tga" or "Particle_Frost_02.tga"))
  tex:SetBlendMode("ADD");tex:SetAlpha(0)
  state.parts[i]={tex=tex,active=false,life=0}
 end
 -- The original file defines MIST_COUNT=6 but actually creates THREE
 -- clouds using MIST_POSITIONS={2/8,4/8,6/8}. Preserve the real behavior.
 for i,xFrac in ipairs({2/8,4/8,6/8}) do
  local tex=holder:CreateTexture(nil,"ARTWORK",nil,0)
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
