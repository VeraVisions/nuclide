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
	FISTS_IDLE, // 2.0f
	FISTS_FIDGET1, // 3.0f
	FISTS_FIDGET2, // 2.333333f
	FISTS_RIGHT, // 0.419355f
	FISTS_LEFT, // 0.419355f
	FISTS_DOUBLE, // 0.739130f
	FISTS_DRAW, // 1.4f
	FISTS_HOLSTER, // 0.7f
	KNIFE_DRAW, // 0.75f
	KNIFE_HOLSTER, // 0.75f
	KNIFE_IDLE, // 2.0f
	KNIFE_FIDGET, // 2.0f
	KNIFE_ATTACK1, // 0.789474f
	KNIFE_ATTACK2, // 0.421053f
	HANDS_PUSHBUTTON, // 8.0f
};

enum
{
	HS_KNIFE,
	HS_KNIFE_TO_FISTS,
	HS_FISTS,
	HS_FISTS_TO_KNIFE
};

void
w_fists_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, -1, pl.fist_mode);
#endif
}

void
w_fists_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_hands.mdl");
	Weapons_SetGeomset("geomset 1 2\n");
	Weapons_ViewAnimation(KNIFE_DRAW);
#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_fists.knifedraw");
#endif
}

void
w_fists_holster(void)
{
	Weapons_ViewAnimation(KNIFE_HOLSTER);
}

void
w_fists_release(void)
{
	int r;
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	if (pl.a_ammo3 == HS_FISTS_TO_KNIFE) {
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_fists.knifedraw");
#endif
		Weapons_ViewAnimation(KNIFE_DRAW);
		Weapons_SetGeomset("geomset 1 2\n");
		pl.a_ammo3 = HS_KNIFE;
		pl.w_attack_next = 0.75f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	} else if (pl.a_ammo3 == HS_KNIFE_TO_FISTS) {
		Weapons_ViewAnimation(FISTS_DRAW);
		Weapons_SetGeomset("geomset 1 1\n");
		pl.a_ammo3 = HS_FISTS;
		pl.w_attack_next = 1.4f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	if (pl.a_ammo3 == HS_KNIFE) {
		r  = (float)input_sequence % 5;
		switch (r) {
		case 0:
		case 1:
		case 2:
		case 3:
			Weapons_ViewAnimation(KNIFE_IDLE);
			pl.w_idle_next = 10.0f;
			break;
		default:
			Weapons_ViewAnimation(KNIFE_FIDGET);
			pl.w_idle_next = 2.0f;
		}
	} else {
		r  = (float)input_sequence % 5;
		switch (r) {
		case 0:
		case 1:
		case 2:
			Weapons_ViewAnimation(FISTS_IDLE);
			pl.w_idle_next = 10.0f;
			break;
		case 3:
			Weapons_ViewAnimation(FISTS_FIDGET1);
			pl.w_idle_next = 3.0f;
			break;
		default:
			Weapons_ViewAnimation(FISTS_FIDGET2);
			pl.w_idle_next = 2.333333f;
		}
	}
}

void
w_fists_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	pl.a_ammo1 = 1 - pl.a_ammo1;

	if (pl.a_ammo3 == HS_KNIFE) {
		#ifdef SERVER
		Sound_Play(pl, 8, "weapon_fists.missknife");
		#endif
		if (pl.a_ammo1 == 1) {
			Weapons_ViewAnimation(KNIFE_ATTACK1);
		} else {
			Weapons_ViewAnimation(KNIFE_ATTACK2);
		}
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = pl.w_attack_next;
	} else {
		if (pl.a_ammo1 == 1) {
			Weapons_ViewAnimation(FISTS_RIGHT);
			#ifdef SERVER
			Sound_Play(pl, CHAN_WEAPON, "weapon_fists.hitright");
			#endif
		} else {
			Weapons_ViewAnimation(FISTS_LEFT);
			#ifdef SERVER
			Sound_Play(pl, CHAN_WEAPON, "weapon_fists.hitleft");
			#endif
		}
		pl.w_attack_next = 0.25f;
		pl.w_idle_next = pl.w_attack_next;
	}
}

void
w_fists_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		w_fists_release();
		return;
	}

	if (pl.a_ammo3 == HS_KNIFE) {
		Weapons_ViewAnimation(KNIFE_HOLSTER);
		pl.a_ammo3 = HS_KNIFE_TO_FISTS;
		pl.w_attack_next = 0.75f;
		pl.w_idle_next = pl.w_attack_next;
	} else if (pl.a_ammo3 == HS_FISTS) {
		Weapons_ViewAnimation(FISTS_HOLSTER);
		pl.a_ammo3 = HS_FISTS_TO_KNIFE;
		pl.w_attack_next = 0.7f;
		pl.w_idle_next = pl.w_attack_next;
	}
}

string
w_fists_wmodel(void)
{
	return "";
}

string
w_fists_pmodel(void)
{
/*	if (pl.a_ammo3 == HS_KNIFE) {
		return "";
	} else {
		return "";
	}*/
	return "";
}

string
w_fists_deathmsg(void)
{
	return "%s killed %s with his knife.";
}

float
w_fists_aimanim(void)
{
	return 0;
}

int
w_fists_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_minigun < 100) {
		pl.ammo_minigun = bound(0, pl.ammo_minigun + 30, 100);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_fists_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_fists0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_fists_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_fists.knifedraw");
	Sound_Precache("weapon_fists.hitleft");
	Sound_Precache("weapon_fists.hitright");
	Sound_Precache("weapon_fists.missknife");
#endif

	precache_model("models/v_hands.mdl");
}

weapon_t w_fists =
{
	.id		= ITEM_FISTS,
	.slot		= 0,
	.slot_pos	= 0,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_fists_draw,
	.holster	= w_fists_holster,
	.primary	= w_fists_primary,
	.secondary	= w_fists_secondary,
	.reload		= __NULL__,
	.release	= w_fists_release,
	.crosshair	= __NULL__,
	.precache	= w_fists_precache,
	.pickup		= __NULL__,
	.updateammo	= w_fists_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= __NULL__,
	.deathmsg	= w_fists_deathmsg,
	.aimanim	= w_fists_aimanim,
	.hudpic		= w_fists_hudpic
};
