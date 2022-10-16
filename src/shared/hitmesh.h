/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/** Hitmesh types that models can support. You can figure those
out on any model as long as you cast a traceline with the MOVE_HITMODEL
flag. The result will be stored inside the global `trace_surface_id`. */
typedef enum
{
	BODY_DEFAULT, /**< No specific body part. */
	BODY_HEAD,		/**< trace hit the head */
	BODY_CHEST,		/**< trace hit the chest */
	BODY_STOMACH,	/**< trace hit the stomach */
	BODY_ARMLEFT,	/**< trace hit the left arm */
	BODY_ARMRIGHT,	/**< trace hit the right arm */
	BODY_LEGLEFT,	/**< trace hit the left leg */
	BODY_LEGRIGHT	/**< trace hit the right leg */
} bodyType_t;
