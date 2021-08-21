
; Offset from left boundary of screen\
SpawnBoundaryOffsets:
	.db $18 ; rightward (lo)
	.db $E0 ; leftward (lo)
	.db $01 ; rightward (hi)
	.db $FF ; leftward (hi)


CheckObjectSpawnBoundaries:
	LDA BossBeaten
	BNE CheckObjectSpawnBoundaries_Exit

	LDA IsHorizontalLevel
	JSR JumpToTableAfterJump

	.dw CheckObjectVerticalSpawnBoundaries
	.dw CheckObjectHorizontalSpawnBoundaries


CheckObjectHorizontalSpawnBoundaries:
	LDY PlayerMovementDirection
	; Low offset (pixel)
	LDA ScreenBoundaryLeftLo
	CLC
	ADC SpawnBoundaryOffsets - 1, Y
	AND #$F0
	STA byte_RAM_5
	; High offset (page)
	LDA ScreenBoundaryLeftHi
	ADC SpawnBoundaryOffsets + 1, Y
	STA byte_RAM_6
	CMP #$0A
	BCS CheckObjectSpawnBoundaries_Exit


CheckObjectHorizontalSpawnBoundaries_InitializePage:
	LDA InSubspaceOrJar
	CMP #$02
	BEQ CheckObjectSpawnBoundaries_Exit

	; Initialize the enemy data page offset
	LDX #$00
	STX byte_RAM_0
CheckObjectHorizontalSpawnBoundaries_InitializePage_Loop:
	; Stop looping and start checking the individual enemies on the current page
	CPX byte_RAM_6
	BEQ CheckObjectHorizontalSpawnBoundaries_InitializePage_Next

	; Advance to the next page of enemy data
	LDA byte_RAM_0
	TAY
	CLC
	ADC (RawEnemyData), Y
	STA byte_RAM_0
	INX
	JMP CheckObjectHorizontalSpawnBoundaries_InitializePage_Loop


CheckObjectHorizontalSpawnBoundaries_InitializePage_Next:
	; We're on the page, now start counting bytes of enemy data
	LDY byte_RAM_0
	LDA (RawEnemyData), Y
	STA byte_RAM_1
	LDX #$FF
	DEY

CheckObjectHorizontalSpawnBoundaries_InitializePage_NextObject:
	INY
	INY
	INX
	INX
	CPX byte_RAM_1
	BCC CheckObjectHorizontalSpawnBoundaries_InitializePage_InitializeObject

	LDX byte_RAM_12

CheckObjectSpawnBoundaries_Exit:
	RTS


CheckObjectHorizontalSpawnBoundaries_InitializePage_InitializeObject:
	; If bit 7 of the enemy type is set, it's already active and we should not re-initialize
	LDA (RawEnemyData), Y
	BMI CheckObjectHorizontalSpawnBoundaries_InitializePage_NextObject

	; Load the x-position of the object
	INY
	LDA (RawEnemyData), Y
	DEY
	AND #$F0
	CMP byte_RAM_5
	BNE CheckObjectHorizontalSpawnBoundaries_InitializePage_NextObject

	; Check if it's a generator/swarm object (end of enemy init table < enemy type > boss types)
	LDA (RawEnemyData), Y
	CMP #Enemy_BossBirdo
	BCS CheckObjectHorizontalSpawnBoundaries_InitializePage_RegularObject
	CMP #((EnemyInitializationTable_End - EnemyInitializationTable) / 2)
	BCC CheckObjectHorizontalSpawnBoundaries_InitializePage_RegularObject

	STA SwarmType
	RTS


CheckObjectHorizontalSpawnBoundaries_InitializePage_RegularObject:
	; Look for an enmpy slot for the object
	LDX #$04
CheckObjectHorizontalSpawnBoundaries_InitializePage_RegularObject_Loop:
	LDA EnemyState, X
	BEQ CheckObjectHorizontalSpawnBoundaries_InitializePage_CreateObject

	DEX
	BPL CheckObjectHorizontalSpawnBoundaries_InitializePage_RegularObject_Loop

	RTS

