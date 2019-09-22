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

enum {
	BEAMGUN_DRAW,
	BEAMGUN_IDLE, // 2.6f
	BEAMGUN_FIDGET1, // 2.4f
	BEAMGUN_FIDGET2, // 2.08f
	BEAMGUN_FIRE, // 0.333333f
	BEAMGUN_FIRESINGLE, // 0.333333f
	BEAMGUN_CONFIG, // 2.26087f
	BEAMGUN_CHARGE // 1.3f
};

void
w_beamgun_draw(void)
{
	Weapons_SetModel("models/v_beam.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(BEAMGUN_DRAW);
}

void
w_beamgun_holster(void)
{
}

void
w_beamgun_release(void)
{
	player pl = (player)self;

	pl.flags |= FL_SEMI_TOGGLED;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(BEAMGUN_IDLE);
	pl.w_idle_next = 2.6f;
}

void
w_beamgun_primary(void)
{
	vector src;
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags &= ~FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(BEAMGUN_CONFIG);
		pl.w_attack_next = 2.26087f;
		pl.w_idle_next = 2.26087f;
		return;
	}

	if (pl.w_attack_next) {
		return;
	}

	src = Weapons_GetCameraPos();

#ifdef CSQC
	//Weapons_ViewAnimation(GP_FIRESINGLE);
#endif

	pl.w_attack_next = 0.15f;
	pl.w_idle_next = 2.5f;
}

void
w_beamgun_secondary(void)
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
	if (pl.a_ammo1 <= 0 || pl.a_ammo1 == 3) {
		pl.a_ammo1 = 1;
	} else {
		pl.a_ammo1 = bound(1, pl.a_ammo1 + 1, 3);
	}
}

void
w_beamgun_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, pl.ammo_battery, -1);
#endif
}

string
w_beamgun_wmodel(void)
{
	return "";
}

string
w_beamgun_pmodel(void)
{
	return "";
}

string
w_beamgun_deathmsg(void)
{
	return "";
}

float
w_beamgun_aimanim(void)
{
	return 0;
}

void
w_beamgun_hud(void)
{
#ifdef CSQC
	static string rmodes[] = {
		"TOUCH TAZER",
		"SHORT TAZER",
		"MEDIUM BEAM",
		"LONG BEAM"
	};
	static string pmodes[] = {
		"LOW",
		"MEDIUM",
		"HIGH",
		"HIGHEST"
	};
	static string amodes[] = {
		"HIGHEST",
		"HIGH",
		"MEDIUM",
		"LOW"
	};
	static string lmodes[] = {
		"BEAM",
		"CHAIN",
		"BALL"
	};
	vector pos;
	player pl = (player)self;

	/* menu */
	if (pl.a_ammo1 > 0) {
		vector col1, col2, col3;
		string txt1, txt2, txt3, txt4;

		col1 = col2 = col3 = [1,1,1];
		switch (pl.a_ammo1) {
		case 1:
			col1 = [0,1,0];
			break;
		case 2:
			col2 = [0,1,0];
			break;
		case 3:
			col3 = [0,1,0];
			break;
		}

		txt1 = sprintf("RANGE: %s", rmodes[getstati(46)]);
		txt2 = sprintf("POWER: %s", pmodes[getstati(47)]);
		txt3 = sprintf("ACCURACY: %s", amodes[getstati(47)]);
		txt4 = sprintf("LIGHTNING: %s", lmodes[getstati(48)]);
		pos = video_mins + (video_res / 2) + [-80,-48];

		drawfont = FONT_20;
		drawstring(pos, txt1, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt2, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt3, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt4, [20,20], col3, 1.0f,
			DRAWFLAG_ADDITIVE);
		return;
	}

	pos = video_mins + (video_res / 2) + [-15,-15];
	drawsubpic(
		pos,
		[31,31],
		"sprites/crosshairs.spr_0.tga",
		[116/256,1/128],
		[31/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo2();
#endif
}

void
w_beamgun_hudpic(int selected, vector pos)
{
#ifdef CSQC
	drawpic(
		pos,
		"gfx/vgui/640_weapon_beamgun0.tga",
		[170,43],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_beamgun_precache(void)
{
	precache_model("models/v_beam.mdl");

#ifdef SSQC
	clientstat(46, EV_INTEGER, player::beam_range);
	clientstat(47, EV_INTEGER, player::beam_poweracc);
	clientstat(48, EV_INTEGER, player::beam_lightning);
#endif
}

weapon_t w_beamgun =
{
	.id		= ITEM_BEAMGUN,
	.slot		= 3,
	.slot_pos	= 0,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_beamgun_draw,
	.holster	= w_beamgun_holster,
	.primary	= w_beamgun_primary,
	.secondary	= w_beamgun_secondary,
	.reload		= __NULL__,
	.release	= w_beamgun_release,
	.crosshair	= w_beamgun_hud,
	.precache	= w_beamgun_precache,
	.pickup		= __NULL__,
	.updateammo	= w_beamgun_updateammo,
	.wmodel		= w_beamgun_wmodel,
	.pmodel		= w_beamgun_pmodel,
	.deathmsg	= w_beamgun_deathmsg,
	.aimanim	= w_beamgun_aimanim,
	.hudpic		= w_beamgun_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_beamgun(void)
{
	Weapons_InitItem(WEAPON_BEAMGUN);
}
#endif

#ifdef CSQC
int
w_beamgun_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_beamgun_range", "i", 1i);
		break;
	case 2:
		sendevent("w_beamgun_power", "i", 1i);
		break;
	case 3:
		sendevent("w_beamgun_light", "i", 1i);
		break;
	}
	return FALSE;
}

int
w_beamgun_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}
	
	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_beamgun_range", "i", -1i);
		break;
	case 2:
		sendevent("w_beamgun_power", "i", -1i);
		break;
	case 3:
		sendevent("w_beamgun_light", "i", -1i);
		break;
	}
	return FALSE;
}
#else
void
CSEv_w_beamgun_range_i(int f)
{
	player pl = (player)self;
	pl.beam_range = bound(0, pl.beam_range + f, 3);
}

void
CSEv_w_beamgun_power_i(int f)
{
	player pl = (player)self;
	pl.beam_poweracc = bound(0, pl.beam_poweracc + f, 3);
}

void
CSEv_w_beamgun_light_i(int f)
{
	player pl = (player)self;
	pl.beam_lightning = bound(0, pl.beam_lightning + f, 2);
}
#endif
