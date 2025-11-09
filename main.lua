Vector    = require("libraries/hump/vector")
Camera    = require("libraries/hump/camera")
Timer    = require("libraries/hump/timer")
Object = require("libraries/classic/classic")
Iffy      = require("libraries/iffy/iffy")
Util      = require("utils")
Generator = require("generator")
GameObject = require("GameObject")
Player   = require("Player")

local ACTIVE_MAP = nil
local text = ""
local previous_mx, previous_my = 0,0

function love.draw()
    GCamera:attach(0, 0, GW, GH)

    Iffy.drawTilemap(ACTIVE_MAP, 'tiles')
    Player:draw()
    GCamera:detach()

end

function love.wheelmoved(x, y)
    if y > 0 then
        text = "Mouse wheel moved up"
        GCamera.scale = GCamera.scale + 0.4
    elseif y < 0 then
        text = "Mouse wheel moved down"
        GCamera.scale = GCamera.scale - 0.4
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "r" then
        Generator.init()
        Generator.print_dungeon()
        local t = Iffy.newTilemap(Generator.csv_map_path)
        
        for key, value in pairs(t) do
            print("Tilemap key:", key, "value:", value)
            for k, v in pairs(value) do
                print("  Subkey:", k, "Subvalue:", v)
            end
        end
        
        ACTIVE_MAP = Generator.csv_map_path:sub(1, -5) -- Remove .csv extension for Iffy
        ACTIVE_MAP = ACTIVE_MAP:gsub(".*/", "")        -- Extract just the filename without path
        -- os.remove(Generator.csv_map_path)
    end
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.mouse.isDown(1) then
        local mx, my = GCamera:getMousePosition(SX, SY, 0, 0, SX * GW, SY * GH)
        local dx, dy = mx - previous_mx, my - previous_my
        print("Mouse position: ", mx, my)
        print("Dragging camera by: ", dx, dy)
        GCamera:move(-dx, -dy)
    end
        previous_mx, previous_my = GCamera:getMousePosition(SX, SY, 0, 0, SX * GW, SY * GH)

    
    Player:update(dt)
    GCamera:update(dt)
end

function love.load()
    math.randomseed(os.time())
    GCamera = Camera()
    Generator.init()
    Generator.print_dungeon()
    Iffy.newTileset('tiles', 'resources/tiles.png', 32, 32, 0, 0, 224, 832)
    print(":( Generator.csv_map_path: ", tostring(Generator.csv_map_path))
    Iffy.newImage("resources/rogues.png")
    Player = Player(nil, 100, 100, {iffy =  Iffy, speed = 200})

    Iffy.newTilemap(Generator.csv_map_path)
    ACTIVE_MAP = Generator.csv_map_path:sub(1, -5) -- Remove .csv extension for Iffy
    ACTIVE_MAP = ACTIVE_MAP:gsub(".*/", "")        -- Extract just the filename without path
    local exists, info = FileExists(Generator.csv_map_path)
    print("File exists:", tostring(exists), tostring(info))
    local succs, err = os.remove(Generator.csv_map_path)
    if not succs then
        print("Error removing file:", err)
    end
end
