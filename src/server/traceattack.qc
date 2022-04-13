/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
int g_multiDamage_HitBod;

static void
TraceAttack_Apply(entity eAttacker, int iWeapon)
{
	/* may not be defined yet */
	if (g_multiDamage_Target == __NULL__)
		return;

	if (trace_ent.iBleeds == 1) {
		FX_Blood(trace_endpos, [1,0,0]);
	}

	trace_surface_id = g_multiDamage_HitBod;
	Damage_Apply(g_multiDamage_Target, self, g_multiDamage_Value, iWeapon, DMG_BULLET);
	g_multiDamage_Target = __NULL__;
	g_multiDamage_Value = 0;
	g_multiDamage_HitBod = 0;
}

void
TraceAttack_ImpactWorld(void)
{
	
}

/* cast a single bullet shot */
static void
TraceAttack_FireSingle(vector vecPos, vector vAngle, int iDamage, int iWeapon, float dist)
{
	vector range;

	if (dist <= 0)
		return;

	range = (vAngle * 8196);

	self.dimension_solid = 255;
	self.dimension_hit = 255;

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(vecPos, vecPos + range, MOVE_LAGGED | MOVE_HITMODEL, self);
	self.hitcontentsmaski = oldhitcontents;

	dist -= trace_plane_dist;

	self.dimension_solid = 254;
	self.dimension_hit = 254;

	g_multiDamage_HitBod |= trace_surface_id;

	if (trace_fraction >= 1.0f)
		return;

	/* water impact */
	if (trace_endcontentsi & CONTENTBIT_WATER) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage / 2, iWeapon, dist);
	} else if (trace_endcontentsi & CONTENTBIT_SLIME) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage / 2, iWeapon, dist);
	} else if (trace_endcontentsi & CONTENTBIT_LAVA) {
		FX_Impact(IMPACT_SLOSH, trace_endpos, trace_plane_normal);
		TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage / 2, iWeapon, dist);
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
		SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
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
		if (!(trace_surfaceflagsi & SURF_PENETRATE))
			iTotalPenetrations -= 1;
		TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage / 2, iWeapon, dist);
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
		TraceAttack_FireSingle(vecPos, vDir, iDamage, iWeapon, 8196);
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
