/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#ifdef SERVER
.ncTimer m_touchTimer;
#endif

void
ncTrigger::ncTrigger(void)
{
#ifdef SERVER
	m_touchTimer = __NULL__;
	m_outputOnStartTouch =
	m_outputOnEndTouch = __NULL__;
	m_globalState = __NULL__;
	m_triggerKillTarget = "";
	m_triggerMessage = __NULL__;
	m_masterName = __NULL__;
	m_triggerValue = 0i;
	m_triggerDelay = 0.0f;
	m_triggerStartsDisabled = false;
	m_triggerEnabled = true;
	m_triggerSpawnflagFilter = false;
#endif
}

#ifdef SERVER
void
ncTrigger::Spawned(void)
{
	super::Spawned();
	blocked = _BlockedHandler;
	touch = _TouchHandler;

	if (STRING_SET(m_outputOnStartTouch))
		m_outputOnStartTouch = CreateOutput(m_outputOnStartTouch);
	if (STRING_SET(m_outputOnEndTouch))
		m_outputOnEndTouch = CreateOutput(m_outputOnEndTouch);
}

bool
ncTrigger::CanBeTriggeredBy(entity testEnt)
{
	/* easy way out */
	if (spawnflags & TOUCHFILTER_EVERYTHING) {
		return true;
	}

	/* filters */
	if (!(spawnflags & TOUCHFILTER_CLIENTS) && (testEnt.flags & FL_CLIENT)) {
		return false;
	}

	if (!(spawnflags & TOUCHFILTER_NPCS) && (testEnt.flags & FL_MONSTER)) {
		return false;
	}

	if (!(spawnflags & TOUCHFILTER_PUSHABLE) && (testEnt.classname == "func_pushable")) {
		return false;
	}

	if (!(spawnflags & TOUCHFILTER_PHYSICS) && (testEnt.isPhysics == true)) {
		return false;
	}

	if (!(spawnflags & TOUCHFILTER_FRIENDLIES) && (testEnt.flags & FL_MONSTER) && (testEnt.m_iAlliance == 0)) {
		return false;
	}

	if (!(spawnflags & TOUCHFILTER_CLIENTSINVEHICLES) && (testEnt.flags & FL_CLIENT) && (testEnt.m_nuclideFlags & VFL_INVEHICLE)) {
		return false;
	}

/*

	if (!spawnflags & TOUCHFILTER_CLIENTSNOTINVEHICLES) {
		return false;
	if (!spawnflags &TRIGTELE_DEBRIS) && )
		return false;
	if (!spawnflags &TRIGTELE_NPCSINVEHICLES) && )
		return false;
	if (!spawnflags &TRIGTELE_NOBOTS) && )
		return false;
*/

	return true;
}

/* legacy trigger architecture */
void
ncTrigger::Trigger(entity act, triggermode_t state)
{
	EntWarning("%S triggered by %S with no consequence", targetname, act.classname);
}

void
ncTrigger::UseTargets(entity act, int state, float triggerDelay)
{
	static void Entities_UseTargets_Think(void) {
		ncTrigger::UseTargets(self.owner, self.health, 0.0f);
		ncTrigger::Destroy();
	}

	if (!STRING_SET(m_triggerKillTarget) && !STRING_SET(target)) {
		return;
	}

	if (triggerDelay > 0.0f) {
		EntLog("Scheduling trigger of %S in %f seconds.", target, triggerDelay);
		ncTrigger eTimer = spawn(ncTrigger);
		eTimer.netname = sprintf("%s_%d_target_trigger", classname, num_for_edict(this));
		eTimer.owner = act;
		eTimer.think = Entities_UseTargets_Think;
		eTimer.target = target;
		eTimer.nextthink = time + triggerDelay;
		eTimer.health = state;  /* ugly */

		if (STRING_SET(m_triggerKillTarget)) {
			EntLog("Will kill %S before that happens.", m_triggerKillTarget);
		}
		eTimer.m_triggerKillTarget = m_triggerKillTarget;
		eTimer.m_triggerMessage = m_triggerMessage;
	} else {
		if (STRING_SET(m_triggerMessage)) {
			env_message_single(act, m_triggerMessage);
		}

		if (STRING_SET(target) && target != targetname)
		for (entity f = world; (f = find(f, ::targetname, target));) {
			ncTrigger trigger = (ncTrigger)f;

			EntLog("Triggering %s %S, activator %S (%d)", \
			        f.classname, trigger.targetname, \
					act.classname, num_for_edict(act));

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(act, state);
			}
		}

		if (STRING_SET(m_triggerKillTarget)) {
			ncEntity eKill = (ncEntity)find(world, ::targetname, m_triggerKillTarget);
			EntLog("Killtargeting %S", m_triggerKillTarget);

			if (eKill) {
				eKill.Destroy();
			}
		}
	}
}

