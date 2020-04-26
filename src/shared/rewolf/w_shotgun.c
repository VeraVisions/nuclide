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

enum
{
	SHOTGUN_DRAW, // 0.909091f
	SHOTGUN_IDLE, // 2.0f
	SHOTGUN_FIDGET, // 2.0f
	SHOTGUN_SHOOT1, // 0.846154f
	SHOTGUN_SHOOT2, // 0.846154f
	SHOTGUN_SHOOT3, // 0.846154f
	SHOTGUN_SHOOT4, // 0.846154f
	SHOTGUN_CUSTOMIZE // 2.25f
};

enum
{
	SMENU_NONE,
	SMENU_SHELLS,
	SMENU_SPREAD
};

enum
{
	SPREAD_RIOT,
	SPREAD_SHOT,
	SPREAD_RIFLE
};

#ifdef CLIENT
string gsmodes[] = {
	"RIOTGUN",
	"SHOTGUN",
	"RIFLE"
};
#endif

void
w_shotgun_draw(void)
{
	Weapons_SetModel("models/v_shotgun.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(SHOTGUN_DRAW);
}

void
w_shotgun_holster(void)
{
	Weapons_ViewAnimation(SHOTGUN_DRAW);
}

void
w_shotgun_primary(void)
{
	vector src;
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags &= ~FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(SHOTGUN_CUSTOMIZE);
		pl.w_attack_next = 2.25f;
		pl.w_idle_next = 2.25f;
		return;
	}

	if (pl.w_attack_next) {
		return;
	}

	src = Weapons_GetCameraPos();

	pl.velocity += v_forward * -128;

#ifdef SERVER
	vector spread = [0.1,0.05];
	int pellets;

	switch (pl.shotgun_spread) {
	case SPREAD_RIOT:
		spread = [0.1,0.1];
		break;
	case SPREAD_RIFLE:
		spread = [0.05,0.05];
		break;
	default:
		spread = [0.1,0.05];
	}

	pellets = pl.shotgun_shells * 4;

	TraceAttack_FireBullets(pellets, src, 5, spread, WEAPON_SHOTGUN);
	Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.fire");
#else
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-5,0,0]);

	int r  = (float)input_sequence % 4;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SHOTGUN_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(SHOTGUN_SHOOT2);
		break;
	case 2:
		Weapons_ViewAnimation(SHOTGUN_SHOOT3);
		break;
	default:
		Weapons_ViewAnimation(SHOTGUN_SHOOT4);
	}
#endif

	pl.w_attack_next = 0.846154f;
	pl.w_idle_next = 2.5f;
}

void
w_shotgun_secondary(void)
{
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	pl.flags &= ~FL_SEMI_TOGGLED;

	if (pl.w_attack_next) {
		return;
	}

	/* activate menu */
	if (pl.a_ammo1 <= 0) {
		pl.a_ammo1 = 1;
	} else {
		if (pl.a_ammo1 == 1) {
			pl.a_ammo1 = 2;
		} else {
			pl.a_ammo1 = 1;
		}
	}
}

void
w_shotgun_release(void)
{
	player pl = (player)self;
	pl.flags |= FL_SEMI_TOGGLED;

	if (pl.w_idle_next) {
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(SHOTGUN_IDLE);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(SHOTGUN_FIDGET);
		pl.w_idle_next = 2.0f;
	}
}

void
w_shotgun_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, pl.ammo_buckshot, -1);
#endif
}

string
w_shotgun_wmodel(void)
{
	return "models/w_shotgun.mdl";
}

string
w_shotgun_pmodel(void)
{
	return "models/p_shotgun.mdl";
}

string
w_shotgun_deathmsg(void)
{
	return "";
}

float
w_shotgun_aimanim(void)
{
	return 0;
}

int
w_shotgun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.shotgun_shells = 2;
		pl.shotgun_spread = SPREAD_SHOT;
	}

	if (pl.ammo_buckshot < 90) {
		pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 16, 90);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_shotgun_hud(void)
{
#ifdef CLIENT
	vector pos;
	player pl = (player)self;

	pos = g_hudmins + [g_hudres[0] - 125, g_hudres[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_buckshot.tga",
			[32,16],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
		pos[1] += 8;
	}

	HUD_DrawAmmo2();

	/* menu */
	if (pl.a_ammo1 > 0) {
		vector col1, col2;
		string shellstr, spreadstr;
		
		col1 = col2 = [1,1,1];
		switch (pl.a_ammo1) {
		case SMENU_SHELLS:
			col1 = [0,1,0];
			break;
		case SMENU_SPREAD:
			col2 = [0,1,0];
			break;
		}
		
		shellstr = sprintf("SHELLS: %i", getstati(40));
		spreadstr = sprintf("SPREAD: %s", gsmodes[getstati(41)]);
		pos = g_hudmins + (g_hudres / 2) + [-48,-16];

		drawfont = FONT_20;
		drawstring(pos, shellstr, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		drawstring(pos + [0,24], spreadstr, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		return;
	}

	/* crosshair */
	pos = g_hudmins + (g_hudres / 2) + [-15,-15];
	drawsubpic(
		pos,
		[31,31],
		"sprites/crosshairs.spr_0.tga",
		[34/256,1/128],
		[31/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_shotgun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_shotgun0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_shotgun_precache(void)
{
	precache_model("models/v_shotgun.mdl");
	precache_model("models/w_shotgun.mdl");
	precache_model("models/p_shotgun.mdl");

#ifdef SERVER
	Sound_Precache("weapon_shotgun.fire");
	clientstat(40, EV_INTEGER, player::shotgun_shells);
	clientstat(41, EV_INTEGER, player::shotgun_spread);
#endif
}

weapon_t w_shotgun =
{
	.name		= "shotgun",
	.id			= ITEM_SHOTGUN,
	.slot		= 2,
	.slot_pos	= 0,
	.draw		= w_shotgun_draw,
	.holster	= w_shotgun_holster,
	.primary	= w_shotgun_primary,
	.secondary	= w_shotgun_secondary,
	.reload		= __NULL__,
	.release	= w_shotgun_release,
	.crosshair	= w_shotgun_hud,
	.precache	= w_shotgun_precache,
	.pickup		= w_shotgun_pickup,
	.updateammo	= w_shotgun_updateammo,
	.wmodel		= w_shotgun_wmodel,
	.pmodel		= w_shotgun_pmodel,
	.deathmsg	= w_shotgun_deathmsg,
	.aimanim	= w_shotgun_aimanim,
	.hudpic		= w_shotgun_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_shotgun(void)
{
	Weapons_InitItem(WEAPON_SHOTGUN);
}
#endif

#ifdef CLIENT
int
w_shotgun_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case SMENU_SHELLS:
		sendevent("w_shot_shell", "i", 1i);
		break;
	case SMENU_SPREAD:
		sendevent("w_shot_spread", "i", 1i);
		break;
	}
	return FALSE;
}

int
w_shotgun_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}
	
	switch (pl.a_ammo1) {
	case SMENU_SHELLS:
		sendevent("w_shot_shell", "i", -1i);
		break;
	case SMENU_SPREAD:
		sendevent("w_shot_spread", "i", -1i);
		break;
	}
	return FALSE;
}
#else
void
CSEv_w_shot_shell_i(int f)
{
	player pl = (player)self;
	pl.shotgun_shells = bound(1, pl.shotgun_shells + f, 4);
}

void
CSEv_w_shot_spread_i(int f)
{
	player pl = (player)self;
	pl.shotgun_spread = bound(SPREAD_RIOT, pl.shotgun_spread + f, SPREAD_RIFLE);
}
#endif
