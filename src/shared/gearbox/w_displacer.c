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

/*QUAKED weapon_displacer (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_displacer.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Displacer Weapon

*/

enum
{
	DISP_IDLE1,
	DISP_IDLE2,
	DISP_SPINUP,
	DISP_SPIN,
	DISP_FIRE,
	DISP_DRAW,
	DISP_HOLSTER
};

#ifdef SERVER
entity Spawn_SelectRandom(string);
#endif

void
w_displacer_precache(void)
{
	precache_sound("weapons/displacer_fire.wav");
	precache_sound("weapons/displacer_impact.wav");
	precache_sound("weapons/displacer_self.wav");
	precache_sound("weapons/displacer_spin.wav");
	precache_sound("weapons/displacer_spin2.wav");
	precache_sound("weapons/displacer_start.wav");
	precache_sound("weapons/displacer_teleport.wav");
	precache_sound("weapons/displacer_teleport_player.wav");
	precache_model("models/v_displacer.mdl");
	precache_model("models/w_displacer.mdl");
	precache_model("models/p_displacer.mdl");
	precache_model("sprites/exit1.spr");
}

void
w_displacer_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
#endif
}

string
w_displacer_wmodel(void)
{
	return "models/w_displacer.mdl";
}

string
w_displacer_pmodel(void)
{
	return "models/p_displacer.mdl";
}

string
w_displacer_deathmsg(void)
{
	return "%s was assaulted by %s's Displacer.";
}

int
w_displacer_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_uranium < 100) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 40, 100);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_displacer_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_displacer.mdl");
	Weapons_ViewAnimation(DISP_DRAW);
#endif
}

void
w_displacer_holster(void)
{
#ifdef CLIENT
	Weapons_ViewAnimation(DISP_HOLSTER);
#endif
}

void
w_displacer_teleport(entity target)
{
#ifdef SERVER
	player pl = (player)target;
	/* TODO, 250 damage */
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/displacer_teleport.wav", 1, ATTN_NORM);
	
	/* FIXME: This will teleport upon your standard spawn positions
	 * in other game modes, such as CTF (your team spawns), no clue
	 * about singleplayer */
	entity spot = Spawn_SelectRandom("info_player_deathmatch");
	setorigin(pl, spot.origin);
#endif
}

void
w_displacer_fireball(void)
{
	player pl = (player)self;

	static void displacerball_touch(void)
	{
#ifdef SERVER
		if (other.flags & FL_CLIENT) {
			w_displacer_teleport(other);
		}
		Damage_Radius(self.origin, self.owner, 250, 250 * 2.5f, TRUE, WEAPON_DISPLACER);
		sound(self, 1, "weapons/displacer_impact.wav", 1, ATTN_NORM);
#endif
		remove(self);
	}
#ifdef CLIENT
	static float displacerball_predraw(void)
	{
		
		addentity(self);
		return PREDRAW_NEXT;
	}
#endif

	Weapons_MakeVectors();
	entity ball = spawn();
	
#ifdef CLIENT
	setmodel(ball, "sprites/exit1.spr");
	ball.drawmask = MASK_ENGINE;
	ball.predraw = displacerball_predraw;
#endif

	setorigin(ball, Weapons_GetCameraPos() + (v_forward * 16));
	ball.owner = self;
	ball.velocity = v_forward * 500;
	ball.movetype = MOVETYPE_FLYMISSILE;
	ball.solid = SOLID_BBOX;
	ball.angles = vectoangles(ball.velocity);
	ball.touch = displacerball_touch;
	setsize(ball, [0,0,0], [0,0,0]);

#ifdef SERVER
	sound(pl, CHAN_WEAPON, "weapons/displacer_fire.wav", 1, ATTN_NORM);
#endif
}

void
w_displacer_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(DISP_FIRE);
		w_displacer_fireball();
		pl.a_ammo3 = 0;
		pl.w_idle_next = pl.w_attack_next = 1.0f;
		return;
	} else if (pl.a_ammo3 == 2) {
		Weapons_ViewAnimation(DISP_FIRE);
		w_displacer_teleport(pl);
		pl.a_ammo3 = 0;
		pl.w_idle_next = pl.w_attack_next = 1.0f;
		return;
	}

	int r = (float)input_sequence % 3;
	if (r == 1) {
		Weapons_ViewAnimation(DISP_IDLE1);
	} else {
		Weapons_ViewAnimation(DISP_IDLE2);
	}
	
	pl.w_idle_next = 3.0f;
}

void
w_displacer_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (pl.a_ammo2 < 20) {
		return;
	}
#else
	if (pl.ammo_uranium < 20) {
		return;
	}
#endif

	/* we're already in spinning mode */
	if (pl.a_ammo3 > 0) {
		w_displacer_release();
		return;
	}

	pl.a_ammo3 = 1;

#ifdef CLIENT
	Weapons_ViewAnimation(DISP_SPINUP);
#else
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/displacer_spin.wav", 1, ATTN_NORM);
#endif
	pl.w_idle_next = pl.w_attack_next = 1.0f;
}

void
w_displacer_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (pl.a_ammo2 < 60) {
		return;
	}
#else
	if (pl.ammo_uranium < 60) {
		return;
	}
#endif

	/* we're already in spinning mode */
	if (pl.a_ammo3 > 0) {
		w_displacer_release();
		return;
	}

	pl.a_ammo3 = 2;

#ifdef CLIENT
	Weapons_ViewAnimation(DISP_SPINUP);
#else
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/displacer_spin2.wav", 1, ATTN_NORM);
#endif
	pl.w_idle_next = pl.w_attack_next = 1.0f;
}

float
w_displacer_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_displacer_hud(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/ofch1.spr_0.tga",
		[48/72,0],
		[24/72,24/72],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[0,96/128], // was [24/256,72/128]... which makes 0 sense
		[24/256, 24/128],
		g_hud_color,
		pSeat->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	HUD_DrawAmmo2();
#endif
}

void
w_displacer_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
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
			"sprites/640hudof01.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_displacer =
{
	.id		= ITEM_DISPLACER,
	.slot		= 5,
	.slot_pos	= 1,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [48,208],
	.draw		= w_displacer_draw,
	.holster	= w_displacer_holster,
	.primary	= w_displacer_primary,
	.secondary	= w_displacer_secondary,
	.reload		= __NULL__,
	.release	= w_displacer_release,
	.crosshair	= w_displacer_hud,
	.precache	= w_displacer_precache,
	.pickup		= w_displacer_pickup,
	.updateammo	= w_displacer_updateammo,
	.wmodel		= w_displacer_wmodel,
	.pmodel		= w_displacer_pmodel,
	.deathmsg	= w_displacer_deathmsg,
	.aimanim	= w_displacer_aimanim,
	.hudpic		= w_displacer_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_displacer(void)
{
	Weapons_InitItem(WEAPON_DISPLACER);
}
#endif
