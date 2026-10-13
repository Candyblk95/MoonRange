-- MoonRange Holy particles, adapted from Sleek Casting Bars Particles_Holy.lua.
-- Light_Holy remains the existing independent range indicator.
-- Draw the effects below the nameplate artwork, like the Frost/Ice FX.
local _, MR = ...
local FX = {}
MR.HolyFX = FX

local TAU = math.pi * 2
local function rand(a,b) return a + math.random()*(b-a) end
local function clamp(v) return math.max(0,math.min(1,v)) end
local function envelope(t,fadeIn,fadeOut)
 if t<fadeIn then return t/fadeIn end
 if t>fadeOut then return (1-t)/(1-fadeOut) end
 return 1
end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.frame)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 holder:EnableMouse(false)
 holder:Hide()

 local state={holder=holder,entry=entry,groups={},acc={0,0,0,0}}
 local definitions={
  -- original front fragments, spread along the nameplate instead of a cast front
  {count=36,rate=.08,per=2,minSize=4,maxSize=15,minLife=.4,maxLife=.9,alpha=.78,kind="front"},
  -- original ambient fragments
  {count=55,rate=.12,per=3,minSize=3,maxSize=13,minLife=.6,maxLife=1.4,alpha=.56,kind="ambient"},
  -- original fine golden glow particles
  {count=45,rate=.035,per=2,minSize=5,maxSize=9,minLife=.35,maxLife=.7,alpha=.78,kind="glow"},
  -- additional Holy stars: subtle, slow twinkling near the frame
  {count=16,rate=.24,per=1,minSize=9,maxSize=15,minLife=1.0,maxLife=1.9,alpha=.62,kind="star"},
 }
 for gi,d in ipairs(definitions) do
  local group={def=d,parts={}}
  for i=1,d.count do
   local tex=holder:CreateTexture(nil,"ARTWORK",nil,gi)
   if d.kind=="front" or d.kind=="ambient" then
    tex:SetTexture(MR.path.."holy\\Misc_Holy_0"..((i%2)+1)..".tga")
   elseif d.kind=="star" then
    tex:SetTexture(MR.path.."holy\\Stars_Holy.tga")
   else
    tex:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
    tex:SetVertexColor(1,.92,.45)
   end
   tex:SetBlendMode("ADD")
   tex:SetAlpha(0)
   group.parts[i]={tex=tex,active=false}
  end
  state.groups[gi]=group
 end

 local function Spawn(group)
  local d=group.def
  for _,p in ipairs(group.parts) do
   if not p.active then
    p.active=true;p.life=0;p.maxLife=rand(d.minLife,d.maxLife)
    local w=entry.lastWidth or 170
    if w<20 then w=170 end
    if d.kind=="front" then
     -- Original casting-front fragments, now distributed across the bar.
     p.x=rand(-w*.62,w*.62);p.y=rand(-21,21)
     p.vx=rand(-10,10);p.vy=rand(-18,4)
    elseif d.kind=="ambient" then
     -- Three-random-average distribution from the original effect.
     local function gauss(r) return (rand(-r,r)+rand(-r,r)+rand(-r,r))/3 end
     p.x=gauss(w*.75+12);p.y=gauss(40)
     p.vx=rand(-6,6);p.vy=rand(-4,8)
    elseif d.kind=="glow" then
     p.x=rand(-w*.64,w*.64);p.y=rand(-27,27)
     p.vx=rand(-5,5);p.vy=rand(-8,8)
    else
     p.x=rand(-w*.68,w*.68)
     p.y=(math.random(2)==1 and -1 or 1)*rand(18,42)
     p.vx=rand(-5,5);p.vy=rand(-3,5)
    end
    p.phase=rand(0,TAU)
    p.tex:SetSize(rand(d.minSize,d.maxSize),rand(d.minSize,d.maxSize))
    p.tex:SetAlpha(0)
    return
   end
  end
 end

 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  for gi,group in ipairs(state.groups) do
   local d=group.def
   for _,p in ipairs(group.parts) do
    if p.active then
     p.life=p.life+dt
     local t=p.life/p.maxLife
     if t>=1 then
      p.active=false;p.tex:SetAlpha(0)
     else
      if d.kind=="front" then
       p.vy=p.vy-8*dt
       p.x=p.x+p.vx*dt+math.sin(p.life*4+p.phase)*.4
       p.y=p.y+p.vy*dt
      elseif d.kind=="ambient" then
       p.x=p.x+p.vx*dt+math.sin(p.life*2+p.phase)*.3
       p.y=p.y+p.vy*dt
      elseif d.kind=="glow" then
       p.vy=p.vy*.88
       p.x=p.x+p.vx*dt
       p.y=p.y+p.vy*dt+math.sin(p.life*10+p.phase)*.4
      else
       p.x=p.x+p.vx*dt+math.sin(p.life*2+p.phase)*.3
       p.y=p.y+p.vy*dt
      end
      p.tex:ClearAllPoints()
      p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
      local fadeIn,fadeOut=.2,.75
      if d.kind=="ambient" then fadeIn,fadeOut=.25,.65
      elseif d.kind=="star" then fadeIn,fadeOut=.35,.60 end
      p.tex:SetAlpha(clamp(envelope(t,fadeIn,fadeOut))*d.alpha)
     end
    end
   end
   state.acc[gi]=state.acc[gi]+dt
   if state.acc[gi]>=d.rate then
    state.acc[gi]=state.acc[gi]-d.rate
    for i=1,d.per do Spawn(group) end
   end
  end
 end)
 return state
end

function FX:SetActive(entry,enabled)
 if not entry.holyFX then
  if not enabled then return end
  entry.holyFX=Make(entry)
 end
 local state=entry.holyFX
 if enabled then
  if not state.holder:IsShown() then
   for i=1,#state.acc do state.acc[i]=0 end
   state.holder:Show()
  end
 elseif state.holder:IsShown() then
  state.holder:Hide()
  for _,group in ipairs(state.groups) do
   for _,p in ipairs(group.parts) do
    p.active=false;p.tex:SetAlpha(0)
   end
  end
 end
end
