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
		info_landmark landmark;

		/* a trigger_transition may share the same targetname, thus we do this */
		for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
			info_landmark lm = (info_landmark)e;
			/* found it */
			if (lm.m_strTargetName == m_strLandmark) {
				dprint(sprintf("^2trigger_changelevel::^3Change^7: Found landmark for %s\n", m_strLandmark));
				landmark = lm;
				g_landmarkpos = m_activator.origin - landmark.origin;
			}
		}
		changelevel(m_strMap, m_strLandmark);
	} else {
		dprint( sprintf( "^2trigger_changelevel::^3Change^7: Change to `%s`\n", 
			m_strMap ) );
		changelevel(m_strMap);
	}
}

void trigger_changelevel::Trigger(void)
{
	if (time < 5) {
		return;
	}

	/* eActivator == player who triggered the damn thing */
	m_activator = eActivator;

	if (m_flChangeDelay) {
		dprint( sprintf( "^2trigger_changelevel::^3Trigger^7: Delayed change to `%s` in %d sec/s\n", 
			m_strMap, m_flChangeDelay ) );
		think = Change;
		nextthink = time + m_flChangeDelay;
	} else {
		dprint( sprintf( "^2trigger_changelevel::^3Trigger^7: Change to `%s` requested\n", 
			m_strMap ) );
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
	info_landmark landmark = world;

	/* a trigger_transition may share the same targetname, thus we do this */
	for (entity e = world; (e = find(e, ::classname, "info_landmark"));) {
		info_landmark lm = (info_landmark)e;
		/* found it */
		if (lm.m_strTargetName == startspot) {
			dprint(sprintf("^3Landmark_GetSpot^7: Found landmark for %s\n", startspot));
			landmark = lm;
			return landmark.origin + g_landmarkpos;
		}
	}

	/* return something useful at least */
	entity ips = find(world, ::classname, "info_player_start");
	print(sprintf("^1ERROR^7: Landmark_GetSpot: Cannot find startspot '%s'!\n",startspot));
	return ips.origin;
}
