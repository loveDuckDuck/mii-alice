local GameObject = Object:extend()                                    -- Extend the object

function GameObject:new(area, x, y, opts)                       -- Constructor function 🛠️
    local opts = opts or {}                                     -- Use opts or empty table
    if opts then for k, v in pairs(opts) do self[k] = v end end -- Copy options ✍️

    self.area = area                                            -- Set the area
    self.x, self.y = x, y                                       -- Set coordinates
    self.id = UUID()                                            -- Generate a unique id
    self.creation_time = love.timer.getTime()                   -- Get creation time ⏳
    self.timer = Timer()                                        -- Initialize the timer
    self.layer = 50                                             -- Depth to drawn, same idea of layer, so biggest is the layer more its infront
    self.dead = false                                           -- Not dead yet 😇
end

function GameObject:update(dt)                  
    if self.timer then self.timer:update(dt) end 
    if self.collider then self.x, self.y = self.collider:getPosition() end
end

function GameObject:draw() 
end

function GameObject:destroy()
    self.timer:destroy()
    if self.collider then self.collider:destroy() end
    self.collider = nil
--    table.clear(self)
end

return GameObject