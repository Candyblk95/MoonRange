local _, MR = ...
local FX = {}
MR.HerbalismFX = FX
local TAU=math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end
local function rotate(t,a)
 local c,s=math.cos(a),math.sin(a)
 t:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,.5-.5*c-.5*s,.5-.5*s+.5*c,.5+.5*c+.5*s,.5+.5*s-.5*c,.5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function make(entry)
 local f=CreateFrame("Frame",nil,entry.foreground)
 f:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 f:SetScale(1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=f
 f:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 f:EnableMouse(false)
 f:Hide()
 local leaves,glows={},{}
 for i=1,35 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,1)
  t:SetTexture(MR.path.."nature\\"..string.format("Leaf_%02d",(i-1)%5+1)..".tga")
  t:SetBlendMode("BLEND")
  t:SetAlpha(0)
  leaves[i]={tex=t,active=false}
 end
 for i=1,40 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,2)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(.3,1,.25)
  t:SetAlpha(0)
  glows[i]={tex=t,life=0}
 end
 local s={holder=f,leaves=leaves,glows=glows,active=false,leafClock=0,glowClock=0}
 f:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  local w=entry.lastWidth or 190
  local left=-w*.5
  local right=w*.5
  -- Leaves orbit the bar in shallow elliptical spirals instead of crossing its fill.
  for _,l in ipairs(leaves) do
   if l.active then
    l.life=l.life+dt
    l.theta=l.theta+l.speed*dt
    l.angle=l.angle+l.rotSpeed*dt
    local x=math.cos(l.theta)*l.rx
    local y=math.sin(l.theta)*l.ry + math.sin(l.life*2+l.phase)*2
    l.tex:ClearAllPoints()
    l.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
    rotate(l.tex,l.angle)
    l.tex:SetAlpha(l.alpha*(.75+.25*math.sin(l.theta)^2))
   end
  end
  s.leafClock=s.leafClock+dt
  if s.leafClock>=.20 then
   s.leafClock=0
   for _,l in ipairs(leaves) do
    if not l.active then
     l.active=true;l.life=0
     l.theta=rand(0,TAU);l.speed=rand(.45,1.1)*(math.random(2)==1 and 1 or -1)
     l.rx=rand(w*.35,w*.54);l.ry=rand(12,22)
     l.phase=rand(0,TAU);l.angle=rand(0,TAU)
     l.rotSpeed=rand(.8,2.8)*(math.random(2)==1 and 1 or -1)
     l.size=rand(6,12);l.alpha=rand(.40,.78)
     l.tex:SetSize(l.size,l.size)
     break
    end
   end
  end
  for _,p in ipairs(glows) do
   if p.life>0 then
    p.life=p.life-dt
    if p.life<=0 then p.tex:SetAlpha(0)
    else
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.55*math.min(1,p.life/.12))
    end
   end
  end
  s.glowClock=s.glowClock+dt
  if s.glowClock>=.04 then
   s.glowClock=0
   for _,p in ipairs(glows) do
    if p.life<=0 then
     p.life=rand(.18,.35);p.x=rand(left,right);p.y=(math.random(2)==1 and 1 or -1)*rand(10,19)
     p.vx=rand(-9,9);p.vy=rand(-8,8)
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
 local s=entry.herbalismFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=make(entry);entry.herbalismFX=s end
 if s.active then return end
 s.active=true;s.leafClock=0;s.glowClock=0
 for _,l in ipairs(s.leaves) do l.active=false;l.tex:SetAlpha(0) end
 for _,p in ipairs(s.glows) do p.life=0;p.tex:SetAlpha(0) end
 s.holder:Show()
end
