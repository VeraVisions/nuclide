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

#ifdef CSQC
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

	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
	virtual void() postdraw;
#else
	int ammo_battery; // beamgun
	int ammo_chem; // chemicalgun
	int ammo_rocket; // dml / grenades
	int ammo_gauss; // gauspistol
	int ammo_minigun; // minigun
	int ammo_buckshot; // shotgun

	int fist_mode; // knife/fists
	int gauss_mode;
	int shotgun_shells;
	int shotgun_spread;
	
	int dml_launch; /* when fired, when targeted */
	int dml_flightpath; /* guided, homing, spiral */
	int dml_detonate; /* on impact, in proximity, timed, when tripped */
	int dml_payload; /* explosive, cluster */

	int chem_acid;
	int chem_neutral;
	int chem_base;
	int chem_pressure;

	int beam_range; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	int beam_poweracc; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	int beam_lightning; /* BEAM, CHAIN, BALL */

	int gren_detonate; /* when tripped (tripmine), timed, on impact */
	int gren_payload; /* cluster, explosive */

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
#endif
};

