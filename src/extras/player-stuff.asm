

; ChkToNextValidCharacter:
;       LDA     CurrentCharacter
;       AND     #$3
;       STA     CurrentCharacter
;       TAX
;       LDA     CharLookupTable, X
;       AND     CharacterLock_Variable
;       RTS

; IFDEF PLAYER_STUFF
; ChampSet:
;     LDA ObjectType, X
;     CMP #Enemy_Pidgit
;     BEQ ++
;     CMP #Enemy_Key
;     BEQ ++
;     CMP #Enemy_CrystalBall
;     BEQ ++
;     LDA Enemy_Champion, X
;     BNE +
;     LDA PseudoRNGValues + 2 
;     STA Enemy_Champion, X
; +
;     CMP ChampionChance
;     BCS ++
;     LDA #ObjAttrib_Palette3
;     EOR ObjectAttributes, X
; 	STA ObjectAttributes, X
;     LDA EnemyArray_46E_Data, Y
;     ORA #$42 
;     STA EnemyArray_46E, X
;     INC EnemyHP, X
;     SEC
;     RTS
; ++  
;     RTS
; ENDIF


; IFDEF PLAYER_STUFF
; HandlePlayerProjectileEffect:
;     TXA
;     PHA
;     TYA
;     PHA
;     TAX
;     LDA Enemy_Fireball_Hits, X
;     AND #ProjChar_PuffEnemy
; 	BEQ +
; 	JSR TurnIntoPuffOfSmoke
; +   LDA Enemy_Fireball_Hits, X
;     AND #ProjChar_Disappear
; 	BEQ +
; 	JSR TurnIntoPuffOfSmoke
;     LDA #$0
;     STA EnemyTimer, X
; +   LDA Enemy_Fireball_Hits, X
;     AND #ProjChar_Explosion
; 	BEQ +
; 	JSR EnemyBehavior_Bomb_Explode
; +   PLA
;     TAY
;     PLA
;     TAX
;     RTS
; ENDIF


; IFDEF PLAYER_STUFF
; BossDefeatMush:
;     JSR TurnIntoPuffOfSmoke_Proper

;     LDA BossMushroom
;     BEQ +
;     LDX #CustomBitFlag_Mush1
;     JSR ChkFlagLevel
;     BEQ +
;     LDX byte_RAM_12
;     JSR CreateEnemy_TryAllSlots
;     BMI +
;     TXA
;     PHA
; 	LDX byte_RAM_0
;     STX byte_RAM_12
;     LDY #$0
;     STY EnemyVariable, X
;     LDA PlayerLevelPowerup_1, Y
;     STA MushroomEffect, X
;     LDA #Enemy_Mushroom
;     STA ObjectType, X
;     JSR ProcessCustomPowerup    
;     PLA
;     STA byte_RAM_12
; 	LDX byte_RAM_0
; 	LDY byte_RAM_12
; 	LDA unk_RAM_4EF, Y
; 	STA ObjectXHi, X
;     LDA #$D0
;     STA ObjectYVelocity, X
;     LDA #$0
;     STA ObjectXVelocity, X
; +   
; 	LDX byte_RAM_12
;     RTS
; ENDIF

; IFDEF EXTENDED_PTR_CONTINUE
; SetGameModeBonusChanceCustom:
;     LDA CurrentLevelPage
;     ASL
;     TAX
; 	LDA AreaPointersByPage, X
;     CMP #$1F
;     BNE +
;     LDY #GameMode_Shop
;     STY GameMode
;     LDA CurrentLevelPage
;     STA CurrentLevelEntryPage
;     STA CurrentLevelEntryPage_Init
;     RTS
; +
;     LDA CurrentLevelPage
;     ASL
;     TAX
;     LDA AreaPointersByPage, X
;     AND #$20
;     CMP #$20
;     BEQ +
;     RTS
; +
; 	LDA #GameMode_BonusChance
; 	STA GameMode
; 	RTS
; ENDIF

; ;; other ideas:
; ;; stat upgrades
; ;; mltp unlock
; ;; map radar
; ;; mask egg buddy 
; ;; luck
; ;; reduce item chances
; ;; fixx:
; ;; radar, sound or tile draw, remove potion, add crystal
; ;; fire, straight forward

