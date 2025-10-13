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

#ifdef SERVER
/*! \brief Server-Entity: Recharging Station */
/*!QUAKED ncCharger (0 .5 .8) ?
# OVERVIEW
Object that fills up the health, armor or ammo values of
an entity that's interacting with it without removing itself
from the world.

Can be used, but a player can also stand within its volume when
set up that way.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "snd_first" : Sound to play when first used.
- "snd_charging" : Sound to play when first charging.
- "snd_done" : Sound to play when first finished charging.

@ingroup server
@ingroup brushentity
*/
class
ncCharger:ncRenderableEntity
{
public:
	void ncCharger(void);
	
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
	entity m_chargestationUser;
	float m_timeUntilNextDrop;
	float m_timeUntilUserCheck;
	string m_sndFirst;
	string m_sndCharging;
	string m_sndDone;
	string m_refillType;
	float m_startCharge;
	bool m_doesReset;
	bool m_resetOnEmpty;
	bool m_resetOnFirstUse;
	float m_resetDelay;
	bool m_frametimeTransfer;
};

void
ncCharger::ncCharger(void)
{
	m_sndFirst = "";
	m_sndCharging = "";
	m_sndDone = "";
	m_chargestationUser = __NULL__;
	m_timeUntilNextDrop = 0.0f;
	m_timeUntilUserCheck = 0.0f;
	m_refillType = "health";
	m_startCharge = 100.0f;
	m_doesReset = false;
	m_resetOnEmpty = true;
	m_resetOnFirstUse = false;
	m_resetDelay = 30.0f;
	m_frametimeTransfer = false;
}

void
ncCharger::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_chargestationUser", m_chargestationUser);
	SaveFloat(handle, "m_timeUntilNextDrop", m_timeUntilNextDrop);
	SaveFloat(handle, "m_timeUntilUserCheck", m_timeUntilUserCheck);
	SaveString(handle, "m_sndFirst", m_sndFirst);
	SaveString(handle, "m_sndCharging", m_sndCharging);
	SaveString(handle, "m_sndDone", m_sndDone);
	SaveString(handle, "m_refillType", m_refillType);
	SaveFloat(handle, "m_startCharge", m_startCharge);
	SaveBool(handle, "m_doesReset", m_doesReset);
	SaveBool(handle, "m_resetOnEmpty", m_resetOnEmpty);
	SaveBool(handle, "m_resetOnFirstUse", m_resetOnFirstUse);
	SaveFloat(handle, "m_resetDelay", m_resetDelay);
	SaveBool(handle, "m_frametimeTransfer", m_frametimeTransfer);
}

void
ncCharger::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_chargestationUser":
		m_chargestationUser = ReadEntity(setValue);
		break;
	case "m_timeUntilNextDrop":
		m_timeUntilNextDrop = ReadFloat(setValue);
		break;
	case "m_timeUntilUserCheck":
		m_timeUntilUserCheck = ReadFloat(setValue);
		break;
	case "m_sndFirst":
		m_sndFirst = ReadString(setValue);
		break;
	case "m_sndCharging":
		m_sndCharging = ReadString(setValue);
		break;
	case "m_sndDone":
		m_sndDone = ReadString(setValue);
		break;
	case "m_refillType":
		m_refillType = ReadString(setValue);
		break;
	case "m_startCharge":
		m_startCharge = ReadFloat(setValue);
		break;

	case "m_doesReset":
		m_doesReset = ReadBool(setValue);
		break;
	case "m_resetOnEmpty":
		m_resetOnEmpty = ReadBool(setValue);
		break;
	case "m_resetOnFirstUse":
		m_resetOnFirstUse = ReadBool(setValue);
		break;
	case "m_resetDelay":
		m_resetDelay = ReadFloat(setValue);
		break;
	case "m_frametimeTransfer":
		m_frametimeTransfer = ReadBool(setValue);
		break;

	default:
		super::Restore(keyName, setValue);
	}
}

