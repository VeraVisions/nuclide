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
SVPF_game_LoadNextMap(void)
{
	localcmd("nextmap\n");
}

void
SVPF_game_EndMap(void)
{
	ncRuleDelegate currentRule = ncRuleDelegate::ActiveInstance();
	currentRule.IntermissionStart();
}

void
SVPF_game_CleanUpMap(void)
{
	//localcmd("respawnEntities\n");

	/* user created decals (not sprays) */
	for (entity eFind = world; (eFind = find(eFind, ::classname, "tempdecal"));) {
		//ents.Input(eFind, "Destroy", "", world);
	}

	/* respawn all entities. */
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		ncEntity caw = (ncEntity)a;

		if (!(is.Player(caw))) {
			caw.Respawn();
		}
	}

	/* clear the corpses/items, you name it*/
	for (entity eFind = world; (eFind = find(eFind, ::classname, "remove_me"));) {
		if (eFind.identity) {
			ncEntity toRemove = (ncEntity)eFind;
			toRemove.Destroy();
		} else {
			remove(eFind);
		}
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CLEARDECALS);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
}

string
SVPF_game_GetMap(void)
{
	return (mapname);
}

string
SVPF_game_GetNextMap(void)
{
	return "";
}

void
SVPF_game_TeleportToSpawn(entity targetClient)
{
	Spawn_TeleportToSpawn(targetClient);
}

void
SVPF_game_SetSpawnPoint(string spawnPoint)
{
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_UNASSIGNED), spawnPoint);
}

int
SVPF_actor_GetReserveAmmo(ncActor targetActor, int ammoID)
{
	if (!targetActor) {
		return (0i);
	}

	return targetActor.GetReserveAmmo(ammoID);
}

bool
SVPF_actor_MaxAmmo(ncActor targetActor, int ammoID)
{
	/* deny anything funny */
	if (!targetActor) {
		return (true);
	}

	return targetActor.MaxAmmo(ammoID);
}

string
SVPF_actor_GetInventory(ncActor targetActor)
{
	string outputString = "";
	ncItem m_listStart = targetActor.m_itemList;

	while (m_listStart) {
		outputString = strcat(outputString, m_listStart.classname, " ");
		m_listStart = m_listStart.m_nextItem;
	}

	return (outputString);
}

bool
SVPF_actor_HasItem(ncActor targetActor, string itemName)
{
	return (targetActor.HasItem(itemName));
}

int
SVPF_actor_TotalActors(void)
{
	int actorCount = 0i;

	for (ncActor actorEnum = __NULL__; (actorEnum = (ncActor)nextent(actorEnum));) {
		if (actorEnum.flags & FL_MONSTER) {
			if (actorEnum.IsAlive() == true) {
				actorCount++;
			}
		}
	}

	return (actorCount);
}

int
SVPF_actor_TotalActorsOnTeam(int teamID)
{
	int actorCount = 0i;

	for (ncActor actorEnum = __NULL__; (actorEnum = (ncActor)nextent(actorEnum));) {
		if (actorEnum.flags & FL_MONSTER) {
			if (actorEnum.team == (float)teamID && actorEnum.IsAlive() == true) {
				actorCount++;
			}
		}
	}

	return (actorCount);
}

string
SVPF_util_TimeToString(int realTime, int zoneType, string formatString)
{
	/* supposed to take extra (optional parameters...) */
	if (zoneType == 1i) {
		return strftime(true, formatString);
	} else {
		return strftime(true, formatString);
	}
}

bool
SVPF_exists_InPVS(entity testEntity, vector testCoord)
{
	return checkpvs(testCoord, testEntity);
}

bool
SVPF_exists_InMap(string className)
{
	return find(world, ::classname, className) ? (true) : (false);
}

bool
SVPF_exists_InVFS(string fileName)
{
	return fileExists(fileName);
}

/* damage/combat */
/* helper functions */

