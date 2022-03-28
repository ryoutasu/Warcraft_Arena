Ability.ShadowBolt = {}
AbilityIndex[FourCC("AHsb")]    = Ability.ShadowBolt

local DUMMY_SPELL               = FourCC("ADsb")
local DAMAGE                    = { 40, 80, 120, 160 }
local MISSILE                   = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
local SPEED                     = 1000
local RADIUS                    = 150
local Z                         = 75
local CHARGE_TIME               = 15
local GROUP                     = CreateGroup()

function Ability.ShadowBolt.spellEffect()
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
    
    GroupClear(GROUP)
    local projectile = createProjectileToXY(MISSILE, x, y, Z, SPEED, nil, nx, ny, Z)
    addProjectileUnitImpact(projectile, RADIUS, function(target)
        if IsUnitAliveBJ(target)
        and IsUnitEnemy(target, player)
        and not IsUnitInGroup(target, GROUP)
        then
            GroupAddUnit(GROUP, target)
            local xt, yt = GetWidgetX(target), GetWidgetY(target)
            local dummy = CreateUnit(player, FourCC('dumm'), xt, yt, 0)
            UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
            UnitAddAbility(dummy, DUMMY_SPELL)
            SetUnitAbilityLevel(dummy, DUMMY_SPELL, level)
            IssueTargetOrder(dummy, 'drunkenhaze', target)
            UnitDamageTarget(caster, target, damage, false, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_FIRE, WEAPON_TYPE_WHOKNOWS)
            addBlackArrowCharge(target, caster, CHARGE_TIME)
        end
    end)
end