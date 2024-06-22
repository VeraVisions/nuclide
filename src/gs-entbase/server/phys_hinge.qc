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

/*! \brief Server-Entity: Hinge Physics Constraint */
/*!QUAKED phys_hinge (.5 .3 0) (-8 -8 -8) (8 8 8) BREAKCOLL x INACTIVE MASS NOCONNECT
# OVERVIEW
Creates a connection between two entities in the form of a hinge.

# KEYS
- "targetname" : Name
- "attach1" : Entity 1
- "attach2" : Entity 2
- "hingefriction" : Friction in the hinge.
- "hingeaxis" : Axis of the hinge. Technically the position it is aiming at.

# INPUTS
- "Break" : Forcefully break the constraint.
- "TurnOn" : Turn 
- "TurnOff" : Disables the constraint
- "SetAngularVelocity" : Applies rotation to the hinge motor.

# SPAWNFLAGS
- BREAKCOLL (1) : No collision until the connection breaks.
- INACTIVE (4) : Starts inactive.
- MASS (8) : Mass Hack.
- NOCONNECT (16) : Will not connect entities until turned on via Inputs.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup server
@ingroup pointentity
*/
class
phys_hinge:NSPhysicsConstraint
{
public:
	void phys_hinge(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	virtual void Respawn(void);
	nonvirtual void AfterSpawn(void);

private:
	float m_flHingeFriction;
	vector m_vecHingeAxis;
};

void
phys_hinge::phys_hinge(void)
{
	m_flHingeFriction = 1.0f;
	m_vecHingeAxis = g_vec_null;
}

void
phys_hinge::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flHingeFriction", m_flHingeFriction);
	SaveVector(handle, "m_vecHingeAxis", m_vecHingeAxis);
}

void
phys_hinge::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flHingeFriction":
		m_flHingeFriction = ReadFloat(strValue);
		break;
	case "m_vecHingeAxis":
		m_vecHingeAxis = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
phys_hinge::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "hingefriction":
		m_flHingeFriction = ReadFloat(setValue);
		break;
	case "hingeaxis":
		m_vecHingeAxis = ReadVector(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
phys_hinge::Respawn(void)
{
	ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_hinge::AfterSpawn(void)
{
	SetConstraintType(CONSTRAINT_HINGE);
	SetOrigin(GetSpawnVector("origin"));

	SetEntity1(find(world, ::targetname, m_strEnt1));

	if (m_strEnt2)
		SetEntity2(find(world, ::targetname, m_strEnt2));
	else
		SetEntity2(this);

	SetAngles(vectoangles(m_vecHingeAxis - GetOrigin()));
	SetSliderMaxVelocity(99999);
	SetSliderFriction(m_flHingeFriction);

	WakeTargets();
}

void
phys_hinge::Input(entity activatorEnt, string inputName, string dataString)
{
	switch (inputName) {
	case "SetAngularVelocity":
		SetSliderVelocity(stof(dataString));
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}