# BSMod Custom KillMove Template

A template for creating custom killmove animations for BSMod.

**Works with both:**
- ✅ Original BSMod (Workshop)
- ✅ BSMod Extended (Fork with extra features)

---

## Quick Start

1. Copy the `Addon/BSMod Custom KillMove Template` folder
2. Rename it to your addon name (e.g., "My Awesome Killmoves")
3. Edit `addon.json` with your addon info
4. Edit `lua/autorun/bsmod_customkillmove.lua`:
   - Change `ADDON_NAME` to something unique
   - Set your model paths
   - Set your animation name
   - Configure direction and chance
5. Create your animations in Blender
6. Compile models with Crowbar
7. Test and upload to Workshop!

---

## Configuration (Top of Lua File)

```lua
-- Your unique addon name (CHANGE THIS!)
local ADDON_NAME = "YourKillmoveName"

-- Model paths
local PLAYER_MODEL = "models/weapons/c_limbs_yourmodel.mdl"
local TARGET_MODEL = "models/bsmodimations_yourmodel.mdl"

-- Animation name (must match $sequence in your .qc file)
local ANIM_NAME = "killmove_example"

-- Direction: "front", "back", "left", "right", or "any"
local TRIGGER_DIRECTION = "back"

-- Chance (1-100, lower = other killmoves can trigger too)
local TRIGGER_CHANCE = 100

-- Custom sound (or nil for no sound)
local CUSTOM_SOUND = "mysound.ogg"
local SOUND_DELAY = 0.5
```

---

## Direction Reference

The `angleAround` parameter tells you where the player is relative to the target:

```
           0° (front)
              ↑
    315° ←  TARGET  → 45°
              ↓
          180° (back)

Front: 315-360° or 0-45°
Left:  45-135°
Back:  135-225°
Right: 225-315°
```

---

## Built-in Sounds

These sounds are included with BSMod and can be used without adding files:

```
player/killmove/km_hit1.wav - km_hit5.wav      (impact sounds)
player/killmove/km_bonebreak1.wav - 3.wav     (bone breaking)
player/killmove/km_gorehit1.wav - 2.wav       (gore impact)
player/killmove/km_grapple1.wav               (grab sound)
player/killmove/km_punch1.wav                 (punch)
player/killmove/km_slash1.wav - 3.wav         (slash)
player/killmove/km_stabin1.wav - 3.wav        (stab in)
player/killmove/km_stabout1.wav - 2.wav       (stab out)
player/fists/fists_crackl.wav                 (crack sound)
player/fists/fists_hit01.wav - 03.wav         (fist hits)
```

Use with: `PlayRandomSound(ply, 1, 5, "player/killmove/km_hit")`

---

## BSMod Extended Features

These features **only work with BSMod Extended**, but your killmove will still work with original BSMod (these checks are just skipped).

### Position Types (18 total)
- Ground: `ground_front`, `ground_back`, `ground_left`, `ground_right`
- Air (DFA): `air_front`, `air_back`, `air_left`, `air_right`
- Water: `water_front`, `water_back`, `water_left`, `water_right`
- Cover: `cover_front`, `cover_back`
- DFB: `dfb_front`, `dfb_back`

### Available Variables
```lua
ply.bsmod_km_position_type      -- "ground_front", "water_back", etc.
ply.bsmod_km_direction          -- "front", "back", "left", "right"
ply.bsmod_km_in_water           -- true/false
ply.bsmod_km_in_air             -- true/false
ply.bsmod_km_cover_state        -- "none", "cover", "dfb"
ply.bsmod_km_target_type        -- "zombie", "combine", "player", etc.
ply.bsmod_km_target_crouching   -- true/false
ply.bsmod_km_player_weapon_type -- "unarmed", "melee", "pistol", "rifle"
```

