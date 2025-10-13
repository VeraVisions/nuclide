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

/*! \brief Server-Entity: Item Supply Crate with optional Physics */
/*!QUAKED item_item_crate (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Server-side Item Supply Crate which can also have physics.

# KEYS
- "model" : Model that represents the crate entity.
- "ItemClass" : Name of the entity class to spawn upon breaking.
- "ItemCount" : Total number of items dropped upon breaking.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
item_item_crate:ncPhysicsEntity
{
public:
	void item_item_crate(void);
	
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
};

void
item_item_crate::item_item_crate(void)
{
}

void
item_item_crate::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
item_item_crate::Respawn(void)
{
	super::Respawn();
}
