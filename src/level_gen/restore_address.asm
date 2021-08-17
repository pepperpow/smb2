;
; Sets the raw level data pointer to the level data.
;
RestoreLevelDataCopyAddress:
	LDA #>RawLevelData
	STA byte_RAM_6
	LDA #<RawLevelData
	STA byte_RAM_5
	RTS


;
; Sets the raw level data pointer to the jar data.
;
; This is what allows jars to load so quickly.
;
HijackLevelDataCopyAddressWithJar:
	LDA #>RawJarData
	STA byte_RAM_6
	LDA #<RawJarData
	STA byte_RAM_5
	RTS