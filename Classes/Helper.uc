class Helper extends Object
    config(User);

struct ColorRecord
{
    var string Color;
    var string Tag;
    var string RGB;
};

var config array<ColorRecord> ColorList;
var array<string> colorCodes;
var bool bMadeColorCodes;

static final function string ParseTags(string S)
{
    local int i;
    local string NewTag, newCode;

    CheckColorCodes();
    
    for(i=0;i < default.ColorList.Length;i++)
    {
        NewTag = default.ColorList[i].Tag;
        newCode = default.colorCodes[i];
        ReplaceText(S, NewTag, newCode);
    }
    return S;
}

static final function string StripTags(string S)
{
    local int i;

    CheckColorCodes();
    
    for(i=0;i < default.ColorList.Length;i++)
    {
        ReplaceText(S, default.ColorList[i].Tag, "");
    }
    return S;
}

static final function string StripColor(string S)
{
    local int i;

    i = InStr(S, Chr(27));
    
    while(i >= 0)
    {
        S = Left(S, i) $ Mid(S, i + 4);
        i = InStr(S, Chr(27));
    }
    return S;
}

static final function MakeColorCodes()
{
    local int i;

    for(i=0;i < default.ColorList.Length;i++)
    {
        default.colorCodes[default.colorCodes.Length] = GetColorCode(default.ColorList[i].RGB);
    }
    default.bMadeColorCodes = true;
}

static final function string GetColorCode(string rgbString)
{
    local Color NewColor;
    local array<string> RGB;

    Split(rgbString, ",", RGB);
    RGB.Length = 3;
    NewColor.R = byte(Clamp(int(RGB[0]), 1, 255));
    NewColor.G = byte(Clamp(int(RGB[1]), 1, 255));
    NewColor.B = byte(Clamp(int(RGB[2]), 1, 255));
    return ((Chr(27) $ Chr(NewColor.R)) $ Chr(NewColor.G)) $ Chr(NewColor.B);
}

static final function CheckColorCodes()
{
    if(!default.bMadeColorCodes)
    {
        MakeColorCodes();
    }
}

static final function MakeMutateCommand(string MutateString, out string Command, out string Arg, out array<string> args)
{
    Split(MutateString, " ", args);
    args.Length = 10;
    Command = args[0];
    args.Remove(0, 1);
    Arg = args[0];
}

static final function string RandString(int Length)
{
    local string Chars, S;
    local int i;

    Chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJMLMNOPQRSTUVWXYZ0123456789!%^*(){}[]<>.,";
    
    for(i=0;i < Length;i++)
    {
        S $= Mid(Chars, Rand(Len(Chars)), 1);
    }
    return S;
}

static final function string MergeArray(coerce array<string> Arr, optional string Delim, optional string Prefix)
{
    local int i;
    local string NewList;

    if(Delim == "")
    {
        Delim = ",";
    }
    
    for(i=0;i < Arr.Length;i++)
    {
        if(Arr[i] != "")
        {
            NewList $= ((Delim $ Prefix) $ Arr[i]);
        }
    }
    return Mid(NewList, Len(Delim));
}

static final function SortArray(coerce out array<string> Arr)
{
    local string Swap, With;
    local int Len, Min, i, j;

    Len = Arr.Length;
    
    for(i=0;i < Len-1;i++)
    {
        Min = i;
        
        for(j=i+1;j < Len;j++)
        {
            if(Arr[j] < Arr[Min])
            {
                Min = j;
            }
        }
        if(Arr[Min] != Arr[i])
        {
            Swap = Arr[Min];
            With = Arr[i];
            Arr[i] = Swap;
            Arr[Min] = With;
        }
    }
}

static final function bool IsInArray(coerce array<string> Arr, coerce string S)
{
    local int i;

    for(i=0;i < Arr.Length;i++)
    {
        if(S ~= Arr[i])
        {
            return true;
        }
    }
}

static final function bool IsInString(string arrayString, coerce string S)
{
    local array<string> tempList;
    local int i;

    Split(arrayString, ",", tempList);
    
    for(i=0;i < tempList.Length;i++)
    {
        if(S ~= tempList[i])
        {
            return true;
        }
    }
}

