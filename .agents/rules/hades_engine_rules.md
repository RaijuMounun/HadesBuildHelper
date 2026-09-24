# Hades Engine Identification Rules

**CRITICAL RULE: DO NOT GUESS OR HALLUCINATE INTERNAL GAME IDs.**

## 1. Zero Tolerance for Assumptions
- **NO GUESSING:** The AI MUST NOT make ANY assumptions about internal Hades engine IDs, Trait names, Weapon names, Boon names, Prop IDs, Enemy IDs, or any other game asset names.
- **NO CONVERSATIONAL EXCUSES:** Do NOT generate speculative explanations or rationalizations for mismatched IDs (e.g., "I assumed it was X because it was in the database, but the game uses Y"). The user explicitly forbids these types of explanations. Just get it right the first time or ask.
- **DATABASE != ENGINE:** Never assume a name used in our custom database maps 1:1 to a game engine internal ID.

## 2. Enforcement & Verification
1. **Evidence-Based Lookups:** You MUST strictly rely on evidence from the game's actual data files or the `Data/GameDataParser.lua`.
2. **Explicit User Verification:** If you do not have absolute, definitive proof of a hook, ID, or trait's internal game engine name from the data parser, you MUST explicitly ASK THE USER for the true internal ID before writing any code.
3. **Stop on Uncertainty:** If you are unsure of the engine naming conventions for a specific object, DO NOT attempt to guess, synthesize, or infer a name. Stop your work and request the exact internal ID from the user immediately.

Failure to follow these rules will cause the mod to hook into non-existent engine objects and crash the game silently. Always use verified IDs.
