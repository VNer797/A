local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local SUCCESS_FLAGS, COMBAT_REMOTE_THREAD = pcall(function()
    return require(Modules.Flags).COMBAT_REMOTE_THREAD or false
end)
local SUCCESS_HIT, HIT_FUNCTION = pcall(function()
    return (getmenv or getsenv)(Net)._G.SendHitsToServer
end)

function SendAttack(Cooldown, Args)
    RegisterAttack:FireServer(Cooldown)
    if SUCCESS_FLAGS and COMBAT_REMOTE_THREAD and SUCCESS_HIT and HIT_FUNCTION then
        HIT_FUNCTION(Args[1], Args[2])
    else
        RegisterHit:FireServer(Args[1], Args[2])
    end
end

local FastAttack = {
    Distance = 60,
    AttackMobs = true,
    AttackPlayers = true,
    Debounce = 0
}

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:GetTargets(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return {} end
    local playerPos = character.HumanoidRootPart.Position
    local targets = {}

    if self.AttackMobs then
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
            local head = enemy:FindFirstChild("Head")
            if rootPart and self:IsEntityAlive(enemy) and (rootPart.Position - playerPos).Magnitude <= self.Distance then
                table.insert(targets, {enemy, head or rootPart})
            end
        end
    end

    if self.AttackPlayers then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and self:IsEntityAlive(otherPlayer.Character) and (rootPart.Position - playerPos).Magnitude <= self.Distance then
                    table.insert(targets, {otherPlayer.Character, rootPart})
                end
            end
        end
    end

    return targets
end

function FastAttack:Attack()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local weapon = character:FindFirstChildOfClass("Tool")
    if not weapon then return end
    local tip = weapon.ToolTip
    if tip ~= "Melee" and tip ~= "Sword" then return end
    local currentTime = tick()
    if currentTime - self.Debounce < 0.1 then return end
    self.Debounce = currentTime
    local targets = self:GetTargets(character)
    if #targets == 0 then return end
    local hitTargets = {}
    for _, target in ipairs(targets) do
        table.insert(hitTargets, {target[1], target[2]})
    end
    pcall(function()
        SendAttack(0.1, {hitTargets[1][2], hitTargets})
        task.wait(0.1)
    end)
end

task.spawn(function()
    while task.wait(0.0000001) do
        pcall(function()
            FastAttack:Attack()
        end)
    end
end)