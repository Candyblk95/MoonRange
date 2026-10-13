-- Bronze: shimmering sand orbiting the glass ends, with grains falling below the frame.
local _,MR=...
local FX={}
MR.BronzeFX=FX
local TAU=math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end
local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 holder:EnableMouse(false)
 holder:Hide()
 local orbit={}
 for i=1,30 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetBlendMode("ADD")
  t:SetVertexColor(rand(.83,1),rand(.55,.85),rand(.20,.47))
  orbit[i]={tex=t,side=i%2==0 and 1 or -1,angle=rand(0,TAU),
   speed=rand(.65,1.5)*(i%3==0 and -1 or 1),rx=rand(9,20),ry=rand(8,19),
   size=rand(1.1,2.7),alpha=rand(.40,.86),phase=rand(0,TAU)}
 end
 local falling={}
 for i=1,42 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetBlendMode("ADD")
  t:SetVertexColor(rand(.86,1),rand(.58,.85),rand(.23,.48))
  t:SetAlpha(0)
  falling[i]={tex=t,active=false}
 end
 local s={holder=holder,orbit=orbit,falling=falling,clock=0,spawn=0}
 local function Emit()
  for _,p in ipairs(falling) do
   if not p.active then
    p.active=true;p.life=0;p.duration=rand(.65,1.65)
    p.side=math.random(2)==1 and -1 or 1
    p.x=rand(-12,12);p.y=rand(-6,4)
    p.vx=rand(-14,14);p.vy=rand(-13,-29)
    p.size=rand(.9,2.6);p.alpha=rand(.45,.9)
    return
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  s.clock=s.clock+dt
  local scale=entry.particleScale or 1
  -- Keep each swirl centered on the actual health-bar ends as the bar resizes.
  local half=(entry.lastWidth or 150)*.53
  for _,o in ipairs(orbit) do
   o.angle=o.angle+o.speed*dt
   local x=o.side*half+math.cos(o.angle)*o.rx*scale
   local y=math.sin(o.angle)*o.ry*scale
   o.tex:ClearAllPoints()
   o.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
   local z=o.size*scale
   o.tex:SetSize(z,z)
   o.tex:SetAlpha(o.alpha*(.68+.32*math.sin(s.clock*4+o.phase)^2))
  end
  s.spawn=s.spawn+dt
  while s.spawn>=.055 do s.spawn=s.spawn-.055;Emit() end
  for _,p in ipairs(falling) do
   if p.active then
    p.life=p.life+dt
    if p.life>=p.duration then
     p.active=false;p.tex:SetAlpha(0)
    else
     p.vy=p.vy-32*dt
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.side*half+p.x*scale,p.y*scale)
     p.tex:SetSize(p.size*scale,p.size*scale)
     local t=p.life/p.duration
     p.tex:SetAlpha(p.alpha*math.min(1,t/.12,(1-t)/.45))
    end
   end
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
  s.clock=0;s.spawn=0
  for _,p in ipairs(s.falling) do p.active=false;p.tex:SetAlpha(0) end
  s.holder:Show()
 end
end
