/*
 * Copyright (c) 2023 Vera Visions LLC.
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

#ifdef CLIENT
#define WAVE_POLY_COUNT 32
#endif

/*!QUAKED env_shockwave (1 .5 0) (-8 -8 -8) (8 8 8) CENTERED REPEATABLE
# OVERVIEW
A temporary shockwave effect is produced when triggered.

# KEYS
- "targetname" : Name
- "m_iszPosition" : Entity name to attach the effect too. Runs effect on self if empty.
- "netname" : Path to the sprite to use.
- "rendercolor" : Color of the shockwave effect.
- "renderamt" : Opacity of the effect.
- "m_iTime" : Shockwave life time.
- "m_iRadius" : Final radius of the shockwave effect. In game units.
- "m_iHeight" : Vertical height of the shockwave effect.
- "m_iScrollRate": TODO: Speed at which the texture scrolls.
- "m_iNoise" : Scrolling distortion.
- "m_iFrameRate" : TODO: Framerate at which the texture animates, independent from scrolling.
- "m_iStartFrame" : Frame at which to start animating.

# SPAWNFLAGS
- CENTERED (1) : Center the effect on the target. We ignore this for now, but make sure to set it for when we get around to it.
- REPEATABLE (2) : If set, will not delete the effect after being triggered.

# TRIVIA
This entity was introduced in Spirit of Half-Life (2000)
*/
class
env_shockwave:NSEntity
{
public:
	void env_shockwave(void);

#ifdef SERVER
	virtual void SpawnKey(string, string);
	virtual void Trigger(entity, triggermode_t);
#endif

#ifdef CLIENT
	virtual float predraw(void);
#endif

private:
	float m_flRadius;
	string m_strTexture;
	float m_flStartFrame;
	float m_flFrameRate;
	float m_flLifeTime;
	float m_flHeight;
	float m_flNoiseAmp;
	vector m_vecColor;
	float m_flBrightness;
	float m_flScrollSpeed;

#ifdef SERVER
	string m_strTargetEntity;
#endif
};

void
env_shockwave::env_shockwave(void)
{
	m_flRadius = 1000.0f;
	m_strTexture = __NULL__;
	m_flStartFrame = 0;
	m_flFrameRate = 10.0f;
	m_flLifeTime = 1.0f;
	m_flHeight = 32.0f;
	m_flNoiseAmp = 0.0f;
	m_vecColor = [1,1,1];
	m_flBrightness = 1.0f;;
	m_flScrollSpeed = 0.0f;
}

#ifdef SERVER
void
env_shockwave::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "m_iszPosition":
		m_strTargetEntity = ReadString(setValue);
		break;
	case "netname":
		m_strTexture = ReadString(setValue);
		break;
	case "rendercolor":
		m_vecColor = ReadVector(setValue);
		break;
	case "renderamt":
		m_flBrightness = ReadFloat(setValue);
		break;
	case "m_iTime":
		m_flLifeTime = ReadFloat(setValue);
		break;
	case "m_iRadius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "m_iHeight":
		m_flHeight = ReadFloat(setValue);
		break;
	case "m_iScrollRate":
		m_flScrollSpeed = ReadFloat(setValue);
		break;
	case "m_iNoise":
		m_flNoiseAmp = ReadFloat(setValue);
		break;
	case "m_iFrameRate":
		m_flFrameRate = ReadFloat(setValue);
		break;
	case "m_iStartFrame":
		m_flStartFrame = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
env_shockwave::Trigger(entity theActivator, triggermode_t triggerState)
{
	vector targetPosition = GetOrigin();

	if (m_strTargetEntity) {
		NSEntity target = (NSEntity)find(world, ::targetname, m_strTargetEntity);

		if (target) {
			targetPosition = target.WorldSpaceCenter();
		}
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BEAMCYLINDER);
	WriteCoord(MSG_MULTICAST, targetPosition[0]);
	WriteCoord(MSG_MULTICAST, targetPosition[1]);
	WriteCoord(MSG_MULTICAST, targetPosition[2]);
	WriteCoord(MSG_MULTICAST, angles[0]);
	WriteCoord(MSG_MULTICAST, m_flRadius);
	WriteCoord(MSG_MULTICAST, angles[2]);
	WriteShort(MSG_MULTICAST, getmodelindex(m_strTexture));
	WriteByte(MSG_MULTICAST, m_flStartFrame);
	WriteByte(MSG_MULTICAST, m_flFrameRate);
	WriteByte(MSG_MULTICAST, m_flLifeTime);
	WriteByte(MSG_MULTICAST, m_flHeight);
	WriteByte(MSG_MULTICAST, m_flNoiseAmp);
	WriteByte(MSG_MULTICAST, m_vecColor[0]);
	WriteByte(MSG_MULTICAST, m_vecColor[1]);
	WriteByte(MSG_MULTICAST, m_vecColor[2]);
	WriteByte(MSG_MULTICAST, m_flBrightness);
	WriteByte(MSG_MULTICAST, m_flScrollSpeed);

	msg_entity = this;
	multicast(origin, MULTICAST_PVS);

	if (HasSpawnFlags(2) == false) {
		Destroy();
	}
}
#endif

