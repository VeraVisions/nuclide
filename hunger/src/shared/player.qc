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

int input_sequence;

class player:base_player
{
#ifdef CLIENT
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;
	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
#else
	int glock_mag;
	int ap9_mag;
	int taurus_mag;
	int mp5_mag;
	int python_mag;
	int shotgun_mag;
	int crossbow_mag;
	int sniper_mag;
	int rpg_mag;
	int chaingun_mag;
	int satchel_chg;
	
	int ammo_9mm;
	int ammo_357;
	int ammo_ap9;
	int ammo_taurus;
	int ammo_buckshot;
	int ammo_m203_grenade;
	int ammo_bolt;
	int ammo_sniper;
	int ammo_rocket;
	int ammo_uranium;
	int ammo_gas;
	int ammo_handgrenade;
	int ammo_satchel;
	int ammo_tripmine;
	int ammo_snark;
	int ammo_hornet;
	int ammo_medkit;
#endif
};

