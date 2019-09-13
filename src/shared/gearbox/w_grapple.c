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

enum
{
	BARN_IDLE1,
	BARN_IDLE2,
	BARN_IDLE3,
	BARN_COUGH,
	BARN_HOLSTER,
	BARN_DRAW,
	BARN_FIRE,
	BARN_FIREWAIT,
	BARN_FIREREACH,
	BARN_FIRETRAVEL,
	BARN_FIRERELEASE
};

void
w_grapple_precache(void)
{
	precache_sound("weapons/bgrapple_cough.wav");
	precache_sound("weapons/bgrapple_fire.wav");
	precache_sound("weapons/bgrapple_impact.wav");
	precache_sound("weapons/bgrapple_pull.wav");
	precache_sound("weapons/bgrapple_release.wav");
	precache_sound("weapons/bgrapple_wait.wav");
	precache_model("models/v_bgrap.mdl");
	precache_model("models/v_bgrap_tonguetip.mdl");
	precache_model("models/w_bgrap.mdl");
	precache_model("models/p_bgrap.mdl");
}

void
w_grapple_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_grapple_wmodel(void)
{
	return "models/w_bgrap.mdl";
}

string
w_grapple_pmodel(void)
{
	return "models/p_bgrap.mdl";
}

string
w_grapple_deathmsg(void)
{
	return "%s was assaulted by %s's Barnacle.";
}

void
w_grapple_draw(void)
{
	Weapons_SetModel("models/v_bgrap.mdl");
	Weapons_ViewAnimation(BARN_DRAW);
}

void
w_grapple_holster(void)
{
	Weapons_ViewAnimation(BARN_HOLSTER);
}

void Grapple_Touch(void)
{
	player pl = (player)self.owner;
	pl.hook.movetype = MOVETYPE_NONE;
	pl.hook.touch = __NULL__;
	pl.hook.velocity = [0,0,0];
	pl.hook.solid = SOLID_NOT;
	pl.hook.skin = 1; /* grappled */
	pl.a_ammo1 = 1;
}

void
w_grapple_primary(void)
{
	player pl = (player)self;

	if (pl.hook != __NULL__) {
		/* play the looping reel anim once */
		if (pl.a_ammo1 == 1) {
			pl.a_ammo1 = 2;
			Weapons_ViewAnimation(BARN_FIRETRAVEL);
		}
		return;
	}

	Weapons_MakeVectors();
	pl.hook = spawn();

#ifdef CSQC
	setmodel(pl.hook, "models/v_bgrap_tonguetip.mdl");
	pl.hook.drawmask = MASK_ENGINE;
#endif
	setorigin(pl.hook, Weapons_GetCameraPos() + (v_forward * 16));
	pl.hook.owner = self;
	pl.hook.velocity = v_forward * 800;
	pl.hook.movetype = MOVETYPE_FLYMISSILE;
	pl.hook.solid = SOLID_BBOX;
	pl.hook.angles = vectoangles(pl.hook.velocity);
	pl.hook.touch = Grapple_Touch;
	pl.hook.skin = 0; /* ungrappled */
	setsize(pl.hook, [0,0,0], [0,0,0]);
	Weapons_ViewAnimation(BARN_FIRE);
}

void
w_grapple_secondary(void)
{
/* TODO, special CTF alt fire */
}


void
w_grapple_release(void)
{
	player pl = (player)self;

	if (pl.hook != __NULL__) {
		pl.hook.skin = 0; /* ungrappled */
		remove(pl.hook);
		pl.hook = __NULL__;
		Weapons_ViewAnimation(BARN_FIRERELEASE);
		pl.w_idle_next = 1.0f;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(BARN_IDLE1);
		pl.w_idle_next = 2.566667f;
		break;
	case 2:
		Weapons_ViewAnimation(BARN_IDLE2);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(BARN_IDLE3);
		pl.w_idle_next = 1.35f;
		break;
	}
}

float
w_grapple_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_grapple_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_grapple =
{
	.id		= ITEM_GRAPPLE,
	.slot		= 0,
	.slot_pos	= 3,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,224],
	.draw		= w_grapple_draw,
	.holster	= w_grapple_holster,
	.primary	= w_grapple_primary,
	.secondary	= w_grapple_secondary,
	.reload		= __NULL__,
	.release	= w_grapple_release,
	.crosshair	= __NULL__,
	.precache	= w_grapple_precache,
	.pickup		= __NULL__,
	.updateammo	= w_grapple_updateammo,
	.wmodel		= w_grapple_wmodel,
	.pmodel		= w_grapple_pmodel,
	.deathmsg	= w_grapple_deathmsg,
	.aimanim	= w_grapple_aimanim,
	.hudpic		= w_grapple_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_grapple(void)
{
	Weapons_InitItem(WEAPON_GRAPPLE);
}
#endif
