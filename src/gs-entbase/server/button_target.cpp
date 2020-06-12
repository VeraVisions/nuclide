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

/*QUAKED button_target (0 .5 .8) ? BUTTA_USE BUTTA_TEXON
"targetname"    Name
"target"        Target when triggered.

Non-moving button that can either be used by hand, or shot.

If BUTTA_USE is set, the button becomes 'use' only and the players
have to interact with it manually instead of shooting it.

If BUTTA_TEXON is set, the texture choices will be inverted in case
multiple frames exist.
*/

enumflags
{
	BUTTA_USE,
	BUTTA_TEXON
};

class button_target:CBaseTrigger
{
	void(void) button_target;

	virtual void(void) Respawn;
	virtual void(void) Trigger;
	virtual void(int) Damage;
};

void
button_target::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	/* it's either one or the other */
	if (spawnflags & BUTTA_USE) {
		PlayerUse = Trigger;
	} else {
		health = 1;
		takedamage = DAMAGE_YES;
		Pain = Death = Damage;
	}

	/* purely cosmetic */
	frame = (spawnflags & BUTTA_TEXON) ? 1 : 0;
}

void
button_target::Trigger(void)
{
	/* make unusable */
	PlayerUse = __NULL__;
	takedamage = DAMAGE_NO;

	frame = 1 - frame;
	UseTargets();
}

void
button_target::Damage(int hit)
{
	Trigger();
}

void
button_target::button_target(void)
{
	CBaseTrigger::CBaseTrigger();
}
