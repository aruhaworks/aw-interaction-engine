AWInteractionConfig = {
    cellSize = 32.0,

    -- The scanner sleeps longer when the player is far from
    -- the closest registered interaction.
    scanIntervals = {
        active = 0,
        nearby = 100,
        idle = 500
    },

    defaultRadius = 2.0,
    maxServerDistance = 8.0,

    debug = false
}