static final function bool IsDigit(string S)
{
    local int i;

    if(S == "")
    {
        return false;
    }

    while(S != "")
    {
        i = Asc(Left(S, 1));
        if((i > 57) || i < 48)
        {
            return false;
        }
        S = Mid(S, 1);
    }
    return true;
}

static final function string ProperCase(string S)
{
    local string initial;

    S = Locs(S);
    initial = Left(S, 1);
    initial = Caps(initial);
    return initial $ Mid(S, 1);
}

static final function string Quotes(string S)
{
    return ("'" $ S) $ "'";
}

static final function string RemoveSpaces(string S)
{
    return Repl(S, " ", "");
}

static final function Vector ParseVectorString(string S)
{
    local Vector newVec;
    local array<string> Arr;
    local int i;

    Split(S, ",", Arr);
    
    for(i=0;i < Arr.Length;i++)
    {
        S = RemoveSpaces(Arr[i]);
        if(S == "")
        {
            continue;
        }
        if(InStr(S, "x=") != -1)
        {
            newVec.X = float(Mid(S, 2));
        }
        if(InStr(S, "y=") != -1)
        {
            newVec.Y = float(Mid(S, 2));
        }
        if(InStr(S, "z=") != -1)
        {
            newVec.Z = float(Mid(S, 2));
        }
    }
    return newVec;
}

static function BroadcastText(coerce string S, Actor inClass, optional bool bCentered)
{
    local Controller C;
    local PlayerController PC;
    local string Msg, coloredMsg, plainMsg;

    if(S == "")
    {
        return;
    }
    coloredMsg = ParseTags(S);
    plainMsg = StripTags(S);
    Log(plainMsg, inClass.Class.Outer.Name);
    
    for(C = inClass.Level.ControllerList;C != none;C = C.nextController)
    {
        PC = PlayerController(C);
        if(PC == none)
        {
            continue;
        }
        else if(MessagingSpectator(C) != none)
        {
            Msg = plainMsg;
        }
        else
        {
            Msg = coloredMsg;
            if(bCentered)
            {
                PC.ClearProgressMessages();
                PC.SetProgressTime(4.0);
                PC.SetProgressMessage(0, Msg, class'Canvas'.static.MakeColor(byte(255), byte(255), byte(255)));
            }
            else
            {
                continue;
            }
            PC.TeamMessage(none, Msg, inClass.Class.Outer.Name);
        }
    }
}

static final function TellAbout(PlayerController PC, array<string> Arr)
{
    local int i;

    if((PC == none) || Arr.Length <= 0)
    {
        return;
    }
    
    for(i=0;i < Arr.Length;i++)
    {
        SendMessage(PC, Arr[i]);
    }
}

static final function SendMessage(PlayerController PC, coerce string Msg, optional bool bAlreadyColored)
{
    if((PC == none) || Msg == "")
    {
        return;
    }
    if(!bAlreadyColored)
    {
        Msg = ParseTags(Msg);
    }
    PC.TeamMessage(none, Msg, 'None');
}

static final function BroadcastSound(Actor inClass, coerce string SoundName, optional float Volume)
{
    local KFPlayerController KFPC;
    local Controller C;
    local Sound NewSound;

    NewSound = Sound(DynamicLoadObject(SoundName, class'Sound'));
    if(NewSound == none)
    {
        return;
    }
    if(Volume <= float(0))
    {
        Volume = 2.0;
    }
    
    for(C = inClass.Level.ControllerList;C != none;C = C.nextController)
    {
        KFPC = KFPlayerController(C);
        if((KFPC == none) || KFPC.PlayerReplicationInfo == none)
        {
            continue;
        }
        else
        {
            KFPC.ClientPlaySound(NewSound, true, Volume, SLOT_None);
            Log("Sound played:" @ string(NewSound.Name), inClass.Class.Outer.Name);
        }
    }
}

static final function string GetDate(LevelInfo Level, int Arg)
{
    local string Date, Year, Month, Day, Hour, Minute,
	    Second;

    Year = Right(string(Level.Year), Len(string(Level.Year)) - 2);
    Month = string(Level.Month);
    Day = string(Level.Day);
    Date = (((Day $ "-") $ Month) $ "-") $ Year;
    if(Level.Hour < 10)
    {
        Hour = string(0) $ string(Level.Hour);
    }
    else
    {
        Hour = string(Level.Hour);
    }
    if(Level.Minute < 10)
    {
        Minute = string(0) $ string(Level.Minute);
    }
    else
    {
        Minute = string(Level.Minute);
    }
    if(Level.Second < 10)
    {
        Second = string(0) $ string(Level.Second);
    }
    else
    {
        Second = string(Level.Second);
    }
    switch(Arg)
    {
        case 1:
            return (((Hour $ ":") $ Minute) $ ":") $ Second;
        case 2:
            return Date;
        case 3:
            return ((Date @ Hour) $ ":") $ Minute;
        default:
    }
}