CheckObjectHorizontalSpawnBoundaries_InitializePage_CreateObject:
	; Store the object slot used
	STX byte_RAM_12

	; Set the x-position of the object (we already looked it up)
	LDA byte_RAM_5
	STA ObjectXLo, X
	LDA byte_RAM_6
	STA ObjectXHi, X

	; Set the y-position of the object (fetch from the enemy data)
	INY
	LDA (RawEnemyData), Y
	DEY
	ASL A
	ASL A
	ASL A
	ASL A
	STA ObjectYLo, X
	LDA #$00
	STA ObjectYHi, X

	JMP CheckObjectSpawnBoundaries_InitializePage_PreInitObject


CheckObjectVerticalSpawnBoundaries:
	LDA byte_RAM_10
	AND #$01
	TAY
	INY
	LDA NeedsScroll
	BEQ loc_BANK2_82FC

	AND #$03
	EOR #$03
	TAY

loc_BANK2_82FC:
	LDA ScreenYLo
	CLC
	ADC SpawnBoundaryOffsets - 1, Y
	AND #$F0
	STA byte_RAM_5
	LDA ScreenYHi
	ADC SpawnBoundaryOffsets + 1, Y
	STA byte_RAM_6
	CMP #$0A
	BCS CheckObjectSpawnBoundaries_Exit

CheckObjectVerticalSpawnBoundaries_InitializePage:
	LDX #$00
	STX byte_RAM_0
CheckObjectVerticalSpawnBoundaries_InitializePage_Loop:
	; Stop looping and start checking the individual enemies on the current page
	CPX byte_RAM_6
	BEQ CheckObjectVerticalSpawnBoundaries_InitializePage_Next

	; Advance to the next page of enemy data
	LDA byte_RAM_0
	TAY
	CLC
	ADC (RawEnemyData), Y
	STA byte_RAM_0
	INX
	JMP CheckObjectVerticalSpawnBoundaries_InitializePage_Loop


CheckObjectVerticalSpawnBoundaries_InitializePage_Next:
	; We're on the page, now start counting bytes of enemy data
	LDY byte_RAM_0
	LDA (RawEnemyData), Y
	STA byte_RAM_1
	LDX #$FF
	DEY

CheckObjectVerticalSpawnBoundaries_InitializePage_NextObject:
	INY
	INY
	INX
	INX
	CPX byte_RAM_1
	BCC CheckObjectVerticalSpawnBoundaries_InitializePage_InitializeObject

	LDX byte_RAM_12

CheckObjectVerticalSpawnBoundaries_Exit:
	RTS


CheckObjectVerticalSpawnBoundaries_InitializePage_InitializeObject:
	; If bit 7 of the enemy type is set, it's already active and we should not re-initialize
	LDA (RawEnemyData), Y
	BMI CheckObjectVerticalSpawnBoundaries_InitializePage_NextObject

	; Load the y-position of the object
	INY
	LDA (RawEnemyData), Y
	DEY
	ASL A
	ASL A
	ASL A
	ASL A
	CMP byte_RAM_5
	BNE CheckObjectVerticalSpawnBoundaries_InitializePage_NextObject

	; Check if it's a generator/swarm object (end of enemy init table < enemy type > boss types)
	LDA (RawEnemyData), Y
	CMP #Enemy_BossBirdo
	BCS CheckObjectVerticalSpawnBoundaries_InitializePage_RegularObject
	CMP #((EnemyInitializationTable_End - EnemyInitializationTable) / 2)
	BCC CheckObjectVerticalSpawnBoundaries_InitializePage_RegularObject

	STA SwarmType
	RTS


CheckObjectVerticalSpawnBoundaries_InitializePage_RegularObject:
	LDX #$04
CheckObjectVerticalSpawnBoundaries_InitializePage_RegularObject_Loop:
	LDA EnemyState, X
	BEQ CheckObjectVerticalSpawnBoundaries_InitializePage_CreateObject

	DEX
	BPL CheckObjectVerticalSpawnBoundaries_InitializePage_RegularObject_Loop

	RTS


