DetectSecret:
    CMP #BackgroundTile_SubspaceMushroom1
    BEQ +
    CMP #BackgroundTile_SubspaceMushroom2
    BNE EndTileSecret
+   ; TXA   
    ; PHA
    ; LDY ReadLevelDataOffset
	; LDA (ReadLevelDataAddress), Y
    ; SEC
	; SBC #BackgroundTile_SubspaceMushroom1
    ; TAX
    ; LDA Mushroom1Pulled, X
    ; BEQ +++
    ; PLA
    ; TAX
    LDA #SoundEffect1_StopwatchTick
    STA SoundEffectQueue1
	LDA #BackgroundTile_LightTrail 
    BNE EndTileSecret
; +++ PLA
;     TAX
;     LDY ReadLevelDataOffset
;     LDA (ReadLevelDataAddress), Y
EndTileSecret:
    RTS