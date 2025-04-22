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
/*!QUAKED item_recharge (0 .5 .8) ?
# OVERVIEW
Brush that fills up your health when used, to a maximum of 100 HP.

![A working item_recharge, mounted against a wall](@ref item_recharge.jpg)

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "snd_first" : Sound to play when first used.
- "snd_charging" : Sound to play when first charging.
- "snd_done" : Sound to play when first finished charging.

# TRIVIA
This entity was introduced in Half-Life for PS2 (2001).

@ingroup serverentity
@ingroup pointentity
*/
class
item_recharge:ncRenderableEntity
{
public:
	void item_recharge(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Precache(void);
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
	ncEntity m_eUser;
	ncRenderableEntity m_eProgressMeter;
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
item_recharge::item_recharge(void)
{
	m_eUser = __NULL__;
	m_flDelay = 0.0f;
	m_flCheck = 0.0f;
	m_strSndFirst = "items/medshot4.wav";
	m_strSndCharging = "items/medcharge4.wav";
	m_strSndDone = "items/medshotno1.wav";
}
void
item_recharge::Save(float handle)
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
item_recharge::Restore(string strKey, string setValue)
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
item_recharge::SpawnKey(string strKey, string setValue)
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
item_recharge::Precache(void)
{
	precache.Sound(m_strSndFirst);
	precache.Sound(m_strSndCharging);
	precache.Sound(m_strSndDone);
}


void
item_recharge::Deploy(void)
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
item_recharge::GiveShot(void)
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
item_recharge::Retract(void)
{
	SetFrame(HEALTHCHARGER_FRAMEGROUP_RETRACT);
	m_toucher = __NULL__;
}

void
item_recharge::RetractShot(void)
{
	SetFrame(HEALTHCHARGER_FRAMEGROUP_RETRACTSHOT);
	m_eProgressMeter.SetFrame(2);
	m_flAnimationTime = 0.5f;
}

void
item_recharge::UpdateProgress(void)
{
	m_eProgressMeter.SetBoneController1(-10 * (1.0 - (health/max_health)));
}

void
item_recharge::Disable(void)
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
item_recharge::Enable(void)
{
	SetSkin(0);
}

void
item_recharge::Respawn(void)
{
	static void item_recharge_notify(void) {
		item_recharge parent = (item_recharge)self.owner;
		parent.Deploy();
		parent.m_toucher = other;
	}

	super::Respawn();

	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetModel("models/hev.mdl");
	SetSize([-16,-16,-24], [16,16,24]);
	PlayerUse = OnPlayerUse;
	ResetHealth();

	if (!m_chargeZone) {
		m_chargeZone = spawn();
		setorigin(m_chargeZone, GetOrigin());
		m_chargeZone.solid = SOLID_TRIGGER;
		m_chargeZone.movetype = MOVETYPE_NONE;
		m_chargeZone.touch = item_recharge_notify;
		m_chargeZone.owner = this;
		setsize(m_chargeZone, [-96,-96,-96], [96,96,96]);
	}

	if (!m_eProgressMeter) {
		m_eProgressMeter = spawn(ncRenderableEntity);
		m_eProgressMeter.Spawn();
		m_eProgressMeter.SetOrigin(GetOrigin());
		m_eProgressMeter.SetAngles(GetAngles());
		m_eProgressMeter.SetMovetype(MOVETYPE_NONE);
		m_eProgressMeter.SetRenderMode(RM_COLOR);
		m_eProgressMeter.SetRenderColor([255,255,255]);
		m_eProgressMeter.SetRenderAmt(64);
		m_eProgressMeter.SetModel("models/field.mdl");
	}
}

void
item_recharge::ResetHealth(void)
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
item_recharge::OnPlayerUse(void)
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
item_recharge::customphysics(void)
{
	if ((health && m_toucher) && (GetFrame() == HEALTHCHARGER_FRAMEGROUP_DEPLOY || GetFrame() == HEALTHCHARGER_FRAMEGROUP_RETRACTSHOT || GetFrame() == HEALTHCHARGER_FRAMEGROUP_GIVESHOT)) {
		vector vecDelta;
		vecDelta = vectorNormalize(m_toucher.origin - GetOrigin() );
		m_flSwingArm = ((1.0 + (vecDelta * anglesToRight(angles))) * 0.5);
		m_flSwingArm = lerp(-80, 90, 1.0 - m_flSwingArm);
	} else {
		m_flSwingArm = 0.0f;
	}

	SetBoneController1(lerp(GetBoneController1(), m_flSwingArm, frametime * 20.0f));
	SetBoneController2(GetBoneController1());

	if (m_flCheck > GetTime())
		return;

	if (m_eUser) {
		StopSound(CHAN_ITEM, true);
		m_eUser = __NULL__;
		RetractShot();
	}

	HandleThink();
}
