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

void
CheatersLament(ncPlayer playerEntity, vector absAngles, float buttons, float timeLength)
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
	if (buttons & INPUT_PRIMARY || buttons & INPUT_SECONDARY) { /* primary & secondary fire counts */
		vector deltaPosition;
		float deltaDegrees;

		makevectors( absAngles );
		for (entity e = world; (e = next.Player(e));) {
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
