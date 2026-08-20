ZVEAUTH ; VE — Modern authentication helpers (email login, password reset)
 ;;1.0;VE AUTH;**;Apr 2026
 ; Overlay RPCs for self-service password reset and email-based login.
 ; Register via INSTALL^ZVEAUTH.
 ; Output uses R() array (broker type 2).
 Q
 ;
INSTALL ; Register RPCs in File #8994 (idempotent)
 W !,"=== Installing ZVE AUTH RPCs ==="
 D REGONE^ZVEUSMG("ZVE AUTH EMAILOOKUP","EMAILKUP","ZVEAUTH","Lookup DUZ by email address")
 D REGONE^ZVEUSMG("ZVE AUTH RESETGEN","RESETGEN","ZVEAUTH","Generate password reset token")
 D REGONE^ZVEUSMG("ZVE AUTH RESETVAL","RESETVAL","ZVEAUTH","Validate password reset token")
 D REGONE^ZVEUSMG("ZVE AUTH RESETEXEC","RESETEXEC","ZVEAUTH","Execute password reset")
 D REGONE^ZVEUSMG("ZVE AUTH VCVERIFY","VCVERIFY","ZVEAUTH","Verify password for email login")
 D REGONE^ZVEUSMG("ZVE AUTH POSTLOGIN","POSTLGN","ZVEAUTH","Post-login info (last sign-on, failed attempts)")
 W !,"=== ZVE AUTH install complete ==="
 Q
 ;
EMAILKUP(R,EMAIL) ; RPC ZVE AUTH EMAILOOKUP — find DUZ by email (File 200 field .151)
 ; Sequential scan of File 200 checking Email Address field (.151).
 ; Returns DUZ and name on match.
 I $G(EMAIL)="" S R(0)="0^Email required" Q
 N SRCH S SRCH=$$LOW^XLFSTR(EMAIL)
 I SRCH'["@" S R(0)="0^Invalid email format" Q
 ;
 N TDUZ,FOUND S FOUND=0
 S TDUZ=0
 F  S TDUZ=$O(^VA(200,TDUZ)) Q:'TDUZ  D  Q:FOUND
 . N EADDR S EADDR=$G(^VA(200,TDUZ,.15))
 . I EADDR="" Q
 . ; File 200 node .15 piece 1 = field .151 (email address)
 . S EADDR=$P(EADDR,U,1)
 . I $$LOW^XLFSTR(EADDR)=SRCH D
 . . S FOUND=1
 . . N NM S NM=$$GET1^DIQ(200,TDUZ_",",.01,"E")
 . . S R(0)="1^"_TDUZ_"^"_NM
 ;
 I 'FOUND S R(0)="0^No user found with that email address"
 Q
 ;
RESETGEN(R,IDENT) ; RPC ZVE AUTH RESETGEN — generate reset token
 ; IDENT can be DUZ (numeric) or email. Generates a random token stored in
 ; ^ZVEX("RESET",DUZ) with a 15-minute expiry. Returns the token so the
 ; server can include it in the reset URL.
 I $G(IDENT)="" S R(0)="0^Identifier required" Q
 ;
 ; Resolve to DUZ
 N TDUZ
 I +IDENT=IDENT,+IDENT>0 S TDUZ=+IDENT  ; numeric DUZ
 E  D  Q:'TDUZ
 . ; Treat as email lookup
 . N ELOOK
 . D EMAILKUP(.ELOOK,IDENT)
 . I +$P($G(ELOOK(0)),U,1)=1 S TDUZ=+$P(ELOOK(0),U,2)
 . E  S TDUZ=0,R(0)="0^User not found" Q
 ;
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 ;
 ; Check DISUSER — don't generate tokens for disabled accounts
 I +$P($G(^VA(200,+TDUZ,7)),U,1)=1 S R(0)="0^Account is disabled" Q
 ;
 ; Generate a random token: combination of $H, $J and DUZ hashed for unpredictability
 N TOKEN,NOW
 S NOW=$$NOW^XLFDT
 S TOKEN=$$EN^XUSHSH(TDUZ_";"_$H_";"_$J_";"_$R(999999))
 ; Truncate to 40 chars for URL friendliness
 S TOKEN=$E(TOKEN,1,40)
 ;
 ; Store with 15-minute expiry (internal FileMan format)
 N EXPIRY S EXPIRY=$$FMADD^XLFDT(NOW,0,0,15)
 S ^ZVEX("RESET",+TDUZ)=TOKEN_U_EXPIRY_U_NOW
 ;
 D AUDITLOG^ZVEADMIN("RESET-GEN",+TDUZ,"Password reset token generated")
 S R(0)="1^"_TOKEN_"^"_+TDUZ
 Q
 ;
