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

.float hurt_next;

#define HURTTYPE_GENERIC	0
#define HURTTYPE_CRUSH		1
#define HURTTYPE_BULLET		2
#define HURTTYPE_SLASH		4
#define HURTTYPE_BURN		8
#define HURTTYPE_FREEZE		16
#define HURTTYPE_FALL		32
#define HURTTYPE_BLAST		64
#define HURTTYPE_CLUB		128
#define HURTTYPE_SHOCK		256
#define HURTTYPE_SONIC		512
#define HURTTYPE_ENERGYBEAM	1024
#define HURTTYPE_DROWN		16384
#define HURTTYPE_PARALYSE	32768
#define HURTTYPE_NERVEGAS	65536
#define HURTTYPE_POISON		131072
#define HURTTYPE_RADIATION	262144
#define HURTTYPE_DROWNRECOVER	524288
#define HURTTYPE_CHEMICAL	1048576
#define HURTTYPE_SLOWBURN	2097152
#define HURTTYPE_SLOWFREEZE	4194304

#define SF_HURT_ONCE			1 // Turn off once it fired the first time
#define SF_HURT_OFF				2 // Needs to be triggered in order to work again
#define SF_HURT_NOPLAYERS		8 // Don't hurt players
#define SF_HURT_FIREONPLAYER	16 // Only call UseTarget functions when it's a player
#define SF_HURT_TOUCHPLAYER		32 // Only hurt players

/*!QUAKED trigger_hurt (.5 .5 .5) ? SF_HURT_ONCE SF_HURT_OFF x SF_HURT_NOPLAYERS SF_HURT_FIREONPLAYER SF_HURT_TOUCHPLAYER
# OVERVIEW
Trigger volume that damages everything it touches.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "delay" : Delay until target is triggered.
- "killtarget" : Target to kill when triggered.
- "dmg" : Damage inflicted.

# SPAWNFLAGS
- SF_HURT_ONCE (1) : Stop once it's been triggered the first time.
- SF_HURT_OFF (2) : Needs to be triggered in order to work again.
- SF_HURT_NOPLAYERS (8) : Will only hurt NPCs.
- SF_HURT_TOUCHPLAYER (16) : Will only hurt players.
- SF_HURT_FIREONPLAYER (32) : Only trigger a target if a player activates it.

# TRIVIA
This entity was introduced in Quake (1996).
*/
class
trigger_hurt:NSBrushTrigger
{
public:
	void trigger_hurt(void);
	
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Touch(entity);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void Input(entity,string,string);

private:
	int m_iDamage;
	int m_iDamageType;
	float m_flNextTrigger;
	float m_flNextDmg;
	float m_flDelay;
	string m_strOnHurt;
	string m_strOnHurtPlayer;
};

void
trigger_hurt::trigger_hurt(void)
{
	m_iDamage = 15;
	m_iDamageType = 0i;
	m_flNextTrigger = 0.0f;
	m_flNextDmg = 0.5f;
	m_flDelay = 0.0f;
	m_strOnHurt = __NULL__;
	m_strOnHurtPlayer = __NULL__;
}

void
trigger_hurt::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iDamage", m_iDamage);
	SaveInt(handle, "m_iDamageType", m_iDamageType);
	SaveFloat(handle, "m_flNextTrigger", m_flNextTrigger);
	SaveFloat(handle, "m_flNextDmg", m_flNextDmg);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveString(handle, "m_strOnHurt", m_strOnHurt);
	SaveString(handle, "m_strOnHurtPlayer", m_strOnHurtPlayer);
}

