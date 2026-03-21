ZVEUSMG ; VE — User management broker helpers (keys, e-sig, creds, lifecycle)
 ;;1.0;VE USERMG;**;Mar 21, 2026
 ; Overlay RPCs for tenant-admin direct writes. Register via INSTALL^ZVEUSMG.
 ; Keys use ^XUSEC(KEY,DUZ) (standard Kernel pattern).
 Q
 ;
INSTALL ; Register RPCs in File #8994 (idempotent)
 W !,"=== Installing ZVE USMG RPCs ==="
 D REGONE("ZVE USMG KEYS","KEYS","ZVEUSMG","Assign/remove security keys")
 D REGONE("ZVE USMG ESIG","ESIG","ZVEUSMG","Set electronic signature code")
 D REGONE("ZVE USMG CRED","CRED","ZVEUSMG","Set access/verify (XUSHSH)")
 D REGONE("ZVE USMG ADD","ADD","ZVEUSMG","Create File 200 stub user")
 D REGONE("ZVE USMG DEACT","DEACT","ZVEUSMG","Set termination date (field 9)")
 D REGONE("ZVE USMG REACT","REACT","ZVEUSMG","Clear termination date")
 W !,"=== ZVE USMG install complete ==="
 Q
 ;
REGONE(NAME,TAG,RTN,DESC) ; Register one remote procedure
 N IEN S IEN=$$FIND1^DIC(8994,,"BX",NAME)
 I IEN>0 W !,"  ",NAME," already registered" Q
 N FDA,ERR
 S FDA(8994,"+1,",.01)=NAME
 S FDA(8994,"+1,",.02)=TAG
 S FDA(8994,"+1,",.03)=RTN
 S FDA(8994,"+1,",.04)=2
 D UPDATE^DIE("E","FDA","","ERR")
 I $D(ERR) W !,"  ERROR: ",$G(ERR("DIERR",1,"TEXT",1)) Q
 W !,"  Registered: ",NAME
 Q
 ;
KEYS(R,ACT,DUZ,KNM) ; RPC ZVE USMG KEYS — params: ACTION, DUZ, KEY name
 N E S E=""
 I $G(ACT)="" S E="ACTION required"
 I '+$G(DUZ) S E="DUZ required"
 I $G(KNM)="" S E="KEY required"
 I E]"" W "0^",E,! Q
 I ACT'="ADD",ACT'="DEL" W "0^Invalid ACTION",! Q
 I ACT="ADD" S ^XUSEC(KNM,DUZ)=""
 I ACT="DEL" K ^XUSEC(KNM,DUZ)
 W "1^OK^",ACT,! Q
 ;
ESIG(R,DUZ,CODE) ; RPC ZVE USMG ESIG
 I '+$G(DUZ) W "0^DUZ required",! Q
 I $G(CODE)="" W "0^CODE required",! Q
 N FDA,DIERR
 S FDA(200,DUZ_",",20.4)=$$EN^XUSHSH(CODE)
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) W "0^FILE^DIE error",! Q
 W "1^OK",! Q
 ;
CRED(R,DUZ,AC,VC) ; RPC ZVE USMG CRED
 I '+$G(DUZ) W "0^DUZ required",! Q
 I $G(AC)=""!($G(VC)="") W "0^ACCESS and VERIFY required",! Q
 N FDA,DIERR
 S FDA(200,DUZ_",",2)=$$EN^XUSHSH(AC)
 S FDA(200,DUZ_",",11)=$$EN^XUSHSH(VC)
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) W "0^FILE^DIE error",! Q
 W "1^OK",! Q
 ;
ADD(R,NM,AC,VC) ; RPC ZVE USMG ADD — minimal demo user
 I $G(NM)="" W "0^NAME required",! Q
 N FDA,IEN,DIERR
 S FDA(200,"+1,",.01)=NM
 I $G(AC)]"" S FDA(200,"+1,",2)=$$EN^XUSHSH(AC)
 I $G(VC)]"" S FDA(200,"+1,",11)=$$EN^XUSHSH(VC)
 D UPDATE^DIE("E",$NA(FDA),$NA(IEN),$NA(DIERR))
 I $D(DIERR) W "0^UPDATE^DIE failed",! Q
 W "1^",$G(IEN(1)),! Q
 ;
DEACT(R,DUZ) ; RPC ZVE USMG DEACT — set field 9 = today
 I '+$G(DUZ) W "0^DUZ required",! Q
 N FDA,DIERR
 S FDA(200,DUZ_",",9)=DT
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) W "0^FILE^DIE error",! Q
 W "1^OK",! Q
 ;
REACT(R,DUZ) ; RPC ZVE USMG REACT — delete termination date
 I '+$G(DUZ) W "0^DUZ required",! Q
 N FDA,DIERR
 S FDA(200,DUZ_",",9)="@"
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) W "0^FILE^DIE error",! Q
 W "1^OK",! Q
