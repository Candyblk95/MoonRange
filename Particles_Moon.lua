local _, MR = ...
local FX = {}
MR.MoonFX = FX
local function rand(a,b) return a+math.random()*(b-a) end
local function make(entry)
 local f=CreateFrame("Frame",nil,entry.foreground)
 f:SetAllPoints(entry.frame)
 -- Scale the entire particle layer with the artwork, preserving tuned offsets and sizes.
 f:SetScale(entry.particleScale or 1)
 entry.particleScaleFrames=entry.particleScaleFrames or {}
 entry.particleScaleFrames[#entry.particleScaleFrames+1]=f
 f:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 f:EnableMouse(false)
 f:Hide()
 local misc,glows={},{}
 for i=1,65 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,1)
  t:SetTexture(MR.path.."holy\\"..string.format("Misc_Holy_%02d",(i-1)%2+1)..".tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(0,.9,1)
  t:SetAlpha(0)
  misc[i]={tex=t,life=0}
 end
 for i=1,45 do
  local t=f:CreateTexture(nil,"OVERLAY",nil,2)
  t:SetTexture(MR.path.."frost\\Particle_Frost_01.tga")
  t:SetBlendMode("ADD")
  t:SetVertexColor(0,.9,1)
  t:SetAlpha(0)
  glows[i]={tex=t,life=0}
 end
 local s={holder=f,misc=misc,glows=glows,active=false,miscClock=0,glowClock=0}
 f:SetScript("OnUpdate",function(_,dt)
  if not s.active then return end
  dt=math.min(dt,.05)
  local w=entry.lastWidth or 190
  -- Wide elliptical paths let cyan fragments pass above and below the frame.
  for _,p in ipairs(misc) do
   if p.life>0 then
    p.life=p.life-dt
    if p.life<=0 then p.tex:SetAlpha(0)
    else
     p.theta=p.theta+p.speed*dt
     local x=math.cos(p.theta)*p.rx
     local y=math.sin(p.theta)*p.ry+math.sin(p.phase+p.life*3)*2
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",x,y)
     p.tex:SetAlpha(p.alpha*math.min(1,p.life/.3))
    end
   end
  end
  s.miscClock=s.miscClock+dt
  if s.miscClock>=.055 then
   s.miscClock=0
   for _,p in ipairs(misc) do
    if p.life<=0 then
     p.life=rand(1.5,3.2)
     p.theta=rand(0,math.pi*2)
     p.speed=rand(.7,1.5)*(math.random(2)==1 and 1 or -1)
     p.rx=rand(w*.30,w*.53)
     p.ry=rand(15,25)
     p.phase=rand(0,math.pi*2)
     p.alpha=rand(.58,.95)
     local size=rand(6,13);p.tex:SetSize(size,size)
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
     p.tex:SetAlpha(.75*math.min(1,p.life/.14))
    end
   end
  end
  s.glowClock=s.glowClock+dt
  if s.glowClock>=.045 then
   s.glowClock=0
   for _,p in ipairs(glows) do
    if p.life<=0 then
     p.life=rand(.2,.45)
     p.x=rand(-w*.45,w*.45)
     p.y=(math.random(2)==1 and 1 or -1)*rand(13,23)
     p.vx=rand(-6,6);p.vy=rand(-7,9)
     local size=rand(4,8);p.tex:SetSize(size,size)
     break
    end
   end
  end
 end)
 return s
end
function FX:SetActive(entry,enabled)
 if not entry then return end
 local s=entry.moonFX
 if not enabled then
  if s and s.active then s.active=false;s.holder:Hide() end
  return
 end
 if not s then s=make(entry);entry.moonFX=s end
 if s.active then return end
 s.active=true;s.miscClock=0;s.glowClock=0
 for _,p in ipairs(s.misc) do p.life=0;p.tex:SetAlpha(0) end
 for _,p in ipairs(s.glows) do p.life=0;p.tex:SetAlpha(0) end
 s.holder:Show()
end
