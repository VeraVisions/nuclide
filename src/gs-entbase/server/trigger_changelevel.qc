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

/*!QUAKED trigger_changelevel (.5 .5 .5) ? LC_NOINTERMISSION LC_USEONLY
# OVERVIEW
When a Landmark is specified, you will have to position two info_landmark
entities across your two levels with the same name. They'll mark a translation
point for the coordinates in your levels.

# KEYS
- "targetname" : Name
- "map" : Next .bsp file name to transition to.
- "landmark" : Landmark name to target.
- "changedelay" : Time in seconds until the transition happens.

# SPAWNFLAGS
- LC_NOINTERMISSION (1) : Don't show intermission cam (unimplemented).
- LC_USEONLY (2) : Can't activate through touching, only via triggers.

# TRIVIA
This entity was introduced in Quake (1996).
*/

vector g_landmarkpos;

class
info_landmark:NSPointTrigger
{
	
};

enumflags
{
	LC_NOINTERMISSION,
	LC_USEONLY
};

void
ChangeTarget_Activate(void)
{
	string ctarg = cvar_string("_bsp_changetarget");
	NSTimer foo = __NULL__;

	static void Finalize(void) {
		string ctarg = cvar_string("_bsp_changetarget");

		if not (ctarg)
			return;

		if (ctarg == "")
			return;

		for (entity a = world; (a = find(a, ::targetname, ctarg));) {
			NSEntity t = (NSEntity)a;

			if (t.Trigger)
				t.Trigger(self, TRIG_TOGGLE);
		}

		readcmd("set _bsp_changetarget \"\"\n");
		readcmd("set _bsp_changedelay \"\"\n");
	}

	if not (ctarg)
		return;

	foo.TemporaryTimer(self, Finalize, cvar("_bsp_changedelay"), false);
}

class
trigger_changelevel:NSBrushTrigger
{
	float m_flChangeDelay;
	string m_strChangeTarget;
	string m_strMap;
	string m_strLandmark;
	string m_strOnLevelChange;
	entity m_activator;

public:
	void trigger_changelevel(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);
	
	virtual void Change(void);
	virtual void Touch(entity);
	virtual int IsInside(entity,entity);
};

void
trigger_changelevel::trigger_changelevel(void)
{
	m_flChangeDelay = 0.0f;
	m_strChangeTarget = __NULL__;
	m_strMap = __NULL__;
	m_strLandmark = __NULL__;
	m_strOnLevelChange = __NULL__;
	m_activator = __NULL__;
}

void
trigger_changelevel::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flChangeDelay", m_flChangeDelay);
	SaveString(handle, "m_strChangeTarget", m_strChangeTarget);
	SaveString(handle, "m_strMap", m_strMap);
	SaveString(handle, "m_strLandmark", m_strLandmark);
	SaveString(handle, "m_strOnLevelChange", m_strOnLevelChange);
	SaveEntity(handle, "m_activator", m_activator);
}

void
trigger_changelevel::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flChangeDelay":
		m_flChangeDelay = ReadFloat(strValue);
		break;
	case "m_strChangeTarget":
		m_strChangeTarget = ReadString(strValue);
		break;
	case "m_strMap":
		m_strMap = ReadString(strValue);
		break;
	case "m_strLandmark":
		m_strLandmark = ReadString(strValue);
		break;
	case "m_strOnLevelChange":
		m_strOnLevelChange = ReadString(strValue);
		break;
	case "m_activator":
		m_activator = ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_changelevel::RestoreComplete(void)
{
	super::RestoreComplete();
	SetSolid(SOLID_TRIGGER);
}

