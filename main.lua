local suit = require 'suit'
-- local suit = nil

-- Game state variables
local gameState = "menu"
local player = {}
local enemies = {}
local bullets = {}
local score = 0
local gameTime = 0
local enemySpawnTimer = 0
local enemySpawnRate = 2.0
-- local playerNameInput = nil

local settings = {}
local difficultyOptions = { "Easy", "Normal", "Hard" }
local currentDifficultIndex = 2

-- Screen dimensions (set in love.load)
local screenWidth, screenHeight

function love.load()
    sounds = {}
    images = {}

    -- Create multiple shoot sound sources for rapid fire
    sounds.shoot = {}
    for i = 1, 5 do -- Create 5 copies
        sounds.shoot[i] = love.audio.newSource( "assets/sounds/9mm-pistol.mp3", "static" )
        sounds.shoot[i]:setVolume( 0.3 )
    end
    sounds.shootIndex = 1 -- Track which one to use next

    -- Load sound effects
    sounds.enemyHit = love.audio.newSource( "assets/sounds/enemy-hit.mp3", "static" )
    sounds.enemyDeath = love.audio.newSource( "assets/sounds/enemy-hit.mp3", "static" )
    sounds.playerHurt = love.audio.newSource( "assets/sounds/player-hurt.mp3", "static" )
    sounds.background = love.audio.newSource( "assets/sounds/night-drive.mp3", "static" )

    -- Set volumes
    sounds.enemyHit:setVolume( 0.4 )
    sounds.enemyDeath:setVolume( 0.5 )
    sounds.playerHurt:setVolume( 0.6 )
    sounds.background:setVolume( 0.2 )
    sounds.background:setLooping( true )

    -- Load images

    -- Start background music
    love.audio.play( sounds.background )

    print( "Assets loaded!" )

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

    print( "Suit loaded:", suit ~= nil )
    if suit then
        print( "SUIT has update:", suit.update ~= nil )
        print( "SUIT has draw:", suit.draw ~= nil )
        print( "SUIT has Button:", suit.Button ~= nil )
    end
end

function love.update( dt )
    gameTime = gameTime + dt

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
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SETTINGS", 0, 50, screenWidth, "center")
    
    local startY = 120
    local spacing = 60
    
    -- Volume control with buttons
    love.graphics.print("Volume: " .. math.floor(settings.volume * 100) .. "%", screenWidth/2 - 100, startY)
    if suit.Button("-", {id = "volDown"}, screenWidth/2 - 100, startY + 25, 30, 30).hit then
        settings.volume = math.max(0, settings.volume - 0.1)
        updateVolume()
    end
    if suit.Button("+", {id = "volUp"}, screenWidth/2 - 60, startY + 25, 30, 30).hit then
        settings.volume = math.min(1, settings.volume + 0.1)
        updateVolume()
    end
    
    -- Rest of settings...
    
    -- Back button
    if suit.Button("BACK TO MENU", {id = "backBtn"}, screenWidth/2 - 75, startY + spacing * 3 + 40, 150, 40).hit then
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
    enemySpawnTimer = 0
    enemySpawnRate = 2.0
    -- Enemy spawning will be added here
end

function updateEnemies( dt )
    -- Spawn enemies based on difficulty
    enemySpawnTimer = enemySpawnTimer + dt
    local spawnRate = getEnemySpawnRate()
    
    if enemySpawnTimer >= spawnRate then
        spawnEnemy()
        enemySpawnTimer = 0
    end
    
    -- Update existing enemies
    for i = #enemies, 1, - 1 do
        local enemy = enemies[i]
        
        -- Move enemy toward player
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        local distance = math.sqrt( dx * dx + dy * dy )
        
        if distance > 0 then
            -- Normalize direction and apply speed
            local moveX = ( dx / distance ) * enemy.speed * dt
            local moveY = ( dy / distance ) * enemy.speed * dt
            
            enemy.x = enemy.x + moveX
            enemy.y = enemy.y + moveY
        end
        
        -- Remove enemies that are too far off screen (cleanup)
        if enemy.x < - 100 or enemy.x > screenWidth + 100 or 
           enemy.y < - 100 or enemy.y > screenHeight + 100 then
            table.remove( enemies, i )
        end
    end
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

-- check collision helper function
function checkCollision( x1, y1, w1, h1, x2, y2, w2, h2 )
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1

end

-- Collision detection
function updateCollisions()
    -- Bullet enemy collisions
    for i = #bullets, 1, - 1 do
        local bullet = bullets[i]
        for j = #enemies, 1, - 1 do
            local enemy = enemies[j]

            -- check if bullet hits enemy
            if checkCollision( bullet.x, bullet.y, bullet.radius * 2, bullet.radius * 2, enemy.x - enemy.width / 2, enemy.y - enemy.height / 2, enemy.width, enemy.height ) then

                -- Damage enemy
                enemy.health = enemy.health - 1

                -- Remove bullet after collision
                table.remove( bullets, i )

                -- Remove enemy if dead
                if enemy.health <= 0 then
                    table.remove( enemies, j )
                    score = score + 10 -- points for killing enemy

                    -- Play death sound
                    love.audio.play( sounds.enemyDeath )
                else
                    -- Play hit sound
                    love.audio.play( sounds.enemyHit )
                end

                break -- bullets only hit one enemy
            end
        end
    end

    -- Enemy player collisions
    for i = #enemies, 1, - 1 do
        local enemy = enemies[i]

        if checkCollision( player.x - player.width / 2, player.y - player.height / 2, player.width, player.height, enemy.x - enemy.width / 2, enemy.y - enemy.height / 2, enemy.width, enemy.height ) then

            -- Damage player
            player.health = player.health - 10

            -- Play hurt sound
            love.audio.play( sounds.playerHurt )

            -- Remove enemy
            table.remove( enemies, i )
        end
    end
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