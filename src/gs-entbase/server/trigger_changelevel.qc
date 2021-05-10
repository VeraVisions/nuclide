/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED trigger_changelevel (0 .5 .8) ? LC_NOINTERMISSION LC_USEONLY
"targetname"    Name
"map"           Next .bsp file name to transition to.
"landmark"      Landmark name to target.
"changedelay"   Time in seconds until the transition happens.

When a Landmark is specified, you will have to position two info_landmark
entities across your two levels with the same name. They'll mark a translation
point for the coordinates in your levels.

When LC_NOINTERMISSION is set, there'll be no stats screen at the end of the
level.

When LC_USEONLY is set, it will not act as a trigger volume people can step in.
It'll have to be triggered by another entity.

Trivia:
This entity was introduced in Quake (1996).
*/

vector g_landmarkpos;

class info_landmark:CBaseTrigger
{
	
};

enumflags
{
	LC_NOINTERMISSION,
	LC_USEONLY
};

class trigger_changelevel:CBaseTrigger
{
	string m_strMap;
	string m_strLandmark;
	float m_flChangeDelay;
	entity m_activator;

	string m_strOnLevelChange;

	void(void) trigger_changelevel;
	virtual void(void) Change;
	virtual void(entity, int) Trigger;
	virtual void(void) TouchTrigger;
	virtual void(void) Respawn;
	virtual int(entity, entity) IsInside;
	virtual void(entity, string, string) Input;
	virtual void(string, string) SpawnKey;
};

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
	/* standard level change */
	if (!m_strLandmark) {
		dprint(sprintf("^2trigger_changelevel::^3Change^7: Change to `%s`\n", 
			m_strMap));
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

	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark lm = (info_landmark)e;
		/* found it */
		if (lm.targetname == m_strLandmark) {
			dprint(sprintf("^2trigger_changelevel::^3Change^7: Found landmark for %s\n", m_strLandmark));
			g_landmarkpos = m_activator.origin - lm.origin;
			changelevel(m_strMap, m_strLandmark);
			break;
		}
	}
}

void
trigger_changelevel::Trigger(entity act, int unused)
{
	if (GetMaster() == FALSE)
		return;

	/* disable meself */
	SetSolid(SOLID_NOT);

	/* eActivator == player who triggered the damn thing */
	m_activator = act;

	if (m_flChangeDelay) {
		dprint(sprintf("^2trigger_changelevel::^3Trigger^7: Delayed change to `%s` in %d sec/s\n", m_strMap, m_flChangeDelay));
		think = Change;
		nextthink = time + m_flChangeDelay;
	} else {
		dprint(sprintf("^2trigger_changelevel::^3Trigger^7: Change to `%s` requested\n", m_strMap));
		Change();
	}
}

void
trigger_changelevel::TouchTrigger(void)
{
	if (!(other.flags & FL_CLIENT))
		return;

	Trigger(other, TRIG_TOGGLE);
}

void
trigger_changelevel::Respawn(void)
{
	InitBrushTrigger();

	if (!(spawnflags & LC_USEONLY)) {
		touch = TouchTrigger;
	}
}

void
trigger_changelevel::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "ChangeLevel":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		CBaseTrigger::Input(eAct, strInput, strData);
	}
}

void
trigger_changelevel::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
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
		strValue = strreplace(",", ",_", strValue);
		m_strOnLevelChange = strcat(m_strOnLevelChange, ",_", strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_changelevel::trigger_changelevel(void)
{
	CBaseTrigger::CBaseTrigger();

	if (m_strOnLevelChange)
		m_strOnLevelChange = CreateOutput(m_strOnLevelChange);
}

vector
Landmark_GetSpot(void)
{
	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark lm = (info_landmark)e;
		/* found it */
		if (lm.targetname == startspot) {
			dprint(sprintf("^3Landmark_GetSpot^7: Found landmark for %s\n", startspot));
			return lm.origin + g_landmarkpos;
		}
	}

	/* return something useful at least */
	entity ips = find(world, ::classname, "info_player_start");
	print(sprintf("^1ERROR^7: Landmark_GetSpot: Cannot find startspot '%s'!\n",startspot));
	return ips.origin;
}
