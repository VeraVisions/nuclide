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

vector g_landmarkpos;

/*! \brief Server-Entity: Shared Point Between Levels */
/*!QUAKED info_landmark (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Defines a shared point between two levels. Used for level transitions, such
as the ones produced by a trigger_changelevel.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
info_landmark:ncPointTrigger
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
	ncTimer foo = __NULL__;

	static void Finalize(void) {
		string ctarg = cvar_string("_bsp_changetarget");

		if not (ctarg)
			return;

		if (ctarg == "")
			return;

		for (entity a = world; (a = find(a, ::targetname, ctarg));) {
			ncEntity t = (ncEntity)a;

			if (t.Trigger)
				t.Trigger(self, TRIG_TOGGLE);
		}

		cvar_set("_bsp_changetarget", "");
		cvar_set("_bsp_changedelay", "");
	}

	if not (ctarg)
		return;

	foo.TemporaryTimer(self, Finalize, cvar("_bsp_changedelay"), false);
}

/*! \brief Server-Entity: Triggers Level Changes */
/*!QUAKED trigger_changelevel (.5 .5 .5) ? NO_INTERMISSION TRIGGER_ONLY
# OVERVIEW
A trigger volume that initiates a level change, from one map to the next.
It can be used in combination with info_landmark and trigger_transition
to define a shared point and a transition area for entities respectively.

# KEYS
- "targetname" : Name
- "map" : Next .bsp file name to transition to.
- "landmark" : Landmark name to target.
- "changedelay" : Time in seconds until the transition happens.

# INPUTS
- "ChangeLevel" : Triggers the level to change.

# OUTPUTS
- "OnChangeLevel" : Fired when the level changes.

# SPAWNFLAGS
- NO_INTERMISSION (1) : Don't show intermission cam (unimplemented).
- TRIGGER_ONLY (2) : Can't activate through touching, only via triggers.

# NOTES
When a `landmark` is specified, you will have to position two info_landmark
entities across your two levels with the same name. They'll mark a translation
point for the coordinates in your levels.

If you have set a landmark, you might also want to restrict the area in which entities get carried across to the next level. This is accomplished by placing a trigger_transition volume with the same name as the specified `landmark`.

If you do not make use of the trigger_transition entity, it will carry over all of the entities that are in the same PVS (room and attached hallways) of the info_landmark.

The PVS-culling method can prove difficult to work with. Developers have been spotted using 'killtarget' on entities before level transitions take place to manually filter through them (Half-Life's c1a0e - c1a0c).

# TRIVIA
This entity was introduced in Quake (1996).
*/
class
trigger_changelevel:ncBrushTrigger
{
public:
	void trigger_changelevel(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);

	virtual void Change(void);
	virtual void Touch(entity);
	virtual int IsInside(entity,entity);

private:
	float m_flChangeDelay;
	string m_strChangeTarget;
	string m_strMap;
	string m_strLandmark;
	string m_outputOnLevelChange;
	entity m_activator;
};

void
trigger_changelevel::trigger_changelevel(void)
{
	m_flChangeDelay = 0.0f;
	m_strChangeTarget = __NULL__;
	m_strMap = __NULL__;
	m_strLandmark = __NULL__;
	m_outputOnLevelChange = __NULL__;
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
	SaveString(handle, "m_outputOnLevelChange", m_outputOnLevelChange);
	SaveEntity(handle, "m_activator", m_activator);
}

void
trigger_changelevel::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flChangeDelay":
		m_flChangeDelay = ReadFloat(setValue);
		break;
	case "m_strChangeTarget":
		m_strChangeTarget = ReadString(setValue);
		break;
	case "m_strMap":
		m_strMap = ReadString(setValue);
		break;
	case "m_strLandmark":
		m_strLandmark = ReadString(setValue);
		break;
	case "m_outputOnLevelChange":
		m_outputOnLevelChange = ReadString(setValue);
		break;
	case "m_activator":
		m_activator = ReadEntity(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_changelevel::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "changetarget":
		m_strChangeTarget = setValue;
		break;
	case "map":
		m_strMap = setValue;
		break;
	case "landmark":
		m_strLandmark = setValue;
		break;
	case "changedelay":
		m_flChangeDelay = stof(setValue);
		break;
	case "OnLevelChange":
	case "OnChangeLevel":
		m_outputOnLevelChange = PrepareOutput(m_outputOnLevelChange, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_changelevel::Spawned(void)
{
	super::Spawned();

	if (m_outputOnLevelChange) {
		m_outputOnLevelChange = CreateOutput(m_outputOnLevelChange);
	}
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
		 ePlayer.absmax[2] < eVolume.absmin[2]) {
		 return (0);
	}

	return (1);
}

void
trigger_changelevel::Change(void)
{
	trigger_transition transitionHelper = __NULL__;

	/* needed for logic_auto */
	cvar_set("_bsp_change_auto", "1");

	/* standard level change */
	if (!m_strLandmark) {
		EntLog("Change to %S", m_strMap);
		parm_string = m_strChangeTarget;
		changelevel(m_strMap);
		return;
	}

	if (!target) {
		UseOutput(m_activator, m_outputOnLevelChange);
	} else {
		UseTargets(m_activator, TRIG_TOGGLE, GetTriggerDelay());
	}

	/* if some other entity triggered us... just find the next player. */
	if (!(m_activator.flags & FL_CLIENT)) {
		/* we need a player if we want to use landmarks at all */
		m_activator = next.Player(world);
	}

	if (m_strLandmark) {
		for (entity e = world; (e = find(e, ::classname, "trigger_transition"));) {
			transitionHelper = (trigger_transition)e;

			if (e.targetname == m_strLandmark) {
				if (IsInside(m_activator, e) == false)
					return;
			}
		}
	}

	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark landMarkPVS = (info_landmark)e;
		/* found it */
		if (landMarkPVS.targetname == m_strLandmark) {
			EntLog("Found landmark for %S", m_strLandmark);
			g_landmarkpos = m_activator.origin - landMarkPVS.origin;

			if (transitionHelper) {
				ncSessionManager::TransitionFromVolume(transitionHelper);
			} else {
				ncSessionManager::TransitionFromPVS(landMarkPVS);
			}

			changelevel(m_strMap, m_strLandmark);
			return;
		}
	}
}

void
trigger_changelevel::Trigger(entity act, triggermode_t unused)
{
	if (GetMaster(act) == false) {
		return;
	}

	/* disable meself */
	SetSolid(SOLID_NOT);

	/* eActivator == player who triggered the damn thing */
	m_activator = act;

	cvar_set("_bsp_changetarget", m_strChangeTarget);
	cvar_set("_bsp_changedelay", ftos(m_flChangeDelay));

	Change();
}

void
trigger_changelevel::Touch(entity eToucher)
{
	if (HasSpawnFlags(LC_USEONLY)) {
		return;
	}

	if (is.Player(eToucher) == false) {
		return;
	}

	if (time < 2.0f) {
		return;
	}

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
			ncLog("^3Landmark_GetSpot^7: Found landmark for %s", startspot);
			return lm.origin + g_landmarkpos;
		}
	}

	/* return something useful at least */
	entity ips = find(world, ::classname, "info_player_start");
	ncError("Cannot find startspot %S!\n", startspot);
	return ips.origin;
}

vector
Landmark_GetPosition(void)
{
	return g_landmarkpos;
}
