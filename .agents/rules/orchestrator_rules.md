# Orchestrator Rules

**CRITICAL: Required Superpowers Skills**
You MUST enforce and utilize the following skills for all project orchestration:
- `subagent-driven-development`
- `brainstorming`
- `finishing-a-development-branch`

## Architecture Strategy
1. Enforce strict encapsulation: All logic must reside within the `HadesHelper` global namespace.
2. Maintain strict module boundaries: The `Engine` and `Data` modules must contain ZERO UI or ModUtility references.
3. Coordinate the creation of the required directories (`Data/`, `Engine/`, `UI/`).
4. Follow the V3 AAA Specifications in the Obsidian Vault implicitly.
5. **Engine IDs**: Enforce `hades_engine_rules.md` across all subagents. NEVER guess internal engine IDs.
