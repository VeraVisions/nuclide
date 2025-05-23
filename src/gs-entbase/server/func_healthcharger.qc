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

/*! \brief Server-Entity: Health Charging Station */
/*!QUAKED func_healthcharger (0 .5 .8) ?
# OVERVIEW
Brush that fills up your health when used, to a maximum of 100 HP.

![A working func_healthcharger, mounted against a wall](@ref func_healthcharger.jpg)

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "snd_first" : Sound to play when first used.
- "snd_charging" : Sound to play when first charging.
- "snd_done" : Sound to play when first finished charging.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_healthcharger:ncRenderableEntity
{
public:
	void func_healthcharger(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Precache(void);
	virtual void SpawnKey(string,string);
	virtual void customphysics(void);
	virtual void Respawn(void);
	
	virtual void OnPlayerUse(void);
	nonvirtual void ResetHealth(void);
	nonvirtual void SetChargerCapacity(float);
	nonvirtual float GetChargerCapacity(void);

private:
	ncEntity m_eUser;
	float m_flDelay;
	float m_flCheck;

	string m_strSndFirst;
	string m_strSndCharging;
	string m_strSndDone;
};

void
func_healthcharger::func_healthcharger(void)
{
	m_eUser = __NULL__;
	m_flDelay = 0.0f;
	m_flCheck = 0.0f;
	m_strSndFirst = "items/medshot4.wav";
	m_strSndCharging = "items/medcharge4.wav";
	m_strSndDone = "items/medshotno1.wav";
}

void
func_healthcharger::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "user", m_eUser);
	SaveFloat(handle, "delay", m_flDelay);
	SaveFloat(handle, "check", m_flCheck);
	SaveString(handle, "snd_first", m_strSndFirst);
	SaveString(handle, "snd_charging", m_strSndCharging);
	SaveString(handle, "snd_done", m_strSndDone);
}

void
func_healthcharger::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "user":
		m_eUser = (ncEntity)ReadEntity(setValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "check":
		m_flCheck = ReadFloat(setValue);
		break;
	case "snd_first":
		m_strSndFirst = ReadString(setValue);
		break;
	case "snd_charging":
		m_strSndCharging = ReadString(setValue);
		break;
	case "snd_done":
		m_strSndDone = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_healthcharger::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "snd_first":
		m_strSndFirst = setValue;
		break;
	case "snd_charging":
		m_strSndCharging = setValue;
		break;
	case "snd_done":
		m_strSndDone = setValue;
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_healthcharger::Precache(void)
{
	precache.Sound(m_strSndFirst);
	precache.Sound(m_strSndCharging);
	precache.Sound(m_strSndDone);
}

void
func_healthcharger::Respawn(void)
{
	super::Respawn();
	
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	PlayerUse = OnPlayerUse;
	ResetHealth();
}

void
func_healthcharger::SetChargerCapacity(float newCapacity)
{
	health = newCapacity;
}

float
func_healthcharger::GetChargerCapacity(void)
{
	return (health);
}

void
func_healthcharger::ResetHealth(void)
{
	float startHealth = Skill_GetValue("healthcharger", 50);

	if (GetChargerCapacity() <= 0) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	SetFrame(0);
	SetChargerCapacity(startHealth);
}

void
func_healthcharger::OnPlayerUse(void)
{
	/* let's not let this become too funny... */
	if (eActivator.health <= 0) {
		return;
	}

	eActivator.AddVFlags(VFL_USE_RELEASED);

	/* First come first serve */ 
	if (m_eUser && eActivator != m_eUser) {
		return;
	}

	/* First time */
	if (m_eUser == __NULL__) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	if (m_flDelay > GetTime()) {
		return;
	}

	if (GetChargerCapacity() <= 0) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_strSndDone, CHAN_VOICE, 0, true);
		m_eUser = __NULL__;
		return;
	}

	if (eActivator.health >= 100) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_strSndDone, CHAN_VOICE, 0, true);
	} else {
		if (m_eUser == __NULL__) {
			StartSound(m_strSndCharging, CHAN_ITEM, 0, true);
		}

		eActivator.health = (bound(0, eActivator.health += 1, 100));

		/* Reset 30 seconds after first being used successfully */
		//if (health == max_health) {
			ScheduleThink(ResetHealth, 60.0f);
		//}
		SetChargerCapacity(GetChargerCapacity() - 1);

		/* Disable when empty */
		if (GetChargerCapacity() <= 0) {
			StopSound(CHAN_ITEM, true);
			StartSound(m_strSndDone, CHAN_VOICE, 0, true);
			SetFrame(1);
			eActivator.RemoveVFlags(VFL_USE_RELEASED);
			m_eUser = __NULL__;
			return;
		}
	}

	m_eUser = eActivator;
	m_flDelay = GetTime() + 0.1f;
	m_flCheck = GetTime() + 0.25f;
}

void
func_healthcharger::customphysics(void)
{
	if (m_flCheck > GetTime()) {
		return;
	}

	if (m_eUser) {
		StopSound(CHAN_ITEM, true);
		m_eUser = __NULL__;
	}

	HandleThink();
}
