/*
 * Copyright (c) 2023 Vera Visions LLC.
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

enumflags
{
	ENVCASLIGHT_CHANGED_ACTIVE,
	ENVCASLIGHT_CHANGED_ANGLE_X,
	ENVCASLIGHT_CHANGED_ANGLE_Y,
	ENVCASLIGHT_CHANGED_ANGLE_Z,
	ENVCASLIGHT_CHANGED_COLOR_X,
	ENVCASLIGHT_CHANGED_COLOR_Y,
	ENVCASLIGHT_CHANGED_COLOR_Z,
	ENVCASLIGHT_CHANGED_DISTANCE,
};

/*! \brief Shared-Entity: Outdoor Shadow & Lighting Controller */
/*!QUAKED env_cascade_light (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Shadowmapped outdoor lighting entity.

![Shadows cast by an env_cascade_light](@ref env_cascade_light.png)

# KEYS
- "targetname" : Name
- "color" : Color of the sun light. Three space separated 0-255 based values.
- "maxshadowdistance" : Maximum shadow distance from the camera.
- "uselightenvangles" : When set to 1, the angles are taken from the light_environment in the map.
- "StartDisabled" : Entity will have to be enabled in order to work when set to 1.

# INPUTS
- "SetAngles" : Sets the light angle.
- "LightColor" : Sets the light color. Three space separated 0-255 based values.
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# TRIVIA
This entity was introduced in Counter-Strike: Global Offensive (2012).

@ingroup sharedentity
@ingroup pointentity
*/
class
env_cascade_light:ncPointTrigger
{
public:
	void env_cascade_light(void);

#ifdef SERVER
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Input(entity, string, string);
#endif

#ifdef CLIENT
	virtual void OnRemoveEntity(void);
	virtual void ReceiveEntity(float,float);
	virtual void ReloadVideoResources(void);
	nonvirtual void LightChanged(float);
#endif

private:
	NETWORKED_BOOL(m_bLightActive)
	NETWORKED_VECTOR(m_vecLightColor)
	NETWORKED_FLOAT(m_flShadowDistance)

#ifdef CLIENT
	float m_lightHandle;
#endif

#ifdef SERVER
	bool m_bUseEnvAngles;
	bool m_bUseEnvColors;
#endif
};

void
env_cascade_light::env_cascade_light(void)
{
#ifdef SERVER
	m_vecLightColor = [1.0, 1.0, 1.0];
	m_bLightActive = true;
	m_bUseEnvColors = false;
	m_bUseEnvAngles = false;
	m_flShadowDistance = 512.0f;
#endif
}

#ifdef SERVER
void
env_cascade_light::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "color":
		m_vecLightColor = ReadVector(setValue);
		break;
	case "maxshadowdistance":
		m_flShadowDistance = ReadFloat(setValue);
		break;
	case "uselightenvangles":
		m_bUseEnvAngles = ReadBool(setValue);
		break;
	case "uselightenvcolor":
		m_bUseEnvColors = ReadBool(setValue);
		break;
	case "StartDisabled":
		m_bLightActive = ReadBool(setValue) == true ? false : true;
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
env_cascade_light::Respawn(void)
{
	InitPointTrigger();
	pvsflags = PVSF_IGNOREPVS;
}

void
env_cascade_light::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bLightActive", m_bLightActive);
	SaveVector(handle, "m_vecLightColor", m_vecLightColor);
	SaveFloat(handle, "m_flShadowDistance", m_flShadowDistance);
	SaveBool(handle, "m_bUseEnvAngles", m_bUseEnvAngles);
}

