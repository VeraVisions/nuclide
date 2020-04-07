/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

var int autocvar_cl_autoweaponswitch = TRUE;

vector g_hud_color;
vector g_hudmins;
vector g_hudres;

struct
{
	/* viewmodel stuff */
	entity eViewModel;
	entity eMuzzleflash;
	float fNumBones;
	float fEjectBone;
	float fLastWeapon;
	float fBobTime;
	float fBob;
	float damage_alpha;
	vector damage_pos;

	int iZoomed;
	float flZoomTime;

	/* player fields */
	entity ePlayer;
	vector vPlayerOrigin;
	vector vPlayerOriginOld;
	vector vPlayerVelocity;
	float fPlayerFlags;
	
	/* camera fields */
	vector vCameraPos;
	vector vCameraAngle;
	float fCameraTime;
	
	/* punchangle */
	vector punchangle;
	vector net_punchangle;

	/* hud.c */
	float health_old;
	float health_alpha;
	float armor_old;
	float armor_alpha;
	float ammo1_old;
	float ammo1_alpha;
	float ammo2_old;
	float ammo2_alpha;
	float ammo3_old;
	float ammo3_alpha;
	int pickup_weapon;
	float pickup_alpha;

	/* This is seperated from the other VGUI stuff so we can check scores
	 * while buying and whatnot */
	int iShowScores;
	float fHUDWeaponSelected;
	float fHUDWeaponSelectTime;

	int iInputAttack2;
	int iInputReload;
	int iInputUse;
	int iInputDuck;

	float fInputSendNext;
	entity pWeaponFX;
} seats[4], *pSeat;

void HUD_DrawAmmo1(void);
void HUD_DrawAmmo2(void);
void HUD_DrawAmmo3(void);
void HUD_WeaponPickupNotify(int);
