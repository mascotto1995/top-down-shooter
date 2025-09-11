local Enemies = {}
local EnemyData = require 'data.enemies'

function Enemies.update( dt )
    for i, enemy in ipairs(enemies) do
        Enemies.updateMovement(enemy, dt)
        Enemies.checkCollisions(enemy)
    end
end
    
function Enemies.updateMovement(enemy, dt)
    if enemy.behaivor == "player_found" then
        local Player = require 'src.player'
        local px, py = Player.getPosition()

        local dx = px - enemy.x
        local dy = py - enemy.y
        local distance = math.sqrt(dx*dx + dy*dy)

        if distance > 0 then
            enemy.x = enemy.x + (dx/distance) * enemy.speed + dt
            enemy.y = enemy.y + (dy/distance) * enemy.speed + dt
        end
    end
end

return Enemies
