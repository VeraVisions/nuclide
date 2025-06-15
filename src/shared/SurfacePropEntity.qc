/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

void
ncSurfacePropEntity::ncSurfacePropEntity(void)
{
	m_timeUntilNextBurnDamage = 0.0f;

#ifdef SERVER
	max_health = 100;
	max_armor = 100;
	m_propdataID = -1i;
	m_surfdataID = -1i;
	m_outputOnHalfHealth = __NULL__;
	m_outputOnDamaged = __NULL__;
	m_outputOnDamagedByPlayer = __NULL__;
	m_outputOnDeath = __NULL__;
	m_outputOnBreak = __NULL__;
	m_burningAttacker= __NULL__;
	m_burningWeapon = 0i;
	m_timeUntilBurningStops = 0.0f;
	m_timeUntilNextBurnDamage = 0.0f;
	m_surfData = __NULL__;
	m_propData = __NULL__;
#endif
}

void
ncSurfacePropEntity::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	/* tokenization complete, now we can load propdata */
	_SurfaceDataFinish();
	_PropDataFinish();

	/* Input/Output system */
	if (STRING_SET(m_outputOnHalfHealth))
		m_outputOnHalfHealth = CreateOutput(m_outputOnHalfHealth);
	if (STRING_SET(m_outputOnDamaged))
		m_outputOnDamaged = CreateOutput(m_outputOnDamaged);
	if (STRING_SET(m_outputOnDamagedByPlayer))
		m_outputOnDamagedByPlayer = CreateOutput(m_outputOnDamagedByPlayer);
	if (STRING_SET(m_outputOnDeath))
		m_outputOnDeath = CreateOutput(m_outputOnDeath);
	if (STRING_SET(m_outputOnBreak))
		m_outputOnBreak = CreateOutput(m_outputOnBreak);
#endif
}

bool
ncSurfacePropEntity::IsOnFire(void)
{
	return (effects & EF_ONFIRE) ? true : false;
}

/* networking */
#ifdef SERVER
bool
ncSurfacePropEntity::IsAlive(void)
{
	return (health > 0) ? true : false;
}

bool
ncSurfacePropEntity::IsVulnerable(void)
{
	return (m_vulnerable);
}