static final function int GetRealPlayers(LevelInfo Level)
{
    local KFPlayerController KFPC;
    local Controller C;
    local int Count;

    for(C = Level.ControllerList;C != none;C = C.nextController)
    {
        KFPC = KFPlayerController(C);
        if(((KFPC != none) && KFPC.PlayerReplicationInfo != none) && !KFPC.PlayerReplicationInfo.bOnlySpectator)
        {
            ++ Count;
        }
    }
    return Count;
}

static final function int GetAlivePlayers(LevelInfo Level)
{
    local KFPlayerController KFPC;
    local Controller C;
    local int Count;

    for(C = Level.ControllerList;C != none;C = C.nextController)
    {
        KFPC = KFPlayerController(C);
        if(((KFPC != none) && KFPC.Pawn != none) && KFPC.Pawn.Health > 0)
        {
            ++ Count;
        }
    }
    return Count;
}

static final function string GetPlayerIP(PlayerController PC)
{
    local string IP;

    IP = PC.GetPlayerNetworkAddress();
    return Left(IP, InStr(IP, ":"));
}

static final function RestorePlayer(KFHumanPawn KFHP)
{
    if(KFHP == none)
    {
        return;
    }
    KFHP.bBurnified = false;
    KFHP.BileCount = 0;
    KFHP.BurnDown = 0;
    KFHP.RemoveFlamingEffects();
    KFHP.StopBurnFX();
    KFHP.Health = 100;
    KFHP.ShieldStrength = 100.0;
    RefillAmmo(KFHP, true);
}

static final function RefillAmmo(KFHumanPawn KFHP, optional bool bFillMag)
{
    local KFPlayerReplicationInfo KFPRI;
    local class<KFVeterancyTypes> kfvt;
    local Inventory Inv;
    local KFWeapon kfw;
    local KFAmmunition kfa;

    if(KFHP == none)
    {
        return;
    }
    KFPRI = KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo);
    if(KFPRI != none)
    {
        kfvt = KFPRI.ClientVeteranSkill;
    }
    
    for(Inv = KFHP.Inventory;Inv != none;Inv = Inv.Inventory)
    {
        kfw = KFWeapon(Inv);
        if((kfw != none) && bFillMag)
        {
            kfw.MagAmmoRemaining = kfw.MagCapacity;
        }
        kfa = KFAmmunition(Inv);
        if((kfa != none) && kfa.AmmoAmount < kfa.MaxAmmo)
        {
            if(kfvt != none)
            {
                kfa.MaxAmmo = kfa.default.MaxAmmo;
                kfa.MaxAmmo = int(float(kfa.MaxAmmo) * kfvt.static.AddExtraAmmoFor(KFPRI, kfa.Class));
            }
            kfa.AmmoAmount = kfa.MaxAmmo;
        }
    }
}

static final function RemoveFromServerPackages(Actor inClass)
{
    local int i;
    local string PackageName;
    local class<GameEngine> ge;

    ge = class<GameEngine>(DynamicLoadObject("Engine.GameEngine", class'Class'));
    PackageName = string(inClass.Class.Outer.Name);
    
    for(i=0;i < ge.default.ServerPackages.Length;i++)
    {
        if(ge.default.ServerPackages[i] ~= PackageName)
        {
            Log(PackageName @ "was found in ServerPackages! Removing it now!", inClass.Class.Outer.Name);
            ge.default.ServerPackages.Remove(i, 1);
            ge.static.StaticSaveConfig();
            return;
        }
    }
}

static final function DLog(string S, Actor inClass)
{
    Log(S, inClass.Class.Outer.Name);
}