void
env_cascade_light::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_bLightActive":
		m_bLightActive = ReadBool(setValue);
		break;
	case "m_vecLightColor":
		m_vecLightColor = ReadVector(setValue);
		break;
	case "m_flShadowDistance":
		m_flShadowDistance = ReadFloat(setValue);
		break;
	case "m_bUseEnvAngles":
		m_bUseEnvAngles = ReadBool(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
env_cascade_light::Input(entity activatingEntity, string keyName, string setValue)
{
	switch (keyName) {
	case "Enable":
		m_bLightActive = false;
		break;
	case "Disable":
		m_bLightActive = true;
		break;
	case "Toggle":
		m_bLightActive = !m_bLightActive;
		break;
	case "SetAngles":
		angles = stov(setValue);
		break;
	case "LightColor":
		m_vecLightColor = stov(setValue);
		break;
	default:
		super::Input(activatingEntity, keyName, setValue);
	}
}

void
env_cascade_light::Trigger(entity activatingEntity, triggermode_t triggerState)
{
	switch (triggerState) {
	case TRIG_OFF:
		m_bLightActive = (false);
		break;
	case TRIG_ON:
		m_bLightActive = (true);
		break;
	default:
		m_bLightActive = (true - m_bLightActive);
	}
}

void
env_cascade_light::EvaluateEntity(void)
{
	if (m_bUseEnvAngles == true) {
		light envLight = (light)find(world, ::classname, "light_environment");

		/* this isn't going to do what we want. remove it altogether. */
		if (!envLight) {
			ncError("env_cascade_light unable to find light_environment.\n");
			Destroy();
			return;
		}

		if (m_bUseEnvColors) {
			m_vecLightColor = envLight._lightColor;
		}

		makevectors(envLight.GetAngles());
		angles = vectoangles(v_forward);
		angles[0] *= -1;
	}

	//angles[0] = sin(time) * 180.0f;
	//angles[1] = sin(time*2) * 180.0f;

	EVALUATE_FIELD(m_bLightActive, ENVCASLIGHT_CHANGED_ACTIVE)
	EVALUATE_VECTOR(angles, 0, ENVCASLIGHT_CHANGED_ANGLE_X)
	EVALUATE_VECTOR(angles, 1, ENVCASLIGHT_CHANGED_ANGLE_Y)
	EVALUATE_VECTOR(angles, 2, ENVCASLIGHT_CHANGED_ANGLE_Z)
	EVALUATE_VECTOR(m_vecLightColor, 0, ENVCASLIGHT_CHANGED_COLOR_X)
	EVALUATE_VECTOR(m_vecLightColor, 1, ENVCASLIGHT_CHANGED_COLOR_Y)
	EVALUATE_VECTOR(m_vecLightColor, 2, ENVCASLIGHT_CHANGED_COLOR_Z)
	EVALUATE_FIELD(m_flShadowDistance, ENVCASLIGHT_CHANGED_DISTANCE)
}

float
env_cascade_light::SendEntity(entity ePVEnt, float flChanged)
{
	if (m_bLightActive == false)
		return (0);

	WriteByte(MSG_ENTITY, ENT_CASCADELIGHT);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_BYTE(m_bLightActive, ENVCASLIGHT_CHANGED_ACTIVE)
	SENDENTITY_COORD(angles[0], ENVCASLIGHT_CHANGED_ANGLE_X)
	SENDENTITY_COORD(angles[1], ENVCASLIGHT_CHANGED_ANGLE_Y)
	SENDENTITY_COORD(angles[2], ENVCASLIGHT_CHANGED_ANGLE_Z)
	SENDENTITY_BYTE(m_vecLightColor[0], ENVCASLIGHT_CHANGED_COLOR_X)
	SENDENTITY_BYTE(m_vecLightColor[1], ENVCASLIGHT_CHANGED_COLOR_Y)
	SENDENTITY_BYTE(m_vecLightColor[2], ENVCASLIGHT_CHANGED_COLOR_Z)
	SENDENTITY_FLOAT(m_flShadowDistance, ENVCASLIGHT_CHANGED_DISTANCE)

	return (1);
}

#endif

#ifdef CLIENT
void
env_cascade_light::OnRemoveEntity(void)
{
	/* this tells the engine to re-use this for a later light */
	dynamiclight_set(m_lightHandle, LFIELD_RADIUS, 0);
	m_lightHandle = 0;
}

void
env_cascade_light::LightChanged(float flFlags)
{
	bool updateAngle = false;
	bool updateColor = false;

	updateAngle |= (flFlags & ENVCASLIGHT_CHANGED_ANGLE_X) ? true : false;
	updateAngle |= (flFlags & ENVCASLIGHT_CHANGED_ANGLE_Y) ? true : false;
	updateAngle |= (flFlags & ENVCASLIGHT_CHANGED_ANGLE_Z) ? true : false;

	updateColor |= (flFlags & ENVCASLIGHT_CHANGED_COLOR_X) ? true : false;
	updateColor |= (flFlags & ENVCASLIGHT_CHANGED_COLOR_Y) ? true : false;
	updateColor |= (flFlags & ENVCASLIGHT_CHANGED_COLOR_Z) ? true : false;

	if (updateAngle) {
		dynamiclight_set(m_lightHandle, LFIELD_ANGLES, angles);
	}
	if (updateColor) {
		dynamiclight_set(m_lightHandle, LFIELD_COLOUR, m_vecLightColor / 255);
	}
}

void
env_cascade_light::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_BYTE(m_bLightActive, ENVCASLIGHT_CHANGED_ACTIVE)
	READENTITY_COORD(angles[0], ENVCASLIGHT_CHANGED_ANGLE_X)
	READENTITY_COORD(angles[1], ENVCASLIGHT_CHANGED_ANGLE_Y)
	READENTITY_COORD(angles[2], ENVCASLIGHT_CHANGED_ANGLE_Z)
	READENTITY_BYTE(m_vecLightColor[0], ENVCASLIGHT_CHANGED_COLOR_X)
	READENTITY_BYTE(m_vecLightColor[1], ENVCASLIGHT_CHANGED_COLOR_Y)
	READENTITY_BYTE(m_vecLightColor[2], ENVCASLIGHT_CHANGED_COLOR_Z)
	READENTITY_FLOAT(m_flShadowDistance, ENVCASLIGHT_CHANGED_DISTANCE)

	if (flNew) {
		ReloadVideoResources();
	} else {
		LightChanged(flChanged);
	}
}

void
env_cascade_light::ReloadVideoResources(void)
{
	OnRemoveEntity();
	m_lightHandle = dynamiclight_spawnstatic(origin, m_flShadowDistance, m_vecLightColor / 255);
	dynamiclight_set(m_lightHandle, LFIELD_FLAGS, LFLAG_ORTHOSUN | LFLAG_SHADOWMAP | LFLAG_REALTIMEMODE);
	LightChanged(0xFFFFFF);
}
#endif
