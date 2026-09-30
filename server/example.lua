CreateThread(function()
    Wait(1000)

    exports['aw-interaction-engine']:AddInteraction({
        id = 'aw_demo_terminal',
        coords = vector3(441.2, -981.9, 30.7),
        radius = 2.0,
        label = 'Use terminal',
        cooldown = 1000,

        canUse = function(source)
            return source > 0
        end,

        onServer = function(source)
            print(('[AW Interaction] Player %s used the demo terminal'):format(source))
        end
    })
end)
