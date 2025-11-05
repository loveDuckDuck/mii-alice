Vector = require("libraries/hump/vector")
Iffy = require("libraries/iffy/iffy")
Util = require("utils")
Generator = require("generator")
local ACTIVE_MAP = nil
function love.draw()
    Iffy.drawTilemap(ACTIVE_MAP, 'dice')
end

function love.keypressed(key, scancode, isrepeat)
    if key == "r" then
        Generator.init()
        Generator.print_dungeon()
        Iffy.newTilemap(Generator.csv_map_path)
        ACTIVE_MAP = Generator.csv_map_path:sub(1, -5) -- Remove .csv extension for Iffy
        ACTIVE_MAP = ACTIVE_MAP:gsub(".*/", "")        -- Extract just the filename without path
        os.remove(Generator.csv_map_path)
    end
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.load()
    math.randomseed(os.time())
    Generator.init()
    Generator.print_dungeon()
    Iffy.newTileset('dice', 'dice.png', 68, 68, 0, 0, 136, 204)
    print(":( Generator.csv_map_path: ", tostring(Generator.csv_map_path))

    Iffy.newTilemap(Generator.csv_map_path)
    ACTIVE_MAP = Generator.csv_map_path:sub(1, -5) -- Remove .csv extension for Iffy
    ACTIVE_MAP = ACTIVE_MAP:gsub(".*/", "")        -- Extract just the filename without path
    local exists, info = FileExists(Generator.csv_map_path)
    print("File exists:", tostring(exists), tostring(info))
    local succs, err  = os.remove(Generator.csv_map_path)
    if not succs then
        print("Error removing file:", err)
    end
end
