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
	CHEMGUN_DRAW, // 1.2f
	CHEMGUN_HOLSTER, // 1.2f
	CHEMGUN_IDLE, // 2.08f
	CHEMGUN_FIDGET, // 2.08f
	CHEMGUN_CONFIG, // 2.08f
	CHEMGUN_SHOOT // 0.535714
};

void
w_chemicalgun_draw(void)
{
	Weapons_SetModel("models/v_chemgun.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(CHEMGUN_DRAW);
}

void
w_chemicalgun_holster(void)
{
}

void
w_chemicalgun_primary(void)
{
	vector src;
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags &= ~FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(CHEMGUN_CONFIG);
		pl.w_attack_next = 2.08f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	if (pl.w_attack_next) {
		return;
	}

	src = Weapons_GetCameraPos();

#ifdef CLIENT
	//Weapons_ViewAnimation(GP_FIRESINGLE);
#endif

	pl.w_attack_next = 0.15f;
	pl.w_idle_next = 2.5f;
}

void
w_chemicalgun_secondary(void)
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
	if (pl.a_ammo1 <= 0 || pl.a_ammo1 == 4) {
		pl.a_ammo1 = 1;
	} else {
		pl.a_ammo1 = bound(1, pl.a_ammo1 + 1, 4);
	}
}

void
w_chemicalgun_release(void)
{
	player pl = (player)self;

	pl.flags |= FL_SEMI_TOGGLED;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(CHEMGUN_IDLE);
	pl.w_idle_next = 2.08f;
}

void
w_chemicalgun_updateammo(player pl)
{
	
}

string
w_chemicalgun_wmodel(void)
{
	return "models/w_chemgun.mdl";
}

string
w_chemicalgun_pmodel(void)
{
	return "models/p_hgun.mdl";
}

string
w_chemicalgun_deathmsg(void)
{
	return "";
}

float
w_chemicalgun_aimanim(void)
{
	return 0;
}

