local QBCore = exports['qb-core']:GetCoreObject()
local washingPos = vector3(1904.3, 266.01, 161.53)
local washingInProgress = false
local smeltingInProgress = false 
local hasPickaxe = false
local rockMined = {}

function HasPickaxe()
    for k,v in pairs(QBCore.Functions.GetPlayerData().items) do
        if v.name == 'pickaxe' then
            return true
        end
    end
    return false
end

function GetClosestZone()
    local playerPos = GetEntityCoords(PlayerPedId())
    local closestZone = nil
    local closestDistance = nil
    for _, zone in pairs(Config.zones) do
        local distance = #(playerPos - zone.pos)
        if closestDistance == nil or distance < closestDistance then
            closestDistance = distance
            closestZone = zone
        end
    end
    return closestZone, closestDistance
end

Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    for _, zone in pairs(Config.zones) do
        exports['qb-target']:AddBoxZone(
            zone.name,
            zone.pos,
            2, 2,
            {
                name = zone.name,
                heading = 0,
                debugPoly = false,
            },
            {
                options = {
                    {
                        type = "Client",
                        event = "ud-mining:client:MiningStone",
                        icon = "fas fa-circle",
                        label = "Mine Stone",
                    },
                },
                distance = 2.5,
            }
        )
    end
    exports['qb-target']:AddBoxZone("Smelter", vector3(1111.69, -2009.54, 30.9), 2, 2, {
        name = "Smelter",
        heading = 0,
        debugPoly = false,
        minZ = 28.9,
        maxZ = 32.9,
    }, {
        options = {
            {
                event = "ud-mining:SmelterMenu",
                icon = "far fa-clipboard",
                label = "Open Smelter Menu",
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent('ud-mining:SmelterMenu', function(data)
    exports['qb-menu']:openMenu({
        {
            id = 0,
            header = "Smelter Menu",
        },
        {
            id = 1,
            header = "• Gold Ore",
            txt = "1x Stone",
            params = {
                event = "ud-mining:client:MeltingOre"
            }
        },
        {
            id = 2,
            header = "Close (ESC)",
        },
    })
end)

RegisterNetEvent('ud-mining:client:MiningStone')
AddEventHandler("ud-mining:client:MiningStone", function()
    local closestZone, closestDistance = GetClosestZone()
    if closestZone == nil or closestDistance > 2.5 then
        QBCore.Functions.Notify("There is no rock to mine nearby.", "error")
        return
    end
    local rockName = closestZone.name
    if rockMined[rockName] then
        QBCore.Functions.Notify("This rock has already been mined.", "error")
        return
    end
    if not HasPickaxe() then
        QBCore.Functions.Notify("You need a pickaxe to mine stone.", "error")
        return
    end

    QBCore.Functions.Progressbar("mining", "Mining Some Stone", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "amb@world_human_const_drill@male@drill@base",
        anim = "base",
        flags = 16,
    }, {}, {}, function() 
        local playerPed = PlayerPedId()
        exports['ps-ui']:Circle(function(success)
            if success then
                exports["mz-skills"]:UpdateSkill('Mining', 1)
                StopAnimTask(playerPed, "amb@world_human_const_drill@male@drill@base", "base", 1.0)
                TriggerServerEvent("ud-mining:server:StoneMined")
                ClearPedTasks(playerPed)
                rockMined[rockName] = true
            else
                QBCore.Functions.Notify("Failed!", "error")
                ClearPedTasks(playerPed)
            end
        end)
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if #(pos - washingPos) < 2.5 then
            if not washingInProgress then
                exports['qb-core']:DrawText("Press [E] to wash stones", "primary")
            end
            if IsControlJustPressed(0, 38) then -- E key
                TriggerEvent("ud-mining:client:WashingStones")
            end
        else
            exports['qb-core']:HideText()
        end
    end
end)

local function onProgressComplete(success, eventType, progressName)
    local playerPed = PlayerPedId()
    if success then
        TriggerServerEvent(eventType)
        ClearPedTasks(playerPed)
    else
        QBCore.Functions.Notify("Failed!", "error")
        ClearPedTasks(playerPed)
    end
end

AddEventHandler("ud-mining:client:WashingStones", function()
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_BUM_WASH", 0, true)
    
    QBCore.Functions.Progressbar("washingstones", "Washing Stones...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        exports['ps-ui']:Circle(function(success)
            onProgressComplete(success, "ud-mining:server:WashStones", "washingstones")
        end)
    end)
end)

AddEventHandler("ud-mining:client:MeltingOre", function()
    QBCore.Functions.Progressbar("meltingore", "Melting Ore...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        exports['ps-ui']:Circle(function(success)
            onProgressComplete(success, "ud-mining:server:MeltOre", "meltingore")
        end)
    end)
end)