
.include "./src/title_screen/nmi.asm"

IFNDEF CUSTOM_TITLE
.include "./src/title_screen/title_data.asm"
ELSE
.include "./src/extras/ui/title_data.asm"
ENDIF

; =============== S U B R O U T I N E =======================================

TitleScreen:
	LDY #$07 ; Does initialization of RAM.
	STY byte_RAM_1 ; This clears $200 to $7FF.
	LDY #$00
	STY byte_RAM_0
	TYA

InitMemoryLoop:
	STA (byte_RAM_0), Y ; I'm not sure if a different method of initializing memory
; would work better in this case.
	DEY
	BNE InitMemoryLoop

	DEC byte_RAM_1
	LDX byte_RAM_1
	CPX #$02
	BCS InitMemoryLoop ; Stop initialization after we hit $200.

IFDEF CUSTOM_TITLE
	LDY #$78 ; Does initialization of RAM.
	STY byte_RAM_1 ; This clears $200 to $7FF.
	LDY #$00
	STY byte_RAM_0
	TYA

InitMemoryLoop_Custom:
	STA (byte_RAM_0), Y ; I'm not sure if a different method of initializing memory
; would work better in this case.
	DEY
	BNE InitMemoryLoop_Custom

	DEC byte_RAM_1
	LDX byte_RAM_1
	CPX #$72
	BCS InitMemoryLoop_Custom; Stop initialization after we hit $200.
ENDIF

loc_BANK0_9A53:
	LDA #$00
	TAY

InitMemoryLoop2:
	; Clear $0000-$00FF.
	; Notably, this leaves the stack area $0100-$01FF uninitialized.
	; This is not super important, but you might want to do it yourself to
	; track stack corruption or whatever.
	STA byte_RAM_0, Y
	INY
	BNE InitMemoryLoop2

	JSR LoadTitleScreenCHRBanks

	JSR ClearNametablesAndSprites

	LDA PPUSTATUS
	LDA #$3F
	LDY #$00
	STA PPUADDR
	STY PPUADDR

InitTitleBackgroundPalettesLoop:
	LDA TitleBackgroundPalettes, Y
	STA PPUDATA
	INY
	CPY #$20
	BCC InitTitleBackgroundPalettesLoop

	LDA #$01
	STA RAM_PPUDataBufferPointer
	LDA #$03
	STA RAM_PPUDataBufferPointer + 1
	LDA #Stack100_Menu
	STA StackArea
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x8 | PPUCtrl_NMIEnabled
	STA PPUCtrlMirror
	STA PPUCTRL
	JSR WaitForNMI_TitleScreen

	LDA #$01 ; @TODO
	STA ScreenUpdateIndex
	JSR WaitForNMI_TitleScreen

	LDA #Music1_Title
	STA MusicQueue1
	JSR WaitForNMI_TitleScreen_TurnOnPPU

	LDA #$03
	STA byte_RAM_10
IFNDEF CUSTOM_TITLE
	LDA #$25
ELSE
	LDA #$50
ENDIF
	STA byte_RAM_2
	LDA #$20
	STA PlayerXHi
	LDA #$C7
	STA ObjectXHi
	LDA #$52
	STA ObjectXHi + 1

loc_BANK0_9AB4:
	JSR WaitForNMI_TitleScreen

	LDA ObjectXHi + 2
	BNE loc_BANK0_9AF3

loc_BANK0_9ABB:
	INC byte_RAM_10
	LDA byte_RAM_10
	AND #$0F
	BEQ loc_BANK0_9AC6

	JMP loc_BANK0_9B4D

; ---------------------------------------------------------------------------

loc_BANK0_9AC6:
	DEC byte_RAM_2
	LDA byte_RAM_2
	CMP #$06
	BNE loc_BANK0_9B4D

	INC ObjectXHi + 2
	LDA PlayerXHi
	STA PPUBuffer_301
	LDA ObjectXHi
	STA PPUBuffer_301 + 1
	LDA ObjectXHi + 1
	STA PPUBuffer_301 + 2
	LDA #$E6
	STA ObjectXHi
	LDA #$54
	STA ObjectXHi + 1
	LDA #$0FB
	STA PPUBuffer_301 + 3
	LDA #$00
	STA PPUBuffer_301 + 4
	BEQ loc_BANK0_9B4D

