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

/*QUAKED weapon_flashbang (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_flashbang.mdl"

COUNTER-STRIKE (1999) ENTITY

Concussion (Flashbang) Grenade Weapon

When thrown, nearby players become blinded temporarily from the blast.

- Buy Menu -
Price: $200

*/

enum
{
	FLASHBANG_IDLE,
	FLASHBANG_PULLPIN,
	FLASHBANG_THROW,
	FLASHBANG_DRAW,
};

void
w_flashbang_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_flashbang.bounce");
	Sound_Precache("weapon_flashbang.explode");
#endif
	precache_model("models/v_flashbang.mdl");
	precache_model("models/w_flashbang.mdl");
	precache_model("models/p_flashbang.mdl");
}

void
w_flashbang_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, pl.ammo_fbgrenade, pl.a_ammo3);
#endif
}

int
w_flashbang_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_fbgrenade < 3) {
		pl.ammo_fbgrenade = bound(0, pl.ammo_fbgrenade + 1, 3);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

string
w_flashbang_wmodel(void)
{
	return "models/w_flashbang.mdl";
}

string
w_flashbang_pmodel(void)
{
	return "models/p_flashbang.mdl";
}

string
w_flashbang_deathmsg(void)
{
	return "";
}

void
w_flashbang_draw(void)
{
	Weapons_SetModel("models/v_flashbang.mdl");
	Weapons_ViewAnimation(FLASHBANG_DRAW);
}

#ifdef SERVER
void w_flashbang_throw(void)
{
	static void flashbang_explode(void)
	{
		FX_Flashbang(self.origin);
		Sound_Play(self, CHAN_BODY, "weapon_flashbang.explode");
		remove(self);
	}
	
	static void flashbang_touch(void)
	{
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, WEAPON_FLASHBANG, DMG_BLUNT);
		} else {
			Sound_Play(self, CHAN_BODY, "weapon_flashbang.bounce");
		}
		self.frame = 0;
	}

	player pl = (player)self;
	vector vPLAngle = pl.v_angle;
	if (vPLAngle[0] < 0) {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 - 10) / 90.0);
	} else {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 + 10) / 90.0);
	}

	float flVel = (90 - vPLAngle[0]) * 5;
	if (flVel > 1000) {
		flVel = 1000;
	}

	makevectors(vPLAngle);
	vector vecSrc = pl.origin + pl.view_ofs + v_forward * 16;
	vector vecThrow = v_forward * flVel + pl.velocity;

	entity eGrenade = spawn();
	eGrenade.owner = pl;
	eGrenade.classname = "remove_me";
	eGrenade.solid = SOLID_BBOX;
	eGrenade.frame = 1;
	eGrenade.velocity = vecThrow;
	eGrenade.movetype = MOVETYPE_BOUNCE;
	eGrenade.think = flashbang_explode;
	eGrenade.touch = flashbang_touch;
	eGrenade.nextthink = time + 4.0f;
	setmodel(eGrenade, "models/w_flashbang.mdl");
	setsize(eGrenade, [0,0,0], [0,0,0]);
	setorigin(eGrenade, vecSrc);
}
#endif

void
w_flashbang_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.a_ammo3 > 0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_fbgrenade <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(FLASHBANG_PULLPIN);

	pl.a_ammo3 = 1;
	pl.w_attack_next = 0.975f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_flashbang_release(void)
{
	player pl = (player)self;
	
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
#ifdef CLIENT
		pl.a_ammo2--;
		Weapons_ViewAnimation(FLASHBANG_THROW);
#else
		pl.ammo_fbgrenade--;
		w_flashbang_throw();
#endif
		pl.a_ammo3 = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.a_ammo3 == 2) {
#ifdef CLIENT
		Weapons_ViewAnimation(FLASHBANG_DRAW);
#else
		if (!pl.ammo_fbgrenade) {
			Weapons_RemoveItem(pl, WEAPON_FLASHBANG);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.a_ammo3 = 0;
	}
}

float
w_flashbang_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_GRENADE : ANIM_AIM_GRENADE;
}

void
w_flashbang_hud(void)
{
#ifdef CLIENT

	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_flashbang_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud6.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud3.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_flashbang =
{
	ITEM_FLASHBANG,
	3,
	1,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,192],
	w_flashbang_draw,
	__NULL__,
	w_flashbang_primary,
	w_flashbang_release,
	w_flashbang_release,
	w_flashbang_release,
	w_flashbang_hud,
	w_flashbang_precache,
	w_flashbang_pickup,
	w_flashbang_updateammo,
	w_flashbang_wmodel,
	w_flashbang_pmodel,
	w_flashbang_deathmsg,
	w_flashbang_aimanim,
	w_flashbang_hudpic
};

#ifdef SERVER
void
weapon_flashbang(void)
{
	Weapons_InitItem(WEAPON_FLASHBANG);
}
#endif
