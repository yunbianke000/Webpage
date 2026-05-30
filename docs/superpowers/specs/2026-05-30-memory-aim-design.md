# Memory Test & Aim Trainer Design Spec

## 1. Overview
Extend the current Toolbox application with two new human-capability tests: "Memory Test" (chimpanzee test style) and "Aim Trainer". These additions align with the existing "CPS Test" and "Reaction Test" to form a comprehensive testing suite.

## 2. Architecture & Integration
- **Navigation:** Add two new tabs to the top-level tab bar (`.tab-bar`): "Memory Test" and "Aim Trainer".
- **Tool Containers:** Create `.tool-memory` and `.tool-aim` containers within `.left-panel` and `.right-panel`.
- **CSS Architecture:** Reuse existing CSS variables (`--bg-tertiary`, `--accent-cyan`, `--glow-cyan`, etc.) for consistency. Use the existing `.panel`, `.stage-container`, and `.stat-item` layouts.
- **I18n:** Add translation keys for both tools across zh, en, ru, and ja.
- **State Management:** Isolate state in `memoryState` and `aimState` objects. Save histories to `localStorage`.

## 3. Component Details

### 3.1 Memory Test
- **Left Panel (Stage):**
  - A fixed CSS Grid container (e.g., 6x6 or 7x7).
  - Control bar with a "Start" button.
  - **Gameplay Logic:**
    1. Generate `N` random unique positions in the grid (starts at N=3).
    2. Display numbered tiles (1 to N).
    3. User clicks '1'. Immediately, tiles 2 to N lose their numbers and become identical solid squares.
    4. User must click the remaining tiles in order.
    5. Success: N increases by 1, automatically start next level.
    6. Failure: Game ends, save score (Max Level reached).
- **Right Panel (Stats & Rules):**
  - **Stats Grid:** Current Level, Best Level, Strikes/Errors.
  - **Rules:** Explain the click-1-to-hide mechanic.
  - **History:** List of previous attempts and max levels reached.

### 3.2 Aim Trainer
- **Left Panel (Stage):**
  - A large relative container `.aim-area`.
  - Control bar: Target count selector (e.g., 10, 20, 30) and "Start" button.
  - **Gameplay Logic:**
    1. Spawns a single target (`.aim-target`, circular, absolute positioned within bounds).
    2. When clicked, it disappears and immediately spawns a new one at a random location.
    3. Tracks total time taken to click all targets.
- **Right Panel (Stats & Rules):**
  - **Stats Grid:** Remaining targets, Average time per target (ms), Best average time.
  - **Rules/Tips:** Click targets as fast as possible.
  - **History:** List of recent tests (Target count, Avg Time, Total Time).

## 4. Error Handling & Edge Cases
- **Memory Test:** Clicking an empty grid cell does nothing. Clicking out of order triggers a visual error shake (`invalid-flash`) and ends the game.
- **Aim Trainer:** Ensure targets spawn fully within the bounding box (calc max top/left). Ensure targets don't spawn overlapping the exact previous position to prevent double-clicks registering instantly.
- **Tab Switching:** If a test is running and the user switches tabs, the test should be aborted/reset cleanly to prevent background timers from leaking.

## 5. Testing Strategy
- Verify tab switching logic correctly hides/shows `.tool-memory` and `.tool-aim`.
- Verify i18n switches correctly update all new labels.
- Play Memory Test through level 3 and fail on level 4 to ensure game over and history save works.
- Play Aim Trainer with 10 targets to ensure average calculation and history save works.