ZVEADMN1 ; VE — Admin Keys, Params, Roles, Divisions, Alerts RPCs ; Apr 2026
 ;;1.0;VISTA EVOLVED;**1**;Apr 2026;Build 1
 ;
 ; RPCs in this routine:
 ;   ZVE KEY LIST       - List security keys from #19.1
 ;   ZVE KEY ASSIGN     - Assign key to user (ORES/ORELSE mutex)
 ;   ZVE KEY REMOVE     - Remove key from user
 ;   ZVE ESIG MANAGE    - E-sig status/clear (never view)
 ;   ZVE ROLE TEMPLATE  - Role template bundles
 ;   ZVE PARAM GET      - Read kernel parameters
 ;   ZVE PARAM SET      - Set parameter with VHA enforcement
 ;   ZVE DIVISION LIST  - List all divisions
 ;   ZVE DIVISION ASSIGN- Assign division to user
 ;
 Q  ; No direct entry
 ;
INSTALL ;
 W !,"=== Installing ZVEADMN1 RPCs ==="
 D REGONE^ZVEADMIN("ZVE KEY LIST","KEYLIST","ZVEADMN1","List security keys")
 D REGONE^ZVEADMIN("ZVE KEY ASSIGN","KEYASSN","ZVEADMN1","Assign key to user")
 D REGONE^ZVEADMIN("ZVE KEY REMOVE","KEYREM","ZVEADMN1","Remove key from user")
 D REGONE^ZVEADMIN("ZVE ESIG MANAGE","ESIGMGT","ZVEADMN1","E-signature management")
 D REGONE^ZVEADMIN("ZVE ROLE TEMPLATE","ROLETPL","ZVEADMN1","Role template key bundles")
 D REGONE^ZVEADMIN("ZVE PARAM GET","PARAMGT","ZVEADMN1","Read kernel parameters")
 D REGONE^ZVEADMIN("ZVE PARAM SET","PARAMST","ZVEADMN1","Set parameter with VHA enforcement")
 D REGONE^ZVEADMIN("ZVE DIVISION LIST","DIVLIST","ZVEADMN1","List all divisions")
 D REGONE^ZVEADMIN("ZVE DIVISION ASSIGN","DIVASN","ZVEADMN1","Assign division to user")
 W !,"=== ZVEADMN1 install complete ==="
 Q
 ;
 ; ============================================================
 ; ZVE KEY LIST — List security keys
 ; ============================================================
 ; Params: TARGETDUZ (if provided: keys for that user; if empty: all keys)
 ; Output:
 ;   "1^COUNT^OK"
 ;   Per-key: "IEN^NAME^DESCRIPTION^HOLDERS"
 ;   If TARGETDUZ: "IEN^NAME" (just user's assigned keys)
 ; ============================================================
KEYLIST(R,TARGETDUZ) ;
 N CNT,OUT
 S CNT=0
 S TARGETDUZ=$G(TARGETDUZ)
 ;
 I TARGETDUZ]"",+TARGETDUZ>0 D  G KLOUT
 . ; List keys for specific user
 . N KIEN,KNAME,KKIEN
 . S KIEN=0 F  S KIEN=$O(^VA(200,+TARGETDUZ,51,KIEN)) Q:'KIEN  D
 . . S KNAME=$P($G(^VA(200,+TARGETDUZ,51,KIEN,0)),U,1) Q:KNAME=""
 . . S KKIEN=$O(^DIC(19.1,"B",KNAME,0))
 . . S CNT=CNT+1,OUT(CNT)=$G(KKIEN)_U_KNAME
 ;
 ; List all keys from SECURITY KEY #19.1
 N IEN,NM,DESC,HCNT
 S NM="" F  S NM=$O(^DIC(19.1,"B",NM)) Q:NM=""  D
 . S IEN=$O(^DIC(19.1,"B",NM,0)) Q:'IEN
 . S DESC=$P($G(^DIC(19.1,IEN,1)),U,1)
 . ; Count holders via ^XUSEC cross-reference
 . S HCNT=0 N D S D=0 F  S D=$O(^XUSEC(NM,D)) Q:'D  S HCNT=HCNT+1
 . S CNT=CNT+1,OUT(CNT)=IEN_U_NM_U_DESC_U_HCNT
 ;
