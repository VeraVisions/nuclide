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

/*! \brief Server-Entity: Non-Solid Detail Geometry */
/*!QUAKED func_detail_illusionary (0 .5 .8) ?
# OVERVIEW
A "fake" entity for level editors.
It is almost identical to func_detail except that it has no collision.
Think of it as an alternative to func_illusionary and nonsolid surfaceparms,
except that it does not use an entity slot or require custom materials.

# KEYS
- "_rs" : Specifies if the geometry will recieve shadows (RAD lighting).
- "_cs" : Specifies if the geometry will cast shadows (RAD lighting).

# NOTES
If you want this entity to have collision, consider using func_detail.

# TRIVIA
This entity was introduced in ericw-tools (2017).

@ingroup serverentity
@ingroup brushentity
*/
class
func_detail_illusionary:info_null
{
public:
	void func_detail_illusionary(void);
};

void
func_detail_illusionary::func_detail_illusionary(void)
{
}