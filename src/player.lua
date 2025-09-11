local Player = {}

local player = {
    x = 100, y = 100,
    width = 32, height = 32,
    health = 100,
    speed = 200,
}

function Player.initialize()
    -- Setup player
end

function Player.update( dt )
    -- Handle movement, input
    local dx, dy = getMovementInput()

    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt

    -- Check collisions with level
    Player.checkCollisions()

    -- Normalize diagonal movement (fixes diagonal speed boost using two keys at once)
    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707
        dy = dy * 0.707
    end

    -- Update player position
    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt

    -- Keep player on screen
    player.x = math.max( player.width / 2, math.min( screenWidth - player.width / 2, player.x ) )
    player.y = math.max( player.height / 2, math.min( screenHeight - player.height / 2, player.y ) )
end

function Player.draw()
    -- Render player
    love.graphics.setColor( 0.2, 0.8, 0.2 )
    love.graphics.rectangle( "fill", player.x - player.width / 2, player.y - player.height / 2, player.width, player.height )

    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.line( player.x, player.y, mouseX, mouseY )
end

function Player.getPosition()
    return player.x, player.y
end

function Player.checkCollisions()
    local Collision = require 'src.collision'
    Collision.checkPlayerWalls(player)

function getMovementInput()
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy = 1 end
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx = 1 end

    -- Diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx, dy = dx * 0.707, dy * 0.707
    end

    return dx, dy
end

return Player