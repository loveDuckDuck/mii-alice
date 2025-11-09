local Player = GameObject:extend()           -- Extend the GameObject class
function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts) -- Call the parent constructor

    self.speed = opts.speed or 100           -- Set player speed
    self.sprite = opts.sprite or nil         -- Set player sprite

   self.iffy.newSprite("rogues","knight",0,0,32,32)
end

function Player:update(dt)
    Player.super.update(self, dt) -- Call the parent update method

    local moveX, moveY = 0, 0     -- Initialize movement variables

    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("d") then moveX = moveX + 1 end

    local length = math.sqrt(moveX * moveX + moveY * moveY)
    if length > 0 then
        moveX, moveY = moveX / length, moveY / length
    end

    self.x = self.x + moveX * self.speed * dt
    self.y = self.y + moveY * self.speed * dt
end

function Player:draw()
   self.iffy.drawSprite("knight",self.x, self.y)
end

return Player