void
ncSurfacePropEntity::EnableAimAssist(void)
{
	m_autoAim = true;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::DisableAimAssist(void)
{
	m_autoAim = false;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::MakeVulnerable(void)
{
	m_vulnerable = true;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::MakeInvulnerable(void)
{
	m_vulnerable = false;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::_UpdateTakedamage(void)
{
	if (!m_vulnerable) {
		takedamage = DAMAGE_NO;
	} else {
		if (m_autoAim) {
			takedamage = DAMAGE_AIM;
		} else {
			takedamage = DAMAGE_YES;
		}
	}
}

void
ncSurfacePropEntity::SetHealth(float new_health)
{
	if (m_bonusHealth && new_health < health) {
		float delta = health - new_health;
		m_bonusHealth = bound(0, m_bonusHealth - delta, 100);
	}

	if (max_health > 0) {
		health = min(new_health, GetMaxHealth());
	} else {
		health = new_health;
	}
}

void
ncSurfacePropEntity::SetMaxHealth(float new_health)
{
	max_health = new_health;
	health =  min(health, max_health);
}

void
ncSurfacePropEntity::SetMaxArmor(float new_armor)
{
	max_armor = new_armor;
	armor =  min(armor, max_armor);
}

float
ncSurfacePropEntity::GetHealth(void)
{
	return (health);
}

float
ncSurfacePropEntity::GetMaxHealth(void)
{
	return (max_health + m_bonusHealth);
}

float
ncSurfacePropEntity::GetMaxArmor(void)
{
	return (max_armor + m_bonusArmor);
}

void
ncSurfacePropEntity::SetArmor(float new_armor)
{
	if (m_bonusArmor && new_armor < armor) {
		float delta = armor - new_armor;
		m_bonusArmor = bound(0, m_bonusArmor - delta, 100);
	}

	if (max_armor > 0) {
		armor = min(new_armor, GetMaxArmor());
	} else {
		armor = new_armor;
	}
}

float
ncSurfacePropEntity::GetArmor(void)
{
	return (armor);
}

void
ncSurfacePropEntity::AddBonusHealth(float bonusHealth)
{
	/* poke max_health directly here, else we'll include the bonus health = recursion */
	float pointsTilMax = bound(0, max_health - GetHealth(), 100);

	/*EntWarning("pointsTilMax: %d (%d - %d)", pointsTilMax, max_health, GetHealth());*/

	/* sufficient bonus points to go above max_health. */
	if (bonusHealth > pointsTilMax) {
		float newBonusHealth = bonusHealth - pointsTilMax;
		/*EntWarning("newBonusHealth: %d (%d - %d)", newBonusHealth, bonusHealth, pointsTilMax);*/
		m_bonusHealth = bound(0, m_bonusHealth + newBonusHealth, 100);
		m_timeUntilBonusHealthDecreases = GetTime() + 1.0f;
		SetHealth(bound(0, max_health + m_bonusHealth, max_health + m_bonusHealth));
	} else {
		SetHealth(GetHealth() + bonusHealth);
	}
}

void
ncSurfacePropEntity::AddBonusArmor(float bonusArmor)
{
	/* poke max_armor directly here, else we'll include the bonus armor = recursion */
	float pointsTilMax = bound(0, max_armor - GetArmor(), 100);

	/*EntWarning("pointsTilMax: %d (%d - %d)", pointsTilMax, max_armor, GetArmor());*/

	/* sufficient bonus points to go above max_armor. */
	if (bonusArmor > pointsTilMax) {
		float newBonusArmor = bonusArmor - pointsTilMax;
		/*EntWarning("newBonusArmor: %d (%d - %d)", newBonusArmor, bonusArmor, pointsTilMax);*/
		m_bonusArmor = bound(0, m_bonusArmor + newBonusArmor, 100);
		m_timeUntilBonusArmorDecreases = GetTime() + 1.0f;
		SetArmor(bound(0, max_armor + m_bonusArmor, max_armor + m_bonusArmor));
	} else {
		SetArmor(GetArmor() + bonusArmor);
	}
}

float
ncSurfacePropEntity::GetBonusArmor(void)
{
	return (m_bonusArmor);
}

float
ncSurfacePropEntity::GetBonusHealth(void)
{
	return (m_bonusHealth);
}

void
ncSurfacePropEntity::ParentUpdate(void)
{
	/* TODO: Move out */
	if (IsOnFire()) {
		if (m_timeUntilNextBurnDamage < GetTime()) {
			if (GetTime() > m_timeUntilBurningStops) {
				Extinguish();
			}

			SetHealth(GetHealth() - 5);

			if (GetHealth() <= 0) {
				Death(m_burningAttacker, m_burningAttacker, 5i, g_vec_null, origin, 0i);
				Extinguish();
			} else {
				Pain(m_burningAttacker, m_burningAttacker, 5i, g_vec_null, origin, 0i);
			}

			m_timeUntilNextBurnDamage = GetTime() + 0.5f;
		}
	}

	/* only possible if bonusHealth is amping it up */
	if (GetHealth() > max_health) {
		if (m_timeUntilBonusHealthDecreases < GetTime()) {
			m_bonusHealth = bound(0, m_bonusHealth - 1, 100);
			m_timeUntilBonusHealthDecreases = GetTime() + 1.0f;

			/* clamp our final health value to the newest max health */
			health = (bound(0, GetHealth(), GetMaxHealth()));
		}
	} else {
		m_bonusHealth = 0;
		m_timeUntilBonusHealthDecreases = 0.0f;
		SetHealth(bound(0, GetHealth(), GetMaxHealth()));
	}

	/* only possible if bonusArmor is amping it up */
	if (GetArmor() > max_armor) {
		if (m_timeUntilBonusArmorDecreases < GetTime()) {
			m_bonusArmor = bound(0, m_bonusArmor - 1, 100);
			m_timeUntilBonusArmorDecreases = GetTime() + 1.0f;

			/* clamp our final armor value to the newest max armor */
			armor = (bound(0, GetArmor(), GetMaxArmor()));
		}
	} else {
		m_bonusArmor = 0;
		m_timeUntilBonusArmorDecreases = 0.0f;
		SetArmor(bound(0, GetArmor(), GetMaxArmor()));
	}

	super::ParentUpdate();
}

void
ncSurfacePropEntity::Damage(entity inflictor, entity attacker, ncDict damageDecl, float damageScale, vector dmgDir, vector hitLocation)
{
	ncSurfacePropEntity ourAttacker;
	float damagePoints = 0.0f;
	float randomDamage = 0.0f;
	float baseDamage = 0.0f;
	float oldHealth = GetHealth();
	float halfHealth = max_health / 2.0f;
	float igniteTime = 0.0f;

	if (IsVulnerable() == false) {
		return;
	}

	ourAttacker = (ncSurfacePropEntity)attacker;
	baseDamage = ReadFloat(damageDecl.GetString("damage"));
	randomDamage = random(0, ReadFloat(damageDecl.GetString("damage_random")));
	damagePoints = (float)rint((baseDamage + randomDamage) * damageScale);
	igniteTime = ReadFloat(damageDecl.GetString("ignite"));

	if (igniteTime > 0.0f) {
		Ignite(attacker, igniteTime, damageDecl.GetString("weapon"));
		EntLog("damage causes entity to burn for %f seconds", igniteTime);
	}

	EntLog("applying %d damage by %s", damagePoints, attacker.classname);

	/* notify them */
	if (is.Sentient(attacker)) {
		ourAttacker.DamageFeedback(this, inflictor, damagePoints);
	}

	if (GetMovetype() == MOVETYPE_PHYSICS) {
		ncPhysicsEntity meSelf = (ncPhysicsEntity)this;
		float pushForce = damageDecl.GetFloat("push");

		if (pushForce > 0.0f) {
			meSelf.ApplyForceOffset(dmgDir * pushForce, hitLocation);
		}
	}

	if (damagePoints != 0) {
		SetHealth(rint(GetHealth() - damagePoints));

		if (GetHealth() < halfHealth && oldHealth > halfHealth) {
			UseOutput(attacker, m_outputOnHalfHealth);
		}

		if (is.Player(attacker)) {
			UseOutput(attacker, m_outputOnDamagedByPlayer);
		}

		UseOutput(attacker, m_outputOnDamaged);

		if (GetHealth() <= 0) {
			/* apply knockback, but only on death */
			float knockBack = damageDecl.GetFloat("knockback");

			if (knockBack >= 0) {
				AddVelocity(dmgDir * knockBack);
			}

			Death(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, damageDecl.GetInteger("hitbody"));
		} else if (damagePoints > 0) {
			Pain(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, damageDecl.GetInteger("hitbody"));
		}
	}
}

/* Burning, fire, flames, etc. */
void
ncSurfacePropEntity::Ignite(entity attacker, float burnTime, string weaponDef)
{
	AddEffects(EF_ONFIRE);
	m_burningAttacker = attacker;
	m_burningWeapon = weaponDef;
	m_timeUntilBurningStops = GetTime() + burnTime;

	if (m_timeUntilNextBurnDamage < time) {
		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", "5");
		damageDecl.AddKey("noArmor", "1");
		damageDecl.AddKey("type", "burn");
		damageDecl.AddKey("weapon", "weaponDef");
		Damage(m_burningAttacker, m_burningAttacker, damageDecl, 1.0f, g_vec_null, origin);
		remove(damageDecl);
		m_timeUntilNextBurnDamage = time + 0.25f;
	}
}

bool
ncSurfacePropEntity::CanBeDamaged(vector damageOrigin, vector hitLocation)
{
	vector testCenter = WorldSpaceCenter();

	traceline(hitLocation, testCenter, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, 15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, -15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, 15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, -15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	return (false);
}

void
ncSurfacePropEntity::Extinguish(void)
{
	RemoveEffects(EF_ONFIRE);
	m_burningAttacker = __NULL__;
	m_burningWeapon =
	m_timeUntilBurningStops = 0;
}

void
ncSurfacePropEntity::Respawn(void)
{
	float sh = GetSpawnFloat("health");

	super::Respawn();

	/* only use spawndata's health if we aren't overriding it */
	if (HasPropData() != false && sh <= 0) {
		SetHealth((float)GetPropData(PROPINFO_HEALTH));
	} else {
		SetHealth(sh);
	}

	if (GetHealth() > 0) {
		MakeVulnerable();
	} else {
		MakeInvulnerable();
	}

	string surfDataOverride = GetSpawnString("surfdata");

	if (STRING_SET(surfDataOverride)) {
		SetSurfaceData(surfDataOverride);
	}
}

void
ncSurfacePropEntity::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "timeUntilNextBurnDamage", m_timeUntilNextBurnDamage);
	SaveFloat(handle, "burningAttacker", num_for_edict(m_burningAttacker));
	SaveString(handle, "burningWeapon", m_burningWeapon);
	SaveFloat(handle,"timeUntilBurningStops", m_timeUntilBurningStops);
	SaveFloat(handle, "timeUntilNextBurnDamage", m_timeUntilNextBurnDamage);
	
	SaveString(handle, "outputOnDamaged", m_outputOnDamaged);
	SaveString(handle, "outputOnDamagedByPlayer", m_outputOnDamagedByPlayer);
	SaveString(handle, "outputOnHalfHealth", m_outputOnHalfHealth);
	SaveString(handle, "outputOnDeath", m_outputOnDeath);
	SaveString(handle, "outputOnBreak", m_outputOnBreak);

	SaveInt(handle, "surfdataID", m_surfdataID);
	SaveInt(handle, "propdataID", m_propdataID);
	SaveFloat(handle, "timeOfDeath", m_timeOfDeath);
	SaveFloat(handle, "max_armor", max_armor);
	SaveFloat(handle, "vulnerable", m_vulnerable);
	SaveFloat(handle, "autoAim", m_autoAim);
}

void
ncSurfacePropEntity::Restore(string keyName, string savedValue)
{
	switch (keyName) {
	case "timeUntilNextBurnDamage":
		m_timeUntilNextBurnDamage = ReadFloat(savedValue);
		break;
	case "burningAttacker":
		m_burningAttacker = edict_num(ReadFloat(savedValue));
		break;
	case "burningWeapon":
		m_burningWeapon = ReadString(savedValue);
		break;
	case "timeUntilBurningStops":
		m_timeUntilBurningStops = ReadFloat(savedValue);
		break;
	case "timeUntilNextBurnDamage":
		m_timeUntilNextBurnDamage = ReadFloat(savedValue);
		break;
	case "outputOnDamaged":
		m_outputOnDamaged = ReadString(savedValue);
		break;
	case "outputOnDamagedByPlayer":
		m_outputOnDamagedByPlayer = ReadString(savedValue);
		break;
	case "outputOnHalfHealth":
		m_outputOnHalfHealth = ReadString(savedValue);
		break;
	case "outputOnDeath":
		m_outputOnDeath = ReadString(savedValue);
		break;
	case "outputOnBreak":
		m_outputOnBreak = ReadString(savedValue);
		break;
	case "surfData":
		m_surfData = ReadString(savedValue);
		break;
	case "propData":
		m_propData = ReadString(savedValue);
		break;
	case "timeOfDeath":
		m_timeOfDeath = ReadFloat(savedValue);
		break;
	case "max_armor":
		max_armor = ReadFloat(savedValue);
		break;
	case "vulnerable":
		m_vulnerable = ReadBool(savedValue);
		break;
	case "autoAim":
		m_autoAim = ReadBool(savedValue);
		break;
	default:
		super::Restore(keyName, savedValue);
	}
}

void
ncSurfacePropEntity::RestoreComplete(void)
{
	/* tokenization complete, now we can load propdata */
	_SurfaceDataFinish();
	_PropDataFinish();
}

void
ncSurfacePropEntity::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "SetHealth":
		SetHealth(ReadFloat(dataField));
		break;
	case "SetMaxHealth":
		SetMaxHealth(ReadFloat(dataField));
		break;
	case "SetArmor":
		SetArmor(ReadFloat(dataField));
		break;
	case "SetMaxArmor":
		SetMaxArmor(ReadFloat(dataField));
		break;
	case "AddBonusHealth":
		AddBonusHealth(ReadFloat(dataField));
		break;
	case "AddBonusArmor":
		AddBonusArmor(ReadFloat(dataField));
		break;
	case "Ignite":
		Ignite(entityActivator, 5000, "");
		break;
	case "IgniteLifetime":
		float lifeTime = stof(dataField);
		Ignite(entityActivator, lifeTime, "");
		break;
	case "Extinguish":
		Extinguish();
		break;
	case "Damage":
		ncDict damageDecl = spawn(ncDict);
		float damagePoints = stof(dataField);
		damageDecl.AddKey("damage", dataField);
		Damage(this, this, damageDecl, 1.0, g_vec_null, GetOrigin());
		remove(damageDecl);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncSurfacePropEntity::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "max_health":
		max_health = ReadFloat(setValue);
		break;
	case "health":
		health = ReadFloat(setValue);

		/* just in case it never gets set elsewhere. */
		if (max_health == 0 && health > 0) {
			max_health = health;
		}
		break;
	case "propdata":
		m_propData = ReadString(setValue);
		break;
	case "surfdata":
	case "materialdata":
		m_surfData = ReadString(setValue);
		break;
	/* Input/Output system */
	case "OnDamaged":
		m_outputOnDamaged = PrepareOutput(m_outputOnDamaged, ReadString(setValue));
		break;
	case "OnDamagedByPlayer":
		m_outputOnDamagedByPlayer = PrepareOutput(m_outputOnDamagedByPlayer, ReadString(setValue));
		break;
	case "OnHalfHealth":
		m_outputOnHalfHealth = PrepareOutput(m_outputOnHalfHealth, ReadString(setValue));
		break;
	case "OnDeath":
		m_outputOnDeath = PrepareOutput(m_outputOnDeath, ReadString(setValue));
		break;
	case "OnBreak":
		m_outputOnBreak = PrepareOutput(m_outputOnBreak, ReadString(setValue));
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncSurfacePropEntity::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	/* implemented in sub-class */
}

void
ncSurfacePropEntity::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (takedamage == DAMAGE_NO) {
		return;
	}

	BreakModel(damage, dir, hitBody);
	UseOutput(attacker, m_outputOnDeath);
	Extinguish();
}

void
ncSurfacePropEntity::DamageFeedback(entity theVictim, entity theInflictor, int desiredDamage)
{
	/* implemented in sub-class */
}

void
ncSurfacePropEntity::BreakModel(int damage, vector dir, int location)
{
	float explosionMagnitude, explosionRadius;
	string gibeffect;
	int breakcount;
	float speedValue;

	m_timeOfDeath = time;

	/* the first thing we do is mark this as invulnerable, to avoid
	   any possible recursion in regards to damage later. */
	MakeInvulnerable();

	if (HasPropData() == false) {
		Disappear();
		return;
	}

	if (GetPropData(PROPINFO_SKIN) != 0) {
		SetSkin(GetPropData(PROPINFO_SKIN));
	} else if (GetPropData(PROPINFO_BREAKMODEL) != __NULL__) {
		speedValue = length(GetVelocity());

		/* if we have enough momentum of our own, use that instead. */
		if (speedValue > damage) {
			BreakModel_Entity(this, normalize(GetVelocity()), speedValue * 0.5f); /* absorb some power */
		} else {
			BreakModel_Entity(this, dir, damage);
		}
		
		SoundDef_PlayAt(GetOrigin(), GetSurfaceData(SURFDATA_SND_BREAK));
		Disappear();
	} else {
		Disappear();
	}

	/* handle explosions */
	explosionMagnitude = GetPropData(PROPINFO_EXPLOSIVE_DMG);
	explosionRadius = GetPropData(PROPINFO_EXPLOSIVE_RADIUS);

	if (explosionMagnitude) {
		if (explosionRadius <= 0) {
			explosionRadius = explosionMagnitude * 2.5f;
		}

		pointparticles(particleeffectnum("fx_explosion.main"), GetOrigin(), GetAngles(), 1);
		combat.RadiusDamage(GetOrigin(), explosionRadius, 0i, (int)explosionMagnitude, this, "");
	}

	UseOutput(this, m_outputOnBreak);
}

float
ncSurfacePropEntity::TimeSinceDeath(void)
{
	if (IsAlive()) {
		return (-1.0f);
	}

	return (time - m_timeOfDeath);
}

void
ncSurfacePropEntity::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SRFENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, SRFENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, SRFENT_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, SRFENT_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, SRFENT_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, SRFENT_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, SRFENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(flags, SRFENT_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, SRFENT_CHANGED_SIZE)
	EVALUATE_FIELD(frame, SRFENT_CHANGED_FRAME)
	EVALUATE_FIELD(skin, SRFENT_CHANGED_SKIN)
	EVALUATE_FIELD(effects, SRFENT_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_geomsetField, SRFENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 0, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 1, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_axialScale, 2, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_renderMode, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_renderFX, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_renderColor, 0, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 1, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 2, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)
}

/* Make sure StartFrame calls this */
float
ncSurfacePropEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex) {
		return (0);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_SURFPROP);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)

	return (1);
}

#else
/*
============
ncSurfacePropEntity::ReceiveEntity
============
*/
void
ncSurfacePropEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
	READENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
	READENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
	READENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
	READENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)

	/* this shall never be valid. use Hide() */
	if (scale == 0.0f) {
		scale = 1.0f;
	}

	/* other post-eval operations happen here */
	if (flChanged & SRFENT_CHANGED_SIZE) {
		setsize(this, mins * scale, maxs * scale);
	}

	if (flChanged & SRFENT_CHANGED_BODY) {
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_geomsetField, m_geomsetField));
	}

	if (flChanged & SRFENT_CHANGED_MODELINDEX) {
		_ModelChanged();
		_UpdateBoneCount();
	}
}

void
ncSurfacePropEntity::RenderFire(void)
{
	if (IsOnFire() == false) {
		return;
	}
	
	if (m_timeUntilNextBurnDamage < time) {
		vector randomOrg;
		randomOrg[0] = absmin[0] + ( random() * ( absmax[0] - absmin[0] ) );
		randomOrg[1] = absmin[1] + ( random() * ( absmax[1] - absmin[1] ) );
		randomOrg[2] = absmin[2] + ( random() * ( absmax[2] - absmin[2] ) );
		pointparticles(PART_BURNING, randomOrg, g_vec_null, 1);
		m_timeUntilNextBurnDamage = time + 0.1f;
	}
}

float
ncSurfacePropEntity::predraw(void)
{
	float oldEffects = effects;

	if (modelindex != 0) {
		RenderFire();
	}

	float returnValue = super::predraw();

	effects = oldEffects;
	return returnValue;
}

void
ncSurfacePropEntity_ReadEntity(bool isNew)
{
	float networkFlags;
	ncSurfacePropEntity rendEnt = (ncSurfacePropEntity)self;

	if (isNew) {
		spawnfunc_ncSurfacePropEntity();
	}

	networkFlags = readfloat();
	rendEnt.ReceiveEntity(isNew, networkFlags);
}
#endif

void
ncSurfacePropEntity::SetSurfaceData(string type)
{
	m_surfData = type;

	if (Loading() == false) {
		_SurfaceDataFinish();
	}
}

void
ncSurfacePropEntity::SetPropData(string type)
{
	m_propData = type;

	if (Loading() == false) {
		_PropDataFinish();
	}
}

bool
ncSurfacePropEntity::HasPropData(void)
{
	return (m_propdataID != -1) ? true : false;
}

__variant
ncSurfacePropEntity::GetPropData(int type)
{
	return Prop_GetInfo(m_propdataID, type);
}

bool
ncSurfacePropEntity::HasSurfaceData(void)
{
	return (m_surfdataID != -1) ? true : false;
}

__variant
ncSurfacePropEntity::GetSurfaceData(int type)
{
	return SurfData_GetInfo(m_surfdataID, type);
}

void
ncSurfacePropEntity::_SurfaceDataFinish(void)
{
	SurfData_SetStage(m_surfData);

	if (STRING_SET(m_surfData)) {
		m_surfdataID = SurfData_Finish();
	} else {
		m_surfdataID = -1i;
	}
}

void
ncSurfacePropEntity::_PropDataFinish(void)
{
	PropData_SetStage(m_propData);

	if (STRING_SET(m_propData)) {
		m_propdataID = PropData_Finish();
	} else {
		m_propdataID = -1i;
	}

	/* no surfdata? maybe the propdata has got one set. */
	if (m_surfdataID == -1i && m_propdataID != -1i) {
		string propDataSurf = GetPropData(PROPINFO_SURFACEPROP);

		if (STRING_SET(propDataSurf)) {
			SetSurfaceData(propDataSurf);
		}
	}
}

void
ncSurfacePropEntity::SetModel(string newModel)
{
	super::SetModel(newModel);

	if (IsBrush() == true) {
		return;
	}

	if (STRING_SET(model) && HasPropData() == false) {
		m_propdataID = PropData_ForModel(model);
		m_propData = model;
		_PropDataFinish();
	}
}
