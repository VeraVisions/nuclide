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

/*QUAKED func_friction (0 .5 .8) ?
Volume that permanently adds a modifier that affects an entities' friction.
Higher value = less friction.

-------- KEYS --------
"targetname" : Name
"modifier" : Friction modifier.

-------- NOTES --------
Similar to trigger_gravity in that you want to make sure the friction is reset
around the primary volume in case that's the effect that you desire.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

#ifdef CLIENT
class func_friction:CBaseEntity
#else
class func_friction:CBaseTrigger
#endif
{
	float m_flFriction;
	void(void) func_friction;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

#ifdef CLIENT
	virtual void(void) Initialized;
#endif
};

void
func_friction::touch(void)
{
	other.friction = m_flFriction;
}

/* TODO: Make this redundant */
void
func_friction::Respawn(void)
{
	solid = SOLID_BSPTRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void
func_friction::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "modifier":
		m_flFriction = stof(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

#ifdef CLIENT
void
func_friction::Initialized(void)
{
	setmodel(this, model);
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSPTRIGGER;
}
#endif

void
func_friction::func_friction(void)
{
#ifdef SERVER
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
#endif
}
