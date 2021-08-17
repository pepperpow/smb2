;
; ## Ground appearance tiles
;
; The ground setting defines a single column (or row, for vertical areas) where each row (or column)
; is be one of four tiles. That set of four tiles is the ground appearance. Each world has its own
; ground appearances defined, which are which are divided into horizontal and vertical sets.
;
; An area has its initial ground appearance set in the header, but it can be changed mid-area using
; the `$F6` special object.
;

;
; #### Ground appearance pointers
;
GroundTilesHorizontalLo:
	.db <World1GroundTilesHorizontal
	.db <World2GroundTilesHorizontal
	.db <World3GroundTilesHorizontal
	.db <World4GroundTilesHorizontal
	.db <World5GroundTilesHorizontal
	.db <World6GroundTilesHorizontal
	.db <World7GroundTilesHorizontal

GroundTilesVerticalLo:
	.db <World1GroundTilesVertical
	.db <World2GroundTilesVertical
	.db <World3GroundTilesVertical
	.db <World4GroundTilesVertical
	.db <World5GroundTilesVertical
	.db <World6GroundTilesVertical
	.db <World7GroundTilesVertical

GroundTilesHorizontalHi:
	.db >World1GroundTilesHorizontal
	.db >World2GroundTilesHorizontal
	.db >World3GroundTilesHorizontal
	.db >World4GroundTilesHorizontal
	.db >World5GroundTilesHorizontal
	.db >World6GroundTilesHorizontal
	.db >World7GroundTilesHorizontal

GroundTilesVerticalHi:
	.db >World1GroundTilesVertical
	.db >World2GroundTilesVertical
	.db >World3GroundTilesVertical
	.db >World4GroundTilesVertical
	.db >World5GroundTilesVertical
	.db >World6GroundTilesVertical
	.db >World7GroundTilesVertical

;
; #### Ground appearance tile definitions
;
; These are the tiles used to render the ground setting of an area.
; Each row in a world's table corresponds to the ground type.
;
; You'll notice that the first entry, which correponds to the sky/background is
; $00 instead of $40. This is skipped with a BEQ in WriteGroundSetTiles,
; presumably as an optimization, so the value doesn't matter!
;
World1GroundTilesHorizontal:
	.db $00, $99, $D5, $00 ; $00
	.db $00, $99, $99, $99 ; $01
	.db $00, $A0, $A0, $A0 ; $02
	.db $00, $A2, $A2, $A2 ; $03
	.db $00, $D6, $9B, $18 ; $04
	.db $00, $A0, $A0, $99 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World1GroundTilesHorizontal + $40, $00
ENDIF

World1GroundTilesVertical:
	.db $00, $9D, $9E, $C6 ; $00
	.db $00, $05, $A0, $00 ; $01
	.db $00, $00, $00, $00 ; $02
	.db $00, $00, $A2, $00 ; $03
	.db $00, $00, $C2, $00 ; $04
	.db $00, $00, $A0, $00 ; $05
	.db $00, $93, $9E, $C6 ; $06
	.db $00, $40, $9E, $C6 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World1GroundTilesVertical + $40, $00
ENDIF

World2GroundTilesHorizontal:
	.db $00, $99, $99, $99 ; $00
	.db $00, $8A, $8A, $8A ; $01
	.db $00, $8B, $8B, $8B ; $02
	.db $00, $A0, $A0, $A0 ; $03
	.db $00, $A2, $A2, $A2 ; $04
	.db $00, $D6, $9B, $18 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World2GroundTilesHorizontal + $40, $00
ENDIF

World2GroundTilesVertical:
	.db $00, $9D, $9E, $C6 ; $00
	.db $00, $93, $A0, $00 ; $01
	.db $00, $40, $9B, $40 ; $02
	.db $00, $93, $9E, $C6 ; $03
	.db $00, $40, $9E, $C6 ; $04
	.db $00, $00, $00, $00 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World2GroundTilesVertical + $40, $00
ENDIF

World3GroundTilesHorizontal:
	.db $00, $99, $D5, $00 ; $00
	.db $00, $99, $99, $99 ; $01
	.db $00, $A0, $A0, $A0 ; $02
	.db $00, $A2, $A2, $A2 ; $03
	.db $00, $D6, $9B, $18 ; $04
	.db $00, $A0, $A0, $99 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World3GroundTilesHorizontal + $40, $00
