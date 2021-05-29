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

enum
{
	AUTO_FIRE_FAILED,
	AUTO_FIRED,
	AUTO_LAST,
	AUTO_EMPTY
};

int
w_baseauto_fire(int w, .int mag, int d, vector bs)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return (AUTO_FIRE_FAILED);
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		return (AUTO_FIRE_FAILED);
	}
	if (pl.(mag) <= 0) {
		pl.gflags |= GF_SEMI_TOGGLED;
		return (AUTO_EMPTY);
	}

	pl.(mag)--;

#ifdef SERVER
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, d, bs, w);
#endif

	if (pl.(mag) == 0)
		return (AUTO_LAST);
	else
		return (AUTO_FIRED);
}
