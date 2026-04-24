I'd like to quickly share my setup for debugging Gen III Pokémon games. This setup has helped me both understand how undocumented parts of the games work and also create the mods on this site. Hopefully sharing this helps others looking to do the same.

This setup is compatible with the [pokeruby](www.github.com/pret/pokeruby), [pokefirered](www.github.com/pret/pokefirered), and [pokeemerald](www.github.com/pret/pokeemerald) projects on Linux, MacOS, or WSL.

# VSCode

[VSCode](https://code.visualstudio.com/) offers a great interface for [debugging](https://code.visualstudio.com/docs/editor/debugging) code. The experience is streamlined into the code editor and uses the source code to provide useful context while debugging. Let me explain with a few examples.

## Setting breakpoints

You can set a breakpoint at a particular line of code. When that line is executed, the progam pauses, allowing you to inspect program state (such as RAM variables and the call stack). You can then follow the program as it executes line-by-line.

This action is highly streamlined in VSCode -- you simply click next to a line of code to add a breakpoint:




![figure](/posts/debugging-gen-3/breakpoint.png)




## Watching global variables

The Gen III Pokémon games use many global variables. VSCode allows you to watch these variables -- when the program is paused, you can see their current values. The interface interprets and displays C data types, allowing you to easily explore how structs and arrays defined in the source code are used.

For example, we can watch the internal representation of a trainer card `sTrainerCard->trainerCard`. When the game is paused, we see its value which includes the trainer ID, Pokédex count, and play time:




![figure](/posts/debugging-gen-3/watching.png)




## Setting watchpoints

Sometimes a global variable changes, and you'd like to figure out exactly when it happened. In VSCode, you can set a watchpoint on a global variable. When the value of the variable changes, VSCode pauses the program and shows you the line of code that made the change.

For example, the colon in the trainer card's play time ticks every second. To find out which line causes this, we set a watchpoint in VSCode's debug console:

```bash
-exec watch sTrainerCard->timeColonInvisible
bash something
grep another thing
./script.py boo
```

```c
// True if the boardId corresponds to at least level `level`.
#define LEVEL_AT_LEAST(boardId, level) (boardId >= 10 * (level - 1))

static int VoltorbFlipGameState_CalcNextLevel(VoltorbFlipGameState *game) {
    int i;
    u32 boardId;
    VoltorbFlipRoundOutcome roundOutcome;

    RoundSummary *prevRound = VoltorbFlipGameState_GetBoardHistoryTop(game);
    roundOutcome = prevRound->roundOutcome;

    if (roundOutcome == ROUND_OUTCOME_WON && LEVEL_AT_LEAST(prevRound->boardId, 8)) {
        return 0; // Lv. 8
    }

    boardId = prevRound->boardId;
    // You can reach Lv. 8 if you're at Lv. 5 or higher now and if in each of
    // the last 5 rounds you:
    //  - Did not lose
    //  - Flipped at least 8 cards
    if (LEVEL_AT_LEAST(boardId, 5)) {
        for (i = 0; i < 5; i++) {
            RoundSummary *round = &game->boardHistory[i];
            if (round->cardsFlipped < 8 || round->roundOutcome == ROUND_OUTCOME_LOST) {
                break;
            }
        }
        if (i == 5) {
            return 0; // Lv. 8
        }
    }

    if ((LEVEL_AT_LEAST(boardId, 7) && prevRound->cardsFlipped >= 7) || (LEVEL_AT_LEAST(boardId, 6) && roundOutcome == ROUND_OUTCOME_WON)) {
        return 1; // Lv. 7
    }
    if ((LEVEL_AT_LEAST(boardId, 6) && prevRound->cardsFlipped >= 6) || (LEVEL_AT_LEAST(boardId, 5) && roundOutcome == ROUND_OUTCOME_WON)) {
        return 2; // Lv. 6
    }
    if ((LEVEL_AT_LEAST(boardId, 5) && prevRound->cardsFlipped >= 5) || (LEVEL_AT_LEAST(boardId, 4) && roundOutcome == ROUND_OUTCOME_WON)) {
        return 3; // Lv. 5
    }
    if ((LEVEL_AT_LEAST(boardId, 4) && prevRound->cardsFlipped >= 4) || (LEVEL_AT_LEAST(boardId, 3) && roundOutcome == ROUND_OUTCOME_WON)) {
        return 4; // Lv. 4
    }
    if ((LEVEL_AT_LEAST(boardId, 3) && prevRound->cardsFlipped >= 3) || (LEVEL_AT_LEAST(boardId, 2) && roundOutcome == ROUND_OUTCOME_WON)) {
        return 5; // Lv. 3
    }
    if ((LEVEL_AT_LEAST(boardId, 2) && prevRound->cardsFlipped >= 2) || (roundOutcome == ROUND_OUTCOME_WON)) {
        return 6; // Lv. 2
    }
    return 7; // Lv. 1
}

static void VoltorbFlipGameState_SelectBoardId(VoltorbFlipGameState *game) {
    int i;

    int rand = (u32)MTRandom() % 100;
    int level = VoltorbFlipGameState_CalcNextLevel(game);
    GF_ASSERT(level < 8);

    for (i = 0; i < 80; i++) {
        if (rand < sBoardIdDistribution[level][i]) {
            break;
        }
        GF_ASSERT(i < 80);
    }
    game->level = level;
    game->boardId = i;
}
```

Then the game will pause after the value of `sTrainerCard->timeColonInvisible` changes. Here we see line 1566 caused the change:




![figure](/posts/debugging-gen-3/watchpoint.png)




# Setup

In addition to VSCode, this setup requires the [mGBA](https://mgba.io) emulator, and [devkitPro](https://devkitpro.org/wiki/Getting_Started). mGBA comes with a gdb server, which VSCode can hook into to issue debugging commands.

In VSCode, you can configure your debugging setup in the `.vscode/launch.json` file of your project. We specify a launch configuration which boots up mGBA and the debugging server. The configuration contains a `preLaunchTask` defined in `.vscode/tasks.json`, which builds the game with debug symbols, loads it into mGBA, and starts the server.

# Notes

In order to use this setup on WSL, the project folder must be located in the WSL file system.

It is worth noting that because these games are compiled at the -O2 [optimization level](https://gcc.gnu.org/onlinedocs/gnat_ugn/Optimization-Levels.html), some variables and lines of code are optimized out of the game. If needed, you can recover these by inserting calls to dummy functions.

Special thanks to [Sierraffinity](https://github.com/Sierraffinity) for first documenting this workflow.

# Links

[VSCode workflow](https://gist.github.com/abaresk/436a42d01534f169d3d3a763fde24fcf)
