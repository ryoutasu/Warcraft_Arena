Ability.Shield = {}
AbilityIndex[FourCC("AHsh")] = Ability.Shield

local RESIST = 1
local DURABLE = { 150, 250, 350, 450 }
local INSTANCE = {}
local BUFF = FourCC("BHsh")

local function clear(key)
    if not INSTANCE[key] then return end
    INSTANCE[key].hp = nil
    INSTANCE[key] = false
end

function Ability.Shield.spellEffect()
    local target = GetSpellTargetUnit()
    local caster = GetSpellAbilityUnit()
    local ability = GetSpellAbilityId()
    local level = GetUnitAbilityLevel(caster, ability)
    local player = GetOwningPlayer(caster)
    local key = GetHandleId(target)
    
    if not INSTANCE[key] then
        INSTANCE[key] = {}
        INSTANCE[key].hp = 0
    end
    INSTANCE[key].hp = math.min(INSTANCE[key].hp + DURABLE[level], DURABLE[level] * 2)
end

function Ability.Shield.init()
    local t = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(t, function()
        local damage = GetEventDamage()
        if damage < 1 then return end
        
        local target = BlzGetEventDamageTarget()
        local key = GetHandleId(target)
        if GetUnitAbilityLevel(target, BUFF) == 0 then
            if INSTANCE[key] then clear(key) end
            return
        end
        local hp = INSTANCE[key].hp

        local new_damage = damage * RESIST
        if hp < new_damage then new_damage = hp end
        hp = hp - new_damage
        BlzSetEventDamage(damage - new_damage)

        if hp <= 0 then
            UnitRemoveAbility(target, BUFF)
            clear(key)
            return
        end

        INSTANCE[key].hp = hp
    end)
end