#ifdef CLIENT
float
env_shockwave::predraw(void)
{
	vector vecPlayer;

	vector startPos = origin;
	vector endPos = origin;
	float maxSize = (frame1time / m_flLifeTime); /* 0.0 - 1.0 */

	if (maxSize >= 1.0) {
		Destroy();
	}

	vecPlayer = g_view.GetCameraOrigin();
	vecPlayer[2] = origin[2] + (m_flHeight * 0.5f);

	makevectors(angles);
	startPos += v_forward * m_flRadius;
	endPos -= v_forward * m_flRadius;

	/* primitive representation */
#if 0
	R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(endPos, [1,1], [0,1,0], 1.0f);
	R_EndPolygon();
#endif

	if (m_strTexture) {
		makevectors(angles);
		setproperty(VF_ORIGIN, vecPlayer);
		R_BeginPolygon(m_strTexture, DRAWFLAG_ADDITIVE, 0);

		for (float i = 0; i < WAVE_POLY_COUNT; i++) {
			vector point;
			vector jitter;
			float a = 1.0f;
			/* our steps from a - b */
			vector center = origin;
			float length = vlen(startPos - endPos) * 0.5;
			length *= maxSize;

			float theta = 2.0f * M_PI * (i / (WAVE_POLY_COUNT-1));
			vector p = [sin(theta), cos(theta)] * length;
			point = center + p;

			if (m_flNoiseAmp > 0) {
				/* nudge it a lil bit up/down left/right from its trajectory */
				/* these are all randomly chosen constants */
				jitter = v_right * (pseudorand((4 * time) + i + entnum) - 0.5);
				jitter += v_up * (pseudorand((4 * time) + i + 64.12 + entnum) - 0.5);
				jitter += v_right * (pseudorand(100 + (8 * time) + i + entnum) - 0.5);
				jitter += v_up * (pseudorand(100 + (8 * time) + i + 25.4 + entnum) - 0.5);
				jitter *= m_flNoiseAmp;

				/* apply jitter */
				point += jitter;
			}

			R_PolygonVertex(point, [1, 0], m_vecColor / 255, m_flBrightness / 255);
		}

		R_EndPolygonRibbon(m_flHeight, [-1,0]);
	}

	frame1time += frametime;

	return (PREDRAW_NEXT);
}

/* basically re-implementing TE_BEAMCYLINDER*/
void
EV_BeamCylinder_Parse(void)
{
	env_shockwave tempCylinder = spawn(env_shockwave);

	tempCylinder.origin[0] = readcoord();
	tempCylinder.origin[1] = readcoord();
	tempCylinder.origin[2] = readcoord();
	tempCylinder.angles[0] = readcoord();
	tempCylinder.m_flRadius = readcoord();
	tempCylinder.angles[2] = readcoord();
	tempCylinder.modelindex = readshort();
	tempCylinder.m_flStartFrame = readbyte();
	tempCylinder.model = modelnameforindex(tempCylinder.modelindex);
	tempCylinder.m_strTexture = spriteframe(tempCylinder.model, tempCylinder.m_flStartFrame, 0.0f);
	tempCylinder.m_flFrameRate = readbyte();
	tempCylinder.m_flLifeTime = readbyte() * 0.1f;
	tempCylinder.m_flHeight = readbyte();
	tempCylinder.m_flNoiseAmp = readbyte();
	tempCylinder.m_vecColor[0] = readbyte();
	tempCylinder.m_vecColor[1] = readbyte();
	tempCylinder.m_vecColor[2] = readbyte();
	tempCylinder.m_flBrightness = readbyte();
	tempCylinder.m_flScrollSpeed = readbyte();
	tempCylinder.frame1time = 0.0f;
	setorigin(tempCylinder, tempCylinder.origin);
	setsize(tempCylinder, [0,0,0], [0,0,0]);
	tempCylinder.drawmask = MASK_ENGINE;
}
#endif