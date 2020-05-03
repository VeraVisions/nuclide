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

	/* Weapon specific */

#ifdef CLIENT
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
#else
	int ammo_nail;
	int ammo_buckshot;
	int ammo_bolts;
	int ammo_xencandy;
	int ammo_satchel;

	int bradnailer_mag;
	int nailgun_mag;
	int shotgun_mag;
	int cmlwbr_mag;
	int xs_mag;
	int satchel_chg;
#endif
};

