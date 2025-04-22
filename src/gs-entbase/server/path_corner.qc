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

@ingroup serverentity
@ingroup pointentity
*/
class
path_corner:ncPointTrigger
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

	nonvirtual float DesiredTrainSpeed(void);
	nonvirtual float DesiredTrainYawSpeed(void);
	nonvirtual float DesiredWaitTime(void);

private:
	bool m_pathTriggeredTargets;
	float m_trainSpeed;
	float m_trainYawSpeed;
	float m_waitUntilNodeChange;
	string m_outputOnPass;
	string m_triggerWhenPassed;
};

void
path_corner::path_corner(void)
{
	m_pathTriggeredTargets = false;
	m_trainSpeed = 0.0f;
	m_trainYawSpeed = 0.0f;
	m_waitUntilNodeChange = 0.0f;
	m_outputOnPass = __NULL__;
}

float
path_corner::DesiredTrainSpeed(void)
{
	return (m_trainSpeed);
}

float
path_corner::DesiredTrainYawSpeed(void)
{
	return (m_trainYawSpeed);
}


float
path_corner::DesiredWaitTime(void)
{
	return (m_waitUntilNodeChange);
}


void
path_corner::Spawned(void)
{
	super::Spawned();

	if (STRING_SET(m_outputOnPass))
		m_outputOnPass = CreateOutput(m_outputOnPass);
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
	SaveBool(handle, "m_pathTriggeredTargets", m_pathTriggeredTargets);
	SaveFloat(handle, "m_trainSpeed", m_trainSpeed);
	SaveFloat(handle, "m_trainYawSpeed", m_trainYawSpeed);
	SaveFloat(handle, "m_waitUntilNodeChange", m_waitUntilNodeChange);
	SaveString(handle, "m_outputOnPass", m_outputOnPass);
	SaveString(handle, "m_triggerWhenPassed", m_triggerWhenPassed);
}

void
path_corner::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_pathTriggeredTargets":
		m_pathTriggeredTargets = ReadBool(setValue);
		break;
	case "m_trainSpeed":
		m_trainSpeed = ReadFloat(setValue);
		break;
	case "m_trainYawSpeed":
		m_trainYawSpeed = ReadFloat(setValue);
		break;
	case "m_waitUntilNodeChange":
		m_waitUntilNodeChange = ReadFloat(setValue);
		break;
	case "m_outputOnPass":
		m_outputOnPass = ReadString(setValue);
		break;
	case "m_triggerWhenPassed":
		m_triggerWhenPassed = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
path_corner::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "speed":
		m_trainSpeed = ReadFloat(setValue);
		break;
	case "yaw_speed":
		m_trainYawSpeed = ReadFloat(setValue);
		break;
	case "wait":
		m_waitUntilNodeChange = ReadFloat(setValue);
		break;
	case "message":
		m_triggerWhenPassed = ReadString(setValue);
		break;
	/* I/O system */
	case "OnPass":
		m_outputOnPass = PrepareOutput(m_outputOnPass, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
path_corner::Respawn(void)
{
	InitPointTrigger();

#ifdef DEVELOPER
	if (autocvar_dev_cornerspeed != 0) {
		m_trainSpeed = autocvar_dev_cornerspeed;
	}
#endif

	m_pathTriggeredTargets = false;
}

void
path_corner::Trigger(entity act, triggermode_t state)
{

}

void
path_corner::PathPassTrigger(entity activatingEntity, triggermode_t triggerMode)
{
	if (HasSpawnFlags(PC_FIREONCE) && m_pathTriggeredTargets) {
		EntLog("tried to fire more than once");
		return;
	}

	EntLog("%S (%d) has passed us.", \
		activatingEntity.classname, num_for_edict(activatingEntity));

	UseOutput(this, m_outputOnPass);
	m_pathTriggeredTargets = true;

	/* never trigger "" */
	if (!STRING_SET(m_triggerWhenPassed)) {
		return;
	}

	for (entity f = world; (f = find(f, ::targetname, m_triggerWhenPassed));) {
		ncTrigger trigger = (ncTrigger)f;

		EntLog("Triggering %s `%s` from %s", f.classname, \
		        trigger.targetname, activatingEntity.classname);

		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(activatingEntity, triggerMode);
		}
	}
}
