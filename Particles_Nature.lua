-- MoonRange Nature particles, adapted from the original Nature leaf flow.
-- Frost particle sparkles are tinted mushroom amber. No mist.
local _, MR = ...
local FX = {}
MR.NatureFX = FX
local TAU = math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end
local function rotate(t,a)
 local c,s=math.cos(a),math.sin(a)
 t:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,.5-.5*c-.5*s,.5-.5*s+.5*c,.5+.5*c+.5*s,.5+.5*s-.5*c,.5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function Make(entry)
 local f=CreateFrame("Frame",nil,entry.frame)
 f:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 f:SetScale(entry.particleScale or 1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=f
 f:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 f:EnableMouse(false);f:Hide()
 local leaves,bursts,stars={},{},{}
 for i=1,35 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,1)
  t:SetTexture(MR.path.."nature\\Leaf_0"..((i-1)%5+1)..".tga")
  t:SetBlendMode("BLEND");t:SetAlpha(0)
  leaves[i]={tex=t,active=false}
 end
 for i=1,25 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,2)
  t:SetTexture(MR.path.."nature\\Leaf_0"..((i-1)%5+1)..".tga")
  t:SetBlendMode("BLEND");t:SetAlpha(0)
  bursts[i]={tex=t,active=false}
 end
 for i=1,42 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,3)
  t:SetTexture(MR.path.."frost\\Particle_Frost_0"..((i-1)%2+1)..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(1,.57,.20)
  t:SetAlpha(0)
  stars[i]={tex=t,active=false}
 end
 local s={holder=f,leaves=leaves,bursts=bursts,stars=stars,active=false,leafClock=0,burstClock=0,starClock=0}
 f:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  local w=entry.lastWidth or 170
  if w<20 then w=170 end
  for _,p in ipairs(leaves) do
   if p.active then
    p.life=p.life+dt
    p.x=p.x+p.vx*dt
    local y=p.baseY+math.sin(p.life*p.freq+p.phase)*p.amp+p.vy*p.life
    p.angle=p.angle+p.rotSpeed*dt
    if p.x>w*.62 then p.active=false;p.tex:SetAlpha(0)
    else
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,y)
     rotate(p.tex,p.angle)
     p.tex:SetAlpha(p.alpha*math.min(1,p.life/.4)*math.min(1,(w*.62-p.x)/22))
    end
   end
  end
  s.leafClock=s.leafClock+dt
  if s.leafClock>=.15 then
   s.leafClock=s.leafClock-.15
   for _,p in ipairs(leaves) do
    if not p.active then
     p.active=true;p.life=0;p.x=-w*.62
     p.baseY=(math.random(2)==1 and 1 or -1)*rand(12,24)
     p.vx=rand(40,75);p.vy=rand(-3,3);p.freq=rand(1.2,2.8);p.amp=rand(3,7)
     p.phase=rand(0,TAU);p.angle=rand(0,TAU);p.rotSpeed=rand(-2.8,2.8)
     p.alpha=rand(.45,.72)
     local size=rand(6,11);p.tex:SetSize(size,size)
     break
    end
   end
  end
  -- Occasional small outward leaf bursts, from original Nature front-leaf motion.
  for _,p in ipairs(bursts) do
   if p.active then
    p.life=p.life+dt
    if p.life>=p.duration then p.active=false;p.tex:SetAlpha(0)
    else
     p.vy=p.vy-55*dt;p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.angle=p.angle+p.spin*dt
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     rotate(p.tex,p.angle);p.tex:SetAlpha(.58*(1-p.life/p.duration))
    end
   end
  end
  s.burstClock=s.burstClock+dt
  if s.burstClock>=.32 then
   s.burstClock=s.burstClock-.32
   for _,p in ipairs(bursts) do
    if not p.active then
     p.active=true;p.life=0;p.duration=rand(.4,.75)
     p.x=(math.random(2)==1 and 1 or -1)*rand(w*.30,w*.48)
     p.y=rand(-7,7);p.vx=rand(-28,28);p.vy=rand(16,40)
     p.angle=rand(0,TAU);p.spin=rand(-3,3)
     local size=rand(5,9);p.tex:SetSize(size,size)
     break
    end
   end
  end
  -- Frost star particles: tiny mushroom-amber glints, not Frost mist.
  for _,p in ipairs(stars) do
   if p.active then
    p.life=p.life+dt
    local t=p.life/p.duration
    if t>=1 then p.active=false;p.tex:SetAlpha(0)
    else
     p.theta=p.theta+p.speed*dt
     local x=math.cos(p.theta)*p.rx
     local y=math.sin(p.theta)*p.ry
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
     p.tex:SetAlpha(p.alpha*math.max(0,math.min(1,t/.22,(1-t)/.28)))
    end
   end
  end
  s.starClock=s.starClock+dt
  if s.starClock>=.075 then
   s.starClock=s.starClock-.075
   for _,p in ipairs(stars) do
    if not p.active then
     p.active=true;p.life=0;p.duration=rand(.8,1.7)
     p.theta=rand(0,TAU);p.speed=rand(.5,1.2)*(math.random(2)==1 and 1 or -1)
     p.rx=rand(w*.36,w*.60);p.ry=rand(14,29)
     p.alpha=rand(.40,.72)
     local size=rand(3,6);p.tex:SetSize(size,size)
     break
    end
   end
  end
 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.natureFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=Make(entry);entry.natureFX=s end
 if s.active then return end
 s.active=true;s.leafClock=0;s.burstClock=0;s.starClock=0
 for _,group in ipairs({s.leaves,s.bursts,s.stars}) do
  for _,p in ipairs(group) do p.active=false;p.tex:SetAlpha(0) end
 end
 s.holder:Show()
end