; ItemCollisionCustom:
;     JMP + ;; skip collision until we get a better way to do it
; 	LDA ObjectType, Y
;     CMP #Enemy_Mushroom
;     BNE +
;     LDA MushroomEffect, Y
;     BEQ +
;     LDA ObjectYVelocity, Y
;     BMI +
;     LDX byte_RAM_12
; 	JSR TurnIntoPuffOfSmoke
;     JSR ProcessCustomPowerupAward
;     LDY byte_RAM_12
; ++  LDA #Enemy_MushroomBlock
;     STA ObjectType, Y
;     LDA #$1
;     STA EnemyArray_42F, Y
;     PLA
;     PLA
;     JMP CheckCollisionWithPlayer_Exit
; +
; 	LDA ObjectType, Y
; 	CMP #Enemy_Coin
;     BNE +
; 	LDA Is_Player_Projectile, Y
;     BMI ++
;     LDA #EnemyState_PuffOfSmoke
; 	STA EnemyState, Y
; 	LDA #SoundEffect2_CoinGet
; 	STA SoundEffectQueue2
;     INC SlotMachineCoins
;     LDA Enemy_Champion, Y
;     CMP ChampionChance
;     BCS ++
;     INC SlotMachineCoins
; ++
;     INC Level_Count_Coins
;     PLA
;     PLA
;     JMP CheckCollisionWithPlayer_Exit
; +   RTS


; ClearPlayerStuff:
;     LDY #$11
;     LDA #0
;     STA Boss_HP
;     STA CrushTimer
;     STA ProjectileNumber
; -	STA AreaPointersByPage, Y
;     DEY
;     BPL -
;     LDY #$8
; -	STA PlayerLevelPowerup_1, Y
;     DEY
;     BPL -
;     RTS


; CustomTransitionFlag_Continue = $80
; CustomTransitionFlag_ResetPos = $40
; CustomTransitionFlag_LevelComplete = $20

ProcessCustomPowerupAward: ;; setup enum for extra options on compile
    LDA MushroomEffect, X
ProcessCustomPowerupAward_NoLookup:
    TAX
 	JSR JumpToTableAfterJump

 	.dw Normal_Mushroom_BEH ; Mushroom
 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag 
; 	.dw CustomBeh_Flag2 
; 	.dw CustomBeh_Flag2 
; 	.dw CustomBeh_Flag2 
; 	.dw CustomBeh_Flag2 ;;key
; 	.dw CustomBeh_Flag2 
; 	.dw CustomBeh_Flag2 
; 	.dw Normal_Mushroom_BEH 
; 	.dw Normal_Mushroom_BEH 
;     .dw CustomBeh_Fireball ; $11
;     .dw CustomBeh_Egg ; $12
;     .dw CustomBeh_Bomb
;     .dw CustomBeh_Phanto
;     .dw CustomBeh_Fry
;     .dw CustomBeh_Hammer
;     .dw CustomBeh_Freeze
;     .dw CustomBeh_Continue
; 	.dw CustomBeh_UnlockM 
; 	.dw CustomBeh_UnlockL 
; 	.dw CustomBeh_UnlockT 
; 	.dw CustomBeh_UnlockP 
 	.dw CustomBeh_Mushroom_Fragment 
;     ;; leave objects at end, empty data

; CustomBeh_Continue:
;     INC Continues
;     JSR RemoveFromPlayfield
;     JSR PlayMushGet
;     RTS 

CustomBeh_Mushroom_Fragment:
    INC MushroomFragments
    LDA MushroomFragments
    CMP #$4
    BCC ++
    LDA #$0
    STA MushroomFragments
    JSR Normal_Mushroom_BEH
++  JSR RemoveFromPlayfield
    JSR PlayMushGet
    RTS

