--[[
================================================================================
    BSMod Custom KillMove Template
    
    This template works with BOTH:
    - Original BSMod (Workshop)
    - BSMod Extended (Fork with extra features)
    
    IMPORTANT: Change "YourKillmoveName" in ALL hooks to something unique!
    Example: "NecksnapKillmove", "KnifeExecutions", "ZombieTakedowns"
    
    Having duplicate hook names WILL cause conflicts with other addons!
================================================================================
]]

--[[
================================================================================
    CONFIGURATION
    Edit these values to customize your killmove
================================================================================
]]

-- Your unique addon name (CHANGE THIS!)
local ADDON_NAME = "YourKillmoveName"

-- Model paths (change to your compiled models)
local PLAYER_MODEL = "models/weapons/c_limbs_template.mdl"
local TARGET_MODEL = "models/bsmodimations_zombie_template.mdl"

-- Animation name (must match the $sequence name in your .qc file)
local ANIM_NAME = "killmove_example"

-- Which direction triggers this killmove? ("front", "back", "left", "right", or "any")
local TRIGGER_DIRECTION = "back"

-- Random chance (1-100). Set to 100 for always, lower to let other killmoves trigger too
local TRIGGER_CHANCE = 100

-- Sound to play (set to nil for no sound, or use built-in sounds like "player/killmove/km_hit")
local CUSTOM_SOUND = nil  -- Example: "mysound.wav" (place in sound/ folder)
local SOUND_DELAY = 0.5   -- Seconds to wait before playing sound

-- Player position offset from target (tweak these to align your animation)
local POSITION_OFFSET = 0  -- Distance in front/behind target (negative = behind)

--[[
================================================================================
    OPTIONAL: ConVar for chance slider in menu
    Uncomment this section if you want players to adjust the chance in-game
================================================================================
]]

--[[
CreateConVar("bsmod_yourkillmove_chance", "4", FCVAR_ARCHIVE + FCVAR_REPLICATED, 
    "Killmove chance (1=0%, 2=25%, 3=50%, 4=100%)", 1, 4)

local chanceTable = {
    [1] = 0,
    [2] = 25,
    [3] = 50,
    [4] = 100,
}
]]

--[[
================================================================================
    SERVER-SIDE CODE
    This is where the killmove logic runs
================================================================================
]]

