local Module = {}

local replicated = game:GetService('ReplicatedStorage')
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
    local PlaceID = game.PlaceId
	local AllIDs = {}
	local foundAnything = ""
	local actualHour = os.date("!*t").hour
	local Deleted = false
	function TPReturner()
		local Site;
		if foundAnything == "" then
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
		else
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
		end
		local ID = ""
		if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
			foundAnything = Site.nextPageCursor
		end
		local num = 0;
		for i,v in pairs(Site.data) do
			local Possible = true
			ID = tostring(v.id)
			if tonumber(v.maxPlayers) > tonumber(v.playing) then
				for _,Existing in pairs(AllIDs) do
					if num ~= 0 then
						if ID == tostring(Existing) then
							Possible = false
						end
					else
						if tonumber(actualHour) ~= tonumber(Existing) then
							local delFile = pcall(function()
								AllIDs = {}
								table.insert(AllIDs, actualHour)
							end)
						end
					end
					num = num + 1
				end
				if Possible == true then
					table.insert(AllIDs, ID)
					wait()
					pcall(function()
						wait()
						game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
					end)
					wait(4)
				end
			end
		end
	end
	function Teleport() 
		while true do task.wait()
			pcall(function()
				TPReturner()
				if foundAnything ~= "" then
					TPReturner()
				end
			end)
		end
	end
	Teleport()
end
function Module.Rejoin()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
	ts:Teleport(game.PlaceId, p)
end
function Module.HopLowestPlayer()
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
function Module.Process(Value)
    if Value == 'EliteHunter' then
        local cache = nil
        if not cache then cache = replicated.Remotes.CommF_:InvokeServer("EliteHunter","Progress")end
        local value = string.match(cache, "%d+")
        return value
    end
    if Value == 'SpyChecker' then
        local cache = nil
        if not cache then cache = replicated.Remotes.CommF_:InvokeServer("InfoLeviathan","1")end
        local value = string.match(cache, "%d+")
        return value
    end
    if Value == 'Katakuri' then
        local cache = nil
        if not cache then cache = replicated.Remotes.CommF_:InvokeServer("CakePrinceSpawner")end
        local value = string.match(cache, "%d+")
        return value
    end
    if Value == 'Bones' then
        local InventoryCache = nil
        local LastUpdate = 0
        local function UpdateInventory()
            if tick() - LastUpdate > 3 then
                InventoryCache = replicated.Remotes.CommF_:InvokeServer("getInventory")
                LastUpdate = tick()
            end
        end
        local function GetM(Name)
            UpdateInventory()
            for _, tab in pairs(InventoryCache or {}) do
                if type(tab) == "table" and tab.Type == "Material" and tab.Name == Name then
                    return tab.Count
                end
            end
            return 0
        end
        return GetM('Bones')    
    end        
    return false
end

return Module