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

#include "NSIO.h"
#include "NSTrigger.h"
#include "NSEntity.h"
#include "NSRenderableEntity.h"
#include "NSSurfacePropEntity.h"
#include "NSBrushTrigger.h"
#include "NSPointTrigger.h"
#include "NSMonster.h"
#include "NSTalkMonster.h"

/*
============
Compatibility Layer

CBaseEntity was once the main, bloated class.
It's since been replaced by a smaller NSEntity class.

Here we have to make sure that CBaseEntity points to the
largest general purpose entity that is renderable.
============
*/
/* TODO: Throw this out */
class CBaseEntity:NSSurfacePropEntity
{
	void(void) CBaseEntity;
};

void
CBaseEntity::CBaseEntity(void)
{
	NSSurfacePropEntity::NSSurfacePropEntity();
}

class CBaseTrigger:CBaseEntity
{
	void(void) CBaseTrigger;
};

void
CBaseTrigger::CBaseTrigger(void)
{
	CBaseEntity::CBaseEntity();
}