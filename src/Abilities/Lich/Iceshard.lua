Ability.Iceshard = {}
AbilityIndex[FourCC("AHis")] = Ability.Iceshard

local ABILITYID     = FourCC("AHis")
local RELEASEID     = FourCC("AHrs")
local DUMMY_SPELL   = FourCC("ADis")
local MISSILE       = "Abilities\\Spells\\Other\\FrostBolt\\FrostBoltMissile.mdl"
local SPEED         = 500
local Z             = 75
local INSTANCE      = {}

function Ability.Iceshard.spellEffect()
    local caster    = GetTriggerUnit()
    local player    = GetOwningPlayer(caster)
    local ability   = GetSpellAbility()
    local level     = GetUnitAbilityLevel(caster, GetSpellAbilityId())
    local x, y      = GetUnitX(caster), GetUnitY(caster)
    local tx, ty    = GetSpellTargetX(), GetSpellTargetY()
    local range     = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, level - 1)
    local instance  = {}
    instance.level  = level
    
    local angle     = math.atan(ty - y, tx - x)
    local cos, sin  = math.cos(angle), math.sin(angle)
    local nx, ny    = x + cos * range, y + sin * range
    
    BlzUnitHideAbility(caster, ABILITYID, true)
    UnitAddAbility(caster, RELEASEID)
    
    local projectile    = createProjectileToXY(MISSILE, x, y, Z, SPEED, nil, nx, ny, Z, function()
        x               = BlzGetLocalSpecialEffectX(instance.projectile.missile)
        y               = BlzGetLocalSpecialEffectY(instance.projectile.missile)
        UnitRemoveAbility(caster, RELEASEID)
        BlzUnitHideAbility(caster, ABILITYID, false)
    
        angle           = math.random(0, math.rad(90))
        for i = 1, 4, 1 do
            cos, sin    = math.cos(angle), math.sin(angle)
            nx, ny      = x + cos * 100, y + sin * 100
            local dummy = CreateUnit(player, DUMMY, x, y, 0)
            UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
            UnitAddAbility(dummy, DUMMY_SPELL)
            SetUnitAbilityLevel(dummy, DUMMY_SPELL, instance.level)
            IssuePointOrder(dummy, 'breathoffrost', nx, ny)
            
            angle = angle + math.pi / 2
        end
    
        INSTANCE[caster] = nil
    end)

    instance.projectile = projectile
    INSTANCE[caster] = instance
end


Ability.Releaseshard = {}
AbilityIndex[FourCC("AHrs")] = Ability.Releaseshard

function Ability.Releaseshard.spellEffect()
    local caster    = GetTriggerUnit()
    local player    = GetOwningPlayer(caster)
    local instance  = INSTANCE[caster]
    local x         = BlzGetLocalSpecialEffectX(instance.projectile.missile)
    local y         = BlzGetLocalSpecialEffectY(instance.projectile.missile)
    destroyProjectile(instance.projectile)
    UnitRemoveAbility(caster, RELEASEID)
    BlzUnitHideAbility(caster, ABILITYID, false)

    local angle     = math.random(0, math.rad(90))
    for i = 1, 4, 1 do
        local cos, sin  = math.cos(angle), math.sin(angle)
        local nx, ny    = x + cos * 100, y + sin * 100
        local dummy     = CreateUnit(player, DUMMY, x, y, 0)
        UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
        UnitAddAbility(dummy, DUMMY_SPELL)
        SetUnitAbilityLevel(dummy, DUMMY_SPELL, instance.level)
        IssuePointOrder(dummy, 'breathoffrost', nx, ny)
        
        angle = angle + math.rad(90)
    end

    INSTANCE[caster] = nil
end