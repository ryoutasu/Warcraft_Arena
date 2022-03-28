Ability.BansheeBlink = {}
AbilityIndex[FourCC("AHbb")]    = Ability.BansheeBlink

local DUMMY_SPELL               = FourCC('ADbb')
local MISSILE                   = "units\\undead\\Banshee\\Banshee"
local SPEED                     = 950
local Z                         = 10

function Ability.BansheeBlink.spellEffect()
    local caster    = GetTriggerUnit()
    local player    = GetOwningPlayer(caster)
    local level     = GetUnitAbilityLevel(caster, GetSpellAbilityId())
    local x, y      = GetUnitX(caster), GetUnitY(caster)
    local tx, ty    = GetSpellTargetX(), GetSpellTargetY()

    local dummy     = CreateUnit(player, FourCC('dumm'), x, y, 0)
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 2)
    UnitAddAbility(dummy, DUMMY_SPELL)
    SetUnitAbilityLevel(dummy, DUMMY_SPELL, level)
    IssuePointOrder(dummy, 'silence', x, y)

    ShowUnit(caster, false)
    local projectile = createProjectileToXY(MISSILE, x, y, Z, SPEED, nil, tx, ty, Z, function()
        ShowUnit(caster, true)
        SelectUnitForPlayerSingle(caster, player)

        local dumm = CreateUnit(player, FourCC('dumm'), tx, ty, 0)
        UnitApplyTimedLife(dumm, FourCC("BTLF"), 2)
        UnitAddAbility(dumm, DUMMY_SPELL)
        SetUnitAbilityLevel(dumm, DUMMY_SPELL, level)
        IssuePointOrder(dumm, 'silence', tx, ty)
    end)
    BlzPlaySpecialEffect(projectile.missile, ANIM_TYPE_WALK)
end