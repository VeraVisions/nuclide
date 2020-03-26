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

enum {
	MONSTER_IDLE,
	MONSTER_WALK,
	MONSTER_RUN,
	MONSTER_DEAD
};

class CBaseMonster:CBaseEntity
{
	int body;
	int oldnet_body;
	vector oldnet_velocity;
	float m_flPitch;
	int m_iFlags;
	vector base_mins;
	vector base_maxs;
	int base_health;

	void() CBaseMonster;

	virtual void() touch;
	virtual void() Hide;
	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void() Physics;
	virtual void() IdleNoise;
	virtual void() Gib;
	virtual void(string) Speak;
	virtual float(entity, float) SendEntity;
	virtual void() ParentUpdate;
};

void CBaseMonster::Speak(string msg)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, msg);
	WriteFloat(MSG_MULTICAST, m_flPitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

float CBaseMonster::SendEntity(entity ePEnt, float fChanged)
{
	if (modelindex == 0) {
		return FALSE;
	}

	WriteByte(MSG_ENTITY, ENT_NPC);
	WriteShort(MSG_ENTITY, fChanged);

	if (fChanged & NPC_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);
	if (fChanged & NPC_ORIGIN_X)
		WriteCoord(MSG_ENTITY, origin[0]);
	if (fChanged & NPC_ORIGIN_Y)
		WriteCoord(MSG_ENTITY, origin[1]);
	if (fChanged & NPC_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);
	if (fChanged & NPC_ANGLES_X)
		WriteFloat(MSG_ENTITY, angles[0]);
	if (fChanged & NPC_ANGLES_Y)
		WriteFloat(MSG_ENTITY, angles[1]);
	if (fChanged & NPC_ANGLES_Z)
		WriteFloat(MSG_ENTITY, angles[2]);
	if (fChanged & NPC_VELOCITY_X)
		WriteCoord(MSG_ENTITY, velocity[0]);
	if (fChanged & NPC_VELOCITY_Y)
		WriteCoord(MSG_ENTITY, velocity[1]);
	if (fChanged & NPC_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);
	if (fChanged & NPC_FRAME)
		WriteByte(MSG_ENTITY, frame);
	if (fChanged & NPC_SKIN)
		WriteByte(MSG_ENTITY, skin);
	if (fChanged & NPC_BODY)
		WriteByte(MSG_ENTITY, body);

	return TRUE;
}

void CBaseMonster::Gib(void)
{
	takedamage = DAMAGE_NO;
	Effect_GibHuman(this.origin);
	Hide();
}

void CBaseMonster::IdleNoise(void)
{

}

void CBaseMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;

	input_angles = angles = v_angle;
	input_timelength = frametime;
	movetype = MOVETYPE_WALK;

	runstandardplayerphysics(this);
	movetype = MOVETYPE_NONE;

	IdleNoise();
}

void CBaseMonster::touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void CBaseMonster::PlayerUse(void)
{

}

void CBaseMonster::ParentUpdate(void)
{
	if (modelindex != oldnet_modelindex)
		SendFlags |= NPC_MODELINDEX;
	if (origin[0] != oldnet_origin[0])
		SendFlags |= NPC_ORIGIN_X;
	if (origin[1] != oldnet_origin[1])
		SendFlags |= NPC_ORIGIN_Y;
	if (origin[2] != oldnet_origin[2])
		SendFlags |= NPC_ORIGIN_Z;
	if (angles[0] != oldnet_angles[0])
		SendFlags |= NPC_ANGLES_X;
	if (angles[1] != oldnet_angles[1])
		SendFlags |= NPC_ANGLES_Y;
	if (angles[2] != oldnet_angles[2])
		SendFlags |= NPC_ANGLES_Z;
	if (velocity[0] != oldnet_velocity[0])
		SendFlags |= NPC_VELOCITY_X;
	if (velocity[1] != oldnet_velocity[1])
		SendFlags |= NPC_VELOCITY_Y;
	if (velocity[2] != oldnet_velocity[2])
		SendFlags |= NPC_VELOCITY_Z;
	if (frame != oldnet_frame)
		SendFlags |= NPC_FRAME;
	if (skin != oldnet_skin)
		SendFlags |= NPC_SKIN;
	if (body != oldnet_body)
		SendFlags |= NPC_BODY;

	oldnet_modelindex = modelindex;
	oldnet_origin = origin;
	oldnet_angles = angles;
	oldnet_velocity = velocity;
	oldnet_frame = frame;
	oldnet_skin = skin;
	oldnet_body = body;
}

void CBaseMonster::Pain(int iHitBody)
{

}

void CBaseMonster::Death(int iHitBody)
{
	m_iFlags = 0x0;

	if (health < -50) {
		Gib();
		return;
	}

	/* make sure we're not causing any more obituaries */
	flags &= ~FL_MONSTER;

	/* gibbing action */
	movetype = MOVETYPE_NONE;
	solid = SOLID_CORPSE;
	style = MONSTER_DEAD;
}

void CBaseMonster::Hide(void)
{
	setmodel(this, "");
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	customphysics = __NULL__;
}

void CBaseMonster::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);
	flags |= FL_MONSTER;
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	customphysics = Physics;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	SendFlags = 0xff;
	style = MONSTER_IDLE;
	health = base_health;
	setmodel(this, m_oldModel);
	setsize(this, base_mins, base_maxs);
	setorigin(this, m_oldOrigin);
}

void CBaseMonster::CBaseMonster(void)
{
	CBaseEntity::CBaseEntity();
}
