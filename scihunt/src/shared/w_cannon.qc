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

#ifdef CLIENT
var string g_cannon_spr;
#endif

typedef enum
{
	CANNON_FIREBOTH,
	CANNON_FIRELEFT,
	CANNON_FIRERIGHT,
	CANNON_RELOAD,
	CANNON_DEPLOY,
	CANNON_PUTAWAY,
	CANNON_IDLE1,
	CANNON_IDLE2
} cannonAnims_t;

void
w_cannon_precache(void)
{
#ifdef SERVER
	precache_sound("cannon/cin.wav");
	precache_sound("cannon/close.wav");
	precache_sound("cannon/cout.wav");
	precache_sound("cannon/fire.wav");
	precache_sound("cannon/open.wav");
#else
	precache_model("models/v_cannon.mdl");
	precache_model("models/p_cannon.mdl");
	g_cannon_spr = spriteframe("sprites/w_cannon.spr", 0, 0.0f);
#endif
}

void
w_cannon_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.cannon_mag, pl.ammo_buckshot, __NULL__);
#endif
}

string
w_cannon_pmodel(void)
{
	return "models/p_cannon.mdl";
}

string
w_cannon_deathmsg(void)
{
	return "%s killed %s with handcannon.";
}

void
w_cannon_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0) {
		return;
	}
#ifdef CLIENT
	if (pl.a_ammo1 >= 2) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.cannon_mag >= 2) {
		return;
	}
	if (!pl.ammo_buckshot) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::cannon_mag, player::ammo_buckshot, 2);
	Weapons_UpdateAmmo(pl, pl.cannon_mag, pl.ammo_buckshot, __NULL__);
#endif
	Weapons_ViewAnimation(CANNON_RELOAD);

	pl.w_attack_next = 3.0f;
	pl.w_idle_next = 3.0f;
}

int
w_cannon_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.cannon_mag = 2;
	} else {
		if (pl.ammo_buckshot < 125) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 2, 125);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_cannon_draw(void)
{
	Weapons_SetModel("models/v_cannon.mdl");
	Weapons_ViewAnimation(CANNON_DEPLOY);
#ifdef SERVER
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.cannon_mag, pl.ammo_buckshot, __NULL__);
#endif
}

void
w_cannon_holster(void)
{
	Weapons_ViewAnimation(CANNON_PUTAWAY);
}

void
w_cannon_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 != 2) {
		w_cannon_reload();
		return;
	}

	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	int dmg;

	if (pl.cannon_mag != 2) {
		w_cannon_reload();
		return;
	}

	dmg = Skill_GetValue("plr_cannon", 5);
	TraceAttack_FireBullets(20, pl.origin + pl.view_ofs, dmg, [0.08716,0.04362], WEAPON_CANNON);
	pl.cannon_mag -= 2;
	Weapons_PlaySound(pl, CHAN_WEAPON, "cannon/fire.wav", 1, ATTN_NORM);
	Weapons_UpdateAmmo(pl, pl.cannon_mag, pl.ammo_buckshot, __NULL__);
#endif
	Weapons_ViewPunchAngle([-5,0,0]);
	Weapons_ViewAnimation(CANNON_FIREBOTH);
	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 2.5f;
}

void
w_cannon_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (!pl.a_ammo1) {
		w_cannon_reload();
		return;
	}

	Weapons_ViewPunchAngle([-5,0,0]);
#else
	int dmg;
	if (!pl.cannon_mag) {
		w_cannon_reload();
		return;
	}

	dmg = Skill_GetValue("plr_cannon", 5);
	TraceAttack_FireBullets(10, pl.origin + pl.view_ofs, dmg, [0.08716,0.04362], WEAPON_CANNON);
	pl.cannon_mag--;
	Weapons_PlaySound(pl, CHAN_WEAPON, "cannon/fire.wav", 1, ATTN_NORM);
	Weapons_UpdateAmmo(pl, pl.cannon_mag, pl.ammo_buckshot, __NULL__);
#endif

	if (pl.a_ammo1 == 2) {
        Weapons_ViewAnimation(CANNON_FIRELEFT);
    } else {
        Weapons_ViewAnimation(CANNON_FIRERIGHT);
    }

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 2.5f;
}
void
w_cannon_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.a_ammo1 == 0 && pl.a_ammo2 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(CANNON_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(CANNON_IDLE2);
		break;
	}

	pl.w_idle_next = 8.0f;
}

void
w_cannon_crosshair(void)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], g_cross_spr, [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_cannon_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_cannon_hudpic(int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], g_cannon_spr, [0,48/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], g_cannon_spr, [0,0], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t
w_cannon =
{
	.name		= "handcannon",
	.id		= ITEM_CANNON,
	.slot		= 2,
	.slot_pos	= 3,
	.draw		= w_cannon_draw,
	.holster	= w_cannon_holster,
	.primary	= w_cannon_primary,
	.secondary	= w_cannon_secondary,
	.reload		= w_cannon_reload,
	.release	= w_cannon_release,
	.crosshair	= w_cannon_crosshair,
	.precache	= w_cannon_precache,
	.pickup		= w_cannon_pickup,
	.updateammo	= w_cannon_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= w_cannon_pmodel,
	.deathmsg	= w_cannon_deathmsg,
	.aimanim	= w_cannon_aimanim,
	.hudpic		= w_cannon_hudpic
};
