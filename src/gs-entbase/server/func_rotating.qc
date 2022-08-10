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

/*QUAKED func_rotating (0 .5 .8) ? FR_STARTON FR_REVERSE FR_ZAXIS FR_XAXIS FR_ACCDCC FR_FANPAIN FR_NOTSOLID FR_SMALLRADIUS FR_MRADIUS FR_LRADIUS FR_TOGGLEDIR
Rotating brush object. Useful for fans, etc.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"speed" : Speed in units per second.
"dmg" : Damage applied to entity blocking its rotational path.

-------- SPAWNFLAGS --------
FR_STARTON : Start on.
FR_REVERSE : Spin in reverse.
FR_ZAXIS : Spin on the Z-axis.
FR_XAXIS : Spin on the X-axis.
FR_ACCDCC : Enable acceleration and de-acceleration.
FR_FANPAIN : Will damage entities that collide when turned on.
FR_NOTSOLID : Don't do collision testing against this entity.
FR_SMALLRADIUS : Fan sound will have a small playback radius.
FR_MRADIUS : Fan sound will have a medium playback radius.
FR_LRADIUS : Fan sound will have a large playback radius.
FR_TOGGLEDIR : Reverses direction when triggered.

-------- NOTES --------
Please include an origin brush so that a pivot point will be defined.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

#ifdef GS_DEVELOPER
var int autocvar_dev_rotspeed = 0;
#endif

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

class
func_rotating:NSRenderableEntity
{
	vector m_vecMoveDir;
	float m_flSpeed;
	float m_flDamage;
	float m_flDir;

	void(void) func_rotating;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;

	virtual void(void) Rotate;
	virtual void(entity) Blocked;
	virtual void(entity) Touch;
	virtual void(void) SetMovementDirection;
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
#ifdef GS_DEVELOPER
	if (autocvar_dev_rotspeed != 0) {
		m_flSpeed = autocvar_dev_rotspeed;
	}
#endif

	m_flDir = 0; /* Reset */

	SetModel(GetSpawnModel());
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(HasSpawnFlags(FR_NOTSOLID) ? SOLID_NOT : SOLID_BSP);
	SetOrigin(GetSpawnOrigin());

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (HasSpawnFlags(FR_STARTON)) {
		avelocity = m_vecMoveDir * m_flSpeed;
		think = Rotate;
		nextthink = ltime + 1.5f;
	}
}

/* TODO: Handle state */
void
func_rotating::Trigger(entity act, int state)
{
	if (vlen(avelocity) > 0) {
		avelocity = [0,0,0];
		think = __NULL__;
		nextthink = 0.0f;
	} else {
		float flSpeed;

		if (HasSpawnFlags(FR_TOGGLEDIR) && m_flDir) {
			flSpeed = m_flSpeed * -1;
		} else {
			flSpeed = m_flSpeed;
		}

		avelocity = m_vecMoveDir * flSpeed;
		m_flDir = 1 - m_flDir;

		/* HACK HACK HACK! This is terrible */
		think = Rotate;
		nextthink = ltime + 99999.0f;
	}
}

void
func_rotating::Rotate(void)
{
	nextthink = ltime + 10.0f;
}

void
func_rotating::Blocked(entity eBlocker)
{
	if (vlen(avelocity) <= 0) {
		return;
	}

	if (other.takedamage == DAMAGE_YES) {
		/* this is to work around a Q1 BSP bug. don't attempt to damage our
		 * target unless we're absolutely sure he's within the bounds of the entity */
		if not (other.absmin[0] >= absmin[0] && other.absmax[0] <= absmax[0])
			return;
		if not (other.absmin[1] >= absmin[1] && other.absmax[1] <= absmax[1])
			return;
		if not (other.absmin[2] >= absmin[2] && other.absmax[2] <= absmax[2])
			return;
		Damage_Apply(other, this, m_flDamage, 0, DMG_CRUSH);
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
