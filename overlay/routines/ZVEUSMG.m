ZVEUSMG ; VE — User management broker helpers (keys, e-sig, creds, lifecycle)
 ;;1.0;VE USERMG;**;Mar 21, 2026
 ; Overlay RPCs for tenant-admin direct writes. Register via INSTALL^ZVEUSMG.
 ; Keys use ^XUSEC(KEY,DUZ) (standard Kernel pattern).
 ; Output uses R() array (broker type 2) — NOT W-based.
 ; IMPORTANT: Target user param is TDUZ (not DUZ) to avoid shadowing system DUZ.
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
KEYS(R,ACT,TDUZ,KNM) ; RPC ZVE USMG KEYS — params: ACTION, target-DUZ, KEY name
 N E S E=""
 I $G(ACT)="" S E="ACTION required"
 I '+$G(TDUZ) S E="DUZ required"
 I $G(KNM)="" S E="KEY required"
 I E]"" S R(0)="0^"_E Q
 I ACT'="ADD",ACT'="DEL" S R(0)="0^Invalid ACTION" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 ;
 ; ORES/ORELSE mutual exclusion check (CONFLICT NEWed at this level)
 N CONFLICT S CONFLICT=0
 I ACT="ADD" D
 . I KNM="ORES" D  Q:CONFLICT
 . . N KIEN S KIEN=0
 . . F  S KIEN=$O(^VA(200,+TDUZ,51,KIEN)) Q:'KIEN  D  Q:CONFLICT
 . . . I $P($G(^VA(200,+TDUZ,51,KIEN,0)),U,1)="ORELSE" D
 . . . . S CONFLICT=1,R(0)="0^Cannot assign ORES: user holds ORELSE (mutually exclusive)"
 . I KNM="ORELSE" D  Q:CONFLICT
 . . N KIEN S KIEN=0
 . . F  S KIEN=$O(^VA(200,+TDUZ,51,KIEN)) Q:'KIEN  D  Q:CONFLICT
 . . . I $P($G(^VA(200,+TDUZ,51,KIEN,0)),U,1)="ORES" D
 . . . . S CONFLICT=1,R(0)="0^Cannot assign ORELSE: user holds ORES (mutually exclusive)"
 Q:CONFLICT
 ;
 I ACT="ADD" D
 . S ^XUSEC(KNM,+TDUZ)=""
 . N MAXK S MAXK=+$O(^VA(200,+TDUZ,51,"A"),-1)+1
 . S ^VA(200,+TDUZ,51,MAXK,0)=KNM
 . S ^VA(200,+TDUZ,51,"B",KNM,MAXK)=""
 . I '$P($G(^VA(200,+TDUZ,51,0)),U,1) S $P(^VA(200,+TDUZ,51,0),U,1)="200.051"
 . S $P(^VA(200,+TDUZ,51,0),U,3)=MAXK
 . S $P(^VA(200,+TDUZ,51,0),U,4)=$P($G(^VA(200,+TDUZ,51,0)),U,4)+1
 . D AUDITLOG^ZVEADMIN("KEY-ASSIGN",+TDUZ,"Key="_KNM)
 I ACT="DEL" D
 . N KIEN,FOUND S FOUND=0,KIEN=0
 . F  S KIEN=$O(^VA(200,+TDUZ,51,KIEN)) Q:'KIEN  D  Q:FOUND
 . . I $P($G(^VA(200,+TDUZ,51,KIEN,0)),U,1)=KNM D
 . . . K ^VA(200,+TDUZ,51,KIEN)
 . . . K ^VA(200,+TDUZ,51,"B",KNM,KIEN)
 . . . S FOUND=1
 . I 'FOUND S R(0)="0^Key not assigned: "_KNM Q
 . K ^XUSEC(KNM,+TDUZ)
 . S $P(^VA(200,+TDUZ,51,0),U,4)=$P($G(^VA(200,+TDUZ,51,0)),U,4)-1
 . D AUDITLOG^ZVEADMIN("KEY-REMOVE",+TDUZ,"Key="_KNM)
 S R(0)="1^OK^"_ACT Q
 ;
ESIG(R,TDUZ,CODE) ; RPC ZVE USMG ESIG
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 I $G(CODE)="" S R(0)="0^CODE required" Q
 N FDA,DIERR
 S FDA(200,TDUZ_",",20.4)=$$EN^XUSHSH(CODE)
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) S R(0)="0^FILE^DIE error" Q
 D AUDITLOG^ZVEADMIN("ESIG-SET",+TDUZ,"E-sig set via USMG")
 S R(0)="1^OK" Q
 ;
CRED(R,TDUZ,AC,VC) ; RPC ZVE USMG CRED
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 I $G(AC)=""!($G(VC)="") S R(0)="0^ACCESS and VERIFY required" Q
 N FDA,DIERR
 S FDA(200,TDUZ_",",2)=$$EN^XUSHSH(AC)
 S FDA(200,TDUZ_",",11)=$$EN^XUSHSH(VC)
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) S R(0)="0^FILE^DIE error" Q
 D AUDITLOG^ZVEADMIN("CRED-SET",+TDUZ,"Credentials updated via admin")
 S R(0)="1^OK" Q
 ;
ADD(R,NM,AC,VC) ; RPC ZVE USMG ADD — minimal user creation
 I $G(NM)="" S R(0)="0^NAME required" Q
 N FDA,IEN,DIERR
 S FDA(200,"+1,",.01)=NM
 D UPDATE^DIE("E",$NA(FDA),$NA(IEN),$NA(DIERR))
 I $D(DIERR) S R(0)="0^UPDATE^DIE failed" Q
 ; Set hashed credentials via FILE^DIE (internal format)
 N CFDA,CERR
 I $G(AC)]"" S CFDA(200,IEN(1)_",",2)=$$EN^XUSHSH(AC)
 I $G(VC)]"" S CFDA(200,IEN(1)_",",11)=$$EN^XUSHSH(VC)
 I $D(CFDA)>1 D FILE^DIE("","CFDA","CERR")
 D AUDITLOG^ZVEADMIN("USER-ADD",+$G(IEN(1)),"Created user "_NM)
 S R(0)="1^"_$G(IEN(1)) Q
 ;
DEACT(R,TDUZ) ; RPC ZVE USMG DEACT — set field 9 = today
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 N FDA,DIERR
 S FDA(200,TDUZ_",",9)=DT
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) S R(0)="0^FILE^DIE error" Q
 D AUDITLOG^ZVEADMIN("USER-DEACT",+TDUZ,"Deactivated")
 S R(0)="1^OK" Q
 ;
REACT(R,TDUZ) ; RPC ZVE USMG REACT — delete termination date
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 N FDA,DIERR
 S FDA(200,TDUZ_",",9)="@"
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) S R(0)="0^FILE^DIE error" Q
 D AUDITLOG^ZVEADMIN("USER-REACT",+TDUZ,"Reactivated")
 S R(0)="1^OK" Q
