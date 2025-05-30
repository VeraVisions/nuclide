/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

.vector movedir;
.entity aiment;

void
ncPhysicsConstraint::ncPhysicsConstraint(void)
{
	m_flTorqueLimit = 0.0f;
	m_flForceLimit = 0.0f;
	m_strEnt1 = __NULL__;
	m_strEnt2 = __NULL__;
	m_strBreakSound = __NULL__;
	m_outputOnBreak = __NULL__;
	m_strConstraintSystem = __NULL__;
}

void
ncPhysicsConstraint::ConstraintThink(void)
{
	ncPhysicsEntity target1 = (ncPhysicsEntity)GetEntity1();
	ncPhysicsEntity target2 = (ncPhysicsEntity)GetEntity1();

	/* never run again */
	if (m_flForceLimit <= 0 && m_flTorqueLimit <= 0)
		return;

	if (m_flForceLimit > 0)
	if (vlen(target1.GetVelocity()) > m_flForceLimit) {
		Break(this);
		return;
	}

	if (m_flTorqueLimit > 0)
	if (vlen(target1.GetAngularVelocity()) > m_flTorqueLimit) {
		Break(this);
		return;
	}

	if (m_flForceLimit > 0)
	if (vlen(target2.GetVelocity()) > m_flForceLimit) {
		Break(this);
		return;
	}

	if (m_flTorqueLimit > 0)
	if (vlen(target2.GetAngularVelocity()) > m_flTorqueLimit) {
		Break(this);
		return;
	}
	SetNextThink(0.0f);
}

#ifdef SERVER
void
ncPhysicsConstraint::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flTorqueLimit", m_flTorqueLimit);
	SaveFloat(handle, "m_flForceLimit", m_flForceLimit);
	SaveString(handle, "m_strEnt1", m_strEnt1);
	SaveString(handle, "m_strEnt2", m_strEnt2);
	SaveString(handle, "m_strBreakSound", m_strBreakSound);
	SaveString(handle, "m_outputOnBreak", m_outputOnBreak);
	SaveString(handle, "m_strConstraintSystem", m_strConstraintSystem);
}

void
ncPhysicsConstraint::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_flTorqueLimit":
		m_flTorqueLimit = ReadFloat(setValue);
		break;
	case "m_flForceLimit":
		m_flForceLimit = ReadFloat(setValue);
		break;
	case "m_strEnt1":
		m_strEnt1 = ReadString(setValue);
		break;
	case "m_strEnt2":
		m_strEnt2 = ReadString(setValue);
		break;
	case "m_strBreakSound":
		m_strBreakSound = ReadString(setValue);
		break;
	case "m_outputOnBreak":
		m_outputOnBreak = ReadString(setValue);
		break;
	case "m_strConstraintSystem":
		m_strConstraintSystem = ReadString(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}
#endif

void
ncPhysicsConstraint::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "attach1":
		m_strEnt1 = ReadString(setValue);
		break;
	case "attach2":
		m_strEnt2 = ReadString(setValue);
		break;
	case "torquelimit":
		m_flTorqueLimit = ReadFloat(setValue);
		break;
	case "forcelimit":
		m_flForceLimit = ReadFloat(setValue);
		break;
	case "breaksound":
		m_strBreakSound = ReadString(setValue);
		break;
	case "teleportfollowdistance":
		break;
	case "constraintsystem":
		m_strConstraintSystem = ReadString(setValue);
		break;
#ifdef SERVER
	case "OnBreak":
		m_outputOnBreak = PrepareOutput(m_outputOnBreak, setValue);
		break;
#endif
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

float
ncPhysicsConstraint::GetConstraintSystemID(void)
{
	entity system;

	/* default to group 0 */
	if (!m_strConstraintSystem)
		return 0;

	system = find(world, ::targetname, m_strConstraintSystem);

	/* must have been invalid/mappers error */
	if (!system) {
		return 0;
	}

	return system.jointgroup;
}

void
ncPhysicsConstraint::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	if (m_outputOnBreak)
		m_outputOnBreak = CreateOutput(m_outputOnBreak);
#endif
}

#ifdef SERVER
void
ncPhysicsConstraint::Input(entity activatorEnt, string inputName, string dataString)
{
	switch (inputName) {
	case "Break":
		Break(activatorEnt);
		break;
	case "TurnOn":
		break;
	case "TurnOff":
		break;
	default:
		super::Input(activatorEnt, inputName, dataString);
		break;
	}
}
#endif

