-- MoonRange Arcane: rotating runes and violet arcane particles.
-- Uses the original Arcane rune textures; does not alter health fill or range.
local _,MR=...
local FX={}
MR.ArcaneFX=FX
local TAU=math.pi*2
local function rand(a,b)return a+math.random()*(b-a)end
local function rotate(t,a)
 local c,s=math.cos(a),math.sin(a)
 t:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,.5-.5*c-.5*s,.5-.5*s+.5*c,.5+.5*c+.5*s,.5+.5*s-.5*c,.5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.frame)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 holder:EnableMouse(false);holder:Hide()
 local runes={}
 for i=1,2 do
  local t=holder:CreateTexture(nil,"ARTWORK",nil,1)
  t:SetTexture(MR.path.."arcane\\Rune_0"..i..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(.65,.35,1)
  t:SetSize(54,54)
  t:SetAlpha(.36)
  runes[i]={tex=t,angle=rand(0,TAU),speed=(i==1 and .42 or -.35)}
 end
 local sparks={}
 for i=1,38 do
  local t=holder:CreateTexture(nil,"ARTWORK",nil,2)
  t:SetTexture("Interface\\Buttons\\WHITE8X8")
  t:SetBlendMode("ADD")
  t:SetVertexColor(rand(.55,.85),rand(.24,.50),1)
  t:SetAlpha(0)
  sparks[i]={tex=t,active=false}
 end
 local s={holder=holder,runes=runes,sparks=sparks,active=false,clock=0,spawn=0}
 holder:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  s.clock=s.clock+dt
  local w=entry.lastWidth or entry.frame:GetWidth()
  if not w or w<20 then w=170 end
  for i,r in ipairs(runes)do
   r.angle=r.angle+r.speed*dt
   local x=(i==1 and -1 or 1)*(w*.47)
   r.tex:ClearAllPoints();r.tex:SetPoint("CENTER",entry.frame,"CENTER",x,0)
   r.tex:SetAlpha(.28+.16*(.5+.5*math.sin(s.clock*2+i)))
   rotate(r.tex,r.angle)
  end
  for _,p in ipairs(sparks)do
   if p.active then
    p.life=p.life+dt
    local t=p.life/p.duration
    if t>=1 then p.active=false;p.tex:SetAlpha(0)
    else
     p.angle=p.angle+p.speed*dt
     p.x=p.x+p.vx*dt
     local y=p.side*(p.ry+math.sin(p.angle)*p.amp)
     p.tex:ClearAllPoints();p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,y)
     p.tex:SetAlpha(p.alpha*math.min(1,t/.15,(1-t)/.3))
    end
   end
  end
  s.spawn=s.spawn+dt
  if s.spawn>=.07 then
   s.spawn=s.spawn-.07
   for _,p in ipairs(sparks)do
    if not p.active then
     p.active=true;p.life=0;p.duration=rand(.7,1.6)
     p.x=rand(-w*.54,w*.54);p.vx=rand(-15,15)
     p.side=math.random(2)==1 and -1 or 1
     p.ry=rand(12,21);p.amp=rand(3,8)
     p.angle=rand(0,TAU);p.speed=rand(1,2.7)
     p.alpha=rand(.35,.75)
     local z=rand(1.5,3.5);p.tex:SetSize(z,z)
     break
    end
   end
  end
 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.arcaneFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=Make(entry);entry.arcaneFX=s end
 if s.active then return end
 s.active=true;s.spawn=0
 for _,p in ipairs(s.sparks)do p.active=false;p.tex:SetAlpha(0)end
 s.holder:Show()
end