; ; $00 Mario
; ; $01 Princess
; ; $02 Toad
; ; $03 Luigi
; ; however on screen
; ; $00 Mario
; ; $03 Luigi
; ; $02 Toad
; ; $01 Princess
; ;CharLookupTable:
; ;	.db $01 ; Mio 
; ;	.db $08 ; Pch 
; ;	.db $04 ; Tod 
; ;	.db $02 ; Lug 
; ;ENDIF
; CustomBeh_UnlockM:
;     LDA #$0F ^ #%0001
;     LDX #0
;     JMP CustomBeh_Unlock
; CustomBeh_UnlockP:
;     LDA #$0F ^ #%1000
;     LDX #1
;     JMP CustomBeh_Unlock
; CustomBeh_UnlockT:
;     LDA #$0F ^ #%0100 ; their respective slot
;     LDX #2
;     JMP CustomBeh_Unlock
; CustomBeh_UnlockL:
;     LDA #$0F ^ #%0010
;     LDX #3
;     JMP CustomBeh_Unlock

; CustomBeh_Unlock:
;     AND CharacterLock_Variable
;     STA CharacterLock_Variable
;     LDA IndependentLives
;     BEQ +
;     LDA ContinueGame + 1 ;; lives
;     CMP PlayerIndependentLives, X
;     BCC ++
;     STA PlayerIndependentLives, X
;     JMP ++
; +   LDA ContinueGame + 1 ;; lives
;     CMP PlayerIndependentLives, X
;     BCC ++
;     STA PlayerIndependentLives, X
; ++
;     LDA RescueCondition
;     BNE +++
;     JSR RemoveFromPlayfield
; +++
;     JSR PlayMushGet
;     RTS

Normal_Mushroom_BEH:
    LDA PlayerMaxHealth
    BMI ++
	INC PlayerMaxHealth
    INC Level_Count_MushCount
    JSR RemoveFromPlayfield
    LDA PlayerMaxHealth
    CMP MaxedHealth
    BCC + 
    LDA MaxedHealth
    STA PlayerMaxHealth
+   JSR RestorePlayerToFullHealth
    JSR PlayMushGet
    RTS
++
    LDA #$1F
    STA PlayerHealth
    RTS

PlayMushGet:
	LDA #Music2_MushroomGetJingle
	STA MusicQueue2
	LDA #0
	STA SoundEffectQueue1
    RTS

RemoveFromPlayfield:
    LDY byte_RAM_12
    LDX EnemyVariable, Y ;; make this less weird
    CPX #$2
    BCS ++
    JSR GetMushFlag_Bitmask
    JSR ApplyFlagLevel 
++  RTS


ShiftBit:
    TXA
    TAY
    LDA #1
-   CPY #1
    BEQ +
    ASL
    DEY
    JMP -
+   RTS

CustomBeh_Flag:
    JSR ShiftBit
    TAX
    JSR ApplyFlagPlayer
    JSR RemoveFromPlayfield
    RTS

; CustomBeh_Flag2:
;     TXA
;     AND #%111
;     TAX
;     JSR ShiftBit
;     TAX
;     JSR ApplyFlagPlayer2
;     JSR RemoveFromPlayfield
;     RTS

; JumpAttack:
;     LDA PlayerYVelocity
;     BMI +
;     CMP #$10
;     BCC +
;     JSR LoadFlagPlayer3
;     LDY CurrentCharacter
;     LDA (byte_RAM_C5), Y
;     AND #CustomBitFlag_BounceAll
;     BNE +ok
;     LDA (byte_RAM_C5), Y
;     AND #CustomBitFlag_BounceJump
;     BEQ +o
;     LDA PlayerAnimationFrame
;     CMP #SpriteAnimation_Jumping
;     BEQ +ok
;     JMP +
; +o
;     LDA (byte_RAM_C5), Y
;     AND #CustomBitFlag_GroundPound
;     BEQ +o
;     LDA Player1JoypadHeld
;     AND #ControllerInput_Down
;     BEQ +
;     LDA CrushTimer
;     CMP #$08
;     BCS +ok
;     LDA #$0
;     STA CrushTimer
;     JMP +
; +o
;     JMP +
; +ok
;     LDA #$0
;     STA CrushTimer
;     LDA Player1JoypadHeld
;     AND #ControllerInput_A
;     BEQ ++
;     LDA #$A0
;     STA PlayerYVelocity
;     BNE +++
; ++  LDA #$C0
;     STA PlayerYVelocity
; +++ LDX byte_RAM_12
;     INX
;     LDY #$14
;     JSR DamageEnemy_NoProjectile
; 	LDX byte_RAM_ED
;     PLA
;     PLA
;     RTS
; +
;     RTS