if SERVER then
    
    -- Add your files for multiplayer (clients will download these)
    -- Uncomment and edit these with your actual file paths:
    --[[
    resource.AddFile("models/weapons/c_limbs_yourmodel.mdl")
    resource.AddFile("models/weapons/c_limbs_yourmodel.dx80.vtx")
    resource.AddFile("models/weapons/c_limbs_yourmodel.dx90.vtx")
    resource.AddFile("models/weapons/c_limbs_yourmodel.vvd")
    resource.AddFile("models/bsmodimations_yourmodel.mdl")
    resource.AddFile("models/bsmodimations_yourmodel.dx80.vtx")
    resource.AddFile("models/bsmodimations_yourmodel.dx90.vtx")
    resource.AddFile("models/bsmodimations_yourmodel.vvd")
    resource.AddFile("sound/yoursound.ogg")
    ]]
    
    --[[
        MAIN KILLMOVE HOOK
        This function decides when your killmove should trigger
        
        Parameters:
        - ply: The player doing the killmove
        - target: The NPC/player being killed
        - angleAround: Angle from 0-360 showing where player is relative to target
            * 0 or 360 = directly in front
            * 90 = to the left
            * 180 = directly behind
            * 270 = to the right
    ]]
    
    hook.Add("CustomKillMoves", ADDON_NAME, function(ply, target, angleAround)
        
        -- Setup killmove data table
        local plyKMModel = nil
        local targetKMModel = nil
        local animName = nil
        local plyKMPosition = nil
        local plyKMAngle = nil
        local kmData = {nil, nil, nil, nil, nil}
        
        ------------------------------------------------------------------------
        -- STEP 1: Check random chance
        ------------------------------------------------------------------------
        
        -- If using ConVar chance slider, uncomment this:
        --[[
        local cv = GetConVar("bsmod_yourkillmove_chance")
        if cv then
            local chanceSetting = cv:GetInt()
            local chancePercent = chanceTable[chanceSetting] or 100
            if chancePercent == 0 then return end
            if chancePercent < 100 and math.random(1, 100) > chancePercent then return end
        end
        ]]
        
        -- Simple random chance (comment out if using ConVar above)
        if TRIGGER_CHANCE < 100 and math.random(1, 100) > TRIGGER_CHANCE then 
            return 
        end
        
        ------------------------------------------------------------------------
        -- STEP 2: Check direction
        -- This determines which angle the player must be at to trigger
        ------------------------------------------------------------------------
        
        local directionMatch = false
        
        if TRIGGER_DIRECTION == "any" then
            directionMatch = true
            
        elseif TRIGGER_DIRECTION == "front" then
            -- Player is in front of target (0-45 or 315-360 degrees)
            directionMatch = (angleAround <= 45 or angleAround > 315)
            
        elseif TRIGGER_DIRECTION == "left" then
            -- Player is to the left of target (45-135 degrees)
            directionMatch = (angleAround > 45 and angleAround <= 135)
            
        elseif TRIGGER_DIRECTION == "back" then
            -- Player is behind target (135-225 degrees)
            directionMatch = (angleAround > 135 and angleAround <= 225)
            
        elseif TRIGGER_DIRECTION == "right" then
            -- Player is to the right of target (225-315 degrees)
            directionMatch = (angleAround > 225 and angleAround <= 315)
        end
        
        if not directionMatch then return end
        
        ------------------------------------------------------------------------
        -- STEP 3: Check target requirements
        ------------------------------------------------------------------------
        
        -- Must be on ground (comment out if you want air killmoves)
        if not ply:OnGround() then return end
        
        -- Target must have humanoid skeleton (ValveBiped)
        -- Comment this out if your killmove works on non-humanoid targets
        if not target:LookupBone("ValveBiped.Bip01_Spine") then return end
        
        -- Optional: Only trigger on specific NPC types
        -- Uncomment and edit as needed:
        --[[
        local targetClass = target:GetClass()
        if targetClass ~= "npc_citizen" and targetClass ~= "npc_combine_s" then
            return
        end
        ]]
        
        ------------------------------------------------------------------------
        -- STEP 4: Set up the killmove
        ------------------------------------------------------------------------
        
        plyKMModel = PLAYER_MODEL
        targetKMModel = TARGET_MODEL
        animName = ANIM_NAME
        
        -- Position player relative to target
        local targetPos = target:GetPos()
        local targetForward = target:GetForward()
        
        if TRIGGER_DIRECTION == "back" then
            plyKMPosition = targetPos + (-targetForward * POSITION_OFFSET)
            plyKMAngle = targetForward:Angle()  -- Face same direction as target
        elseif TRIGGER_DIRECTION == "front" then
            plyKMPosition = targetPos + (targetForward * POSITION_OFFSET)
            -- plyKMAngle = nil  -- Let base mod calculate angle (face target)
        else
            plyKMPosition = targetPos + (targetForward * POSITION_OFFSET)
        end
        
        ------------------------------------------------------------------------
        -- STEP 5: Return the killmove data
        ------------------------------------------------------------------------
        
        kmData[1] = plyKMModel      -- Player animation model
        kmData[2] = targetKMModel   -- Target animation model
        kmData[3] = animName        -- Animation sequence name
        kmData[4] = plyKMPosition   -- Where to position player (or nil for default)
        kmData[5] = plyKMAngle      -- Player angle (or nil for default)
        -- kmData[6] = plyKMTime    -- Optional: custom animation duration
        -- kmData[7] = targetKMTime -- Optional: custom target animation duration
        -- kmData[8] = moveTarget   -- Optional: true to move target instead of player
        
        return kmData
    end)
    
    --[[
        SOUND AND EFFECTS HOOK
        Add sounds and visual effects to your animation
    ]]
    
    hook.Add("CustomKMEffects", ADDON_NAME, function(ply, animName, targetModel)
        -- Only run for our animation
        if animName ~= ANIM_NAME then return end
        if not IsValid(targetModel) then return end
        
        -- Play custom sound with delay
        if CUSTOM_SOUND then
            timer.Simple(SOUND_DELAY, function()
                if not IsValid(ply) then return end
                ply:EmitSound(CUSTOM_SOUND, 75, 100, 1.0)
            end)
        end
        
        -- Example: Play built-in hit sound at 0.5 seconds
        --[[
        timer.Simple(0.5, function()
            if not IsValid(targetModel) then return end
            PlayRandomSound(ply, 1, 5, "player/killmove/km_hit")
        end)
        ]]
        
        -- Example: Blood effect at target's head
        --[[
        timer.Simple(0.8, function()
            if not IsValid(targetModel) then return end
            local headBone = targetModel:GetHeadBone()
            if headBone then
                local effectdata = EffectData()
                effectdata:SetOrigin(targetModel:GetBonePosition(headBone))
                util.Effect("BloodImpact", effectdata)
            end
        end)
        ]]
    end)
    
