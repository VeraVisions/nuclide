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

/*QUAKED env_laser (1 0 0) (-8 -8 -8) (8 8 8) ENVLAZ_STARTON x x x ENVLAZ_STARTSPARK ENVLAZ_ENDSPARK ENVLAZ_DECALEND
Shoots a frickin lazer.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"texture" : Sprite to use as a texture.
"EndSprite" : Sprite to draw at the end of the laser beam impact.
"LaserTarget" : Which entity determines the end position.
"damage" : Damage-per-second when something passes through.

-------- NOTES --------
Use an info_notnull for a LaserTarget.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	ENVLASER_CHANGED_ORIGIN,
	ENVLASER_CHANGED_ANGLES,
	ENVLASER_CHANGED_TEXTURE,
	ENVLASER_CHANGED_ENDTEXTURE,
	ENVLASER_CHANGED_STATE
};

enumflags
{
	ENVLAZ_STARTON,
	ENVLAZ_2,
	ENVLAZ_4,
	ENVLAZ_8,
	ENVLAZ_STARTSPARK,
	ENVLAZ_ENDSPARK,
	ENVLAZ_DECALEND
};

class
env_laser:NSPointTrigger
{
	int m_iState;
	int m_iStateOld;
	float m_flDPS;
	string m_strLaserDest;
	string m_strBeamTex;
	string m_strEndTex;

	void(void) env_laser;

	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;
	virtual void(void) LaserThink;
	virtual void(entity, int) Trigger;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
};

void
env_laser::env_laser(void)
{
	pvsflags = PVSF_IGNOREPVS;
	m_iState = 0i;
	m_iStateOld = 0i;
	m_flDPS = 0.0f;
	m_strLaserDest = __NULL__;
	m_strBeamTex = __NULL__;
	m_strEndTex = __NULL__;
}

void
env_laser::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iState", m_iState);
	SaveInt(handle, "m_iStateOld", m_iStateOld);
	SaveFloat(handle, "m_flDPS", m_flDPS);
	SaveString(handle, "m_strLaserDest", m_strLaserDest);
	SaveString(handle, "m_strBeamTex", m_strBeamTex);
	SaveString(handle, "m_strEndTex", m_strEndTex);
}

void
env_laser::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iState":
		m_iState = ReadInt(strValue);
		break;
	case "m_iStateOld":
		m_iStateOld = ReadInt(strValue);
		break;
	case "m_flDPS":
		m_flDPS = ReadFloat(strValue);
		break;
	case "m_strLaserDest":
		m_strLaserDest = ReadString(strValue);
		break;
	case "m_strBeamTex":
		m_strBeamTex = ReadString(strValue);
		break;
	case "m_strEndTex":
		m_strEndTex = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_laser::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "texture":
		m_strBeamTex = strValue;
		precache_model(m_strBeamTex);
		break;
	case "EndSprite":
		m_strEndTex = strValue;
		precache_model(m_strEndTex);
		break;
	case "LaserTarget":
		m_strLaserDest = strValue;
		break;
	case "damage":
		m_flDPS = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_laser::Respawn(void)
{
	if (HasSpawnFlags(ENVLAZ_STARTON)) {
		m_iState = 1;
		ScheduleThink(LaserThink, 0.0f);
	}
}

void
env_laser::LaserThink(void)
{
	entity t;

	if (!m_iState) {
		return;
	} else {
		ScheduleThink(LaserThink, 0.1f);
	}

	t = find(world, ::targetname, m_strLaserDest);
	SetAngles(t.origin);

	if (!t) {
		print(sprintf("^1env_laser::^3LaserThink^7: %s has no valid target. Aborting\n", targetname));
		return;
	}

	traceline(origin, t.origin, FALSE, this);

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, this, rint(m_flDPS), 0, DMG_GENERIC);
	}
}

void
env_laser::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iState = 0;
		break;
	case TRIG_ON:
		m_iState = 1;
		break;
	default:
		m_iState = 1 - m_iState;
	}

	if (m_iState) {
		ScheduleThink(LaserThink, 0.0f);
	} else {
		ReleaseThink();
	}
}

float
env_laser::SendEntity(entity ePEnt, float fChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_ENVLASER);
	WriteFloat(MSG_ENTITY, fChanged);

	if (fChanged & ENVLASER_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & ENVLASER_CHANGED_ANGLES) {
		WriteCoord(MSG_ENTITY, angles[0]);
		WriteCoord(MSG_ENTITY, angles[1]);
		WriteCoord(MSG_ENTITY, angles[2]);
	}
	if (fChanged & ENVLASER_CHANGED_TEXTURE) {
		WriteString(MSG_ENTITY, m_strBeamTex);
	}
	if (fChanged & ENVLASER_CHANGED_ENDTEXTURE) {
		WriteString(MSG_ENTITY, m_strEndTex);
	}
	if (fChanged & ENVLASER_CHANGED_STATE) {
		WriteByte(MSG_ENTITY, m_iState);
	}

	return (1);
}

void
env_laser::EvaluateEntity(void)
{
	/* FIXME: Check our fields for networking */
	if (ATTR_CHANGED(angles)) {
		SetSendFlags(ENVLASER_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(ENVLASER_CHANGED_ANGLES);
	}
	if (m_iState != m_iStateOld) {
		SetSendFlags(ENVLASER_CHANGED_STATE);
		m_iStateOld = m_iState;
	}

	SAVE_STATE(origin);
	SAVE_STATE(angles);
}
