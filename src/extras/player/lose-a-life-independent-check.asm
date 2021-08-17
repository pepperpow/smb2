
    LDX IndependentLives
    BEQ +
    LDX CurrentCharacter
    DEC PlayerIndependentLives, X
    LDA PlayerIndependentLives, X
    STA ExtraLives
    BNE ++
    LDA CharLookupTable, X
    ORA CharacterLock_Variable
    STA CharacterLock_Variable
    CMP #$F
    BNE ++
    INY
    JMP SetGameModeAfterDeath
+   LDA ExtraLives  
++