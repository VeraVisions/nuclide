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

/*QUAKED trigger_gravity (0 .5 .8) ?
"targetname"    Name
"gravity"       Gravity multiplier.

Volume that permanently adds a multiplier that affects an entities' gravity.
*/

#ifdef CSQC
class trigger_gravity:CBaseEntity
#else
class trigger_gravity:CBaseTrigger
#endif
{
	float m_flGravity;
	void() trigger_gravity;
	virtual void() touch;
	virtual void() Respawn;

#ifdef CSQC
	virtual void() Initialized;
	virtual void(string, string) SpawnKey;
#endif
};

void trigger_gravity::touch(void)
{
	other.gravity = m_flGravity;
}

/* TODO: Make this redundant */
void trigger_gravity::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_gravity::trigger_gravity(void)
{
#ifdef SSQC
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "gravity":
			m_flGravity = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
#endif
}

#ifdef CSQC
void trigger_gravity :: Initialized (void)
{
	setmodel( this, model );
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;
}
void trigger_gravity::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "gravity":
			m_flGravity = stof(strKey);
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}
#endif
