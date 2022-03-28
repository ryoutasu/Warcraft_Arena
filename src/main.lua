BlzLoadTOCFile("resources\\UI\\Templates.toc")
require('Utils.utils')
require('Utils.Projectile')
require('Utils.tablecopy')

require('Game.Game')
require('UI.HeroPick')
require('UI.Shop')
require('UI.GameUI')
require('UI.Message')
require('Multiboard')
require('Arena.Arena')
require('Abilities.Abilities')

GameUI.hideOriginUI()

TimerStart(CreateTimer(), 0, false, function()
    Game:start()

    DestroyTimer(GetExpiredTimer())
end)