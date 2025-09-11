local Player = require 'src.player'
local Enemies = require 'src.enemies'
local Level = require 'src.level'
local UI = require 'src.ui'
local Audio = require 'src.audio'

local gameState = "menu"
local currentLevel = 1

function love.load()
    Audio.initialize()
    Player.initialize()
    Level.generate( currentLevel )
    UI.initialize()
end

function love.update( dt )
    if gameState == "playing" then
        Player.update( dt )
        Enemies.update( dt )
        Level.update( dt )
    elseif gameState == "menu" then
        UI.updateMenu( dt )
    end
end

function love.draw()
    if gameState == "playing" then
        Level.draw()
        Player.draw()
        Enemies.draw()
        UI.draw()
    elseif gameState == "menu" then
        UI.drawMenu()
    end
end

local suit = require 'suit'

function love.draw()
    if gameState == "playing" then
        drawGame()
    elseif gameState == "menu" then
        drawMenu()
    elseif gameState == "settings" then
        drawSettings()
    elseif gameState == "paused" then
        drawGame() -- draw game behind pause menu
        drawPauseMenu()
    elseif gameState == "gameover" then
        drawGameOver()
    end

    -- ADD THIS LINE for SUIT (before FPS counter):
    if suit and suit.draw then
        suit:draw()
    end

    if settings.showFPS then
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.print( "FPS: " .. love.timer.getFPS(), 10, 10 )
    end
end

function drawGame()
    -- Draw game world
    drawPlayer()
    drawEnemies()
    drawBullets()
    drawUI()
end

function updateVolume()
    if not sounds then return end

    local masterVolume = settings.volume

    -- Update shoot sounds
    for i = 1, #sounds.shoot do
        sounds.shoot[i]:setVolume( 0.3 * masterVolume )
    end

    sounds.enemyHit:setVolume( 0.4 * masterVolume )
    sounds.enemyDeath:setVolume( 0.5 * masterVolume )
    sounds.playerHurt:setVolume( 0.6 * masterVolume )
    sounds.background:setVolume( 0.2 * masterVolume )
end

function drawSettings()
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.printf( "SETTINGS", 0, 50, screenWidth, "center" )
    
    local startY = 120
    local spacing = 60
    
    -- Volume control with buttons
    love.graphics.print( "Volume: " .. math.floor( settings.volume * 100 ) .. "%", screenWidth / 2 - 100, startY )
    if suit.Button( "-", { id = "volDown" }, screenWidth / 2 - 100, startY + 25, 30, 30 ).hit then
        settings.volume = math.max( 0, settings.volume - 0.1 )
        updateVolume()
    end
    if suit.Button( "+", { id = "volUp" }, screenWidth / 2 - 60, startY + 25, 30, 30 ).hit then
        settings.volume = math.min( 1, settings.volume + 0.1 )
        updateVolume()
    end
    
    -- Rest of settings...
    
    -- Back button
    if suit.Button( "BACK TO MENU", { id = "backBtn" }, screenWidth / 2 - 75, startY + spacing * 3 + 40, 150, 40 ).hit then
        gameState = "menu"
    end
end

function drawMenu()
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.printf( "TOP-DOWN SHOOTER", 0, screenHeight / 2 - 100, screenWidth, "center" )

    -- test button
    if suit.Button( "START GAME", screenWidth / 2 - 75, screenHeight / 2 - 80, 150, 40 ).hit then
        gameState = "playing"
    end

    -- Settings button
    if suit.Button( "SETTINGS", screenWidth / 2 - 75, screenHeight / 2 - 30, 150, 40 ).hit then
        gameState = "settings"
    end

    if suit.Button( "QUIT", screenWidth / 2 - 75, screenHeight / 2 + 20, 150, 40 ).hit then
        love.event.quit()
    end

    love.graphics.printf( "WASD to move, Mouse to aim/shoot", 0, screenHeight / 2 + 120, screenWidth, "center" )
end

function drawPauseMenu()
    -- Semi-transparent overlay
    love.graphics.setColor( 0, 0, 0, 0.5 )
    love.graphics.rectangle( "fill", 0, 0, screenWidth, screenHeight )

    love.graphics.setColor( 1, 1, 1 )
    love.graphics.printf( "PAUSED", 0, screenHeight / 2 - 50, screenWidth, "center" )
    love.graphics.printf( "Press P to resume", 0, screenHeight / 2, screenWidth, "center" )
end

function drawGameOver()
    love.graphics.setColor( 1, 0.2, 0.2 )
    love.graphics.printf( "GAME OVER", 0, screenHeight / 2 - 100, screenWidth, "center" )
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.printf( "Score: " .. score, 0, screenHeight / 2 - 50, screenWidth, "center" )
    love.graphics.printf( "Press R to restart", 0, screenHeight / 2, screenWidth, "center" )
end

function initializeEnemies()
    enemies = {}
    enemySpawnTimer = 0
    enemySpawnRate = 2.0
    -- Enemy spawning will be added here
end