end  -- End SERVER block

--[[
================================================================================
    RAGDOLL PHYSICS HOOK
    Control how the body falls after the killmove
    This runs on BOTH server and client (for clientside ragdolls)
================================================================================
]]

hook.Add("KMRagdoll", ADDON_NAME, function(entity, ragdoll, animName)
    -- Only run for our animation
    if animName ~= ANIM_NAME then return end
    if not IsValid(ragdoll) then return end
    
    -- Get spine bone for direction reference
    local spinePos, spineAng = nil, nil
    if ragdoll:LookupBone("ValveBiped.Bip01_Spine") then
        spinePos, spineAng = ragdoll:GetBonePosition(ragdoll:LookupBone("ValveBiped.Bip01_Spine"))
    end
    
    -- Apply physics to all bones
    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
        local bone = ragdoll:GetPhysicsObjectNum(i)
        if bone and bone:IsValid() then
            
            -- Simple collapse (body falls down)
            bone:SetVelocity(Vector(0, 0, -50))
            
            -- Example: Push ragdoll backward
            -- if spineAng then
            --     bone:SetVelocity(-spineAng:Up() * 100)
            -- end
            
            -- Example: Make ragdoll spin
            -- bone:SetAngleVelocity(Vector(0, 0, 500))
            
        end
    end
end)

--[[
================================================================================
    OPTIONAL: CLIENT MENU
    Adds a settings tab in Options > BSMod
    Uncomment this section if you added the ConVar above
================================================================================
]]

--[[
if CLIENT then
    local function YourKillmoveOptions(Panel)
        Panel:ClearControls()
        Panel:Help("Your Killmove Settings")
        Panel:Help("")
        
        local chanceLabels = {
            [1] = "0% (Disabled)",
            [2] = "25%",
            [3] = "50%",
            [4] = "100% (Always)",
        }
        
        local slider = Panel:NumSlider("Killmove Chance", "bsmod_yourkillmove_chance", 1, 4, 0)
        
        local oldThink = slider.Think
        slider.Think = function(self)
            if oldThink then oldThink(self) end
            local val = math.Round(self:GetValue())
            self.Label:SetText("Chance: " .. (chanceLabels[val] or "100%"))
        end
        
        Panel:Help("")
        Panel:Help("Description of your killmove here.")
    end
    
    hook.Add("PopulateToolMenu", ADDON_NAME .. "Menu", function()
        spawnmenu.AddToolMenuOption("Options", "BSMod", ADDON_NAME, "Your Killmove", "", "", YourKillmoveOptions)
    end)
end
]]

--[[
================================================================================
    BSMOD EXTENDED ONLY FEATURES
    
    These features ONLY work with BSMod Extended (the fork), not original BSMod.
    The killmove will still work with original BSMod, but these extra checks
    will be skipped.
    
    Available variables (only in Extended):
    - ply.bsmod_km_position_type: "ground_front", "air_back", "water_left", etc.
    - ply.bsmod_km_direction: "front", "back", "left", "right"
    - ply.bsmod_km_in_water: true if player is in water
    - ply.bsmod_km_in_air: true if player is in air
    - ply.bsmod_km_cover_state: "none", "cover", or "dfb"
    - ply.bsmod_km_target_type: "zombie", "combine", "player", etc.
    - ply.bsmod_km_target_crouching: true if target is crouching
    - ply.bsmod_km_player_weapon_type: "unarmed", "melee", "pistol", "rifle"
    
    Example usage in CustomKillMoves hook:
    
    -- Check if Extended is available
    if ply.bsmod_km_position_type then
        -- Extended features available!
        
        -- Water killmove
        if ply.bsmod_km_position_type == "water_back" then
            animName = "killmove_water_stealth"
        end
        
        -- Cover takedown
        if ply.bsmod_km_cover_state == "cover" then
            animName = "killmove_cover_pull"
        end
        
        -- Weapon-specific
        if ply.bsmod_km_player_weapon_type == "melee" then
            animName = "killmove_knife_execute"
        end
    end
================================================================================
]]
