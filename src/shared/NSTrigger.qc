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

void
NSTrigger::NSTrigger(void)
{
	blocked = _BlockedHandler;
	touch = _TouchHandler;

#ifdef SERVER
	m_oldstrTarget = __NULL__;
	m_strGlobalState = __NULL__;
	m_strKillTarget = __NULL__;
	m_strMessage = __NULL__;
	m_strMaster = __NULL__;
	m_iUseType = 0i;
	team = 0;
	m_iValue = 0i;
	m_flDelay = 0.0f;
	m_bStartDisabled = false;
	m_bEnabled = true;
	m_bIsModern = false;
#endif
}

#ifdef SERVER
void
NSTrigger::Respawn(void)
{
	super::Respawn();
	SetTriggerTarget( m_oldstrTarget );
}

bool
NSTrigger::CanBeTriggeredBy(entity testEnt)
{
	/* easy way out */
	if (spawnflags & TOUCHFILTER_EVERYTHING)
		return true;

	/* filters */
	if (!(spawnflags & TOUCHFILTER_CLIENTS) && (testEnt.flags & FL_CLIENT))
		return false;
	if (!(spawnflags & TOUCHFILTER_NPCS) && (testEnt.flags & FL_MONSTER))
		return false;
	if (!(spawnflags & TOUCHFILTER_PUSHABLE) && (testEnt.classname == "func_pushable"))
		return false;
	if (!(spawnflags & TOUCHFILTER_PHYSICS) && (testEnt.isPhysics == true))
		return false;
	if (!(spawnflags & TOUCHFILTER_FRIENDLIES) && (testEnt.flags & FL_MONSTER) && (testEnt.m_iAlliance == 0))
		return false;
	if (!(spawnflags & TOUCHFILTER_CLIENTSINVEHICLES) && (testEnt.flags & FL_CLIENT) && (testEnt.flags & FL_INVEHICLE))
		return false;

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
NSTrigger::Trigger(entity act, triggermode_t state)
{
	EntWarning("%S triggered by %S with no consequence", targetname, act.classname);
}

void
NSTrigger::UseTargets(entity act, int state, float triggerDelay)
{
	static void Entities_UseTargets_Think(void) {
		NSTrigger::UseTargets(self.owner, self.health, 0.0f);
		remove(self);
	}

	if (!m_strKillTarget && !target)
		return;

	if (triggerDelay > 0.0f) {
		EntLog("Scheduling trigger of %S in %f seconds.", target, triggerDelay);
		NSTrigger eTimer = spawn(NSTrigger);
		eTimer.netname = sprintf("%s_%d_target_trigger", classname, num_for_edict(this));
		eTimer.owner = act;
		eTimer.think = Entities_UseTargets_Think;
		eTimer.target = target;
		eTimer.nextthink = time + triggerDelay;
		eTimer.health = state;  /* ugly */

		if (m_strKillTarget) {
			EntLog("Will kill %S before that happens.", m_strKillTarget);
		}
		eTimer.m_strKillTarget = m_strKillTarget;
		eTimer.m_strMessage = m_strMessage;
	} else {
		if (m_strMessage) {
			env_message_single(act, m_strMessage);
		}

		if (target && target != "" && target != targetname)
		for (entity f = world; (f = find(f, ::targetname, target));) {
			NSTrigger trigger = (NSTrigger)f;

			EntLog("Triggering %s %S, activator %S (%d)", \
			        f.classname, trigger.targetname, \
					act.classname, num_for_edict(act));

			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(act, state);
			}
		}

		if (m_strKillTarget && m_strKillTarget != "") {
			NSEntity eKill = (NSEntity)find(world, ::targetname, m_strKillTarget);
			EntLog("Killtargeting %S", m_strKillTarget);

			if (eKill) {
				eKill.Destroy();
			}
		}
	}
}

void
NSTrigger::SetTriggerTarget(string name)
{
	target = name;
}

int
NSTrigger::GetValue(entity queryingEntity)
{
	return m_iValue;
}

globalstate_t
NSTrigger::GetGlobalValue(string strName)
{
	for (int i = 0; i < (tokenize(cvar_string(CENVGLOBAL_CVAR))); i += 2) {
		if (argv(i) == strName) {
			return stof(argv(i+1));
		}
	}
	return (0);
}

int
NSTrigger::GetMaster(entity queryingEntity)
{
	NSTrigger t;

	/* default to success */
	if (!m_strMaster) {
		/*NSLog("^2%s::^3GetMaster^7: No master, return success", 
		classname));*/
		return (1);
	}

	t = (NSTrigger)find(world, ::targetname, m_strMaster);

	/* we couldn't find it, so let's not even bother going further */
	if (!t) {
		/*NSLog("^2%s::^3GetMaster^7: Invalid master (%s), return success", 
			classname, m_strMaster);*/
		return (1);
	}

/*
	if (t.GetValue(queryingEntity) == 1)
		NSLog("^2%s::^3GetMaster^7: %s learns %s ^2POSITIVE", 
			classname, targetname, m_strMaster);
	else
		NSLog("^2%s::^3GetMaster^7: %s learns %s ^1NEGATIVE", 
			classname, targetname, m_strMaster);
*/

	return t.GetValue(queryingEntity);
}

