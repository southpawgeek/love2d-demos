TUNING = {}

-- XP required to reach each level.
-- Interpretation:
-- - Level 1 starts at 0 XP, next threshold is xpThresholds[1]
-- - Level 2 starts at xpThresholds[1], next threshold is xpThresholds[2], etc.
TUNING.xpThresholds = {
    10,  -- reach level 2
    25,  -- reach level 3
    50,  -- reach level 4
    100, -- reach level 5
    175,
    275,
    400
}

function TUNING:levelForXp(xp)
    local level = 1
    for i = 1, #self.xpThresholds do
        if xp >= self.xpThresholds[i] then
            level = i + 2 - 1 -- i thresholds crossed => level = i+1; written this way for clarity
        else
            break
        end
    end
    return level
end

function TUNING:xpWindowForLevel(level)
    -- Returns (startXp, nextXp). If nextXp is nil, treat as "maxed".
    if level <= 1 then
        return 0, self.xpThresholds[1]
    end
    local startXp = self.xpThresholds[level - 1]
    local nextXp = self.xpThresholds[level]
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
    bg = {0, 0, 0, 0.55},
    fill = {0.2, 0.95, 0.35, 0.95}
}

