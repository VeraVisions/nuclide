/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef CSTRIKE
#define PENETRATION
#endif

#ifdef PENETRATION
var int iTotalPenetrations;
#endif

void TraceAttack_FireSingle(vector vPos, vector vAngle, int iDamage)
{
#ifdef CSTRIKE
	traceline(vPos, vPos + (vAngle * wptTable[self.weapon].fRange), MOVE_LAGGED | MOVE_HITMODEL, self);
#else
	traceline(vPos, vPos + (vAngle * 8196), MOVE_LAGGED | MOVE_HITMODEL, self);
#endif

	if (trace_fraction != 1.0) {
		if (trace_ent.takedamage == DAMAGE_YES) {

			Damage_Apply(trace_ent, self, iDamage, trace_endpos, FALSE);

			/*if (trace_ent.health <= 0 && trace_ent.iBleeds == TRUE) {
				makevectors(self.v_angle);
				trace_ent.movetype = MOVETYPE_BOUNCE;
				trace_ent.velocity = (v_forward * (150 * iDamage)) + [0,0,100 * iDamage];
			}*/
		}

		if (trace_ent.iBleeds != TRUE) {
			string sTexture = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

			switch ((float)hash_get(hashMaterials, sTexture)) {
				case 'G':
				case 'V':
					Effect_Impact(IMPACT_METAL, trace_endpos, trace_plane_normal);
					break;
				case 'M':
				case 'P':
					Effect_Impact(IMPACT_METAL, trace_endpos, trace_plane_normal);
					break;
				case 'D':
				case 'W':
					Effect_Impact(IMPACT_WOOD, trace_endpos, trace_plane_normal);
					break;
				case 'Y':
					Effect_Impact(IMPACT_GLASS, trace_endpos, trace_plane_normal);
					break;
				case 'N':
					Effect_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
					break;
				case 'T':
				default:
					Effect_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
					break;
			 }

#ifdef PENETRATION
			if (iTotalPenetrations > 0) {
				iTotalPenetrations -= 1;
				TraceAttack_FireSingle(trace_endpos + (v_forward * 2), vAngle, iDamage);
			}
#endif
		}
	}
}

/*
=================
TraceAttack_FireBullets

Fire a given amount of shots
=================
*/
void TraceAttack_FireBullets(int iShots, vector vPos, int iDamage, vector vecAccuracy)
{
	vector vDir;
	makevectors(self.v_angle);

	while (iShots > 0) {
#ifdef PENETRATION
		iTotalPenetrations = 4;
#endif
		vDir = aim(self, 100000) + Math_CRandom()*vecAccuracy[0]*v_right + Math_CRandom()*vecAccuracy[1]*v_up;
		TraceAttack_FireSingle(vPos, vDir, iDamage);
		iShots--;
	}
}
