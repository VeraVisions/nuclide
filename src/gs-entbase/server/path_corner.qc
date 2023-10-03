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

/*!QUAKED path_corner (.5 .3 0) (-8 -8 -8) (8 8 8) PC_WAIT PC_TELEPORT PC_FIREONCE
# OVERVIEW
Node entities used for func_trains and func_guntargets.

# KEYS
- "targetname" : Name
- "target" : Next node.
- "message" : Target to trigger when a train passes this node.
- "speed" : New speed for passing train.
- "yaw_speed" : New yaw rotation for passing train. Currently unused.
- "wait" : Waiting time until we go to the next node.

# SPAWNFLAGS
- PC_WAIT (1) : Train will stop moving once passed. Needs retrigger to progress.
- PC_TELEPORT (2) : Train passing will immediately teleport to "target".
- PC_FIREONCE (4) : Only fire its target (message) once.

# TRIVIA
This entity was introduced in Quake (1996).
*/

#ifdef DEVELOPER
var int autocvar_dev_cornerspeed = 0;
#endif

enumflags
{
	PC_WAIT,
	PC_TELEPORT,
	PC_FIREONCE
};

class
path_corner:NSPointTrigger
{
public:
	void path_corner(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);

private:
	int m_iFired;
	float m_flSpeed;
	float m_flYawSpeed;
	float m_flWait;
};

void
path_corner::path_corner(void)
{
	m_iFired = 0i;
	m_flSpeed = 100.0f;
	m_flYawSpeed = 0.0f;
	m_flWait = 1.0f;
}

void
path_corner::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iFired", m_iFired);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flYawSpeed", m_flYawSpeed);
	SaveFloat(handle, "m_flWait", m_flWait);
}

void
path_corner::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iFired":
		m_iFired = ReadInt(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flYawSpeed":
		m_flYawSpeed = ReadFloat(strValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
path_corner::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "yaw_speed":
		m_flYawSpeed = stof(strValue);
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "message":
		m_strMessage = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
path_corner::Respawn(void)
{
#ifdef DEVELOPER
	if (autocvar_dev_cornerspeed != 0) {
		m_flSpeed = autocvar_dev_cornerspeed;
	}
#endif

	m_iFired = FALSE;
}

void
path_corner::Trigger(entity act, triggermode_t state)
{
	entity a;

	if (HasSpawnFlags(PC_FIREONCE) && m_iFired) {
		NSLog("path_corner (%s) can only fire its targets once", targetname);
		return;
	}

	if (m_strMessage)
	for (a = world; (a = find(a, ::targetname, m_strMessage));) {
		NSEntity trigger = (NSEntity)a;
		trigger.Trigger(act, state);
		m_iFired = TRUE;
		NSLog("path_corner (%s) fired its %S targets", targetname, m_strMessage);
	}
}
