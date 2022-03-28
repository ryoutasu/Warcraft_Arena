Ability = {}
AbilityIndex = {}

require('Abilities.Lich.Frostnova')
require('Abilities.Lich.Iceshard')
require('Abilities.Lich.UnholyPact')
require('Abilities.MurlocSage.Fireball')
require('Abilities.MurlocSage.RainOfFire')
require('Abilities.Priest.Penance')
require('Abilities.Priest.Shield')
require('Abilities.Priest.Lightspark')
require('Abilities.DarkRanger.BlackArrow')
require('Abilities.DarkRanger.ShadowBolt')
require('Abilities.DarkRanger.BansheeBlink')

DUMMY = FourCC('dumm')

do
    local EventChannelId = GetHandleId(EVENT_PLAYER_UNIT_SPELL_CHANNEL)
    local EventCastId    = GetHandleId(EVENT_PLAYER_UNIT_SPELL_CAST)
    local EventEffectId  = GetHandleId(EVENT_PLAYER_UNIT_SPELL_EFFECT)
    local EventEndCastId = GetHandleId(EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    local EventFinishId  = GetHandleId(EVENT_PLAYER_UNIT_SPELL_FINISH)

    function InitAbilities(abilities)
        for k,v in pairs(abilities) do
            if type(v) == "table" then
                local init = v.init
                if (init and type(init)) == "function" then init() end
            end
        end

        local trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trigger, function()
            local eventId = GetHandleId(GetTriggerEventId())
            local abilityId = GetSpellAbilityId()
            local spelldata = AbilityIndex[abilityId]
            if spelldata and type(spelldata) == "table" then
                local spellEffect = spelldata.spellEffect
                if eventId == EventEffectId and spellEffect then spellEffect() end
            end
        end)
    end

    function InitAllAbilities()
        for k,v in pairs(Ability) do
            if type(v) == "table" then
                local init = v.init
                if (init and type(init)) == "function" then init() end
            end
        end

        local trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        TriggerAddAction(trigger, function()
            local eventId = GetHandleId(GetTriggerEventId())
            local abilityId = GetSpellAbilityId()
            local spelldata = AbilityIndex[abilityId]
            if spelldata and type(spelldata) == "table" then
                local spellEffect = spelldata.spellEffect
                local spellEndCast = spelldata.spellEndCast
                if eventId == EventEffectId and spellEffect then spellEffect() end
                if eventId == EventEndCastId and spellEndCast then spellEndCast() end
            end
        end)
    end


    local remove = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(remove, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddCondition(remove, Condition(function()
        return (GetUnitTypeId(GetDyingUnit()) == DUMMY)
    end))
    TriggerAddAction(remove, function()
        RemoveUnit(GetDyingUnit())
    end)
end
