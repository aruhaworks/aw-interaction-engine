local interactions = {}
local cooldowns = {}

local function now()
    return GetGameTimer()
end

local function distanceSquared(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z

    return dx * dx + dy * dy + dz * dz
end

local function isRateLimited(source, id, cooldown)
    local key = ('%s:%s'):format(source, id)
    local timestamp = cooldowns[key] or 0
    local current = now()

    if current - timestamp < cooldown then
        return true
    end

    cooldowns[key] = current
    return false
end

local function canUse(source, interaction)
    if type(interaction.canUse) == 'function' then
        local ok, result = xpcall(
            interaction.canUse,
            debug.traceback,
            source
        )

        if not ok then
            print(('[AW Interaction] permission callback failed: %s'):format(result))
            return false
        end

        return result == true
    end

    return true
end

local function broadcast()
    local list = {}

    for _, interaction in pairs(interactions) do
        list[#list + 1] = {
            id = interaction.id,
            coords = interaction.coords,
            radius = interaction.radius,
            label = interaction.label
        }
    end

    TriggerClientEvent('aw:interaction:sync', -1, list)
end

local function addInteraction(data)
    assert(type(data.id) == 'string', 'interaction id is required')
    assert(data.coords, 'interaction coords are required')

    data.radius = data.radius or AWInteractionConfig.defaultRadius
    data.cooldown = data.cooldown or 500

    interactions[data.id] = data
    broadcast()
end

local function removeInteraction(id)
    if not interactions[id] then
        return false
    end

    interactions[id] = nil
    broadcast()

    return true
end

RegisterNetEvent('aw:interaction:activate', function(id)
    local source = source
    local interaction = interactions[id]

    if not interaction then
        return
    end

    local playerPed = GetPlayerPed(source)

    if playerPed == 0 then
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local maxDistance = math.min(
        interaction.radius + 0.75,
        AWInteractionConfig.maxServerDistance
    )

    if distanceSquared(playerCoords, interaction.coords)
        > maxDistance * maxDistance then
        return
    end

    if isRateLimited(source, id, interaction.cooldown) then
        return
    end

    if not canUse(source, interaction) then
        return
    end

    if type(interaction.onServer) == 'function' then
        local ok, err = xpcall(
            interaction.onServer,
            debug.traceback,
            source
        )

        if not ok then
            print(('[AW Interaction] handler failed: %s'):format(err))
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    local prefix = tostring(source) .. ':'

    for key in pairs(cooldowns) do
        if key:sub(1, #prefix) == prefix then
            cooldowns[key] = nil
        end
    end
end)

exports('AddInteraction', addInteraction)
exports('RemoveInteraction', removeInteraction)
exports('GetInteraction', function(id)
    return interactions[id]
end)
