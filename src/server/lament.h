/*
 * Copyright (c) 2023 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/** @defgroup lament Anti-Cheat
    @brief Cheaters Lament: passive anti-cheat system
    @ingroup server

System designed to analyze movement deltas and warn about suspicious
behaviour as it is happening.

# Explanation

Intense movement comes with decreased accuracy. If a player is
showcasing signs of above average reaction time and consistent success
in trailing (and shooting) valid targets we are going to inform the
server admin of suspicious behaviour.

The system does not act on its own, it merely gives feedback and
expects the host to act upon it.

We can tally the feedback and create a score based on suspicious
behaviour as a result. these results should ideally be made public
to the other players so they themselves can make a choice.

# Technical Deep Dive

We accumulate the camera angle deltas over time to track
the average mouse movement intensity over a short period of time.
waiting a full second will actually remove a full 360 degrees
of delta.
Then we also accumulate accuracy information, we increases a counter
whenever the player is actively firing, while also aiming at an opposing
player within an radius of less than 10 degrees (to compensate for rocket shots
and othe projectile trails).
Whenever the player is firing and not aiming with that level of precision,
the counter goes down.

If the deltas together reach a high point together, that must mean that
the player is having frantic mouse movements, combined with
incredible hit accuracy.

The high point calibration is taken from analyzing various demos
of known pro players as well as some cheating incidents.

# Limitations

When going through teleporters, the angle deltas may be high
enough to trigger false positives.

This is obviously not a perfect system, but it is to be used
as a tool to assist in the decision making that goes into
moderating a game server.

@{

*/

 
/** Called by Nuclide within `SV_RunClientCommand()` every time an input packet is received. */
void CheatersLament(NSClientPlayer, vector, float, float);

/** @} */ // end of lament