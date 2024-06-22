# Multiplayer Systems {#mp}

## Punkbusting (Cheaters Lament) System {#lament}

### Preface

Cheating in games is a difficult problem to tackle, as those measures have gotten more sophisticated over the years.

It is now common to deploy more invasive techniques, even going down into the kernel level. It is our belief that automated systems won't work on any scale and that the only reliable mechanism is informing players as to what is going on.

Our proposed solution is dubbed **Cheaters Lament**.

### Analysis of Automated Solutions

Automated systems have, much like humans, high rates of error. Calibration is a necessary, ongoing duty for the vendor. Automated systems have to constantly adjust the changing methods and strategies of detecting unfair behaviour.

Automated systems are judge, jury and executioner. Which means if they misjudge, it hurts players that are innocent, and will make those individuals very unhappy.

And in some games, some players are not given enough tools to make a confident decision. Often automated systems don't detect new, or non-obvious cheats.

### Our Proposal

**Cheaters Lament** is a passive warning system collecting movement information about a player and testing it against their movement tracking capability.

If someone has an insanely rating it will trigger a warning to the console. This system can be elevated so it will notify other players of said warning. Players can then leverage the built-in [voting](@ref voting) system to make a democratic decision over the fate of the player.

### Our Implementation

We accumulate the camera angle deltas over time, tracking the average mouse movement intensity over a short period of time. Waiting a full second will remove a full 360 degrees of delta.  

We also accumulate accuracy information by increasing a counter whenever the player is actively firing, while also aiming at an opposing player with a radius of less than 10 degrees (to compensate for projectiles). Whenever the player we're tracking is firing, and not aiming with that consistent level of precision, we decrease the counter.  

If the deltas are both very high, that must mean that the player is having frantic mouse movements, coupled with insanely high accuracy.

### Limitations

The system can totally misfire, especially in high latency environments where we cannot get enough movement samples.

Since the system is passive and won't act on its own, it doesn't really have any negative consequences if it does fire a warning.

It is calibrated against a demo of someone most likely cheating in the videogame **Quake**. It might need to be recalibrated to be useful in other types of games.

Currently there is no easy way to calibrate it, or to turn it off.
