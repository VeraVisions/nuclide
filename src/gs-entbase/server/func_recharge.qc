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

/*! \brief Server-Entity: Armor Recharging Station */
/*!QUAKED func_recharge (0 .5 .8) ?
# OVERVIEW
Brush that fills up your armor when used, to a maximum of 100 points.
Known as the "H.E.V. Charger", formerly known as the "Super Charger".

![A working func_recharge, mounted against a wall](@ref func_recharge.jpg)

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
func_recharge:ncRenderableEntity
{
public:
	void func_recharge(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void customphysics(void);
	
	virtual void OnPlayerUse(void);
	nonvirtual void ResetHealth(void);

private:
	entity m_eUser;
	float m_flDelay;
	float m_flCheck;

	string m_strSndFirst;
	string m_strSndCharging;
	string m_strSndDone;
};

void
func_recharge::func_recharge(void)
{
	m_strSndFirst = "items/suitchargeok1.wav";
	m_strSndCharging = "items/suitcharge1.wav";
	m_strSndDone = "items/suitchargeno1.wav";
	m_eUser = __NULL__;
	m_flDelay = 0.0f;
	m_flCheck = 0.0f;
}

void
func_recharge::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_eUser", m_eUser);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flCheck", m_flCheck);
	SaveString(handle, "m_strSndFirst", m_strSndFirst);
	SaveString(handle, "m_strSndCharging", m_strSndCharging);
	SaveString(handle, "m_strSndDone", m_strSndDone);
}

void
func_recharge::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eUser":
		m_eUser = ReadEntity(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_flCheck":
		m_flCheck = ReadFloat(strValue);
		break;
	case "m_strSndFirst":
		m_strSndFirst = ReadString(strValue);
		break;
	case "m_strSndCharging":
		m_strSndCharging = ReadString(strValue);
		break;
	case "m_strSndDone":
		m_strSndDone = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_recharge::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "snd_first":
		m_strSndFirst = strValue;
		break;
	case "snd_charging":
		m_strSndCharging = strValue;
		break;
	case "snd_done":
		m_strSndDone = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_recharge::Spawned(void)
{
	super::Spawned();

	precache_sound(m_strSndFirst);
	precache_sound(m_strSndCharging);
	precache_sound(m_strSndDone);
}

void
func_recharge::Respawn(void)
{
	super::Respawn();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	PlayerUse = OnPlayerUse;
	ResetHealth();
}

void
func_recharge::ResetHealth(void)
{
	if (health <= 0) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	SetFrame(0);

	if (g_grMode.IsMultiplayer() == true)
		health = max_health = 30.0f;
	else
		health = max_health = Skill_GetValue("suitcharger", 75);
}

void
func_recharge::OnPlayerUse(void)
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
	if (m_eUser == world) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	if (m_flDelay > GetTime()) {
		return;
	}

	if (health <= 0) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_strSndDone, CHAN_VOICE, 0, true);
		m_eUser = world;
		return;
	}

	ncPlayer pl = (ncPlayer)eActivator;
	if (pl.armor >= 100) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_strSndDone, CHAN_VOICE, 0, true);
	} else {
		if (m_eUser == world) {
			StartSound(m_strSndCharging, CHAN_ITEM, 0, true);
		}

		pl.armor = bound(0, pl.armor += 1, 100);

		/* Reset 30 seconds after first being used successfully */
		//if (health == max_health) {
			ScheduleThink(ResetHealth, 30.0f);
		//}
		health -= 1;

		/* Disable when empty */
		if (health <= 0) {
			StopSound(CHAN_ITEM, true);
			StartSound(m_strSndDone, CHAN_VOICE, 0, true);
			SetFrame(1);
			eActivator.RemoveVFlags(VFL_USE_RELEASED);
			m_eUser = world;
			return;
		}
	}

	m_eUser = eActivator;
	m_flDelay = GetTime() + 0.1f;
	m_flCheck = GetTime() + 0.25f;
}

void
func_recharge::customphysics(void)
{
	if (m_flCheck > GetTime()) {
		return;
	}

	if (m_eUser) {
		sound(this, CHAN_ITEM, "common/null.wav", 1.0, ATTN_NORM);
		m_eUser = world;
	}

	HandleThink();
}