void
ncTrigger::SetTriggerTarget(string name)
{
	target = name;
}

void
ncTrigger::SetValue(int newValue)
{
	m_triggerValue = newValue;
}

int
ncTrigger::GetValue(entity queryingEntity)
{
	return m_triggerValue;
}

globalstate_t
ncTrigger::GetGlobalValue(string strName)
{
	string globalString = ncSessionManager::GetGlobal(strName);

	switch (globalString) {
	case "false":
	case "0":
		return (GLOBAL_OFF);
		break;
	case "dead":
	case "":
		return (GLOBAL_DEAD);
		break;
	case "1":
	case "true":
	default:
		return (GLOBAL_ON);
	}
}

int
ncTrigger::GetMaster(entity queryingEntity)
{
	ncTrigger t;

	/* default to success */
	if (!STRING_SET(m_masterName)) {
		/*ncLog("^2%s::^3GetMaster^7: No master, return success",
		classname));*/
		return (1);
	}

	t = (ncTrigger)find(world, ::targetname, m_masterName);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		/*ncLog("^2%s::^3GetMaster^7: Invalid master (%s), return success",
			classname, m_masterName);*/
		return (1);
	}

/*
	if (t.GetValue(queryingEntity) == 1)
		ncLog("^2%s::^3GetMaster^7: %s learns %s ^2POSITIVE",
			classname, targetname, m_masterName);
	else
		ncLog("^2%s::^3GetMaster^7: %s learns %s ^1NEGATIVE",
			classname, targetname, m_masterName);
*/

	return t.GetValue(queryingEntity);
}

string
ncTrigger::GetTriggerTarget(void)
{
	return (target);
}

float
ncTrigger::GetTriggerDelay(void)
{
	return (m_triggerDelay);
}

string
ncTrigger:: GetTriggerMessage(void)
{
	return (m_triggerMessage);
}

string
ncTrigger::GetTriggerKillTarget(void)
{
	return (m_triggerKillTarget);
}

entity
ncTrigger::GetTargetEntity(void)
{
	if (HasTriggerTarget() == false)
		return __NULL__;

	return find(world, ::targetname, target);
}

bool
ncTrigger::HasTriggerTarget(void)
{
	return STRING_SET(target) ? (true) : (false);
}

bool
ncTrigger::HasTargetname(void)
{
	if not (targetname)
		return false;

	return true;
}

void
ncTrigger::EnableTrigger(void)
{
	m_triggerEnabled = true;
}

void
ncTrigger::DisableTrigger(void)
{
	m_triggerEnabled = false;
}

void
ncTrigger::ToggleTrigger(void)
{
	m_triggerEnabled = true - m_triggerEnabled;
}

bool
ncTrigger::TriggerEnabled(void)
{
	return (m_triggerEnabled);
}

void
ncTrigger::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "globalState", m_globalState);
	SaveString(handle, "triggerKillTarget", m_triggerKillTarget);
	SaveString(handle, "triggerMessage", m_triggerMessage);
	SaveString(handle, "masterName", m_masterName);
	SaveInt(handle, "triggerValue", m_triggerValue);
	SaveFloat(handle, "triggerDelay", m_triggerDelay);
	SaveString(handle, "globalName", m_globalName);
	SaveBool(handle, "triggerStartsDisabled", m_triggerStartsDisabled);
	SaveBool(handle, "triggerEnabled", m_triggerEnabled);
	SaveBool(handle, "triggerSpawnflagFilter", m_triggerSpawnflagFilter);
	SaveFloat(handle, "timeSinceLastTouch", m_timeSinceLastTouch);
	SaveBool(handle, "beingTouched", m_beingTouched);
	SaveEntity(handle, "touchingEntity", m_touchingEntity);
	SaveFloat(handle, "touchingOnlyTeam", m_touchingOnlyTeam);
}
void
ncTrigger::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "globalState":
		m_globalState = ReadString(setValue);
		break;
	case "triggerKillTarget":
		m_triggerKillTarget = ReadString(setValue);
		break;
	case "triggerMessage":
		m_triggerMessage = ReadString(setValue);
		break;
	case "masterName":
		m_masterName = ReadString(setValue);
		break;
	case "triggerValue":
		m_triggerValue = ReadInt(setValue);
		break;
	case "triggerDelay":
		m_triggerDelay = ReadFloat(setValue);
		break;
	case "globalName":
		m_globalName = ReadString(setValue);
		break;
	case "triggerStartsDisabled":
		m_triggerStartsDisabled = ReadBool(setValue);
		break;
	case "triggerEnabled":
		m_triggerEnabled = ReadBool(setValue);
		break;
	case "triggerSpawnflagFilter":
		m_triggerSpawnflagFilter = ReadBool(setValue);
		break;
	case "timeSinceLastTouch":
		m_timeSinceLastTouch = ReadFloat(setValue);
		break;
	case "beingTouched":
		m_beingTouched = ReadBool(setValue);
		break;
	case "touchingEntity":
		m_touchingEntity = ReadEntity(setValue);
		break;
	case "touchingOnlyTeam":
		m_touchingOnlyTeam = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
