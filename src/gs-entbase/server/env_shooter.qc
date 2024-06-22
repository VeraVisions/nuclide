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

#define EVSHOOTER_REPEATABLE 1

/*! \brief Server-Entity: Model Shooter */
/*!QUAKED env_shooter (1 .5 0) (-8 -8 -8) (8 8 8) EVSHOOTER_REPEATABLE
# OVERVIEW
Shoots model entities from its location.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll direction of the shooter.
- "shootmodel" : Model file to shoot.
- "shootsounds" : PCM sample to play whenever a piece shoots out.
- "m_iGibs" : Amount of models shot in total.
- "m_flDelay" : Delay before being able to be fired again.
- "m_flVelocity" : Speed of the models in units per second.
- "delay" : Delay between shots.
- "m_flVariance" : Variance in shot trajectory.
- "m_flGibLife" : Life of the individual model piece.
- "scale" : Scale modifier of the model pieces.

# INPUTS
- "Shoot" : Causes the shooter to shoot.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup pointentity
*/
class
env_shooter:NSRenderableEntity
{
public:
	void env_shooter(void);

	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	nonvirtual void ShootGib(void);
	nonvirtual void ShooterLoop(void);

private:
	int m_iGibs;
	int m_iGibsLeft;

	float m_flDelay;
	float m_flVelocity;
	float m_flVariance;
	float m_flGibLife;
	string m_strShootModel;
	float m_flShootSounds;
	float m_flScale;
	float m_flSkin;
	bool m_bCanScale;
};

void
env_shooter::env_shooter(void)
{
	m_flVariance = 0.0f;
	m_flDelay = 0.0f;
	m_iGibs = 1;
	m_iGibsLeft = 1;
	m_flVelocity = 0;
	m_flGibLife = 1.0f;
	m_strShootModel = __NULL__;
	m_flShootSounds = 0;
	m_flScale = 1.0;
	m_flSkin = 0;
	m_bCanScale = false;
}

void
env_shooter::Spawned(void)
{
	super::Spawned();

	if (m_strShootModel) {
		precache_model(m_strShootModel);
	}

	/* There isn't a much more portable to do this, maybe this can be abstracted
		through separate soundDef entries but I don't know if that'll be less annoying. */
	switch (m_flShootSounds) {
	case 0:	/* glass */
		Sound_Precache("func_breakable.impact_glass");
		break;
	case 1:	/* wood */
		Sound_Precache("func_breakable.impact_wood");
		break;
	case 2:	/* metal */
		Sound_Precache("func_breakable.impact_metal");
		break;
	case 3: /* flesh */
		Sound_Precache("func_breakable.impact_flesh");
		break;
	case 4:	/* concrete */
		Sound_Precache("func_breakable.impact_concrete");
		break;
	case -1: /* none */
	default:
		break;
	}

	/* figure out if we're a sprite... */
	if (Util_ExtensionFromString(m_strShootModel) == "spr") {
		m_bCanScale = true;
	}
}

void
env_shooter::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flVariance", m_flVariance);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveInt(handle, "m_iGibs", m_iGibs);
	SaveInt(handle, "m_iGibsLeft", m_iGibsLeft);
	SaveFloat(handle, "m_flVelocity", m_flVelocity);
	SaveFloat(handle, "m_flGibLife", m_flGibLife);
	SaveString(handle, "m_strShootModel", m_strShootModel);
	SaveFloat(handle, "m_flShootSounds", m_flShootSounds);
	SaveFloat(handle, "m_flScale", m_flScale);
	SaveFloat(handle, "m_flSkin", m_flSkin);
	SaveBool(handle, "m_bCanScale", m_bCanScale);
}

