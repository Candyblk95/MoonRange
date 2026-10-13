-- MoonRange Holy: Herbalism-style elliptical particle swirl.
-- Light_Holy remains reserved for the existing range indicator.
local _, MR = ...
local FX = {}
MR.HolyFX = FX
local TAU=math.pi*2
local function rand(a,b) return a+math.random()*(b-a) end

local function Make(entry)
 -- Match Frost/Ice layering: all effects behind the ornate Holy artwork.
 local f=CreateFrame("Frame",nil,entry.frame)
 f:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 f:SetScale(1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=f
 f:SetFrameLevel(math.max(0,entry.frame:GetFrameLevel()-1))
 f:EnableMouse(false)
 f:Hide()

 local orbit,glows={},{}
 for i=1,34 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,1)
  if i%5==0 then
   t:SetTexture(MR.path.."holy\\Stars_Holy.tga")
  else
   t:SetTexture(MR.path.."holy\\Misc_Holy_0"..((i%2)+1)..".tga")
  end
  t:SetBlendMode("ADD")
  t:SetAlpha(0)
  orbit[i]={tex=t,active=false}
 end
 for i=1,34 do
  local t=f:CreateTexture(nil,"ARTWORK",nil,2)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(1,.92,.45)
  t:SetAlpha(0)
  glows[i]={tex=t,life=0}
 end
 local s={holder=f,orbit=orbit,glows=glows,active=false,orbitClock=0,glowClock=0}
 f:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  local w=entry.lastWidth or 190
  if w<20 then w=190 end
  -- Same shallow elliptical swirl as Herbalism, with alternating directions.
  for _,p in ipairs(orbit) do
   if p.active then
    p.life=p.life+dt
    p.theta=p.theta+p.speed*dt
    local x=math.cos(p.theta)*p.rx
    local y=math.sin(p.theta)*p.ry+math.sin(p.life*2+p.phase)*2
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
    p.tex:SetAlpha(p.alpha*(.72+.28*math.sin(p.theta)^2))
   end
  end
  s.orbitClock=s.orbitClock+dt
  if s.orbitClock>=.17 then
   s.orbitClock=0
   for i,p in ipairs(orbit) do
    if not p.active then
     p.active=true;p.life=0
     p.theta=rand(0,TAU)
     p.speed=rand(.45,1.1)*(math.random(2)==1 and 1 or -1)
     p.rx=rand(w*.37,w*.58)
     p.ry=rand(15,28)
     p.phase=rand(0,TAU)
     p.alpha=rand(.40,.70)
     local size=i%5==0 and rand(5,8) or rand(4,8)
     p.tex:SetSize(size,size)
     break
    end
   end
  end
  -- Smaller golden glints drifting around the outer edges.
  for _,p in ipairs(glows) do
   if p.life>0 then
    p.life=p.life-dt
    if p.life<=0 then p.tex:SetAlpha(0)
    else
     p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     p.tex:SetAlpha(.48*math.min(1,p.life/.12))
    end
   end
  end
  s.glowClock=s.glowClock+dt
  if s.glowClock>=.065 then
   s.glowClock=0
   for _,p in ipairs(glows) do
    if p.life<=0 then
     p.life=rand(.20,.38)
     p.x=rand(-w*.55,w*.55)
     p.y=(math.random(2)==1 and 1 or -1)*rand(14,25)
     p.vx=rand(-8,8);p.vy=rand(-6,6)
     local size=rand(3,5)
     p.tex:SetSize(size,size)
     break
    end
   end
  end
 end)
 return s
end

function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.holyFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=Make(entry);entry.holyFX=s end
 if s.active then return end
 s.active=true;s.orbitClock=0;s.glowClock=0
 for _,p in ipairs(s.orbit) do p.active=false;p.tex:SetAlpha(0) end
 for _,p in ipairs(s.glows) do p.life=0;p.tex:SetAlpha(0) end
 s.holder:Show()
end
