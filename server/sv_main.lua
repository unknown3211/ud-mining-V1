local QBCore = exports['qb-core']:GetCoreObject()

 RegisterServerEvent('ud-mining:server:StoneMined')
AddEventHandler('ud-mining:server:StoneMined', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player ~= nil then
        Player.Functions.AddItem('stone', 1)
        TriggerClientEvent('QBCore:Notify', src, 'You have mined a stone!', 'success', 3500)
    end
end)

RegisterServerEvent("ud-mining:server:WashStones")
AddEventHandler("ud-mining:server:WashStones", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local stone = Player.Functions.GetItemByName("stone")
    if stone ~= nil then

        if stone.amount >= 1 then
            Player.Functions.RemoveItem("stone", 1)
            Player.Functions.AddItem("washedstone", 1)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["washedstone"], "add", 1)
            TriggerClientEvent('QBCore:Notify', src, 'Stones Washed.')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You dont have any stones bruh...', 'error')
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Missing something...", "error")
    end
end)

RegisterServerEvent("ud-mining:server:MeltOre")
AddEventHandler("ud-mining:server:MeltOre", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local washedstone = Player.Functions.GetItemByName("washedstone")
    if washedstone ~= nil then

        if washedstone.amount >= 1 then
            Player.Functions.RemoveItem("washedstone", 1)
            Player.Functions.AddItem("goldore", 1)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["goldore"], "add", 1)
            TriggerClientEvent('QBCore:Notify', src, 'Melted Stone.')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You dont have any  washed stones bruh...', 'error')
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Missing something...", "error")
    end
end)