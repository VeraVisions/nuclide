/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* Use first frame for drawing (needs precache) */
#define HUD_NUMS "sprites/640hud7.spr_0.tga"

#define NUMSIZE_X 24/256
#define NUMSIZE_Y 24/128
#define HUD_ALPHA 0.5

vector g_hud_color;

float spr_hudnum[10] = {
	0 / 256,
	24 / 256,
	(24*2) / 256,
	(24*3) / 256,
	(24*4) / 256,
	(24*5) / 256,
	(24*6) / 256,
	(24*7) / 256,
	(24*8) / 256,
	(24*9) / 256
};
float spr_health[4] = {
	80 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};
float spr_suit1[4] = {
	10 / 256, // pos x
	24 / 128, // pos u
	30 / 256, // size x
	40 / 128 // size y
};
float spr_suit2[4] = {
	50 / 256, // pos x
	24 / 128, // pos u
	30 / 256, // size x
	40 / 128 // size y
};


float spr_flash1[4] = {
	160 / 256, // pos x
	24 / 128, // pos u
	32 / 256, // size x
	32 / 128 // size y
};
float spr_flash2[4] = {
	112 / 256, // pos x
	24 / 128, // pos u
	48 / 256, // size x
	32 / 128 // size y
};

void HUD_Init(void)
{
	precache_model("sprites/640hud7.spr");
}

/*
=================
HUD_DrawNumber

Draws a normal number
=================
*/
void HUD_DrawNumber(int iNumber, vector vPos, float fAlpha, vector vColor) {
	drawsubpic(vPos, [24,24], HUD_NUMS, [spr_hudnum[iNumber], 0],
			   [NUMSIZE_X, NUMSIZE_Y], vColor, fAlpha, DRAWFLAG_ADDITIVE);
}

/*
=================
HUD_DrawNums

Draws numerals quickly for health, armor etc.
=================
*/
void HUD_DrawNums(float fNumber, vector vPos, float fAlpha, vector vColor) {
	int iNumber = fNumber;
	if (iNumber > 0) {
		while (iNumber > 0) {
			HUD_DrawNumber((float)iNumber % 10, vPos, fAlpha, vColor);
			iNumber = iNumber / 10;
			vPos[0] -= 20;
		} 
	} else {
		HUD_DrawNumber(0, vPos, fAlpha, vColor);
	}
}

/*
=================
HUD_DrawHealth

Draw the current amount of health
=================
*/
void HUD_DrawHealth(void) {
	player pl = (player)self;

	static float fOldHealth;
	static float fHealthAlpha;
	if (pl.health != fOldHealth) {
		fHealthAlpha = 1.0;
	}
	
	if (fHealthAlpha >= HUD_ALPHA) {
		fHealthAlpha -= frametime * 0.5;
	} else {
		fHealthAlpha = HUD_ALPHA;
	}
	
	vector pos = video_mins + [16, video_res[1] - 42];
	if (pl.health > 25) {
		drawsubpic(pos + [0,-4], [32,32], HUD_NUMS, [spr_health[0], spr_health[1]],
			   [spr_health[2], spr_health[3]], g_hud_color, HUD_ALPHA, DRAWFLAG_ADDITIVE);
		HUD_DrawNums(pl.health, pos + [72, 0], HUD_ALPHA, g_hud_color);
	} else {
		drawsubpic(pos + [0,-4], [32,32], HUD_NUMS, [spr_health[0], spr_health[1]],
			   [spr_health[2], spr_health[3]], [1,0,0], HUD_ALPHA, DRAWFLAG_ADDITIVE);
		HUD_DrawNums(pl.health, pos + [72, 0], HUD_ALPHA, [1,0,0]);
	}
	fOldHealth = pl.health;
}


/*
=================
HUD_DrawArmor

Draw the current amount of armor
=================
*/
void HUD_DrawArmor(void)
{
	vector pos;
	static float oldarmor;
	static float armoralpha;
	player pl = (player)self;

	pos = video_mins + [128, video_res[1] - 42];
	
	if (pl.armor != oldarmor) {
		armoralpha = 1.0;
	}

	if (armoralpha >= HUD_ALPHA) {
		armoralpha -= frametime * 0.5;
	} else {
		armoralpha = HUD_ALPHA;
	}

	drawsubpic(pos + [0,-9], [30,40], HUD_NUMS, [spr_suit2[0], spr_suit2[1]],
			  [spr_suit2[2], spr_suit2[3]], g_hud_color, armoralpha, DRAWFLAG_ADDITIVE);
	HUD_DrawNums(pl.armor, pos + [72, 0], armoralpha, g_hud_color);

	oldarmor = pl.armor;
}

void HUD_DrawFlashlight(void)
{
	vector pos;
	pos = video_mins + [video_res[0] - 48, 16];
	
	drawsubpic(pos, [32,32], HUD_NUMS, [spr_flash1[0], spr_flash1[1]],
			  [spr_flash1[2], spr_flash1[3]], g_hud_color, HUD_ALPHA, DRAWFLAG_ADDITIVE);
}

void HUD_Draw(void)
{
	g_hud_color = autocvar_con_color * (1 / 255);
	
	HUD_DrawHealth();
	HUD_DrawArmor();
	HUD_DrawFlashlight();
	Damage_Draw();
}