void
ncCharger::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "snd_first":
		m_sndFirst = ReadString(setValue);
		break;
	case "snd_charging":
		m_sndCharging = ReadString(setValue);
		break;
	case "snd_done":
		m_sndDone = ReadString(setValue);
		break;
	case "chargeType":
		m_refillType = ReadString(setValue);
		break;
	case "charge":
		m_startCharge = ReadFloat(setValue);
		break;
	case "resets":
		m_doesReset = ReadBool(setValue);
		break;
	case "resetsOnEmpty":
		m_resetOnEmpty = ReadBool(setValue);
		break;
	case "resetsOnFirstUse":
		m_resetOnFirstUse = ReadBool(setValue);
		break;
	case "resetDelay":
		m_resetDelay = ReadFloat(setValue);
		break;
	case "frametimeTransfer":
		m_frametimeTransfer = ReadBool(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
ncCharger::Spawned(void)
{
	super::Spawned();

	precache_sound(m_sndFirst);
	precache_sound(m_sndCharging);
	precache_sound(m_sndDone);
}

void
ncCharger::Respawn(void)
{
	super::Respawn();

	if (m_modelBrushBased == true) {
		SetSolid(SOLID_BSP);
	} else {
		SetSolid(SOLID_BBOX);
	}

	SetMovetype(MOVETYPE_NONE);
	PlayerUse = OnPlayerUse;
	ResetHealth();

	if (m_frametimeTransfer) {
		/* the animation on this entity will not advance on its own. */
		m_nuclideFlags = VFL_NOFRAMEADVANCE;
	}
}

void
ncCharger::ResetHealth(void)
{
	if (health <= 0) {
		StartSound(m_sndFirst, CHAN_VOICE, 0, true);
	}

	SetFrame(0);
	health = max_health = m_startCharge;
}

void
ncCharger::OnPlayerUse(void)
{
	/* let's not let this become too funny... */
	if (eActivator.health <= 0) {
		return;
	}

	eActivator.AddVFlags(VFL_USE_RELEASED);

	/* First come first serve */ 
	if (m_chargestationUser && eActivator != m_chargestationUser) {
		return;
	}

	/* First time */
	if (m_chargestationUser == world) {
		StartSound(m_sndFirst, CHAN_VOICE, 0, true);
	}

	if (m_timeUntilNextDrop > GetTime()) {
		return;
	}

	if (health <= 0) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_sndDone, CHAN_VOICE, 0, true);
		m_chargestationUser = world;
		return;
	}

	ncPlayer pl = (ncPlayer)eActivator;
	bool playerAtMax = false;

	if (m_refillType == "armor") {
		if (pl.armor > pl.max_armor) {
			playerAtMax = true;
		}
	} else if (m_refillType == "health") {
		if (pl.health > pl.max_health) {
			playerAtMax = true;
		}
	}

	if (playerAtMax) {
		eActivator.RemoveVFlags(VFL_USE_RELEASED);
		StartSound(m_sndDone, CHAN_VOICE, 0, true);
	} else {
		bool resets = m_doesReset;

		if (m_chargestationUser == world) {
			StartSound(m_sndCharging, CHAN_ITEM, 0, true);
		}

		if (m_refillType == "armor") {
			pl.armor = bound(0, pl.armor += 1, pl.max_armor);
		} else if (m_refillType == "health") {
			pl.health = bound(0, pl.health += 1, pl.max_health);
		}

		/* nowhere near empty */
		if (m_resetOnEmpty && health > 1) {
			resets = false;
		}

		/* already been used. */
		if (m_resetOnFirstUse && health < max_health) {
			resets = false;
		}

		if (resets) {
			ScheduleThink(ResetHealth, 30.0f);
		}

		health -= 1;

		if (m_frametimeTransfer) {
			float maxValue = frameduration(modelindex, frame);
			frame1time = maxValue - ((health / max_health) * maxValue);
		}

		/* Disable when empty */
		if (health <= 0) {
			StopSound(CHAN_ITEM, true);
			StartSound(m_sndDone, CHAN_VOICE, 0, true);
			SetFrame(1);
			eActivator.RemoveVFlags(VFL_USE_RELEASED);
			m_chargestationUser = world;
			return;
		}
	}

	m_chargestationUser = eActivator;
	m_timeUntilNextDrop = GetTime() + 0.1f;
	m_timeUntilUserCheck = GetTime() + 0.25f;
}

void
ncCharger::customphysics(void)
{
	if (m_timeUntilUserCheck > GetTime()) {
		return;
	}

	if (m_chargestationUser) {
		StopSound(CHAN_ITEM, true);
		m_chargestationUser = world;
	}

	HandleThink();
}
#endif
