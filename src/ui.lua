local UI = {}

local ui = {}

function UI.draw()
    -- Health bar background
    love.graphics.setColor( 0.3, 0.3, 0.3 )
    love.graphics.rectangle( "fill", 20, screenHeight - 50, 200, 25 )

    -- Health bar fill
    love.graphics.setColor( 0.8, 0.2, 0.2 )
    love.graphics.rectangle( "fill", 20, screenHeight - 40, 200, 20 )
    love.graphics.setColor( 0.2, 0.8, 0.2 )
    local healthPercent = player.health / player.maxHealth
    love.graphics.rectangle( "fill", 20, screenHeight - 40, 200 * healthPercent, 20 )

    -- Health bar border
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.rectangle( "line", 20, screenHeight - 50, 200, 25 )

    -- Health text
    love.graphics.print( "Health " .. math.floor( player.health ) .. "/" .. player.maxHealth, 25, screenHeight - 48 )

    -- Score and player info
    love.graphics.print( "Score: " .. score, screenWidth - 120, 10 )
    love.graphics.print( "Player: " .. settings.playerName, screenWidth - 120, 30 )
    love.graphics.print( "Time: " .. math.floor( gameTime ) .. "s", screenWidth - 120, 50 )
    love.graphics.print( "Difficulty: " .. settings.difficulty, screenWidth - 120, 70 )
end

return UI