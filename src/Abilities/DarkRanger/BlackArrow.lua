Ability.BlackArrow = {}
AbilityIndex[FourCC("AHba")]    = Ability.BlackArrow

local ABILITYID                 = FourCC('AHba')
local AURAID                    = FourCC('ADba')
local BUFF                      = FourCC('Bpoi')
local AURABUFF                  = FourCC('BHba')
local EFFECT                    = "Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl"
local CHARGE_TIME               = 6
local MAX_CHARGES               = 5
local DAMAGE_AS_LIFE_PERCENT    = 0.07
local INSTANCE                  = {}
local TIMER_TICK                = 0.0625 -- 1/16 of second

local function FloatingText(text, x, y, r, g, b)
    r = r or 255
    g = g or 255
    b = b or 255
    local tt = CreateTextTag()
    SetTextTagText(tt, text, 0.023)
    SetTextTagPos(tt, x, y, 0.0)
    SetTextTagColor(tt, r, g, b, 255)
    SetTextTagVelocity(tt, 0.0,  0.04)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 2.0)
    SetTextTagVisibility(tt, IsVisibleToPlayer(x, y, GetLocalPlayer()))
    SetTextTagPermanent(tt, false)
end

function addBlackArrowCharge(target, caster, time)
    local instance = INSTANCE[target]
    if GetUnitAbilityLevel(target, AURAID) < 1 then
        instance = { charges = 0, time = 0 }
        UnitAddAbility(target, AURAID)
    end
    instance.charges = instance.charges + 1
    SetUnitAbilityLevel(target, AURABUFF, instance.charges)
    instance.time = math.max(time, instance.time)
    
    if instance.charges >= MAX_CHARGES then
        UnitRemoveAbility(target, AURAID)
        UnitRemoveAbility(target, AURABUFF)
        instance.charges = 0
        instance = nil

        local damage = BlzGetUnitMaxHP(target) * DAMAGE_AS_LIFE_PERCENT
        UnitDamageTarget(caster, target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS)
        FloatingText(R2I(damage)..'!', GetUnitX(target), GetUnitY(target), 128, 0, 128)
        DestroyEffect(AddSpecialEffectTarget(EFFECT, target, 'origin'))
    else
        FloatingText(instance.charges, GetUnitX(target), GetUnitY(target), 128, 0, 128)
    end
    
    INSTANCE[target] = instance
end

function Ability.BlackArrow.init()
    local attackTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(attackTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(attackTrigger, function()
        local caster = GetEventDamageSource()
        local target = BlzGetEventDamageTarget()
        local level = GetUnitAbilityLevel(caster, ABILITYID)

        if GetUnitAbilityLevel(target, BUFF) < 1
        or level < 1
        or not BlzGetEventIsAttack()
        then return end
        UnitRemoveAbility(target, BUFF)
        
        addBlackArrowCharge(target, caster, CHARGE_TIME)
    end)

    TimerStart(CreateTimer(), TIMER_TICK, true, function()
        for target, instance in pairs(INSTANCE) do
            instance.time = instance.time - TIMER_TICK
            if instance.time <= 0 then
                instance.charges = 0
                instance = nil
                UnitRemoveAbility(target, AURAID)
                UnitRemoveAbility(target, AURABUFF)
            end
        end
    end)
end