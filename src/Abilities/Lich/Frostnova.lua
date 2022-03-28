Ability.Frostnova = {}
AbilityIndex[FourCC("AHfn")]    = Ability.Frostnova

local DUMMY_SPELL               = FourCC("ADfn")
local GROUP                     = CreateGroup()
local PREEFFECT                 = 'Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl'
local EFFECT                    = 'Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl'

function Ability.Frostnova.spellEffect()
    local caster  = GetTriggerUnit()
    local player  = GetOwningPlayer(caster)
    local ability = GetSpellAbility()
    local level   = GetUnitAbilityLevel(caster, GetSpellAbilityId())
    local x, y    = GetSpellTargetX(), GetSpellTargetY()
    local radius  = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    
    local preeffect = AddSpecialEffect(PREEFFECT, x, y)
    BlzSetSpecialEffectScale(preeffect, 2.5)
    TimerStart(CreateTimer(), 0.75, false, function()
        GroupEnumUnitsInRange(GROUP, x, y, radius + 128)
        for index = BlzGroupGetSize(GROUP) - 1, 0, -1 do
            local target = BlzGroupUnitAt(GROUP, index)
            if IsUnitAliveBJ(target) and IsUnitInRangeXY(target, x, y, radius)
            and IsUnitEnemy(target, player) then
                local dummy = CreateUnit(player, FourCC('dumm'), x, y, 0)
                UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
                UnitAddAbility(dummy, DUMMY_SPELL)
                SetUnitAbilityLevel(dummy, DUMMY_SPELL, level)
                IssueTargetOrder(dummy, "frostnova", target)
            end
        end
        DestroyEffect(AddSpecialEffect(EFFECT, x, y))
        DestroyEffect(preeffect)
        TimerStart(CreateTimer(), 0.333, false, function()
            BlzSetSpecialEffectScale(preeffect, 0)
            DestroyTimer(GetExpiredTimer())
        end)
        GroupClear(GROUP)
        DestroyTimer(GetExpiredTimer())
    end)
end

function Ability.Frostnova.init()
    
end