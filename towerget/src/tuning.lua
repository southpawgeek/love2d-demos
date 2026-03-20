TUNING = {}

-- XP scaling: cumulative total XP to *enter* each level (geometric segment lengths).
-- XP to go from level L -> L+1 = BASE * GROWTH^(L-1)  (first step: 10, then 12.5, 15.625, ...)
-- Cumulative XP to enter level L (1-indexed): sum of segments for levels 1..L-1
--   = BASE * (GROWTH^(L-1) - 1) / (GROWTH - 1)
TUNING.xpBase = 10
TUNING.xpGrowth = 1.25

function TUNING:cumulativeXpToEnterLevel(level)
    if level <= 1 then return 0 end
    local b, g = self.xpBase, self.xpGrowth
    return b * (math.pow(g, level - 1) - 1) / (g - 1)
end

function TUNING:levelForXp(xp)
    if xp < 0 then return 1 end
    local level = 1
    while true do
        local nextThreshold = self:cumulativeXpToEnterLevel(level + 1)
        if xp < nextThreshold then return level end
        level = level + 1
        if level > 999 then return level end
    end
end

function TUNING:xpWindowForLevel(level)
    -- startXp = total XP at start of this level; nextXp = total XP needed to enter following level
    local startXp = self:cumulativeXpToEnterLevel(level)
    local nextXp = self:cumulativeXpToEnterLevel(level + 1)
    return startXp, nextXp
end

function TUNING:difficultyByLevel(level)
    -- Basic scaling knobs (tweak these in one place).
    -- Early waves should be less dense than the old defaults (mobSpawn=1, mobMax=5).
    local l = math.max(1, level)

    -- Spawn cadence: starts slower, ramps down.
    local mobSpawn = math.max(0.35, 1.6 - (l - 1) * 0.12)

    -- Max mobs per burst: starts small, ramps up.
    local mobMax = math.min(18, 2 + (l - 1))

    -- Global speed multiplier (applied to all mobs).
    local mobSpeedMul = 1 + (l - 1) * 0.10

    -- Intensity multiplier for special movement params (wobble/zig/bounce/orbit).
    local specialIntensityMul = 1 + (l - 1) * 0.08

    return {
        mobSpawn = mobSpawn,
        mobMax = mobMax,
        mobSpeedMul = mobSpeedMul,
        specialIntensityMul = specialIntensityMul
    }
end

TUNING.xpBar = {
    height = 6,
    bg = { 0, 0, 0, 0.55 },
    fill = { 0.2, 0.95, 0.35, 0.95 }
}

-- XP pickup SFX: many independent Sources so kills can overlap without one buffer stop/replay clicks.
TUNING.xpPickup = {
    poolCount = 14,  -- max overlapping pickup voices if onPoolExhausted = 'skip'
    volume = 0.28,   -- lower per voice so overlaps stay clean in the mix
    minInterval = 0, -- 0 = off; minimum seconds between any two pickup plays

    -- When every pool voice is already playing:
    -- 'skip' = do not play (hard cap concurrent = poolCount; no stop/restart spam)
    -- 'steal' = stop() next voice and replay (can sound harsh when overloaded)
    onPoolExhausted = 'skip',

    -- Max how many pickup sounds may *start* within any rolling 1-second window (0 = unlimited).
    -- Use with pool + skip to tame machine-gun kills without stealing voices.
    maxStartsPerSecond = 6,
}
