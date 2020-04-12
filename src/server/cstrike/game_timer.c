/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

void Timer_Begin(float tleft, int mode)
{
	if (mode == GAME_FREEZE) {
		g_cs_gamestate = GAME_FREEZE;
	} else if (mode == GAME_ACTIVE) {
		g_cs_gamestate = GAME_ACTIVE;
	} else if (mode == GAME_END) {
		g_cs_gamestate = GAME_END;
	} else if (mode == GAME_COMMENCING) {
		g_cs_gamestate = GAME_COMMENCING;
	} else if (mode == GAME_OVER) {
		g_cs_gamestate = GAME_OVER;
	}

	g_cs_gametime = tleft;
}

void
Timer_Update(void)
{
//	static float fVoxTimer;

	if (cvar("sv_playerslots") == 1) {
		g_cs_gametime = -1;
		return;
	}

	// This map has been played enough we think
	if (g_cs_gamestate != GAME_OVER) {
		if (cvar("mp_timelimit") > 0) {
			/*if (autocvar_fcs_voxannounce == TRUE) {
				if (fVoxTimer > time) {
					return;
				}
				
				float fTimeLeft = (cvar("mp_timelimit") * 60) - time;
				for (int i = 0; i <= 10; i++) {
					if (rint(fTimeLeft) == (i * 60)) {
						Vox_Broadcast(sprintf("%s minutes remaining", Vox_TimeToString(fTimeLeft / 60)));
						fVoxTimer = time + 10.0f;
					}
				}
			}*/
		
			if (time >= (cvar("mp_timelimit") * 60)) {
				Timer_Begin(5, GAME_OVER);
			}
		}
	}

	if ((g_cs_gamestate == GAME_OVER) && (g_cs_gametime < 0)) {
		localcmd("nextmap\n");
	}

	// Okay, this means that timelimit is not the only deciding factor
	if (autocvar_mp_winlimit > 0 && g_cs_gamestate != GAME_OVER) {
		// It really doesn't matter who won. Do some logging perhaps?
		if (g_cs_roundswon_ct == autocvar_mp_winlimit) {
			Timer_Begin(5, GAME_OVER);
		} else if (g_cs_roundswon_t == autocvar_mp_winlimit) {
			Timer_Begin(5, GAME_OVER);
		}
	}

	if (g_cs_gamestate == GAME_INACTIVE) {
		return;
	}

	if (g_cs_gametime > 0) {
		g_cs_gametime -= frametime;
	} else {
		g_cs_gametime = 0;
	}

	if (g_cs_gamestate == GAME_COMMENCING || g_cs_gamestate == GAME_END) {
		if (g_cs_gametime <= 0) {
			if (g_cs_roundswon_t == 0 && g_cs_roundswon_ct == 0) {
				Money_ResetTeamReward();
				Money_ResetRoundReward();
				Rules_Restart(TRUE);
			} else {
				if (autocvar_mp_halftime == TRUE && (autocvar_mp_winlimit / 2 == g_cs_roundsplayed)) {
					Money_ResetTeamReward();
					Rules_SwitchTeams();
					Rules_Restart(TRUE);
				} else {
					Rules_Restart(FALSE);
				}
			}
		}
		return;
	}

	if ((g_cs_gamestate == GAME_ACTIVE) || (g_cs_gamestate == GAME_FREEZE)) {
		if (g_cs_gametime <= 0) {
			if (g_cs_gamestate == GAME_ACTIVE) {
				/* 1.5 will make the T's lose if time runs out no matter what */
				if (autocvar_fcs_fix_bombtimer == TRUE) {
					if (g_cs_bombzones > 0 && g_cs_bombplanted == TRUE) {
						return;
					}
				}
				Rules_TimeOver();
				Timer_Begin(5, GAME_END); // Round is over, 5 seconds til a new round starts
			} else {
				Timer_Begin(autocvar_mp_roundtime * 60, GAME_ACTIVE); // Unfreeze
				Radio_StartMessage();
			}
		}
	}
}
