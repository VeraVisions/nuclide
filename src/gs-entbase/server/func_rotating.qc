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

enumflags
{
	FR_STARTON,
	FR_REVERSE,
	FR_ZAXIS,
	FR_XAXIS,
	FR_ACCDCC,
	FR_FANPAIN,
	FR_NOTSOLID,
	FR_SMALLRADIUS,
	FR_MRADIUS,
	FR_LRADIUS,
	FR_TOGGLEDIR
};

/*! \brief Server-Entity: Rotating Brush/Fan */
/*!QUAKED func_rotating (0 .5 .8) ? FR_STARTON FR_REVERSE FR_ZAXIS FR_XAXIS FR_ACCDCC FR_FANPAIN FR_NOTSOLID FR_SMALLRADIUS FR_MRADIUS FR_LRADIUS FR_TOGGLEDIR
# OVERVIEW
Rotating brush object. Useful for fans, etc.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "speed" : Speed in units per second.
- "dmg" : Damage applied to entity blocking its rotational path.

# SPAWNFLAGS
- FR_STARTON (1) : Start on.
- FR_REVERSE (2) : Spin in reverse.
- FR_ZAXIS (4) : Spin on the Z-axis.
- FR_XAXIS (8) : Spin on the X-axis.
- FR_ACCDCC (16) : Enable acceleration and de-acceleration.
- FR_FANPAIN (32) : Will damage entities that collide when turned on.
- FR_NOTSOLID (64) : Don't do collision testing against this entity.
- FR_SMALLRADIUS (128) : Fan sound will have a small playback radius.
- FR_MRADIUS (256) : Fan sound will have a medium playback radius.
- FR_LRADIUS (512) : Fan sound will have a large playback radius.
- FR_TOGGLEDIR (1024) : Reverses direction when triggered.

# NOTES
Please include an origin brush so that a pivot point will be defined.

# TRIVIA
This entity was introduced in Quake II (1997).

@ingroup serverentity
@ingroup brushentity
*/
class
func_rotating:ncRenderableEntity
{
public:
	void func_rotating(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	
	virtual void Rotate(void);
	virtual void Blocked(entity);
	virtual void Touch(entity);
	virtual void SetMovementDirection(void);

private:
	vector m_vecMoveDir;
	float m_flSpeed;
	float m_flDamage;
	float m_flDir;
};

void
func_rotating::func_rotating(void)
{
	m_vecMoveDir = [0.0f, 0.0f, 0.0f];
	m_flSpeed = 100;
	m_flDamage = 0.0f;
	m_flDir = 0.0f;
}

void
func_rotating::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flDamage", m_flDamage);
	SaveFloat(handle, "m_flDir", m_flDir);
}

void
func_rotating::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flDamage":
		m_flDamage = ReadFloat(strValue);
		break;
	case "m_flDir":
		m_flDir = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_rotating::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "dmg":
		m_flDamage = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_rotating::Respawn(void)
{
	super::Respawn();

	m_flDir = 0; /* Reset */

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(HasSpawnFlags(FR_NOTSOLID) ? SOLID_NOT : SOLID_BSP);

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (HasSpawnFlags(FR_STARTON)) {
		SetAngularVelocity(m_vecMoveDir * m_flSpeed);
		ScheduleThink(Rotate, 1.5f);
	}
}

/* TODO: Handle state */
void
func_rotating::Trigger(entity act, triggermode_t state)
{
	if (vlen(avelocity) > 0) {
		ClearVelocity();
		ReleaseThink();
	} else {
		float flSpeed;

		if (HasSpawnFlags(FR_TOGGLEDIR) && m_flDir) {
			flSpeed = m_flSpeed * -1;
		} else {
			flSpeed = m_flSpeed;
		}

		SetAngularVelocity(m_vecMoveDir * flSpeed);
		m_flDir = 1 - m_flDir;

		/* HACK HACK HACK! This is terrible, but the only way PUSH movetypes rotate */
		ScheduleThink(Rotate, 99999.0f);
	}
}

void
func_rotating::Rotate(void)
{
	SetNextThink(10.0f);
}

void
func_rotating::Blocked(entity eBlocker)
{
	if (vlen(avelocity) <= 0) {
		return;
	}

	/* this can be crushed */
	if (eBlocker.takedamage != DAMAGE_NO) {
		/* this is to work around a Q1 BSP bug. don't attempt to damage our
		 * target unless we're absolutely sure he's within the bounds of the entity */
		if (WithinBounds(eBlocker)) {
			vector center = WorldSpaceCenter();
			vector dmgDir = dirFromTarget(center, eBlocker.origin);
			ncDict damageDecl = spawn(ncDict);
			damageDecl.AddKey("damage", ftos(m_flDamage));
			combat.Damage(eBlocker, this, eBlocker, damageDecl.GetDeclBody(), center, dmgDir, eBlocker.origin);
			remove(damageDecl);
		}
	}
}

void
func_rotating::Touch(entity eToucher)
{
	if (HasSpawnFlags(FR_FANPAIN)) {
		Blocked(eToucher);
	}
}

void
func_rotating::SetMovementDirection(void)
{
	if (HasSpawnFlags(FR_ZAXIS)) {
		m_vecMoveDir = [0,0,1];
	} else if (HasSpawnFlags(FR_XAXIS)) {
		m_vecMoveDir = [1,0,0];
	} else {
		m_vecMoveDir = [0,1,0];
	}

	if (HasSpawnFlags(FR_REVERSE)) {
		m_vecMoveDir *= -1;
	}
}