CheckObjectVerticalSpawnBoundaries_InitializePage_CreateObject:
	; Store the object slot used
	STX byte_RAM_12

	; Set the y-position of the object (we already looked it up)
	LDA byte_RAM_5
	STA ObjectYLo, X
	LDA byte_RAM_6
	STA ObjectYHi, X

	; Set the x-position of the object (fetch from the enemy data)
	INY
	LDA (RawEnemyData), Y
	DEY
	AND #$F0
	STA ObjectXLo, X
	LDA #$00
	STA ObjectXHi, X

CheckObjectSpawnBoundaries_InitializePage_PreInitObject:
	; Reset the flag to spawn a door
	STA EnemyArray_SpawnsDoor, X
	; Stash the enemy data offset
	STY byte_RAM_C

	; Face the player (horizontal levels only)
	LDA (RawEnemyData), Y
	AND #%00111111
	CMP #Enemy_VegetableSmall
	BCS CheckObjectSpawnBoundaries_InitializePage_MarkEnemyData

	LDA IsHorizontalLevel
	BEQ CheckObjectSpawnBoundaries_InitializePage_MarkEnemyData

	JSR EnemyFindWhichSidePlayerIsOn

	LDA byte_RAM_F
	ADC #$18
	CMP #$30
	BCC CheckObjectVerticalSpawnBoundaries_Exit

CheckObjectSpawnBoundaries_InitializePage_MarkEnemyData:
	; enable bit 7 of the raw enemy data to indicate that the enemy has spawned
	LDY byte_RAM_C
	LDA (RawEnemyData), Y
	ORA #%10000000
	STA (RawEnemyData), Y

	; Is this a boss type?
IFDEF RANDOMIZER_FLAGS
	CMP #%10000000 | Enemy_Birdo
	BEQ SetBossHijack
	CMP #%10000000 | Enemy_HawkmouthBoss
	BEQ SetBossHijack
ENDIF
	CMP #%10000000 | Enemy_BossBirdo
	AND #%01111111
	BCC CheckObjectSpawnBoundaries_InitializePage_SetObjectType

	; Enable the flag to spawn a door for boss types
	AND #%00111111
	STA EnemyArray_SpawnsDoor, X
IFDEF RANDOMIZER_FLAGS
SetBossHijack:
	LDA #>SetBossHealth_Hijack
	PHA
	LDA #<SetBossHealth_Hijack - 1
	PHA
	LDA (RawEnemyData), Y
	AND #%00111111
	BNE CheckObjectSpawnBoundaries_InitializePage_SetObjectType
	
SetBossHealth_Hijack:
	LDX byte_RAM_12
	LDA EnemyHP, X
	CLC
    ADC BossHP
	STA EnemyHP, X

	LDA EnemyArray_SpawnsDoor, X
    BEQ ++
	LDA ObjectXHi, X
	STA unk_RAM_4EF, X
	LDY CurrentWorld
	LDA World_Bit_Flags, Y
    AND #CustomBitFlag_Boss_Defeated 
	BEQ ++
    INC EnemyState, X
++  RTS
ENDIF

CheckObjectSpawnBoundaries_InitializePage_SetObjectType:
	STA ObjectType, X
	TYA
	STA EnemyRawDataOffset, X
	INC EnemyState, X
	LDA ObjectType, X

InitializeEnemy:
	JSR JumpToTableAfterJump

