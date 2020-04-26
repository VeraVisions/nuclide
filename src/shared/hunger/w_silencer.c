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
	GLOCK_IDLE1,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD_EMPTY,
	GLOCK_RELOAD,
	GLOCK_DRAW,
	GLOCK_HOLSTER,
	GLOCK_SILENCER
};

void
w_silencer_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_glock.fire");
	Sound_Precache("weapon_silencer.fire");
#endif

	precache_model("models/v_9mmhandgun.mdl");
	precache_model("models/w_9mmhandgun.mdl");
	precache_model("models/p_9mmhandgun.mdl");
}

void
w_silencer_updateammo(player pl)
{
	w_glock_updateammo(pl);
}

string
w_silencer_wmodel(void)
{
	return "models/w_silencer.mdl";
}

string
w_silencer_pmodel(void)
{
	return w_glock_pmodel();
}

string
w_silencer_deathmsg(void)
{
	return "%s was silenced by %s's Beretta.";
}

int
w_silencer_pickup(int new, int startammo)
{
	return w_glock_pickup(new, startammo);
}

void
w_silencer_draw(void)
{
	w_glock_draw();
}
void
w_silencer_holster(void)
{
	w_glock_holster();
}

void
w_silencer_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
	
	if (pl.a_ammo3 == 1) {
		View_SetMuzzleflash(0);

	} else {
		View_SetMuzzleflash(MUZZLE_SMALL);
	}

	Weapons_ViewPunchAngle([-2,0,0]);
	
#else
	if (!pl.glock_mag) {
		return;
	}
#endif

	/* actual firing */
#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-2,0,0]);

	if (pl.a_ammo1) {
		Weapons_ViewAnimation(GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(GLOCK_SHOOT_EMPTY);
	}
#else
	pl.glock_mag--;

	/* Different sound & accuracy without silencer */
	if (pl.a_ammo3 == 1) {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet"), [0.01, 0.01], WEAPON_GLOCK);
		Sound_Play(pl, CHAN_WEAPON, "weapon_silencer.fire");

	} else {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet"),  [0.1,0.1], WEAPON_GLOCK);
		Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);
#endif

	/* Fires faster without silencer */
	if (pl.a_ammo3 == 1) {
		pl.w_attack_next = 0.3f;
	} else {
		pl.w_attack_next = 0.2f;
	}
	pl.w_idle_next = 5.0f;
}

void
w_silencer_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

	/* toggle silencer */
	pl.a_ammo3 = 1 - pl.a_ammo3;

	/* the sub model isn't setting right, need the right values */
#ifdef CLIENT
	if (pl.a_ammo3) {
		Weapons_SetGeomset("geomset 1 3\n");
		Weapons_ViewAnimation(GLOCK_SILENCER);
	} else {
		Weapons_SetGeomset("geomset 0 1\n");
		Weapons_ViewAnimation(GLOCK_HOLSTER);
	}
#endif
	if (pl.a_ammo3) {
		pl.w_attack_next = 3.3f;
		pl.w_idle_next = pl.w_attack_next;
	} else {
		
		pl.w_attack_next = 0.94f;
		pl.w_idle_next = pl.w_attack_next;
	}
}

void
w_silencer_reload(void)
{
	w_glock_reload();
}

void
w_silencer_release(void)
{
	w_glock_release();
}

float
w_silencer_aimanim(void)
{
	return w_glock_aimanim();
}

void
w_silencer_hud(void)
{
	w_glock_hud();
}

void
w_silencer_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,135/256],
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
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_silencer =
{
	.name		= "silencer",
	.id			= ITEM_GLOCK,
	.slot		= 1,
	.slot_pos	= 0,
	.draw		= w_silencer_draw,
	.holster	= w_silencer_holster,
	.primary	= w_silencer_primary,
	.secondary	= w_silencer_secondary,
	.reload		= w_silencer_reload,
	.release	= w_silencer_release,
	.crosshair	= w_silencer_hud,
	.precache	= w_silencer_precache,
	.pickup		= w_silencer_pickup,
	.updateammo	= w_silencer_updateammo,
	.wmodel		= w_silencer_wmodel,
	.pmodel		= w_silencer_pmodel,
	.deathmsg	= w_silencer_deathmsg,
	.aimanim	= w_silencer_aimanim,
	.hudpic		= w_silencer_hudpic
};
