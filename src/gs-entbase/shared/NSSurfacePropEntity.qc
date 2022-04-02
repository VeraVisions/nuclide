/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

#ifdef SERVER
void
NSSurfacePropEntity::SetTakedamage(float type)
{
	takedamage = type;
}

void
NSSurfacePropEntity::SetHealth(float new_health)
{
	if (max_health > 0)
		health = min(new_health, max_health);
	else
		health = new_health;
}

void
NSSurfacePropEntity::SetMaxHealth(float new_health)
{
	max_health = new_health;
	health =  min(health, max_health);
}


float
NSSurfacePropEntity::GetHealth(void)
{
	return health;
}
float
NSSurfacePropEntity::GetMaxHealth(void)
{
	return max_health;
}
float
NSSurfacePropEntity::GetSpawnHealth(void)
{
	return m_oldHealth;
}

bool
NSSurfacePropEntity::HasPropData(void)
{
	return (m_iPropData != -1) ? true : false;
}

__variant
NSSurfacePropEntity::GetPropData(int type)
{
	return Prop_GetInfo(m_iPropData, type);
}

bool
NSSurfacePropEntity::HasSurfaceData(void)
{
	return (m_iMaterial != -1) ? true : false;
}

__variant
NSSurfacePropEntity::GetSurfaceData(int type)
{
	return SurfData_GetInfo(m_iMaterial, type);
}

void
NSSurfacePropEntity::ParentUpdate(void)
{
	/* TODO: Move out */
	if (flags & FL_ONFIRE) {
		if (m_flBurnNext < time) {
			if (time > m_flBurnTime) {
				flags &= ~FL_ONFIRE;
			}

			Damage_Apply(this, m_eBurner, 5, m_iBurnWeapon, DMG_BURN);
			m_flBurnNext = time + 0.5f;
		}
	}

	NSRenderableEntity::ParentUpdate();
}

/* Burning, fire, flames, etc. */
void
NSSurfacePropEntity::Ignite(entity attacker, float flLifetime, int iWeapon)
{
	flags |= FL_ONFIRE;
	m_eBurner = attacker;
	m_iBurnWeapon = iWeapon;
	m_flBurnTime = time + flLifetime;
}

void
NSSurfacePropEntity::Extinguish(void)
{
	flags &= ~FL_ONFIRE;
	m_eBurner = __NULL__;
	m_iBurnWeapon =
	m_flBurnTime = 0;
}

bool
NSSurfacePropEntity::IsOnFire(void)
{
	return (flags & FL_ONFIRE) ? true : false;
}

void
NSSurfacePropEntity::Respawn(void)
{
	float sh = GetSpawnHealth();
	NSRenderableEntity::Respawn();

	/* only use spawndata's health if we aren't overriding it */
	if (HasPropData() == false && sh <= 0) {
		health = (float)GetPropData(PROPINFO_HEALTH);
	} else {
		health = sh;
	}

	if (health > 0)
		takedamage = DAMAGE_YES;
	else
		takedamage = DAMAGE_NO;
}

void
NSSurfacePropEntity::Save(float handle)
{
	SaveFloat(handle, "m_eBurner", num_for_edict(m_eBurner));
	SaveInt(handle, "m_iBurnWeapon", m_iBurnWeapon);
	SaveFloat(handle,"m_flBurnTime", m_flBurnTime);
	SaveFloat(handle, "m_flBurnNext", m_flBurnNext);
	SaveString(handle, "m_strOnBreak", m_strOnBreak);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "m_oldHealth", m_oldHealth);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iPropData", m_iPropData);

	super::Save(handle);
}

void
NSSurfacePropEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eBurner":
		m_eBurner = edict_num(ReadFloat(strValue));
		break;
	case "m_iBurnWeapon":
		m_iBurnWeapon = ReadInt(strValue);
		break;
	case "m_flBurnTime":
		m_flBurnTime = ReadFloat(strValue);
		break;
	case "m_flBurnNext":
		m_flBurnNext = ReadFloat(strValue);
		break;
	case "m_strOnBreak":
		m_strOnBreak = ReadString(strValue);
		break;
	case "health":
		health = ReadFloat(strValue);
		break;
	case "m_oldHealth":
		m_oldHealth = ReadFloat(strValue);
		break;
	case "m_iMaterial":
		m_iMaterial = ReadInt(strValue);
		break;
	case "m_iPropData":
		m_iPropData = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSSurfacePropEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Ignite":
		Ignite(eAct, 5000, 0);
		break;
	case "IgniteLifetime":
		Ignite(eAct, stof(strData), 0);
		break;
	case "Extinguish":
		Extinguish();
		break;
	default:
		NSRenderableEntity::Input(eAct, strInput, strData);
	}
}

