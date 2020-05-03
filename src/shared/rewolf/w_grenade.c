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
	GREN_IDLE1, // 2.0f
	GREN_IDLE2, // 2.0f
	GREN_FIDGET, // 1.2f
	GREN_RELOAD, // 1.6f
	GREN_ARM, // 1.2f
	GREN_THROW, // 0.5f
	GREN_TRIPMINE, // 1.33333f
	GREN_DRAW // 0.588235f
};

void
w_grenade_draw(void)
{
	Weapons_SetModel("models/v_grenade.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(GREN_DRAW);
}

void
w_grenade_holster(void)
{
}

void
w_grenade_primary(void)
{
	vector src;
	player pl = (player)self;

	if (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags |= FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(GREN_FIDGET);
		pl.w_attack_next = 1.2f;
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
w_grenade_secondary(void)
{
	player pl = (player)self;

	if (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	pl.flags |= FL_SEMI_TOGGLED;

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
w_grenade_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(GREN_IDLE1);
	pl.w_idle_next = 1.777778f;
}

void
w_grenade_updateammo(player pl)
{
	
}

string
w_grenade_wmodel(void)
{
	return "models/w_grenade.mdl";
}

string
w_grenade_pmodel(void)
{
	return "models/p_grenade.mdl";
}

string
w_grenade_deathmsg(void)
{
	return "";
}

float
w_grenade_aimanim(void)
{
	return 0;
}

void
w_grenade_hud(void)
{
#ifdef CLIENT
	vector pos;
	player pl = (player)self;
	
	static string dmodes[] = {
		"WHEN TRIPPED",
		"TIMED",
		"ON IMPACT"
	};
	static string pmodes[] = {
		"CLUSTER",
		"EXPLOSIVE"
	};

	HUD_DrawAmmo2();

	/* menu */
	if (pl.a_ammo1 > 0) {
		vector col1, col2;
		string txt1, txt2;
		
		col1 = col2 = [1,1,1];
		switch (pl.a_ammo1) {
		case 1:
			col1 = [0,1,0];
			break;
		case 2:
			col2 = [0,1,0];
			break;
		}
		
		txt1 = sprintf("DETONATE: %s", dmodes[getstati(49)]);
		txt2 = sprintf("PAYLOAD: %s", pmodes[getstati(50)]);
		pos = g_hudmins + (g_hudres / 2) + [-48,-16];

		drawfont = FONT_20;
		drawstring(pos, txt1, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		drawstring(pos + [0,24], txt2, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		return;
	}
#endif
}

void
w_grenade_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_dmlGrenade0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_grenade_precache(void)
{
	precache_model("models/v_grenade.mdl");

#ifdef SERVER
	clientstat(49, EV_INTEGER, player::gren_detonate);
	clientstat(50, EV_INTEGER, player::gren_payload);
#endif
}

weapon_t w_grenade =
{
	.name		= "grenade",
	.id			= ITEM_GRENADE,
	.slot		= 4,
	.slot_pos	= 0,
	.draw		= w_grenade_draw,
	.holster	= w_grenade_holster,
	.primary	= w_grenade_primary,
	.secondary	= w_grenade_secondary,
	.reload		= __NULL__,
	.release	= w_grenade_release,
	.crosshair	= w_grenade_hud,
	.precache	= w_grenade_precache,
	.pickup		= __NULL__,
	.updateammo	= w_grenade_updateammo,
	.wmodel		= w_grenade_wmodel,
	.pmodel		= w_grenade_pmodel,
	.deathmsg	= w_grenade_deathmsg,
	.aimanim	= w_grenade_aimanim,
	.hudpic		= w_grenade_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_grenade(void)
{
	Weapons_InitItem(WEAPON_GRENADE);
}
#endif

#ifdef CLIENT
int
w_grenade_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_gren_det", "i", 1i);
		break;
	case 2:
		sendevent("w_gren_pay", "i", 1i);
		break;
	}
	return FALSE;
}

int
w_grenade_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case 1:
		sendevent("w_gren_det", "i", -1i);
		break;
	case 2:
		sendevent("w_gren_pay", "i", -1i);
		break;
	}
	return FALSE;
}
#else
void
CSEv_w_gren_det_i(int f)
{
	player pl = (player)self;
	pl.gren_detonate = bound(0, pl.gren_detonate + f, 2);
}

void
CSEv_w_gren_pay_i(int f)
{
	player pl = (player)self;
	pl.gren_payload = bound(0, pl.gren_payload + f, 1);
}
#endif
