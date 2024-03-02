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

#define SF_GUNTARGET_ON 1

/*!QUAKED func_guntarget (0 .5 .8) ?
# OVERVIEW
Gun targets brushes that trigger a target once they 'die'.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "health" : Health until it stops and triggers its targets.
- "speed" : Speed in units per second at which it moves.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
func_guntarget:NSSurfacePropEntity
{
public:
	void func_guntarget(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Death(void);
	
	nonvirtual void NextPath(void);
	nonvirtual void Move(void);
	nonvirtual void Start(void);
	nonvirtual void Stop(void);

	virtual void Input(entity, string, string);

private:
	float m_flSpeed;
	string m_strOnDeath;
	string m_strOnDeathLegacy;
};

void
func_guntarget::func_guntarget(void)
{
	m_flSpeed = 100;
	m_strOnDeath = __NULL__;
	m_strOnDeathLegacy = __NULL__;
}

void
func_guntarget::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveString(handle, "m_strOnDeath", m_strOnDeath);
	SaveString(handle, "m_strOnDeathLegacy", m_strOnDeathLegacy);
}

void
func_guntarget::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flSpeed":
		m_flSpeed =  ReadFloat(strValue);
		break;
	case "m_strOnDeath":
		m_strOnDeath = ReadString(strValue);
		break;
	case "m_strOnDeathLegacy":
		m_strOnDeathLegacy = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_guntarget::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "message":
		m_strOnDeathLegacy = strValue;
		break;
	case "OnDeath":
		m_strOnDeath = PrepareOutput(m_strOnDeath, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_guntarget::Spawned(void)
{
	super::Spawned();

	if (m_strOnDeath)
		m_strOnDeath = CreateOutput(m_strOnDeath);
}

void
func_guntarget::Respawn(void)
{
	static void ThinkWrap(void) {
		Trigger(this, TRIG_TOGGLE);
	}

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetHealth(GetSpawnHealth());

	if (HasSpawnFlags(SF_GUNTARGET_ON) == true) {
		ScheduleThink(ThinkWrap, 0.25f);
	}
}

void
func_guntarget::Move(void)
{
	float flTravelTime;
	vector vel_to_pos;
	path_corner node;

	node = (path_corner)find(world, ::targetname, target);

	if (!node) {
		EntWarning("node %s for %s not found!", target, targetname);
		return;
	}

	vector vecWorldPos;
	vecWorldPos = WorldSpaceCenter();

	vel_to_pos = (node.origin - vecWorldPos);
	flTravelTime = (vlen(vel_to_pos) / m_flSpeed);

	if (flTravelTime <= 0.0f) {
		NextPath();
		return;
	}

	SetVelocity(vel_to_pos * (1 / flTravelTime));
	ScheduleThink(NextPath, flTravelTime);
}

void
func_guntarget::NextPath(void)
{
	path_corner node;

	EntLog("Talking to current target %s... ", target);
	node = (path_corner)find(world, ::targetname, target);

	if (!node) {
		dprint("^1FAILED.\n");
	} else {
		dprint("^2SUCCESS.\n");
	}

	target = node.target;
	ClearVelocity();

	if (target) {
		Move();
	}
}

void
func_guntarget::Death(void)
{
	Stop();

	if (!m_strOnDeath && !m_strOnDeathLegacy) {
		return;
	}

	if (!m_strOnDeathLegacy) {
		UseOutput(g_dmg_eAttacker, m_strOnDeath);
	} else {
		entity a;
		for (a = world; (a = find(a, ::targetname, m_strOnDeathLegacy));) {
			NSEntity trigger = (NSEntity)a;
			trigger.Trigger(g_dmg_eAttacker, TRIG_TOGGLE);
		}
	}
}

void
func_guntarget::Start(void)
{
	SetTakedamage(DAMAGE_YES);
	NextPath();
	m_iValue = 0;
}

void
func_guntarget::Stop(void)
{
	SetTakedamage(DAMAGE_NO);
	ClearVelocity();
	ReleaseThink();
	m_iValue = 1;
}

void
func_guntarget::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_iValue = 0;
		break;
	case TRIG_ON:
		m_iValue = 1;
		break;
	default:
		m_iValue = 1 - m_iValue;
	}

	if (m_iValue) {
		Start();
	} else {
		Stop();
	}
}

void
func_guntarget::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Start":
		Trigger(eAct, TRIG_ON);
		break;
	case "Stop":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
