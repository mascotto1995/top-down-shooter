return {
    -- Level scaling
    scaling = {
        enemy_health_per_level = 0.15, -- 15% increase per level
        enemy_damage_per_level = 0.1, -- 10% increase per level
        item_rarity_bonus_per_level = 0.02 -- 2% better drops per level
    },
    
    -- Room templates
    room_types = {
        spawn = {
            min_size = {width = 15, height = 15}, -- Grid tiles, not pixels
            max_size = {width = 25, height = 20},
            enemy_count = {min = 3, max = 8}
        }
    }
}

function generateRoom(width, height)
    local room = {
        x = 0, y = 0, -- Top left corner
        width = width,
        height = height,
        tiles = {}
    }

    -- Create 2D tile grid
    for x = 1, width do
        room.tiles[x] = {}
        for y = 1, height do
            room.tiles[x][y] = "floor" -- or "wall", "door", etc.
        end
    end
    
    return room
end