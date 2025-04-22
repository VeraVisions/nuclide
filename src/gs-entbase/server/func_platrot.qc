/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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
	FNCPLATROT_TOGGLE,
	FNCPLATROT_UNUSED1,
	FNCPLATROT_UNUSED2,
	FNCPLATROT_UNUSED3,
	FNCPLATROT_UNUSED4,
	FNCPLATROT_UNUSED5,
	FNCPLATROT_AXISX,
	FNCPLATROT_AXISY,
};

enum
{
	PLATSTATE_RAISED,
	PLATSTATE_LOWERED,
	PLATSTATE_UP,
	PLATSTATE_DOWN
};

/*! \brief Server-Entity: Rotating Vertical Platform */
/*!QUAKED func_platrot (0 .5 .8) ? TOGGLE x x x x x AXIS_X AXIS_Y
# OVERVIEW
A vertically moving platform that rotates.

# KEYS
- "targetname"     : Name
- "noise1"         : Sound when moving
- "noise2"         : Sound when stopped
- "speed"          : Speed of rotation in u/s
- "height"         : Vertical travel distance
- "rotation"       : Rotation amount, in degrees

# SPAWNFLAGS
- TOGGLE (1) : Won't respond to touch.
- AXIS_X (64) : Will rotate on the X-Axis. (Spirit of Half-Life addition)
- AXIS_Y (128) : Will rotate on the Y-Axis. (Spirit of Half-Life addition)

# NOTES
Spins.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_platrot:func_plat
{
public:
	void func_platrot(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void PlatformReturn(void);

private:
	float m_platRotation;
};

void
func_platrot::func_platrot(void)
{
	m_platRotation = 0.0f;
}

void
func_platrot::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "platRotation", m_platRotation);
}

void
func_platrot::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "platRotation":
		m_platRotation = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_platrot::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "rotation":
		m_platRotation = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_platrot::Respawn(void)
{
	super::Respawn();

	SetMoverRotation2(GetAngles());
	SetMoverRotation1([0, m_platRotation, 0]);

	if (HasTargetname() == false) {
		SetAngles(GetMoverRotation2());
	} else {
		SetAngles(GetMoverRotation1());
	}
}

void
func_platrot::PlatformReturn(void)
{
	MoveAndRotateToPosition(GetMoverPosition2(), GetMoverRotation2(), GetPlatformSpeed());
}

void
func_platrot::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		MoveAndRotateToPosition(GetMoverPosition1(), GetMoverRotation1(), GetPlatformSpeed());
		break;
	case TRIG_ON:
		MoveAndRotateToPosition(GetMoverPosition2(), GetMoverRotation2(), GetPlatformSpeed());
		break;
	default:
		if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
			MoveAndRotateToPosition(GetMoverPosition1(), GetMoverRotation1(), GetPlatformSpeed());
		} else {
			MoveAndRotateToPosition(GetMoverPosition2(), GetMoverRotation2(), GetPlatformSpeed());
		}
	}
}