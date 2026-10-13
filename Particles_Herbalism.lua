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
  for _,l in ipairs(leaves) do
   if l.active then
    l.life=l.life+dt
    l.x=l.x+l.speed*dt
    l.angle=l.angle+l.rotSpeed*dt
    local y=l.y+math.sin(l.life*l.freq+l.phase)*l.amp+l.vy*l.life
    if l.x>right+l.size*2 then l.active=false;l.tex:SetAlpha(0)
    else
     l.tex:ClearAllPoints()
     l.tex:SetPoint("CENTER",entry.frame,"CENTER",l.x,y)
     rotate(l.tex,l.angle)
     local fade=math.min(1,l.life/.5,math.max(0,(right+l.size*2-l.x)/40))
     l.tex:SetAlpha(l.alpha*fade)
    end
   end
  end
  s.leafClock=s.leafClock+dt
  if s.leafClock>=.12 then
   s.leafClock=0
   for _,l in ipairs(leaves) do
    if not l.active then
     l.active=true;l.life=0;l.x=left-22
     l.y=rand(-5,5);l.speed=rand(55,120);l.size=rand(10,22)
     l.amp=rand(3,9);l.freq=rand(1.2,2.8);l.phase=rand(0,TAU)
     l.vy=rand(-4,4);l.angle=rand(0,TAU)
     l.rotSpeed=rand(.8,2.8)*(math.random(2)==1 and 1 or -1)
     l.alpha=rand(.55,.9);l.tex:SetSize(l.size,l.size)
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
     p.life=rand(.18,.35);p.x=rand(left,right);p.y=rand(-6,6)
     p.vx=rand(-9,9);p.vy=rand(-8,8)
     local size=rand(6,12);p.tex:SetSize(size,size)
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