### Example: Extended-Only Features
```lua
hook.Add("CustomKillMoves", "MyKillmove", function(ply, target, angleAround)
    -- ... basic setup ...
    
    -- Check if Extended is available
    if ply.bsmod_km_position_type then
        -- Water stealth takedown
        if ply.bsmod_km_position_type == "water_back" then
            animName = "killmove_water_stealth"
        end
        
        -- Cover takedown (through window)
        if ply.bsmod_km_cover_state == "cover" then
            animName = "killmove_cover_pull"
        end
        
        -- Knife execution
        if ply.bsmod_km_player_weapon_type == "melee" then
            animName = "killmove_knife"
        end
    end
    
    -- ... return kmData ...
end)
```

---

## Hooks Reference

### CustomKillMoves (Main Hook)
```lua
hook.Add("CustomKillMoves", "YourName", function(ply, target, angleAround)
    local kmData = {
        [1] = plyKMModel,      -- Player animation model path
        [2] = targetKMModel,   -- Target animation model path
        [3] = animName,        -- Animation sequence name
        [4] = plyKMPosition,   -- Player position (Vector or nil)
        [5] = plyKMAngle,      -- Player angle (Angle or nil)
        [6] = plyKMTime,       -- Optional: animation duration override
        [7] = targetKMTime,    -- Optional: target animation duration
        [8] = moveTarget,      -- Optional: true to move target instead
    }
    return kmData
end)
```

### CustomKMEffects (Sounds & Effects)
```lua
hook.Add("CustomKMEffects", "YourName", function(ply, animName, targetModel)
    if animName ~= "your_anim" then return end
    
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        ply:EmitSound("yoursound.ogg", 75, 100, 1.0)
    end)
end)
```

### KMRagdoll (Ragdoll Physics)
```lua
hook.Add("KMRagdoll", "YourName", function(entity, ragdoll, animName)
    if animName ~= "your_anim" then return end
    
    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
        local bone = ragdoll:GetPhysicsObjectNum(i)
        if bone and bone:IsValid() then
            bone:SetVelocity(Vector(0, 0, -50))
        end
    end
end)
```

### BSMod_KillMoveStarted / BSMod_KillMoveEnded (Extended Only)
```lua
hook.Add("BSMod_KillMoveStarted", "YourName", function(ply, target, animName, positionType)
    -- Killmove just started
end)

hook.Add("BSMod_KillMoveEnded", "YourName", function(ply, target, positionType)
    -- Killmove just ended
end)
```

---

## Tools Required

### Blender (for animations)
**Blender 4.2 LTS** recommended: https://www.blender.org/download/lts/4-2/

**Blender Source Tools** (SourceIO): https://github.com/REDxEYE/SourceIO

### Crowbar (for compiling)
https://steamcommunity.com/groups/CrowbarTool

### Workshop Upload
https://wiki.facepunch.com/gmod/Workshop_Addon_Creation

---

## Folder Structure

```
Your Addon/
├── addon.json
├── lua/
│   └── autorun/
│       └── bsmod_yourkillmove.lua
├── models/
│   ├── weapons/
│   │   └── c_limbs_yourmodel.mdl (+ .vtx, .vvd)
│   └── bsmodimations_yourmodel.mdl (+ .vtx, .vvd)
└── sound/
    └── yoursound.ogg
```

---

## Tips

- **Always change `ADDON_NAME`** to something unique to avoid conflicts
- **Add random chance** if you want other killmove packs to also trigger
- **Test with `bsmod_killmove_disable_defaults 1`** to only see your killmoves
- **Remove sound events from .qc files** to avoid unwanted sounds baked into animations
- **Use `resource.AddFile()`** for multiplayer compatibility

---

## Troubleshooting

**Killmove doesn't trigger:**
- Check that `TRIGGER_DIRECTION` matches where you're standing
- Make sure target has `ValveBiped.Bip01_Spine` bone (or remove that check)
- Check console for Lua errors

**Animation doesn't play:**
- Verify `ANIM_NAME` matches the `$sequence` name in your .qc exactly
- Make sure model files are in the correct paths

**Unwanted sounds playing:**
- Check your .qc file for `event AE_CL_PLAYSOUND` or similar lines
- Remove them and recompile the model

**Multiplayer issues:**
- Add all model/sound files with `resource.AddFile()`
