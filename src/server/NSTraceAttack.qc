/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
NSTraceAttack::NSTraceAttack(void)
{
	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;
	m_iMultiBody = 0;
	m_flRange = 8196;
	//m_iDecalGroup = -1;
	m_strDecalGroup = __NULL__;

#ifdef BULLETPENETRATION
	m_flMaxThickness = 5.0f;
	m_flRangeModifier = 1.0f;
	m_iTotalPenetrations = 0;
#endif

	identity = 1;
};

void
NSTraceAttack::Save(float handle)
{
	SaveEntity(handle, "m_eMultiTarget", m_eMultiTarget);
	SaveInt(handle, "m_iMultiValue", m_iMultiValue);
	SaveInt(handle, "m_iMultiBody", m_iMultiBody);
	SaveInt(handle, "m_iShots", m_iShots);
	SaveFloat(handle, "m_flDamage", m_flDamage);
	SaveVector(handle, "m_vecSpread", m_vecSpread);
	SaveInt(handle, "m_iWeapon", m_iWeapon);
	SaveEntity(handle, "m_eOwner", m_eOwner);
	SaveFloat(handle, "m_flRange", m_flRange);
	SaveVector(handle, "m_vecOrigin", m_vecOrigin);
	SaveString(handle, "m_strDecalGroup", m_strDecalGroup);

#ifdef BULLETPENETRATION
	SaveFloat(handle, "m_flMaxThickness", m_flMaxThickness);
	SaveFloat(handle, "m_flRangeModifier", m_flRangeModifier);
	SaveInt(handle, "m_iTotalPenetrations", m_iTotalPenetrations);
#endif
}

void
NSTraceAttack::RestoreComplete(void)
{
	g_traceAttack = this;
}

void
NSTraceAttack::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eMultiTarget":
		m_eMultiTarget = ReadEntity(strValue);
		break;
	case "m_iMultiValue":
		m_iMultiValue = ReadInt(strValue);
		break;
	case "m_iMultiBody":
		m_iMultiBody = ReadInt(strValue);
		break;

	case "m_iShots":
		m_iShots = ReadInt(strValue);
		break;
	case "m_flDamage":
		m_flDamage = ReadFloat(strValue);
		break;
	case "m_vecSpread":
		m_vecSpread = ReadVector(strValue);
		break;
	case "m_iWeapon":
		m_iWeapon = ReadInt(strValue);
		break;
	case "m_eOwner":
		m_eOwner = ReadEntity(strValue);
		break;
	case "m_flRange":
		m_flRange = ReadFloat(strValue);
		break;
	case "m_vecOrigin":
		m_vecOrigin = ReadVector(strValue);
		break;
	case "m_strDecalGroup":
		m_strDecalGroup = ReadString(strValue);
		break;

	/* bullet penetration */
#ifdef BULLETPENETRATION
	case "m_flMaxThickness":
		m_flMaxThickness = ReadFloat(strValue);
		break;
	case "m_flRangeModifier":
		m_flRangeModifier = ReadFloat(strValue);
		break;
	case "m_iTotalPenetrations":
		m_iTotalPenetrations = ReadInt(strValue);
		break;
#endif
	}
}

void
NSTraceAttack::_ApplyDamage(void)
{
	/* may not be defined yet */
	if (m_eMultiTarget == __NULL__)
		return;

	/* the location _could_ be more accurate... */
	if (m_eMultiTarget.iBleeds == 1) {
		FX_Blood(trace_endpos, [0.5,0,0]);
	}

	trace_surface_id = m_iMultiBody;
	g_dmg_vecLocation = trace_endpos;
	Damage_Apply(m_eMultiTarget, m_eOwner, m_iMultiValue, m_iWeapon, DMG_BULLET);
	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;
	m_iMultiBody = 0;
}


