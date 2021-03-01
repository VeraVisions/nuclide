/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_knife (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_knife.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Knife Weapon

*/

enum
{
	KNIFE_IDLE1,
	KNIFE_DRAW,
	KNIFE_HOLSTER,
	KNIFE_ATTACK1HIT,
	KNIFE_ATTACK1MISS,
	KNIFE_ATTACK2MISS,
	KNIFE_ATTACK2HIT,
	KNIFE_ATTACK3MISS,
	KNIFE_ATTACK3HIT,
	KNIFE_IDLE2,
	KNIFE_IDLE3
};

void
w_knife_precache(void)
{
#ifdef SERVER
	precache_model("models/w_knife.mdl");
	precache_sound("weapons/knife1.wav");
	precache_sound("weapons/knife2.wav");
	precache_sound("weapons/knife3.wav");
	precache_sound("weapons/knife_hit_wall1.wav");
	precache_sound("weapons/knife_hit_wall2.wav");
	precache_sound("weapons/knife_hit_flesh1.wav");
	precache_sound("weapons/knife_hit_flesh2.wav");
#else
	precache_model("models/v_knife.mdl");
	precache_model("models/p_knife.mdl");
#endif
}

void 
w_knife_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, -1, -1);
}

string
w_knife_wmodel(void)
{
	return "models/w_knife.mdl";
}

string
w_knife_pmodel(void)
{
	return "models/p_knife.mdl";
}

string
w_knife_deathmsg(void)
{
	return "%s was assaulted by %s's Knife.";
}

void
w_knife_draw(void)
{
	Weapons_SetModel("models/v_knife.mdl");
	Weapons_ViewAnimation(KNIFE_DRAW);
}

void
w_knife_holster(void)
{
	Weapons_ViewAnimation(KNIFE_HOLSTER);
}

void
w_knife_primary(void)
{
	int anim = 0;
	int r;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}
	pl.w_idle_next = 2.5f;

#ifdef CLIENT
	r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		anim = trace_fraction >= 1 ? KNIFE_ATTACK1MISS:KNIFE_ATTACK1HIT;
		break;
	case 1:
		anim = trace_fraction >= 1 ? KNIFE_ATTACK2MISS:KNIFE_ATTACK2HIT;
		break;
	default:
		anim = trace_fraction >= 1 ? KNIFE_ATTACK3MISS:KNIFE_ATTACK3HIT;
	}
	Weapons_ViewAnimation(anim);
#else
	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTopTemp(ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTopTemp(ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

	r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		sound(pl, CHAN_WEAPON, "weapons/knife1.wav", 1, ATTN_NORM);
		break;
	case 1:
		sound(pl, CHAN_WEAPON, "weapons/knife2.wav", 1, ATTN_NORM);
		break;
	default:
		sound(pl, CHAN_WEAPON, "weapons/knife3.wav", 1, ATTN_NORM);
	}

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		FX_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, self, 10, WEAPON_KNIFE, DMG_SLASH);

		if (!trace_ent.iBleeds) {
			return;
		}

		if (random() < 0.5) {
			sound(pl, 8, "weapons/knife_hit_flesh1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/knife_hit_flesh2.wav", 1, ATTN_NORM);
		}
	} else {
		if (random() < 0.5) {
			sound(pl, 8, "weapons/knife_hit_wall1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/knife_hit_wall2.wav", 1, ATTN_NORM);
		}
	}
#endif
}

void
w_knife_release(void)
{
	int r;
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(KNIFE_IDLE1);
		pl.w_idle_next = 2.7f;
		break;
	case 1:
		Weapons_ViewAnimation(KNIFE_IDLE2);
		pl.w_idle_next = 5.3f;
		break;
	default:
		Weapons_ViewAnimation(KNIFE_IDLE3);
		pl.w_idle_next = 5.3f;
	}
}

float
w_knife_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_knife_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof04.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof03.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_knife =
{
	.name		= "knife",
	.id			= ITEM_KNIFE,
	.slot		= 0,
	.slot_pos	= 2,
	.draw		= w_knife_draw,
	.holster	= w_knife_holster,
	.primary	= w_knife_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_knife_release,
	.crosshair	= __NULL__,
	.precache	= w_knife_precache,
	.pickup		= __NULL__,
	.updateammo	= w_knife_updateammo,
	.wmodel		= w_knife_wmodel,
	.pmodel		= w_knife_pmodel,
	.deathmsg	= w_knife_deathmsg,
	.aimanim	= w_knife_aimanim,
	.hudpic		= w_knife_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void weapon_knife(void)
{
	Weapons_InitItem(WEAPON_KNIFE);
}
#endif
