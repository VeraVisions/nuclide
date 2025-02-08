# Singleplayer Systems {#sp}

## Level Transition System {#transitions}

Moving between different levels is ensured in part by the engine, and in part by Nuclide and sub-systems such as the [Save/Restore System](@ref saveload).

Level designers create level changes by utilising the trigger_changelevel entity. For transitions to work, they usually need to incorporate an info_landmark, to designated a shared point between two levels.  

In addition, it is recommended that they place a trigger_transition with the same name as the info_landmark. Otherwise you risk carrying over too much entity data. Please read the entity documentation for more details.

When a level transition is completed, Nuclide will call the overridable method `ncEntity::TransitionComplete()` on every entity, to give it a chance to re-align itself with the new environment.
