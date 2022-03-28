Ability.Fireball = {}
AbilityIndex[FourCC("AHf1")] = Ability.Fireball

local DUMMY_SPELL   = FourCC("ADfb")
local DAMAGE        = {100, 175, 250, 325}
local MISSILE       = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
local SPEED         = 1200
local RADIUS        = 100
local Z             = 75

function Ability.Fireball.spellEffect()
    local caster    = GetTriggerUnit()
    local player    = GetOwningPlayer(caster)
    local ability   = GetSpellAbility()
    local level     = GetUnitAbilityLevel(caster, GetSpellAbilityId())
    local x, y      = GetUnitX(caster), GetUnitY(caster)
    local tx, ty    = GetSpellTargetX(), GetSpellTargetY()
    local damage    = DAMAGE[level]
    local range     = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, level - 1)

    local angle     = math.atan(ty - y, tx - x)
    local cos, sin  = math.cos(angle), math.sin(angle)
    local nx, ny    = x + cos * range, y + sin * range
    
    local projectile = createProjectileToXY(MISSILE, x, y, Z, SPEED, nil, nx, ny, Z)
    BlzSetSpecialEffectScale(projectile.missile, 1.2)
    addProjectileUnitImpact(projectile, RADIUS, function(target)
        if IsUnitAliveBJ(target)
        and IsUnitEnemy(target, player) then
            local xt, yt = GetWidgetX(target), GetWidgetY(target)
            local dummy = CreateUnit(player, FourCC('dumm'), xt, yt, 0)
            UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
            UnitAddAbility(dummy, DUMMY_SPELL)
            SetUnitAbilityLevel(dummy, DUMMY_SPELL, level)
            IssueTargetOrder(dummy, "cripple", target)
            UnitDamageTarget(caster, target, damage, false, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE, WEAPON_TYPE_WHOKNOWS)
            destroyProjectile(projectile)
        end
    end)
end