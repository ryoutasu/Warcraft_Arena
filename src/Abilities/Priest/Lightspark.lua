Ability.Lightspark = {}
AbilityIndex[FourCC("AHls")] = Ability.Lightspark

local EFFECT = 'Abilities/Spells/Undead/ReplenishHealth/ReplenishHealthCasterOverhead.mdl'
local EFFECT_1 = 'Abilities/Spells/NightElf/ManaBurn/ManaBurnTarget.mdl'
local EFFECT_2 = 'Abilities/Spells/Human/Heal/HealTarget.mdl'
local HEAL = { 80, 120, 160, 200}
local GROUP = CreateGroup()

function Ability.Lightspark.spellEffect()
    local caster  = GetTriggerUnit()
    local player  = GetOwningPlayer(caster)
    local ability = GetSpellAbility()
    local level   = GetUnitAbilityLevel(caster, GetSpellAbilityId())
    local x, y    = GetSpellTargetX(), GetSpellTargetY()
    local radius  = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)

    DestroyEffect(AddSpecialEffect(EFFECT, x, y))
    DestroyEffect(AddSpecialEffect(EFFECT_1, x, y))
    GroupEnumUnitsInRange(GROUP, x, y, radius + 32)
				
    for index = BlzGroupGetSize(GROUP) - 1, 0, -1 do
        local target = BlzGroupUnitAt(GROUP, index)
        if IsUnitAliveBJ(target)
        and IsUnitAlly(target, player)
        and not IsUnitType(target, UNIT_TYPE_MECHANICAL)
        and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
        then
            SetWidgetLife(target, GetWidgetLife(target) + HEAL[level])
            DestroyEffect(AddSpecialEffectTarget(EFFECT_2, target, 'origin'))
        end
    end
    GroupClear(GROUP)
end


function Ability.Lightspark.init()

end