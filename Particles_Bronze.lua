-- Bronze particles adapted from the original supplied Sleek Casting Bars effect.
-- Preserves the 380 sinuous sand grains, wind gusts, 50 tip sparks and 60 glow sparks.
-- Each nameplate owns its own particles; coordinates follow the Bronze frame.
local _,MR=...
local FX={}
MR.BronzeFX=FX
local sin,cos,pi=math.sin,math.cos,math.pi
local function rand(a,b)return a+math.random()*(b-a)end
local COLS={{1,.88,.22},{1,.72,.12},{1,.95,.55},{.95,.78,.18},{1,.62,.10}}
local function rotate(tex,a)
 local c,s=cos(a),sin(a)
 tex:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,.5-.5*c-.5*s,.5-.5*s+.5*c,
                 .5+.5*c+.5*s,.5+.5*s-.5*c,.5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 holder:EnableMouse(false);holder:Hide()
 local sand,tip,glow={},{},{}
 for i=1,380 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetBlendMode("ADD");t:SetAlpha(0)
  sand[i]={tex=t,active=false}
 end
 for i=1,50 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture(MR.path.."frost\\Particle_Frost_0"..((i-1)%2+1)..".tga")
  t:SetBlendMode("ADD");t:SetAlpha(0)
  tip[i]={tex=t,active=false}
 end
 for i=1,60 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture(MR.path.."frost\\Particle_Frost_0"..((i-1)%2+1)..".tga")
  t:SetBlendMode("ADD");t:SetAlpha(0)
  glow[i]={tex=t,active=false}
 end
 local s={holder=holder,sand=sand,tip=tip,glow=glow,clock=0,wind=0,sandAcc=0,tipAcc=0,glowAcc=0}
 local function SpawnSand(left,h)
  for _,g in ipairs(sand) do
   if not g.active then
    local col=COLS[math.random(#COLS)]
    g.active=true;g.x=left-2;g.y0=rand(-h*.18,h*.18)
    g.vx=rand(45,120);g.amp=rand(6,22);g.frq=rand(.3,1.2)
    g.phase=rand(0,pi*2);g.drift=rand(-15,15)
    g.windOff=rand(0,1.8);g.life=0;g.deadX=0
    local a=math.random();g.maxAlpha=a*a*.75+.08
    local size=math.random(2);g.texSize=size;g.tex:SetSize(size,size)
    g.tex:SetVertexColor(col[1],col[2],col[3])
    g.tex:SetAlpha(0)
    return
   end
  end
 end
 local function SpawnTip(front,h)
  for _,p in ipairs(tip) do
   if not p.active then
    local col=COLS[math.random(#COLS)]
    local angle=math.rad(rand(50,130));local speed=rand(35,95)
    p.active=true;p.life=0;p.maxLife=rand(.35,.75)
    p.x=front+rand(-4,4);p.y=rand(-h*.18,h*.18)
    p.vx=cos(angle)*speed;p.vy=sin(angle)*speed
    local z=rand(4,9);p.texSize=z;p.tex:SetSize(z,z)
    p.tex:SetVertexColor(col[1],col[2],col[3]);p.tex:SetAlpha(.85)
    p.rot=rand(0,pi*2);p.spin=rand(-5,5)
    return
   end
  end
 end
 local function SpawnGlow(front,h)
  for _,p in ipairs(glow) do
   if not p.active then
    local col=COLS[math.random(#COLS)]
    p.active=true;p.life=0;p.maxLife=rand(.18,.38)
    p.x=front+rand(-3,3);p.y=rand(-h*.15,h*.15)
    p.vy=rand(-18,18)
    local z=rand(4,10);p.texSize=z;p.tex:SetSize(z,z)
    p.tex:SetVertexColor(col[1],col[2],col[3]);p.tex:SetAlpha(0)
    return
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  s.clock=s.clock+dt;s.wind=(s.wind+dt)%1.8
  local scale=entry.particleScale or 1
  local width=(entry.lastWidth or 150)/scale
  local h=20 -- reference height in original particle design space
  local left,right=-width*.5,width*.5
  local progress=(s.clock%3)/3 -- original tip/glow progression, looped for a persistent target
  for _,g in ipairs(sand) do
   if g.active then
    g.life=g.life+dt
    local phase=((s.wind+g.windOff)%1.8)/1.8
    local gust=phase<.28 and phase/.28 or 1-(phase-.28)/.72
    g.x=g.x+(g.vx+60*gust*.45)*dt
    local y=g.y0+sin(g.life*g.frq+g.phase)*g.amp+g.drift*g.life
    if g.deadX==0 then g.deadX=right+4 end
    local distance=g.deadX-g.x
    if g.x>=g.deadX or g.life>5 then
     g.active=false;g.tex:SetAlpha(0)
    else
     g.tex:SetAlpha(g.maxAlpha*math.min(g.life/.12,1)*math.min(1,math.max(0,distance/22)))
     g.tex:ClearAllPoints();g.tex:SetPoint("CENTER",entry.frame,"CENTER",g.x*scale,y*scale)
     local z=(g.texSize or 1)
     -- Native sizes are retained; scale explicitly rather than scaling the frame twice.
     g.tex:SetSize(z*scale,z*scale)
    end
   end
  end
  s.sandAcc=s.sandAcc+dt
  while s.sandAcc>=.009 do
   s.sandAcc=s.sandAcc-.009
   for i=1,math.random(3,5) do SpawnSand(left,h) end
  end

 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.bronzeFX
 if not enabled then
  if s then s.holder:Hide() end
  return
 end
 if not s then s=Make(entry);entry.bronzeFX=s end
 if not s.holder:IsShown() then
  s.clock=0;s.wind=0;s.sandAcc=0;s.tipAcc=0;s.glowAcc=0
  for _,group in ipairs({s.sand,s.tip,s.glow}) do
   for _,p in ipairs(group) do p.active=false;p.tex:SetAlpha(0) end
  end
  s.holder:Show()
 end
end
