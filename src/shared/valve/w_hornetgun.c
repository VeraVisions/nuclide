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
	HORNETGUN_IDLE,
	HORNETGUN_FIDGET1,
	HORNETGUN_FIDGET2,
	HORNETGUN_HOLSTER,
	HORNETGUN_DRAW,
	HORNETGUN_SHOOT
};

void
w_hornetgun_precache(void)
{
	precache_model("models/v_hgun.mdl");
	precache_model("models/w_hgun.mdl");
	precache_model("models/p_hgun.mdl");
	precache_model("models/hornet.mdl");
	
#ifdef SSQC
	Sound_Precache("weapon_hornetgun.fire");
	Sound_Precache("weapon_hornetgun.buzz");
	Sound_Precache("weapon_hornetgun.hit");
#endif
}

int
w_hornetgun_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	/* only pick it up once */
	if (new) {
		pl.ammo_hornet = MAX_A_HORNET;
		return TRUE;
	}
#endif
	return FALSE;
}

void
w_hornetgun_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, pl.ammo_hornet, -1);
#endif
}
string w_hornetgun_wmodel(void)
{
	return "models/w_hgun.mdl";
}
string w_hornetgun_pmodel(void)
{
	return "models/p_hgun.mdl";
}
string w_hornetgun_deathmsg(void)
{
	return "";
}

void
w_hornetgun_draw(void)
{
	Weapons_SetModel("models/v_hgun.mdl");
	Weapons_ViewAnimation(HORNETGUN_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_hornet, __NULL__);
#endif
}

void
w_hornetgun_holster(void)
{
	
}

#ifdef SSQC
void
w_hornetgun_shoothornet(void)
{
	static void Hornet_Touch(void) {
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 10, WEAPON_HORNETGUN, DMG_GENERIC);
			Sound_Play(other, CHAN_VOICE, "weapon_hornetgun.hit");
		} else {
			Sound_Play(self, CHAN_VOICE, "weapon_hornetgun.buzz");
		}
		remove(self);
	}

	Weapons_MakeVectors();
	entity bolt = spawn();
	setmodel(bolt, "models/hornet.mdl");
	setorigin(bolt, Weapons_GetCameraPos() + (v_forward * 16) + (v_up * -8));
	bolt.owner = self;
	bolt.velocity = v_forward * 1000;
	bolt.movetype = MOVETYPE_FLY;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.touch = Hornet_Touch;
	bolt.traileffectnum = particleeffectnum("weapon_hornet.trail");
	setsize(bolt, [0,0,0], [0,0,0]);
}
#endif

void
w_hornetgun_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo2 < MAX_A_HORNET) {
		pl.a_ammo2 = bound(0, pl.a_ammo2 + 1, MAX_A_HORNET);
		pl.w_idle_next = 0.35f;
	}
#else
	if (pl.ammo_hornet < MAX_A_HORNET) {
		pl.ammo_hornet = bound(0, pl.ammo_hornet + 1, MAX_A_HORNET);
		Weapons_UpdateAmmo(pl, -1, pl.ammo_hornet, -1);
		pl.w_idle_next = 0.35f;
		return;
	}
#endif

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r;
	r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(HORNETGUN_FIDGET1);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(HORNETGUN_FIDGET2);
		pl.w_idle_next = 2.1875f;
		break;
	default:
		Weapons_ViewAnimation(HORNETGUN_IDLE);
		pl.w_idle_next = 1.875f;
	}
}

void
w_hornetgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		w_hornetgun_release();
		return;
	}
#else
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release();
		return;
	}
#endif


#ifdef SSQC
	w_hornetgun_shoothornet();
	Sound_Play(pl, CHAN_WEAPON, "weapon_hornetgun.fire");

	pl.ammo_hornet--;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_hornet, __NULL__);
#else
	pl.a_ammo2--;
#endif

	Weapons_ViewAnimation(HORNETGUN_SHOOT);

	pl.w_attack_next = 0.25;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		w_hornetgun_release();
		return;
	}
#else
	if (pl.ammo_hornet <= 0) {
		w_hornetgun_release();
		return;
	}
#endif

#ifdef SSQC
	pl.ammo_hornet--;
	w_hornetgun_shoothornet();
	Weapons_PlaySound(pl, CHAN_WEAPON, sprintf("agrunt/ag_fire%d.wav", floor(random(1,4))), 1, ATTN_NORM);
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_hornet, __NULL__);
#else
	pl.a_ammo2--;
#endif

	Weapons_ViewAnimation(HORNETGUN_SHOOT);

	pl.w_attack_next = 0.1;
	pl.w_idle_next = 1.0f;
}

void
w_hornetgun_crosshair(void)
{
#ifdef CSQC
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/crosshairs.spr_0.tga",
		[72/128,24/128],
		[0.1875, 0.1875],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo2();

	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/256,96/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo2_alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_hornetgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
}

void
w_hornetgun_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
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
			"sprites/640hud2.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_hornetgun =
{
	ITEM_HORNETGUN,
	3,
	3,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,144],
	w_hornetgun_draw,
	w_hornetgun_holster,
	w_hornetgun_primary,
	w_hornetgun_secondary,
	__NULL__,
	w_hornetgun_release,
	w_hornetgun_crosshair,
	w_hornetgun_precache,
	w_hornetgun_pickup,
	w_hornetgun_updateammo,
	w_hornetgun_wmodel,
	w_hornetgun_pmodel,
	w_hornetgun_deathmsg,
	w_hornetgun_aimanim,
	w_hornetgun_hudpic
};

#ifdef SSQC
void
weapon_hornetgun(void)
{
	Weapons_InitItem(WEAPON_HORNETGUN);
}
#endif
