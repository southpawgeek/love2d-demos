HoemHud = Class {}

function HoemHud:init(hoem)
    self.hoem = hoem
    self.xp = 0
    self.levelXpStart = 0
    self.levelXpNext = 10
    self.level = 1
end

function HoemHud:setXpProgress(xp, levelStart, levelNext, level)
    self.xp = xp or 0
    self.levelXpStart = levelStart or 0
    self.levelXpNext = levelNext or 10
    self.level = level or 1
end

function HoemHud:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(LOC.S_HP .. self.hoem.health, 0, 0)
    love.graphics.print(LOC.S_LVL .. (self.level or 1), 0, 10)

    -- XP bar across bottom of screen (full width, no numbers)
    local cfg = TUNING.xpBar or { height = 6, bg = { 0, 0, 0, 0.55 }, fill = { 0.2, 0.95, 0.35, 0.95 } }
    local h = cfg.height or 6
    local y = VIRTUAL_HEIGHT - h
    local w = VIRTUAL_WIDTH

    -- Background
    love.graphics.setColor(cfg.bg[1], cfg.bg[2], cfg.bg[3], cfg.bg[4] or 1)
    love.graphics.rectangle('fill', 0, y, w, h)

    -- Fill (progress toward next level)
    local progress = 0
    if self.levelXpNext and self.levelXpNext > self.levelXpStart then
        local range = self.levelXpNext - self.levelXpStart
        progress = math.max(0, math.min(1, (self.xp - self.levelXpStart) / range))
    end

    love.graphics.setColor(cfg.fill[1], cfg.fill[2], cfg.fill[3], cfg.fill[4] or 1)
    love.graphics.rectangle('fill', 0, y, w * progress, h)
end