; AwardHealth:
;     PHA ;; award one extra health to a full stack, but only if we aren't farming
;     CMP ProjectileType
;     BEQ +o
;     LDA #$0
;     STA PlayerCurrentSize
; 	LDA #$06
; 	STA PlayerStateTimer
; 	LDA #PlayerState_ChangingSize
; 	STA PlayerState
; 	LDA PlayerHealth
;     CMP #$FF
;     BEQ +
;     INC PlayerMaxHealth
;     INC PlayerMaxHealth
;     LSR
;     LSR
;     LSR
;     LSR
;     CMP PlayerMaxHealth
;     BCS ++
;     LDA PlayerHealth
; 	CLC
; 	ADC #$10
;     STA PlayerHealth
; ++  DEC PlayerMaxHealth
;     DEC PlayerMaxHealth
;     JMP +
; +o  LDA #SoundEffect1_CherryGet
; 	STA SoundEffectQueue1
; +   PLA
;     RTS

; CustomBeh_Fireball:
;     LDA #$1
;     JSR AwardHealth
;     STA ProjectileType
; --  LDX #0
;     JSR RptPaletteCustom
;     RTS

; CustomBeh_Egg:
;     LDA #$2
;     JSR AwardHealth
;     STA ProjectileType
; -   LDX #8
;     JSR RptPaletteCustom
;     RTS

; CustomBeh_Bomb:
;     LDA #$3
;     JSR AwardHealth
;     STA ProjectileType
;     JMP -

; CustomBeh_Phanto:
;     LDA #$4
;     JSR AwardHealth
;     STA ProjectileType
;     JMP -

; CustomBeh_Fry:
;     LDA #$5
;     JSR AwardHealth
;     STA ProjectileType
;     JMP --

; CustomBeh_Hammer:
;     LDA #$9
;     JSR AwardHealth
;     STA ProjectileType
;     JMP --

; CustomBeh_Freeze:
;     LDA #$D
;     JSR AwardHealth
;     STA ProjectileType
;     JMP --


; CustomCopyChar:
;       LDA     #PRGBank_A_B
;       JSR     ChangeMappedPRGBank
; CharSel:
;       LDA     CurrentCharacter
;       STA PreviousCharacter
;       TAX
;       LDY     StatOffsets,X
;       LDX     #0


; RptStats:
;       LDA     MarioStats,Y
;       STA     PickupSpeedAnimation,X
;       INY
;       INX
;       CPX     #$17
;       BCC     RptStats
; GetCharBit:
;       LDA     CurrentCharacter
;       ASL     A
;       ASL     A
;       TAX
;       JSR     RptPalette

; EndCharacterSwap:
;       LDA     #PRGBank_2_3
;       JSR     ChangeMappedPRGBank
;     ; load carry offsets
; 	; Copy the character-specific FINAL carrying heights into memory
; 	LDY CurrentCharacter
; 	LDA CarryYOffsetBigLo, Y
; 	STA ItemCarryYOffsetsRAM
; 	LDA CarryYOffsetSmallLo, Y
; 	STA ItemCarryYOffsetsRAM + $07
; 	LDA CarryYOffsetBigHi, Y
; 	STA ItemCarryYOffsetsRAM + $0E
; 	LDA CarryYOffsetSmallHi, Y
; 	STA ItemCarryYOffsetsRAM + $15
;       LDA     #PRGBank_0_1
;       JSR     ChangeMappedPRGBank
; 	; update chr for character
; 	JSR LoadCharacterCHRBanks
;     RTS

; CustomPalette:
; 	.db $0F,$01,$16,$27
; 	.db $0F,$06,$25,$36
; 	.db $0F,$01,$30,$27
; 	.db $0F,$01,$2A,$36

; RptPaletteCustom:
;       RTS
;       LDY #0
;   -
;       LDA     CustomPalette,X
;       STA     RestorePlayerPalette0,Y
;       INX
;       INY
;       CPY     #4
;       BNE     -
;       LDA SkyFlashTimer
;       BNE +
;       INC     SkyFlashTimer
; +
;       RTS

