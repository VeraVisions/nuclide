/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 * Copyright (c) 2019-2020 Gethyn ThomasQuail <xylemon@posteo.net>
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
	MEDKIT_IDLE1,
	MEDKIT_IDLE2,
	MEDKIT_USE,
	MEDKIT_UNUSED,
	MEDKIT_HOLSTER,
	MEDKIT_DRAW
};

void
w_medkit_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_medkit.heal");
#endif
	precache_model("models/v_tfc_medkit.mdl");
	precache_model("models/w_tfc_medkit.mdl");
	precache_model("models/p_tfc_medkit.mdl");
}

void
w_medkit_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, pl.ammo_medkit, -1);
#endif
}

string
w_medkit_wmodel(void)
{
	return "models/w_tfc_medkit.mdl";
}

string
w_medkit_pmodel(void)
{
	return "models/p_tfc_medkit.mdl";
}

string
w_medkit_deathmsg(void)
{
	return "%s was somehow healed to death by %s's Medkit.";
}

int
w_medkit_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.ammo_medkit = 8;
	} else {
		if (pl.ammo_medkit < MAX_A_MEDKIT) {
			pl.ammo_medkit = bound(0, pl.ammo_medkit + 8, MAX_A_MEDKIT);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}


void
w_medkit_draw(void)
{
	Weapons_SetModel("models/v_tfc_medkit.mdl");
	Weapons_ViewAnimation(MEDKIT_DRAW);
}

void
w_medkit_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef SERVER
	if (!pl.ammo_medkit) {
		return;
	}

	/* Don't give the player more than 100 health */
	if (pl.health >= 100) {
		return;
	}

	/* We want to only give health to the player & skip armor */
	Damage_Apply(pl, pl, -15, WEAPON_MEDKIT, DMG_GENERIC);
	pl.ammo_medkit--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_medkit.heal");
#endif

	if (pl.health >= 100) {
		return;
	} else {
		Weapons_ViewAnimation(MEDKIT_USE);
	}

	pl.w_attack_next = 2.4f;
	pl.w_idle_next = 5.0f;
}

void
w_medkit_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(MEDKIT_IDLE1);
		pl.w_idle_next = 1.16f;
		break;
	default:
		Weapons_ViewAnimation(MEDKIT_IDLE2);
		pl.w_idle_next = 2.36f;
		break;
	}
}

float
w_medkit_aimanim(void)
{
	return w_snark_aimanim();
}

void
w_medkit_crosshair(void)
{
#ifdef CLIENT
	vector aicon_pos;
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	HUD_DrawAmmo2();

	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/256,96/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

void
w_medkit_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud06.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_medkit =
{
	.name		= "medkit",
	.id			= ITEM_MEDKIT2,
	.slot		= 4,
	.slot_pos	= 4,
	.draw		= w_medkit_draw,
	.holster	= __NULL__,
	.primary	= w_medkit_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_medkit_release,
	.crosshair	= w_medkit_crosshair,
	.precache	= w_medkit_precache,
	.pickup		= w_medkit_pickup,
	.updateammo	= w_medkit_updateammo,
	.wmodel		= w_medkit_wmodel,
	.pmodel		= w_medkit_pmodel,
	.deathmsg	= w_medkit_deathmsg,
	.aimanim	= w_medkit_aimanim,
	.hudpic		= w_medkit_hudpic
};

#ifdef SERVER
void
weapon_th_medkit(void)
{
	Weapons_InitItem(WEAPON_MEDKIT);
}
#endif
