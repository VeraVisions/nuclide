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

noref int input_sequence;
class player:base_player
{
	int cs_shotmultiplier;
	float cs_shottime;
	int ingame;

#ifdef CLIENT
	/* External model */
	entity p_model;
	int playertype;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;

	int cs_cross_mindist;
	int cs_cross_deltadist;
	int cs_old_shotmultiplier;
	float cs_crosshairdistance;

	int net_cs_shotmultiplier;
	float net_cs_shottime;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
#else
	int charmodel;
	int money;
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
	int ammo_hegrenade;
	int ammo_fbgrenade;
	int ammo_smokegrenade;

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

	int mode_usp45;
	int mode_m4a1;
	int mode_glock18;

	int old_cs_shotmultiplier;
	float old_cs_shottime;
#endif
};
