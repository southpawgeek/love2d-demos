# Tower Get Resolution Change Implementation Plan

## Overview
Change virtual resolution from **512×288** to **360×180** for more aggressive pixel-art aesthetic while maintaining aspect ratio and using Push library's scaling.

---

## Current State Analysis

### Resolution Configuration (setup.lua)
- **Current Virtual Resolution:** 512 × 288 (16:9 aspect ratio)
- **Current Window Size:** 1024 × 576 (16:9 aspect ratio, exactly 2x virtual)
- **Target Virtual Resolution:** 360 × 180 (16:9 aspect ratio)
- **Recommended Window Size:** 720 × 405 or 720 × 400 (16:9 aspect ratio, ~2x virtual)

### Pixel Art Rendering Setup (main.lua)
✅ Already configured correctly:
```lua
love.graphics.setDefaultFilter('nearest', 'nearest')  -- Line 11
```

---

## Files Requiring Changes

### 1. `src/setup.lua` - Resolution Constants Only
**Lines to change:**
- Line 24: `WINDOW_WIDTH = 1024` → `WINDOW_WIDTH = 720` (or 864 for cleaner scaling)
- Line 25: `WINDOW_HEIGHT = 576` → `WINDOW_HEIGHT = 405` (or 400)
- Line 41: `VIRTUAL_WIDTH = 512` → `VIRTUAL_WIDTH = 360`
- Line 42: `VIRTUAL_HEIGHT = 288` → `VIRTUAL_HEIGHT = 180`

**Impact:** None - all other code uses these constants, which will automatically scale.

---

## Files Using VIRTUAL_WIDTH/VIRTUAL_HEIGHT (No Changes Required)

### ✅ Already Resolution-Agnostic Code:
All of the following correctly use VIRTUAL_WIDTH and VIRTUAL_HEIGHT as variables:

1. **main.lua** - Line 14: Push setup uses these constants
2. **Hoem.lua** - Lines 4-5: Core position at center (uses / 2)
3. **HoemHud.lua** - Lines 26-27: XP bar spans full width, positioned from bottom
4. **Mob.lua** - Lines 212-216: Spawn points random within virtual bounds
5. **Play.lua**:
   - Line 131: Pause text right-aligned using VIRTUAL_WIDTH
   - Lines 146-147: Block selector centered horizontally, positioned from bottom

---

## Detailed Change Summary

### File: `src/setup.lua`

```diff
-- Current values (lines 24-25):
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

-- NEW values (Option A - clean scaling):
+ WINDOW_WIDTH = 720
+ WINDOW_HEIGHT = 405

-- Current virtual resolution:
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- NEW virtual resolution:
+ VIRTUAL_WIDTH = 360
+ VIRTUAL_HEIGHT = 180
```

---

## Why No Other Changes Are Needed

### ✅ Aspect Ratio Preserved (16:9)
- Old: 512 ÷ 288 = 1.778... (16:9)
- New: 360 ÷ 180 = 2.0 (exactly 16:9)

### ✅ Push Library Handles Scaling Automatically
Push library manages all coordinate transformations between virtual and window space via `Push:toGame()` and internal scaling calculations.

### ✅ All Game Objects Use Virtual Coordinates
- Mob spawning uses `math.random(VIRTUAL_WIDTH)` and `VIRTUAL_HEIGHT`
- Core position is centered at `(VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT/2)`
- UI elements use these constants for positioning
- No hardcoded pixel values exist in game logic

### ⚠️ Considerations for Smaller Resolution:
1. **Block selector size:** 24px blocks may appear smaller - still readable
2. **Mob spawn area:** Smaller bounds mean mobs spawn closer together (more intense gameplay)
3. **Core position:** Still centered, but world is more compact

---

## Visual Impact Assessment

### What Changes:
- **Game world is much smaller:** More cramped gameplay, faster-paced
- **Much crisper pixel art:** Push's nearest-neighbor filter at lower resolution = chunkier pixels
- **Window appears smaller:** 720×405 window vs current 1024×576

### What Stays the Same:
- All game mechanics (mob speeds, collision detection, projectile behavior)
- UI layout proportions (block selector stays centered at bottom)
- Core position relative to screen center
- Aspect ratio and overall feel

---

## Testing Checklist After Changes

1. **Visual:** Game renders with chunky pixel-art style
2. **Window size:** Opens at 720×405 (or scaled proportionally on high-DPI displays)
3. **Core position:** Still centered in play area
4. **Mob spawning:** Mobs spawn closer together due to smaller bounds
5. **Block selector:** Still centered horizontally, positioned from bottom
6. **Pause text:** Right-aligned at top still works
7. **XP bar:** Full-width at bottom still visible
8. **Mouse input:** Click positions map correctly to game world

---

## Risk Assessment: LOW ✅

### Why This Is Safe:
1. Only 4 constant values change in one file
2. All other code uses these as variables (no hardcoded pixels)
3. Aspect ratio unchanged (16:9 → 16:9)
4. Push library designed for exactly this use case
5. No coordinate recalculations needed

### Potential Issues (None Expected):
- None identified - all game logic is resolution-agnostic by design

---

## Implementation Steps

1. **Edit `src/setup.lua`:**
   - Change WINDOW_WIDTH to 720
   - Change WINDOW_HEIGHT to 405
   - Change VIRTUAL_WIDTH to 360
   - Change VIRTUAL_HEIGHT to 180

2. **Run the game:**
   - Verify window opens at new size
   - Check all UI elements position correctly
   - Test gameplay (mob spawning, clicking, movement)

3. **If needed:** Adjust Push settings in main.lua line 14:
   ```lua
   Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
       fullscreen = false,
       resizable = true,
       vsync = true
   })
   ```

---

## Alternative Window Sizes (If 720×405 Doesn't Fit Your Display)

| Resolution | Scale Factor | Use Case |
|------------|--------------|----------|
| 720 × 405  | 2.0x         | Clean scaling, maintains exact ratio |
| 864 × 480  | 2.4x         | Larger window, still clean scaling |
| 1024 × 576 | ~2.84x       | Keep current window size |
| 1280 × 720 | ~3.55x       | Full HD displays |

---

## Conclusion

**This is a minimal, low-risk change with maximum benefit.** Only 4 lines in one file need modification. All game logic already uses virtual resolution constants correctly and will automatically adapt to the new values. The Push library handles all scaling calculations, so no coordinate adjustments are needed anywhere else.
