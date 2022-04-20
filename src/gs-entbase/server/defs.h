/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any+
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

#include "../shared/baseentity.h"
#include "NSOutput.h"

void FX_Spark(vector, vector);
void FX_BreakModel(int, vector, vector, vector, float);

/* Backwards compat */
class CBaseMonster:NSMonster
{
	void(void) CBaseMonster;
};
void
CBaseMonster::CBaseMonster(void)
{
	super::NSMonster();
}

class CBaseNPC:NSTalkMonster
{
	void(void) CBaseNPC;
};
void
CBaseNPC::CBaseNPC(void)
{
	super::NSTalkMonster();
}

class CBasePhysics:NSPhysicsEntity
{
	void(void) CBasePhysics;
};
void
CBasePhysics::CBasePhysics(void)
{
	super::NSPhysicsEntity();
}
