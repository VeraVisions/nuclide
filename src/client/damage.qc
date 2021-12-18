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

/*
 * engine specific callback for when dmg_ fields are set on the client side.
 * might want to replace it at some point? probably not...
 * hence why 'take' is unused.
 */
float
CSQC_Parse_Damage_New(vector abs_pos, int take, int flags)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];

	/* FIXME: while a player shooting you from [0,0,0] is unlikely, it's
	 * not impossible. we only do this to lazily seperate players from
	 * entities belonging to world
	 */
	if (abs_pos) {
		pSeat->m_vecDamagePos = abs_pos;
		pSeat->m_flDamageAlpha = 1.0f;
		pSeat->m_iDamageFlags |= flags;
	}

	return (1);
}
