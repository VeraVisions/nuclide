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
func_plat_helper:NSEntity
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
*/
class
func_plat:NSMoverEntity
{
public:
	void func_plat(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);

	virtual void MoverStartsMoving(void);
	virtual void MoverFinishesMoving(void);
	virtual void PlatformReturn(void);

private:
	float m_flSpeed;
	float m_flHeight;
	string m_strSndMove;
	string m_strSndStop;

	func_plat_helper m_handler;
};

void
func_plat::func_plat(void)
{
	m_flSpeed = 100.0f;
	m_flHeight = 0.0f;
	m_handler = __NULL__;
	m_strSndMove =
	m_strSndStop = __NULL__;
}

void
func_plat::Spawned(void)
{
	super::Spawned();

	if (m_strSndStop)
		Sound_Precache(m_strSndStop);
	if (m_strSndMove)
		Sound_Precache(m_strSndMove);
}

void
func_plat::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flHeight", m_flHeight);
	SaveString(handle, "m_strSndMove", m_strSndMove);
	SaveString(handle, "m_strSndStop", m_strSndStop);
	SaveEntity(handle, "m_handler", m_handler);
}

void
func_plat::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flHeight":
		m_flHeight = ReadFloat(strValue);
		break;
	case "m_strSndMove":
		m_strSndMove = ReadString(strValue);
		break;
	case "m_strSndStop":
		m_strSndStop = ReadString(strValue);
		break;
	case "m_handler":
		m_handler = (func_plat_helper)ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_plat::SpawnKey(string strKey, string strValue)
{
	int x = 0i;

	switch (strKey) {
	case "height":
		m_flHeight = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = stoi(strValue);
		m_strSndMove = sprintf("func_plat.move_%i", x);
		break;
	case "stopsnd":
		x = stoi(strValue);
		m_strSndStop = sprintf("func_plat.stop_%i", x);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_plat::MoverStartsMoving(void)
{
	if (GetMoverState() == MOVER_1TO2) {
		m_iValue = 1;
	} else if (GetMoverState() == MOVER_2TO1) {
		m_iValue = 0;
	}

	if (m_strSndMove)
		StartSoundDef(m_strSndMove, CHAN_VOICE, true);
}

void
func_plat::PlatformReturn(void)
{
	MoveToPosition(GetMoverPosition2(), m_flSpeed);
}

void
func_plat::MoverFinishesMoving(void)
{
	/* cancel out any moving sfx */
	if (m_strSndMove) {
		StartSound("common/null.wav", CHAN_VOICE, 0, true);
	}

	if (m_strSndStop) {
		StartSoundDef(m_strSndStop, CHAN_VOICE, true);
	}

	if (HasTargetname() == false) {
		if (GetMoverState() == MOVER_POS1) {
			ScheduleThink(PlatformReturn, 3.0);
		}
	}
}

void
func_plat::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());

	if (!m_flHeight) {
		m_flHeight = size[2] + 8;
	}

	SetMoverPosition1(GetOrigin());
	SetMoverPosition2(GetOrigin() - [0, 0, m_flHeight]);

	ClearAngles();
	ReleaseThink();

	/* only spawn the helper if it's not set to be triggered */
	if (!HasSpawnFlags(FNCPLAT_TRIGGER)) {
		if (!m_handler)
			m_handler = spawn(func_plat_helper);

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
func_plat::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		MoveToPosition(GetMoverPosition1(), m_flSpeed);
		break;
	case TRIG_ON:
		MoveToPosition(GetMoverPosition2(), m_flSpeed);
		break;
	default:
		MoveToReverse(m_flSpeed);
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
	SaveEntity(handle, "m_eTargetPlat", m_eTargetPlat);
}

void
func_plat_helper::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eTargetPlat":
		m_eTargetPlat = ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
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
}

void
func_plat_helper::Touch(entity eToucher)
{
	func_plat targetPlat;

	if (eToucher.movetype != MOVETYPE_WALK) {
		return;
	}

	targetPlat = (func_plat)m_eTargetPlat;

	if (targetPlat.IsMoving())
		return;

	if (targetPlat.GetMoverState() == MOVER_POS2)
		targetPlat.Trigger(eToucher, TRIG_OFF);
	else
		targetPlat.SetNextThink(1.0);
}