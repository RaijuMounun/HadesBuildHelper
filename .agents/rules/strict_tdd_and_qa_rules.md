# Strict TDD and QA Rules

**CRITICAL: Required Superpowers Skills**
All subagents involved in logic or engine development MUST use the following skills:
- `test-driven-development`
- `systematic-debugging`
- `requesting-code-review`
- `receiving-code-review`
- `verification-before-completion`

## QA Protocols
1. **Unit Testing (Phase 1)**: Pure Lua functions in the `Engine/` module must be developed with TDD using `test_scoring.lua`. Tests must evaluate the Exponential Math Curves and Additive Scoring (capped at 100%).
2. **In-Game Manual QA (Phase 2)**: Use Codex Menu Mod (nexusmods.com/hades/mods/15) to spawn boons/states and verify UI rendering. Verify that no text persists after closing the menu.
