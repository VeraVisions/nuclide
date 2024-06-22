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

/*! \brief Server-Entity: Physics Upright Controller */
/*!QUAKED phys_keepupright (.5 .3 0) (-8 -8 -8) (8 8 8) INACTIVE
# OVERVIEW
Keep an entity upright.

# KEYS
- "targetname" : Name
- "attach1" : Entity 1
- "angularlimit" : The limit of angular velocity this can clamp.

# INPUTS
- "TurnOn" : Make Entity 1 upright.
- "TurnOff" : Make Entity 1 no longer upright.

# SPAWNFLAGS
- INACTIVE (1) : Starts inactive.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup server
@ingroup pointentity
*/
class
phys_keepupright:NSPhysicsConstraint
{
public:
	void phys_keepupright(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Respawn(void);
	nonvirtual void AfterSpawn(void);
	virtual void Input(entity, string, string);

private:
	float m_flAngularLimit;
};

void
phys_keepupright::phys_keepupright(void)
{
	m_flAngularLimit = -1.0f;
}

void
phys_keepupright::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flAngularLimit", m_flAngularLimit);
}

void
phys_keepupright::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flAngularLimit":
		m_flAngularLimit = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
phys_keepupright::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "angularlimit":
		m_flAngularLimit = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
phys_keepupright::Respawn(void)
{
	if (HasSpawnFlags(1) == false)
		ScheduleThink(AfterSpawn, 0.0f);
}

void
phys_keepupright::AfterSpawn(void)
{
	SetOrigin(GetSpawnVector("origin"));
	SetEntity1(find(world, ::targetname, m_strEnt1));
	NSEntity targetEnt = (NSEntity)GetEntity1();
	KeepUpright(targetEnt, targetEnt.GetSpawnVector("angles"), m_flAngularLimit);
}

void
phys_keepupright::Input(entity activatorEnt, string inputName, string dataString)
{
	NSEntity targetEnt;

	switch (inputName) {
	case "TurnOn":
		targetEnt = (NSEntity)GetEntity1();
		KeepUpright(targetEnt, targetEnt.GetSpawnVector("angles"), m_flAngularLimit);
		break;
	case "TurnOff":
		targetEnt = (NSEntity)GetEntity1();
		KeepUpright(targetEnt, targetEnt.GetSpawnVector("angles"), -1);
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}