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
class player:CBaseEntity
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
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	int g_items; 

	float activeweapon;
	float viewzoom;
	vector punchangle;
	vector view_ofs;
	float weapontime;

	/* any mods that use hooks */
	entity hook;

	/* Weapon specific */
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

#ifdef CLIENT
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;

	/* Prediction */
	vector net_origin;
	vector net_velocity;
	float net_flags;
	float net_w_attack_next;
	float net_w_idle_next;
	float net_jumptime;
	float net_teleport_time;
	float net_weapontime;
	float net_viewzoom;
	vector net_punchangle;
	int net_ammo1;
	int net_ammo2;
	int net_ammo3;
	int sequence;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
#else
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

	/* conditional networking */
	int old_modelindex;
	vector old_origin;
	vector old_angles;
	vector old_velocity;
	int old_flags;
	int old_activeweapon;
	int old_items;
	int old_health;
	int old_armor;
	int old_movetype;
	float old_viewofs;
	int old_baseframe;
	int old_frame;
	int old_a_ammo1;
	int old_a_ammo2;
	int old_a_ammo3;
	int voted;
#endif
};

