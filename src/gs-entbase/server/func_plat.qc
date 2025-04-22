/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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
	FNCPLAT_TRIGGER,
};

class
func_plat_helper:ncEntity
{
public:
	void func_plat_helper(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Touch(entity);
	nonvirtual void SetTargetPlatform(entity);

private:
	entity m_eTargetPlat;
};

/*! \brief Server-Entity: Automatic Elevator */
/*!QUAKED func_plat (0 .5 .8) ? FNCPLAT_TRIGGER
# OVERVIEW
It's a simple elevator. It goes down... and back up.

# KEYS
- "targetname" : Name
- "speed" : Speed of the lift in units per second
- "height" : Number of units the lift is supposed to move down

# SPAWNFLAGS
- FNCPLAT_TRIGGER (1) : Has to be triggered to move.

# NOTES
By default, touching the platform near its end/start point results in the platform
to be called up/down.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
func_plat:ncMoverEntity
{
public:
	void func_plat(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);

	virtual void MoverStartsMoving(void);
	virtual void MoverFinishesMoving(void);
	virtual void PlatformReturn(void);

	nonvirtual float GetPlatformHeight(void);
	nonvirtual float GetPlatformSpeed(void);

private:
	float m_platSpeed;
	float m_platHeight;
	string m_sndMove;
	string m_sndStop;
	func_plat_helper m_handler;
};

void
func_plat::func_plat(void)
{
	m_platSpeed = 100.0f;
	m_platHeight = 0.0f;
	m_handler = __NULL__;
	m_sndMove =
	m_sndStop = __NULL__;
}

float
func_plat::GetPlatformHeight(void)
{
	return (m_platHeight);
}

float
func_plat::GetPlatformSpeed(void)
{
	return (m_platSpeed);
}

void
func_plat::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_sndStop);
	precache.Sound(m_sndMove);
}

void
func_plat::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "platSpeed", m_platSpeed);
	SaveFloat(handle, "platHeight", m_platHeight);
	SaveString(handle, "sndMove", m_sndMove);
	SaveString(handle, "sndStop", m_sndStop);
	SaveEntity(handle, "handler", m_handler);
}

void
func_plat::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "platSpeed":
		m_platSpeed = ReadFloat(setValue);
		break;
	case "platHeight":
		m_platHeight = ReadFloat(setValue);
		break;
	case "sndMove":
		m_sndMove = ReadString(setValue);
		break;
	case "sndStop":
		m_sndStop = ReadString(setValue);
		break;
	case "handler":
		m_handler = (func_plat_helper)ReadEntity(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_plat::SpawnKey(string strKey, string setValue)
{
	int x = 0i;

	switch (strKey) {
	case "height":
		m_platHeight = ReadFloat(setValue);
		break;
	case "speed":
		m_platSpeed = ReadFloat(setValue);
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = ReadInt(setValue);
		m_sndMove = sprintf("func_plat.move_%i", x);
		break;
	case "stopsnd":
		x = ReadInt(setValue);
		m_sndStop = sprintf("func_plat.stop_%i", x);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_plat::MoverStartsMoving(void)
{
	if (GetMoverState() == MOVER_1TO2) {
		SetValue(1i);
	} else if (GetMoverState() == MOVER_2TO1) {
		SetValue(0i);
	}

	StartSoundDef(m_sndMove, CHAN_VOICE, true);
}

void
func_plat::PlatformReturn(void)
{
	MoveToPosition(GetMoverPosition2(), m_platSpeed);
}

void
func_plat::MoverFinishesMoving(void)
{
	/* cancel out any moving sfx */
	StopSound(CHAN_VOICE, true);
	StartSoundDef(m_sndStop, CHAN_VOICE, true);

	if (HasTargetname() == false) {
		if (GetMoverState() == MOVER_POS1) {
			ScheduleThink(PlatformReturn, 3.0);
		}
	}
}

void
func_plat::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);

	if (!m_platHeight) {
		m_platHeight = size[2] - 8;
	}

	SetMoverPosition1(GetOrigin());
	SetMoverPosition2(GetOrigin() - [0, 0, m_platHeight]);

	ClearAngles();
	ReleaseThink();

	/* only spawn the helper if it's not set to be triggered */
	if (!HasSpawnFlags(FNCPLAT_TRIGGER)) {
		if (!m_handler) {
			m_handler = spawn(func_plat_helper);
			m_handler.Spawn();
		}

		m_handler.SetTargetPlatform(this);
	}

	if (HasTargetname() == false) {
		SetOrigin(GetMoverPosition2());
		SetMoverState(MOVER_POS2);
	} else {
		SetOrigin(GetMoverPosition1());
		SetMoverState(MOVER_POS1);
	}
}

void
func_plat::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "GoUp":
		MoveToPosition(GetMoverPosition1(), m_platSpeed);
		break;
	case "GoDown":
		MoveToPosition(GetMoverPosition2(), m_platSpeed);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
func_plat::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		MoveToPosition(GetMoverPosition1(), m_platSpeed);
		break;
	case TRIG_ON:
		MoveToPosition(GetMoverPosition2(), m_platSpeed);
		break;
	default:
		MoveToReverse(m_platSpeed);
	}
}

void
func_plat_helper::func_plat_helper(void)
{
	m_eTargetPlat = __NULL__;
}

void
func_plat_helper::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "eTargetPlat", m_eTargetPlat);
}

void
func_plat_helper::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "eTargetPlat":
		m_eTargetPlat = ReadEntity(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_plat_helper::SetTargetPlatform(entity targ)
{
	func_plat targetPlat = (func_plat)targ;
	vector vecMins, vecMaxs;
	vector vecPos1, vecPos2;

	m_eTargetPlat = targ;

	vecPos1 = targetPlat.GetMoverPosition1();
	vecPos2 = targetPlat.GetMoverPosition2();
	vecMins = targetPlat.GetMins() + [25, 25, 0];
	vecMaxs = targetPlat.GetMaxs() - [25, 25, -8];
	vecMins[2] = vecMaxs[2] - (vecPos1[2] - vecPos2[2] + 8);

	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetOrigin(targetPlat.origin);
	SetSize(vecMins, vecMaxs);
	Relink();
}

void
func_plat_helper::Touch(entity eToucher)
{
	func_plat targetPlat;

	if (is.Sentient(eToucher) == false) {
		return;
	}

	targetPlat = (func_plat)m_eTargetPlat;

	if (targetPlat.IsMoving() == true) {
		return;
	}

	if (targetPlat.GetMoverState() == MOVER_POS2) {
		targetPlat.Trigger(eToucher, TRIG_OFF);
	} else {
		targetPlat.SetNextThink(1.0);
	}
}

