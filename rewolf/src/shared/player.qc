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
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
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
#endif
};

