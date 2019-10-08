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

/*QUAKED env_sound (1 0 0) (-8 -8 -8) (8 8 8)
"radius"    Radius in units.
"roomtype"  Roomtype value:
                0 = DEFAULT
                1 = PADDEDCELL
                2 = ROOM
                3 = BATHROOM
                4 = LIVINGROOM
                5 = STONEROOM
                6 = AUDITORIUM
                7 = CONCERTHALL
                8 = CAVE
                9 = ARENA
                10 = HANGAR
                11 = CARPETEDHALLWAY
                12 = HALLWAY
                13 = STONECORRIDOR
                14 = ALLEY
                15 = FOREST
                16 = CITY
                17 = MOUNTAINS
                18 = QUARRY
                19 = PLAIN
                20 = PARKINGLOT
                21 = SEWERPIPE
                22 = UNDERWATER
                23 = DRUGGED
                24 = DIZZY
                25 = PSYCHOTIC
                26 = CITYSTREETS
                27 = SUBWAY
                28 = MUSEUM
                29 = LIBRARY
                30 = UNDERPASS
                31 = ABANDONED
                32 = DUSTYROOM
                33 = CHAPEL
                34 = SMALLWATERROOM

Client-side environmental reverb modifier.
This works only with the OpenAL sound backend.
*/

int g_iDSP;
float g_flDSPCheck;

enum {
	DSP_DEFAULT,
	DSP_PADDEDCELL,
	DSP_ROOM,
	DSP_BATHROOM,
	DSP_LIVINGROOM,
	DSP_STONEROOM,
	DSP_AUDITORIUM,
	DSP_CONCERTHALL,
	DSP_CAVE,
	DSP_ARENA,
	DSP_HANGAR,
	DSP_CARPETEDHALLWAY,
	DSP_HALLWAY,
	DSP_STONECORRIDOR,
	DSP_ALLEY,
	DSP_FOREST,
	DSP_CITY,
	DSP_MOUNTAINS,
	DSP_QUARRY,
	DSP_PLAIN,
	DSP_PARKINGLOT,
	DSP_SEWERPIPE,
	DSP_UNDERWATER,
	DSP_DRUGGED,
	DSP_DIZZY,
	DSP_PSYCHOTIC,
	DSP_CITYSTREETS,
	DSP_SUBWAY,
	DSP_MUSEUM,
	DSP_LIBRARY,
	DSP_UNDERPASS,
	DSP_ABANDONED,
	DSP_DUSTYROOM,
	DSP_CHAPEL,
	DSP_SMALLWATERROOM
};

