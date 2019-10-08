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

int g_iSoundscape;
float g_flSoundscapeCheck;
int Sound_Precache(string shader);

class env_soundscape:CBaseEntity
{
	int m_iShader;
	int m_iRadius;

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
		if (g_iSoundscape == m_iShader) {
			return;
		}
		dprint(sprintf("[DSP] Soundscape changed to %i\n", m_iShader));
		g_iSoundscape = m_iShader;
		g_flSoundscapeCheck = time + 0.5;
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

void DSP_UpdateSoundscape(void)
{
	
}