void
SVPF_combat_Damage(entity targetEnt, entity inflictingEnt, entity attackingEnt, string damageDef, vector damageOrigin, vector damageDir, vector hitLocation)
{
	ncSurfacePropEntity theTarget;

	/* common filters */
	if (targetEnt.takedamage == DAMAGE_NO) {
		return;
	}

	if (is.GodMode(targetEnt) == true) {
		return;
	}

	theTarget = (ncSurfacePropEntity)targetEnt;

	/* don't use IsAlive(), else we can't gib */
	if (!theTarget.GetHealth()) {
		return;
	}

	ncDict findDecl = (ncDict)find(world, ::declclass, damageDef);

	if (findDecl) {
		theTarget.Damage(inflictingEnt, attackingEnt, findDecl, 1.0, damageDir, hitLocation);
		return;
	}

	ncError("Cannot find decl %S for damage info.", damageDef);
}

void
SVPF_combat_RadiusDamage(vector damageCenter, float damageRange, int damageMin, int damageMax, entity attackingEnt, string strDamageDecl)
{
	vector entPos = g_vec_null;
	float entDistance = 0.0f;
	int newDamage = 0i;
	float damageFrac = 0.0f;
	vector dmgDir = g_vec_null;

	for (ncSurfacePropEntity e = __NULL__; (e = (ncSurfacePropEntity)nextent(e));) {
		if (e.takedamage == DAMAGE_NO) {
			continue;
		}

		entPos = e.WorldSpaceCenter();

		/* don't bother if it's not anywhere near us */
		entDistance = length(damageCenter - entPos);

		if (entDistance > damageRange) {
			continue;
		}

		/* can we physically hit this thing? */
		if (damageMax > 0i) {
			if (e.CanBeDamaged(damageCenter, entPos) == false) {
				continue;
			}
		}

		/* calculate new damage values */
		damageFrac = (damageRange - entDistance) / damageRange;
		newDamage = (int)lerp(fabs((float)damageMin), (float)damageMax, damageFrac);
		dmgDir = dirFromTarget(damageCenter, entPos);

		if (e == attackingEnt) {
			newDamage *= 0.5f;
		}

		ncDict damageDecl;

		if (STRING_SET(strDamageDecl)) {
			int declID = EntityDef_IDFromName(strDamageDecl);
			damageDecl = ncDict::InitWithSpawnData(EntityDef_GetSpawnData(declID));
		} else {
			damageDecl = spawn(ncDict);
		}

		damageDecl.AddKey("damage", itos(newDamage));
		damageDecl.AddKey("location", vtos(entPos - (anglesToForward(dmgDir) * e.size[0])));
		damageDecl.AddKey("push", itos(newDamage * 100));
		e.Damage(attackingEnt, attackingEnt, damageDecl, 1.0, dmgDir, e.origin);
		remove(damageDecl);
	}
}

void
SVPF_combat_Obituary(string targetName, string attackerName, string weaponDef, string meansOfDeath)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	WriteString(MSG_MULTICAST, targetName);
	WriteString(MSG_MULTICAST, attackerName);
	WriteString(MSG_MULTICAST, weaponDef);
	WriteString(MSG_MULTICAST, meansOfDeath);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}

entity
SVPF_ents_Create(string className, vector worldPosition)
{
	return spawnClass(className, worldPosition);
}

float
SVPF_ents_ChangeToClass(entity targetEntity, string className)
{
	return changeClass(targetEntity, className);
}

void
SVPF_ents_Input(entity target, string inputName, string dataString, entity activator)
{
	sendInput(target, inputName, dataString, activator);
}

void SVPF_music_Stop(void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_STOP);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}

void SVPF_music_StopOnClient(entity targetClient)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_STOP);
	msg_entity = targetClient;
	multicast([0,0,0], MULTICAST_ONE_R);
}

void SVPF_music_Play(musictrack_t globalTrack)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_LOOP);
	WriteFloat(MSG_MULTICAST, globalTrack);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}

void SVPF_music_PlayOnce(musictrack_t globalTrack)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_ONCE);
	WriteFloat(MSG_MULTICAST, globalTrack);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}

void SVPF_music_PlayOnClient(musictrack_t globalTrack, entity targetClient)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_LOOP);
	WriteFloat(MSG_MULTICAST, globalTrack);
	msg_entity = targetClient;
	multicast([0,0,0], MULTICAST_ONE_R);
}

void SVPF_music_PlayOnceOnClient(musictrack_t globalTrack, entity targetClient)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSIC_ONCE);
	WriteFloat(MSG_MULTICAST, globalTrack);
	msg_entity = targetClient;
	multicast([0,0,0], MULTICAST_ONE_R);
}
