--[[
    Variables for the room generation
    TODO : define all the variables at the top of the file
   ]]
Vector = require("libraries/hump/vector")

local rooms = {}

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



function create_room()
    local floor_count = love.math.random(1, max_overlap_floors)
    local floors = {}
    for _ = 1, floor_count do
        table.insert(floors, create_floor_rect())
    end

    draw_floor(floors)
    fill_gap()
end

function create_floor_rect()
    local start_point_range = 5
    local startPoint = Vector(love.math.random(-start_point_range, start_point_range),
        love.math.random(-start_point_range, start_point_range))
    local width = love.math.random(min_floor_width, max_floor_width)
    local height = love.math.random(min_floor_height, max_floor_height)

    return { position = startPoint, size = Vector(width, height) }
end

function draw_floor(floors)
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

function fill_gap()
    local change_list = {}
    local rect = 
end