defaultproperties
{
    ColorList(0)=(Color="Black",Tag="$b",RGB="1,1,1")
    ColorList(1)=(Color="Blue",Tag="%b",RGB="0,100,200")
    ColorList(2)=(Color="Cyan",Tag="%c",RGB="0,255,255")
    ColorList(3)=(Color="Gray",Tag="$g",RGB="96,96,96")
    ColorList(4)=(Color="Green",Tag="%g",RGB="0,255,0")
    ColorList(5)=(Color="Neon Blue",Tag="%nb",RGB="0,150,200")
    ColorList(6)=(Color="Orange",Tag="%o",RGB="200,77,0")
    ColorList(7)=(Color="Pink",Tag="%p",RGB="255,192,203")
    ColorList(8)=(Color="Purple",Tag="^p",RGB="128,0,128")
    ColorList(9)=(Color="Red",Tag="%r",RGB="255,0,0")
    ColorList(10)=(Color="Violet",Tag="%v",RGB="255,0,139")
    ColorList(11)=(Color="White",Tag="%w",RGB="255,255,255")
    ColorList(12)=(Color="Yellow",Tag="%y",RGB="255,255,0")
    ColorList(13)=(Color="ScrN 1",Tag="^0",RGB="1,1,1")
    ColorList(14)=(Color="ScrN 2",Tag="^1",RGB="200,1,1")
    ColorList(15)=(Color="ScrN 3",Tag="^2",RGB="1,200,1")
    ColorList(16)=(Color="ScrN 4",Tag="^3",RGB="200,200,1")
    ColorList(17)=(Color="ScrN 5",Tag="^4",RGB="1,1,255")
    ColorList(18)=(Color="ScrN 6",Tag="^5",RGB="1,255,255")
    ColorList(19)=(Color="ScrN 7",Tag="^6",RGB="200,1,200")
    ColorList(20)=(Color="",Tag="",RGB="")
    ColorList(21)=(Color="ScrN 8",Tag="^7",RGB="200,200,200")
    ColorList(22)=(Color="ScrN 9",Tag="^8",RGB="255,127,0")
    ColorList(23)=(Color="ScrN 10",Tag="^9",RGB="128,128,128")
    ColorList(24)=(Color="ScrN 11",Tag="^w$",RGB="255,255,255")
    ColorList(25)=(Color="ScrN 12",Tag="^r$",RGB="255,1,1")
    ColorList(26)=(Color="ScrN 13",Tag="^g$",RGB="1,255,1")
    ColorList(27)=(Color="ScrN 14",Tag="^b$",RGB="1,1,255")
    ColorList(28)=(Color="ScrN 15",Tag="^y$",RGB="255,255,1")
    ColorList(29)=(Color="ScrN 16",Tag="^c$",RGB="1,255,255")
    ColorList(30)=(Color="ScrN 17",Tag="^o$",RGB="255,140,1")
    ColorList(31)=(Color="ScrN 18",Tag="^u$",RGB="255,20,147")
    ColorList(32)=(Color="ScrN 19",Tag="^s$",RGB="1,192,255")
    ColorList(33)=(Color="ScrN 20",Tag="^n$",RGB="139,69,19")
    ColorList(34)=(Color="ScrN 21",Tag="^w$",RGB="112,138,144")
    ColorList(35)=(Color="ScrN 22",Tag="^R$",RGB="132,1,1")
    ColorList(36)=(Color="ScrN 23",Tag="^G$",RGB="1,132,1")
    ColorList(37)=(Color="ScrN 24",Tag="^B$",RGB="1,1,132")
    ColorList(38)=(Color="ScrN 25",Tag="^y$",RGB="255,192,1")
    ColorList(39)=(Color="ScrN 26",Tag="^c$",RGB="1,160,192")
    ColorList(40)=(Color="",Tag="",RGB="")
    ColorList(41)=(Color="ScrN 27",Tag="^O$",RGB="255,69,1")
    ColorList(42)=(Color="ScrN 28",Tag="^U$",RGB="160,32,240")
    ColorList(43)=(Color="ScrN 29",Tag="^s$",RGB="65,105,225")
    ColorList(44)=(Color="ScrN 30",Tag="^n$",RGB="80,40,20")
    ColorList(45)=(Color="Misc 1",Tag="%1$",RGB="109,64,255")
    ColorList(46)=(Color="Misc 2",Tag="%2$",RGB="204,64,255")
    ColorList(47)=(Color="Misc 3",Tag="%3$",RGB="64,166,255")
}