string
NSTrigger::GetTriggerTarget(void)
{
	return target;
}

entity
NSTrigger::GetTargetEntity(void)
{
	if (HasTriggerTarget() == false)
		return __NULL__;

	return find(world, ::targetname, target);
}

bool
NSTrigger::HasTriggerTarget(void)
{
	if not (target)
		return false;
	if (target == "")
		return false;

	return true;
}

bool
NSTrigger::HasTargetname(void)
{
	if not (targetname)
		return false;

	return true;
}

void
NSTrigger::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_oldstrTarget", m_oldstrTarget);
	SaveString(handle, "m_strGlobalState", m_strGlobalState);
	SaveString(handle, "m_strKillTarget", m_strKillTarget);
	SaveString(handle, "m_strMessage", m_strMessage);
	SaveString(handle, "m_strMaster", m_strMaster);
	SaveInt(handle, "m_iUseType", m_iUseType);
	SaveFloat(handle, "team", team);
	SaveInt(handle, "m_iValue", m_iValue);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveString(handle, "m_strGlobalName", m_strGlobalName);
	SaveBool(handle, "m_bStartDisabled", m_bStartDisabled);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveBool(handle, "m_bIsModern", m_bIsModern);
}
void
NSTrigger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_oldstrTarget":
		m_oldstrTarget = ReadString(strValue);
		break;
	case "m_strGlobalState":
		m_strGlobalState = ReadString(strValue);
		break;
	case "m_strKillTarget":
		m_strKillTarget = ReadString(strValue);
		break;
	case "m_strMessage":
		m_strMessage = ReadString(strValue);
		break;
	case "m_strMaster":
		m_strMaster = ReadString(strValue);
		break;
	case "m_iUseType":
		m_iUseType = ReadInt(strValue);
		break;
	case "team":
		team = ReadFloat(strValue);
		break;
	case "m_iValue":
		m_iValue = ReadInt(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_strGlobalName":
		m_strGlobalName = ReadString(strValue);
		break;
	case "m_bStartDisabled":
		m_bStartDisabled = ReadBool(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	case "m_bIsModern":
		m_bIsModern = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSTrigger::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Trigger":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "Enable":
		m_bEnabled = true;
		break;
	case "Disable":
		m_bEnabled = false;
		break;
	case "Toggle":
		m_bEnabled = (m_bEnabled) ? false : true;
		break;
	default:
		super:: Input(eAct, strInput, strData);
	}
}

void
NSTrigger::SetTeam(float new_team)
{
	team = new_team;

	/* update the InfoKey too if it's a client entity */
	if (flags & FL_CLIENT) {
		NSClient client = (NSClient)this;
		client.SetInfoKey("*team", sprintf("%d", new_team));
	}
}

float
NSTrigger::GetTeam(void)
{
	return (team);
}
#endif

void
NSTrigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
#ifdef SERVER
	case "killtarget":
		m_strKillTarget = ReadString(strValue);
		break;
	case "message":
		m_strMessage = ReadString(strValue);
		break;
	case "master":
		m_strMaster = ReadString(strValue);
		break;
	case "team_no":
		team_no = ReadFloat(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "globalstate":
		m_strGlobalState = ReadString(strValue);
		break;
	case "globalname":
		m_strGlobalName = ReadString(strValue);
		break;
	case "StartDisabled":
		m_bStartDisabled = ReadBool(strValue);
		m_bIsModern = true;
		break;
#endif
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSTrigger::Blocked(entity eBlocker)
{
	/* To be handled by sub-classes */
}

void
NSTrigger::_BlockedHandler(void)
{
	Blocked(other);
}

void
NSTrigger::Touch(entity eToucher)
{
	/* To be handled by sub-classes */
}

void
NSTrigger::StartTouch(entity eToucher)
{
	/* To be handled by sub-classes */
}

void
NSTrigger::EndTouch(entity eToucher)
{
	/* To be handled by sub-classes */
}

void
NSTrigger::_TouchHandler(void)
{
#ifdef SERVER
	if (g_grMode.IsTeamplay())
	if (team_no > 0i)
	if (other.team != team_no) {
		return;
	}
#endif


	/* start touch in case we haven't */
	if (m_beingTouched != true)
		StartTouch(other);

	Touch(other);

	m_flTouchTime = GetTime();
	m_beingTouched = true;
	m_eTouchLast = other;
}