ncTrigger::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "UseTargets":
		UseTargets(eAct, TRIG_TOGGLE, 0.0);
		break;
	case "Trigger":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "Enable":
		m_triggerEnabled = true;
		break;
	case "Disable":
		m_triggerEnabled = false;
		break;
	case "Toggle":
		m_triggerEnabled = (m_triggerEnabled) ? false : true;
		break;
	case "SetTeam":
		SetTeam(stof(strData));
		break;
	default:
		super:: Input(eAct, strInput, strData);
	}
}

void
ncTrigger::SetTeam(float new_team)
{
	team = new_team;

	/* update the InfoKey too if it's a client entity */
	if (is.Client(this)) {
		ncClient client = (ncClient)this;
		client.SetInfoKey("*team", sprintf("%d", new_team));
	}
}

float
ncTrigger::GetTeam(void)
{
	return (team);
}
#endif

void
ncTrigger::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
#ifdef SERVER
	case "killtarget":
		m_triggerKillTarget = ReadString(setValue);
		break;
	case "message":
		m_triggerMessage = ReadString(setValue);
		break;
	case "master":
		m_masterName = ReadString(setValue);
		break;
	case "m_touchingOnlyTeam":
		m_touchingOnlyTeam = ReadFloat(setValue);
		break;
	case "delay":
		m_triggerDelay = ReadFloat(setValue);
		break;
	case "globalstate":
		m_globalState = ReadString(setValue);
		break;
	case "globalname":
		m_globalName = ReadString(setValue);
		break;
	case "StartDisabled":
		m_triggerStartsDisabled = ReadBool(setValue);
		m_triggerSpawnflagFilter = true;
		break;

	case "OnStartTouch":
		m_outputOnStartTouch = PrepareOutput(m_outputOnStartTouch, setValue);
		break;
	case "OnEndTouch":
		m_outputOnEndTouch = PrepareOutput(m_outputOnEndTouch, setValue);
		break;
#endif
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncTrigger::Blocked(entity eBlocker)
{
	/* To be handled by sub-classes */
}

void
ncTrigger::_BlockedHandler(void)
{
	Blocked(other);
}

void
ncTrigger::Touch(entity eToucher)
{
	/* To be handled by sub-classes */
}

void
ncTrigger::StartTouch(entity eToucher)
{
	/* To be handled by sub-classes */
}

void
ncTrigger::EndTouch(entity eToucher)
{
	/* To be handled by sub-classes */
}

vector
ncTrigger::GetTouchPosition(void)
{
	return (m_touchPosition);
}

vector
ncTrigger::GetTouchNormal(void)
{
	return (m_touchNormal);
}

#ifdef SERVER

void
ncTrigger::_TouchEnded(void)
{
	EndTouch(m_touchingEntity);
	UseOutput(m_touchingEntity, m_outputOnEndTouch);
	m_touchingEntity = __NULL__;
	m_beingTouched = false;

	if (m_touchTimer) {
		m_touchTimer.Destroy();
		m_touchTimer = 0;
	}
}
#endif

void
ncTrigger::_TouchHandler(void)
{
	m_touchPosition = trace_endpos;
	m_touchNormal = trace_plane_normal;
	m_touchingEntity = other;

#ifdef SERVER
	if (g_grMode) {
		if (g_grMode.IsTeamplay())
		if (m_touchingOnlyTeam > 0i)
		if (m_touchingEntity.team != m_touchingOnlyTeam) {
			return;
		}
	}

	/* start touch in case we haven't */
	if (!m_touchTimer) {
		StartTouch(m_touchingEntity);
		UseOutput(m_touchingEntity, m_outputOnStartTouch);
		m_touchTimer = m_touchTimer.SetupTimer(this, _TouchEnded, 0.1f, false);
	}

	m_touchTimer.RunTimer();
#endif

	Touch(m_touchingEntity);
	m_timeSinceLastTouch = GetTime();
}
