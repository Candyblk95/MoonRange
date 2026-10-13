-- Chaos nameplate particles adapted from the supplied Sleek Casting Bars effect.
-- Random Spike_BG grows behind the bar; corrupted green ashes and glowing motes.
local _,MR=...
local FX={}
MR.ChaosFX=FX
local function rand(a,b)return a+math.random()*(b-a)end
local TAU=math.pi*2
local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+2)
 holder:EnableMouse(false);holder:Hide()
 local spikeLayer=CreateFrame("Frame",nil,entry.frame)
 spikeLayer:SetAllPoints(entry.frame)
 spikeLayer:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 spikeLayer:EnableMouse(false)
 local spike=spikeLayer:CreateTexture(nil,"BACKGROUND",nil,0)
 spike:SetPoint("CENTER",entry.frame,"CENTER",0,0)
 spike:SetBlendMode("BLEND");spike:SetAlpha(0)
 spikeLayer:Hide()
 local ashes,glows={},{}
 for i=1,60 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture(MR.path..string.format("earth\\Misc_Earth_%02d.tga",(i-1)%7+5))
  t:SetBlendMode("ADD");t:SetVertexColor(.10,.85,.20);t:SetAlpha(0)
  ashes[i]={tex=t,active=false}
 end
 for i=1,60 do
  local t=holder:CreateTexture(nil,"OVERLAY")
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD");t:SetVertexColor(.10,.85,.20);t:SetAlpha(0)
  glows[i]={tex=t,active=false}
 end
 local s={holder=holder,spikeLayer=spikeLayer,spike=spike,ashes=ashes,glows=glows,
          clock=0,ashAcc=0,glowAcc=0}
 local function SpawnAsh(w,h,progress)
  for _,a in ipairs(ashes) do
   if not a.active then
    local edge=math.random(2)==1 and 1 or -1
    a.active=true;a.life=0;a.maxLife=rand(.8,2.2)
    a.x=rand(-w*.5,-w*.5+w*progress)
    a.y=edge*h*.5*rand(.2,.8)
    a.vx=rand(-18,18);a.vy=rand(12,35)
    a.drift=rand(-8,8);a.phase=rand(0,TAU)
    a.size=rand(3,9)
    a.tex:SetAlpha(.9)
    return
   end
  end
 end
 local function SpawnGlow(w,h,progress)
  for _,p in ipairs(glows) do
   if not p.active then
    local spread=math.min(h*.25,10)
    p.active=true;p.life=0;p.maxLife=rand(.18,.35)
    p.x=-w*.5+w*progress+rand(0,3)
    p.y=rand(-spread,spread);p.vy=rand(-5,5);p.phase=rand(0,TAU)
    p.size=rand(6,12);p.tex:SetAlpha(0)
    return
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  s.clock=s.clock+dt
  local scale=entry.particleScale or 1
  local w=(entry.lastWidth or 150)/scale
  local h=20
  -- The original grows its chosen spike backdrop over the first 60% of progress.
  -- Nameplates have no cast progress, so play this once on target selection.
  local t=math.min(s.clock/1.5,1)
  local ease=1-(1-t)^3
  s.spike:SetSize(math.max(1,200*scale*ease),math.max(1,100*scale*ease))
  local progress=.5+.5*math.sin(s.clock*.6)
  for _,a in ipairs(ashes) do
   if a.active then
    a.life=a.life+dt
    local age=a.life/a.maxLife
    if age>=1 then a.active=false;a.tex:SetAlpha(0)
    else
     a.vy=a.vy-4*dt
     a.x=a.x+a.vx*dt+math.sin(a.life*2.5+a.phase)*a.drift*dt
     a.y=a.y+a.vy*dt
     a.tex:SetSize(a.size*scale,a.size*scale)
     a.tex:ClearAllPoints();a.tex:SetPoint("CENTER",entry.frame,"CENTER",a.x*scale,a.y*scale)
     local alpha=age<.15 and age/.15 or age<.65 and 1 or math.max(0,(1-age)/.35)
     a.tex:SetAlpha(alpha*.9)
    end
   end
  end
  s.ashAcc=s.ashAcc+dt
  while s.ashAcc>=.05 do s.ashAcc=s.ashAcc-.05;SpawnAsh(w,h,1) end

 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.chaosFX
 if not enabled then
  if s then s.holder:Hide();s.spikeLayer:Hide() end
  return
 end
 if not s then s=Make(entry);entry.chaosFX=s end
 if not s.holder:IsShown() then
  s.clock=0;s.ashAcc=0;s.glowAcc=0
  s.spike:SetTexture(MR.path.."chaos\\Spike_BG_0"..math.random(4)..".tga")
  s.spike:SetSize(1,1);s.spike:SetAlpha(1)
  for _,pool in ipairs({s.ashes,s.glows}) do
   for _,p in ipairs(pool) do p.active=false;p.tex:SetAlpha(0) end
  end
  s.spikeLayer:Show();s.holder:Show()
 end
end
