local _, MR = ...
local FX = {}
MR.ArcaneumFX = FX

local TAU = math.pi * 2
local function random(a,b) return a + math.random() * (b-a) end
local function rotate(tex, angle)
 local c,s=math.cos(angle),math.sin(angle)
 tex:SetTexCoord(
  .5-.5*c+.5*s,.5-.5*s-.5*c,
  .5-.5*c-.5*s,.5-.5*s+.5*c,
  .5+.5*c+.5*s,.5+.5*s-.5*c,
  .5+.5*c-.5*s,.5+.5*s+.5*c)
end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 holder:EnableMouse(false)
 holder:Hide()
 local rune=holder:CreateTexture(nil,"ARTWORK",nil,0)
 rune:SetPoint("CENTER",entry.frame,"CENTER",0,0)
 rune:SetSize(130,130)
 rune:SetTexture(MR.path.."arcane\\Rune_01.tga")
 rune:SetBlendMode("ADD")
 rune:SetAlpha(.30)
 local rocks={}
 for i=1,10 do
  local t=holder:CreateTexture(nil,"OVERLAY",nil,1)
  local kind=i<=8 and string.format("Misc_Arcaneum_%02d",i) or string.format("Misc_Arcaneum_Medium_%02d",i-8)
  t:SetTexture(MR.path.."Arcaneum\\"..kind..".tga")
  t:SetSize(random(8,16),random(8,16))
  t:SetAlpha(random(.38,.65))
  rocks[i]={tex=t,angle=random(0,TAU),speed=random(.18,.38)*(i%2==0 and 1 or -1),rx=random(78,105),ry=random(12,26),spin=random(-1.1,1.1),rot=random(0,TAU)}
 end
 local sparks={}
 for i=1,35 do
  local t=holder:CreateTexture(nil,"OVERLAY",nil,2)
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetBlendMode("ADD")
  t:SetVertexColor(1,random(.13,.36),random(.7,1))
  t:SetSize(random(1,3),random(1,3))
  t:SetAlpha(0)
  sparks[i]={tex=t,life=0,maxLife=1,x=0,y=0,vx=0,vy=0}
 end
 local state={holder=holder,rune=rune,rocks=rocks,sparks=sparks,time=0,spawn=0,active=false,swap=false}
 holder:SetScript("OnUpdate",function(_,dt)
  if not state.active then return end
  dt=math.min(dt,.05)
  state.time=state.time+dt
  rotate(rune,state.time*.55)
  for _,r in ipairs(rocks) do
   r.angle=r.angle+r.speed*TAU*dt
   r.rot=r.rot+r.spin*dt
   local t=r.tex
   t:ClearAllPoints()
   t:SetPoint("CENTER",entry.frame,"CENTER",math.cos(r.angle)*r.rx,math.sin(r.angle)*r.ry)
   rotate(t,r.rot)
  end
  for _,p in ipairs(sparks) do
   if p.life>0 then
    p.life=p.life-dt
    if p.life<=0 then p.tex:SetAlpha(0)
    else
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.vy=p.vy-15*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.65*math.min(1,p.life/.45))
    end
   end
  end
  state.spawn=state.spawn+dt
  if state.spawn>=.045 then
   state.spawn=0
   for _,p in ipairs(sparks) do
    if p.life<=0 then
     p.life=random(.4,1.1);p.maxLife=p.life
     p.x=random(-65,65);p.y=random(-9,9)
     p.vx=random(-16,16);p.vy=random(8,35)
     break
    end
   end
  end
 end)
 return state
end

function FX:SetActive(entry,enabled)
 if not entry then return end
 if not enabled then
  local s=entry.arcaneumFX
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 local s=entry.arcaneumFX
 if not s then s=Make(entry);entry.arcaneumFX=s end
 if s.active then return end
 s.active=true
 s.time=0
 s.spawn=0
 s.swap=not s.swap
 s.rune:SetTexture(MR.path.."arcane\\Rune_"..(s.swap and "02" or "01")..".tga")
 for _,p in ipairs(s.sparks) do p.life=0;p.tex:SetAlpha(0) end
 s.holder:Show()
end
