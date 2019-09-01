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

/*
=================
Timer_Begin

Initiates a new state timer
=================
*/
void Timer_Begin(float fTime, float fMode)
{
	if (fMode == GAME_FREEZE) {
		fGameState = GAME_FREEZE;
	} else if (fMode == GAME_ACTIVE) {
		fGameState = GAME_ACTIVE;
	} else if (fMode == GAME_END) {
		fGameState = GAME_END;
	} else if (fMode == GAME_COMMENCING) {
		fGameState = GAME_COMMENCING;
	} else if (fMode == GAME_OVER) {
		fGameState = GAME_OVER;
	}
	
	fGameTime = fTime;
}

/*
=================
Timer_Update

Called once every frame to check the status of things
=================
*/
void Timer_Update(void)
{
	static float fVoxTimer;
	
	if (cvar("sv_playerslots") == 1) {
		fGameTime = -1;
		return;
	}

	// This map has been played enough we think
	if (fGameState != GAME_OVER) {
		if (cvar("mp_timelimit") > 0) {
			if (autocvar_fcs_voxannounce == TRUE) {
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
			}
		
			if (time >= (cvar("mp_timelimit") * 60)) {
				Timer_Begin(5, GAME_OVER);
			}
		}
	}
	
	if ((fGameState == GAME_OVER) && (fGameTime < 0)) {
		for (int i = 0; i < iMapCycleCount; i++) {
			if (sMapCycle[i] == mapname) {
				if ((i + 1) < iMapCycleCount) {
					localcmd(sprintf("changelevel %s\n", sMapCycle[i + 1]));
					return;
				} else {
					localcmd(sprintf("changelevel %s\n", sMapCycle[0]));
				}
			}
		}
	}
	
	// Okay, this means that timelimit is not the only deciding factor
	if (autocvar_mp_winlimit > 0 && fGameState != GAME_OVER) {
		// It really doesn't matter who won. Do some logging perhaps?
		if (iWon_CT == autocvar_mp_winlimit) {
			Timer_Begin(5, GAME_OVER);
		} else if (iWon_T == autocvar_mp_winlimit) {
			Timer_Begin(5, GAME_OVER);
		}
	}
	
	if (fGameState == GAME_INACTIVE) {
		return;
	}
	
	if (fGameTime > 0) {
		fGameTime -= frametime;
	} else {
		fGameTime = 0;
	}

	if (fGameState == GAME_COMMENCING || fGameState == GAME_END) {
		if (fGameTime <= 0) {
			if (iWon_T == 0 && iWon_CT == 0) {
				Money_ResetTeamReward();
				Money_ResetRoundReward();
				Rules_Restart(TRUE);
			} else {
				if (autocvar_mp_halftime == TRUE && (autocvar_mp_winlimit / 2 == iRounds)) {
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
	
	if ((fGameState == GAME_ACTIVE) || (fGameState == GAME_FREEZE)) {
		if (fGameTime <= 0) {
			if (fGameState == GAME_ACTIVE) {
				/* 1.5 will make the T's lose if time runs out no matter what */
				if (autocvar_fcs_fix_bombtimer == TRUE) {
					if (iBombZones > 0 && iBombPlanted == TRUE) {
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
