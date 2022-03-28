local GAME_UI = BlzGetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 )
local Text = BlzCreateFrameByType("TEXT", "", GAME_UI, "", 0)
BlzFrameSetPoint( Text, FRAMEPOINT_TOP, GAME_UI, FRAMEPOINT_TOP, 0.0, -0.03 )
BlzFrameSetScale( Text, 2.0 )

function SetTopText( message )
    BlzFrameSetText( Text, message )
end