RESETVAL(R,TOKEN,TDUZ) ; RPC ZVE AUTH RESETVAL — validate reset token
 ; Checks token matches and hasn't expired. Does NOT consume the token.
 I $G(TOKEN)="" S R(0)="0^Token required" Q
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 ;
 N STORED S STORED=$G(^ZVEX("RESET",+TDUZ))
 I STORED="" S R(0)="0^No reset request found" Q
 ;
 N STOKEN,SEXPIRY
 S STOKEN=$P(STORED,U,1)
 S SEXPIRY=$P(STORED,U,2)
 ;
 I TOKEN'=STOKEN D  Q
 . K ^ZVEX("RESET",+TDUZ)
 . D AUDITLOG^ZVEADMIN("RESET-FAIL",+TDUZ,"Invalid token presented — token cleared")
 . S R(0)="0^Invalid or expired token"
 ;
 ; Check expiry
 N NOW S NOW=$$NOW^XLFDT
 I NOW>SEXPIRY D  Q
 . K ^ZVEX("RESET",+TDUZ)
 . D AUDITLOG^ZVEADMIN("RESET-EXPIRE",+TDUZ,"Reset token expired")
 . S R(0)="0^Token has expired"
 ;
 S R(0)="1^Valid"
 Q
 ;
RESETEXEC(R,TOKEN,TDUZ,NEWVC) ; RPC ZVE AUTH RESETEXEC — execute password reset
 ; Validates the token, then sets new verify code. Consumes the token.
 I $G(TOKEN)="" S R(0)="0^Token required" Q
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I $G(NEWVC)="" S R(0)="0^New password required" Q
 ;
 ; Validate token first
 N VALR D RESETVAL(.VALR,TOKEN,TDUZ)
 I +$P($G(VALR(0)),U,1)'=1 S R(0)=VALR(0) Q
 ;
 ; Set the new verify code hash
 N FDA,DIERR
 S FDA(200,TDUZ_",",11)=$$EN^XUSHSH(NEWVC)
 ; Update verify code change date to now (so it doesn't immediately expire)
 S FDA(200,TDUZ_",",11.2)=DT
 D FILE^DIE("","FDA","DIERR")
 I $D(DIERR) S R(0)="0^Failed to set new password" Q
 ;
 ; Consume the token
 K ^ZVEX("RESET",+TDUZ)
 ;
 D AUDITLOG^ZVEADMIN("RESET-EXEC",+TDUZ,"Password reset completed via self-service")
 S R(0)="1^OK^Password has been reset"
 Q
 ;
VCVERIFY(R,TDUZ,VC) ; RPC ZVE AUTH VCVERIFY — verify password hash for email login
 ; Compares provided verify code against stored hash in File 200 field 11.
 ; Used for email-based login where broker auth can't be used (no access code).
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I $G(VC)="" S R(0)="0^Verify code required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 ;
 ; Check DISUSER
 I +$P($G(^VA(200,+TDUZ,7)),U,1)=1 S R(0)="0^Account is disabled" Q
 ;
 ; Compare hash
 N STORED S STORED=$P($G(^VA(200,+TDUZ,.1)),U,2)
 I STORED="" S R(0)="0^No verify code on file" Q
 N GIVEN S GIVEN=$$EN^XUSHSH(VC)
 I GIVEN'=STORED S R(0)="0^Invalid credentials" Q
 ;
 ; Return user info on success
 N NM S NM=$$GET1^DIQ(200,TDUZ_",",.01,"E")
 D AUDITLOG^ZVEADMIN("EMAIL-LOGIN",+TDUZ,"Email login verified")
 S R(0)="1^"_+TDUZ_"^"_NM
 Q
 ;
POSTLGN(R,TDUZ) ; RPC ZVE AUTH POSTLOGIN — post-login info
 ; Returns data shown after successful login (mirrors XUS1A^USER):
 ;   Line 0: status
 ;   Line 1: LASTDT^FAILEDATTEMPTS^GREETING
 ;   Line 2+: POST SIGN-IN MESSAGE lines from KSP 8989.3
 ;
 I '+$G(TDUZ) S R(0)="0^DUZ required" Q
 I '$D(^VA(200,+TDUZ,0)) S R(0)="0^User not found" Q
 ;
 N LSINFO,LASTFM,FAILCNT,LASTDT,GREETING,%H,NM
 S LSINFO=$G(^VA(200,+TDUZ,1.1))
 S LASTFM=+$P(LSINFO,U,1)
 S FAILCNT=+$P(LSINFO,U,2)
 ;
 ; Format last sign-on date for display
 S LASTDT=""
 I LASTFM>0 S LASTDT=$$FMTE^XLFDT(LASTFM,"5Z")
 ;
 ; Build greeting
 S %H=$P($H,",",2)
 S NM=$P($G(^VA(200,+TDUZ,0)),U,1)
 S GREETING="Good "_$S(%H<43200:"morning ",%H<61200:"afternoon ",1:"evening ")_NM
 ;
 S R(0)="1^OK"
 S R(1)=LASTDT_U_FAILCNT_U_GREETING
 ;
 ; Append POST SIGN-IN MESSAGE lines from KSP
 N I,CNT S CNT=1
 S I=0 F  S I=$O(^XTV(8989.3,1,"POST",I)) Q:I'>0  D
 . S CNT=CNT+1
 . S R(CNT)="MSG^"_$G(^XTV(8989.3,1,"POST",I,0))
 ;
 ; Update last sign-on tracking: set current date/time and clear failed count
 S $P(^VA(200,+TDUZ,1.1),U,1)=$$NOW^XLFDT
 S $P(^VA(200,+TDUZ,1.1),U,2)=0
 Q
