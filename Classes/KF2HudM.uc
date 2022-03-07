class KF2HudM extends Mutator;

var KFGameType KFGT;


function PostBeginPlay()
{
  	GT = KFGameType(level.game);
  	if (GT != none)
		GT.HUDType = string(class'KF2Hud');
    
    super(Actor).PostBeginPlay();
}


defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-KF2Hud"
     FriendlyName="KF2Hud"
     Description="KF2Hud For Vanilla KF1."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
