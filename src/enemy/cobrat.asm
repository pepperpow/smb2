
;
; Cobrat (Ground)
; ===============
;
; Bobs up and down until the player gets close, then jumps up, chases, and shoots bullets
;
; EnemyVariable = target y-position
; EnemyArray_480 = flag that gets enabled when the player gets close
; EnemyArray_477 = counter used to determine bobbing direction
; ObjectAnimationTimer = counter used to determine how quickly Cobrat turns
; EnemyArray_453 = counter used to determine when to fire a bullet
;
EnemyInit_Cobrats:
	JSR EnemyInit_Basic

	LDA ObjectYLo, X
	SEC
	SBC #$08
	STA EnemyVariable, X
	RTS

EnemyBehavior_CobratGround:
	JSR EnemyBehavior_CheckDamagedInterrupt

	JSR EnemyBehavior_Check42FPhysicsInterrupt

	JSR EnemyBehavior_CheckBeingCarriedTimerInterrupt

	JSR ObjectTileCollision

	LDA EnemyArray_480, X
	BNE EnemyBehavior_CobratGround_Jump

	STA ObjectXVelocity, X
	JSR EnemyFindWhichSidePlayerIsOn

	LDA byte_RAM_F
	ADC #$40
	CMP #$80
	BCS EnemyBehavior_CobratGround_Bob

	INC EnemyArray_480, X
	LDA #$C0
	STA ObjectYVelocity, X
	BNE EnemyBehavior_CobratGround_Jump

EnemyBehavior_CobratGround_Bob:
	INC EnemyArray_477, X
	LDY #$FC
	LDA EnemyArray_477, X
	AND #$20
	BEQ EnemyBehavior_CobratGround_BobMovement

	LDY #$04

EnemyBehavior_CobratGround_BobMovement:
	STY ObjectYVelocity, X
	JSR ApplyObjectPhysicsY

	LDA #ObjAttrib_16x32 | ObjAttrib_BehindBackground | ObjAttrib_Palette1
	STA ObjectAttributes, X
	JMP RenderSprite

EnemyBehavior_CobratGround_Jump:
	LDA ObjectYVelocity, X
	BMI EnemyBehavior_CobratGround_Movement

	LDA EnemyVariable, X
	SEC
	SBC #$18
	CMP ObjectYLo, X
	BCS EnemyBehavior_CobratGround_Movement

	STA ObjectYLo, X
	LDA #$00
	STA ObjectYVelocity, X

EnemyBehavior_CobratGround_Movement:
	JSR ApplyObjectMovement

	INC ObjectAnimationTimer, X
	LDA ObjectAnimationTimer, X
	PHA
	AND #$3F
	BNE EnemyBehavior_CobratGround_AfterBasicMovement

	JSR EnemyInit_BasicMovementTowardPlayer

EnemyBehavior_CobratGround_AfterBasicMovement:
	PLA
	BNE EnemyBehavior_CobratGround_CheckCollision

	LDA #$18
	STA EnemyArray_453, X

EnemyBehavior_CobratGround_CheckCollision:
	LDA EnemyCollision, X
	AND #$03
	BEQ EnemyBehavior_CobratGround_SetAttributes

	JSR EnemyBehavior_TurnAround

EnemyBehavior_CobratGround_SetAttributes:
	LDA #ObjAttrib_16x32 | ObjAttrib_Palette1
	LDY ObjectYVelocity, X
	BPL EnemyBehavior_CobratGround_Shoot

	LDA #ObjAttrib_16x32 | ObjAttrib_BehindBackground | ObjAttrib_Palette1

EnemyBehavior_CobratGround_Shoot:
	JMP EnemyBehavior_CobratJar_Shoot


;
; Cobrat (Jar)
; ============
;
; Bobs up and down, then occasionally jumps up to shoot a bullet at the player
;
; EnemyVariable = target y-position
; EnemyArray_B1 = flag that gets set when the Cobrat jumps
; byte_RAM_10 = counter used to determine when to jump and fire
; EnemyArray_453 = counter used to determine when to fire a bullet
;
EnemyBehavior_CobratJar:
	JSR EnemyBehavior_CheckDamagedInterrupt

	JSR EnemyBehavior_Check42FPhysicsInterrupt

	JSR EnemyBehavior_CheckBeingCarriedTimerInterrupt

	JSR ObjectTileCollision

	LDA EnemyCollision, X
	AND #CollisionFlags_Up
	BEQ EnemyBehavior_CobratJar_Uncorked

EnemyBehavior_CobratJar_Corked:
	LDA EnemyVariable, X
	STA ObjectYLo, X
	RTS

EnemyBehavior_CobratJar_Uncorked:
	JSR EnemyFindWhichSidePlayerIsOn

	INY
	STY EnemyMovementDirection, X

	LDA EnemyArray_B1, X
	BNE EnemyBehavior_CobratJar_Jump

	LDA EnemyTimer, X
	BNE EnemyBehavior_CobratJar_Bob

	LDA #$D0
	STA ObjectYVelocity, X
	INC EnemyArray_B1, X
	JMP EnemyBehavior_CobratJar_Movement

EnemyBehavior_CobratJar_Bob:
	LDY #$FC
	LDA byte_RAM_10
	AND #$20
	BEQ EnemyBehavior_CobratJar_BobMovement

	LDY #$04

EnemyBehavior_CobratJar_BobMovement:
	STY ObjectYVelocity, X
	JSR ApplyObjectPhysicsY

	JMP EnemyBehavior_CobratJar_SetAttributes

EnemyBehavior_CobratJar_Jump:
	INC ObjectAnimationTimer, X
	LDA ObjectYVelocity, X
	BMI EnemyBehavior_CobratJar_Movement

	BNE EnemyBehavior_CobratJar_CheckLanding

	LDA #$10
	STA EnemyArray_453, X

EnemyBehavior_CobratJar_CheckLanding:
	LDA ObjectYVelocity, X
	BMI EnemyBehavior_CobratJar_CheckReset

	LDA EnemyCollision, X
	AND #CollisionFlags_Down
	BEQ EnemyBehavior_CobratJar_CheckReset

	LDA byte_RAM_E
	SEC
	SBC #$6F
	CMP #$06
	BCC EnemyBehavior_CobratJar_CheckReset

EnemyBehavior_CobratJar_Blocked:
	LDA #EnemyState_Dead
	STA EnemyState, X
	LDA #$E0
	STA ObjectYVelocity, X
	LDA #DPCM_BossHurt
	STA DPCMQueue

EnemyBehavior_CobratJar_CheckReset:
	LDA EnemyVariable, X
	CMP ObjectYLo, X
	BCS EnemyBehavior_CobratJar_Movement

	STA ObjectYLo, X
	LDA #$00
	STA EnemyArray_B1, X
	LDA #$A0
	STA EnemyTimer, X

EnemyBehavior_CobratJar_Movement:
	JSR ApplyObjectMovement_Vertical

EnemyBehavior_CobratJar_SetAttributes:
	LDA #ObjAttrib_16x32 | ObjAttrib_BehindBackground | ObjAttrib_Palette1

EnemyBehavior_CobratJar_Shoot:
	STA ObjectAttributes, X
	LDA EnemyArray_453, X
	BEQ EnemyBehavior_CobratJar_Render

	CMP #$05
	BNE EnemyBehavior_CobratJar_RenderShot

	JSR CreateBullet

EnemyBehavior_CobratJar_RenderShot:
	LDA #$64 ; firing bullet
	JMP RenderSprite_DrawObject

EnemyBehavior_CobratJar_Render:
	JMP RenderSprite

