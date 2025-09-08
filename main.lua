local suit = require 'suit'
-- local suit = nil

-- Game state variables
local gameState = "menu"
local player = {}
local enemies = {}
local bullets = {}
local score = 0
local gameTime = 0
local playerNameInput = nil

local settings = {}
local difficultyOptions = { "Easy", "Normal", "Hard" }
local currentDifficultIndex = 2

-- Screen dimensions (set in love.load)
local screenWidth, screenHeight

function love.load()
    -- Get screen dimensions
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Set up graphics
    love.graphics.setBackgroundColor( 0.1, 0.1, 0.15 ) -- dark blue-gray

    -- Initialize settings
    settings = {
        volume = 0.5,
        difficulty = "Normal",
        showFPS = true,
        playerName = "Player"
    }

    -- Initialize player
    player = {
        x = screenWidth / 2,
        y = screenHeight / 2,
        width = 32,
        height = 32,
        speed = 200,
        health = 100,
        maxHealth = 100
    }

    -- Initialize game systems
    initializeEnemies()
    initializeBullets()

    print( "Game loaded!" )
end

function love.update( dt )
    gameTime = gameTime + dt
    
    -- ADD THIS LINE for SUIT:
    if suit and suit.update then
        suit:update(dt)
    end

    if gameState == "playing" then
        updatePlayer( dt )
        updateEnemies( dt )
        updateBullets( dt )
        updateCollisions()

        -- Check game conditions
        if player.health <= 0 then
            gameState = "gameover"
        end

    elseif gameState == "menu" then
        -- add menu logic here
    elseif gameState == "paused" then
        -- add paused logic here
    elseif gameState == "gameover" then
        -- add game over logic here
    end
end

function love.draw()
    if gameState == "playing" then
        drawGame()
    elseif gameState == "menu" then
        drawMenu()
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

    love.graphics.setColor( 1, 1, 1 )
    love.graphics.print( "FPS: " .. love.timer.getFPS(), 10, 10 )
end

function drawGame()
    -- Draw game world
    drawPlayer()
    drawEnemies()
    drawBullets()
    drawUI()
end

function drawMenu()
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.printf( "TOP-DOWN SHOOTER", 0, screenHeight / 2 - 200, screenWidth, "center" )
    
    -- Simple test button
    if suit.Button( "START GAME", screenWidth / 2 - 75, screenHeight / 2 - 60, 150, 40 ).hit then
        gameState = "playing"
    end
    
    -- Fallback text (should always show)
    love.graphics.printf( "Click the button above or press SPACE", 0, screenHeight / 2, screenWidth, "center" )
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

function updatePlayer( dt )
    -- Movement input
    local dx, dy = 0, 0
    if love.keyboard.isDown( "w" ) or love.keyboard.isDown( "up" ) then
        dy = - 1
    end
    if love.keyboard.isDown( "s" ) or love.keyboard.isDown( "down" ) then
        dy = 1
    end
    if love.keyboard.isDown( "a" ) or love.keyboard.isDown( "left" ) then
        dx = - 1
    end
    if love.keyboard.isDown( "d" ) or love.keyboard.isDown( "right" ) then
        dx = 1
    end

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

function drawPlayer()
    love.graphics.setColor( 0.2, 0.8, 0.2 )
    love.graphics.rectangle( "fill", player.x - player.width / 2, player.y - player.height / 2, player.width, player.height )

    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.line( player.x, player.y, mouseX, mouseY )
end

function initializeEnemies()
    enemies = {}
    -- Enemy spawning will be added here
end

function updateEnemies( dt )
    -- Enemy AI and movement goes here
    for i = #enemies, 1, - 1 do
        local enemy = enemies[i]
        -- update enemy logic here
    end
end

function drawEnemies()
    love.graphics.setColor( 0.8, 0.2, 0.2 ) -- red
    for _, enemy in ipairs( enemies ) do
        love.graphics.rectangle( "fill", enemy.x - enemy.width / 2, enemy.y - enemy.height / 2, enemy.width, enemy.height )
    end
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
end

-- Collision detection
function updateCollisions()
    -- Bullet enemy collisions here
    -- Player enemy collisions here
end

-- UI functions
function drawUI()
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

-- Input handling
function love.keypressed( key )
    -- Let SUIT handle input first (if it exists and has the method)
    if suit and suit.keypressed then
        suit:keypressed( key )
    end
    
    -- Game controls (work with or without SUIT) - REMOVE the "and not suit" part
    if key == "space" and gameState == "menu" then  -- REMOVED: and not suit
        gameState = "playing"
    elseif key == "p" then
        if gameState == "playing" then
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "playing"
        end
    elseif key == "s" and ( gameState == "menu" or gameState == "paused" ) then  -- REMOVED: and not suit
        gameState = "settings"
    elseif key == "r" and gameState == "gameover" then  -- REMOVED: and not suit
        -- Restart game
        score = 0
        gameTime = 0
        player.health = player.maxHealth
        player.x = screenWidth / 2
        player.y = screenHeight / 2
        enemies = {}
        bullets = {}
        gameState = "playing"
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