loc_BANK0_9AF3:
	LDA PlayerXHi
	STA PPUBuffer_301
	LDA ObjectXHi
	STA PPUBuffer_301 + 1
	LDA ObjectXHi + 1
	STA PPUBuffer_301 + 2
	LDA #$0FB
	STA PPUBuffer_301 + 3
	LDA #$00
	STA PPUBuffer_301 + 4
	LDA ObjectXHi
	CLC
	ADC #$20
	STA ObjectXHi
	LDA PlayerXHi
	ADC #$00
	STA PlayerXHi
	CMP #$23

loc_BANK0_9B1B:
	BCC loc_BANK0_9B4D

	LDA #$20
	STA byte_RAM_10
	LDX #$17
	LDY #$00

loc_BANK0_9B25:
	LDA TitleAttributeData1, Y
	STA PPUBuffer_301 + 4, Y
	INY
	DEX
	BPL loc_BANK0_9B25

	LDA #$00
	STA PPUBuffer_301 + 4, Y
	JSR WaitForNMI_TitleScreen

	LDX #$1B
	LDY #$00

loc_BANK0_9B3B:
	LDA TitleAttributeData2, Y
	STA PPUBuffer_301, Y
	INY
	DEX
	BPL loc_BANK0_9B3B

	LDA #$00
	STA PPUBuffer_301, Y
	JMP loc_BANK0_9B59

; ---------------------------------------------------------------------------

loc_BANK0_9B4D:
IFDEF CUSTOM_TITLE
	LDA Player1JoypadPress
	AND #ControllerInput_A | #ControllerInput_B
	BEQ +no
	LDA #$07
	STA byte_RAM_2
+no
ENDIF
	LDA Player1JoypadPress
	AND #ControllerInput_Start
	BEQ loc_BANK0_9B56

	JMP loc_BANK0_9C1F

; ---------------------------------------------------------------------------

loc_BANK0_9B56:
	JMP loc_BANK0_9AB4

; ---------------------------------------------------------------------------

loc_BANK0_9B59:
	JSR WaitForNMI_TitleScreen

	LDA ObjectXHi + 4
	BEQ loc_BANK0_9B63

	JMP loc_BANK0_9C19

; ---------------------------------------------------------------------------

loc_BANK0_9B63:
	LDA ObjectXHi + 3
IFNDEF CUSTOM_TITLE
	CMP #$09
	BEQ loc_BANK0_9B93
ELSE
	CMP #$11
    BEQ TitleScreen_WriteCreditsText
ENDIF

	LDA ObjectXHi + 3
	BNE loc_BANK0_9BA3

	DEC byte_RAM_10
	BMI TitleScreen_WriteSTORYText

	JMP loc_BANK0_9C19

; ---------------------------------------------------------------------------

IFDEF CUSTOM_TITLE
TitleStoryText_CREDITS:
	.db $DC, $EB, $DE, $DD, $E2, $ED, $EC ; CREDITS

TitleScreen_WriteCreditsText:
    ; PPUBuffer_301
    ; ObjectXHi    ;; vis row
    ; PlayerXHi    ;; vis col
    ; ObjectXHi + 3 ;; cnt lines
    ; ObjectXHi + 5 ;; vis row timer
	LDA #$20
	STA PPUBuffer_301
	LDA #$0AD
	STA PPUBuffer_301 + 1
	LDA #$07 ; Length of STORY text (5 bytes)
	STA PPUBuffer_301 + 2
	LDY #$06 ; Bytes to copy minus one (5-1=4)

TitleScreen_WriteCreditsTextLoop:
	LDA TitleStoryText_CREDITS, Y ; Copy STORY text to PPU write buffer
	STA PPUBuffer_301 + 3, Y
	DEY
	BPL TitleScreen_WriteCreditsTextLoop

	LDA #$00 ; Terminate STORY text in buffer
	STA PPUBuffer_301 + 10
    JMP loc_BANK0_9B93
ENDIF

TitleScreen_WriteSTORYText:
    ; PPUBuffer_301
    ; ObjectXHi    ;; vis row
    ; PlayerXHi    ;; vis col
    ; ObjectXHi + 3 ;; cnt lines
    ; ObjectXHi + 5 ;; vis row timer
	LDA #$20
	STA PPUBuffer_301
	LDA #$0AE
	STA PPUBuffer_301 + 1
	LDA #$05 ; Length of STORY text (5 bytes)
	STA PPUBuffer_301 + 2
	LDY #$04 ; Bytes to copy minus one (5-1=4)

TitleScreen_WriteSTORYTextLoop:
	LDA TitleStoryText_STORY, Y ; Copy STORY text to PPU write buffer
	STA PPUBuffer_301 + 3, Y
	DEY
	BPL TitleScreen_WriteSTORYTextLoop

	LDA #$00 ; Terminate STORY text in buffer
	STA PPUBuffer_301 + 8

