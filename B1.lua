local Module = {}

local Cached = { Bring = {} }
local _ENV = (getgenv or getrenv or getfenv)()
local BRING_TAG: string = _ENV._Bring_Tag or `b{math.random(80, 2e4)}t`
_ENV._Bring_Tag = BRING_TAG
local Settings = { BringDistance = 250 }

local hookmetamethod = hookmetamethod or (function(...) return ... end)
local hookfunction = hookfunction or (function(...) return ... end)
local sethiddenproperty = sethiddenproperty or (function(...) return ... end)

function IsAlive(model)
  local hum = model:FindFirstChildOfClass("Humanoid")
  return hum and hum.Health > 0
end
function Module.BringEnemy()
    if not _B then return end
    pcall(sethiddenproperty,plr,"SimulationRadius", math.huge)
    for _, Enemy in pairs(workspace.Enemies:GetChildren()) do
        if not IsAlive(Enemy) then continue end
        if not Enemy.PrimaryPart then continue end
        if Enemy.Parent ~= workspace.Enemies then continue end
        if Enemy:FindFirstChild("CharacterReady") == nil then continue end
        local Primary = Enemy.PrimaryPart
        local dist = (Root.Position - Primary.Position).Magnitude
        if not Cached.Bring[Enemy] or (Primary.Position - Cached.Bring[Enemy].Position).Magnitude > 25 then
            Cached.Bring[Enemy] = CFrame.new(PosMon)
        end
        if dist < Settings.BringDistance then
            local hum = Enemy:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                Enemy:AddTag(BRING_TAG)
            end
            Primary.CFrame = CFrame.new(PosMon)
        end
    end
end

return Module