ENDIF

World3GroundTilesVertical:
	.db $00, $C6, $9E, $9D ; $00
	.db $00, $05, $A0, $00 ; $01
	.db $00, $93, $9E, $C6 ; $02
	.db $00, $00, $A2, $00 ; $03
	.db $00, $00, $C2, $00 ; $04
	.db $00, $00, $A0, $00 ; $05
	.db $00, $40, $9E, $C6 ; $06
	.db $00, $06, $A0, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World3GroundTilesVertical + $40, $00
ENDIF

World4GroundTilesHorizontal:
	.db $00, $99, $D5, $00 ; $00
	.db $00, $99, $16, $00 ; $01
	.db $00, $A0, $A0, $A0 ; $02
	.db $00, $A2, $A2, $A2 ; $03
	.db $00, $D6, $9B, $18 ; $04
	.db $00, $0A, $0A, $08 ; $05
	.db $00, $1F, $1F, $1F ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World4GroundTilesHorizontal + $40, $00
ENDIF

World4GroundTilesVertical:
	.db $00, $C6, $99, $9D ; $00
	.db $00, $A2, $A2, $A2 ; $01
	.db $00, $9B, $9B, $9B ; $02
	.db $00, $A0, $A0, $A0 ; $03
	.db $00, $D6, $D6, $D6 ; $04
	.db $00, $18, $18, $18 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World4GroundTilesVertical + $40, $00
ENDIF

World5GroundTilesHorizontal:
	.db $00, $99, $D5, $40 ; $00
	.db $00, $99, $99, $99 ; $01
	.db $00, $A0, $A0, $A0 ; $02
	.db $00, $A2, $A2, $A2 ; $03
	.db $00, $D6, $9B, $18 ; $04
	.db $00, $A0, $A0, $99 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World5GroundTilesHorizontal + $40, $00
ENDIF

World5GroundTilesVertical:
	.db $00, $9D, $9E, $C6 ; $00
	.db $00, $05, $A0, $00 ; $01
	.db $00, $40, $A4, $00 ; $02
	.db $00, $00, $A2, $00 ; $03
	.db $00, $00, $C2, $00 ; $04
	.db $00, $00, $A0, $00 ; $05
	.db $00, $93, $9E, $C6 ; $06
	.db $00, $40, $9E, $C6 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World5GroundTilesVertical + $40, $00
ENDIF

World6GroundTilesHorizontal:
	.db $00, $99, $99, $99 ; $00
	.db $00, $8A, $8A, $8A ; $01
	.db $00, $8B, $8B, $8B ; $02
	.db $00, $A0, $A0, $A0 ; $03
	.db $00, $A2, $A2, $A2 ; $04
	.db $00, $D6, $9B, $18 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World6GroundTilesHorizontal + $40, $00
ENDIF

World6GroundTilesVertical:
	.db $00, $9D, $9E, $C6 ; $00
	.db $00, $93, $A0, $00 ; $01
	.db $00, $40, $18, $40 ; $02
	.db $00, $93, $9E, $C6 ; $03
	.db $00, $40, $9E, $C6 ; $04
	.db $00, $00, $00, $00 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World6GroundTilesVertical + $40, $00
ENDIF

World7GroundTilesHorizontal:
	.db $00, $9C, $9C, $9C ; $00
	.db $00, $D7, $9C, $19 ; $01
	.db $00, $00, $00, $00 ; $02
	.db $00, $00, $00, $00 ; $03
	.db $00, $00, $00, $00 ; $04
	.db $00, $00, $00, $00 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World7GroundTilesHorizontal + $40, $00
ENDIF

World7GroundTilesVertical:
	.db $00, $9C, $9C, $9C ; $00
	.db $00, $05, $A0, $00 ; $01
	.db $00, $00, $00, $00 ; $02
	.db $00, $00, $9C, $00 ; $03
	.db $00, $00, $C2, $00 ; $04
	.db $00, $00, $A0, $00 ; $05
	.db $00, $00, $00, $00 ; $06
	.db $00, $00, $00, $00 ; $07
IFDEF EXPAND_TABLES
	unusedSpace World7GroundTilesVertical + $40, $00
ENDIF

; -----
