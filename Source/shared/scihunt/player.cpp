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

int input_sequence;
class player
{
	float health;
	float armor;

	/* When the weapon is done firing */
	float w_attack_next;
	/* When to play the next idle animation */ 
	float w_idle_next;

	/* Magazine/Clip */
	int a_ammo1;
	/* Rest in the inventory */
	int a_ammo2;
	/* Special ammo */
	int a_ammo3;

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. */
	int g_items; 

	float activeweapon;
	float viewzoom;
	vector view_ofs;
	float weapontime;

	/* Weapon specific */
	int glock_mag;
	int mp5_mag;
	int python_mag;
	int shotgun_mag;
	int crossbow_mag;
	int rpg_mag;
	int satchel_chg;
	int cannon_mag;

#ifdef CSQC
	/* External model */
	entity p_model;
	int playertype;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;

	/* Prediction */
	vector netorigin;
	vector netvelocity;
	float netflags;
	float net_w_attack_next;
	float net_w_idle_next;
	float net_weapontime;
	float netjumptime;
	float netteleport_time;
	int net_ammo1;
    int net_ammo2;
    int net_ammo3;
	int sequence;
	
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
	virtual void() postdraw;
#else
	int ammo_9mm;
	int ammo_357;
	int ammo_buckshot;
	int ammo_m203_grenade;
	int ammo_bolt;
	int ammo_rocket;
	int ammo_uranium;
	int ammo_handgrenade;
	int ammo_satchel;
	int ammo_tripmine;
	int ammo_snark;
	int ammo_hornet;
#endif
};
