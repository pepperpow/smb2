;
; Bank C & Bank D
; ===============
;
; What's inside:
;
;   - The ending sequence with Mario sleeping and the cast roll
;

IFNDEF EXCLUDE_MARIO_DREAM
.include "src/mario_dream/main.asm"
ELSE
.db 'haha heeeheeehhahah ho ho hah ha ha'
ENDIF