void
NSTraceAttack::_FireSingle(vector vecPos, vector vecAngles, float flDamage, float flRange)
{
	vector range;

	if (flRange <= 0)
		return;

	if (flDamage < 1)
		return;

	range = (vecAngles * 8196);

	m_eOwner.dimension_solid = 255;
	m_eOwner.dimension_hit = 255;

	/* make sure we can gib corpses */
	int oldhitcontents = m_eOwner.hitcontentsmaski;
	m_eOwner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(vecPos, vecPos + range, MOVE_LAGGED | MOVE_HITMODEL, m_eOwner);
	m_eOwner.hitcontentsmaski = oldhitcontents;

	flRange -= trace_plane_dist;

	m_eOwner.dimension_solid = 254;
	m_eOwner.dimension_hit = 254;

	m_iMultiBody |= trace_surface_id;

	if (trace_fraction >= 1.0f)
		return;

	/* water impact */
	if (trace_endcontentsi & CONTENTBIT_WATER) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		_FireSingle(trace_endpos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	} else if (trace_endcontentsi & CONTENTBIT_SLIME) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		_FireSingle(trace_endpos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	} else if (trace_endcontentsi & CONTENTBIT_LAVA) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		_FireSingle(trace_endpos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	}

	if (trace_ent.takedamage == DAMAGE_YES && trace_ent.iBleeds) {
		Sound_Play(trace_ent, CHAN_BODY, "damage_bullet.hit");

#ifdef CSTRIKE
		player pl = (player)trace_ent;
		/* modify the damage based on the location */
		switch (trace_surface_id) {
		case BODY_HEAD:
			/* the helmet is one power house */
			if (pl.g_items & ITEM_HELMET) {
				m_flDamage = 0;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshotarmor");
				pl.g_items &= ~ITEM_HELMET;
				return;
			} else {
				m_flDamage *= 4;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshot");
			}
			break;
		case BODY_STOMACH:
			m_flDamage *= 0.9;
			if (pl.armor > 0)
				Sound_Play(trace_ent, CHAN_BODY, "player.hitarmor");
			break;
		case BODY_LEGLEFT:
		case BODY_LEGRIGHT:
			m_flDamage *= 0.4;
			break;
		}
#else
		/* only headshots count in HL */
		if (trace_surface_id == BODY_HEAD)
			m_flDamage *= 3;
#endif
	}

#ifdef WASTES
	player pl1 = (player)self;
	if (pl1.m_iWillpowerValue > 0) {
		FX_Crit(trace_endpos, vectoangles(trace_endpos - pl1.origin), 0);
	}
#endif

	/* impact per bullet */
	if (trace_ent.iBleeds == 0) {
		if (m_strDecalGroup)
			DecalGroups_Place(m_strDecalGroup, trace_endpos + (v_forward * -2));

		SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
	}

	/* combine them into one single Damage_Apply call later */
	if (trace_ent.takedamage == DAMAGE_YES) {
		if (trace_ent != m_eMultiTarget) {
			_ApplyDamage();
			m_eMultiTarget = trace_ent;
			m_iMultiValue = flDamage;
		} else {
			m_iMultiValue += flDamage;
		}
	}

#ifdef BULLETPENETRATION
	if (m_iTotalPenetrations > 0) {
		float cont;

		if (!(trace_surfaceflagsi & SURF_PENETRATE))
			m_iTotalPenetrations -= 1;

		/* check if this wall is 6 units thick... */
		if (m_iTotalPenetrations > 0) {
			cont = pointcontents(trace_endpos + v_forward * 5);

			if (cont == CONTENT_SOLID)
				m_iTotalPenetrations -= 1; /* deduct 1 penetration power */
		}

		cont = pointcontents(trace_endpos + v_forward * m_flMaxThickness);

		if (cont == CONTENT_EMPTY)
			_FireSingle(trace_endpos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	}
#endif
}

void
NSTraceAttack::Fire(void)
{
	vector vecDir;
	makevectors(m_eOwner.v_angle);

	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;

	while (m_iShots > 0) {
		if (m_eOwner.flags & FL_CLIENT) {
			vecDir = aim(m_eOwner, 100000);
		} else {
			makevectors(m_eOwner.v_angle);
			vecDir = v_forward;
		}

#ifndef BULLETPATTERNS
		vecDir += random(-1,1) * m_vecSpread[0] * v_right;
		vecDir += random(-1,1) * m_vecSpread[1] * v_up;
#else
		/* FOR NOW Monsters will not be able to do spread like players if patterns are enabled */
		if (!(m_eOwner.flags & FL_CLIENT)) {
			vecDir += random(-1,1) * m_vecSpread[0] * v_right;
			vecDir += random(-1,1) * m_vecSpread[1] * v_up;
		} else {
			player pl = (player) m_eOwner;

			/* weapons have already applied their multiplier... so attempt this */
			int multiplier = pl.cs_shotmultiplier - m_iShots;
			float frand = (multiplier / 6);

			/* shoddy attempt at spray patterns */
			if (frand < 1)
				frand = frand;
			else if (frand <= 2)
				frand = 2 - (frand * 1.5);

			vecDir += frand * m_vecSpread[0] * v_right;
			vecDir += (m_vecSpread[1] * v_up) * 2;
		}
#endif
		_FireSingle(m_vecOrigin, vecDir, m_flDamage, m_flRange);
		m_iShots--;
	}

	if (m_eMultiTarget) {
		_ApplyDamage();
	}
}

void
NSTraceAttack::SetShots(int iShots)
{
	m_iShots = iShots;
}

void
NSTraceAttack::SetOrigin(vector vecOrigin)
{
	m_vecOrigin = vecOrigin;
}

void
NSTraceAttack::SetDamage(int iDamage)
{
	m_flDamage = (float)iDamage;
}

void
NSTraceAttack::SetSpread(vector vecSpread)
{
	m_vecSpread = vecSpread;
}

void
NSTraceAttack::SetWeapon(int iWeapon)
{
	m_iWeapon = iWeapon;
}

void
NSTraceAttack::SetRange(float flRange)
{
	m_flRange = flRange;
}

void
NSTraceAttack::SetOwner(entity eOwner)
{
	m_eOwner = eOwner;
}

void
NSTraceAttack::SetDecalGroup(string strGroupName)
{
	//int m_iDecalGroup = DecalGroups_NumForName(strGroupName);
	m_strDecalGroup = strGroupName;
}

#ifdef BULLETPENETRATION
void
NSTraceAttack::SetPenetrationMaxThickness(float flThickness)
{
	m_flMaxThickness = flThickness;
}
void
NSTraceAttack::SetPenetrationPower(int iPower)
{
	m_iTotalPenetrations = iPower;
}
#endif

/* fire a given amount of shots */
void
TraceAttack_FireBullets(int iShots, vector vecPos, int iDamage, vector vecSpread, int iWeapon)
{
	if (!g_traceAttack) {
		g_traceAttack = spawn(NSTraceAttack);
	}

	g_traceAttack.SetShots(iShots);
	g_traceAttack.SetOrigin(vecPos);
	g_traceAttack.SetDamage(iDamage);
	g_traceAttack.SetSpread(vecSpread);
	g_traceAttack.SetWeapon(iWeapon);
	g_traceAttack.SetOwner(self);
	g_traceAttack.Fire();
}

void
TraceAttack_FireBulletsWithDecal(int iShots, vector vecPos, int iDamage, vector vecSpread, int iWeapon, string strDecalGroup)
{
	if (!g_traceAttack) {
		g_traceAttack = spawn(NSTraceAttack);
	}

	g_traceAttack.SetShots(iShots);
	g_traceAttack.SetOrigin(vecPos);
	g_traceAttack.SetDamage(iDamage);
	g_traceAttack.SetSpread(vecSpread);
	g_traceAttack.SetWeapon(iWeapon);
	g_traceAttack.SetOwner(self);
	g_traceAttack.SetDecalGroup(strDecalGroup);
	g_traceAttack.Fire();
}

#ifdef BULLETPENETRATION
void
TraceAttack_SetRangeModifier(float units)
{
	if (!g_traceAttack) {
		g_traceAttack = spawn(NSTraceAttack);
	}
	g_traceAttack.m_flRangeModifier = (units);
}
void
TraceAttack_SetPenetrationPower(int power)
{
	if (!g_traceAttack) {
		g_traceAttack = spawn(NSTraceAttack);
	}
	g_traceAttack.SetPenetrationPower(power);
	/* thickness equals 8 units per power times rangemodifier */
	g_traceAttack.SetPenetrationMaxThickness((8 * power) * g_traceAttack.m_flRangeModifier);
}
#endif

/* generic function that applies damage, pain and suffering */
void
Damage_Apply(entity t, entity c, float dmg, int w, damageType_t type)
{
	CGameRules rules = (CGameRules)g_grMode;
	rules.DamageApply(t, c, dmg, w, type);
}

/* physical check of whether or not we can trace important parts of an ent */
float
Damage_CheckTrace(entity t, vector vecHitPos)
{
	CGameRules rules = (CGameRules)g_grMode;
	return rules.DamageCheckTrace(t, vecHitPos);
}

/* even more pain and suffering, mostly used for explosives */
void
Damage_Radius(vector org, entity attacker, float dmg, float r, int check, int w)
{
	CGameRules rules = (CGameRules)g_grMode;
	rules.DamageRadius(org, attacker, dmg, r, check, w);
}
