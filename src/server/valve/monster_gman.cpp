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

/*QUAKED monster_gman (0 0.8 0.8) (-16 -16 0) (16 16 72)

G-Man

*/

enum {
	GMAN_IDLE,
	GMAN_IDLETIE,
	GMAN_IDLELOOK,
	GMAN_IDLE2,
	GMAN_OPEN,
	GMAN_STAND,
	GMAN_WALK,
	GMAN_YES,
	GMAN_NO,
	GMAN_NOBIG,
	GMAN_YESBIG,
	GMAN_LISTEN,
	GMAN_LOOKDOWN,
	GMAN_LOOKDOWN2
};

class monster_gman:CBaseMonster
{
	void() monster_gman;
	virtual void() Respawn;
};

void monster_gman::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = GMAN_IDLE;
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
}

void monster_gman::monster_gman(void)
{
	netname = "G-Man";
	model = "models/gman.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
