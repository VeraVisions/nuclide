/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
*/

vector g_landmarkpos;

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

	void() trigger_changelevel;
	virtual void() Change;
	virtual void() Trigger;
	virtual void() Respawn;
	virtual int(entity, entity) IsInside;
};

int trigger_changelevel::IsInside(entity ePlayer, entity eVolume)
{
	if (ePlayer.absmin[0] > eVolume.absmax[0] ||
		 ePlayer.absmin[1] > eVolume.absmax[1] ||
		 ePlayer.absmin[2] > eVolume.absmax[2] ||
		 ePlayer.absmax[0] < eVolume.absmin[0] ||
		 ePlayer.absmax[1] < eVolume.absmin[1] ||
		 ePlayer.absmax[2] < eVolume.absmin[2])
		 return FALSE;
	return TRUE;
}

void trigger_changelevel::Change(void)
{
	if (m_strLandmark) {
		entity landmark = find(world, CBaseTrigger::m_strTargetName, m_strLandmark);
		g_landmarkpos = m_activator.origin - landmark.origin;
#ifdef GS_DEVELOPER
		print( sprintf( "%s::Change: Change to `%s` using landmark '%s'\n", 
			this.classname, m_strMap, m_strLandmark ) );
#endif
		changelevel(m_strMap, m_strLandmark);
	} else {
#ifdef GS_DEVELOPER
		print( sprintf( "%s::Change: Change to `%s`\n", 
			this.classname, m_strMap ) );
#endif
		changelevel(m_strMap);
	}
}

void trigger_changelevel::Trigger(void)
{
	if (time < 5) {
		return;
	}

	/*eVolume = find(world, ::targetname, m_strLandmark);
	if (eVolume && eVolume.classname == "CTriggerVolume") {
		if (IsInside(other, eVolume) == FALSE) {
			return;
		}
	}*/

	m_activator = other;
	if (m_flChangeDelay) {
#ifdef GS_DEVELOPER
		print( sprintf( "%s::Trigger: Delayed change to `%s` in %d sec/s\n", 
			this.classname, m_strMap, m_flChangeDelay ) );
#endif
		think = Change;
		nextthink = time + m_flChangeDelay;
	} else {
#ifdef GS_DEVELOPER
		print( sprintf( "%s::Trigger: Change to `%s`\n", 
			this.classname, m_strMap ) );
#endif
		Change();
	}
}

void trigger_changelevel::Respawn(void)
{
	if (!(spawnflags & LC_USEONLY)) {
		touch = Trigger;
	}
}

void trigger_changelevel::trigger_changelevel(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "map":
			m_strMap = argv(i+1);
			break;
		case "landmark":
			m_strLandmark = argv(i+1);
			break;
		case "changedelay":
			m_flChangeDelay = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
}

vector Landmark_GetSpot(void)
{
	entity landmark = find(world, CBaseTrigger::m_strTargetName, startspot);

	if (!landmark) {
		print(sprintf("^1ERROR^7: Landmark_GetSpot: Cannot find startspot '%s'!\n",startspot));
		/* return something useful? */
		landmark = find(world, ::classname, "info_player_start");
		return landmark.origin;
	}

	return landmark.origin + g_landmarkpos;
}

class info_landmark:CBaseTrigger
{
	
};
