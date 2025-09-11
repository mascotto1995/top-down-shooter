local Collision = {}
local Level = require 'src.level'

-- Collision detection
function Collision.checkPlayerWalls(player)
    local tile_x = math.floor(player.x / TILE_SIZE)
    local tile_y = math.floor(player.y / TILE_SIZE)

    if Level.isWallAt(tile_x, tile_y) then
        -- Handle collision
        Collision.resolveWallCollision(player, tile_x, tile_y)
    end
end

function Collision.checkBulletEnemy(bullet, enemy)
    return bullet.x < enemy.x + enemy.width and
    enemy.x < bullet.x + bullet.width and
    bullet.y < enemy.y + bullet.height and
    enemy.y < bullet.y + bullet.height
end

function Collision.resolveWallCollision(entity, wall_x, wall_y)
    -- Push entity out of wall
    -- Implementation depends on collision system
end

Return Collision