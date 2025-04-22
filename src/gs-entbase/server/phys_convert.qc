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

/*! \brief Server-Entity: Static To Physics Converter */
/*!QUAKED phys_convert (.5 .3 0) (-8 -8 -8) (8 8 8) ASLEEP DEBRIS
# OVERVIEW
Turns a standard entity into a physically simulated one.

# KEYS
- "targetname" : Name
- "target" : Entity 1
- "swapmodel" : Model override.
- "massoverride" : Optional new mass.

# INPUTS
- "ConvertTarget" : Triggers the conversion.

# OUTPUTS
- "OnConvert" : Triggered after successful conversion.

# SPAWNFLAGS
- ASLEEP (1) : Don't activate motion when conversion is done.
- DEBRIS (2) : Makes converted entity non-solid.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
@ingroup physics
*/
class
phys_convert:ncPhysicsConstraint
{
public:
	void phys_convert(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Input(entity, string, string);
	nonvirtual void AfterSpawn(void);
	nonvirtual void ConvertTarget(entity);

private:
	string m_strSwapModel;
	float m_flMassOverride;
	string m_outputOnConvert;
};

void
phys_convert::phys_convert(void)
{
	m_strSwapModel = __NULL__;
	m_flMassOverride = 0.0f;
	m_outputOnConvert = __NULL__;
}

void
phys_convert::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSwapModel", m_strSwapModel);
	SaveFloat(handle, "m_flMassOverride", m_flMassOverride);
	SaveString(handle, "m_outputOnConvert", m_outputOnConvert);
}

void
phys_convert::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strSwapModel":
		m_strSwapModel = ReadString(setValue);
		break;
	case "m_flMassOverride":
		m_flMassOverride = ReadFloat(setValue);
		break;
	case "m_outputOnConvert":
		m_outputOnConvert = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
phys_convert::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "target":
		m_strEnt1 = ReadString(setValue);
		break;
	case "swapmodel":
		m_strSwapModel = ReadString(setValue);
		break;
	case "massoverride":
		m_flMassOverride = ReadFloat(setValue);
		break;
	case "OnConvert":
		m_outputOnConvert = PrepareOutput(m_outputOnConvert, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
phys_convert::Spawned(void)
{
	super::Spawned();

	if (m_outputOnConvert)
		m_outputOnConvert = CreateOutput(m_outputOnConvert);
}

void
phys_convert::Respawn(void)
{
	ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_convert::AfterSpawn(void)
{
	SetOrigin(GetSpawnVector("origin"));
	SetEntity1(find(world, ::targetname, m_strEnt1));
}

void
phys_convert::ConvertTarget(entity activatorEnt)
{
	ncEntity targetEnt = (ncEntity)GetEntity1();
	string targetModel;
	vector targetAngle;
	vector targetPos;
	vector targetVelocity;
	string targetName;
	ncPhysicsEntity new;

	if (!targetEnt) {
		EntWarning("Cannot find target to convert.");
		return;
	}

	targetModel = targetEnt.GetModel();
	targetAngle = targetEnt.GetAngles();
	targetPos = targetEnt.GetOrigin();
	targetVelocity = targetEnt.GetVelocity();
	targetName = targetEnt.targetname;

	new = spawn(ncPhysicsEntity);
	new.Spawn();

	/* may have an override */
	if (m_strSwapModel) {
		targetModel = m_strSwapModel;
	}

	new.SetModel(targetModel);
	new.SetOrigin(targetPos);
	new.SetAngles(targetAngle);
	new.SetVelocity(targetVelocity);
	new.targetname = (targetName);

	if (m_flMassOverride > 0.0f) {
		new.SetMass(m_flMassOverride);
	}

	/* Spawnflags ASLEEP */
	if (HasSpawnFlags(1)) {
		new.Sleep();
	} else {
		new.Wake();
	}

	/* Spawnflag DEBRIS */
	if (HasSpawnFlags(2)) {
		new.SetSolid(SOLID_NOT);
	}

	targetEnt.Destroy();

	if (m_outputOnConvert)
		UseOutput(activatorEnt, m_outputOnConvert);
}

void
phys_convert::Input(entity activatorEnt, string inputName, string dataString)
{
	switch (inputName) {
	case "ConvertTarget":
		ConvertTarget(activatorEnt);
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}
