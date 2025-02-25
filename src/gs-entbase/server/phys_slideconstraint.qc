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

/*! \brief Server-Entity: Sliding Physics Constraint */
/*!QUAKED phys_slideconstraint (.5 .3 0) (-8 -8 -8) (8 8 8) BREAKCOLL LIMITENDS
# OVERVIEW
Will slide an entity along a segment.

# KEYS
- "targetname" : Name
- "attach1" : Entity 1
- "attach2" : Entity 2
- "slideaxis" : Axis onto which the entity slides along. Technically the position it is aiming at.
- "slidefriction" : Friction the entity experiences along the slide.

# INPUTS
- "Break" : Forcefully break the constraint.
- "TurnOn" : Turn 
- "TurnOff" : Disables the constraint

# SPAWNFLAGS
- BREAKCOLL (1) : No collision until the connection breaks.
- LIMITENDS (2) : Limit endpoints.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
@ingroup physics
*/
class
phys_slideconstraint:ncPhysicsConstraint
{
public:
	void phys_slideconstraint(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	virtual void Respawn(void);
	nonvirtual void AfterSpawn(void);

private:
	vector m_vecSliderAxis;
	float m_flSliderFriction;
};

void
phys_slideconstraint::phys_slideconstraint(void)
{
	m_vecSliderAxis = g_vec_null;
	m_flSliderFriction = 0.0f;
}

void
phys_slideconstraint::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecSliderAxis", m_vecSliderAxis);
	SaveFloat(handle, "m_flSliderFriction", m_flSliderFriction);
}

void
phys_slideconstraint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecSliderAxis":
		m_vecSliderAxis = ReadVector(strValue);
		break;
	case "m_flSliderFriction":
		m_flSliderFriction = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
phys_slideconstraint::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "slideaxis":
		m_vecSliderAxis = ReadVector(setValue);
		break;
	case "slidefriction":
		m_flSliderFriction = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
phys_slideconstraint::Respawn(void)
{
	ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_slideconstraint::AfterSpawn(void)
{
	SetConstraintType(CONSTRAINT_SLIDER);
	SetOrigin(GetSpawnVector("origin"));

	SetEntity1(find(world, ::targetname, m_strEnt1));

	if (m_strEnt2)
		SetEntity2(find(world, ::targetname, m_strEnt2));
	else
		SetEntity2(this);

	SetAngles(vectoangles(m_vecSliderAxis - GetOrigin()));
	SetSliderMaxVelocity(99999);
	SetSliderFriction(m_flSliderFriction);

	if (HasSpawnFlags(2))
		SetSliderStop(vlen(m_vecSliderAxis - GetOrigin()));

	WakeTargets();
}

void
phys_slideconstraint::Input(entity activatorEnt, string inputName, string dataString)
{
	switch (inputName) {
	case "SetVelocity":
		if (GetSliderVelocity() > 0.0f)
			SetSliderVelocity(-stof(dataString));
		else
			SetSliderVelocity(stof(dataString));

		WakeTargets();
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}