local _, MR = ...
_G.MoonRange = MR
MR.path = "Interface\\AddOns\\MoonRange\\Textures\\"
MR.className, MR.classToken = UnitClass("player")
local defaults = { spell="", width=190, height=30, enabled=true, update=0.15 }
function MR:Print(text) DEFAULT_CHAT_FRAME:AddMessage("|cff67cfffMoonRange|r: "..tostring(text)) end
function MR:KnownSpells()
 local out, seen = {}, {}
 if not GetNumSpellTabs then return out end
 for t=1,GetNumSpellTabs() do
  local _,_,offset,count=GetSpellTabInfo(t)
  if offset and count then
   for i=offset+1,offset+count do
    local name=GetSpellBookItemName(i,BOOKTYPE_SPELL or "spell")
    if name and not seen[name] then seen[name]=true;out[#out+1]=name end
   end
  end
 end
 table.sort(out)
 return out
end
function MR:IsKnownSpell(name)
 if not name or name=="" then return false end
 for _,spell in ipairs(self:KnownSpells()) do if spell==name then return true end end
 return false
end
function MR:SetSpell(name)
 if not self.db then return end
 if name=="" or self:IsKnownSpell(name) then
  self.db.spell=name;self:Print("Range spell: "..(name~="" and name or "none"))
 else self:Print("Spell not found in your spellbook: "..tostring(name)) end
end
function MR:RangeState()
 if not self.db or not self.db.enabled or not UnitExists("target") then return nil end
 if not self:IsKnownSpell(self.db.spell) or not IsSpellInRange then return nil end
 local ok,v=pcall(IsSpellInRange,self.db.spell,"target")
 if not ok then return nil end
 if v==1 or v==true then return true end
 if v==0 or v==false then return false end
 return nil
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:SetScript("OnEvent",function(_,event)
 if event=="PLAYER_LOGIN" then
  MoonRangeDB=type(MoonRangeDB)=="table" and MoonRangeDB or {}
  for k,v in pairs(defaults) do if MoonRangeDB[k]==nil then MoonRangeDB[k]=v end end
  MR.db=MoonRangeDB
  MR:StartNameplates()
  MR:Print("Loaded for "..(MR.className or "your class")..". Use /moonrange.")
 end
end)
SLASH_MOONRANGE1="/moonrange"
SLASH_MOONRANGE2="/mr"
SlashCmdList.MOONRANGE=function(msg)
 msg=(msg or ""):match("^%s*(.-)%s*$")
 local command,rest=msg:match("^(%S+)%s*(.*)$")
 command=command and command:lower() or ""
 if command=="spell" then MR:SetSpell(rest)
 elseif command=="debug" then MR:Print("Class: "..tostring(MR.classToken).." / Spell: "..tostring(MR.db and MR.db.spell).." / Range: "..tostring(MR:RangeState()))
 elseif command=="on" or command=="off" then if MR.db then MR.db.enabled=(command=="on") end
 elseif MR.ToggleConfig then MR:ToggleConfig() end
end