void
ncPhysicsConstraint::Break(entity activatingEnt)
{
#ifdef SERVER
	if (m_outputOnBreak)
		UseOutput(activatingEnt, m_outputOnBreak);
#endif

	if (m_strBreakSound)
		StartSoundDef(m_strBreakSound, CHAN_AUTO, true);

	Destroy();
}

void
ncPhysicsConstraint::OnRemoveEntity(void)
{
	WakeTargets();
}

void
ncPhysicsConstraint::WakeTargets(void)
{
	ncPhysicsEntity physTarget;

	if (enemy.isPhysics) {
		physTarget = (ncPhysicsEntity)enemy;
		physTarget.Wake();
	}
	if (aiment.isPhysics) {
		physTarget = (ncPhysicsEntity)aiment;
		physTarget.Wake();
	}
}

constraint_t
ncPhysicsConstraint::GetConstraintType(void)
{
	return (constraint_t )jointtype;
}

entity
ncPhysicsConstraint::GetEntity1(void)
{
	return enemy;
}

entity
ncPhysicsConstraint::GetEntity2(void)
{
	return aiment;
}

void
ncPhysicsConstraint::SetConstraintType(constraint_t setValue)
{
	jointtype = (float)setValue;
}

void
ncPhysicsConstraint::SetEntity1(entity targetEnt)
{
	enemy = targetEnt;
	jointgroup = GetConstraintSystemID();

	/* give it some time to think. */
	ScheduleThink(ConstraintThink, 0.25f);
}

void
ncPhysicsConstraint::SetEntity2(entity targetEnt)
{
	aiment = targetEnt;
}

void
ncPhysicsConstraint::SetSliderVelocity(float slideVel)
{
	movedir[0] = slideVel;
}

void
ncPhysicsConstraint::SetSliderMaxVelocity(float maxVel)
{
	movedir[1] = -fabs(maxVel);
}

void
ncPhysicsConstraint::SetSliderStop(float stopVal)
{
	movedir[2] = stopVal;
}

void
ncPhysicsConstraint::SetSliderFriction(float frictionValue)
{
	friction = frictionValue;
}

float
ncPhysicsConstraint::GetSliderVelocity(void)
{
	return movedir[0];
}

float
ncPhysicsConstraint::GetSliderMaxVelocity(void)
{
	return movedir[1];
}

float
ncPhysicsConstraint::GetSliderStop(void)
{
	return movedir[2];
}

float
ncPhysicsConstraint::GetSliderFriction(void)
{
	return friction;
}

ncPhysicsConstraint
ncPhysicsConstraint::Ballsocket(entity firstEnt, entity secondEnt, vector pos1, vector pos2, float forceLimit, bool noCollide)
{
	ncPhysicsConstraint new = spawn(ncPhysicsConstraint);
	new.SetConstraintType(CONSTRAINT_POINT);
	new.SetEntity1(firstEnt);
	new.SetEntity2(secondEnt);
	new.origin = pos1;
	new.velocity = pos2;
	new.WakeTargets();

	EntLog("Created ballsocket between %S and %S.", firstEnt.classname, secondEnt.classname);
	return new;
}

ncPhysicsConstraint
ncPhysicsConstraint::Weld(entity firstEnt, entity secondEnt, float bone1, float bone2, float forceLimit, bool noCollide, bool deleteEnt1OnBreak)
{
	if (firstEnt == secondEnt) {
		EntError("Cannot weld the entity with itself!");
		return __NULL__;
	}

	ncPhysicsConstraint new = spawn(ncPhysicsConstraint);
	new.SetConstraintType(CONSTRAINT_FIXED);
	new.SetEntity1(firstEnt);
	new.SetEntity2(secondEnt);
	new.WakeTargets();

	EntLog("Created weld between %S and %S.", firstEnt.classname, secondEnt.classname);
	return new;
}

ncPhysicsConstraint
ncPhysicsConstraint::Rope(entity firstEnt, entity secondEnt, vector pos1, vector pos2)
{
	ncPhysicsConstraint new = spawn(ncPhysicsConstraint);
	new.SetConstraintType(CONSTRAINT_POINT);
	new.SetEntity1(firstEnt);
	new.SetEntity2(secondEnt);
	new.origin = pos1;
	new.velocity = pos2;
	new.WakeTargets();

	EntLog("Created rope between %S and %S", firstEnt.classname, secondEnt.classname);
	return new;
}

.float max_angular;
ncPhysicsConstraint
ncPhysicsConstraint::KeepUpright(entity firstEnt, vector uprightAngle, float angleLimit)
{
	firstEnt.angles = uprightAngle;
	firstEnt.max_angular = angleLimit;
	return __NULL__;
}