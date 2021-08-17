.ignorenl

; ----------------------------------------
;  Super Mario Bros. 2 Disassembly Config
; ----------------------------------------
;
; By default, this repository is set up to build an identical copy
; of the original PRG0 revision of Super Mario Bros. 2 (USA).

; You can tweak the build settings below. To remove
; the default options, comment them out.
; (Changing the assignment to 0 won't work.)
;
; To enable them indefinitely, uncomment the definition.
;
; To enable them for a single build from the command line, use
; build -dFLAGNAME
; For example, to build a PRG1/Rev A ROM,
; build -dREV_A

; ----------------------------------------
; Compatibility fixes for the disassembly
; In some locations, Nintendo used absolute addressing instead of
; zero-page for addresses in the zero page.
; This flag adds in raw bytes to match the opcodes,
; as this assembler isn't capable of forcing absolute addressing for zp.
;
; Note that if you use this, you should probably use
; PRESERVE_FREE_SPACE, too.
COMPATIBILITY = 1

; ----------------------------------------
; Preserve unused space.
; Free space in the original ROM will continue to be padded outwards,
; to the extent that it was in the original.
; Adding your own code should shrink the free space afterwards automatically.
;
; Turning this off will "squish" most banks and move free space
; within them to the end, making it easier to add your own code anywhere.
; ...but it might also cause problems if data gets relocated
; when it isn't properly pointed to.

; PRESERVE_UNUSED_SPACE = 1

; ----------------------------------------
; Build PRG1 / Revision A ROM.
;
; Differences:
;
; PRG-2-3: Fixes bug where killing one of the mini FryGuy enemies
;          while changing size from taking damage would cause
;          the enemy to do the "flip over and fall off" death
;          instead of the "puff of smoke" death, which caused
;          the "number of small bosses left" number to not
;          decrease. Which meant the boss fight never ended.
;          Hope you had an extra life and a second controller...
;
; PRG-E-F: Fixes a minor issue when played on PAL consoles where
;          remarkably poor luck would cause the bonus chance screen
;          to end up rendering completely invisibly due to an NMI hitting
;          at the worst possible time.
;          The fix just waits for an NMI cycle before doing its work.
;
; REV_A = 1
;
;
;
;; ----------------------------------------
;; Patches that fix bugs or glitches
;
;
;; Show all 8 frames of CHR cycling animation
; FIX_CHR_CYCLE = 1
;
;; Fixes the POW falling log glitch
; FIX_POW_LOG_GLITCH = 1
;
;; Fixes vine climbing bug when holding up and down simultaneously
; FIX_CLIMB_ZIP = 1
;
;; Fixes green platform tiles in Subspace
; FIX_SUBSPACE_TILES = 1


;; ----------------------------------------
;; Patches that alter the game in
;; interesting or useful ways


;; Skips Bonus Chance after the end of a level
;; DISABLE_BONUS_CHANCE = 1

;; Go to the Charater Select screen after death
;; CHARACTER_SELECT_AFTER_DEATH = 1

;; Restore the prototype's DPCM samples and/or music;
;; NOTE: The prototype underground music requires the shortened prototype ending music to fit
;; everything in the music header table. Use EXPAND_MUSIC to remove this restriction.
;; PROTOTYPE_DPCM_SAMPLES = 1
;; PROTOTYPE_INSTRUMENTS = 1
;; PROTOTYPE_MUSIC_STARMAN = 1
;; PROTOTYPE_MUSIC_UNDERGROUND = 1
;; PROTOTYPE_MUSIC_ENDING = 1

;; Include debugging tools
;; (push Select to open the debug menu)
;; DEBUG = 1

;; Include controller 2 debug features
;; (@TODO: explain usage)
;; CONTROLLER_2_DEBUG = 1



; ----------------------------------------
; Patches and enhancements largely useful
; only to people hacking the game


; Expand PRG and/or CHR to max capacity
; EXPAND_PRG = 1
; EXPAND_CHR = 1

; Use MMC5 (mapper 5) instead of MMC3 (mapper 4)
; Based on RetroRain's MMC5 patch (https://www.romhacking.net/hacks/2568)
; MMC5 = 1

; Use FME-7 (mapper 69) instead of MMC3 (mapper 4)
; FME7 = 1

; Pads title screen PPU data for easier modification
; PAD_TITLE_SCREEN_PPU_DATA = 1

; Expands various lookup tables so that more values can be added
; EXPAND_TABLES = 1

; Skip unnecessary bonus chance RAM copy
; BONUS_CHANCE_RAM_CLEANUP = 1

; Uses an alternative pointer method for music headers to allow for more segments
; EXPAND_MUSIC = 1

; Encode world tileset in unused 3 bits of area header byte 2
; AREA_HEADER_TILESET = 1

; Checks the CHR latch variable to reload the CHR data
; RESET_CHR_LATCH = 1

; Encode level engine object mode switch in unused 2 bits of area header byte 4
; ENABLE_LEVEL_OBJECT_MODE = 1

; Enables additional level engine features
; LEVEL_ENGINE_UPGRADES = 1

; Enables quicksand tile behavior outside of worlds 2 and 6
; ALWAYS_ALLOW_QUICKSAND = 1

; Use a tile attributes table for rather than TileSolidnessTable
; ENABLE_TILE_ATTRIBUTES_TABLE = 1

; Disables door pointers, so that area pointers are always required
; DISABLE_DOOR_POINTERS = 1uuuuuuuuuuuuuu

; Enables full-page door/vine searching so that entrances don't need to align
; ROBUST_TRANSITION_SEARCH = 1

;; Fixes and Simple Mechanics
REV_A = 1 ; Revision A
ALWAYS_ALLOW_QUICKSAND = 1 ; Quicksand in All Worlds
ROBUST_TRANSITION_SEARCH = 1 ; Align Transitions in all cases
AREA_HEADER_TILESET = 1
FIX_POW_LOG_GLITCH = 1
FIX_CHR_CYCLE = 1
FIX_CLIMB_ZIP = 1
FIX_SUBSPACE_TILES = 1

TRANSITION_INVULN = 1 ; Invuln on transition
JUMP_THROW_FIX = 1 ; Don't drop item on squat jump
HEALTH_REVAMP = 1 ; Show over 4 health
SMALL_HITBOX = 1 ; Crouch hitbox for hit character
BLOCK_CHECK = 1 ; Hit objects from below
SHELL_FIX = 1 ; Shell bounces
SCROLL_FIX = 1 ; Scroll always after transition
NO_CONTINUE = 1 ; Disable continue from beginning of world
CARRY_ON_VINE = 1 ; Carry potion/key from vine
HAWKMOUTH_FIX = 1 ; Hawkmouth in two directions
TEST_FLAG_VERT_SUB = 1 ; Vertical subspace
MUSH_BLOCK_FIX = 1 ; block fix

AreaTransitioned_Invuln = $7603
CharacterLock_Variable = $7610
VertSubspaceFlag = $73F4
CurrentLevelAreaIndex = $73F0
PlayerIndependentLives = $73F8
BossHP = $73F2

; ;; Code changes
CUSTOM_LEVEL_RLE = 1 ; Custom Level Generation
RANDOMIZER_FLAGS = 1 ; Flags
CHAR_SWITCH = 1 ; char switch
DRAW_SECRET = 1
CUSTOM_PLAYER_RENDER = 1
CHARACTER_SELECT_AFTER_DEATH = 1
INDIE_LIVES = 1

; ;; Space changes
EXPAND_PRG = 1
EXPAND_CHR = 1
CUSTOM_CHR = 1
; MMC5 = 1
CUSTOM_TITLE = 1 ; New Title
; EXCLUDE_MARIO_DREAM = 1 ; Remove Mario Dream
REMOVE_UNUSED_DPCMS = 1 ; remove unused dpcms
; TODO: Bug with POW Blocks, just needs to change where damage function works
; SECONDARY_ROUTINE_MOVE = 1 ; Move health render to another bank
; TODO: Bug with Mushroom Blocks which need this for rendering back to tile
MIGRATE_QUADS = 1 ; Move Quad Info to bank 1

;FALL_DEFENSE = 1
;CUSTOM_TITLE = 1
;BLOCK_CHECK = 1
;CUSTOM_TILE_IDS = 1

;;; DEBUG = 1

;FLAG_SYSTEM = 1
;LEVEL_FLAGS = 1
;DAMAGE_RESIST = 1
;LOCKED_DOOR = 1

;TEST_FLAG = 1

;;CUSTOM_UNUSED = 1

;CUSTOM_MUSH = 1

;PHANTO_CUSTOM = 1


endinl
