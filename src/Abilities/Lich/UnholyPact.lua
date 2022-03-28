Ability.UnholyPact = {}
AbilityIndex[FourCC("AHup")]    = Ability.UnholyPact

local EFFECT_CASTER             = "Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl"
local EFFECT_TARGET             = "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl"
local BUFF                      = FourCC('BHup')
local MANA_DRAIN                = { 4, 5, 6, 7}
local ATTACK_NUMBER             = 5
local HEALTH_COST_PERCENT       = 20
local INSTANCE                  = {}

function Ability.UnholyPact.spellEffect()
    local caster        = GetTriggerUnit()
    local player        = GetOwningPlayer(caster)
    local ability       = GetSpellAbilityId()
    local level         = GetUnitAbilityLevel(caster, ability)

    local healthCost    = GetUnitState(caster, UNIT_STATE_LIFE) * (HEALTH_COST_PERCENT / 100)
    SetUnitState(caster, UNIT_STATE_LIFE, GetUnitState(caster, UNIT_STATE_LIFE) - healthCost)

    local instance      = {}
    INSTANCE[caster]    = instance
    instance.attacks    = ATTACK_NUMBER
    instance.level      = level
end

function Ability.UnholyPact.init()
    local attackTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(attackTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(attackTrigger, function()
        local caster    = GetEventDamageSource()
        local target    = BlzGetEventDamageTarget()

        if GetUnitAbilityLevel(caster, BUFF) < 1 then return end
        if not INSTANCE[caster] then return end
        if not BlzGetEventIsAttack() then return end

        local instance  = INSTANCE[caster]
        local level     = instance.level
        local manaDrain = GetUnitState(target, UNIT_STATE_MAX_MANA) * (MANA_DRAIN[level] / 100)
        manaDrain       = math.min(GetUnitState(target, UNIT_STATE_MANA), manaDrain)
        
        SetUnitState(caster, UNIT_STATE_MANA, GetUnitState(caster, UNIT_STATE_MANA) + manaDrain)
        SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) - manaDrain)
        
        local effectC   = AddSpecialEffectTarget(EFFECT_CASTER, caster, "chest")
        local effectT   = AddSpecialEffectTarget(EFFECT_TARGET, target, "origin")
        TimerStart(CreateTimer(), 0.35, false, function()
            DestroyEffect(effectC)
            DestroyEffect(effectT)
            DestroyTimer(GetExpiredTimer())
        end)

        -- DestroyEffect(AddSpecialEffect(EFFECT_CASTER, GetUnitX(caster), GetUnitY(caster)))
        -- DestroyEffect(AddSpecialEffect(EFFECT_TARGET, GetUnitX(target), GetUnitY(target)))

        instance.attacks = instance.attacks - 1
        if instance.attacks < 1 then
            instance = nil
            UnitRemoveAbility(caster, BUFF)
        end

        INSTANCE[caster] = instance
    end)
end