KLOUT ;
 S R(0)="1^"_CNT_"^OK"
 N I F I=1:1:CNT S R(I)=OUT(I)
 Q
 ;
 ; ============================================================
 ; ZVE KEY ASSIGN — Assign key with ORES/ORELSE mutual exclusion
 ; ============================================================
 ; Params: TARGETDUZ, KEYNAME
 ; Output: "1^OK^keyname" or "0^error"
 ; CRITICAL: Enforces ORES/ORELSE mutual exclusion per VA policy
 ; ============================================================
KEYASSN(R,TARGETDUZ,KEYNAME) ;
 N CONFLICT
 S TARGETDUZ=+$G(TARGETDUZ)
 I 'TARGETDUZ S R(0)="0^DUZ required" Q
 I '$D(^VA(200,TARGETDUZ,0)) S R(0)="0^User not found" Q
 S KEYNAME=$G(KEYNAME) I KEYNAME="" S R(0)="0^KEY name required" Q
 ;
 ; Verify key exists in SECURITY KEY #19.1
 N KEYIEN S KEYIEN=$O(^DIC(19.1,"B",KEYNAME,0))
 I 'KEYIEN S R(0)="0^Key not found: "_KEYNAME Q
 ;
 ; === ORES/ORELSE MUTUAL EXCLUSION CHECK ===
 I KEYNAME="ORES" D  Q:$G(CONFLICT)
 . N KIEN S KIEN=0
 . F  S KIEN=$O(^VA(200,TARGETDUZ,51,KIEN)) Q:'KIEN  D  Q:$G(CONFLICT)
 . . I $P($G(^VA(200,TARGETDUZ,51,KIEN,0)),U,1)="ORELSE" D
 . . . S CONFLICT=1
 . . . S R(0)="0^Cannot assign ORES: user holds ORELSE (mutually exclusive per VA policy)"
 ;
 I KEYNAME="ORELSE" D  Q:$G(CONFLICT)
 . N KIEN S KIEN=0
 . F  S KIEN=$O(^VA(200,TARGETDUZ,51,KIEN)) Q:'KIEN  D  Q:$G(CONFLICT)
 . . I $P($G(^VA(200,TARGETDUZ,51,KIEN,0)),U,1)="ORES" D
 . . . S CONFLICT=1
 . . . S R(0)="0^Cannot assign ORELSE: user holds ORES (mutually exclusive per VA policy)"
 ;
 ; Check if already assigned
 N KIEN,ALREADY S ALREADY=0,KIEN=0
 F  S KIEN=$O(^VA(200,TARGETDUZ,51,KIEN)) Q:'KIEN  D  Q:ALREADY
 . I $P($G(^VA(200,TARGETDUZ,51,KIEN,0)),U,1)=KEYNAME S ALREADY=1
 I ALREADY S R(0)="0^Key already assigned: "_KEYNAME Q
 ;
 ; Assign via ^XUSEC (standard Kernel pattern)
 S ^XUSEC(KEYNAME,TARGETDUZ)=""
 ;
 ; Also file into NEW PERSON #200 field 51 (KEYS subfile)
 N MAXK S MAXK=+$O(^VA(200,TARGETDUZ,51,"A"),-1)+1
 S ^VA(200,TARGETDUZ,51,MAXK,0)=KEYNAME
 S ^VA(200,TARGETDUZ,51,"B",KEYNAME,MAXK)=""
 ; Update subfile header
 S $P(^VA(200,TARGETDUZ,51,0),U,3)=MAXK
 S $P(^VA(200,TARGETDUZ,51,0),U,4)=$P($G(^VA(200,TARGETDUZ,51,0)),U,4)+1
 ;
 D AUDITLOG^ZVEADMIN("KEY-ASSIGN",TARGETDUZ,"Key="_KEYNAME)
 ;
 S R(0)="1^OK^"_KEYNAME Q
 ;
 ; ============================================================
 ; ZVE KEY REMOVE — Remove key from user
 ; ============================================================
 ; Params: TARGETDUZ, KEYNAME
 ; Output: "1^OK^keyname" or "0^error"
 ; ============================================================
