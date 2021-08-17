DetectLocked:
    CMP #BackgroundTile_DoorBottomLock
    BNE EndTileLocked
+   LDA KeyUsed
    BEQ +++
	LDA #BackgroundTile_DoorBottom
    BNE EndTileLocked
+++ LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
EndTileLocked:
    RTS