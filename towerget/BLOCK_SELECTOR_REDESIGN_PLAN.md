# Block Selector Redesign Implementation Plan

## Overview
Move block type selector from horizontal bottom display to vertical left-side display, starting just under the HP/XP HUD.

---

## Current State Analysis

### Current Layout (Play.lua:renderBlockSelector)
- **Position:** Bottom of screen (y = VIRTUAL_HEIGHT - 60)
- **Orientation:** Horizontal row of blocks
- **Sizing:** 
  - Block size: 24px × 24px
  - Padding between blocks: 8px
  - Total width: (#variants × 32) - 8 = (3 × 32) - 8 = 88px

### Current Code Location
**File:** `screens/Play.lua`  
**Function:** `renderBlockSelector()` (lines 142-166)

---

## New Layout Design

### Vertical Left-Side Display
```
┌─────────────────────────────┐
│ HP: 25                       │ ← Top-left corner
│ LV: 1                        │
├─────────────────────────────┤
│ [Basic] [Medium] [Large]     │ ← New vertical selector (left side)
│   ↓      ↓      ↓            │
└─────────────────────────────┘
```

### Proposed Positioning
- **X position:** Left-aligned at x = 10px from left edge
- **Y position:** Starts at y = 25px (just under HP/XP text)
- **Orientation:** Vertical column of blocks
- **Sizing:** Same as current (24×24 blocks, 8px padding)

### New Layout Dimensions
- Total height: (#variants × 32) - 8 = (3 × 32) - 8 = 88px
- Total width: Block size + padding = 24 + 8 = 32px

---

## Files Requiring Changes

### 1. `screens/Play.lua` - Update renderBlockSelector() function

**Current implementation (lines 142-166):**
```lua
function Play:renderBlockSelector()
    local blockSize = 24
    local padding = 8
    local totalWidth = (#self.variantNames * (blockSize + padding)) - padding
    local startX = (VIRTUAL_WIDTH - totalWidth) / 2
    local bottomY = VIRTUAL_HEIGHT - 60
    
    for i, variantName in ipairs(self.variantNames) do
        local variant = BlockTypes[string.lower(variantName)]
        local x = startX + (i - 1) * (blockSize + padding)
        local y = bottomY
        
        -- Draw block representation
        love.graphics.setColor(variant.color[1], variant.color[2], variant.color[3], variant.color[4])
        love.graphics.rectangle('fill', x, y, variant.size, variant.size)
        
        -- Draw selection indicator (outline)
        if self.selectedBlockVariantIndex == i then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle('line', x, y, variant.size, variant.size)
            love.graphics.setLineWidth(1)
        end
    end
end
```

**New implementation:**
```lua
function Play:renderBlockSelector()
    local blockSize = 24
    local padding = 8
    local totalHeight = (#self.variantNames * (blockSize + padding)) - padding
    
    -- Position at left side, just under HP/XP display
    local leftX = 10
    local topY = 25
    
    for i, variantName in ipairs(self.variantNames) do
        local variant = BlockTypes[string.lower(variantName)]
        local x = leftX
        local y = topY + (i - 1) * (blockSize + padding)
        
        -- Draw block representation
        love.graphics.setColor(variant.color[1], variant.color[2], variant.color[3], variant.color[4])
        love.graphics.rectangle('fill', x, y, variant.size, variant.size)
        
        -- Draw selection indicator (outline)
        if self.selectedBlockVariantIndex == i then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle('line', x, y, variant.size, variant.size)
            love.graphics.setLineWidth(1)
        end
    end
end
```

---

## Visual Impact Assessment

### What Changes:
- **Selector position:** Moves from bottom-right to left side (under HP/XP)
- **Orientation:** Horizontal row → Vertical column
- **Space freed up:** Bottom of screen now has more room for gameplay

### What Stays the Same:
- Block sizes and colors
- Selection highlight style (orange outline)
- Mouse wheel / keyboard controls for selection cycling
- Variant names array order (Basic, Medium, Large)

---

## Implementation Steps

1. **Edit `screens/Play.lua`:**
   - Modify `renderBlockSelector()` function
   - Change from horizontal layout to vertical layout
   - Update positioning variables:
     - Remove: `startX`, `bottomY` calculations
     - Add: `leftX = 10`, `topY = 25`
   - Swap x/y increment logic in loop

2. **Test the changes:**
   - Verify selector appears at correct position
   - Check all three variants display correctly
   - Test mouse wheel selection cycling (should still work)
   - Test keyboard arrow/a/d controls (should still work)
   - Ensure no overlap with other UI elements

---

## Alternative Positioning Options

| Option | X Position | Y Position | Notes |
|--------|-----------|------------|-------|
| Left-aligned (recommended) | 10px | 25px | Just under HP/XP, clean look |
| Centered left | VIRTUAL_WIDTH/4 - 16 | 25px | More centered on screen |
| Far left edge | 0px | 30px |紧贴左边缘 |
| Floating | VIRTUAL_WIDTH/2 - 16 | 100px | Centered, floating below HUD |

---

## Mouse Interaction Considerations

### Current Behavior:
- Mouse clicks anywhere in game area spawn blocks
- Block selector is at bottom (may interfere with spawning)

### New Behavior:
- Selector occupies left side of screen
- **Consideration:** Should we exclude the selector area from block spawning?
- **Recommendation:** Add a small margin to prevent accidental selection when clicking near edge

---

## Testing Checklist After Changes

1. ✅ Block selector appears at left side, under HP/XP
2. ✅ All three variants (Basic, Medium, Large) display correctly
3. ✅ Selected variant has orange outline highlight
4. ✅ Mouse wheel cycles through variants (up/down)
5. ✅ Left/right arrow keys cycle variants
6. ✅ A/D keys cycle variants  
7. ✅ Clicking game area still spawns blocks correctly
8. ✅ No visual overlap with other UI elements

---

## Risk Assessment: LOW ✅

### Why This Is Safe:
1. Only one function modified (`renderBlockSelector`)
2. Same drawing logic, just different positioning math
3. All variant data and selection state unchanged
4. Mouse/keyboard controls remain the same
5. No game mechanics affected - purely visual/layout change

### Potential Issues (None Expected):
- None identified - straightforward layout modification

---

## Conclusion

**This is a minimal, low-risk change.** Only one function in `Play.lua` needs modification. The selector will move from bottom-right to left side, freeing up screen space while maintaining all existing functionality.

Ready for implementation approval.
