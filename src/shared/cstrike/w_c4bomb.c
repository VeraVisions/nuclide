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

/*QUAKED weapon_c4bomb (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_c4.mdl"

COUNTER-STRIKE (1999) ENTITY

C4 Bomb Weapon, Bomb Defusal Gamemode Entity

Default arsenal for Terrorists

Can only be picked up by Terrorists and planted in
func_bombtarget brush entities.

*/

/* C4 weapon logic */

enum
{
	C4_IDLE,
	C4_DRAW,
	C4_DROP,
	C4_ENTERCODE
};

enum
{
	C4S_NONE,
	C4S_ENTERINGCODE,
	C4S_DROPPING,
	C4S_DONE
};

void
w_c4bomb_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_c4bomb.disarm");
	Sound_Precache("weapon_c4bomb.disarmed");
	Sound_Precache("weapon_c4bomb.explode");
	Sound_Precache("weapon_c4bomb.plant");
	precache_sound("weapons/c4_plant.wav");
	precache_sound("weapons/c4_beep1.wav");
	precache_sound("weapons/c4_beep2.wav");
	precache_sound("weapons/c4_beep3.wav");
	precache_sound("weapons/c4_beep4.wav");
	precache_sound("weapons/c4_beep5.wav");
	precache_sound("weapons/c4_explode1.wav");
	precache_model("models/w_c4.mdl");
	precache_model("models/w_backpack.mdl");
	precache_model("models/p_c4.mdl");
	precache_model("sprites/ledglow.spr");
#else
	precache_model("models/v_c4.mdl");
#endif
}

void
w_c4bomb_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.a_ammo1, pl.a_ammo2, pl.a_ammo3);
#endif
}

string
w_c4bomb_wmodel(void)
{
	return "models/w_backpack.mdl";
}

string
w_c4bomb_pmodel(void)
{
	return "models/p_c4.mdl";
}

string
w_c4bomb_deathmsg(void)
{
	return "";
}

void
w_c4bomb_draw(void)
{
	Weapons_SetModel("models/v_c4.mdl");
	Weapons_ViewAnimation(C4_DRAW);
}

void
w_c4bomb_release(void)
{
	player pl = (player)self;
	
	if (pl.a_ammo1 == C4S_DROPPING) {
		if (pl.w_idle_next <= 0.0f) {
			pl.a_ammo1 = C4S_DONE;
#ifdef SERVER
			C4Bomb_Plant(pl);
			Weapons_RemoveItem(pl, WEAPON_C4BOMB);
#endif
		}
		return;
	}

	/* reset animation */
	if (pl.a_ammo1 != C4S_NONE) {
		Weapons_ViewAnimation(C4_IDLE);
	}
	pl.a_ammo1 = C4S_NONE;
	pl.w_idle_next = 0.0f;
}

void
w_c4bomb_primary(void)
{
	player pl = (player)self;

	if (!(pl.flags & FL_BOMBZONE)) {
		return;
	}

	pl.flags |= FL_FROZEN;

	switch (pl.a_ammo1) {
	case C4S_NONE:
			pl.a_ammo1 = C4S_ENTERINGCODE;
			Weapons_ViewAnimation(C4_ENTERCODE);
			pl.w_idle_next = 3.0f;
			break;
	case C4S_ENTERINGCODE:
			if (pl.w_idle_next <= 0.0f) {
				pl.a_ammo1 = C4S_DROPPING;
				Weapons_ViewAnimation(C4_DROP);
				pl.w_idle_next = 1.0f;
			}
			break;
	case C4S_DROPPING:
			w_c4bomb_release();
			return;
			break;
	default:
		break;
	}

	pl.w_attack_next = 0.0f;
}

float
w_c4bomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_C4 : ANIM_AIM_C4;
}

void
w_c4bomb_hud(void)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_c4bomb_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud1.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_c4bomb =
{
	.name		= "c4",
	.id			= ITEM_C4BOMB,
	.slot		= 4,
	.slot_pos	= 0,
	.allow_drop	= TRUE,
	.draw		= w_c4bomb_draw,
	.holster	= __NULL__,
	.primary	= w_c4bomb_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_c4bomb_release,
	.crosshair	= w_c4bomb_hud,
	.precache	= w_c4bomb_precache,
	.pickup		= __NULL__,
	.updateammo	= w_c4bomb_updateammo,
	.wmodel		= w_c4bomb_wmodel,
	.pmodel		= w_c4bomb_pmodel,
	.deathmsg	= w_c4bomb_deathmsg,
	.aimanim	= w_c4bomb_aimanim,
	.hudpic		= w_c4bomb_hudpic
};

#ifdef SERVER
void
weapon_c4bomb(void)
{
	Weapons_InitItem(WEAPON_C4BOMB);
}
#endif
