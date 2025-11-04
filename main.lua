Vector = require("libraries/hump/vector")
Iffy = require("libraries/iffy/iffy")
Generator = require("generator")

-- function love.draw()
--     for _, room in ipairs(rooms) do
--         for key, value in pairs(room.tiles_position) do
--             Iffy.drawSprite("dice1", (value - 1) * size_of_room.x, (value - 1) * size_of_room.y)
--         end
--     end
-- end

function love.load()
    math.randomseed(os.time())


    Generator.init(Vector(3, 3), 7, "C")
    Generator.print_dungeon()
    Iffy.newTileset("dice.png")
    Iffy.newSprite("dice", "dice6", 0, 0, 68, 68)
    Iffy.newSprite("dice", "dice5", 0, 68, 68, 68)
    Iffy.newSprite("dice", "dice1", 0, 136, 68, 68)

    Iffy.newSprite("dice", "dice3", 68, 0, 68, 68)
    Iffy.newSprite("dice", "dice2", 68, 68, 68, 68)
    Iffy.newSprite("dice", "dice4", 68, 136, 68, 68)
end
