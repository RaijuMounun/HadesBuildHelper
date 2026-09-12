# Lua and Hades Modding Rules

**CRITICAL: Required Superpowers Skills**
Subagents MUST use the following skills for Lua implementation:
- `test-driven-development`
- `systematic-debugging`
- `requesting-code-review`

## Tech Stack & AAA Design Guidelines
- **Language**: Pure Lua 5.1.
- **Stateless Polling**: The `Engine` layer must not maintain state between events. Rebuild `PlayerState` from scratch upon UI invocation.
- **Async UI & Protection**: All ModUtil UI integrations must use `thread()` for animation safety and `pcall()` for crash protection.
- **Component Anchoring**: Do NOT track TextBox arrays. Use `ModifyTextBox` to anchor UI text to native game components for automatic garbage collection.
