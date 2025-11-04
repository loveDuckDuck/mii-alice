local generator = {}
local vector_dungeon_dimensions = { width = 7, height = 5 } -- max dimensions of the dungeon in vectors
local array_dungeon = {}                                    -- 2D array representing the dungeon layout
local start_position = Vector(3, 3)                         -- starting tile of the dungeon
local size_of_room = Vector(1024, 1024)                     -- size of each room in pixels
local rooms = {}
local branches_length = Vector(1, 4)                        -- min and max length of branches
local branch_candidates = {}                                -- positions where branches can start
local branches = 3



function generator.init(start_position, length, marker)
    start_position = start_position or Vector(3, 3)
    length = length or 13
    marker = marker or "C"
    generator.initialize_dungeon()
    generator.place_entrance()
    generator.generate_path(start_position, length, marker)
    generator.generate_branches()
    generator.generate_rooms()
end

function generator.initialize_dungeon()
    for x = 1, vector_dungeon_dimensions.width do
        array_dungeon[x] = {}
        for y = 1, vector_dungeon_dimensions.height do
            array_dungeon[x][y] = 0 -- Initialize each cell to 0
        end
    end
end

function generator.vector_random_position_to_start()
    return math.random(1, vector_dungeon_dimensions.width), math.random(1, vector_dungeon_dimensions.height)
end

function generator.place_entrance()
    if
        start_position.x < 0
        or start_position.x > vector_dungeon_dimensions.width
        or start_position.y < 0
        or start_position.y > vector_dungeon_dimensions.height
    then
        local x, y = generator.vector_random_position_to_start()
        start_position = Vector(x, y)
        array_dungeon[x][y] = "S"
    else
        array_dungeon[start_position.x][start_position.y] = "S"
    end
end

function generator.generate_path(start_position, length, marker)
    if length == 0 then
        return true
    end
    print("Generating path from: ", start_position.x, start_position.y, " with length ", length)
    local current = Vector(start_position.x, start_position.y)
    local direction
    local random_direction = math.random(0, 3)
    if random_direction == 0 then
        direction = Vector(1, 0)  -- right
    elseif random_direction == 1 then
        direction = Vector(-1, 0) -- left
    elseif random_direction == 2 then
        direction = Vector(0, 1)  -- down
    else
        direction = Vector(0, -1) -- up
    end
    print("Placing at: ", current.x, current.y)

    for _ = 1, 4, 1 do
        if
            current.x + direction.x >= 1
            and current.x + direction.x < vector_dungeon_dimensions.width
            and current.y + direction.y >= 1
            and current.y + direction.y < vector_dungeon_dimensions.height
            and array_dungeon[current.x + direction.x][current.y + direction.y] == 0
        then
            current = current + direction
            print("Placing at: ", current.x, current.y)
            array_dungeon[current.x][current.y] = marker
            if length > 2 then
                table.insert(branch_candidates, Vector(current.x, current.y))
            end
            if generator.generate_path(current, length - 1, marker) then
                return true
            else
                branch_candidates[#branch_candidates] = nil
                array_dungeon[current.x][current.y] = 0
                current = current - direction
            end
        end
        direction = Vector(direction.y, -direction.x)
    end
    return false
end

function generator.generate_branches()
    local branches_created = 0
    local candidate
    while branches_created < branches and (#branch_candidates > 0) do
        local random_position = love.math.random(1, #branch_candidates)
        candidate = branch_candidates[random_position]
        if generator.generate_path(candidate, love.math.random(branches_length.x, branches_length.y), branches_created + 1) then
            branches_created = branches_created + 1
        else
            table.remove(branch_candidates, random_position)
        end
    end
end

function generator.generate_rooms()
    for x = 1, vector_dungeon_dimensions.width do
        for y = 1, vector_dungeon_dimensions.height do
            if array_dungeon[x][y] ~= 0 then
                table.insert(
                    rooms,
                    {
                        tiles_position = { 1, 1, 1, 1, 1, 1 },
                        size = size_of_room,
                        id = array_dungeon[x][y],
                    }
                )
            end
        end
    end
end

--[[
    Print the dungeon layout to the console for debugging
]]
function generator.print_dungeon()
    for y = 1, vector_dungeon_dimensions.height do
        local row = ""
        for x = 1, vector_dungeon_dimensions.width do
            if array_dungeon[x][y] == 0 then
                row = row .. "[ ]"
            else
                row = row .. "[" .. array_dungeon[x][y] .. "]"
            end
        end
        print(row)
    end
end

return generator
