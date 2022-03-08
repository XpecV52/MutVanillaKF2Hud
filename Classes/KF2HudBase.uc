class KF2HudBase extends HUDKillingFloor;

var protected transient float MsgTopY; // top Y coordinate up upper console message displayed on the HUD

function PostBeginPlay()
{
    super.PostBeginPlay();
}

function Destroyed()
{
    super.Destroyed();
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
    super.DrawEndGameHUD(C, bVictory);
    //display end-game achievements
    C.Reset();
    DisplayLocalMessages(C);
}


simulated function DrawHudPassC(Canvas C)
{
    DrawFadeEffect(C);

    if ( bShowScoreBoard && ScoreBoard != None )
        ScoreBoard.DrawScoreboard(C);

    // portrait
    if ( bShowPortrait && (Portrait != None) )
        DrawPortraitSE(C); // finally this is not final :)  -- PooSH

    if( bCrosshairShow && bShowKFDebugXHair )
        DrawCrosshair(C);

    // Slow, for debugging only
    if( bDebugPlayerCollision && (class'ROEngine.ROLevelInfo'.static.RODebugMode() || Level.NetMode == NM_StandAlone) )
        DrawPointSphere();
}


function DisplayPortrait(PlayerReplicationInfo PRI)
{
    local Material NewPortrait;
    if ( LastPlayerIDTalking > 0 )
        return;


    NewPortrait = PRI.GetPortrait();

    if ( NewPortrait == None )
        return;

    if ( Portrait == None )
        PortraitX = 1;

    Portrait = NewPortrait;
    PortraitTime = Level.TimeSeconds + 3;
    PortraitPRI = PRI;
}

// seems like I'm the first who removed that bloody "final" mark  -- PooSH
simulated function DrawPortraitSE( Canvas C )
{
    local float PortraitWidth, PortraitHeight, Margin, XL, YL, X, Y;
    local int FontIdx;
    // local Material M;

    PortraitWidth = 0.125 * C.ClipY;
    if ( Portrait != TraderPortrait )
        PortraitHeight = PortraitWidth * Portrait.MaterialVSize() / Portrait.MaterialUSize();
    else
        PortraitHeight = 1.5 * PortraitWidth;

    Margin = 0.025*PortraitWidth;
    X = -PortraitWidth * PortraitX + Margin;
    Y = (C.ClipY - PortraitHeight)/2 + Margin;

    // name
    if ( PortraitPRI != None )
    {
        if ( PortraitPRI.Team != None && PortraitPRI.Team.TeamIndex < 2 )
            C.DrawColor = WhiteColor;

        FontIdx = -2;
        do {
            C.Font = GetFontSizeIndex(C, FontIdx);
            KF2ScoreBoardClass.Static.TextSizeCountry(C,PortraitPRI,XL,YL);
        }until ( XL <= PortraitWidth || --FontIdx < -8 );

        // shift portrait up if it gets overlaped with console messages
        if ( Y + (1.07 * PortraitHeight + YL) > MsgTopY )
            Y = MsgTopY - 1.07 * PortraitHeight - YL;

        if ( XL > PortraitWidth )
            KF2ScoreBoardClass.Static.DrawCountryName(C,PortraitPRI, C.ClipY/256 - PortraitWidth*PortraitX, Y + 1.06 * PortraitHeight); // align left
        else
            KF2ScoreBoardClass.Static.DrawCountryName(C,PortraitPRI,C.ClipY/256 - PortraitWidth*PortraitX + (PortraitWidth - XL)/2, Y + 1.06 * PortraitHeight); // align center
    }
    else if ( Portrait == TraderPortrait )
    {
        C.DrawColor = WhiteColor;
        C.Font = GetFontSizeIndex(C, -2);
        C.TextSize(TraderString, XL, YL);
        // shift portrait up if it gets overlaped with console messages
        if ( ConsoleMessagePosY < 0.5 && (Y + 1.07 * PortraitHeight + YL) > MsgTopY )
            Y = MsgTopY - 1.07 * PortraitHeight - YL;
        C.SetPos(C.ClipY / 256 - PortraitWidth * PortraitX + 0.5 * (PortraitWidth - XL), Y + 1.06 * PortraitHeight);
        C.DrawTextClipped(TraderString,true);
    }

    // black background prevents alpha/mask flickering on portraits
    C.SetPos(X, Y);
    C.DrawColor = BlackColor;
    C.DrawTileStretched(WhiteMaterial, PortraitWidth, PortraitHeight);
    C.DrawColor = WhiteColor;
    C.SetPos(X, Y);
    C.DrawTile(Portrait, PortraitWidth, PortraitHeight, 0, 0, Portrait.MaterialUSize(), Portrait.MaterialVSize());



    C.DrawColor = C.static.MakeColor(160, 160, 160);
    C.SetPos(X, Y);
    C.DrawTile( Material'kf_fx_trip_t.Misc.KFModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

    C.DrawColor = WhiteColor;
    C.SetPos(X - Margin, Y - Margin);
    C.DrawTileStretched(texture'InterfaceContent.Menu.BorderBoxA1', PortraitWidth + 2*Margin, PortraitHeight + 2*Margin);
}
