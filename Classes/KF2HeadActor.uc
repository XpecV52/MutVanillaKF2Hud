class KF2HeadActor extends Actor;

var vector CrouchOffset;

defaultproperties
{
     CrouchOffset=(Z=15.000000)
     DrawType=DT_Mesh
     bTrailerSameRotation=True
     bTrailerPrePivot=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     bAnimByOwner=True
     bHardAttach=True
}
