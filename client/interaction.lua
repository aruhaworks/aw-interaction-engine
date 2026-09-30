local interactions = {}
local spatial = SpatialHash:new(AWInteractionConfig.cellSize)

local currentTarget = nil
local lastPosition = nil

local function validCoords(coords)
    return coords
        and type(coords.x) == 'number'
        and type(coords.y) == 'number'
        and type(coords.z) == 'number'
end

local function distanceSquared(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z

    return dx * dx + dy * dy + dz * dz
end

local function registerInteraction(data)
    assert(type(data.id) == 'string', 'interaction id is required')
    assert(validCoords(data.coords), 'interaction coords are required')

    if interactions[data.id] then
        spatial:remove(data.id, interactions[data.id].coords)
    end

    data.radius = data.radius or AWInteractionConfig.defaultRadius
    interactions[data.id] = data
    spatial:insert(data.id, data.coords)
end

local function removeInteraction(id)
    local interaction = interactions[id]

    if not interaction then
        return false
    end

    spatial:remove(id, interaction.coords)
    interactions[id] = nil

    if currentTarget == id then
        currentTarget = nil
    end

    return true
end

RegisterNetEvent('aw:interaction:add', function(data)
    registerInteraction(data)
end)

RegisterNetEvent('aw:interaction:remove', function(id)
    removeInteraction(id)
end)

RegisterNetEvent('aw:interaction:sync', function(data)
    interactions = {}
    spatial:clear()

    for _, interaction in ipairs(data) do
        registerInteraction(interaction)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local position = GetEntityCoords(ped)

        local moved = true

        if lastPosition then
            moved = distanceSquared(position, lastPosition) > 0.04
        end

        lastPosition = position

        local candidates = spatial:query(position, 12.0)
        local closest = nil
        local closestDistance = math.huge

        for i = 1, #candidates do
            local id = candidates[i]
            local interaction = interactions[id]

            if interaction then
                local maxDistance = interaction.radius + 1.0
                local distance = distanceSquared(position, interaction.coords)

                if distance <= maxDistance * maxDistance and distance < closestDistance then
                    closest = interaction
                    closestDistance = distance
                end
            end
        end

        currentTarget = closest and closest.id or nil

        if closest and closestDistance <= (closest.radius * closest.radius) then
            SendNUIMessage({
                action = 'target',
                id = closest.id,
                label = closest.label or closest.id
            })

            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('aw:interaction:activate', closest.id)
            end
        else
            SendNUIMessage({ action = 'clear' })
        end

        local interval = AWInteractionConfig.scanIntervals.idle

        if closest then
            interval = AWInteractionConfig.scanIntervals.nearby
        end

        if not moved then
            interval = math.max(interval, 150)
        end

        Wait(interval)
    end
end)

exports('AddInteraction', registerInteraction)
exports('RemoveInteraction', removeInteraction)
exports('GetInteraction', function(id)
    return interactions[id]
end)
