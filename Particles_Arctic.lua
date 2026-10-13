-- Arctic nameplate particles adapted from the supplied Opulent Casting Bars Arctic effect.
-- Selected targets only. Ice fragments and mist stay behind the decorative frame.
local _,MR=...
local FX={}
MR.ArcticFX=FX
local TAU=math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end
local function rotate(tex,a)
 local c,s=math.cos(a),math.sin(a)
 tex:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,.5-.5*c-.5*s,.5-.5*s+.5*c,
                 .5+.5*c+.5*s,.5+.5*s-.5*c,.5+.5*c-.5*s,.5+.5*s+.5*c)
end
local function Make(entry)
 local back=CreateFrame("Frame",nil,entry.frame)
 back:SetAllPoints(entry.frame)
 back:SetFrameLevel(entry.frame:GetFrameLevel())
 back:EnableMouse(false)
 local front=CreateFrame("Frame",nil,entry.foreground)
 front:SetAllPoints(entry.frame)
 front:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 front:EnableMouse(false)
 local mists,rocks,orbit,flakes={},{},{},{}
 for i=1,4 do
  local t=back:CreateTexture(nil,"BACKGROUND",nil,2)
  t:SetTexture(MR.path.."frost\\Mist_Frost_01.tga")
  t:SetBlendMode("ADD")
  t:SetAlpha(0)
  mists[i]={tex=t,x=(i-.5)/4,phase=rand(0,TAU),speed=rand(.5,1.1),rot=rand(-.2,.2)}
 end
 local function rockTexture(i)
  if i<=8 then return string.format("Misc_Arctic_%02d",i) end
  if i<=10 then return string.format("Misc_Arctic_Medium_%02d",i-8) end
  return string.format("Misc_Arctic_Big_%02d",i-10)
 end
 for i=1,45 do
  local t=back:CreateTexture(nil,"ARTWORK",nil,1)
  t:SetTexture(MR.path.."arctic\\"..rockTexture((i-1)%12+1)..".tga")
  t:SetBlendMode("BLEND")
  local kind=i<=24 and 1 or i<=36 and 2 or 3
  local size=kind==1 and rand(5,10) or kind==2 and rand(10,15) or rand(15,21)
  t:SetSize(size,size)
  rocks[i]={tex=t,x=rand(-.48,.48),y=rand(-10,10),rise=rand(1,5),phase=rand(0,TAU),
   speed=rand(.5,1.5),rot=rand(0,TAU),spin=rand(-.45,.45),alpha=rand(.4,.75)}
 end
 for i=1,10 do
  local t=back:CreateTexture(nil,"ARTWORK",nil,2)
  t:SetTexture(MR.path.."arctic\\"..rockTexture((i-1)%12+1)..".tga")
  t:SetBlendMode("BLEND")
  local size=rand(10,21)
  t:SetSize(size,size)
  orbit[i]={tex=t,a=rand(0,TAU),rx=rand(85,125),ry=rand(14,30),
   speed=rand(.18,.38)*(i%2==0 and 1 or -1),rot=rand(0,TAU),spin=rand(-1.1,1.1),alpha=rand(.4,.7)}
 end
 for i=1,48 do
  local t=front:CreateTexture(nil,"OVERLAY",nil,1)
  t:SetTexture(MR.path.."frost\\Particle_Frost_0"..((i%2)+1)..".tga")
  t:SetBlendMode("ADD")
  t:SetAlpha(0)
  flakes[i]={tex=t,active=false}
 end
 local state={back=back,front=front,mists=mists,rocks=rocks,orbit=orbit,flakes=flakes,elapsed=0,spawn=0,clock=0}
 local function spawn()
  for _,p in ipairs(flakes) do
   if not p.active then
    p.active=true;p.life=0;p.duration=rand(.35,.8)
    p.x=rand(-65,65);p.y=rand(-6,6)
    p.vx=rand(-28,28);p.vy=rand(30,90)
    local sz=rand(4,9)
    p.tex:SetSize(sz,sz)
    return
   end
  end
 end
 back:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  state.elapsed=state.elapsed+dt
  state.clock=state.clock+dt
  local w=entry.lastWidth or 150
  for _,m in ipairs(mists) do
   m.phase=m.phase+m.speed*dt
   m.tex:ClearAllPoints()
   m.tex:SetPoint("CENTER",entry.frame,"CENTER",(m.x-.5)*w,math.sin(m.phase)*3)
   m.tex:SetSize(165+math.sin(m.phase*.5)*12,75+math.sin(m.phase*.5)*6)
   m.tex:SetAlpha(.10+.12*(.5+.5*math.sin(m.phase)))
   rotate(m.tex,m.rot)
  end
  for _,r in ipairs(rocks) do
   r.phase=r.phase+r.speed*dt
   r.rot=r.rot+r.spin*dt
   local x=r.x*w+math.sin(r.phase*.7)*3
   local y=r.y+math.sin(r.phase)*4+math.min(16,state.elapsed*r.rise)
   r.tex:ClearAllPoints()
   r.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
   r.tex:SetAlpha(r.alpha*math.min(1,state.elapsed/1.4))
   rotate(r.tex,r.rot)
  end
  for _,r in ipairs(orbit) do
   r.a=r.a+r.speed*TAU*dt
   r.rot=r.rot+r.spin*dt
   r.tex:ClearAllPoints()
   r.tex:SetPoint("CENTER",entry.frame,"CENTER",math.cos(r.a)*r.rx,math.sin(r.a)*r.ry)
   r.tex:SetAlpha(r.alpha*math.min(1,state.elapsed))
   rotate(r.tex,r.rot)
  end
  state.spawn=state.spawn+dt
  if state.spawn>=.07 then state.spawn=state.spawn-.07;spawn() end
  for _,p in ipairs(flakes) do
   if p.active then
    p.life=p.life+dt
    if p.life>=p.duration then p.active=false;p.tex:SetAlpha(0)
    else
     p.vy=p.vy-110*dt
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.75*math.min(1,(1-p.life/p.duration)/.55))
    end
   end
  end
 end)
 back:Hide();front:Hide()
 return state
end
function FX:SetActive(entry,enabled)
 if not entry.arcticFX then
  if not enabled then return end
  entry.arcticFX=Make(entry)
 end
 local s=entry.arcticFX
 if enabled then
  if not s.back:IsShown() then
   s.elapsed=0;s.spawn=0
   for _,r in ipairs(s.rocks) do r.phase=rand(0,TAU) end
   for _,p in ipairs(s.flakes) do p.active=false;p.tex:SetAlpha(0) end
   s.back:Show();s.front:Show()
  end
 else
  s.back:Hide();s.front:Hide()
  for _,p in ipairs(s.flakes) do p.active=false;p.tex:SetAlpha(0) end
 end
end
