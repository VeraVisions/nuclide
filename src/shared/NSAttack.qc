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
NSAttack::NSAttack(void)
{
#ifdef SERVER
	m_iShots = 1i;
	m_vecSpread = [0.0, 0.0, 0.0];
	m_weaponOwner = __NULL__;
	m_flFuse = -1.0f;
#endif
}

#ifdef SERVER
void
NSAttack::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "fuse": /* fuse time in seconds */
		m_flFuse = ReadFloat(strValue);
		break;
	case "spread":
		m_vecSpread = ReadVector(strValue);
		break;
	case "spread_x":
		m_vecSpread[0] = ReadFloat(strValue);
		break;
	case "spread_y":
		m_vecSpread[1] = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSAttack::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "m_iShots", m_iShots);
	SaveVector(handle, "m_vecSpread", m_vecSpread);
	SaveFloat(handle, "m_flFuse", m_flFuse);
	SaveEntity(handle, "m_weaponOwner", m_weaponOwner);
}

void
NSAttack::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iShots":
		m_iShots = ReadInt(strValue);
		break;
	case "m_flFuse":
		m_flFuse = ReadFloat(strValue);
		break;
	case "m_vecSpread":
		m_vecSpread = ReadVector(strValue);
		break;
	case "m_weaponOwner":
		m_weaponOwner = ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
NSAttack::Spawned(void)
{
	super::Spawned();
}

void
NSAttack::SetWeaponOwner(NSWeapon weaponOwner)
{
	m_weaponOwner = weaponOwner;
}

NSWeapon
NSAttack::GetWeaponOwner(void)
{
	return (m_weaponOwner);
}

void
NSAttack::Launch(vector startPos, vector launchDir, float fuseOffset, float powerMultiplier, float dmgMultiplier)
{
	bool willPlant = GetSpawnBool("plant");

	if (willPlant) {
		string classToPlant = GetSpawnString("def_plant");
		bool willPlantOnGround = GetSpawnBool("plantOnGround");
		float plantDistance = GetSpawnFloat("plantDistance");
		vector forwardPos = (anglesToForward(launchDir) * plantDistance);
		float plantOffset = GetSpawnFloat("plantOffset");

		/* this doesn't need to be customize right now, as testDistance in NSWeapon handles a test */
		traceline(startPos, startPos + forwardPos, MOVE_NORMAL, m_weaponOwner);
		NSEntity plantedEntity = spawnClass(classToPlant, trace_endpos + (trace_plane_normal * plantOffset));
		plantedEntity.SetAngles(vectoangles(trace_plane_normal));
	}

	/* free up the entity slot */
	Destroy();
}

#endif


#ifdef SERVER
NSAttack
NSAttack_SpawnDef(string entityDef, NSActor theOwner)
{
	entity oldself = self;

	NSAttack rocket = spawn(NSAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(theOwner.GetEyePos(), theOwner.GetViewAngle(), (time - theOwner.nadeCookingTime), 0.0f, 0.0f);
	return rocket;
}

NSAttack
NSAttack_SpawnDefAtPosition(string entityDef, NSActor theOwner, vector vecOrigin, vector vecAngles)
{
	entity oldself = self;
	NSAttack rocket = spawn(NSAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(vecOrigin, vecAngles, (time - theOwner.nadeCookingTime), 0.0f, 0.0f);
	return rocket;
}

NSAttack
NSAttack_SpawnDefAttachment(string entityDef, NSActor theOwner, int attachmentID)
{
	entity oldself = self;
	float skeletonIndex = skel_create(theOwner.modelindex);
	vector attachmentPos =  gettaginfo(theOwner, skel_get_numbones(skeletonIndex) + attachmentID);
	skel_delete(skeletonIndex);
	NSAttack rocket = spawn(NSAttack);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(attachmentPos, theOwner.GetViewAngle(), (time - theOwner.nadeCookingTime), 0.0f, 0.0f);
	return rocket;
}
#endif
