    CMP #BackgroundTile_SubspaceMushroom1
    BEQ +
    CMP #BackgroundTile_SubspaceMushroom2
    BNE EndTileSecret
+   TXA
    PHA
    LDX #CustomBitFlag_Secret
    JSR ChkFlagPlayer
    BNE +++
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
    SEC
	SBC #BackgroundTile_SubspaceMushroom1
    TAX
    JSR GetMushFlag_Bitmask
    JSR ChkFlagLevel
    BEQ +++
    PLA
    TAX
    LDA #SoundEffect1_StopwatchTick
    STA SoundEffectQueue1
	LDA #BackgroundTile_LightTrail 
    JMP EndTileSecret
+++ PLA
    TAX   
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
EndTileSecret: