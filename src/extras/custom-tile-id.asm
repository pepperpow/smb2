	CMP #$D8
	BCC + ;; leads outside....
	STX byte_RAM_300
	JSR CheckCustomSolidness
	LDA (ReadLevelDataAddress), Y
	LDX byte_RAM_300
	SBC #$D8
	ASL
	ASL
	STA byte_RAM_0
	LDA #$77
	STA byte_RAM_1
	LDY #$0