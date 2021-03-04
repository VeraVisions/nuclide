/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_pipebomb (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_pipebomb.mdl"

Poke646 (2001) ENTITY

Pipebomb Weapon, literal copy of Half-Life's Satchel Weapon

*/

enum
{
	SATCHEL_IDLE,
	SATCHEL_FIDGET,
	SATCHEL_DRAW,
	SATCHEL_THROW
};

enum
{
	RADIO_IDLE,
	RADIO_FIDGET,
	RADIO_DRAW,
	RADIO_USE,
	RADIO_HOLSTER
};

void w_pipebomb_updateammo(player pl)
{
	w_satchel_updateammo(pl);
}
string w_pipebomb_wmodel(void)
{
	return "models/w_pipebomb.mdl";
}
string w_pipebomb_pmodel(void)
{
	return "models/p_pipebomb.mdl";
}
string w_pipebomb_deathmsg(void)
{
	return "%s blew up %s with a pipebomb.";
}
void w_pipebomb_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_satchel.bounce");
#endif
	precache_model("models/w_pipebomb.mdl");
	precache_model("models/v_pipebomb.mdl");
	precache_model("models/v_pipebomb_watch.mdl");
	precache_model("models/p_pipebomb.mdl");
}

int w_pipebomb_pickup(int new, int startammo)
{
	return w_satchel_pickup(new, startammo);
}

void w_pipebomb_draw(void)
{
	Weapons_SetModel("models/v_pipebomb.mdl");
	Weapons_ViewAnimation(SATCHEL_DRAW);
#ifdef SERVER
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#endif
}

void w_pipebomb_holster(void)
{
	
}

#ifdef SERVER
void s_pipebomb_drop(entity master, vector src, vector vel)
{
	static void s_pipebomb_touch(void)
	{
		if (other == world)
			Sound_Play(self, CHAN_BODY, "weapon_satchel.bounce");
	}
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
	satch.touch = s_pipebomb_touch;
	setmodel(satch, "models/w_satchel.mdl");
	setsize(satch, [-4,-4,-4], [4,4,4]);
	setorigin(satch, src);
}
void s_pipebomb_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "satchel"));) {
		if (b.owner == master) {
			float dmg = Skill_GetValue("plr_satchel", 150);
			FX_Explosion(b.origin);
			Damage_Radius(b.origin, master, dmg, dmg * 2.5f, TRUE, WEAPON_SATCHEL);
			sound(b, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
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
#ifdef CLIENT
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
		return;
	}
#else
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
        return;
	}
#endif

	if (pl.satchel_chg <= 0) {
        Weapons_ViewAnimation(RADIO_DRAW);
    } else {
        Weapons_ViewAnimation(RADIO_USE);
    }

#ifdef SERVER
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
			Weapons_RemoveItem(pl, WEAPON_SATCHEL);
		}
	}
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	setmodel(pSeat->m_eViewModel, "models/v_pipebomb_watch.mdl");
	pl.satchel_chg++;
	pl.ammo_satchel--;
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
#ifdef CLIENT
	if (pl.ammo_satchel <= 0) {
		return;
	}
#else
	if (pl.ammo_satchel <= 0) {
		return;
	}
#endif

#ifdef SERVER
	vector throw;
	Weapons_MakeVectors();
	throw = pl.velocity + (v_forward * 274);
	s_pipebomb_drop(self, pl.origin, throw);
	pl.satchel_chg++;
	pl.ammo_satchel--;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	pl.satchel_chg++;
	pl.ammo_satchel--;
	setmodel(pSeat->m_eViewModel, "models/v_pipebomb_watch.mdl");
#endif

	Weapons_ViewAnimation(RADIO_DRAW);

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}
void w_pipebomb_reload(void)
{
	
}
void w_pipebomb_release(void)
{
	w_satchel_release();
}

float w_pipebomb_aimanim(void)
{
	return w_satchel_aimanim();
}

void w_pipebomb_hud(void)
{
	w_satchel_holster();
}

void w_pipebomb_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_pipebomb =
{
	.name		= "pipebomb",
	.id		= ITEM_SATCHEL,
	.slot		= 4,
	.slot_pos	= 1,
	.draw		= w_pipebomb_draw,
	.holster	= w_pipebomb_holster,
	.primary	= w_pipebomb_primary,
	.secondary	= w_pipebomb_secondary,
	.reload		= __NULL__,
	.release	= w_pipebomb_release,
	.crosshair	= w_pipebomb_hud,
	.precache	= w_pipebomb_precache,
	.pickup		= w_pipebomb_pickup,
	.updateammo	= w_pipebomb_updateammo,
	.wmodel		= w_pipebomb_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= w_pipebomb_aimanim,
	.hudpic		= w_pipebomb_hudpic
};

#ifdef SERVER
void weapon_pipebomb(void) {
	Weapons_InitItem(WEAPON_SATCHEL);
}
#endif