void
trigger_changelevel::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "changetarget":
		m_strChangeTarget = strValue;
		break;
	case "map":
		m_strMap = strValue;
		break;
	case "landmark":
		m_strLandmark = strValue;
		break;
	case "changedelay":
		m_flChangeDelay = stof(strValue);
		break;
	case "OnLevelChange":
	case "OnChangeLevel":
		m_strOnLevelChange = PrepareOutput(m_strOnLevelChange, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_changelevel::Spawned(void)
{
	super::Spawned();

	if (m_strOnLevelChange)
		m_strOnLevelChange = CreateOutput(m_strOnLevelChange);
}

void
trigger_changelevel::Respawn(void)
{
	InitBrushTrigger();
}

int
trigger_changelevel::IsInside(entity ePlayer, entity eVolume)
{
	if (ePlayer.absmin[0] > eVolume.absmax[0] ||
		 ePlayer.absmin[1] > eVolume.absmax[1] ||
		 ePlayer.absmin[2] > eVolume.absmax[2] ||
		 ePlayer.absmax[0] < eVolume.absmin[0] ||
		 ePlayer.absmax[1] < eVolume.absmin[1] ||
		 ePlayer.absmax[2] < eVolume.absmin[2])
		 return (0);
	return (1);
}

void
trigger_changelevel::Change(void)
{
	/* needed for logic_auto */
	readcmd("set _bsp_change_auto \"1\"\n");

	/* standard level change */
	if (!m_strLandmark) {
		NSLog("^2trigger_changelevel::^3Change^7: Change to `%s`", 
			m_strMap);
		parm_string = m_strChangeTarget;
		changelevel(m_strMap);
		return;
	}

	if (!target) {
		UseOutput(m_activator, m_strOnLevelChange);
	} else {
		UseTargets(m_activator, TRIG_TOGGLE, m_flDelay);
	}

	/* if some other entity triggered us... just find the next player. */
	if (!(m_activator.flags & FL_CLIENT)) {
		/* we need a player if we want to use landmarks at all */
		m_activator = find(world, ::classname, "player");
	}

	if (m_strLandmark) {
		for (entity e = world; (e = find(e, ::classname, "trigger_transition"));) { 
			if (e.targetname == m_strLandmark)
				if (IsInside(m_activator, e) == FALSE)
					return;
		}
	}

	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark lm = (info_landmark)e;
		/* found it */
		if (lm.targetname == m_strLandmark) {
			trigger_transition t;
			NSLog("^2trigger_changelevel::^3Change^7: Found landmark for %s", m_strLandmark);
			g_landmarkpos = m_activator.origin - lm.origin;

			/* time to transition */
			t = (trigger_transition)find(world, ::targetname, m_strLandmark);

			if (t) {
				t.SaveTransition();
			}

			changelevel(m_strMap, m_strLandmark);
			break;
		}
	}
}

void
trigger_changelevel::Trigger(entity act, triggermode_t unused)
{
	if (GetMaster() == FALSE)
		return;

	/* disable meself */
	SetSolid(SOLID_NOT);

	/* eActivator == player who triggered the damn thing */
	m_activator = act;

	readcmd(sprintf("set _bsp_changetarget %S\n", m_strChangeTarget));
	readcmd(sprintf("set _bsp_changedelay %f\n", m_flChangeDelay));

	Change();
}

void
trigger_changelevel::Touch(entity eToucher)
{
	if (HasSpawnFlags(LC_USEONLY))
		return;

	if (!(eToucher.flags & FL_CLIENT))
		return;

	Trigger(eToucher, TRIG_TOGGLE);
}

void
trigger_changelevel::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "ChangeLevel":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

vector
Landmark_GetSpot(void)
{
	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark lm = (info_landmark)e;
		/* found it */
		if (lm.targetname == startspot) {
			NSLog("^3Landmark_GetSpot^7: Found landmark for %s", startspot);
			return lm.origin + g_landmarkpos;
		}
	}

	/* return something useful at least */
	entity ips = find(world, ::classname, "info_player_start");
	print(sprintf("^1ERROR^7: Landmark_GetSpot: Cannot find startspot '%s'!\n",startspot));
	return ips.origin;
}

vector
Landmark_GetPosition(void)
{
	return g_landmarkpos;
}