; RptPalette:
;       LDY #0
;   -
;       LDA     MarioPalette,X
;       STA     RestorePlayerPalette0,Y
;       INX
;       INY
;       CPY     #4
;       BNE     -
;       LDA SkyFlashTimer
;       BNE +
;       INC     SkyFlashTimer
; +
;       RTS

; IFDEF PLAYER_STUFF
; ;; appearances
ProcessCustomPowerup_WithRemove:
    LDA EnemyVariable, X
    CMP #$FF
    BEQ +
    TAX
    JSR GetMushFlag_Bitmask
    JSR ChkFlagLevel
    BNE +
    LDX byte_RAM_12
    LDA #$0
    STA EnemyState, X
    RTS
+   LDX byte_RAM_12
ProcessCustomPowerup: ;; setup enum for extra options on compile
    LDA MushroomEffect, X
ProcessCustomPowerup_NoLookup: ;; setup enum for extra options on compile
    TAX
	JSR JumpToTableAfterJump

 	.dw Normal_Mushroom
 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem ;; set 2 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem 
; 	.dw CustomObject_PowerItem ; ocarina?
; 	.dw Normal_Mushroom 
; 	.dw Normal_Mushroom 
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; fire
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; egg
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; bomb
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; phanto
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; fry
; 	.dw CustomObject_MushHalf ;; hammer
; 	.dw CustomObject_PowerItem_NoChrSwitch ;; freeze
; 	.dw CustomObject_PowerItem ;; Continue
; 	.dw CustomObject_RescueHalf ;; unlock m
; 	.dw CustomObject_RescueHalf ;; unlock l
; 	.dw CustomObject_RescueHalf ;; unlock t
; 	.dw CustomObject_RescueHalf ;; unlock p
 	.dw CustomObject_MushHalf ;; mushhalf
; 	.dw PReplaceItem_Persistent ; key
; 	.dw PReplaceItem ; coin (one time coin)
; 	.dw PReplaceItem_Persistent ; shell 
; 	.dw PReplaceItem ; life (one time life)
; 	.dw PReplaceItem_Persistent ; star
; 	.dw PReplaceItem_Persistent ; stop
; 	.dw PReplaceItem_Persistent ; bomb
; 	.dw PReplaceItem_Persistent ; crystal (stays persistent, null on spawn anyway)


EnemyCustom_Attributes:
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
 	.db ObjAttrib_Palette1 ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom

; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom  ; SET 2
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing  ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing  ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom

; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing  ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette3 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing  ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing  ; $3F Enemy_Mushroom

; 	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_Mirrored ;; cont
; 	.db ObjAttrib_Palette3 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom ;; rescue
; 	.db ObjAttrib_Palette3 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette3 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
; 	.db ObjAttrib_Palette3 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
 	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing ; $3F Enemy_Mushroom
; 	.db #Enemy_Key
; 	.db #Enemy_Coin
; 	.db #Enemy_Shell
; 	.db #Enemy_Mushroom1up
; 	.db #Enemy_Starman
; 	.db #Enemy_Stopwatch
; 	.db #Enemy_ShyguyPink
; 	.db #Enemy_CrystalBall

EnemyCustom_TableSprites:
    .db $a5, $a5

    .db $e0, $e2 
;     .db $f2, $f2
;     .db $f8, $fa
;     .db $c8, $ca
;     .db $cc, $cc
;     .db $a8, $a8
;     .db $a6, $a6
;     .db $ec, $ee

;     .db $d8, $da
;     .db $d4, $d6
;     .db $d0, $d2
;     .db $c4, $c6
;     .db $fe, $fe
;     .db $f4, $f6
;     .db $a5, $a5
;     .db $a5, $a5

;     .db $a4, $a4
;     .db $b5, $b9
;     .db $db, $db
;     .db $ed, $ed
;     .db $9c, $9c
;     .db $fb, $f3
;     .db $a4, $3f

;     .db $fc, $fc
;     .db $e4, $fb 
;    .db $e6, $fb 
;     .db $e8, $fb 
;     .db $ea, $fb 
     .db $ba, $fb
