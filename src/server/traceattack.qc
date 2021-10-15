/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

entity g_multiDamage_Target;
int g_multiDamage_Value;

static void
TraceAttack_Apply(entity eAttacker, int iWeapon)
{
	/* may not be defined yet */
	if (g_multiDamage_Target == __NULL__)
		return;

	if (trace_ent.iBleeds == 1) {
		FX_Blood(trace_endpos, [1,0,0]);
	}

	Damage_Apply(g_multiDamage_Target, self, g_multiDamage_Value, iWeapon, DMG_BULLET);
	g_multiDamage_Target = __NULL__;
	g_multiDamage_Value = 0;
}

void
TraceAttack_ImpactWorld(void)
{
	string tex_name;
	float surf;

	switch (serverkeyfloat("*bspversion")) {
	case BSPVER_HL:
		surf = getsurfacenearpoint(trace_ent, trace_endpos);
		tex_name = Materials_FixName(getsurfacetexture(trace_ent, surf));

		/* our hashtable is the key to all this */
		switch ((float)hash_get(hashMaterials, tex_name)) {
		case MATID_ALIEN:
			FX_Impact(IMPACT_ALIEN, trace_endpos, trace_plane_normal);
			break;
		case MATID_COMPUTER:
			FX_Impact(IMPACT_COMPUTER, trace_endpos, trace_plane_normal);
			break;
		case MATID_CONCRETE:
			FX_Impact(IMPACT_CONCRETE, trace_endpos, trace_plane_normal);
			break;
		case MATID_DIRT:
			FX_Impact(IMPACT_DIRT, trace_endpos, trace_plane_normal);
			break;
		case MATID_BLOODYFLESH:
		case MATID_FLESH:
			FX_Impact(IMPACT_FLESH, trace_endpos, trace_plane_normal);
			break;
		case MATID_FOLIAGE:
			FX_Impact(IMPACT_FOLIAGE, trace_endpos, trace_plane_normal);
			break;
		case MATID_GLASS:
			FX_Impact(IMPACT_GLASS, trace_endpos, trace_plane_normal);
			break;
		case MATID_GRATE:
			FX_Impact(IMPACT_GRATE, trace_endpos, trace_plane_normal);
			break;
		case MATID_METAL:
			FX_Impact(IMPACT_METAL, trace_endpos, trace_plane_normal);
			break;
		case MATID_SAND:
			FX_Impact(IMPACT_SAND, trace_endpos, trace_plane_normal);
			break;
		case MATID_SLOSH:
			FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
			break;
		case MATID_SNOW:
			FX_Impact(IMPACT_SNOW, trace_endpos, trace_plane_normal);
			break;
		case MATID_TILE:
			FX_Impact(IMPACT_TILE, trace_endpos, trace_plane_normal);
			break;
		case MATID_VENT:
			FX_Impact(IMPACT_VENT, trace_endpos, trace_plane_normal);
			break;
		case MATID_WOOD:
			FX_Impact(IMPACT_WOOD, trace_endpos, trace_plane_normal);
			break;
		default:
			FX_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
			break;
		}
		break;
	case BSPVER_Q3: /* Q3 */
	case BSPVER_RTCW: /* RtCW */
	case BSPVER_RBSP: /* RFVBSP */
		switch (trace_surfaceflagsi) {
		case SURF_ALIEN:
			FX_Impact(IMPACT_ALIEN, trace_endpos, trace_plane_normal);
			break;
		case SURF_COMPUTER:
			FX_Impact(IMPACT_COMPUTER, trace_endpos, trace_plane_normal);
			break;
		case SURF_CONCRETE:
			FX_Impact(IMPACT_CONCRETE, trace_endpos, trace_plane_normal);
			break;
		case SURF_DIRT:
			FX_Impact(IMPACT_DIRT, trace_endpos, trace_plane_normal);
			break;
		case SURF_BLOODYFLESH:
			FX_Impact(IMPACT_FLESH, trace_endpos, trace_plane_normal);
			break;
		case SURF_FOLIAGE:
			FX_Impact(IMPACT_FOLIAGE, trace_endpos, trace_plane_normal);
			break;
		case SURF_GLASS:
			FX_Impact(IMPACT_GLASS, trace_endpos, trace_plane_normal);
			break;
		case SURF_GRATE:
			FX_Impact(IMPACT_GRATE, trace_endpos, trace_plane_normal);
			break;
		case SURF_METAL:
			FX_Impact(IMPACT_METAL, trace_endpos, trace_plane_normal);
			break;
		case SURF_SAND:
			FX_Impact(IMPACT_SAND, trace_endpos, trace_plane_normal);
			break;
		case SURF_SLOSH:
			FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
			break;
		case SURF_SNOW:
			FX_Impact(IMPACT_SNOW, trace_endpos, trace_plane_normal);
			break;
		case SURF_TILE:
			FX_Impact(IMPACT_TILE, trace_endpos, trace_plane_normal);
			break;
		case SURF_VENT:
			FX_Impact(IMPACT_VENT, trace_endpos, trace_plane_normal);
			break;
		case SURF_WOOD:
			FX_Impact(IMPACT_WOOD, trace_endpos, trace_plane_normal);
			break;
		default:
			FX_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
			break;
		}
		break;
	default:
		FX_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
	}
}