int
w_chemicalgun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.chem_acid = 5;
		pl.chem_neutral = 2;
		pl.chem_base = 4;
		pl.chem_pressure = 3;
	}

	if (pl.ammo_chem < 50) {
		pl.ammo_chem = bound(0, pl.ammo_chem + 10, 50);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

#ifdef CLIENT
void
w_chemgun_drawvial(vector pos, int length, vector col)
{
	int i;
	vector npos;
	const string parts[] = {
		"sprites/vial_el.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_er.spr_0.tga"
	};

	pos[0] += 96;
	npos = pos;

	/* empty */
	for (i = 0; i < 5; i++) {
		if (i >= length) {
			drawpic(
				pos,
				parts[i],
				[32,32],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		pos[0] += 32;
	}

	/* full */
	for (i = 0; i < length; i++) {
		drawpic(
			npos,
			parts[i],
			[32,32],
			col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		npos[0] += 32;
	}
}
void
w_chemgun_drawpressure(vector pos, int length, vector col)
{
	int i;
	const string parts[] = {
		"sprites/hud_pntr.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_ec.spr_0.tga",
		"sprites/vial_er.spr_0.tga"
	};

	pos[0] += 96;

	/* full */
	for (i = 0; i < 5; i++) {
		if (i == length) {
			drawpic(
				pos,
				"sprites/hud_pntr.spr_0.tga",
				[32,32],
				col,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawpic(
				pos,
				"sprites/hud_rule.spr_0.tga",
				[32,32],
				col,
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		pos[0] += 32;
	}
}
#endif

void
w_chemicalgun_hud(void)
{
#ifdef CLIENT
	vector pos;
	player pl = (player)self;

	pos = g_hudmins + [g_hudres[0] - 125, g_hudres[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_chem.tga",
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
		vector col1, col2, col3, col4;
		string txt1, txt2, txt3, txt4;
		
		col1 = col2 = col3 = col4 = [1,1,1];
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
		case 4:
			col4 = [0,1,0];
			break;
		}
		
		txt1 = "ACID:";
		txt2 = "NEUTRAL:";
		txt3 = "BASE:";
		txt4 = "PRESSURE:";
		pos = g_hudmins + (g_hudres / 2) + [-128,-96];

		drawfont = FONT_20;
		drawstring(pos + [0,8], txt1, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		w_chemgun_drawvial(pos, getstati(51), [0,1,0]);
		pos[1] += 48;
		drawstring(pos + [0,8], txt2, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		w_chemgun_drawvial(pos, getstati(52), [0.25,0.25,1]);
		pos[1] += 48;
		drawstring(pos + [0,8], txt3, [20,20], col3, 1.0f,
			DRAWFLAG_ADDITIVE);
		w_chemgun_drawvial(pos, getstati(53), [1,0,0]);
		pos[1] += 48;
		drawstring(pos + [0,8], txt4, [20,20], col4, 1.0f,
			DRAWFLAG_ADDITIVE);
		w_chemgun_drawpressure(pos, getstati(54), [1,0.5,0.25]);
		return;
	}
#endif
}

void
w_chemicalgun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_SPchemicalgun0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_chemicalgun_precache(void)
{
	precache_model("models/v_chemgun.mdl");

	/* empty */
	precache_model("sprites/vial_el.spr"); /* 32x32 */
	precache_model("sprites/vial_ec.spr");
	precache_model("sprites/vial_er.spr");

	/* full */
	precache_model("sprites/vial_fl.spr");
	precache_model("sprites/vial_fc.spr");
	precache_model("sprites/vial_fr.spr");

	precache_model("sprites/hud_pntr.spr");
	precache_model("sprites/hud_rule.spr");

#ifdef SERVER
	clientstat(51, EV_INTEGER, player::chem_acid);
	clientstat(52, EV_INTEGER, player::chem_neutral);
	clientstat(53, EV_INTEGER, player::chem_base);
	clientstat(54, EV_INTEGER, player::chem_pressure);
#endif
}

weapon_t w_chemicalgun =
{
	.name		= "chemicalgun",
	.id			= ITEM_CHEMICALGUN,
	.slot		= 4,
	.slot_pos	= 1,
	.draw		= w_chemicalgun_draw,
	.holster	= w_chemicalgun_holster,
	.primary	= w_chemicalgun_primary,
	.secondary	= w_chemicalgun_secondary,
	.reload		= __NULL__,
	.release	= w_chemicalgun_release,
	.crosshair	= w_chemicalgun_hud,
	.precache	= w_chemicalgun_precache,
	.pickup		= w_chemicalgun_pickup,
	.updateammo	= w_chemicalgun_updateammo,
	.wmodel		= w_chemicalgun_wmodel,
	.pmodel		= w_chemicalgun_pmodel,
	.deathmsg	= w_chemicalgun_deathmsg,
	.aimanim	= w_chemicalgun_aimanim,
	.hudpic		= w_chemicalgun_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_SPchemicalgun(void)
{
	Weapons_InitItem(WEAPON_CHEMICALGUN);
}
#endif

#ifdef CLIENT
int
w_chemgun_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_chem_a", "i", 1i);
		break;
	case 2:
		sendevent("w_chem_n", "i", 1i);
		break;
	case 3:
		sendevent("w_chem_b", "i", 1i);
		break;
	case 4:
		sendevent("w_chem_p", "i", 1i);
		break;
	}
	return FALSE;
}

int
w_chemgun_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_chem_a", "i", -1i);
		break;
	case 2:
		sendevent("w_chem_n", "i", -1i);
		break;
	case 3:
		sendevent("w_chem_b", "i", -1i);
		break;
	case 4:
		sendevent("w_chem_p", "i", -1i);
		break;
	}
	return FALSE;
}
#else
void
CSEv_w_chem_a_i(int f)
{
	player pl = (player)self;
	pl.chem_acid = bound(0, pl.chem_acid + f, 5);
}

void
CSEv_w_chem_n_i(int f)
{
	player pl = (player)self;
	pl.chem_neutral = bound(0, pl.chem_neutral + f, 5);
}

void
CSEv_w_chem_b_i(int f)
{
	player pl = (player)self;
	pl.chem_base = bound(0, pl.chem_base + f, 5);
}

void
CSEv_w_chem_p_i(int f)
{
	player pl = (player)self;
	pl.chem_pressure = bound(0, pl.chem_pressure + f, 4);
}
#endif