reverbinfo_t reverbPresets [35] = {
	{ 1.0000f, 1.0000f, 0.0000f, 1.0000f, 1.0000f, 1.0000f, 1.0000f, 1.0000f, 0.0000f, 0.0000f, [0,0,0], 1.0000f, 0.0000f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 1.0000f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.1715f, 1.0000f, 0.3162f, 0.0010f, 1.0000f, 0.1700f, 0.1000f, 1.0000f, 0.2500f, 0.0010f, [0,0,0], 1.2691f, 0.0020f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.4287f, 1.0000f, 0.3162f, 0.5929f, 1.0000f, 0.4000f, 0.8300f, 1.0000f, 0.1503f, 0.0020f, [0,0,0], 1.0629f, 0.0030f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.1715f, 1.0000f, 0.3162f, 0.2512f, 1.0000f, 1.4900f, 0.5400f, 1.0000f, 0.6531f, 0.0070f, [0,0,0], 3.2734f, 0.0110f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.9766f, 1.0000f, 0.3162f, 0.0010f, 1.0000f, 0.5000f, 0.1000f, 1.0000f, 0.2051f, 0.0030f, [0,0,0], 0.2805f, 0.0040f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.7079f, 1.0000f, 2.3100f, 0.6400f, 1.0000f, 0.4411f, 0.0120f, [0,0,0], 1.1003f, 0.0170f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.5781f, 1.0000f, 4.3200f, 0.5900f, 1.0000f, 0.4032f, 0.0200f, [0,0,0], 0.7170f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.5623f, 1.0000f, 3.9200f, 0.7000f, 1.0000f, 0.2427f, 0.0200f, [0,0,0], 0.9977f, 0.0290f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 1.0000f, 1.0000f, 2.9100f, 1.3000f, 1.0000f, 0.5000f, 0.0150f, [0,0,0], 0.7063f, 0.0220f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.4477f, 1.0000f, 7.2400f, 0.3300f, 1.0000f, 0.2612f, 0.0200f, [0,0,0], 1.0186f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.3162f, 1.0000f, 10.0500f, 0.2300f, 1.0000f, 0.5000f, 0.0200f, [0,0,0], 1.2560f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.4287f, 1.0000f, 0.3162f, 0.0100f, 1.0000f, 0.3000f, 0.1000f, 1.0000f, 0.1215f, 0.0020f, [0,0,0], 0.1531f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.3645f, 1.0000f, 0.3162f, 0.7079f, 1.0000f, 1.4900f, 0.5900f, 1.0000f, 0.2458f, 0.0070f, [0,0,0], 1.6615f, 0.0110f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.7612f, 1.0000f, 2.7000f, 0.7900f, 1.0000f, 0.2472f, 0.0130f, [0,0,0], 1.5758f, 0.0200f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.3000f, 0.3162f, 0.7328f, 1.0000f, 1.4900f, 0.8600f, 1.0000f, 0.2500f, 0.0070f, [0,0,0], 0.9954f, 0.0110f, [0,0,0], 0.1250f, 0.9500f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.3000f, 0.3162f, 0.0224f, 1.0000f, 1.4900f, 0.5400f, 1.0000f, 0.0525f, 0.1620f, [0,0,0], 0.7682f, 0.0880f, [0,0,0], 0.1250f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.5000f, 0.3162f, 0.3981f, 1.0000f, 1.4900f, 0.6700f, 1.0000f, 0.0730f, 0.0070f, [0,0,0], 0.1427f, 0.0110f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.2700f, 0.3162f, 0.0562f, 1.0000f, 1.4900f, 0.2100f, 1.0000f, 0.0407f, 0.3000f, [0,0,0], 0.1919f, 0.1000f, [0,0,0], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 1.0000f, 1.0000f, 0.3162f, 0.3162f, 1.0000f, 1.4900f, 0.8300f, 1.0000f, 0.0000f, 0.0610f, [0,0,0], 1.7783f, 0.0250f, [0,0,0], 0.1250f, 0.7000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.2100f, 0.3162f, 0.1000f, 1.0000f, 1.4900f, 0.5000f, 1.0000f, 0.0585f, 0.1790f, [0,0,0], 0.1089f, 0.1000f, [0,0,0], 0.2500f, 1.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 1.0000f, 0.3162f, 1.0000f, 1.0000f, 1.6500f, 1.5000f, 1.0000f, 0.2082f, 0.0080f, [0,0,0], 0.2652f, 0.0120f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 0.3071f, 0.8000f, 0.3162f, 0.3162f, 1.0000f, 2.8100f, 0.1400f, 1.0000f, 1.6387f, 0.0140f, [0,0,0], 3.2471f, 0.0210f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.3645f, 1.0000f, 0.3162f, 0.0100f, 1.0000f, 1.4900f, 0.1000f, 1.0000f, 0.5963f, 0.0070f, [0,0,0], 7.0795f, 0.0110f, [0,0,0], 0.2500f, 0.0000f, 1.1800f, 0.3480f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.4287f, 0.5000f, 0.3162f, 1.0000f, 1.0000f, 8.3900f, 1.3900f, 1.0000f, 0.8760f, 0.0020f, [0,0,0], 3.1081f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 1.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 0.3645f, 0.6000f, 0.3162f, 0.6310f, 1.0000f, 17.2300f, 0.5600f, 1.0000f, 0.1392f, 0.0200f, [0,0,0], 0.4937f, 0.0300f, [0,0,0], 0.2500f, 1.0000f, 0.8100f, 0.3100f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 0.0625f, 0.5000f, 0.3162f, 0.8404f, 1.0000f, 7.5600f, 0.9100f, 1.0000f, 0.4864f, 0.0200f, [0,0,0], 2.4378f, 0.0300f, [0,0,0], 0.2500f, 0.0000f, 4.0000f, 1.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x0 },
	{ 1.0000f, 0.7800f, 0.3162f, 0.7079f, 0.8913f, 1.7900f, 1.1200f, 0.9100f, 0.2818f, 0.0460f, [0,0,0], 0.1995f, 0.0280f, [0,0,0], 0.2500f, 0.2000f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.7400f, 0.3162f, 0.7079f, 0.8913f, 3.0100f, 1.2300f, 0.9100f, 0.7079f, 0.0460f, [0,0,0], 1.2589f, 0.0280f, [0,0,0], 0.1250f, 0.2100f, 0.2500f, 0.0000f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.8200f, 0.3162f, 0.1778f, 0.1778f, 3.2800f, 1.4000f, 0.5700f, 0.2512f, 0.0390f, [0,0,0], 0.8913f, 0.0340f, [0,0,0], 0.1300f, 0.1700f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 },
	{ 1.0000f, 0.8200f, 0.3162f, 0.2818f, 0.0891f, 2.7600f, 0.8900f, 0.4100f, 0.3548f, 0.0290f, [0,0,0], 0.8913f, 0.0200f, [0,0,0], 0.1300f, 0.1700f, 0.2500f, 0.0000f, 0.9943f, 2854.3999f, 107.5000f, 0.0000f, 0x0 },
	{ 1.0000f, 0.8200f, 0.3162f, 0.4467f, 0.8913f, 3.5700f, 1.1200f, 0.9100f, 0.3981f, 0.0590f, [0,0,0], 0.8913f, 0.0370f, [0,0,0], 0.2500f, 0.1400f, 0.2500f, 0.0000f, 0.9920f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.6900f, 0.3162f, 0.7943f, 0.8913f, 3.2800f, 1.1700f, 0.9100f, 0.4467f, 0.0440f, [0,0,0], 0.2818f, 0.0240f, [0,0,0], 0.2500f, 0.2000f, 0.2500f, 0.0000f, 0.9966f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 0.3645f, 0.5600f, 0.3162f, 0.7943f, 0.7079f, 1.7900f, 0.3800f, 0.2100f, 0.5012f, 0.0020f, [0,0,0], 1.2589f, 0.0060f, [0,0,0], 0.2020f, 0.0500f, 0.2500f, 0.0000f, 0.9886f, 13046.0000f, 163.3000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.8400f, 0.3162f, 0.5623f, 1.0000f, 4.6200f, 0.6400f, 1.2300f, 0.4467f, 0.0320f, [0,0,0], 0.7943f, 0.0490f, [0,0,0], 0.2500f, 0.0000f, 0.2500f, 0.1100f, 0.9943f, 5000.0000f, 250.0000f, 0.0000f, 0x1 },
	{ 1.0000f, 0.7000f, 0.3162f, 0.4477f, 1.0000f, 1.5100f, 1.2500f, 1.1400f, 0.8913f, 0.0200f, [0,0,0], 1.4125f, 0.0300f, [0,0,0], 0.1790f, 0.1500f, 0.8950f, 0.1900f, 0.9920f, 5000.0000f, 250.0000f, 0.0000f, 0x0 }
};

