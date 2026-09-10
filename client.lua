local isLockedOut = false
local nuiReady = false
local pendingPayload = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qbx_namecheck:server:checkName')
end)

RegisterNetEvent('qbx_core:client:playerLoaded', function()
    TriggerServerEvent('qbx_namecheck:server:checkName')
end)

RegisterNUICallback('ready', function(_, cb)
    nuiReady = true
    if pendingPayload then
        SendNUIMessage(pendingPayload)
        pendingPayload = nil
    end
    cb('ok')
end)

RegisterNetEvent('qbx_namecheck:client:lockScreen', function(accountName, characterName)
    if isLockedOut then return end
    isLockedOut = true

    local payload = {
        action = "showLockout",
        accountName = accountName,
        characterName = characterName
    }

    if nuiReady then
        SendNUIMessage(payload)
    else
        pendingPayload = payload
    end
    SetNuiFocus(true, false)
    CreateThread(function()
        while isLockedOut do
            local playerPed = PlayerPedId()
            FreezeEntityPosition(playerPed, true)
            SetEntityInvincible(playerPed, true)
            SetEntityCoordsNoOffset(playerPed, 0.0, 0.0, 500.0, false, false, false)
            DisableAllControlActions(0)
            Wait(0)
        end
    end)
end)
