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

/*! \brief Server-Entity: Triggers Physics Explosion */
/*!QUAKED env_physexplosion (1 .5 0) (-8 -8 -8) (8 8 8) NODAMAGE PUSHCLIENTS RADIAL TRACE SHAKE
# OVERVIEW
A force-centered explosion, primarily targetted at physics objects and optionally, players/clients.

# KEYS
- "targetname" : Name
- "magnitude" : Amount of force applied.
- "radius" : Optional, overrides the radius of the 'explosion'.
- "targetentityname" : Optional, will only target the named entity if specified.
- "inner_radius" : Optional, will test from within this inner radius when TRACE (8) is set.

# SPAWNFLAGS
- NODAMAGE (1) : Do not damage physics entities.
- PUSHCLIENTS (2) : Allow pushing of players.
- RADIAL (4) : Disables any up/down forces from being applied.
- TRACE (8) : Does a collision test with its targets.
- SHAKE (16) : Push the view of the players around a bit.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
env_physexplosion:ncPointTrigger
{
public:
	void env_physexplosion(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);

	nonvirtual void TriggerExplosion(void);

private:
	float m_flMagnitude;
	float m_flRadius;
	string m_strTargetEntity;
	float m_flInnerRadius;
};

void
env_physexplosion::env_physexplosion(void)
{
	m_flMagnitude = 0.0f;
	m_flRadius = 0.0f;
	m_strTargetEntity = __NULL__;
	m_flInnerRadius = 0.0f;
}

void
env_physexplosion::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flMagnitude", m_flMagnitude);
	SaveFloat(handle, "m_flRadius", m_flRadius);
	SaveString(handle, "m_strTargetEntity", m_strTargetEntity);
	SaveFloat(handle, "m_flInnerRadius", m_flInnerRadius);
}

void
env_physexplosion::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flMagnitude":
		m_flMagnitude = ReadFloat(setValue);
		break;
	case "m_flRadius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "m_strTargetEntity":
		m_strTargetEntity = ReadString(setValue);
		break;
	case "m_flInnerRadius":
		m_flInnerRadius = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_physexplosion::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "magnitude":
		m_flMagnitude = ReadFloat(setValue);
		break;
	case "radius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "targetentityname":
		m_strTargetEntity = ReadString(setValue);
		break;
	case "inner_radius":
		m_flInnerRadius = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
env_physexplosion::TriggerExplosion(void)
{
	float entityDistance = 0.0f;
	float targetForce = 0.0f;
	float explosionRadius = m_flRadius;
	ncPhysicsEntity physEnt;

	if (m_flRadius == 0.0) {
		explosionRadius = m_flMagnitude * 2.5;
	}

	/* only target them if set */
	if (m_strTargetEntity) {
		physEnt = (ncPhysicsEntity)find(world, ::targetname, m_strTargetEntity);

		if (!physEnt) {
			EntWarning("Target set, but not found!");
			return;
		}

		entityDistance = vlen(GetOrigin() - physEnt.WorldSpaceCenter());

		if (entityDistance <= explosionRadius) {
			targetForce = (explosionRadius - entityDistance) / explosionRadius;
			targetForce = rint(m_flMagnitude * targetForce);
			physEnt.ApplyForceOffset(v_forward * targetForce, origin);
		}
		return;
	}

	for (entity e = world; (e = findfloat(e, ::isPhysics, true));) {
		physEnt = (ncPhysicsEntity)e;
		entityDistance = vlen(GetOrigin() - physEnt.WorldSpaceCenter());

		if (entityDistance <= explosionRadius) {
			makevectors(vectoangles(physEnt.WorldSpaceCenter() - GetOrigin()));
			targetForce = (explosionRadius - entityDistance) / explosionRadius;
			targetForce = rint(m_flMagnitude * targetForce);
			physEnt.ApplyForceOffset(v_forward * targetForce, origin);
			physEnt.velocity += v_forward * targetForce;
		}
	}
}

void
env_physexplosion::Input(entity activatorEnt, string inputName, string dataString)
{
	switch (inputName) {
	case "Explode":
		TriggerExplosion();
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}