class env_sound:CBaseEntity
{
	int m_iRoomType;
	int m_iRadius;

	void() env_sound;
	virtual void() customphysics;
	virtual void(string, string) SpawnKey;
};

void env_sound::customphysics(void)
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

	if (g_flDSPCheck > time) {
		return;
	}

	other = world;
	traceline(this.origin, vecPlayer, MOVE_OTHERONLY, this);

	if (trace_fraction < 1.0f) {
		return;
	}

	if (fDist <= m_iRadius) {
		if (g_iDSP == m_iRoomType) {
			return;
		}
		setup_reverb(12, &reverbPresets[m_iRoomType], sizeof(reverbinfo_t));
		dprint(sprintf("[DSP] Environment changed to %i\n", m_iRoomType));
		g_iDSP = m_iRoomType;
		g_flDSPCheck = time + 0.5;
	}
}

void env_sound::env_sound(void)
{
	Init();

	/* Valve BSP, convert their env_sound */
	if (serverkeyfloat("*bspversion") == 30) {
		switch(m_iRoomType) {
			case 0:
			case 1:
				m_iRoomType = DSP_DEFAULT;
				break;
			case 2:
				m_iRoomType = DSP_SEWERPIPE;
				break;
			case 3:
				m_iRoomType = DSP_SEWERPIPE;
				break;
			case 4:
				m_iRoomType = DSP_SEWERPIPE;
				break;
			case 5:
				m_iRoomType = DSP_HALLWAY;
				break;
			case 6:
				m_iRoomType = DSP_UNDERPASS;
				break;
			case 7:
				m_iRoomType = DSP_SUBWAY;
				break;
			case 8:
				m_iRoomType = DSP_BATHROOM;
				break;
			case 9:
				m_iRoomType = DSP_LIVINGROOM;
				break;
			case 10:
				m_iRoomType = DSP_AUDITORIUM;
				break;
			case 11:
				m_iRoomType = DSP_QUARRY;
				break;
			case 12:
				m_iRoomType = DSP_FOREST;
				break;
			case 13:
				m_iRoomType = DSP_MOUNTAINS;
				break;
			case 14:
				m_iRoomType = DSP_UNDERWATER;
				break;
			case 15:
				m_iRoomType = DSP_UNDERWATER;
				break;
			case 16:
				m_iRoomType = DSP_UNDERWATER;
				break;
			case 17:
				m_iRoomType = DSP_PARKINGLOT;
				break;
			case 18:
				m_iRoomType = DSP_CAVE;
				break;
			case 19:
				m_iRoomType = DSP_ABANDONED;
				break;
			case 20:
				m_iRoomType = DSP_CHAPEL;
				break;
			case 21:
				m_iRoomType = DSP_CONCERTHALL;
				break;
			case 22:
				m_iRoomType = DSP_MUSEUM;
				break;
			case 23:
				m_iRoomType = DSP_CAVE;
				break;
			case 24:
				m_iRoomType = DSP_CAVE;
				break;
			case 25:
				m_iRoomType = DSP_CAVE;
				break;
			case 26:
				m_iRoomType = DSP_DRUGGED;
				break;
			case 27:
				m_iRoomType = DSP_DIZZY;
				break;
			case 28:
				m_iRoomType = DSP_PSYCHOTIC;
				break;
		}
	}
}

void env_sound::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "roomtype":
			m_iRoomType = stoi(strKey);
			break;
		case "radius":
			m_iRadius = stoi(strKey);
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}

void DSP_Init(void)
{
	g_iDSP = 0;
	setup_reverb(12, &reverbPresets[g_iDSP], sizeof(reverbinfo_t));
	setup_reverb(10, &reverbPresets[DSP_UNDERWATER], sizeof(reverbinfo_t));
}

void DSP_UpdateListener(void)
{
	makevectors(getproperty(VF_CL_VIEWANGLES));
	SetListener(getproperty(VF_ORIGIN), v_forward, v_right, v_up, 12);
}