void
trigger_hurt::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iDamage":
		m_iDamage = ReadInt(strValue);
		break;
	case "m_iDamageType":
		m_iDamageType = ReadInt(strValue);
		break;
	case "m_flNextTrigger":
		m_flNextTrigger = ReadFloat(strValue);
		break;
	case "m_flNextDmg":
		m_flNextDmg = ReadFloat(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_strOnHurt":
		m_strOnHurt = ReadString(strValue);
		break;
	case "m_strOnHurtPlayer":
		m_strOnHurtPlayer = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_hurt::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "dmg":
		m_iDamage = stoi(strValue);
		break;
	case "damagetype":
		m_iDamageType = (int)stoi(strValue);
		break;
	case "wait":
		m_flNextDmg = stof(strValue);
		break;
	case "OnHurt":
		m_strOnHurt = PrepareOutput(m_strOnHurt, strValue);
		break;
	case "OnHurtPlayer":
		m_strOnHurtPlayer = PrepareOutput(m_strOnHurtPlayer, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_hurt::Spawned(void)
{
	super::Spawned();

	if (m_strOnHurt)
		m_strOnHurt = CreateOutput(m_strOnHurt);

	if (m_strOnHurtPlayer)
		m_strOnHurtPlayer = CreateOutput(m_strOnHurtPlayer);
}

void
trigger_hurt::Respawn(void)
{
	InitBrushTrigger();

	if (HasSpawnFlags(SF_HURT_OFF)) {
		Trigger(this, TRIG_OFF);
	} else {
		Trigger(this, TRIG_ON);
	}
}

void
trigger_hurt::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetSolid(SOLID_NOT);
		break;
	case TRIG_ON:
		SetSolid(SOLID_TRIGGER);
		InitBrushTrigger();
		break;
	default:
		if (solid == SOLID_NOT)
			Trigger(act, TRIG_ON);
		else
			Trigger(act, TRIG_OFF);
	}
}

void
trigger_hurt::Touch(entity eToucher)
{
	if (eToucher.takedamage == DAMAGE_NO) {
		return;
	} else if (HasSpawnFlags(SF_HURT_TOUCHPLAYER) && !(eToucher.flags & FL_CLIENT)) {
		return;
	} else if (HasSpawnFlags(SF_HURT_NOPLAYERS) && (eToucher.flags & FL_CLIENT)) {
		return;
	} else if (eToucher.hurt_next > time) {
		return;
	}

	if (!target) {
		if (eToucher.flags & FL_CLIENT)
			UseOutput(eToucher, m_strOnHurtPlayer);
		else
			UseOutput(eToucher, m_strOnHurt);
	} else {
		if (HasSpawnFlags(SF_HURT_FIREONPLAYER)) {
			if (eToucher.flags & FL_CLIENT) {
				eActivator = eToucher;
				UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
			}
		} else {
			eActivator = eToucher;
			UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
		}
	}

	{
		int type = 0;
		if (m_iDamageType & HURTTYPE_BURN)
			type |= DMG_BURN;
		if (m_iDamageType & HURTTYPE_SLOWBURN)
			type |= DMG_SLOWBURN;
		if (m_iDamageType & HURTTYPE_FREEZE)
			type |= DMG_FREEZE;
		if (m_iDamageType & HURTTYPE_SLOWFREEZE)
			type |= DMG_SLOWFREEZE;
		if (m_iDamageType & HURTTYPE_SHOCK)
			type |= DMG_ELECTRO;
		if (m_iDamageType & HURTTYPE_DROWN)
			type |= DMG_DROWN;
		if (m_iDamageType & HURTTYPE_NERVEGAS)
			type |= DMG_NERVEGAS;
		if (m_iDamageType & HURTTYPE_POISON)
			type |= DMG_POISON;
		if (m_iDamageType & HURTTYPE_RADIATION)
			type |= DMG_RADIATION;
		if (m_iDamageType & HURTTYPE_CHEMICAL)
			type |= DMG_CHEMICAL;
	}

	EntLog("Hurting %S (%d) with %i.", eToucher.classname, num_for_edict(eToucher), m_iDamage);
	Damage_Apply(eToucher, this, m_iDamage, 0, type);

	/* shut it down if used once */
	if (HasSpawnFlags(SF_HURT_ONCE)) {
		Trigger(eToucher, TRIG_OFF);
	}

	eToucher.hurt_next = time + m_flNextDmg;
}

void
trigger_hurt::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "SetDamage":
		m_iDamage = stoi(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
