local levels = require 'levels'
local enemies_data = require 'enemies'

local RoomManager = {}

-- Room manager state
local currentRoom = nil
local roomGrid = {}
local playerRoomX, playerRoomY = 0, 0
local roomTransitioning = false
local transitionTimer = 0
local transitionDuration = 0.5

-- Constants
local TILE_SIZE = 32 -- Size of each tile in pixels
local WALL_THICKNESS = 32
local DOOR_WIDTH = 64

function RoomManager.initialize()
    roomGrid = {}
    playerRoomX, playerRoomY = 0, 0

    -- Generate starting room
    currentRoom = RoomManager.generateRoom( 0, 0, "spawn" )
    roomGrid[0] = {}
    roomGrid[0][0] = currentRoom

    -- Generate adjecent rooms
    RoomManager.generateAdjacentRooms( 0, 0 )

    print( "Room system initialized. Starting room size:" currentRoom.width, "x", currentRoom.height )
end

function RoomManager.generateRoom( gridX, gridY, roomType )
    roomType = roomType or "normal"
    local template = levels.room_types.spawn -- Using spawn template for now

    -- Random room dimensions within template bounds
    local width = math.random( template.min_size.width, template.max_size.width )
    local height = math.random( template.min_size.height, template.max_size.height )

    local room = {
        gridX = gridX,
        gridY = gridY,
        y = 0,
        y = 0,
        width = width,
        height = height,
        pixelWidth = width * TILE_SIZE,
        pixelHeight = height * TILE_SIZE,
        tiles = {},
        walls = {},
        doors = {},
        enemies = {},
        items = {},
        cleared = false,
        roomType = roomType
    }

    -- Generate tile grid
    RoomManager.generateTiles( room )

    -- Generate walls and doors
    RoomManager.generateWalls( room )

    -- Spawn enemies
    RoomManager.spawnRoomEnemies( room, template )

    return room
end

function RoomManager.generateTiles( room )
    room.tiles = {}
    for x = 1, room.width do
        room.tiles[x] = {}
        for y = 1, room.height do
            -- Simple room generation - mostly floor with wall borders
            if x == 1 or x == room.width or y == 1 or y == room.height then
                room.tiles[x][y] = "wall"
            else
                room.tiles[x][y] = "floor"
            end
        end
    end
end

function RoomManager.generateWalls( room )
    room.walls = {}
    room.doors = {}

    -- Create wall rectangles for collision
    -- Top wall
    table.insert( room.walls, {
        x = 0, y = - WALL_THICKNESS,
        width = room.pixelWidth, height = WALL_THICKNESS
    } )

    -- Bottom wall
    table.insert( room.walls, {
        x = 0, y = room.pixelHeight,
        width = room.pixelWidth, height = WALL_THICKNESS
    } )

    -- Left wall
    table.insert( room.walls, {
        x = - WALL_THICKNESS, y = 0,
        width = WALL_THICKNESS, height = room.pixelHeight
    } )

    -- Right wall
    table.insert( room.walls. {
        x = room.pixelWidth, y = 0,
        width = WALL_THICKNESS, height = room.pixelHeight
    } )

    -- Create doors (gaps in walls)
    local doorY = room.pixelHeight / 2 - DOOR_WIDTH / 2
    local doorX = room.pixelWidth / 2 - DOOR_WIDTH / 2

    -- North door
    table.insert( room.doors, {
        x = doorX, y = - WALL_THICKNESS,
        width = DOOR_WIDTH, height = WALL_THICKNESS,
        direction = "north",
        targetX = doorX + DOOR_WIDTH / 2,
        targetY = room.pixelHeight - 50 -- Spawn point when entering from south
    } )

    -- South door
    table.insert( room.doors, {
        x = doorX, y = room.pixelHeight,
        width = DOOR_WIDTH, height = WALL_THICKNESS,
        direction = "south",
        targetX = doorX + DOOR_WIDTH / 2,
        targetY = 50 -- Spawn point when entering from the north
    } )

    -- East door
    table.insert( room.doors, {
        x = room.pixelWidth, y = doorY,
        width = WALL_THICKNESS, height = DOOR_WIDTH,
        direction = "east",
        targetX = 50, -- Spawn point when entering from west
        targetY = doorY + DOOR_WIDTH / 2
    } )

    table.insert( room.doors, {
        x = - WALL_THICKNESS, y = doorY,
        width = WALL_THICKNESS, height = DOOR_WIDTH,
        direction = "west",
        targetX = room.pixelWidth - 50, -- Spawn point when entering from east
        targetY = door + DOOR_WIDTH / 2
    } )
end

function RoomManager.spawnRoomEnemies(room, template)
    if room.roomType == "spawn" then
        return -- No enemies in spawn room
    end

    local enemyCount = math.room(template.enemy_count.min, template.enemy_count.max)

    for i = 1, enemy_count do
        local enemyType = math.random() > 0.7 and "brute" or "grunt"
        local enemyTemplate = enemies_data[enemyType]
        local enemy = {
            type = enemyType,
            x = math.random(100, room.pixelWidth - 100),
            y = math.random(100, room.pixelHeight - 100),
            width = enemyTemplate.width,
            height = enemyTemplate.height,
            speed = enemyTemplate.speed,
            health = enemyTemplate.health,
            maxHealth = enemyTemplate.health,
            damage = enemyTemplate.damage,
            points = enemyTemplate.points
        }

        table.insert(room.enemies, enemy)
    end
end
