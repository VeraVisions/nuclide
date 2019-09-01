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

class player
{
	entity p_model;
	int p_hand_bone;
	int p_model_bone;

	vector netorigin;
	vector netvelocity;
	float netflags;
	float netjumptime;
	float netteleport_time;
	
	float activeweapon;
	float weapons;
	float lastweapon;

	float health;
	float armor;
	float pitch;
	float viewzoom;
	float weapontime;
	
	vector view_ofs;

#ifdef CSQC
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
#endif
};
