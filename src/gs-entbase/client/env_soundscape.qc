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

/*QUAKED env_soundscape (0 1 0.3) (-8 -8 -8) (8 8 8)
Client-side environmental soundscape modifier.

-------- KEYS --------
"radius" : Radius in units.
"shader" : Sound shader to play.

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

var int autocvar_dsp_soundscapes = TRUE;

int g_scapes;

class env_soundscape:NSEntity
{
	int m_iID;
	int m_iShader;
	int m_iRadius;
	float m_flVolume;

	void(void) env_soundscape;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

env_soundscape g_entSoundScape;
env_soundscape g_entOldScape;
env_soundscape g_ambientsound;

void
env_soundscape::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "shader":
		m_iShader = Sound_Precache(strKey);
		
		if (m_iShader == -1) {
			Destroy();
		}

		break;
	case "radius":
		m_iRadius = stoi(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
env_soundscape::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
}

void
env_soundscape::env_soundscape(void)
{
	g_scapes+=1;
	m_iID = g_scapes;
	m_iRadius = 1024;
	isCSQC = true;
}

void
DSP_ResetSoundscape(void)
{
	g_entSoundScape = __NULL__;
}

void
DSP_UpdateSoundscape(void)
{
	vector vecPlayer;

	if (autocvar_dsp_soundscapes == FALSE) {
		return;
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	g_entSoundScape = __NULL__;

	float bestdist = 999999;
	for (entity e = world; (e = find(e, classname, "env_soundscape"));) {
		env_soundscape scape = (env_soundscape)e;
		
		other = world;
		traceline(scape.origin, vecPlayer, MOVE_OTHERONLY, scape);
		if (trace_fraction < 1.0f) {
			continue;
		}

		float dist = vlen(e.origin - vecPlayer);
		if (dist > scape.m_iRadius) {
			continue;
		}

		if (dist > bestdist) {
			continue;
		}

		bestdist = dist;
		g_entSoundScape = scape;
	}

	/* fix? */
	if (g_entOldScape != __NULL__) {
		/* if the shader isn't any different... don't bother changing it? */
		if (g_entOldScape.m_iShader == g_entSoundScape.m_iShader) {
			g_entSoundScape = g_entOldScape;
		}
	}
	g_entOldScape = g_entSoundScape;

	float newvol;
	for (entity e = world; (e = find(e, classname, "env_soundscape"));) {
		env_soundscape t = (env_soundscape)e;

		if (g_ambientsound) {
			if (e == g_ambientsound) {
				continue;
			}
		}

		if (t != g_entSoundScape) {
			newvol = bound(0, t.m_flVolume - clframetime, 1.0);
		} else {
			newvol = bound(0, t.m_flVolume + clframetime, 1.0);
		}

		if (newvol != t.m_flVolume) {
			t.m_flVolume = newvol;
			Sound_Update(world, 10 + t.m_iID, t.m_iShader, t.m_flVolume);
		}
	}

	/* is a default ambientsound set in worldspawn? */
	if (!g_ambientsound) {
		return;
	}

	/* is no soundscape active? increase the default volume */
	if (g_entSoundScape == __NULL__) {
		newvol = bound(0, g_ambientsound.m_flVolume + clframetime, 1.0);
	} else{
		newvol = bound(0, g_ambientsound.m_flVolume - clframetime, 1.0);
	}

	/* only call sound update when the volume changes. this works around a bug in the engine */
	if (newvol != g_ambientsound.m_flVolume) {
		g_ambientsound.m_flVolume = newvol;
		Sound_Update(world, 10, g_ambientsound.m_iShader, g_ambientsound.m_flVolume);
	}
}