loc_BANK0_9B93: ;; reset to top?
	INC ObjectXHi + 3
	LDA #$21
	STA PlayerXHi
	LDA #$06
	STA ObjectXHi
	LDA #$40
	STA ObjectXHi + 5
	BNE loc_BANK0_9C19

loc_BANK0_9BA3:
	DEC ObjectXHi + 5
	BPL loc_BANK0_9C19

loc_BANK0_9BA7:
IFNDEF CUSTOM_TITLE
	LDA #$40
ELSE
    LDA #$28 ;; line speed
ENDIF
	STA ObjectXHi + 5
	LDA PlayerXHi
	STA PPUBuffer_301

loc_BANK0_9BB0:
	LDA ObjectXHi ;; row

loc_BANK0_9BB2:
	STA PPUBuffer_301 + 1
	LDA #$14                ; column
	STA PPUBuffer_301 + 2
	LDX ObjectXHi + 3
	DEX
	LDA TitleStoryTextPointersHi, X
	STA byte_RAM_4
	LDA TitleStoryTextPointersLo, X
	STA byte_RAM_3
	LDY #$00 ; array pos
	LDX #$13 ; length string

loc_BANK0_9BCB:
	LDA (byte_RAM_3), Y
	STA PPUBuffer_301 + 3, Y
	INY
	DEX
	BPL loc_BANK0_9BCB ;; loop end

	LDA #$00
	STA PPUBuffer_301 + 3, Y
	INC ObjectXHi + 3
	LDA ObjectXHi
	CLC
IFNDEF CUSTOM_TITLE
	ADC #$40 ;; row shift
ELSE
	ADC #$20 ;; row shift
ENDIF
	STA ObjectXHi
	LDA PlayerXHi ;; carry adds after objectxhi
	ADC #$00
	STA PlayerXHi
	LDA ObjectXHi + 3 ;; how many lines?  after 9, clear
IFNDEF CUSTOM_TITLE
	CMP #$09
ELSE
	CMP #$11
ENDIF
	BCC loc_BANK0_9C19 ;; if under 9, skip

	BNE loc_BANK0_9C0B ;; if exactly 9, proceed down

	LDA #$09 ;; starting delay
	STA byte_RAM_2
IFNDEF CUSTOM_TITLE
	LDA #$03
ELSE
	LDA #$06
ENDIF
	STA byte_RAM_10
	LDA #$20
	STA PlayerXHi
	LDA #$C7
	STA ObjectXHi
	LDA #$52
	STA ObjectXHi + 1
	LDA #$00
	STA ObjectXHi + 2

	JMP loc_BANK0_9ABB

; ---------------------------------------------------------------------------
loc_BANK0_9C0B:
IFNDEF CUSTOM_TITLE
	CMP #$12
ELSE
	CMP #$22
ENDIF
	BCC loc_BANK0_9C19

	INC ObjectXHi + 4
	LDA #$25
	STA byte_RAM_2
IFNDEF CUSTOM_TITLE
	LDA #$03
ELSE
	LDA #$06
ENDIF
	STA byte_RAM_10

loc_BANK0_9C19:
	LDA Player1JoypadHeld
	AND #ControllerInput_Start
	BEQ loc_BANK0_9C35

loc_BANK0_9C1F:
	LDA #Music2_StopMusic
	STA MusicQueue2
	JSR WaitForNMI_TitleScreen

	LDA #$00
	TAY

loc_BANK0_9C2A:
	STA byte_RAM_0, Y
	INY
	CPY #$F0
	BCC loc_BANK0_9C2A

	JMP HideAllSprites

; ---------------------------------------------------------------------------

loc_BANK0_9C35:
	LDA ObjectXHi + 4
	BEQ loc_BANK0_9C4B

	INC byte_RAM_10
	LDA byte_RAM_10
	AND #$0F
	BNE loc_BANK0_9C4B

	DEC byte_RAM_2
	LDA byte_RAM_2
	CMP #$06
	BNE loc_BANK0_9C4B

	BEQ loc_BANK0_9C4E

loc_BANK0_9C4B:
	JMP loc_BANK0_9B59

; ---------------------------------------------------------------------------

loc_BANK0_9C4E:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x8 | PPUCtrl_NMIDisabled
	STA PPUCtrlMirror

loc_BANK0_9C52:
	STA PPUCTRL
	JMP loc_BANK0_9A53

; End of function TitleScreen