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

/* cheaters lament

a system designed to analyze movement deltas and warn about suspicious
behaviour as it is happening.

explanation:

intense movement comes with decreased accuracy. if a player is
showcasing signs of above average reaction time and consistent success
in trailing (and shooting) valid targets we are going to inform the
server admin of suspicious behaviour.

the system does not act on its own, it merely gives feedback and
expects the host to act upon it.

we can tally the feedback and create a score based on suspicious
behaviour as a result. these results should ideally be made public
to the other players so they themselves can make a choice

technical deep dive:

we accumulate the camera angle deltas over time to track
the average mouse movement intensity over a short period of time.
waiting a full second will actually remove a full 360 degrees
of delta.
then we also accumulate accuracy information, we increases a counter
whenever the player is actively firing, while also aiming at an opposing
player within an radius of less than 10 degrees (to compensate for rocket shots
and othe projectile trails).
whenever the player is firing and not aiming with that level of precision,
the counter goes down.

if the deltas together reach a high point together, that must mean that
the player is having frantic mouse movements, combined with
incredible hit accuracy.

the high point calibration is taken from analyzing various demos
of known pro players as well as some cheating incidents.

limitations:

when going through teleporters, the angle deltas may be high
enough to trigger false positives.

this is obviously not a perfect system, but it is to be used
as a tool to assist in the decision making that goes into
moderating a game server.
*/

void
CheatersLament(NSClientPlayer playerEntity, vector absAngles, float buttons, float timeLength)
{
	vector angleDelta = playerEntity.pb_last_angles - absAngles; /* diff between old and new */

	/* only decrement above 0 */
	if (playerEntity.pb_angle_delta > 0.0)
		playerEntity.pb_angle_delta -= timeLength * 360;
	else
		playerEntity.pb_angle_delta = 0.0f;

	/* ditto */
	if (playerEntity.pb_player_delta > 0.0)
		playerEntity.pb_player_delta -= timeLength;
	else
		playerEntity.pb_player_delta = 0.0f;

	/* if the player is firing, calculate the player delta */
	if (buttons & INPUT_BUTTON0 || buttons & INPUT_BUTTON3) { /* primary & secondary fire counts */
		vector deltaPosition;
		float deltaDegrees;

		makevectors( absAngles );
		for (entity e = world; (e = find(e, ::classname, "player"));) {
			deltaPosition = normalize( e.origin - playerEntity.origin );
			deltaDegrees = deltaPosition * v_forward;

			other = world;
			traceline(e.origin, playerEntity.origin, MOVE_OTHERONLY, playerEntity);

			if (trace_fraction == 1.0f && deltaDegrees >= 0.95) {
				playerEntity.pb_player_delta += timeLength * 4.0f;
			}
		}
	}

	playerEntity.pb_last_angles = absAngles; /* set so we don't accumulate */

	/* if our angle delta is less than 256, don't bother reporting */
	if (vlen(angleDelta) < 256.0) {
		return;
	}

	/* we will add the difference only if it is big enough from last frame */
	playerEntity.pb_angle_delta += vlen(angleDelta);

	/* if our delta is consistently above 1024 and we've been trailing a player for 2
		whole second... suspect foul play */
	if (playerEntity.pb_angle_delta > 1024.0 && playerEntity.pb_player_delta > 2.0) {
		localcmd(sprintf("echo Lamenting %S (%s) with (a: %f p: %f)\n", playerEntity.netname, infokey(playerEntity, INFOKEY_P_IP), playerEntity.pb_angle_delta,  playerEntity.pb_player_delta));
	}
}