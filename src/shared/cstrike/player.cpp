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
	 * effects of some bits. Such as invisibility, quad, etc. */
	int g_items; 

	float activeweapon;
	float viewzoom;
	vector view_ofs;
	float weapontime;

	/* any mods that use hooks */
	entity hook;

	/* Weapon specific */
	int usp45_mag;
	int glock18_mag;
	int deagle_mag;
	int p228_mag;
	int elites_mag;
	int fiveseven_mag;
	int m3_mag;
	int xm1014_mag;
	int mp5_mag;
	int p90_mag;
	int ump45_mag;
	int mac10_mag;
	int tmp_mag;
	int ak47_mag;
	int sg552_mag;
	int m4a1_mag;
	int aug_mag;
	int scout_mag;
	int awp_mag;
	int g3sg1_mag;
	int sg550_mag;
	int para_mag;

#ifdef CSQC
	/* External model */
	entity p_model;
	int playertype;
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
	int net_ammo1;
	int net_ammo2;
	int net_ammo3;
	int sequence;
	
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
	virtual void() postdraw;
#else
	int ammo_50ae;
	int ammo_762mm;
	int ammo_556mm;
	int ammo_556mmbox;
	int ammo_338mag;
	int ammo_9mm;
	int ammo_buckshot;
	int ammo_45acp;
	int ammo_357sig;
	int ammo_57mm;

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
	int old_viewofs;
	int old_baseframe;
	int old_frame;
	int old_a_ammo1;
	int old_a_ammo2;
	int old_a_ammo3;
#endif
};
