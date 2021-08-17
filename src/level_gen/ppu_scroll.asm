;
; High byte of the PPU scroll offset for nametable B.
;
; When mirroring vertically, nametable A is `$2000` and nametable B is `$2800`.
; When mirroring horizontally, nametable A is `$2000` and nametable B is `$2400`.
;
PPUScrollHiOffsets_Bank6:
	.db $28 ; vertical
	.db $24 ; horizontal

;
; Resets the PPU high scrolling values and sets the high byte of the PPU scroll offset.
;
; The version of the subroutine in this bank is always called with `A = $00`.
;
; ##### Input
; - `A`: 0 = use nametable A, 1 = use nametable B
; - `Y`: 0 = vertical, 1 = horizontal
;
; ##### Output
; - `PPUScrollYHiMirror`
; - `PPUScrollXHiMirror`
; - `PPUScrollCheckHi`: PPU scroll offset high byte
;
ResetPPUScrollHi_Bank6:
	LSR A
	BCS ResetPPUScrollHi_NametableB_Bank6

ResetPPUScrollHi_NametableA_Bank6:
	LDA #$01
	STA PPUScrollXHiMirror
	ASL A
	STA PPUScrollYHiMirror
	LDA #$20
	BNE ResetPPUScrollHi_Exit_Bank6

ResetPPUScrollHi_NametableB_Bank6:
	LDA #$00
	STA PPUScrollXHiMirror
	STA PPUScrollYHiMirror
	LDA PPUScrollHiOffsets_Bank6, Y

ResetPPUScrollHi_Exit_Bank6:
	STA PPUScrollCheckHi
	RTS