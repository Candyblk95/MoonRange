local _, MR = ...
local FX = {}
MR.ShadowFX = FX
local TAU = math.pi * 2
local function rand(a,b) return a + math.random()*(b-a) end
local function rotate(tex,a)
 local c,s=math.cos(a),math.sin(a)
 tex:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,
                 .5-.5*c-.5*s,.5-.5*s+.5*c,
                 .5+.5*c+.5*s,.5+.5*s-.5*c,
                 .5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function make(entry)
 local f=CreateFrame("Frame",nil,entry.foreground)
 f:SetAllPoints(entry.frame)
 f:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 f:EnableMouse(false)
 f:Hide()
 local circles,orbs,ashes,flames={},{},{},{}
 for i=1,2 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,1)
  t:SetTexture(MR.path.."shadow\\Circle_Shadow.tga")
  t:SetBlendMode("BLEND")
  t:SetSize(28,28)
  circles[i]={tex=t,angle=rand(0,TAU),pulse=rand(0,TAU)}
 end
 for i=1,40 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,2)
  t:SetTexture(MR.path.."earth\\"..string.format("Misc_Earth_%02d",(i-1)%11+1)..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(.35,.15,.45)
  t:SetAlpha(0)
  orbs[i]={tex=t,life=0,angle=0,r=0,side=i<=20 and 1 or 2}
 end
 for i=1,60 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,3)
  t:SetTexture(MR.path.."earth\\"..string.format("Misc_Earth_%02d",(i-1)%11+1)..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(.35,.15,.45)
  t:SetAlpha(0)
  ashes[i]={tex=t,life=0,maxLife=1,x=0,y=0,vx=0,vy=0}
 end
 for i=1,5 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,0)
  t:SetTexture(MR.path.."Shadow\\"..string.format("Flame_Shadow_%02d",i)..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(.35,.15,.45)
  t:SetSize(160,45)
  t:SetPoint("CENTER",entry.frame,"CENTER")
  t:SetAlpha(0)
  flames[i]=t
 end
 local s={holder=f,circles=circles,orbs=orbs,ashes=ashes,flames=flames,time=0,orbClock=0,ashClock=0,active=false}
 f:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  s.time=s.time+dt
  local width=entry.lastWidth or 185
  local xoff=width*.5 + 2
  local centers={-xoff,xoff}
  for i,c in ipairs(circles) do
   c.angle=c.angle-1.6*dt
   c.pulse=c.pulse+2*dt
   local size=29*(1+math.sin(c.pulse)*.07)
   c.tex:SetSize(size,size)
   c.tex:ClearAllPoints()
   c.tex:SetPoint("CENTER",entry.frame,"CENTER",centers[i],7)
   rotate(c.tex,c.angle)
   c.tex:SetAlpha(.9)
  end
  local cycle=s.time/.65
  for i,t in ipairs(flames) do
   local phase=(cycle+(i-1)/5)%1
   local envelope=math.min(1,phase/.2,(1-phase)/.2)
   t:SetAlpha(math.max(0,envelope)*.18)
  end
  for _,o in ipairs(orbs) do
   if o.life>0 then
    o.life=o.life-dt
    o.r=o.r-20*dt
    o.angle=o.angle+2.6*dt*(22/math.max(o.r,4))
    if o.life<=0 or o.r<=2 then o.life=0;o.tex:SetAlpha(0)
    else
     o.tex:ClearAllPoints()
     o.tex:SetPoint("CENTER",entry.frame,"CENTER",centers[o.side]+math.cos(o.angle)*o.r,7+math.sin(o.angle)*o.r)
     o.tex:SetAlpha(.7*math.min(1,o.r/15))
    end
   end
  end
  s.orbClock=s.orbClock+dt
  if s.orbClock>=.09 then
   s.orbClock=0
   for side=1,2 do
    for _,o in ipairs(orbs) do
     if o.side==side and o.life<=0 then
      o.angle=rand(0,TAU);o.r=rand(22,48);o.life=o.r/20
      local size=rand(4,9);o.tex:SetSize(size,size)
      break
     end
    end
   end
  end
  for _,a in ipairs(ashes) do
   if a.life>0 then
    a.life=a.life-dt
    if a.life<=0 then a.tex:SetAlpha(0)
    else
     a.x=a.x+a.vx*dt;a.y=a.y+a.vy*dt
     a.tex:ClearAllPoints()
     a.tex:SetPoint("CENTER",entry.frame,"CENTER",a.x,a.y)
     a.tex:SetAlpha(.65*math.min(1,a.life/.5))
    end
   end
  end
  s.ashClock=s.ashClock+dt
  if s.ashClock>=.05 then
   s.ashClock=0
   for _,a in ipairs(ashes) do
    if a.life<=0 then
     a.life=rand(.8,2.2)
     a.x=rand(-width*.45,width*.45);a.y=rand(-9,9)
     a.vx=rand(-18,18);a.vy=rand(12,35)
     local size=rand(3,8);a.tex:SetSize(size,size)
     break
    end
   end
  end
 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.shadowFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=make(entry);entry.shadowFX=s end
 if s.active then return end
 s.active=true;s.time=0;s.orbClock=0;s.ashClock=0
 for _,o in ipairs(s.orbs) do o.life=0;o.tex:SetAlpha(0) end
 for _,a in ipairs(s.ashes) do a.life=0;a.tex:SetAlpha(0) end
 s.holder:Show()
end
