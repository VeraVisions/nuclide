/*
 * Copyright (c) 2022 Vera Visions LLC.
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
typedef enum
{
	EF_BRIGHTFIELD = (1<<0), /**< Cast a bright, starry field volume. */
	EF_MUZZLEFLASH = (1<<1),	/**< Cast a medium sized dynamic light. */
	EF_BRIGHTLIGHT = (1<<2),	/**< Cast a large sized dynamic light. */
	EF_DIMLIGHT = (1<<3),	/**< Cast a small sized dynamic light. */
	EF_NODRAW = (1<<4), /**< Skip rendering of the entity. Also known as EF_FLAG1 in QW */
	EF_ADDITIVE = (1<<5), /**< Render the entity additively. Also known as EF_FLAG2 in QW */
	EF_BLUE = (1<<6),	/**< Cast a blue dynamic light. */
	EF_RED = (1<<7),	/**< Cast a red dynamic light. */
	EF_UNUSED1 = (1<<8),  /**< Unused. */
	EF_FULLBRIGHT = (1<<9),	/**< Render entity without lighting. */
	EF_UNUSED2 = (1<<10),  /**< Unused. */
	EF_UNUSED3 = (1<<11),  /**< Unused. */
	EF_NOSHADOW = (1<<12), /**< Entity won't cast a shadow. */
	EF_NODEPTHTEST = (1<<13),	/**< Entity renders through walls. */
	EF_UNUSED4 = (1<<14),  /**< Unused. */
	EF_UNUSED5 = (1<<15),  /**< Unused. */
	EF_UNUSED6 = (1<<16),  /**< Unused. */
	EF_UNUSED7 = (1<<17),  /**< Unused. */
	EF_GREEN = (1<<18),	/**< Cast a green dynamic light. */
	EF_UNUSED8 = (1<<19),  /**< Unused. */
	EF_UNUSED9 = (1<<20),  /**< Unused. */
	EF_UNUSED10 = (1<<21),  /**< Unused. */
	EF_UNUSED11 = (1<<22),  /**< Unused. */
	EF_ONFIRE = (1<<23)  /**< Unused. */
} effects_t;