local _, MR = ...
_G.MoonRange = MR
MR.path = "Interface\\AddOns\\MoonRange\\Textures\\"
MR.className, MR.classToken = UnitClass("player")
local defaults = { theme="Moon", spell="", width=190, height=30, enabled=true, update=0.15, nameFont="FRIZQT", nameSize=14, nameX=0, nameY=24, showLevel=true, levelSize=11, levelX=0, levelY=-12, castWidth=130, castHeight=10, castX=0, castY=-32 }
function MR:Print(text) DEFAULT_CHAT_FRAME:AddMessage("|cff67cfffMoonRange|r: "..tostring(text)) end
function MR:KnownSpells()
 local out,seen={},{}
 if GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemName then
  for t=1,GetNumSpellTabs() do
   local _,_,offset,count=GetSpellTabInfo(t)
   if offset and count then
    for slot=offset+1,offset+count do
     local name=GetSpellBookItemName(slot,BOOKTYPE_SPELL or "spell")
     if name and not seen[name] then seen[name]=true;out[#out+1]=name end
    end
   end
  end
 end
 -- Forever exposes the modern spellbook API on some builds.
 if #out==0 and C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
  local book=Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
  local tabs=C_SpellBook.GetNumSpellBookSkillLines()
  for tab=1,tabs do
   local info=C_SpellBook.GetSpellBookSkillLineInfo(tab)
   if info then
    local offset=info.itemIndexOffset or 0
    local count=info.numSpellBookItems or 0
    for slot=offset+1,offset+count do
     local item=C_SpellBook.GetSpellBookItemInfo(slot,book)
     local name=item and (item.name or (item.spellID and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(item.spellID)))
     if name and not seen[name] then seen[name]=true;out[#out+1]=name end
    end
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
-- Forever range API takes a spell ID, not a spell name.
local SPELL_IDS={["Throw"]=2764,["Shoot"]=5019,["Auto Shot"]=75}
local function ResolveSpellID(name)
 if not name or name=="" then return nil end
 if SPELL_IDS[name] then return SPELL_IDS[name] end
 if C_Spell and C_Spell.GetSpellInfo then
  local ok,info=pcall(C_Spell.GetSpellInfo,name)
  if ok and type(info)=="table" then return info.spellID end
 end
 if GetSpellInfo then
  local ok,_,_,_,_,_,_,id=pcall(GetSpellInfo,name)
  if ok then return id end
 end
 return nil
end
function MR:RangeState()
 if not self.db or not self.db.enabled or not UnitExists("target") then return nil end
 local id=ResolveSpellID(self.db.spell)
 if not id then return nil end
 local fn=C_Spell and C_Spell.IsSpellInRange or IsSpellInRange
 if not fn then return nil end
 local ok,v=pcall(fn,id,"target")
 if not ok or (issecretvalue and issecretvalue(v)) then return nil end
 if v==true or v==1 then return true end
 if v==false or v==0 then return false end
 return nil
end
function MR:RangeDebug()
 local name=self.db and self.db.spell or ""
 local id=ResolveSpellID(name)
 local state=self:RangeState()
 self:Print("Spell="..tostring(name).." | ID="..tostring(id).." | Range="..tostring(state))
 if not id then self:Print("No spell ID resolved. Choose Throw, Shoot or a ranged spell from /moonrange.") end
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
 elseif command=="castdebug" then if MR.DebugCastBars then MR:DebugCastBars() end
 elseif command=="debug" then MR:Print("Class: "..tostring(MR.classToken).." / Known: "..#MR:KnownSpells());MR:RangeDebug()
 elseif command=="on" or command=="off" then if MR.db then MR.db.enabled=(command=="on") end
 elseif MR.ToggleConfig then MR:ToggleConfig() end
end
