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

enum
{
	HEALTHCHARGER_FRAMEGROUP_IDLE,
	HEALTHCHARGER_FRAMEGROUP_DEPLOY,
	HEALTHCHARGER_FRAMEGROUP_RETRACT,
	HEALTHCHARGER_FRAMEGROUP_GIVESHOT,
	HEALTHCHARGER_FRAMEGROUP_RETRACTSHOT,
	HEALTHCHARGER_FRAMEGROUP_PREPSHOT,
	HEALTHCHARGER_FRAMEGROUP_SHOTIDLE,
};

/*! \brief Server-Entity: Health Charging Station */
/*!QUAKED item_healthcharger (0 .5 .8) ?
# OVERVIEW
Brush that fills up your health when used, to a maximum of 100 HP.

![A working item_healthcharger, mounted against a wall](@ref item_healthcharger.jpg)

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "snd_first" : Sound to play when first used.
- "snd_charging" : Sound to play when first charging.
- "snd_done" : Sound to play when first finished charging.

# TRIVIA
This entity was introduced in Half-Life for PS2 (2001).

@ingroup server
@ingroup pointentity
*/
class
item_healthcharger:NSRenderableEntity
{
public:
	void item_healthcharger(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Spawned(void);
	virtual void SpawnKey(string,string);
	virtual void customphysics(void);
	virtual void Respawn(void);
	
	virtual void OnPlayerUse(void);
	nonvirtual void Deploy(void);
	nonvirtual void Retract(void);
	nonvirtual void ResetHealth(void);
	nonvirtual void UpdateProgress(void);
	nonvirtual void Disable(void);
	nonvirtual void Enable(void);
	nonvirtual void GiveShot(void);
	nonvirtual void RetractShot(void);

private:
	entity m_toucher;
	entity m_chargeZone;
	NSEntity m_eUser;
	NSRenderableEntity m_eProgressMeter;
	float m_flDelay;
	float m_flCheck;

	string m_strSndFirst;
	string m_strSndCharging;
	string m_strSndDone;
	float m_flAnimationTime;
	float m_flDesiredFrame;
	float m_flSwingArm;
	float m_flRadiusCheck;
};

void
item_healthcharger::item_healthcharger(void)
{
	m_eUser = __NULL__;
	m_flDelay = 0.0f;
	m_flCheck = 0.0f;
	m_strSndFirst = "items/medshot4.wav";
	m_strSndCharging = "items/medcharge4.wav";
	m_strSndDone = "items/medshotno1.wav";
}
void
item_healthcharger::Save(float handle)
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
item_healthcharger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "user":
		m_eUser = (NSEntity)ReadEntity(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "check":
		m_flCheck = ReadFloat(strValue);
		break;
	case "snd_first":
		m_strSndFirst = ReadString(strValue);
		break;
	case "snd_charging":
		m_strSndCharging = ReadString(strValue);
		break;
	case "snd_done":
		m_strSndDone = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
item_healthcharger::SpawnKey(string strKey, string strValue)
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
item_healthcharger::Spawned(void)
{
	super::Spawned();

	precache_sound(m_strSndFirst);
	precache_sound(m_strSndCharging);
	precache_sound(m_strSndDone);
}


void
item_healthcharger::Deploy(void)
{
	if (health <= 0) {
		ScheduleThink(Retract, 1.0f);
		return;
	}

	ScheduleThink(Retract, 2.0f);

	if (m_flAnimationTime > GetTime())
		return;

	/* Play the deploy animation, prevent any other animation for half a second */

	if ( (GetFrame() == HEALTHCHARGER_FRAMEGROUP_IDLE) || (GetFrame() == HEALTHCHARGER_FRAMEGROUP_RETRACT) )
		SetFrame(HEALTHCHARGER_FRAMEGROUP_DEPLOY);
}


void
item_healthcharger::GiveShot(void)
{
	if (GetFrame() != HEALTHCHARGER_FRAMEGROUP_GIVESHOT) {
		SetFrame(HEALTHCHARGER_FRAMEGROUP_GIVESHOT);
	}

	if (m_flAnimationTime < GetTime()) {
		m_eProgressMeter.SetFrame(1);
		m_eProgressMeter.frame1time = 0.0f;
		m_flAnimationTime = GetTime() + 0.5f;
	}
}


void
item_healthcharger::Retract(void)
{
	SetFrame(HEALTHCHARGER_FRAMEGROUP_RETRACT);
	m_toucher = __NULL__;
}

void
item_healthcharger::RetractShot(void)
{
	SetFrame(HEALTHCHARGER_FRAMEGROUP_RETRACTSHOT);
	m_eProgressMeter.SetFrame(2);
	m_flAnimationTime = 0.5f;
}

void
item_healthcharger::UpdateProgress(void)
{
	m_eProgressMeter.m_flBoneControl1 = -10 * (1.0 - (health/max_health));
}

void
item_healthcharger::Disable(void)
{
	SetSkin(1);
	Retract();
	ScheduleThink(ResetHealth, 60.0f);
	m_toucher = __NULL__;
	health = 0;

	StopSound(CHAN_ITEM, true);
	StartSound(m_strSndDone, CHAN_VOICE, 0, true);
}

void
item_healthcharger::Enable(void)
{
	SetSkin(0);
}

void
item_healthcharger::Respawn(void)
{
	static void item_healthcharger_notify(void) {
		item_healthcharger parent = (item_healthcharger)self.owner;
		parent.Deploy();
		parent.m_toucher = other;
	}

	super::Respawn();

	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetModel("models/health_charger_body.mdl");
	SetSize([-16,-16,-24], [16,16,24]);
	PlayerUse = OnPlayerUse;
	ResetHealth();

	if (!m_chargeZone) {
		m_chargeZone = spawn();
		setorigin(m_chargeZone, GetOrigin());
		m_chargeZone.solid = SOLID_TRIGGER;
		m_chargeZone.movetype = MOVETYPE_NONE;
		m_chargeZone.touch = item_healthcharger_notify;
		m_chargeZone.owner = this;
		setsize(m_chargeZone, [-96,-96,-96], [96,96,96]);
	}

	if (!m_eProgressMeter) {
		m_eProgressMeter = spawn(NSRenderableEntity);
		m_eProgressMeter.SetOrigin(GetOrigin());
		m_eProgressMeter.SetAngles(GetAngles());
		m_eProgressMeter.SetMovetype(MOVETYPE_NONE);
		m_eProgressMeter.SetRenderMode(RM_COLOR);
		m_eProgressMeter.SetRenderColor([255,255,255]);
		m_eProgressMeter.SetRenderAmt(64);
		m_eProgressMeter.SetModel("models/health_charger_both.mdl");
	}
}

void
item_healthcharger::ResetHealth(void)
{
	if (health <= 0) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	health = max_health = Skill_GetValue("healthcharger", 50);
	SetFrame(HEALTHCHARGER_FRAMEGROUP_IDLE);
	UpdateProgress();
	Enable();
}

void
item_healthcharger::OnPlayerUse(void)
{
	bool firstTime = false;

	/* let's not let this become too funny... */
	if (eActivator.health <= 0)
		return;

	eActivator.AddVFlags(VFL_USE_RELEASED);

	/* First come first serve */ 
	if (m_eUser && eActivator != m_eUser)
		return;

	/* First time */
	if (m_eUser == __NULL__) {
		StartSound(m_strSndFirst, CHAN_VOICE, 0, true);
	}

	if (m_flDelay > GetTime())
		return;

	if (health <= 0) {
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

		eActivator.health = bound(0, eActivator.health += 1, 100);
		GiveShot();
		health -= 1;
		UpdateProgress();

		/* Disable when empty */
		if (health <= 0) {
			eActivator.RemoveVFlags(VFL_USE_RELEASED);
			m_eUser = __NULL__;
			RetractShot();
			Disable();
			return;
		}
	}

	m_eUser = eActivator;
	m_flDelay = GetTime() + 0.1f;
	m_flCheck = GetTime() + 0.25f;
}

void
item_healthcharger::customphysics(void)
{
	if ((health && m_toucher) && (GetFrame() == HEALTHCHARGER_FRAMEGROUP_DEPLOY || GetFrame() == HEALTHCHARGER_FRAMEGROUP_RETRACTSHOT || GetFrame() == HEALTHCHARGER_FRAMEGROUP_GIVESHOT)) {
		vector vecDelta;
		vecDelta = vectorNormalize(m_toucher.origin - GetOrigin() );
		m_flSwingArm = ((1.0 + (vecDelta * anglesToRight(angles))) * 0.5);
		m_flSwingArm = lerp(-80, 90, 1.0 - m_flSwingArm);
	} else {
		m_flSwingArm = 0.0f;
	}

	SetBoneControl1(lerp(GetBoneControl1(), m_flSwingArm, frametime * 20.0f));
	SetBoneControl2(GetBoneControl1());

	if (m_flCheck > GetTime())
		return;

	if (m_eUser) {
		StopSound(CHAN_ITEM, true);
		m_eUser = __NULL__;
		RetractShot();
	}

	HandleThink();
}