KEYREM(R,TARGETDUZ,KEYNAME) ;
 S TARGETDUZ=+$G(TARGETDUZ)
 I 'TARGETDUZ S R(0)="0^DUZ required" Q
 S KEYNAME=$G(KEYNAME) I KEYNAME="" S R(0)="0^KEY name required" Q
 ;
 ; Remove from ^XUSEC
 K ^XUSEC(KEYNAME,TARGETDUZ)
 ;
 ; Remove from NEW PERSON #200 field 51
 N KIEN,FOUND S FOUND=0,KIEN=0
 F  S KIEN=$O(^VA(200,TARGETDUZ,51,KIEN)) Q:'KIEN  D  Q:FOUND
 . I $P($G(^VA(200,TARGETDUZ,51,KIEN,0)),U,1)=KEYNAME D
 . . K ^VA(200,TARGETDUZ,51,KIEN)
 . . K ^VA(200,TARGETDUZ,51,"B",KEYNAME,KIEN)
 . . S FOUND=1
 ;
 I 'FOUND S R(0)="0^Key not assigned: "_KEYNAME Q
 ;
 ; Update subfile header count
 S $P(^VA(200,TARGETDUZ,51,0),U,4)=$P($G(^VA(200,TARGETDUZ,51,0)),U,4)-1
 ;
 D AUDITLOG^ZVEADMIN("KEY-REMOVE",TARGETDUZ,"Key="_KEYNAME)
 ;
 S R(0)="1^OK^"_KEYNAME Q
 ;
 ; ============================================================
 ; ZVE ESIG MANAGE — E-signature management
 ; ============================================================
 ; Params: TARGETDUZ, ACTION (STATUS|CLEAR)
 ; Output: "1^STATUS^SET|NONE" or "1^CLEARED" or "0^error"
 ; NOTE: No VIEW action. Admins can NEVER see e-sig codes.
 ; ============================================================