;     ;; leave objects at end, empty data


; PReplaceItem:
;     JSR PReplaceItem_Persistent
;     JSR RemoveFromPlayfield
;     RTS
; PReplaceItem_Persistent:
;     ;; autoremove from playfield?
;     ;; turn below into F helper, or load in bank for enemy attribs/init
;     LDA EnemyCustom_Attributes, X
;     LDX byte_RAM_12
; 	STA ObjectType, X
; IFDEF DISABLED
;     CMP #Enemy_Mushroom1up
;     BNE +
;     LDX #CustomBitFlag_1up 
;     JSR ApplyFlagLevel
;     BEQ ++
;     INC Level_Count_1ups
;     INC Mushroom1upPulled 
;     BNE +
; ++  LDX byte_RAM_12
;     LDA #$0
;     STA EnemyState, X
;     RTS
; +   LDX byte_RAM_12
; ENDIF
;     LDY ObjectType, X
;     JSR Normal_Mushroom_Spawn
;     RTS

; PDoNothing:
;     RTS

Normal_Mushroom:
    TXA
    PHA
	LDY #Enemy_Mushroom
    LDX byte_RAM_12
    JSR Normal_Mushroom_Spawn
    PLA
    TAX
    RTS
  
Normal_Mushroom_Spawn:
	LDA ObjectAttributeTable, Y
	AND #$7F
	STA ObjectAttributes, X
	LDA EnemyArray_46E_Data, Y
	STA EnemyArray_46E, X
	LDA EnemyArray_489_Data, Y
	STA EnemyArray_489, X
	LDA EnemyArray_492_Data, Y
	STA EnemyArray_492, X
	LDA #$FF
	STA EnemyRawDataOffset, X
    LDA byte_RAM_12
    ASL
    ASL
    TAY
    LDX #0
    LDA EnemyCustom_TableSprites, X
    STA SpriteTableCustom1, Y
    LDA EnemyCustom_TableSprites + 1, X
    STA SpriteTableCustom1 + 1, Y
    RTS

CustomObject_RescueHalf:
    LDA #$32
    STA SpriteCHR4
    JSR CustomDestroyAll
CustomObject_MushHalf:
    JSR CustomObject_PowerItem_NoChrSwitch
    LDX byte_RAM_12
    LDA ObjectXLo, X
    LDA InSubspaceOrJar
    BEQ +
    LDA ObjectXLo, X
    SEC
    SBC #$4
    JMP ++
+
    LDA ObjectXLo, X
    CLC
    ADC #$4
++
    STA ObjectXLo, X
    RTS

CustomDestroyAll:
    LDA #PRGBank_2_3
    JSR ChangeMappedPRGBankWithoutSaving
    LDA byte_RAM_E
    PHA
    JSR DestroyOnscreenEnemies
    PLA
    STA byte_RAM_E
    LDA MMC3PRGBankTemp
    JSR ChangeMappedPRGBank
    LDA MushroomEffect, X
    TAX
    RTS

; CustomReplaceTile:
;     PHA
;     LDA #PRGBank_0_1
;     JSR ChangeMappedPRGBankWithoutSaving
;     PLA
;     JSR ReplaceTile_Bank0
;     LDA MMC3PRGBankTemp
;     JSR ChangeMappedPRGBank
;     RTS

CustomObject_PowerItem:
    LDA #$32
    STA SpriteCHR4
    JSR CustomDestroyAll
CustomObject_PowerItem_NoChrSwitch:
    JSR Normal_Mushroom
    LDY byte_RAM_12
    LDA EnemyCustom_Attributes, X
    STA ObjectAttributes, Y
    LDA #$5
    STA EnemyArray_492, Y
    LDA #$2
    STA EnemyArray_489, Y
    LDA byte_RAM_12
    ASL
    ASL
    TAY
    TXA
    ASL
    TAX
    LDA EnemyCustom_TableSprites, X
    STA SpriteTableCustom1, Y
    LDA EnemyCustom_TableSprites + 1, X
    STA SpriteTableCustom1 + 1, Y
    RTS
;ENDIF
