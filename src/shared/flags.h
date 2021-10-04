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

/* engine reserved */
#define FL_FLY			(1<<0)
#define FL_SWIM			(1<<1)
#define FL_GLIMPSE		(1<<2)
#define FL_CLIENT		(1<<3)
#define FL_INWATER		(1<<4)
#define FL_MONSTER		(1<<5)
#define FL_GODMODE		(1<<6)
#define FL_NOTARGET		(1<<7)
#define FL_ITEM			(1<<8)
#define FL_ONGROUND		(1<<9)
#define FL_PARTIALGROUND	(1<<10)
#define FL_WATERJUMP		(1<<11)
#define FL_JUMPRELEASED		(1<<12)
#define FL_FINDABLE_NONSOLID	(1<<14)
#define FLQW_LAGGEDMOVE		(1<<16)

/* nuclide */
#define FL_ONLADDER		(1<<13)
#define FL_CROUCHING		(1<<17)
#define FL_INVEHICLE		(1<<18)
#define FL_FROZEN		(1<<19)
#define FL_USE_RELEASED		(1<<20)
#define FL_NOATTACK		(1<<21)
#define FL_ONUSABLE		(1<<22)
#define FL_ONFIRE		(1<<23)
#define FL_RESERVED3		(1<<15)