/* cast a single bullet shot */
static void
TraceAttack_FireSingle(vector vecPos, vector vAngle, int iDamage, int iWeapon)
{
	vector range;

	range = (vAngle * 8196);

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(vecPos, vecPos + range, MOVE_LAGGED | MOVE_HITMODEL, self);
	self.hitcontentsmaski = oldhitcontents;

	if (trace_fraction >= 1.0f)
		return;

	if (trace_ent.takedamage == DAMAGE_YES && trace_ent.iBleeds) {
		Sound_Play(trace_ent, CHAN_BODY, "damage_bullet.hit");

#ifdef CSTRIKE
		player pl = (player)trace_ent;
		/* modify the damage based on the location */
		switch (trace_surface_id) {
		case BODY_HEAD:
			/* the helmet is one power house */
			if (pl.g_items & ITEM_HELMET) {
				iDamage = 0;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshotarmor");
				pl.g_items &= ~ITEM_HELMET;
				return;
			} else {
				iDamage *= 4;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshot");
			}
			break;
		case BODY_STOMACH:
			iDamage *= 0.9;
			if (pl.armor > 0)
				Sound_Play(trace_ent, CHAN_BODY, "player.hitarmor");
			break;
		case BODY_LEGLEFT:
		case BODY_LEGRIGHT:
			iDamage *= 0.4;
			break;
		}
#else
		/* only headshots count in HL */
		if (trace_surface_id == BODY_HEAD)
			iDamage *= 3;
#endif
	}

	/* impact per bullet */
	if (trace_ent.iBleeds == 0) {
		if (trace_ent == world) {
			TraceAttack_ImpactWorld();
		} else {
			CBaseEntity foo = (CBaseEntity)trace_ent;
			switch (foo.m_iMaterial) {
			case BREAKMT_GLASS:
				FX_Impact(IMPACT_GLASS, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_WOOD:
				FX_Impact(IMPACT_WOOD, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_METAL:
				FX_Impact(IMPACT_METAL, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_FLESH:
				FX_Impact(IMPACT_FLESH, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_CINDER:
				FX_Impact(IMPACT_CONCRETE, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_TILE:
				FX_Impact(IMPACT_TILE, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_COMPUTER:
				FX_Impact(IMPACT_COMPUTER, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_GLASS_UNBREAKABLE:
				FX_Impact(IMPACT_GLASS, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_ROCK:
				FX_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
				break;
			case BREAKMT_NONE:
				FX_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
				break;
			}
		}
	}

	/* combine them into one single Damage_Apply call later */
	if (trace_ent.takedamage == DAMAGE_YES) {
		if (trace_ent != g_multiDamage_Target) {
			TraceAttack_Apply(self, iWeapon);
			g_multiDamage_Target = trace_ent;
			g_multiDamage_Value = iDamage;
		} else {
			g_multiDamage_Value += iDamage;
		}
	}

#ifdef BULLETPENETRATION
	if (iTotalPenetrations > 0) {
		iTotalPenetrations -= 1;
		TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage / 2, iWeapon);
	}
#endif
}

/* fire a given amount of shots */
void
TraceAttack_FireBullets(int iShots, vector vecPos, int iDamage, vector vecSpread, int iWeapon)
{
	vector vDir;
	makevectors(self.v_angle);

	g_multiDamage_Target = __NULL__;
	g_multiDamage_Value = 0;

	while (iShots > 0) {
		vDir = aim(self, 100000);
#ifndef BULLETPATTERNS
		vDir += random(-1,1) * vecSpread[0] * v_right;
		vDir += random(-1,1) * vecSpread[1] * v_up;
#else
		player pl = (player)self;

		/* weapons have already applied their multiplier... so attempt this */
		int multiplier = pl.cs_shotmultiplier - iShots;
		float frand = (multiplier / 6);

		/* shoddy attempt at spray patterns */
		if (frand < 1)
			frand = frand;
		else if (frand <= 2)
			frand = 2 - (frand * 1.5);

		vDir += frand * vecSpread[0] * v_right;
		vDir += (vecSpread[1] * v_up) * 2;
#endif
		TraceAttack_FireSingle(vecPos, vDir, iDamage, iWeapon);
		iShots--;
	}
	
	if (g_multiDamage_Target) {
		TraceAttack_Apply(self, iWeapon);
	}
}

#ifdef BULLETPENETRATION
void
TraceAttack_SetPenetrationPower(int power)
{
	iTotalPenetrations = power;
}
#endif
