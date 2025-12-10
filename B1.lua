local Module = {}

local Cached = { Bring = {} }
local _ENV = (getgenv or getrenv or getfenv)()
local BRING_TAG: string = _ENV._Bring_Tag or `b{math.random(80, 2e4)}t`
_ENV._Bring_Tag = BRING_TAG
local Settings = { BringDistance = 250 }

local hookmetamethod = hookmetamethod or (function(...) return ... end)
local hookfunction = hookfunction or (function(...) return ... end)
local sethiddenproperty = sethiddenproperty or (function(...) return ... end)

function Module.IsAlive(model)
  local hum = model:FindFirstChildOfClass("Humanoid")
  return hum and hum.Health > 0
end
function Module.BringEnemy()
    if not _B then return end
    pcall(sethiddenproperty,plr,"SimulationRadius", math.huge)
    for _, Enemy in pairs(workspace.Enemies:GetChildren()) do
        if not Module.IsAlive(Enemy) then continue end
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
function Module.Hop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Servers = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Server, Next = nil, nil
    local function ListServers(cursor)
    local Raw = game:HttpGet(Servers .. ((cursor and "&cursor=" .. cursor) or ""))
    return HttpService:JSONDecode(Raw)
    end
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[math.random(1, (#Servers.data / 3))]
        Next = Servers.nextPageCursor
    until Server
    if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, game.Players.LocalPlayer)
    end
end

return Module