EnemyInitializationTable:
	.dw EnemyInit_Basic ; Heart
	.dw EnemyInit_Basic ; ShyguyRed
	.dw EnemyInit_Basic ; Tweeter
	.dw EnemyInit_Basic ; ShyguyPink
	.dw EnemyInit_Basic ; Porcupo
	.dw EnemyInit_Basic ; SnifitRed
	.dw EnemyInit_Stationary ; SnifitGray
	.dw EnemyInit_Basic ; SnifitPink
	.dw EnemyInit_Basic ; Ostro
	.dw EnemyInit_Bobomb ; BobOmb
	.dw EnemyInit_Basic ; AlbatossCarryingBobOmb
	.dw EnemyInit_AlbatossStartRight ; AlbatossStartRight
	.dw EnemyInit_AlbatossStartLeft ; AlbatossStartLeft
	.dw EnemyInit_Basic ; NinjiRunning
	.dw EnemyInit_Stationary ; NinjiJumping
	.dw EnemyInit_BeezoDiving ; BeezoDiving
	.dw EnemyInit_Basic ; BeezoStraight
	.dw EnemyInit_Basic ; WartBubble
	.dw EnemyInit_Basic ; Pidgit
	.dw EnemyInit_Trouter ; Trouter
	.dw EnemyInit_Basic ; Hoopstar
	.dw EnemyInit_JarGenerators ; JarGeneratorShyguy
	.dw EnemyInit_JarGenerators ; JarGeneratorBobOmb
	.dw EnemyInit_Phanto ; Phanto
	.dw EnemyInit_Cobrats ; CobratJar
	.dw EnemyInit_Cobrats ; CobratSand
	.dw EnemyInit_Pokey ; Pokey
	.dw EnemyInit_Basic ; Bullet
	.dw EnemyInit_Birdo ; Birdo
	.dw EnemyInit_Mouser ; Mouser
	.dw EnemyInit_Basic ; Egg
	.dw EnemyInit_Tryclyde ; Tryclyde
	.dw EnemyInit_Basic ; Fireball
	.dw EnemyInit_Clawgrip ; Clawgrip
	.dw EnemyInit_Basic ; ClawgripRock
	.dw EnemyInit_Stationary ; PanserStationaryFiresAngled
	.dw EnemyInit_Basic ; PanserWalking
	.dw EnemyInit_Stationary ; PanserStationaryFiresUp
	.dw EnemyInit_Basic ; Autobomb
	.dw EnemyInit_Basic ; AutobombFire
	.dw EnemyInit_WhaleSpout ; WhaleSpout
	.dw EnemyInit_Basic ; Flurry
	.dw EnemyInit_Fryguy ; Fryguy
	.dw EnemyInit_Fryguy ; FryguySplit
	.dw EnemyInit_Wart ; Wart
	.dw EnemyInit_HawkmouthBoss ; HawkmouthBoss
	.dw EnemyInit_Sparks ; Spark1
	.dw EnemyInit_Sparks ; Spark2
	.dw EnemyInit_Sparks ; Spark3
	.dw EnemyInit_Sparks ; Spark4
	.dw EnemyInit_Basic ; VegetableSmall
	.dw EnemyInit_Basic ; VegetableLarge
	.dw EnemyInit_Basic ; VegetableWart
	.dw EnemyInit_Basic ; Shell
	.dw EnemyInit_Basic ; Coin
	.dw EnemyInit_Basic ; Bomb
	.dw EnemyInit_Basic ; Rocket
	.dw EnemyInit_Basic ; MushroomBlock
	.dw EnemyInit_Basic ; POWBlock
	.dw EnemyInit_FallingLogs ; FallingLogs
	.dw EnemyInit_Basic ; SubspaceDoor
	.dw EnemyInit_Key ; Key
	.dw EnemyInit_Basic ; SubspacePotion
	.dw EnemyInit_Stationary ; Mushroom
	.dw EnemyInit_Stationary ; Mushroom1up
	.dw EnemyInit_Basic ; FlyingCarpet
	.dw EnemyInit_Hawkmouth ; HawkmouthRight
	.dw EnemyInit_Hawkmouth ; HawkmouthLeft
	.dw EnemyInit_CrystalBallStarmanStopwatch ; CrystalBall
	.dw EnemyInit_CrystalBallStarmanStopwatch ; Starman
	.dw EnemyInit_CrystalBallStarmanStopwatch ; Stopwatch
EnemyInitializationTable_End: