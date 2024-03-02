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
NSPhysicsConstraint::NSPhysicsConstraint(void)
{
	m_flTorqueLimit = 0.0f;
	m_flForceLimit = 0.0f;
	m_strEnt1 = __NULL__;
	m_strEnt2 = __NULL__;
	m_strBreakSound = __NULL__;
	m_strOnBreak = __NULL__;
	m_strConstraintSystem = __NULL__;
}

void
NSPhysicsConstraint::ConstraintThink(void)
{
	NSPhysicsEntity target1 = (NSPhysicsEntity)GetEntity1();
	NSPhysicsEntity target2 = (NSPhysicsEntity)GetEntity1();

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
NSPhysicsConstraint::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flTorqueLimit", m_flTorqueLimit);
	SaveFloat(handle, "m_flForceLimit", m_flForceLimit);
	SaveString(handle, "m_strEnt1", m_strEnt1);
	SaveString(handle, "m_strEnt2", m_strEnt2);
	SaveString(handle, "m_strBreakSound", m_strBreakSound);
	SaveString(handle, "m_strOnBreak", m_strOnBreak);
	SaveString(handle, "m_strConstraintSystem", m_strConstraintSystem);
}

void
NSPhysicsConstraint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flTorqueLimit":
		m_flTorqueLimit = ReadFloat(strValue);
		break;
	case "m_flForceLimit":
		m_flForceLimit = ReadFloat(strValue);
		break;
	case "m_strEnt1":
		m_strEnt1 = ReadString(strValue);
		break;
	case "m_strEnt2":
		m_strEnt2 = ReadString(strValue);
		break;
	case "m_strBreakSound":
		m_strBreakSound = ReadString(strValue);
		break;
	case "m_strOnBreak":
		m_strOnBreak = ReadString(strValue);
		break;
	case "m_strConstraintSystem":
		m_strConstraintSystem = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

void
NSPhysicsConstraint::SpawnKey(string keyName, string setValue)
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
		m_strOnBreak = PrepareOutput(m_strOnBreak, setValue);
		break;
#endif
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

float
NSPhysicsConstraint::GetConstraintSystemID(void)
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
NSPhysicsConstraint::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	if (m_strOnBreak)
		m_strOnBreak = CreateOutput(m_strOnBreak);
#endif
}

#ifdef SERVER
void
NSPhysicsConstraint::Input(entity activatorEnt, string inputName, string dataString)
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
NSPhysicsConstraint::Break(entity activatingEnt)
{
#ifdef SERVER
	if (m_strOnBreak)
		UseOutput(activatingEnt, m_strOnBreak);
#endif

	if (m_strBreakSound)
		StartSoundDef(m_strBreakSound, CHAN_AUTO, true);

	Destroy();
}

void
NSPhysicsConstraint::OnRemoveEntity(void)
{
	WakeTargets();
}

void
NSPhysicsConstraint::WakeTargets(void)
{
	NSPhysicsEntity physTarget;

	if (enemy.isPhysics) {
		physTarget = (NSPhysicsEntity)enemy;
		physTarget.Wake();
	}
	if (aiment.isPhysics) {
		physTarget = (NSPhysicsEntity)aiment;
		physTarget.Wake();
	}
}

constraint_t
NSPhysicsConstraint::GetConstraintType(void)
{
	return (constraint_t )jointtype;
}

entity
NSPhysicsConstraint::GetEntity1(void)
{
	return enemy;
}

entity
NSPhysicsConstraint::GetEntity2(void)
{
	return aiment;
}

void
NSPhysicsConstraint::SetConstraintType(constraint_t setValue)
{
	jointtype = (float)setValue;
}

void
NSPhysicsConstraint::SetEntity1(entity targetEnt)
{
	enemy = targetEnt;
	jointgroup = GetConstraintSystemID();

	/* give it some time to think. */
	ScheduleThink(ConstraintThink, 0.25f);
}

void
NSPhysicsConstraint::SetEntity2(entity targetEnt)
{
	aiment = targetEnt;
}

void
NSPhysicsConstraint::SetSliderVelocity(float slideVel)
{
	movedir[0] = slideVel;
}

void
NSPhysicsConstraint::SetSliderMaxVelocity(float maxVel)
{
	movedir[1] = -fabs(maxVel);
}

void
NSPhysicsConstraint::SetSliderStop(float stopVal)
{
	movedir[2] = stopVal;
}

void
NSPhysicsConstraint::SetSliderFriction(float frictionValue)
{
	friction = frictionValue;
}

float
NSPhysicsConstraint::GetSliderVelocity(void)
{
	return movedir[0];
}

float
NSPhysicsConstraint::GetSliderMaxVelocity(void)
{
	return movedir[1];
}

float
NSPhysicsConstraint::GetSliderStop(void)
{
	return movedir[2];
}

float
NSPhysicsConstraint::GetSliderFriction(void)
{
	return friction;
}

NSPhysicsConstraint
NSPhysicsConstraint::Ballsocket(entity firstEnt, entity secondEnt, vector pos1, vector pos2, float forceLimit, bool noCollide)
{
	NSPhysicsConstraint new = spawn(NSPhysicsConstraint);
	new.SetConstraintType(CONSTRAINT_POINT);
	new.SetEntity1(firstEnt);
	new.SetEntity2(secondEnt);
	new.origin = pos1;
	new.velocity = pos2;
	new.WakeTargets();

	EntLog("Created ballsocket between %S and %S.", firstEnt.classname, secondEnt.classname);
	return new;
}

NSPhysicsConstraint
NSPhysicsConstraint::Weld(entity firstEnt, entity secondEnt, float bone1, float bone2, float forceLimit, bool noCollide, bool deleteEnt1OnBreak)
{
	if (firstEnt == secondEnt) {
		EntError("Cannot weld the entity with itself!");
		return __NULL__;
	}

	NSPhysicsConstraint new = spawn(NSPhysicsConstraint);
	new.SetConstraintType(CONSTRAINT_FIXED);
	new.SetEntity1(firstEnt);
	new.SetEntity2(secondEnt);
	new.WakeTargets();

	EntLog("Created weld between %S and %S.", firstEnt.classname, secondEnt.classname);
	return new;
}

NSPhysicsConstraint
NSPhysicsConstraint::Rope(entity firstEnt, entity secondEnt, vector pos1, vector pos2)
{
	NSPhysicsConstraint new = spawn(NSPhysicsConstraint);
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
NSPhysicsConstraint
NSPhysicsConstraint::KeepUpright(entity firstEnt, vector uprightAngle, float angleLimit)
{
	firstEnt.angles = uprightAngle;
	firstEnt.max_angular = angleLimit;
	return __NULL__;
}