local lfs = require("lfs")

local SUBFOLDER_NAME = "csv_random_maps"



local generator = {
    csv_map_path = io.popen "cd":read '*l'

}

local vector_dungeon_dimensions = { width = 7, height = 5 } -- max dimensions of the dungeon in vectors
local array_dungeon = {}                                    -- 2D array representing the dungeon layout
local start_position = Vector(3, 3)                         -- starting tile of the dungeon
local size_of_room = Vector(3, 3)                           -- size of each room in pixels
local rooms = {}
local branches_length = Vector(1, 1)                        -- min and max length of branches
local branch_candidates = {}                                -- positions where branches can start
local branches = 3



local min_floor_width = 2
local max_floor_width = 5
local min_floor_height = 2
local max_floor_height = 5
local max_overlap_floors = 10
local fill_gap_size = 4

local floor_layer = {}
local wall_layer = {}

local directions = {
    Vector(1, 0),  -- right
    Vector(-1, 0), -- left
    Vector(0, 1),  -- down
    Vector(0, -1), -- up
}

local floor_tiles = { "F" }
-- need to make a one one correspondence between wall tiles and floor tiles
local wall_tiles = { "WL", "WR", "WT", "WB", "WBL", "WBR", "WTL", "WTR", "WI" }



function generator.create_room()
    local floor_count = love.math.random(1, max_overlap_floors)
    local floors = {}
    for _ = 1, floor_count do
        table.insert(floors, generator.create_floor_rect())
    end

    generator.draw_floor(floors)
    generator.fill_gap()
end

function generator.create_floor_rect()
    local start_point_range = 5
    local startPoint = Vector(love.math.random(-start_point_range, start_point_range),
        love.math.random(-start_point_range, start_point_range))
    local width = love.math.random(min_floor_width, max_floor_width)
    local height = love.math.random(min_floor_height, max_floor_height)

    return { position = startPoint, size = Vector(width, height) }
end

function generator.draw_floor(floors)
    for _, value in ipairs(floors) do
        local startPoint = value.position
        local size = value.size
        for x = 1, size.x do
            for y = 1, size.y do
                table.insert(floor_layer,
                    {
                        position = Vector(startPoint.x + x, startPoint.y + y),
                        value = 0,
                        tile = floor_tiles[1]

                    })
            end
        end
    end
end

function generator.fill_gap()
    local change_list = {}
end

function generator.init(start_position, length, dungeon_width, dungeon_height, room_width, room_height,
                        branches_length_min, branches_length_max, marker)
    start_position = start_position or Vector(3, 3)
    length = length or 13
    marker = marker or "C"
    size_of_room.x = room_width or size_of_room.x
    size_of_room.y = room_height or size_of_room.y
    branches_length.x = branches_length_min or branches_length.x
    branches_length.y = branches_length_max or branches_length.y
    vector_dungeon_dimensions.width = dungeon_width or vector_dungeon_dimensions.width
    vector_dungeon_dimensions.height = dungeon_height or vector_dungeon_dimensions.height

    generator.initialize_dungeon()
    generator.place_entrance()
    generator.generate_path(start_position, length, marker)
    generator.generate_branches()
    generator.generate_rooms()
    -- generator.create_room()
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
    if start_position.x < 0
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

    for _ = 1, 4, 1 do
        if
            current.x + direction.x >= 1
            and current.x + direction.x < vector_dungeon_dimensions.width
            and current.y + direction.y >= 1
            and current.y + direction.y < vector_dungeon_dimensions.height
            and array_dungeon[current.x + direction.x][current.y + direction.y] == 0
        then
            current = current + direction
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

--[[ Function to write content to a file in a specified subdirectory.
    -- 1. Check if the subfolder exists and create it if it doesn't
    -- lfs.attributes returns nil if the path does not exist.
        -- Directory does not exist, attempt to create it
            -- If mkdir fails (e.g., due to permission issues), stop execution.
    -- 2. Construct the full file path (using '/' for cross-platform compatibility)
    -- 3. Open the file in write mode ("w")

]]
function generator.write_to_file(subfolder, filename, content)
    if lfs.attributes(subfolder) == nil then
        if lfs.mkdir(subfolder) then
            print("Created required output directory: " .. subfolder)
        else
            io.stderr:write("Error: Could not create directory " .. subfolder .. ". Check permissions.\n")
            return
        end
    end

    local full_filepath = subfolder .. "/" .. filename

    local file, err = io.open(full_filepath, "w")

    if file then
        -- Successfully opened or created the file
        file:write(content)
        file:close()
        print("Successfully wrote content to: " .. full_filepath)
    else
        -- Failed to open the file
        io.stderr:write("Error writing file " .. full_filepath .. ": " .. err .. "\n")
    end
end

function generator.generate_rooms()
    local csvLines = {}

    for y = 1, vector_dungeon_dimensions.height do
        for y_csv = 1, size_of_room.y do
            local line = ""
            for x = 1, vector_dungeon_dimensions.width do
                for x_csv = 1, size_of_room.x do
                    if array_dungeon[x][y] == 0 then
                        line = line .. "0,"
                    else
                        line = line .. "1,"
                    end
                end
            end

            -- Remove the trailing comma from the end of the line
            if #line > 0 then
                line = string.sub(line, 1, #line - 1)
            end

            -- Insert the complete line into the table, followed by a newline
            table.insert(csvLines, line)
        end
    end

    local filename = UUID() .. ".csv"
    local csvData = table.concat(csvLines, "\n")
    generator.write_to_file(SUBFOLDER_NAME, filename, csvData)
    generator.csv_map_path = SUBFOLDER_NAME .. "/" .. filename
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
