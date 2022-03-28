Ability.RainOfFire = {}
AbilityIndex[FourCC("AHr2")] = Ability.RainOfFire

local TIMER_TICK = 0.0625 -- 1/32 of second
local ABILITYID = FourCC("AHr2")
local STATIC_COOLDOWN = 0.2
local MAX_CHARGES = 4
local INSTANCE = {}

function Ability.RainOfFire.spellEffect()
    local caster    = GetTriggerUnit()
    local player    = GetOwningPlayer(caster)
    local ability   = GetSpellAbility()

    if not INSTANCE[caster] then
        INSTANCE[caster] = { charges = MAX_CHARGES, time = 0 }
    end

    local instance = INSTANCE[caster]
    instance.charges = instance.charges - 1
    if instance.charges <= 0 then
        BlzSetUnitAbilityCooldown(caster, ABILITYID, 0, instance.time)
    else
        BlzSetUnitAbilityCooldown(caster, ABILITYID, 0, STATIC_COOLDOWN)
    end
    if instance.time <= 0 then
        instance.time = BlzGetAbilityCooldown(ABILITYID, 0)
    end
end

function Ability.RainOfFire.init()
    TimerStart(CreateTimer(), TIMER_TICK, true, function()
        for caster, instance in pairs(INSTANCE) do
            if instance.time > 0 then
                instance.time = instance.time - TIMER_TICK
            elseif instance.time <= 0 then
                if instance.charges < MAX_CHARGES then
                    instance.charges = instance.charges + 1
                    instance.time = BlzGetAbilityCooldown(ABILITYID, 0)
                end
            end
        end
    end)
end

function Ability.RainOfFire.reset()
    for caster, instance in pairs(INSTANCE) do
        instance.charges = MAX_CHARGES
        instance.time = 0
    end
end