void
NSSurfacePropEntity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		health = stof(strValue);
		m_oldHealth = health;
		break;
	case "propdata":
		SetPropData(strValue);
		break;
	case "surfdata":
	case "materialdata":
		SetSurfaceData(strValue);
		break;
	/* Input/Output system */
#ifdef SERVER
	case "OnBreak":
		m_strOnBreak = PrepareOutput(m_strOnBreak, strValue);
		break;
#endif
	default:
		NSRenderableEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSSurfacePropEntity::Pain(void)
{
	
}

void
NSSurfacePropEntity::Death(void)
{
	UseOutput(g_dmg_eAttacker, m_strOnBreak);

	if (HasPropData() == false)
		return;

	if (GetPropData(PROPINFO_SKIN) != 0) {
		SetSkin(GetPropData(PROPINFO_SKIN));
	} else if (GetPropData(PROPINFO_BREAKMODEL) != __NULL__) {
		string gibeffect = GetPropData(PROPINFO_BREAKMODEL);
		int breakcount = GetPropData(PROPINFO_BREAKCOUNT);
		BreakModel_Spawn(absmin, absmax, [0,0,0], 100, breakcount, gibeffect);
		Hide();
	} else {
		Hide();
	}

	/* handle explosions */
	float flExplodeMag, flExplodeRad;
	flExplodeMag = GetPropData(PROPINFO_EXPLOSIVE_DMG);
	flExplodeRad = GetPropData(PROPINFO_EXPLOSIVE_RADIUS);

	if (flExplodeMag) {
		if (!flExplodeRad)
			flExplodeRad = flExplodeMag * 2.5f;

		FX_Explosion(origin);
		Damage_Radius(origin, this, flExplodeMag, flExplodeRad, TRUE, 0);
	}
}

void
NSSurfacePropEntity::SetSurfaceData(string type)
{
	m_strSurfData = type;
}
void
NSSurfacePropEntity::SetPropData(string type)
{
	m_strPropData = type;
}
void
NSSurfacePropEntity::SurfaceDataFinish(void)
{
	SurfData_SetStage(m_strSurfData);

	if (m_strSurfData)
		m_iMaterial = SurfData_Finish();
	else
		m_iMaterial = -1;
}
void
NSSurfacePropEntity::PropDataFinish(void)
{
	PropData_SetStage(m_strPropData);

	if (m_strPropData)
		m_iPropData = PropData_Finish();
	else
		m_iPropData = -1;
}
#else
float
NSSurfacePropEntity::predraw(void)
{
	if (flags & FL_ONFIRE) {
		vector someorg;

		if (m_flBurnNext < time) {
			someorg[0] = absmin[0] + ( random() * ( absmax[0] - absmin[0] ) );
			someorg[1] = absmin[1] + ( random() * ( absmax[1] - absmin[1] ) );
			someorg[2] = absmin[2] + ( random() * ( absmax[2] - absmin[2] ) );
			pointparticles(PART_BURNING, someorg, [0,0,0], 1);
			m_flBurnNext = time + 0.1f;
		}
	}
	return super::predraw();
}
#endif

void
NSSurfacePropEntity::SetModel(string newModel)
{
	NSRenderableEntity::SetModel(newModel);

#ifdef SERVER
	if (model && HasPropData() == false) {
		m_iPropData = PropData_ForModel(model);
	}
#endif
}

void
NSSurfacePropEntity::NSSurfacePropEntity(void)
{
#ifdef SERVER
	m_iPropData = -1;
	m_iMaterial = -1;

	super::NSRenderableEntity();

	/* tokenization complete, now we can load propdata */
	SurfaceDataFinish();
	PropDataFinish();

	/* Input/Output system */
	m_strOnBreak = CreateOutput(m_strOnBreak);
#endif
}
