Ability.Penance = {}
AbilityIndex[FourCC("AHpe")] = Ability.Penance

local ABILITY_ID = FourCC("AHpe")
local DISTANCE = { 700, 800, 900, 1000 }
local MISSILE = 'Abilities/Weapons/PriestMissile/PriestMissile.mdl'
local MISSILE_EFFECT = 'Abilities/Spells/Items/HealingSalve/HealingSalveTarget.mdl'
local EFFECT = 'Abilities/Spells/Human/Heal/HealTarget.mdl'
local SPEED = 1200
local Z = -30

local HEAL = { 1, 1.5, 2, 2.5 }
local DAMAGE = { 0.7, 1, 1.3, 1.6 }
-- local HEAL_INT = 0
-- local HEAL_INT_PL = 1.5
-- local DAMAGE_INT = 0
-- local DAMAGE_INT_PL = 1
local TIMER_PERIOD = 1

local function DistanceBetweenWidgets(targetA, targetB)
    local dx = GetWidgetX(targetB) - GetWidgetX(targetA)
    local dy = GetWidgetY(targetB) - GetWidgetY(targetA)
    return math.sqrt(dx*dx + dy*dy)
end

local function FloatingText(text, x, y)
    local tt = CreateTextTag()
    SetTextTagText(tt, text, 0.020)
    SetTextTagPos(tt, x, y, 0.0)
    SetTextTagColor(tt, 255, 250, 250, 255)
    SetTextTagVelocity(tt, 0.0,  0.01)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 2.0)
    SetTextTagVisibility(tt, IsVisibleToPlayer(x, y, GetLocalPlayer()))
    SetTextTagPermanent(tt, false)
end

local INSTANCE = {}

function Ability.Penance.spellEffect()
    local caster = GetTriggerUnit()
    local player = GetOwningPlayer(caster)
    local key = GetHandleId(caster)
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, ABILITY_ID)
    local x, y = GetUnitX(caster), GetUnitY(caster)
    local int = GetHeroInt(caster, true)
    local effects = {}

    -- local damage = (DAMAGE_INT + (DAMAGE_INT_PL * level)) * int
    -- local heal = (HEAL_INT + (HEAL_INT_PL * level)) * int
    local damage = DAMAGE[level] * int
    local heal = HEAL[level] * int

    INSTANCE[key] = true

    local function createProjectile()
        local projectile = createProjectileToTarget(MISSILE_EFFECT, x, y, Z, SPEED, nil, target, Z, true, function()
            if not IsUnitAliveBJ(target) then return end
            
            if IsUnitEnemy(target, player) then
                UnitDamageTarget(caster, target, damage, false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                DestroyEffect(AddSpecialEffectTarget(EFFECT, target, 'origin'))
                FloatingText(damage, GetUnitX(target), GetUnitY(target))
            else
                SetWidgetLife(target, GetWidgetLife(target) + heal)
                DestroyEffect(AddSpecialEffectTarget(EFFECT, target, 'origin'))
                FloatingText(heal, GetUnitX(target), GetUnitY(target))
            end
        end)
        return projectile
    end

    createProjectile()
    TimerStart(CreateTimer(), TIMER_PERIOD, true, function()
        local isMaxDistance = DistanceBetweenWidgets(caster, target) >= DISTANCE[level]
        if not INSTANCE[key]
        or isMaxDistance
        or not IsUnitAliveBJ(caster)
        or not IsUnitAliveBJ(target)
        then
            if isMaxDistance
            and IsUnitAliveBJ(caster)
            then IssueImmediateOrderById(caster, 851972) --> stop
            end

            for i, e in ipairs(effects) do
                DestroyEffect(e)
            end
            DestroyTimer(GetExpiredTimer())
            return
        end

        createProjectile()
    end)
end


function Ability.Penance.spellEndCast()
    local key = GetHandleId(GetTriggerUnit())
    INSTANCE[key] = false
end


function Ability.Penance.init()

end