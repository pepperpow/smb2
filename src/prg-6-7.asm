;
; Bank 6 & Bank 7
; ===============
;
; What's inside:
;
;   - Level palettes
;   - Groundset data
;   - Object tiles
;   - Level handling code
;
; -----
;

IFNDEF CUSTOM_LEVEL_RLE

.include "./src/level_gen/world_palettes.asm"

.include "./src/level_gen/ground_appearance.asm"

.include "./src/level_gen/unused_quads.asm"

.include "./src/level_gen/create_object.asm"

IFNDEF EXPAND_TABLES
; Unused space in the original ($9126 - $91FF)
unusedSpace $9200, $FF
ENDIF

.include "./src/level_gen/ground_set.asm"

ELSE ; CUSTOM_LEVEL_RLE

.include "./src/level_gen/world_palettes.asm"

.include "./src/level_gen/restore_address.asm"

.include "./src/level_gen/set_page_offset.asm"

ENDIF

;
; Lookup tables for decoded level data by page
;
DecodedLevelPageStartLo_Bank6:
	.db <DecodedLevelData
	.db <(DecodedLevelData+$00F0)
	.db <(DecodedLevelData+$01E0)
	.db <(DecodedLevelData+$02D0)
	.db <(DecodedLevelData+$03C0)
	.db <(DecodedLevelData+$04B0)
	.db <(DecodedLevelData+$05A0)
	.db <(DecodedLevelData+$0690)
	.db <(DecodedLevelData+$0780)
	.db <(DecodedLevelData+$0870)
	.db <(SubAreaTileLayout)

DecodedLevelPageStartHi_Bank6:
	.db >DecodedLevelData
	.db >(DecodedLevelData+$00F0)
	.db >(DecodedLevelData+$01E0)
	.db >(DecodedLevelData+$02D0)
	.db >(DecodedLevelData+$03C0)
	.db >(DecodedLevelData+$04B0)
	.db >(DecodedLevelData+$05A0)
	.db >(DecodedLevelData+$0690)
	.db >(DecodedLevelData+$0780)
	.db >(DecodedLevelData+$0870)
	.db >(SubAreaTileLayout)


.include "./src/level_gen/subspace_remap.asm"

.include "./src/level_gen/clear_level.asm"

.include "./src/level_gen/palette_set.asm"

.include "./src/level_gen/subspace.asm" ; and sub area

IFDEF CUSTOM_LEVEL_RLE

.include "src/extras/level_gen/custom_level_rle.asm"

ELSE

.include "./src/level_gen/level_loader.asm"

ENDIF

.include "./src/level_gen/ppu_scroll.asm"

.include "./src/level_gen/create_mushroom.asm"