ESIGMGT(R,TARGETDUZ,ACTION) ;
 S TARGETDUZ=+$G(TARGETDUZ)
 I 'TARGETDUZ S R(0)="0^DUZ required" Q
 I '$D(^VA(200,TARGETDUZ,0)) S R(0)="0^User not found" Q
 S ACTION=$$UP^XLFSTR($G(ACTION))
 ;
 I ACTION="STATUS" D  Q
 . N HAS S HAS=$S($D(^VA(200,TARGETDUZ,20))#2:"SET",1:"NONE")
 . N BLOCK S BLOCK=$$GET1^DIQ(200,TARGETDUZ_",",20.2,"E")
 . S R(0)="1^STATUS^"_HAS_"^"_BLOCK
 ;
 I ACTION="CLEAR" D  Q
 . I '$D(^VA(200,TARGETDUZ,20)) S R(0)="0^No e-signature to clear" Q
 . K ^VA(200,TARGETDUZ,20)
 . D AUDITLOG^ZVEADMIN("ESIG-CLEAR",TARGETDUZ,"Admin cleared e-signature")
 . S R(0)="1^CLEARED"
 ;
 S R(0)="0^Invalid ACTION: "_ACTION_" (use STATUS or CLEAR)" Q
 ;
 ; ============================================================
 ; ZVE ROLE TEMPLATE — Return role template key bundles
 ; ============================================================
 ; Params: ROLENAME (PHYSICIAN, NURSE, PHARMACIST, etc.)
 ; Output:
 ;   "1^1^OK"
 ;   "ROLE^rolename^description"
 ;   "KEY^keyname1"
 ;   "KEY^keyname2" ...
 ;   "CTX^contextOptionName"
 ; ============================================================
ROLETPL(R,ROLENAME) ;
 S ROLENAME=$$UP^XLFSTR($G(ROLENAME))
 I ROLENAME="" S R(0)="0^ROLE name required" Q
 ;
 ; Role templates — hardcoded per AUX-06 Security Matrix
 ; These map human roles to VistA key bundles
 N DESC,KEYS,CTX
 ;
 I ROLENAME="PHYSICIAN" D
 . S DESC="Licensed physician provider"
 . S KEYS="ORES^PROVIDER^OR CPRS GUI CHART^GMV MANAGER^TIU SIGN DOCUMENT"
 . S CTX="ZVE CLINICAL CONTEXT"
 E  I ROLENAME="NURSE" D
 . S DESC="Registered nurse"
 . S KEYS="ORELSE^PROVIDER^OR CPRS GUI CHART^GMV MANAGER^PSB NURSE"
 . S CTX="ZVE CLINICAL CONTEXT"
 E  I ROLENAME="PHARMACIST" D
 . S DESC="Licensed pharmacist"
 . S KEYS="ORES^PROVIDER^PSJ PHARMACIST^PSJ PHDRUG USER^PSORPH"
 . S CTX="ZVE PHARMACY CONTEXT"
 E  I ROLENAME="CLERK" D
 . S DESC="Registration/scheduling clerk"
 . S KEYS="DG REGISTRATION^SD SUPERVISOR"
 . S CTX="ZVE PATIENT CONTEXT"
 E  I ROLENAME="LAB TECH" D
 . S DESC="Laboratory technician"
 . S KEYS="LRLAB^LRVERIFY"
 . S CTX="ZVE LAB CONTEXT"
 E  I ROLENAME="RADIOLOGY TECH" D
 . S DESC="Radiology technician"
 . S KEYS="RA VERIFY^RA TECHNOLOGIST"
 . S CTX="ZVE RADIOLOGY CONTEXT"
 E  I ROLENAME="ADMIN" D
 . S DESC="System administrator / ADPAC"
 . S KEYS="XUMGR^XUPROGMODE^XUPROG^XUSTATS"
 . S CTX="ZVE ADMIN CONTEXT"
 E  I ROLENAME="WARD CLERK" D
 . S DESC="Ward clerk / unit secretary"
 . S KEYS="DG ADMIT^DG DISCHARGE^DG TRANSFER^DG REGISTRATION"
 . S CTX="ZVE PATIENT CONTEXT"
 E  I ROLENAME="BILLING" D
 . S DESC="Billing / revenue cycle clerk"
 . S KEYS="IB BILLING CLERK"
 . S CTX="ZVE BILLING CONTEXT"
 E  I ROLENAME="SOCIAL WORKER" D
 . S DESC="Licensed clinical social worker"
 . S KEYS="ORELSE^PROVIDER^SW VERIFIED"
 . S CTX="ZVE CLINICAL CONTEXT"
 E  I ROLENAME="DIETITIAN" D
 . S DESC="Registered dietitian"
 . S KEYS="ORELSE^FH SUPERVISOR"
 . S CTX="ZVE CLINICAL CONTEXT"
 E  I ROLENAME="MENTAL HEALTH" D
 . S DESC="Mental health provider (psychologist/psychiatrist)"
 . S KEYS="ORES^PROVIDER^YS BROKER1"
 . S CTX="ZVE CLINICAL CONTEXT"
 E  I ROLENAME="SURGEON" D
 . S DESC="Surgical provider"
 . S KEYS="ORES^PROVIDER^SR SURGEON"
 . S CTX="ZVE SURGERY CONTEXT"
 E  I ROLENAME="VOLUNTEER" D
 . S DESC="Volunteer / limited access"
 . S KEYS=""
 . S CTX=""
 E  D  Q
 . S R(0)="0^Unknown role: "_ROLENAME
 ;
 N LN S LN=0
 S R(LN)="1^1^OK"
 S LN=LN+1,R(LN)="ROLE"_U_ROLENAME_U_DESC
 N I,K F I=1:1:$L(KEYS,U) S K=$P(KEYS,U,I) I K]"" S LN=LN+1,R(LN)="KEY"_U_K
 I CTX]"" S LN=LN+1,R(LN)="CTX"_U_CTX
 Q
 ;
 ; ============================================================
 ; ZVE PARAM GET — Read kernel system parameters
 ; ============================================================
 ; Params: none (returns all KSP params)
 ; Output:
 ;   "1^COUNT^OK"
 ;   "PARAM^name^value^description"
 ; ============================================================
