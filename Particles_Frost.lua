-- MoonRange Frost and Ice selected-target effects.
-- Adapted from the supplied Sleek Casting Bars frost mist and particles.
local _, MR = ...
local FX = {}
MR.FrostFX = FX
local TAU = math.pi * 2
local function rand(a,b) return a + math.random()*(b-a) end

local function Make(entry)
 local holder=CreateFrame("Frame",nil,entry.foreground)
 holder:SetAllPoints(entry.frame)
 holder:SetFrameLevel(entry.foreground:GetFrameLevel()+1)
 holder:EnableMouse(false)
 holder:Hide()
 local mist={}
 for i=1,3 do
  local tex=holder:CreateTexture(nil,"ARTWORK",nil,1)
  tex:SetTexture(MR.path.."frost\\Mist_Frost_01.tga")
  tex:SetBlendMode("ADD")
  tex:SetSize(225,110)
  tex:SetAlpha(0)
  mist[i]={tex=tex,x=(i-2)*55,phase=(i-1)*2.1,scale=rand(.88,1.12)}
 end
 local particles={}
 for i=1,42 do
  local tex=holder:CreateTexture(nil,"OVERLAY",nil,2)
  tex:SetTexture(MR.path..string.format("frost\\Particle_Frost_%02d.tga",i%2+1))
  tex:SetBlendMode("ADD")
  tex:SetAlpha(0)
  particles[i]={tex=tex,active=false,life=0}
 end
 local state={holder=holder,mist=mist,particles=particles,elapsed=0,spawn=0,ice=false}
 local function Spawn()
  for _,p in ipairs(particles) do
   if not p.active then
    p.active=true;p.life=0
    p.maxLife=state.ice and rand(.4,.8) or rand(.8,1.5)
    p.x=rand(-94,94);p.y=rand(-9,9)
    p.vx=rand(-22,22)*(state.ice and 1.6 or 1)
    p.vy=state.ice and rand(38,84) or rand(14,38)
    local size=state.ice and rand(5,10) or rand(4,8)
    p.tex:SetSize(size,size)
    return
   end
  end
 end
 holder:SetScript("OnUpdate",function(_,dt)
  dt=math.min(dt,.05)
  state.elapsed=state.elapsed+dt
  local ice=state.ice
  for _,m in ipairs(mist) do
   local t=state.elapsed+m.phase
   local alpha=(ice and .43 or .50)*(.72+.28*math.sin(t*.85))
   m.tex:SetAlpha(math.max(0,alpha)*math.min(1,state.elapsed))
   m.tex:SetSize((ice and 205 or 235)*m.scale,(ice and 96 or 115)*m.scale)
   m.tex:ClearAllPoints()
   m.tex:SetPoint("CENTER",entry.frame,"CENTER",m.x+math.sin(t*.48)*12,16+math.sin(t*.65)*9)
  end
  state.spawn=state.spawn+dt
  local interval=ice and .045 or .065
  if state.spawn>=interval then state.spawn=state.spawn-interval;Spawn() end
  for _,p in ipairs(particles) do
   if p.active then
    p.life=p.life+dt
    if p.life>=p.maxLife then
     p.active=false;p.tex:SetAlpha(0)
    else
     p.x=p.x+p.vx*dt
     p.y=p.y+p.vy*dt
     p.vy=p.vy-(ice and 28 or 12)*dt
     p.tex:ClearAllPoints()
     p.tex:SetPoint("CENTER",entry.frame,"CENTER",p.x,p.y)
     local t=p.life/p.maxLife
     p.tex:SetAlpha((ice and .82 or .65)*math.min(1,(1-t)/.45))
    end
   end
  end
 end)
 return state
end

function FX:SetActive(entry,theme)
 if not entry.frostFX then
  if not theme then return end
  entry.frostFX=Make(entry)
 end
 local state=entry.frostFX
 if theme then
  local ice=theme=="Ice"
  if not state.holder:IsShown() or state.ice~=ice then
   state.ice=ice
   state.elapsed=0;state.spawn=0
   for _,p in ipairs(state.particles) do p.active=false;p.tex:SetAlpha(0) end
   state.holder:Show()
  end
 else
  if state.holder:IsShown() then
   state.holder:Hide()
   for _,p in ipairs(state.particles) do p.active=false;p.tex:SetAlpha(0) end
  end
 end
end
