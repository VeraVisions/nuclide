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

/* Use first frame for drawing (needs precache) */
#define HUD_NUMS "sprites/640hud7.spr_0.tga"
#define GM_NUMS "sprites/numbers.spr_0.tga"

#define HUD_ALPHA 0.5

/* New Gunman digits */
#define NUMSIZE_X 18/256
#define NUMSIZE_Y 32/32

float spr_hudnum[10] = {
	0 / 256,
	18 / 256,
	(18*2) / 256,
	(18*3) / 256,
	(18*4) / 256,
	(18*5) / 256,
	(18*6) / 256,
	(18*7) / 256,
	(18*8) / 256,
	(18*9) / 256
};

void HUD_DrawWeaponSelect(void);

void HUD_Init(void)
{
	precache_model("sprites/640hud7.spr");
	precache_model("sprites/numbers.spr");
	precache_model("sprites/armor.spr");
	precache_model("sprites/hudpulse.spr");
	precache_pic("gfx/vgui/640_metalhud_small.tga");
	precache_pic("gfx/vgui/640_metalhud.tga");
}

/*
=================
HUD_DrawNumber

Draws a normal number
=================
*/
void HUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	drawsubpic(vecPos, [18,32], GM_NUMS, [spr_hudnum[iNumber], 0],
			   [NUMSIZE_X, NUMSIZE_Y], vColor, fAlpha, DRAWFLAG_ADDITIVE);
}

void HUD_DrawSeperator(vector pos)
{
	drawsubpic(pos, [2,24], HUD_NUMS, [240/256, 0],
			   [2/256, 24/128], g_hud_color, HUD_ALPHA, DRAWFLAG_ADDITIVE);
}

/*
=================
HUD_DrawNums

Draws numerals quickly for health, armor etc.
=================
*/
void HUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int iNumber = fNumber;
	if (iNumber > 0) {
		while (iNumber > 0) {
			HUD_DrawNumber((float)iNumber % 10, vecPos, fAlpha, vColor);
			iNumber = iNumber / 10;
			vecPos[0] -= 20;
		} 
	} else {
		HUD_DrawNumber(0, vecPos, fAlpha, vColor);
	}
}

/*
=================
HUD_DrawHealth

Draw the current amount of health
=================
*/
void HUD_DrawHealth(void)
{
	vector pos;
	vector hcol;
	player pl;

	pl = (player)pSeat->m_ePlayer;

	/* Shift digits by 128 units for the larger HUD */
	if (g_hudres[0] <= 640) {
		pos = g_hudmins + [0, g_hudres[1] - 128];
	} else {
		pos = g_hudmins + [128, g_hudres[1] - 128];
	}

	/* Obligatory low-health color tint */
	if (pl.health <= 25) {
		hcol = [1,0,0];
	} else {
		hcol = [0,1,1];
	}

	/* Because we've got little space, the number 100 is its own graphic */
	if (pl.health >= 100) {
		drawsubpic(pos+[34,30], [42,32], GM_NUMS, [192/256, 0],
			   [42/256, 32/32], hcol, 1.0f, DRAWFLAG_ADDITIVE);
	} else {
		HUD_DrawNums(pl.health, pos + [56,30], 1.0f, hcol);
	}

	if (pl.armor >= 100) {
		drawsubpic(pos+[34,64], [42,32], GM_NUMS, [192/256, 0],
			   [42/256, 32/32], [0,1,0], 1.0f, DRAWFLAG_ADDITIVE);
	} else {
		HUD_DrawNums(pl.armor, pos + [56,64], 1.0f, [0,1,0]);
	}

	/* Minimal VS Larger HUD */
	if (g_hudres[0] <= 640) {
		drawpic(pos, "gfx/vgui/640_metalhud_small.tga", [128,128], 
			[1,1,1], 1.0f);
	} else {
		pos[0] -= 128;

		/* Armor bar */
		float ap = pl.armor / 100;
		if (ap) {
			drawsubpic(pos+[28,18], [95*ap,32], "sprites/armor.spr_0.tga",
				[0, 0], [0.7421875*ap, 1], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
		}

		/* Health, TODO: make it scroll */
		if (pl.health <= 20) {
			drawpic(pos + [35,53], "sprites/hudpulse.spr_4.tga", [128,32], 
				[1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		} else if (pl.health <= 40) {
			drawpic(pos + [35,53], "sprites/hudpulse.spr_3.tga", [128,32], 
				[1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		} else if (pl.health <= 60) {
			drawpic(pos + [35,53], "sprites/hudpulse.spr_2.tga", [128,32], 
				[1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		} else if (pl.health <= 80) {
			drawpic(pos + [35,53], "sprites/hudpulse.spr_1.tga", [128,32], 
				[1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		} else {
			drawpic(pos + [35,53], "sprites/hudpulse.spr_0.tga", [128,32], 
				[1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		}

		drawpic(pos, "gfx/vgui/640_metalhud.tga", [256,128], [1,1,1], 1.0f);
	}
}

void HUD_DrawAmmo1(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;
	static int old_ammo1;
	static float m_flAmmo1Alpha;

	if (pl.a_ammo1 != old_ammo1) {
		m_flAmmo1Alpha = 1.0;
		old_ammo1 = pl.a_ammo1;
	}

	if (m_flAmmo1Alpha >= HUD_ALPHA) {
		m_flAmmo1Alpha -= clframetime * 0.5;
	} else {
		m_flAmmo1Alpha = HUD_ALPHA;
	}
	
	pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	/* Magazine/Clip */
	if (pl.a_ammo1 != -1) {
		HUD_DrawNums(pl.a_ammo1, pos + [-80,0], m_flAmmo1Alpha, g_hud_color);
	}

	HUD_DrawSeperator(pos + [-50,0]);
}

void HUD_DrawAmmo2(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	static int old_ammo2;
	static float m_flAmmo2Alpha;

	if (pl.a_ammo2 != old_ammo2) {
		m_flAmmo2Alpha = 1.0;
		old_ammo2 = pl.a_ammo2;
	}

	if (m_flAmmo2Alpha >= HUD_ALPHA) {
		m_flAmmo2Alpha -= clframetime * 0.5;
	} else {
		m_flAmmo2Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	/* Leftover Ammo */
	HUD_DrawNums(pl.a_ammo2, pos, m_flAmmo2Alpha, g_hud_color);
}

void HUD_DrawAmmo3(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	static int old_ammo3;
	static float m_flAmmo3Alpha;

	if (pl.a_ammo3 != old_ammo3) {
		m_flAmmo3Alpha = 1.0;
		old_ammo3 = pl.a_ammo3;
	}

	if (m_flAmmo3Alpha >= HUD_ALPHA) {
		m_flAmmo3Alpha -= clframetime * 0.5;
	} else {
		m_flAmmo3Alpha = HUD_ALPHA;
	}
	
	pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	/* Special */
	if (pl.a_ammo3) {
		HUD_DrawNums(pl.a_ammo3, pos + [0, -32], m_flAmmo3Alpha, g_hud_color);
	}
}

void
HUD_WeaponPickupNotify(int w)
{
	
}

void HUD_Draw(void)
{
	g_hud_color = autocvar_con_color * (1 / 255);
	
	Damage_Draw();
	HUD_DrawHealth();
	Weapons_DrawCrosshair();
	HUD_DrawWeaponSelect();
}

void HUD_DrawSpectator(void)
{
	// FIXME
}
