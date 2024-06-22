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

#ifdef DEVELOPER
var int autocvar_dev_cornerspeed = 0;
#endif

enumflags
{
	PC_WAIT,
	PC_TELEPORT,
	PC_FIREONCE
};

/*! \brief Server-Entity: Train/Mover Path Node */
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

# INPUTS
- "OnPass" : Triggered when a 'train' passes over this node.

# SPAWNFLAGS
- PC_WAIT (1) : Train will stop moving once passed. Needs retrigger to progress.
- PC_TELEPORT (2) : Train passing will immediately teleport to "target".
- PC_FIREONCE (4) : Only fire its target (message) once.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup server
@ingroup pointentity
*/
class
path_corner:NSPointTrigger
{
public:
	void path_corner(void);

	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual string GetPathTarget(void);
	virtual string GetSelfTarget(void);
	virtual path_corner GetPathTargetEntity(void);
	virtual path_corner GetSelfTargetEntity(void);
	virtual bool DisablesTrain(void);

	virtual void PathPassTrigger(entity, triggermode_t);

private:
	int m_iFired;
	float m_flSpeed;
	float m_flYawSpeed;
	float m_flWait;
	string m_strOnPass;
};

void
path_corner::path_corner(void)
{
	m_iFired = 0i;
	m_flSpeed = 0.0f;
	m_flYawSpeed = 0.0f;
	m_flWait = 0.0f;
	m_strOnPass = __NULL__;
}

void
path_corner::Spawned(void)
{
	super::Spawned();

	if (m_strOnPass)
		m_strOnPass = CreateOutput(m_strOnPass);
}

string
path_corner::GetPathTarget(void)
{
	return target;
}

bool
path_corner::DisablesTrain(void)
{
	return false;
}

string
path_corner::GetSelfTarget(void)
{
	for (path_corner f = __NULL__; (f = (path_corner)find(f, ::classname, "path_corner"));) {
		if (f.GetPathTarget() == targetname) {
			return f.targetname;
		}
	}

	return __NULL__;
}

path_corner
path_corner::GetPathTargetEntity(void)
{
	string theTarget = GetPathTarget();

	for (path_corner f = __NULL__; (f = (path_corner)find(f, ::classname, "path_corner"));) {
		if (f.targetname == theTarget) {
			return f;
		}
	}

	return __NULL__;
}

path_corner
path_corner::GetSelfTargetEntity(void)
{
	for (path_corner f = __NULL__; (f = (path_corner)find(f, ::classname, "path_corner"));) {
		if (f.GetPathTarget() == targetname) {
			return f;
		}
	}

	return __NULL__;
}

void
path_corner::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iFired", m_iFired);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flYawSpeed", m_flYawSpeed);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveString(handle, "m_strOnPass", m_strOnPass);
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
	case "m_strOnPass":
		m_strOnPass = ReadString(strValue);
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
		m_flSpeed = ReadFloat(strValue);
		break;
	case "yaw_speed":
		m_flYawSpeed = ReadFloat(strValue);
		break;
	case "wait":
		m_flWait = ReadFloat(strValue);
		break;
	case "message":
		m_strMessage = ReadString(strValue);
		break;
	/* I/O system */
	case "OnPass":
		m_strOnPass = PrepareOutput(m_strOnPass, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
path_corner::Respawn(void)
{
	InitPointTrigger();

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

}

void
path_corner::PathPassTrigger(entity activatingEntity, triggermode_t triggerMode)
{
	if (HasSpawnFlags(PC_FIREONCE) && m_iFired) {
		EntLog("tried to fire more than once");
		return;
	}

	EntLog("%S (%d) has passed us.", \
		activatingEntity.classname, num_for_edict(activatingEntity));

	UseOutput(this, m_strOnPass);

	/* never trigger "" */
	if (!m_strMessage || m_strMessage == "")
		return;

	for (entity f = world; (f = find(f, ::targetname, m_strMessage));) {
		NSTrigger trigger = (NSTrigger)f;

		EntLog("Triggering %s `%s` from %s", f.classname, \
		        trigger.targetname, activatingEntity.classname);

		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(activatingEntity, triggerMode);
		}
	}
}
