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

vector g_hud_color;

struct
{
//Viewmodel stuff
	entity eViewModel;
	entity eMuzzleflash;
	float fNumBones;
	float fEjectBone;
	vector vPunchAngle;
	float fLastWeapon;
	float fBobTime;
	float fBob;
	float damage_alpha;
	vector damage_pos;
	
	/* Camera Bob */
	float flCamMove;
	float flCamTime;
	int iCamCycle;
	float flCamFracSin;
	float flCamDelta;

	int iZoomed;
	float flZoomTime;

//Player fields
	entity ePlayer;
	vector vPlayerOrigin;
	vector vPlayerOriginOld;
	vector vPlayerVelocity;
	float fPlayerFlags;
	
// Camera Fields
	//entity ePlayerEnt;
	vector vCameraPos;
	vector vCameraAngle;
	float fCameraTime;
	
//UI fields
	float fVGUI_Display;	// The VGUI menu currently being drawn
	int iShowScores;	// This is seperated from the other VGUI stuff so we can check scores while buying and whatnot
	
//buy menu
	// We can only carry one item per slot, so this is hacking around the last one
	float fHUDWeaponSelected;
	float fHUDWeaponSelectTime;

	int iInputAttack2;
	int iInputReload;
	int iInputUse;
	int iInputDuck;

	float fInputSendNext;
} seats[4], *pSeat;

void HUD_DrawAmmo1(void);
void HUD_DrawAmmo2(void);
void HUD_DrawAmmo3(void);