function drawEnemies()
    love.graphics.setColor( 0.8, 0.2, 0.2 ) -- red
    for _, enemy in ipairs( enemies ) do
        love.graphics.rectangle( "fill", enemy.x - enemy.width / 2, enemy.y - enemy.height / 2, enemy.width, enemy.height )

        -- Draw health bar for enemies with more than 1 HP
        if enemy.maxHealth > 1 then
            local barWidth = enemy.width
            local barHeight = 4
            local barX = enemy.x - barWidth / 2
            local barY = enemy.y - enemy.height / 2 - 8

            -- Background
            love.graphics.setColor( 0.3, 0.3, 0.3 )
            love.graphics.rectangle( "fill", barX, barY, barWidth, barHeight )

            -- Health
            love.graphics.setColor( 0.8, 0.2, 0.2 )
            local healthPercent = enemy.health / enemy.maxHealth
            love.graphics.rectangle( "fill", barX, barY, barWidth * healthPercent, barHeight )

            -- Reset color for next enemy
            love.graphics.setColor( 0.8, 0.2, 0.2 )
        end
    end
end

function spawnEnemy()
    local enemy = {
        width = 24,
        height = 24,
        speed = getEnemySpeed(),
        health = getEnemyHealth(),
        maxHealth = getEnemyHealth()
    }
    
    -- Spawn enemy off-screen in a random direction
    local side = math.random( 1, 4 )
    if side == 1 then -- Top
        enemy.x = math.random( 0, screenWidth )
        enemy.y = - enemy.height
    elseif side == 2 then -- Right
        enemy.x = screenWidth + enemy.width
        enemy.y = math.random( 0, screenHeight )
    elseif side == 3 then -- Bottom
        enemy.x = math.random( 0, screenWidth )
        enemy.y = screenHeight + enemy.height
    else -- Left
        enemy.x = - enemy.width
        enemy.y = math.random( 0, screenHeight )
    end
    
    table.insert( enemies, enemy )
end

function getEnemySpawnRate()
    -- Spawn rate gets faster over time and with difficulty
    local baseRate = 2.0
    local timeMultiplier = math.max( 0.3, 1.0 - ( gameTime * 0.02 ) ) -- Gets faster over time
    local difficultyMultiplier = 1.0
    
    if settings.difficulty == "Easy" then
        difficultyMultiplier = 1.5
    elseif settings.difficulty == "Hard" then
        difficultyMultiplier = 0.6
    end
    
    return baseRate * timeMultiplier * difficultyMultiplier
end

function getEnemySpeed()
    local baseSpeed = 80
    if settings.difficulty == "Easy" then
        return baseSpeed * 0.7
    elseif settings.difficulty == "Hard" then
        return baseSpeed * 1.4
    end
    return baseSpeed
end

function getEnemyHealth()
    local baseHealth = 1
    if settings.difficulty == "Easy" then
        return baseHealth
    elseif settings.difficulty == "Hard" then
        return baseHealth * 2
    end
    return baseHealth
end

-- Bullet functionality
function initializeBullets()
    bullets = {}
end

function updateBullets( dt )
    for i = #bullets, 1, - 1 do
        local bullet = bullets[i]

        -- Move bullet
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt

        -- Remove bullets off screen
        if bullet.x < 0 or bullet.x > screenWidth or bullet.y < 0 or bullet.y > screenHeight then
            table.remove( bullets, i )
        end
    end
end

function drawBullets()
    love.graphics.setColor( 1, 1, 0.2 ) -- yellow
    for _, bullet in ipairs( bullets ) do
        love.graphics.circle( "fill", bullet.x, bullet.y, bullet.radius )
    end
end

function createBullet( x, y, targetX, targetY )
    -- Calculate direction vector
    local dx = targetX - x
    local dy = targetY - y
    local length = math.sqrt( dx * dx + dy * dy )

    -- Normalize and set speed
    local speed = 400
    local vx = ( dx / length ) * speed
    local vy = ( dy / length ) * speed

    table.insert( bullets, {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        radius = 3
    } )

    -- Play 9MM pistol sound
    love.audio.play( sounds.shoot[sounds.shootIndex] )
    sounds.shootIndex = sounds.shootIndex + 1
    if sounds.shootIndex > #sounds.shoot then
        sounds.shootIndex = 1
    end
end

-- Input handling
function love.keypressed( key )
    -- Let SUIT handle input first (safely)
    if suit and suit.keypressed then
        suit:keypressed( key )
    end
    
    -- Add SPACE key support
    if key == "space" and gameState == "menu" then
        gameState = "playing"
    elseif key == "p" then
        if gameState == "playing" then
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "playing"
        end
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed( x, y, button )
    -- Let SUIT handle mouse input first (safely)
    if suit and suit.mousepressed then
        suit:mousepressed( x, y, button )
    end

    if button == 1 and gameState == "playing" then
        createBullet( player.x, player.y, x, y )
    end
end

function love.mousereleased( x, y, button )
    if suit and suit.mousereleased then
        suit:mousereleased( x, y, button )
    end
end

function love.textinput( t )
    if suit and suit.textinput then
        suit:textinput( t )
    end
end