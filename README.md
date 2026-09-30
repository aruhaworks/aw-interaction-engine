# AW Interaction Engine

High-performance, server-authoritative interaction framework for FiveM.

Designed as a small systems project rather than a UI-only resource.

## What it demonstrates

- Spatial hashing for proximity lookups
- Client-side interaction scanning with adaptive intervals
- Server-authoritative action validation
- Per-player rate limiting
- Interaction registration/removal at runtime
- Permission callbacks
- Distance validation
- Cooldown handling
- Entity-aware interactions
- Zero-dependency Lua core
- Framework-independent architecture

## Why spatial hashing?

A naive interaction system can check every interaction every frame:

`players × interactions × frames`

This implementation divides the world into fixed-size cells and only evaluates
interactions inside the player's nearby cells.

That keeps the amount of work bounded as the interaction registry grows.

## Installation

Add the resource to your server:

```cfg
ensure aw-interaction-engine
```

## Example

```lua
exports['aw-interaction-engine']:AddInteraction({
    id = 'police_armory',
    coords = vector3(452.6, -980.0, 30.7),
    radius = 2.0,
    label = 'Open armory',
    groups = {
        police = 0
    },
    cooldown = 1000,

    onServer = function(source)
        print(('Player %s opened the armory'):format(source))
    end
})
```

## Design

The client is responsible for discovering nearby interactions and presenting
them to the player.

The server never trusts the client to decide whether an interaction is valid.
The server re-checks:

- interaction existence
- distance
- cooldown
- optional permission callback

This makes the system suitable as a foundation for larger FiveM resources.

## License

MIT
