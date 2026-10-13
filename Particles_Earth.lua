-- MoonRange Earth particles, adapted from the supplied Earth casting-bar effect.
local _, MR = ...
local FX = {}
MR.EarthFX = FX
local TAU = math.pi * 2
local function rand(a,b) return a + math.random()*(b-a) end
local function rotate(tex,a)
 local c,s=math.cos(a),math.sin(a)
 tex:SetTexCoord(.5-.5*c+.5*s,.5-.5*s-.5*c,
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
 local orbit={}
 for i=1,18 do
  local rock=i<=4
  local index=rock and i or (i-5)%7+5
  local tex=holder:CreateTexture(nil,"OVERLAY",nil,rock and 1 or 2)
  tex:SetTexture(MR.path..string.format("earth\\Misc_Earth_%02d.tga",index))
  tex:SetBlendMode("BLEND")
  local size=rock and rand(13,19) or rand(5,10)
  tex:SetSize(size,size)
  tex:SetAlpha(0)
  orbit[i]={tex=tex,angle=(i-1)*TAU/18,rx=rock and rand(83,111) or rand(65,96),
   ry=rock and rand(16,27) or rand(12,23),
   speed=rand(rock and .16 or .26,rock and .25 or .43)*(i%2==0 and 1 or -1),
   rot=rand(0,TAU),spin=rand(-1.5,1.5),alpha=rock and .78 or .68}
 end
 local fragments={}
 for i=1,32 do
  local tex=holder:CreateTexture(nil,"OVERLAY",nil,3)
  tex:SetTexture(MR.path..string.format("earth\\Misc_Earth_%02d.tga",(i-1)%7+5))
  tex:SetBlendMode("BLEND")
  tex:SetAlpha(0)
  fragments[i]={tex=tex,active=false,life=0}
 end
 local state={holder=holder,orbit=orbit,fragments=fragments,elapsed=0,spawn=0}
 local function Burst()
  for _,p in ipairs(fragments) do
   if not p.active then
    p.active=true;p.life=0;p.maxLife=rand(.45,.85)
    p.x=rand(-55,55);p.y=rand(-5,6)
    p.vx=rand(-27,27);p.vy=rand(30,76)
    local size=rand(3,7)
    p.tex:SetSize(size,size)
    p.tex:SetAlpha(.72)
    return
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  state.elapsed=state.elapsed+dt
  for _,o in ipairs(orbit) do
   o.angle=o.angle+o.speed*TAU*dt
   o.rot=o.rot+o.spin*dt
   local x=math.cos(o.angle)*o.rx
   local y=math.sin(o.angle)*o.ry
   o.tex:ClearAllPoints()
   o.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
   o.tex:SetAlpha(o.alpha*math.min(1,state.elapsed*1.7))
   rotate(o.tex,o.rot)
  end
  state.spawn=state.spawn+dt
  if state.spawn>=.12 then
   state.spawn=state.spawn-.12
   Burst()
  end
  for _,p in ipairs(fragments) do
   if p.active then
    p.life=p.life+dt
    if p.life>=p.maxLife then
     p.active=false;p.tex:SetAlpha(0)
    else
     p.vy=p.vy-115*dt
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     local t=p.life/p.maxLife
     p.tex:SetAlpha(.72*math.min(1,(1-t)/.4))
    end
   end
  end
 end)
 return state
end
function FX:SetActive(entry,enabled)
 if not entry.earthFX then
  if not enabled then return end
  entry.earthFX=Make(entry)
 end
 local state=entry.earthFX
 if enabled then
  if not state.holder:IsShown() then
   state.elapsed=0;state.spawn=0
   state.holder:Show()
  end
 else
  if state.holder:IsShown() then
   state.holder:Hide()
   for _,p in ipairs(state.fragments) do p.active=false;p.tex:SetAlpha(0) end
  end
 end
end