void
env_shooter::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flVariance":
		m_flVariance = ReadFloat(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_iGibs":
		m_iGibs = ReadInt(strValue);
		break;
	case "m_iGibsLeft":
		m_iGibsLeft = ReadInt(strValue);
		break;
	case "m_flVelocity":
		m_flVelocity = ReadFloat(strValue);
		break;
	case "m_flGibLife":
		m_flGibLife = ReadFloat(strValue);
		break;
	case "m_strShootModel":
		m_strShootModel = ReadString(strValue);
		break;
	case "m_flShootSounds":
		m_flShootSounds = ReadFloat(strValue);
		break;
	case "m_flScale":
		m_flScale = ReadFloat(strValue);
		break;
	case "m_flSkin":
		m_flSkin = ReadFloat(strValue);
		break;
	case "m_bCanScale":
		m_bCanScale = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_shooter::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "angle":
		angles = [ReadFloat(strValue) * 90, 0, 0];
		break;
	case "m_iGibs":
		m_iGibs = ReadInt(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_flVelocity":
		m_flVelocity = ReadFloat(strValue);
		break;
	case "m_flVariance":
		m_flVariance = ReadFloat(strValue);
		break;
	case "m_flGibLife":
		m_flGibLife = ReadFloat(strValue);
		break;
	case "shootmodel":
		m_strShootModel = strValue;
		break;
	case "shootsounds":
		m_flShootSounds = ReadFloat(strValue);
		break;
	case "scale":
		m_flScale = ReadFloat(strValue);
		break;
	case "skin":
		m_flSkin = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_shooter::Respawn(void)
{
	if (!m_strShootModel) {
		Destroy();
		return;
	}

	m_iGibsLeft = m_iGibs;
	ReleaseThink();
}

void
env_shooter::ShootGib(void)
{
	vector vecSpinVel = [0.0f, 0.0f, 0.0f];
	vector vecThrowVel = [0.0f, 0.0f, 0.0f];

	NSRenderableEntity eGib = spawn(NSRenderableEntity);
	eGib.SetMovetype(MOVETYPE_BOUNCE);
	eGib.SetModel(m_strShootModel);
	eGib.SetSize([-8,-8,-8],[8,8,8]);
	eGib.SetOrigin(GetOrigin());
	eGib.SetAngles(GetAngles());
	eGib.SetRenderColor(m_vecRenderColor);
	eGib.SetRenderMode(m_iRenderMode);
	eGib.SetRenderFX(m_iRenderFX);
	eGib.SetRenderAmt(m_flRenderAmt);

	/* scale multiplier only works on sprites.
	   the env_shooter entities in lambda_bunker.bsp rely
	   on this exact behaviour. if Source added support
	   for this you need to differentiate between the two. */
	if (m_bCanScale == true) {
		eGib.SetScale(m_flScale);
	}

	eGib.SetSize([-8,-8,-8],[8,8,8]);
	eGib.SetSkin(m_flSkin);

	switch (m_flShootSounds) {
	case 0:	/* glass */
		StartSoundDef("sfx_impact.glass", CHAN_VOICE, false);
		break;
	case 1:	/* wood */
		StartSoundDef("sfx_impact.wood", CHAN_VOICE, false);
		break;
	case 2:	/* metal */
		StartSoundDef("sfx_impact.metal", CHAN_VOICE, false);
		break;
	case 3: /* flesh */
		StartSoundDef("sfx_impact.flesh", CHAN_VOICE, false);
		break;
	case 4:	/* concrete */
		StartSoundDef("sfx_impact.concrete", CHAN_VOICE, false);
		break;
	case -1: /* none */
	default:
		break;
	}

	if (m_flGibLife <= 0)
		m_flGibLife = 1.0f;

	makevectors(GetAngles());
	vecThrowVel = v_forward;
	vecThrowVel += (random(-1,1) * v_right) * m_flVariance;
	vecThrowVel += (random(-1,1) * v_up) * m_flVariance;
	vecThrowVel *= m_flVelocity;

	vecSpinVel[0] = random(-1,1) * 32;
	vecSpinVel[1] = random(-1,1) * 32;
	vecSpinVel[2] = random(-1,1) * 32;
	eGib.SetVelocity(vecThrowVel);
	eGib.SetAngularVelocity(vecSpinVel);
	eGib.ScheduleThink(Destroy, m_flGibLife);
}

void
env_shooter::ShooterLoop(void)
{
	ShootGib();
	m_iGibsLeft--;

	/* keep shooting til we're done */
	if (m_iGibsLeft) {
		ScheduleThink(ShooterLoop, m_flDelay);
	} else {
		/* no more gibs left, destroy if wanted */
		if (HasSpawnFlags(EVSHOOTER_REPEATABLE) == false) {
			ScheduleThink(Destroy, m_flDelay);
		}
	}
}

void
env_shooter::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		ReleaseThink();
		break;
	case TRIG_ON:
		/* reset gib count if repeatable. */
		if (HasSpawnFlags(EVSHOOTER_REPEATABLE) == true) {
			m_iGibsLeft = m_iGibs;
		}

		ScheduleThink(ShooterLoop, m_flDelay);
		break;
	default:
		if (IsThinking() == false)
			Trigger(act, TRIG_ON);
		else
			Trigger(act, TRIG_OFF);
	}
}

void
env_shooter::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "Shoot":
		ShootGib();
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}
