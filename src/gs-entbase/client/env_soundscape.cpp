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

/*QUAKED env_soundscape (1 0 0) (-8 -8 -8) (8 8 8)
"radius"    Radius in units.
"shader"    Sound shader to play.

Client-side environmental soundscape modifier.
*/

float g_flSoundscapeCheck;
int Sound_Precache(string shader);
entity g_entSoundScape;

class env_soundscape:CBaseEntity
{
	int m_iShader;
	int m_iRadius;
	float m_flVolume;

	void() env_soundscape;
	virtual void() customphysics;
	virtual void(string, string) SpawnKey;
};

void env_soundscape::customphysics(void)
{
	vector vecPlayer;

#ifdef WASTES
	vecPlayer = viewClient.vecPlayerOrigin;
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	vecPlayer = pSeat->vPlayerOrigin;
#endif

	if (checkpvs(vecPlayer, this) == FALSE) {
		return;
	}

	float fDist = vlen(vecPlayer - this.origin);

	if (g_flSoundscapeCheck > time) {
		return;
	}

	other = world;
	traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

	if (trace_fraction < 1.0f) {
		return;
	}

	if (fDist <= m_iRadius) {
		if (g_entSoundScape == this) {
			return;
		}
		g_entSoundScape = this;
	}
}

void env_soundscape::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "shader":
		m_iShader = Sound_Precache(strKey);
		break;
	case "radius":
		m_iRadius = stoi(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void env_soundscape::env_soundscape(void)
{
	m_iRadius = 1024;
}

void DSP_ResetSoundscape(void)
{
	g_entSoundScape = world;
}

void DSP_UpdateSoundscape(void)
{
	if (!g_entSoundScape) {
		return;
	}

	for ( entity e = world; ( e = find( e, classname, "env_soundscape" ) ); ) {
		env_soundscape t = (env_soundscape)e;
		
		if (t != g_entSoundScape) {
			t.m_flVolume = bound(0, t.m_flVolume - clframetime, 1.0);
		} else {
			t.m_flVolume = bound(0, t.m_flVolume + clframetime, 1.0);
		}

		Sound_Update(self, 10 + t.m_iShader, t.m_iShader, t.m_flVolume);
	}
}
