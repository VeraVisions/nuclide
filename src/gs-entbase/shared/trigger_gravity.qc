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
Volume that will, when an entity enters it, permanently alters how it
experiences gravity.

-------- KEYS --------
"targetname" : Name
"gravity" : Gravity multiplier.

-------- NOTES --------
Entities leaving the volume will NOT lose the gravity modifier.
If you don't desire this behaviour, then make sure a trigger_gravity with a
modifier value of "1.0" surrounds the aforementioned volume so it can reset itself.
Other than that gravity will naturally reset when the entity respawns.

-------- TRIVIA --------
This entity was introduced in Quake II (1997).
*/

#ifdef CLIENT
class trigger_gravity:CBaseEntity
#else
class trigger_gravity:CBaseTrigger
#endif
{
	float m_flGravity;

	void(void) trigger_gravity;
	virtual void(void) touch;
	virtual void(string, string) SpawnKey;

#ifdef CLIENT
	virtual void(void) Initialized;
#endif
};

void
trigger_gravity::touch(void)
{
	other.gravity = m_flGravity;
}

void
trigger_gravity::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "gravity":
		m_flGravity = stof(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void
trigger_gravity::trigger_gravity(void)
{
#ifdef SERVER
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
	SetSolid(SOLID_BSPTRIGGER);
#endif
}

#ifdef CLIENT
void
trigger_gravity::Initialized(void)
{
	setmodel(this, model);
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSPTRIGGER;
}
#endif
