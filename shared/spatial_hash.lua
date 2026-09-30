SpatialHash = {}
SpatialHash.__index = SpatialHash

function SpatialHash:new(cellSize)
    return setmetatable({
        cellSize = cellSize,
        cells = {}
    }, self)
end

function SpatialHash:_key(coords)
    local x = math.floor(coords.x / self.cellSize)
    local y = math.floor(coords.y / self.cellSize)

    return x .. ':' .. y
end

function SpatialHash:insert(id, coords)
    local key = self:_key(coords)

    self.cells[key] = self.cells[key] or {}
    self.cells[key][id] = true
end

function SpatialHash:remove(id, coords)
    local key = self:_key(coords)
    local cell = self.cells[key]

    if not cell then
        return
    end

    cell[id] = nil

    if next(cell) == nil then
        self.cells[key] = nil
    end
end

function SpatialHash:query(coords, radius)
    local results = {}
    local minX = math.floor((coords.x - radius) / self.cellSize)
    local maxX = math.floor((coords.x + radius) / self.cellSize)
    local minY = math.floor((coords.y - radius) / self.cellSize)
    local maxY = math.floor((coords.y + radius) / self.cellSize)

    for x = minX, maxX do
        for y = minY, maxY do
            local cell = self.cells[x .. ':' .. y]

            if cell then
                for id in pairs(cell) do
                    results[#results + 1] = id
                end
            end
        end
    end

    return results
end

function SpatialHash:clear()
    self.cells = {}
end
