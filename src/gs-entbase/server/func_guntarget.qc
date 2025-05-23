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

/*! \brief Server-Entity: Target Practice Sign */
/*!QUAKED func_guntarget (0 .5 .8) ?
# OVERVIEW
Brushes that triggers a target once they 'die'. It moves around.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "health" : Health until it stops and triggers its targets.
- "speed" : Speed in units per second at which it moves.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_guntarget:ncSurfacePropEntity
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
	virtual void Death(entity, entity, int, vector, vector, int);
	
	nonvirtual void NextPath(void);
	nonvirtual void Move(void);
	nonvirtual void Start(void);
	nonvirtual void Stop(void);

	virtual void Input(entity, string, string);

private:
	float m_flSpeed;
	string m_outputOnDeath;
	string m_outputOnDeathLegacy;
};

void
func_guntarget::func_guntarget(void)
{
	m_flSpeed = 100;
	m_outputOnDeath = __NULL__;
	m_outputOnDeathLegacy = __NULL__;
}

void
func_guntarget::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveString(handle, "m_outputOnDeath", m_outputOnDeath);
	SaveString(handle, "m_outputOnDeathLegacy", m_outputOnDeathLegacy);
}

void
func_guntarget::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flSpeed":
		m_flSpeed =  ReadFloat(setValue);
		break;
	case "m_outputOnDeath":
		m_outputOnDeath = ReadString(setValue);
		break;
	case "m_outputOnDeathLegacy":
		m_outputOnDeathLegacy = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_guntarget::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(setValue);
		break;
	case "message":
		m_outputOnDeathLegacy = setValue;
		break;
	case "OnDeath":
		m_outputOnDeath = PrepareOutput(m_outputOnDeath, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_guntarget::Spawned(void)
{
	super::Spawned();

	if (STRING_SET(m_outputOnDeath)) {
		m_outputOnDeath = CreateOutput(m_outputOnDeath);
	}
}

void
func_guntarget::Respawn(void)
{
	static void ThinkWrap(void) {
		Trigger(this, TRIG_TOGGLE);
	}

	super::Respawn();

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);

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
		EntLog("^1FAILED.\n");
	} else {
		EntLog("^2SUCCESS.\n");
	}

	target = node.target;
	ClearVelocity();

	if (target) {
		Move();
	}
}

void
func_guntarget::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	Stop();

	if (!STRING_SET(m_outputOnDeath) && !STRING_SET(m_outputOnDeathLegacy)) {
		return;
	}

	if (!m_outputOnDeathLegacy) {
		UseOutput(attacker, m_outputOnDeath);
	} else {
		entity a;
		for (a = world; (a = find(a, ::targetname, m_outputOnDeathLegacy));) {
			ncEntity trigger = (ncEntity)a;
			trigger.Trigger(attacker, TRIG_TOGGLE);
		}
	}
}

void
func_guntarget::Start(void)
{
	MakeVulnerable();
	NextPath();
	SetValue(0i);
}

void
func_guntarget::Stop(void)
{
	MakeInvulnerable();
	ClearVelocity();
	ReleaseThink();
	SetValue(1i);
}

void
func_guntarget::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetValue(0i);
		break;
	case TRIG_ON:
		SetValue(1i);
		break;
	default:
		SetValue(1i - GetValue(this));
	}

	if (GetValue(this)) {
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
