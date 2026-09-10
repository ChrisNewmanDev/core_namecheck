local function checkPlayerName(source, charInfo)
    if not source or source == 0 or not charInfo then return end

    if IsPlayerAceAllowed(source, "namecheck.bypass") then
        return
    end

    local accountName = GetPlayerName(source)
    if not accountName then return end

    local firstName = charInfo.firstname or ""
    local lastName = charInfo.lastname or ""
    local characterName = firstName .. " " .. lastName
    local cleanAccount = string.lower(accountName)
    local cleanFirst = string.lower(firstName)
    local cleanLast = string.lower(lastName)
    local hasFirst = cleanFirst ~= "" and string.find(cleanAccount, cleanFirst, 1, true) ~= nil
    local hasLast = cleanLast ~= "" and string.find(cleanAccount, cleanLast, 1, true) ~= nil

    if not (hasFirst and hasLast) then
        TriggerClientEvent('qbx_namecheck:client:lockScreen', source, accountName, characterName)
        print(("[NameCheck] Flagged %s. Name does not contain character details (%s)."):format(accountName, characterName))
    end
end

RegisterNetEvent('qbx_core:server:playerLoaded', function(PlayerData)
    checkPlayerName(PlayerData.source or source, PlayerData.charinfo)
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local PlayerData = Player.PlayerData or Player
    checkPlayerName(PlayerData.source or source, PlayerData.charinfo)
end)

local function getCharInfo(src)
    if GetResourceState('qb-core') == 'started' then
        local player = exports['qb-core']:GetPlayer(src)
        return player and player.PlayerData and player.PlayerData.charinfo
    elseif GetResourceState('qbx_core') == 'started' then
        local player = exports['qbx_core']:GetPlayer(src)
        return player and (player.charinfo or (player.PlayerData and player.PlayerData.charinfo))
    end
    return nil
end

RegisterNetEvent('qbx_namecheck:server:checkName', function()
    local src = source
    checkPlayerName(src, getCharInfo(src))
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Wait(500)
        for _, src in ipairs(GetPlayers()) do
            src = tonumber(src)
            checkPlayerName(src, getCharInfo(src))
        end
    end)
end)
