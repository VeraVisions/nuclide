# Singleplayer Systems {#sp}

## Save/Load System {#saveload}

### Nuclide APIs

Every NSEntity class usually comes with a `NSEntity::Save()` and `NSEntity::Restore()` override. These are also used for [level transitions](@ref transitions).

When a save-game has been restored, the overridable method `NSEntity::RestoreComplete()` will be called. At that point AI or some time based triggers get the chance to re-align themselves with the reloaded environment (if necessary).

### LVC Files
The engine stores cached copies for the current (non-saved) game into the `<gamedir>/saves` directory, in the form of **lvc** files. Each **lvc** file represents a map, containing a copy of its **entity lump**. 

When a specific save is made, it will have its own directory under `<gamedir>/saves/`, with its own copy of **lvc** files.

### FSV Files

Contain misc meta-data accompanying the save file, such as rate, chapter title, player slot parameters, server info keys, as well as specifically engine tracked console variables.

### Preview Image

The preview image for save games is stored under `<gamedir>/saves/<savename>/screeny.tga`.

