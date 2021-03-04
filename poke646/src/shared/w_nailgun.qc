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

enum
{
	NAIL_IDLE1,
	NAIL_IDLE2,
	NAIL_UNUSED1,
	NAIL_RELOAD,
	NAIL_DRAW,
	NAIL_SHOOT
};

void
w_nailgun_precache(void)
{
	precache_sound("weapons/brad_hit1.wav");
	precache_sound("weapons/brad_hit2.wav");
	precache_sound("weapons/nailgun.wav");

	precache_model("models/nail.mdl");
	precache_model("models/v_nailgun.mdl");
	precache_model("models/w_nailgun.mdl");
}

void
w_nailgun_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_nailgun_wmodel(void)
{
	return "models/w_nailgun.mdl";
}

void
w_nailgun_draw(void)
{
	Weapons_SetModel("models/v_nailgun.mdl");
	Weapons_ViewAnimation(NAIL_DRAW);
}

void
w_nailgun_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef SERVER
	static void Nail_Touch(void) {
		FX_Spark(self.origin, trace_plane_normal);
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, WEAPON_NAILGUN, DMG_GENERIC);
			if (random() < 0.5) {
				Weapons_PlaySound(self, CHAN_WEAPON, "weapons/brad_hit1.wav", 1, ATTN_NORM);
			} else {
				Weapons_PlaySound(self, CHAN_WEAPON, "weapons/brad_hit2.wav", 1, ATTN_NORM);
			}
		} else {
			Weapons_PlaySound(self, CHAN_WEAPON, "weapons/xbow_hit1.wav", 1, ATTN_NORM);
		}
		remove(self);
	}

	Weapons_MakeVectors();
	entity nail = spawn();
	setmodel(nail, "models/nail.mdl");
	setorigin(nail, Weapons_GetCameraPos() + (v_forward * 16));
	nail.owner = self;
	nail.velocity = v_forward * 2000;
	nail.movetype = MOVETYPE_FLY;
	nail.solid = SOLID_BBOX;
	nail.angles = vectoangles(nail.velocity);
	nail.avelocity[2] = 10;
	nail.touch = Nail_Touch;
	setsize(nail, [0,0,0], [0,0,0]);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/nailgun.wav", 1, ATTN_NORM);

#else

	Weapons_ViewPunchAngle([-2,0,0]);
	Weapons_ViewAnimation(NAIL_SHOOT);

	
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 5.0f;
}

void
w_nailgun_release(void)
{

	player pl = (player)self;
	if (pl.w_idle_next > 0) {
		return;
	}

	if (random() < 0.5) {
				Weapons_ViewAnimation(NAIL_IDLE1);
		} else {
	Weapons_ViewAnimation(NAIL_IDLE2);
		}
	pl.w_idle_next = 10.0f;

}


void
w_nailgun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/hud640_01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/hud640_01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_nailgun =
{
	.name		= "nailgun",
	.id		= ITEM_NAILGUN,
	.slot		= 1,
	.slot_pos	= 1,
	.draw		= w_nailgun_draw,
	.holster	= __NULL__,
	.primary	= w_nailgun_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_nailgun_release,
	.crosshair	= __NULL__,
	.precache	= w_nailgun_precache,
	.pickup		= __NULL__,
	.updateammo	= w_nailgun_updateammo,
	.wmodel		= w_nailgun_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_nailgun_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_nailgun(void)
{
	Weapons_InitItem(WEAPON_NAILGUN);
}
#endif
