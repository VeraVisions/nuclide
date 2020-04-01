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
	PIPEB_IDLE,
	PIPEB_FIDGET,
	PIPEB_DRAW,
	PIPEB_THROW
};

enum
{
	WATCH_IDLE,
	WATCH_FIDGET,
	WATCH_DRAW,
	WATCH_USE,
	WATCH_HOLSTER
};

void w_pipebomb_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#endif
}
string w_pipebomb_wmodel(void)
{
	return "models/w_pipebomb.mdl";
}
void w_pipebomb_precache(void)
{
	precache_sound("weapons/pb_bounce1.wav");
	precache_sound("weapons/pb_bounce2.wav");	precache_sound("weapons/pb_bounce3.wav");

	precache_model("models/v_pipebomb.mdl");
	precache_model("models/v_pipebomb_watch.mdl");
	precache_model("models/w_pipebomb.mdl");
}

int w_pipebomb_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_satchel < 5) {
		pl.ammo_satchel = bound(0, pl.ammo_satchel + 1, 5);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_pipebomb_draw(void)
{
	Weapons_SetModel("models/v_pipebomb.mdl");
	Weapons_ViewAnimation(PIPEB_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#endif
}

void w_pipebomb_holster(void)
{
	
}

#ifdef SSQC
void s_pipebomb_drop(entity master, vector src, vector vel)
{
	entity satch;
	satch = spawn();
	satch.owner = master;
	satch.classname = "satchel";
	satch.movetype = MOVETYPE_BOUNCE;
	satch.solid = SOLID_BBOX;
	satch.frame = 1;
	satch.gravity = 0.5f;
	satch.friction = 0.8f;
	satch.velocity = vel;
	satch.avelocity = [0,400,0];
	setmodel(satch, "models/w_pipebomb.mdl");
	setsize(satch, [-4,-4,-4], [4,4,4]);
	setorigin(satch, src);
}
void s_pipebomb_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "satchel"));) {
		if (b.owner == master) {
			Effect_CreateExplosion(b.origin);
			Damage_Radius(b.origin, master, 150, 150 * 2.5f, TRUE, WEAPON_PIPEBOMB);
			sound(b, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
			remove(b);
		}
	}
}
#endif

void w_pipebomb_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0 && pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
        return;
	}
#endif

	if (pl.a_ammo1 <= 0) {
        Weapons_ViewAnimation(WATCH_DRAW);
    } else {
        Weapons_ViewAnimation(WATCH_USE);
    }

#ifdef SSQC
	if (!pl.satchel_chg) {
		vector throw;
		
		Weapons_MakeVectors();
		throw = pl.velocity + (v_forward * 274);
		s_pipebomb_drop(self, pl.origin, throw);
		pl.satchel_chg++;
		pl.ammo_satchel--;
	} else {
		s_pipebomb_detonate(pl);
		pl.satchel_chg = 0;

		if (pl.ammo_satchel <= 0) {
			Weapons_RemoveItem(pl, WEAPON_PIPEBOMB);
		}
	}
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	setmodel(pSeat->eViewModel, "models/v_pipebomb_watch.mdl");
	pl.a_ammo1++;
	pl.a_ammo2--;
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 1.0f;
}
void w_pipebomb_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_satchel <= 0) {
		return;
	}
#endif

#ifdef SSQC
	vector throw;
	Weapons_MakeVectors();
	throw = pl.velocity + (v_forward * 274);
	s_pipebomb_drop(self, pl.origin, throw);
	pl.satchel_chg++;
	pl.ammo_satchel--;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	pl.a_ammo1++;
	pl.a_ammo2--;
	setmodel(pSeat->eViewModel, "models/v_pipebomb_watch.mdl");
#endif

	Weapons_ViewAnimation(WATCH_DRAW);

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}
void
w_pipebomb_reload(void)
{
	
}
void
w_pipebomb_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(PIPEB_FIDGET);
	} else {
		Weapons_ViewAnimation(WATCH_FIDGET);
	}
	pl.w_idle_next = 15.0f;
}

float
w_pipebomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_pipebomb_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,96/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_pipebomb_hudpic(int s, vector pos, float a)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_pipebomb =
{
	.id		= ITEM_PIPEBOMB,
	.slot		= 4,
	.slot_pos	= 0,
	.ki_spr		= __NULL__,
	.ki_size	= __NULL__,
	.ki_xy		= __NULL__,
	.draw		= w_pipebomb_draw,
	.holster	= w_pipebomb_holster,
	.primary	= w_pipebomb_primary,
	.secondary	= w_pipebomb_secondary,
	.reload		= __NULL__,
	.release	= w_pipebomb_release,
	.crosshair	= __NULL__,
	.precache	= w_pipebomb_precache,
	.pickup		= __NULL__,
	.updateammo	= w_pipebomb_updateammo,
	.wmodel		= w_pipebomb_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_pipebomb_hudpic
};

#ifdef SSQC
void weapon_pipebomb(void) {
	Weapons_InitItem(WEAPON_PIPEBOMB);
}
#endif

