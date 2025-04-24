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
ncAttack::ncAttack(void)
{
#ifdef SERVER
	m_weaponOwner = __NULL__;
#endif
}

#ifdef SERVER
void
ncAttack::SetWeaponOwner(ncWeapon weaponOwner)
{
	m_weaponOwner = weaponOwner;
}

ncWeapon
ncAttack::GetWeaponOwner(void)
{
	return (m_weaponOwner);
}

void
Grapple_Touch(void)
{

	ncPlayer pl = (ncPlayer)self.owner;

#ifdef GEARBOX
	string tex = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

	/* only if name "XENO_GRAPPLE_" according to TWHL */
	if (substring(tex, 0, 13) == "xeno_grapple_") {
#else
	if (1) {
#endif
		pl.m_hook.movetype = MOVETYPE_NONE;
		pl.m_hook.touch = __NULL__;
		pl.m_hook.velocity = g_vec_null;
		pl.m_hook.solid = SOLID_NOT;
		pl.m_pmoveHookVelocity = (pl.m_hook.origin);
	}  else {
		pl.m_hook.skin = 0; /* ungrappled */
		remove(pl.m_hook);
		pl.m_hook = __NULL__;
		pl.m_pmoveHookVelocity = g_vec_null;
	}
}


void
ncAttack::Launch(vector startPos, vector launchDir, float fuseOffset, float powerMultiplier, float dmgMultiplier)
{
	ncEntity plantedEntity;
	ncPlayer ourOwner = (ncPlayer)m_weaponOwner.owner;
	vector forwardDir = g_vec_null;

	bool willPlant = GetSpawnBool("plant");
	bool willDrop = GetSpawnBool("drop");
	bool grappleHook = GetSpawnBool("grappleHook");
	bool grappleUnhook = GetSpawnBool("grappleUnhook");

	if (willPlant) {
		string classToPlant = GetSpawnString("def_plant");
		bool willPlantOnGround = GetSpawnBool("plantOnGround");
		float plantDistance = GetSpawnFloat("plantDistance");
		vector forwardPos = (anglesToForward(launchDir) * plantDistance);
		float plantOffset = GetSpawnFloat("plantOffset");

		/* this doesn't need to be customize right now, as testDistance in ncWeapon handles a test */
		traceline(startPos, startPos + forwardPos, MOVE_NORMAL, m_weaponOwner);
		plantedEntity = spawnClass(classToPlant, trace_endpos + (trace_plane_normal * plantOffset));
		plantedEntity.SetAngles(vectoangles(trace_plane_normal));
	} else if (willDrop) {
		string classToDrop = GetSpawnString("def_drop");
		float dropDistance = GetSpawnFloat("dropDistance");
		plantedEntity = spawnClass(classToDrop, startPos + (anglesToForward(launchDir) * dropDistance));
		plantedEntity.SetAngles([0, launchDir[1], 0]);
		plantedEntity.Spawn();
	}

	if (grappleHook) {
		if (ourOwner.m_hook != __NULL__) {
			/* play the looping reel anim once */
			/*if (ourOwner.a_ammo1 == 1) {
				ourOwner.a_ammo1 = 2;
				//Weapons_ViewAnimation(pl, BARN_FIRETRAVEL);
			} else if (ourOwner.a_ammo1 == 2) {
				ourOwner.m_hook.skin = 1;
			}*/

			forwardDir = anglesToForward(ourOwner.v_angle);
			vector src = ourOwner.GetEyePos();
			traceline(src, src + (forwardDir * 32), MOVE_NORMAL, ourOwner);

			//if (trace_ent.takedamage == DAMAGE_YES && trace_ent.iBleeds) {
			//	Damage_Apply(trace_ent, pl, 25, WEAPON_GRAPPLE, DMG_GENERIC);
			//}
			//ourOwner.m_timeUntilNextAttack = 0.5f;
			return;
		}

		forwardDir = anglesToForward(ourOwner.v_angle);
		ourOwner.m_hook = spawn();
		setorigin(ourOwner.m_hook, ourOwner.GetEyePos() + (forwardDir * 16));
		ourOwner.m_hook.owner = ourOwner;
		ourOwner.m_hook.velocity = forwardDir * 1500.0f;
		ourOwner.m_hook.movetype = MOVETYPE_FLYMISSILE;
		ourOwner.m_hook.solid = SOLID_BBOX;
		ourOwner.m_hook.angles = vectoangles(ourOwner.m_hook.velocity);
		ourOwner.m_hook.touch = Grapple_Touch;
		setsize(ourOwner.m_hook, [0,0,0], [0,0,0]);
		setmodel(ourOwner.m_hook, GetSpawnString("model"));
	} else if (grappleUnhook) {
		if (ourOwner.m_hook != __NULL__) {
			//ourOwner.a_ammo1 = 0; /* cache */
			ourOwner.m_hook.skin = 0; /* ungrappled */
			remove(ourOwner.m_hook);
			ourOwner.m_hook = __NULL__;
			ourOwner.m_pmoveHookVelocity = g_vec_null;
		}
	}

	/* free up the entity slot */
	Destroy();
}

#endif


#ifdef SERVER
ncAttack
ncAttack_SpawnDef(string entityDef, ncActor theOwner)
{
	entity oldself = self;

	ncAttack rocket = spawn(ncAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(theOwner.GetEyePos(), theOwner.GetViewAngle(), (time - theOwner.m_weaponCookingTime), 0.0f, 0.0f);
	return rocket;
}

ncAttack
ncAttack_SpawnDefAtPosition(string entityDef, ncActor theOwner, vector vecOrigin, vector vecAngles)
{
	entity oldself = self;
	ncAttack rocket = spawn(ncAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(vecOrigin, vecAngles, (time - theOwner.m_weaponCookingTime), 0.0f, 0.0f);
	ncLog("%S %v, %v", entityDef, vecOrigin, vecAngles);
	return rocket;
}

ncAttack
ncAttack_SpawnDefAttachment(string entityDef, ncActor theOwner, int attachmentID)
{
	entity oldself = self;
	float skeletonIndex = skel_create(theOwner.modelindex);
	vector attachmentPos =  gettaginfo(theOwner, skel_get_numbones(skeletonIndex) + attachmentID);
	skel_delete(skeletonIndex);
	ncAttack rocket = spawn(ncAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(attachmentPos, theOwner.GetViewAngle(), (time - theOwner.m_weaponCookingTime), 0.0f, 0.0f);
	return rocket;
}
#endif