PARAMGT(R) ;
 N CNT,OUT
 S CNT=0
 ;
 ; Read KERNEL SYSTEM PARAMETERS #8989.3
 ; IEN 1 is always the system-level entry
 I '$D(^XTV(8989.3,1,0)) S R(0)="0^No Kernel System Parameters found" Q
 ;
 ; Key parameters — field numbers verified against DD
 N DOMAIN S DOMAIN=$$GET1^DIQ(8989.3,"1,",.01,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"DOMAIN"_U_DOMAIN_U_"Site domain name"
 ;
 N SITE S SITE=$$GET1^DIQ(8989.3,"1,",217,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"SITE NAME"_U_SITE_U_"Facility name"
 ;
 N PROD S PROD=$$GET1^DIQ(8989.3,"1,",501,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"PRODUCTION"_U_PROD_U_"Production/test indicator"
 ;
 N AUTOLO S AUTOLO=$$GET1^DIQ(8989.3,"1,",210,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"AUTOLOGOFF"_U_AUTOLO_U_"Session timeout (seconds)"
 ;
 N LOCKOUT S LOCKOUT=$$GET1^DIQ(8989.3,"1,",202,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"LOCKOUT ATTEMPTS"_U_LOCKOUT_U_"Failed sign-in attempts before lockout"
 ;
 N PWEXP S PWEXP=$$GET1^DIQ(8989.3,"1,",214,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"PASSWORD EXPIRATION"_U_PWEXP_U_"Days until verify code expires"
 ;
 N BRKTMO S BRKTMO=$$GET1^DIQ(8989.3,"1,",230,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"BROKER TIMEOUT"_U_BRKTMO_U_"Broker activity timeout"
 ;
 N AGENCY S AGENCY=$$GET1^DIQ(8989.3,"1,",9,"E")
 S CNT=CNT+1,OUT(CNT)="PARAM"_U_"AGENCY CODE"_U_AGENCY_U_"VA agency code"
 ;
 S R(0)="1^"_CNT_"^OK"
 N I F I=1:1:CNT S R(I)=OUT(I)
 Q
 ;
 ; ============================================================
 ; ZVE PARAM SET — Set parameter with VHA Directive 6500 enforcement
 ; ============================================================
 ; Params: PARAMNAME, VALUE, REASON
 ; Output: "1^OK^paramname^value" or "0^error"
 ; ============================================================
PARAMST(R,PARAMNAME,VALUE,REASON) ;
 S PARAMNAME=$$UP^XLFSTR($G(PARAMNAME))
 I PARAMNAME="" S R(0)="0^Parameter name required" Q
 S VALUE=$G(VALUE)
 ;
 ; === VHA DIRECTIVE 6500 ENFORCEMENT ===
 N REJECT
 I PARAMNAME="AUTOLOGOFF" D  Q:$G(REJECT)
 . I +VALUE>900 S REJECT=1 S R(0)="0^Session timeout cannot exceed 900 seconds (15 min) per VHA Directive 6500" Q
 . I +VALUE<60 S REJECT=1 S R(0)="0^Session timeout cannot be less than 60 seconds per VHA Directive 6500" Q
 ;
 I PARAMNAME="LOCKOUT ATTEMPTS" D  Q:$G(REJECT)
 . I +VALUE>5 S REJECT=1 S R(0)="0^Failed sign-in lockout cannot exceed 5 attempts per VHA Directive 6500" Q
 . I +VALUE<1 S REJECT=1 S R(0)="0^Failed sign-in lockout must be at least 1 per VHA Directive 6500" Q
 ;
 I PARAMNAME="PASSWORD EXPIRATION" D  Q:$G(REJECT)
 . I +VALUE>90 S REJECT=1 S R(0)="0^Password expiration cannot exceed 90 days per VHA Directive 6500" Q
 . I +VALUE<1 S REJECT=1 S R(0)="0^Password expiration must be at least 1 day per VHA Directive 6500" Q
 ;
 ; Map parameter names to KSP #8989.3 fields (verified against DD)
 N FNUM
 I PARAMNAME="AUTOLOGOFF" S FNUM=210
 E  I PARAMNAME="LOCKOUT ATTEMPTS" S FNUM=202
 E  I PARAMNAME="PASSWORD EXPIRATION" S FNUM=214
 E  I PARAMNAME="BROKER TIMEOUT" S FNUM=230
 E  I PARAMNAME="AGENCY CODE" S FNUM=9
 E  D  Q
 . S R(0)="0^Unknown parameter: "_PARAMNAME_" (supported: AUTOLOGOFF, LOCKOUT ATTEMPTS, PASSWORD EXPIRATION, BROKER TIMEOUT, AGENCY CODE)"
 ;
 N FDA,DIERR
 S FDA(8989.3,"1,",FNUM)=VALUE
 D FILE^DIE("E","FDA","DIERR")
 I $D(DIERR) S R(0)="0^Failed to set "_PARAMNAME_": "_$G(DIERR("DIERR",1,"TEXT",1)) Q
 ;
 D AUDITLOG^ZVEADMIN("PARAM-SET","KSP",PARAMNAME_"="_VALUE_" Reason: "_$G(REASON))
 ;
 S R(0)="1^OK^"_PARAMNAME_"^"_VALUE Q
 ;
 ; ============================================================
 ; ZVE DIVISION LIST — List all divisions from #40.8
 ; ============================================================
 ; Params: none
 ; Output:
 ;   "1^COUNT^OK"
 ;   "IEN^NAME^STATION^ADDRESS^PHONE^STATUS"
 ; ============================================================
DIVLIST(R) ;
 N CNT,OUT,IEN,NM,STATION,ADDR,PHONE,STATUS
 S CNT=0
 ;
 ; File 40.8 data stored in ^DG(40.8), NOT ^DIC(40.8)
 S IEN=0 F  S IEN=$O(^DG(40.8,IEN)) Q:'IEN  Q:IEN="B"  D
 . S NM=$$GET1^DIQ(40.8,IEN_",",.01,"E") Q:NM=""
 . S STATION=$$GET1^DIQ(40.8,IEN_",",1,"E")
 . S ADDR=$$GET1^DIQ(40.8,IEN_",",1.01,"E")
 . S PHONE=$$GET1^DIQ(40.8,IEN_",",1.03,"E")
 . S STATUS=$S($P($G(^DG(40.8,IEN,0)),U,3)="Y":"ACTIVE",1:"INACTIVE")
 . S CNT=CNT+1,OUT(CNT)=IEN_U_NM_U_STATION_U_ADDR_U_PHONE_U_STATUS
 ;
 S R(0)="1^"_CNT_"^OK"
 N I F I=1:1:CNT S R(I)=OUT(I)
 Q
 ;
 ; ============================================================
 ; ZVE DIVISION ASSIGN — Add/remove division for user
 ; ============================================================
 ; Params: TARGETDUZ, DIVIEN, ACTION (ADD|REMOVE)
 ; Output: "1^OK^action" or "0^error"
 ; ============================================================
DIVASN(R,TARGETDUZ,DIVIEN,ACTION) ;
 S TARGETDUZ=+$G(TARGETDUZ)
 I 'TARGETDUZ S R(0)="0^DUZ required" Q
 I '$D(^VA(200,TARGETDUZ,0)) S R(0)="0^User not found" Q
 S DIVIEN=+$G(DIVIEN)
 I 'DIVIEN S R(0)="0^Division IEN required" Q
 I '$D(^DG(40.8,DIVIEN,0)) S R(0)="0^Division not found: "_DIVIEN Q
 S ACTION=$$UP^XLFSTR($G(ACTION,"ADD"))
 ;
 I ACTION="ADD" D  Q
 . ; Check if already assigned
 . N DI,FOUND S FOUND=0,DI=0
 . F  S DI=$O(^VA(200,TARGETDUZ,2,DI)) Q:'DI  D  Q:FOUND
 . . I $P($G(^VA(200,TARGETDUZ,2,DI,0)),U,1)=DIVIEN S FOUND=1
 . I FOUND S R(0)="0^Division already assigned" Q
 . ;
 . N MAXD S MAXD=+$O(^VA(200,TARGETDUZ,2,"A"),-1)+1
 . S ^VA(200,TARGETDUZ,2,MAXD,0)=DIVIEN
 . S ^VA(200,TARGETDUZ,2,"B",DIVIEN,MAXD)=""
 . ; Update subfile header
 . S $P(^VA(200,TARGETDUZ,2,0),U,3)=MAXD
 . S $P(^VA(200,TARGETDUZ,2,0),U,4)=$P($G(^VA(200,TARGETDUZ,2,0)),U,4)+1
 . D AUDITLOG^ZVEADMIN("DIV-ASSIGN",TARGETDUZ,"Division "_DIVIEN_" assigned")
 . S R(0)="1^OK^ADD"
 ;
 I ACTION="REMOVE" D  Q
 . N DI,FOUND S FOUND=0,DI=0
 . F  S DI=$O(^VA(200,TARGETDUZ,2,DI)) Q:'DI  D  Q:FOUND
 . . I $P($G(^VA(200,TARGETDUZ,2,DI,0)),U,1)=DIVIEN D
 . . . K ^VA(200,TARGETDUZ,2,DI)
 . . . K ^VA(200,TARGETDUZ,2,"B",DIVIEN,DI)
 . . . S FOUND=1
 . I 'FOUND S R(0)="0^Division not assigned" Q
 . ; Update subfile header count
 . S $P(^VA(200,TARGETDUZ,2,0),U,4)=$P($G(^VA(200,TARGETDUZ,2,0)),U,4)-1
 . D AUDITLOG^ZVEADMIN("DIV-REMOVE",TARGETDUZ,"Division "_DIVIEN_" removed")
 . S R(0)="1^OK^REMOVE"
 ;
 S R(0)="0^Invalid ACTION: "_ACTION_" (use ADD or REMOVE)" Q
