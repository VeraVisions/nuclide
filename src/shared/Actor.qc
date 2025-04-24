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
ncActor::ncActor(void)
{
#ifdef SERVER
	m_activeSchedule = __NULL__;
	m_pathfindingNodeCount = 0i;
	m_pathfindingCurrentNode = -1i;
	m_pathfindingGraph = __NULL__;
	m_pathfindingDestination = [0,0,0];
	m_moveSpeedKey = 0.0f;
	m_pathTarget = "";
	m_pathEntity = __NULL__;
	m_timeUntilDroppingRoute = 0.0f;
#endif

	m_itemList = __NULL__;

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		m_ammoTypes[i] = 0i;
	}
}

void
ncActor::ReloadCachedAttributes(void)
{
	m_sndStepLadderLeft = GetSpawnString("snd_stepladderLeft");

	if (STRING_SET(m_sndStepLadderLeft)) {
		m_sndStepLadderRight = GetSpawnString("snd_stepladderRight");
	} else {
		m_sndStepLadderLeft =
		m_sndStepLadderRight = GetSpawnString("snd_stepladder");
	}

	m_sndDeath = GetSpawnString("snd_death");
	m_sndFall = GetSpawnString("snd_fall");
	m_sndPainSmall = GetSpawnString("snd_painSmall");

	if (STRING_SET(m_sndPainSmall)) {
		m_sndPainMedium = GetSpawnString("snd_painMedium");
		m_sndPainLarge = GetSpawnString("snd_painLarge");
		m_sndPainHuge = GetSpawnString("snd_painHuge");
	} else {
		m_sndPainSmall =
		m_sndStepLadderRight =
		m_sndPainMedium =
		m_sndPainLarge =
		m_sndPainHuge = GetSpawnString("snd_pain");
	}

	m_sndLandSoft = GetSpawnString("snd_landSoft");

	if (STRING_SET(m_sndLandSoft)) {
		m_sndLandHard = GetSpawnString("snd_landHard");
	} else {
		m_sndLandSoft =
		m_sndLandHard = GetSpawnString("snd_land");
	}

	m_sndHitArmor = GetSpawnString("snd_hitArmor");

	if (STRING_SET(m_sndHitArmor)) {
		m_sndHitFlesh = GetSpawnString("snd_hitFlesh");
	} else {
		m_sndHitArmor =
		m_sndHitFlesh = GetSpawnString("snd_hit");
	}

	m_sndAirGaspHeavy = GetSpawnString("snd_airGaspHeavy");

	if (STRING_SET(m_sndAirGaspHeavy)) {
		m_sndAirGaspLight = GetSpawnString("snd_airGaspLight");
	} else {
		m_sndAirGaspHeavy =
		m_sndAirGaspLight = GetSpawnString("snd_airGasp");
	}

	m_sndNoAir = GetSpawnString("snd_noAir");
	m_sndTeleportExit = GetSpawnString("snd_teleportExit");
	m_sndTeleportStart = GetSpawnString("snd_teleportStart");
	m_sndWaterExit = GetSpawnString("snd_waterExit");
	m_sndWaterEnter = GetSpawnString("snd_waterStart");
	m_sndWaterWade = GetSpawnString("snd_waterWade");
	m_sndWaterSwim = GetSpawnString("snd_waterSwim");
	m_sndBurn = GetSpawnString("snd_stepladderLeft");
	m_sndHealthtake = GetSpawnString("snd_stepladderLeft");
	m_sndUseDeny = GetSpawnString("snd_useDeny");

	if (STRING_SET(m_sndUseDeny)) {
		m_sndUseSuccess = GetSpawnString("snd_useSuccess");
	} else {
		m_sndUseDeny =
		m_sndUseSuccess = GetSpawnString("snd_use");
	}
}

void
ncActor::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
	}
}

float
ncActor::GetStamina(void)
{
	return (m_currentStamina / g_pmoveVars.pm_stamina);
}

bool
ncActor::IsCrouching(void)
{
	return HasVFlags(VFL_CROUCHING);
}

bool
ncActor::IsProne(void)
{
	return HasVFlags(VFL_PRONE);
}

bool
ncActor::IsStanding(void)
{
	return !HasVFlags(VFL_PRONE | VFL_CROUCHING | VFL_SPRINTING);
}

bool
ncActor::IsSprinting(void)
{
	return HasVFlags(VFL_SPRINTING);
}

bool
ncActor::IsLeaning(void)
{
	return (false);
}

bool
ncActor::CanSprint(void)
{
	return (false);
}

bool
ncActor::CanProne(void)
{
	return (false);
}

bool
ncActor::CanLean(void)
{
	return (false);
}

bool
ncActor::CanCrouch(void)
{
	return (false);
}

/* filled these in with the (default) client side player movement values */
float
ncActor::GetForwardSpeed(void)
{
	return (PMOVE_FORWARD_SPEED);
}

float
ncActor::GetSideSpeed(void)
{
	return (PMOVE_SIDE_SPEED);
}

float
ncActor::GetBackSpeed(void)
{
	return (PMOVE_BACK_SPEED);
}

#ifdef SERVER
void
ncActor::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "bonusHealth", m_bonusHealth);
	SaveFloat(handle, "timeUntilBonusHealthDecreases", m_timeUntilBonusHealthDecreases);
	SaveFloat(handle, "maxspeed", maxspeed);
	SaveVector(handle, "pmoveBaseVelocity", m_pmoveBaseVelocity);
	SaveEntity(handle, "groundentity", groundentity);

	SaveInt(handle, "pathfindingNodeCount", m_pathfindingNodeCount);
	SaveInt(handle, "pathfindingCurrentNode", m_pathfindingCurrentNode);
	SaveVector(handle, "pathfindingDestination", m_pathfindingDestination);
	SaveFloat(handle, "moveSpeedKey", m_moveSpeedKey);

	SaveString(handle, "pathTarget", m_pathTarget);
	SaveEntity(handle, "pathEntity", m_pathEntity);
	SaveFloat(handle, "timeUntilDroppingRoute", m_timeUntilDroppingRoute);
	SaveVector(handle, "pathfindingLastPos", m_pathfindingLastPos);
	SaveEntity(handle, "followingEntity", m_followingEntity);
	SaveString(handle, "mindset", m_mindset);
	SaveFloat(handle, "weaponCookingTime", m_weaponCookingTime);
	SaveFloat(handle, "activeweapon", activeweapon);
	SaveFloat(handle, "itemStart", m_itemStart);
	SaveFloat(handle, "currentStamina", m_currentStamina);
	SaveEntity(handle, "itemList", m_itemList);
	SaveEntity(handle, "activeWeapon", m_activeWeapon);
	SaveEntity(handle, "firstWeapon", m_firstWeapon);
	SaveBool(handle, "_isActor", _isActor);

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		SaveInt(handle, sprintf("ammoTypes_%i", i), m_ammoTypes[i]);
	}
}

void
ncActor::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "bonusHealth":
		m_bonusHealth = ReadFloat(setValue);
		break;
	case "timeUntilBonusHealthDecreases":
		m_timeUntilBonusHealthDecreases = ReadFloat(setValue);
		break;
	case "maxspeed":
		maxspeed = ReadFloat(setValue);
		break;
	case "pmoveBaseVelocity":
		m_pmoveBaseVelocity = ReadVector(setValue);
		break;
	case "groundentity":
		groundentity = ReadEntity(setValue);
		break;
	case "pathfindingNodeCount":
		m_pathfindingNodeCount = ReadInt(setValue);
		break;
	case "pathfindingCurrentNode":
		m_pathfindingCurrentNode = ReadInt(setValue);
		break;
	case "pathfindingDestination":
		m_pathfindingDestination = ReadVector(setValue);
		break;
	case "moveSpeedKey":
		m_moveSpeedKey = ReadFloat(setValue);
		break;
	case "_isActor":
		_isActor = ReadBool(setValue);
		break;
	case "activeWeapon":
		m_activeWeapon = (ncWeapon)ReadEntity(setValue);
		break;
	case "followingEntity":
		m_followingEntity = ReadEntity(setValue);
		break;
	case "firstWeapon":
		m_firstWeapon = (ncWeapon)ReadEntity(setValue);
		break;
	case "itemList":
		m_itemList = (ncItem)ReadEntity(setValue);
		break;
	case "pathEntity":
		m_pathEntity = (ncEntity)ReadEntity(setValue);
		break;
	case "timeUntilDroppingRoute":
		m_timeUntilDroppingRoute = ReadFloat(setValue);
		break;
	case "activeweapon":
		activeweapon = ReadFloat(setValue);
		break;
	case "itemStart":
		m_itemStart = ReadFloat(setValue);
		break;
	case "currentStamina":
		m_currentStamina = ReadFloat(setValue);
		break;
	case"weaponCookingTime":
		m_weaponCookingTime = ReadFloat(setValue);
		break;
	case "mindset":
		m_mindset = ReadString(setValue);
		break;
	case "pathTarget":
		m_pathTarget = ReadString(setValue);
		break;
	case "pathfindingLastPos":
		m_pathfindingLastPos = ReadVector(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
ncActor::Spawned(void)
{
	super::Spawned();
	_isActor = true;

	/* let's not waste time and resources */
	if (wasfreed(this)) {
		return;
	}

	/* start ammo */
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		string defKey = ammoNameForNum(i);

		if (defKey != "") {
			int defValue = GetDefInt(defKey);
			if (defValue > 0i) {
				EntLog("Giving %S some %i units of %S", classname, defValue, defKey);
				GiveAmmo(i, defValue);
			}
		}
	}

	/* give them their inventory */
	string weaponList = GetDefString("weapon");
	string itemList = GetDefString("item");
	int desiredWeapon = GetDefInt("current_weapon");
	string switchTo = "";
	float weaponCount = 0;

	string desiredTeam = GetSpawnString("team");

	if (STRING_SET(desiredTeam)) {
		float teamNum = stof(desiredTeam);

		/* not set */
		if (teamNum == 0) {
			SetTeam(TEAM_UNASSIGNED);
		} else {
			SetTeam(teamNum);
		}
	}

	/* append items to the end */
	if (STRING_SET(itemList)) {
		weaponList = sprintf("%s,%s", weaponList, itemList);
	}

	for (float i = 0; i < tokenizebyseparator(weaponList, ","); i++) {
		string itemName = argv(i);
		GiveItem(itemName);

		if (i == desiredWeapon) {
			switchTo = itemName;
		}
	}

	if (STRING_SET(switchTo)) {
		SwitchToWeapon(switchTo);
	}

	/* give them their desired appearance */
	string spawnModel = GetSpawnString("model");

	if (STRING_SET(spawnModel)) {
		SetModel(spawnModel);
	}
}

void
ncActor::RestoreComplete(void)
{
	SendFlags = -1;

	if (m_pathfindingNodeCount <= 0i) {
		return;
	}

	/* re-plot our route */
	RouteToPosition(m_pathfindingDestination);
}

void
ncActor::ThinkSchedules(void)
{
	if (IsPerforming() == false && m_pathfindingNodeCount <= 0i) {
		SelectNewSchedule();
	}
}

void
ncActor::SelectNewSchedule(void)
{
	string schedule;
	string currentMindset = "idle";

	if (STRING_SET(m_mindset)) {
		currentMindset = m_mindset;
	}

	schedule = GetDefString(strcat("mindset_", currentMindset));

	if (STRING_SET(schedule)) {
		PerformSchedule(schedule);
	}
}

bool
ncActor::IsPerforming(void)
{
	return (m_activeSchedule) ? (true) : (false);
}

bool
ncActor::CancelSchedule(void)
{
	if (m_activeSchedule) {
		m_activeSchedule.ReleaseThink();
		m_activeSchedule.Cancel();
		return (true);
	}

	return (false);
}

void
ncActor::MessageSchedule(string messageString)
{
	if (m_activeSchedule) {
		m_activeSchedule.Message(messageString);
	}
}


void
ncActor::PerformSchedule(string scheduleDecl)
{
	float scheduleCount = tokenizebyseparator(scheduleDecl, ",");

	if (scheduleCount > 1i) {
		scheduleDecl = argv(floor(random(0, scheduleCount)));
	}

	CancelSchedule();
	ncSchedule::CreateSchedule(this, scheduleDecl);
}

int
ncActor::PathNodeCount(void)
{
	return (m_pathfindingNodeCount);
}

int
ncActor::PathCurrentNode(void)
{
	return (m_pathfindingCurrentNode);
}

vector
ncActor::PathDestination(void)
{
	return (m_pathfindingDestination);
}

void
ncActor::MakeCorpse(float deathSequence)
{
	bool makeRagdoll = GetSpawnBool("ragdoll");
	ncEntity newCorpse;

	if (FORCE_RAGDOLLS) {
		makeRagdoll = true;
	}

	if (makeRagdoll) {
		 newCorpse = (ncEntity)BodyQue_SpawnRagdoll(this, deathSequence);
	} else {
		 newCorpse = (ncEntity)BodyQue_Spawn(this, deathSequence);

		/* if we were crouching, adjust the bbox (thx 2 lack of crouch death animation) */
		if (IsCrouching()) {
			newCorpse.SetSize(VEC_HULL_MIN, [16, 16, -16]);
		}
	}
}

void
ncActor::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "UseItem":
		if (HasItem(strData)) {
			ncItem linkedList;

			linkedList = m_itemList;

			while (linkedList) {
				if (!STRING_SET(linkedList.declclass)) {
					linkedList = __NULL__;
					break;
				}

				/* inventory item may not be a weapon */
				if (linkedList.declclass == strData) {
					linkedList.OnUse(eAct);
					break;
				}
				linkedList = (ncItem)linkedList.m_nextItem;
			}
		}
		break;
	case "GiveItem":
		GiveItem(strData);
		break;
	case "GiveAmmo":
		tokenize_console(strData);
		int ammoNum = ammoNumForName(argv(0));
		int ammoCount = stoi(argv(1));

		if (ammoNum != -1i) {
			GiveAmmo(ammoNum, ammoCount);
		}
		break;
	/* schedule management */
	case "ActorThinks":
		printf("%S (%d): %s\n", classname, num_for_edict(this), strData);
		break;
	case "ChangeMindset":
		m_mindset = strData;
		break;
	case "PerformSchedule":
		PerformSchedule(strData);
		break;
	case "SelectNewSchedule":
		SelectNewSchedule();
		break;
	/* some tasks. */
	case "WalkToTarget":
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		m_activeSchedule.AdvanceLater(100);
		break;
	case "RunToTarget":
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		m_activeSchedule.AdvanceLater(100);
		break;
	case "CrouchToTarget":
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		m_activeSchedule.AdvanceLater(100);
		break;
	case "ProneToTarget":
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		m_activeSchedule.AdvanceLater(100);
		break;
	case "TargetNearestPlayer":
		ncEntity firstPlayer = (ncEntity)next.Player(world);

		if (firstPlayer) {
			m_activeSchedule.SetTarget(firstPlayer);
		} else {
			CancelSchedule();
		}
// 		ncWarning("Task %S unimplemented", strInput);
		break;
	case "GoToCover":
		vector coverPos = ncNavInfo::FindCoverFromPosition(this, GetOrigin());

		if (vlen(coverPos) > 0.0f) {
			RouteToPosition(coverPos);
		} else {
			CancelSchedule();
		}
		break;
	case "GoToSpotInRadius":
		vector spot1 = ncNavInfo::FindEmptySpotNearPosition(this, GetOrigin(), 128.0f, stof(strData));

		if (vlen(spot1) > 0.0f) {
			RouteToPosition(spot1);
		} else {
			CancelSchedule();
		}
		break;
	case "AvoidSpotInRadius":
		vector t = ncNavInfo::FindEmptySpotAwayFromPosition(this, GetOrigin(), 0.0f, stof(strData));

		if (vlen(t) > 0.0f) {
			RouteToPosition(t);
		} else {
			CancelSchedule();
		}
		break;
	case "TurnToRandomYaw":
		float randomYaw = random(45.0f,180.0f) - 90.0f;
		angles[1] += randomYaw;
		v_angle = angles;
		break;
	case "GoForward":
		RouteToPosition(GetOrigin() + (anglesToForward(angles) * 1024.0f));
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
#endif


#ifdef SERVER
void
ncActor::RouteEnded(void)
{
	ClearVelocity();
}

void
ncActor::CheckRouteProgression_Path(void)
{
	float flDist = distance(m_pathEntity.GetOrigin(), GetOrigin());

	//print(sprintf("Check Path! %f\n", flDist));

	/* close enough...? */
	if (flDist < 80) {

		if (STRING_SET(targetname)) {
			ncActor_Log("%S reached path node %S", targetname, m_pathTarget);
		} else {
			ncActor_Log("Reached path node %S", m_pathTarget);
		}

		m_pathTarget = m_pathEntity.target;
		m_pathEntity = (ncEntity)m_pathEntity.GetTargetEntity();
		velocity = [0,0,0]; /* clamp friction */
	}
}

void
ncActor::CheckRouteProgression(void)
{
	float flDist;
	float flNodeRadius;
	vector evenpos;

	/* if we're targetting ourselves, we act like a turret */
	if (STRING_SET(targetname) && STRING_SET(m_pathTarget)) {
		if (m_pathTarget == targetname) {
			return;
		}
	}

	if (STRING_SET(m_pathTarget) && m_pathEntity) {
		CheckRouteProgression_Path();
		return;
	}

	if (!m_pathfindingNodeCount) {
		return;
	}

	if (m_timeUntilDroppingRoute < time) {
		float distanceToLastFrame = distanceSquared(m_pathfindingLastPos, origin);
		//printf("distanceToLastFrame: %f\n", distanceToLastFrame);

		/* 50 units in 2 seconds is not good. */
		if (distanceToLastFrame < 50.0f) {
			/* HACK: for followers */
			if (m_followingEntity) {
				RouteToPosition(m_followingEntity.origin);
				ncActor_Log("Giving up current route to follower, re-calculating");
			} else {
				RouteClear();
			}
		}
		m_timeUntilDroppingRoute = time + 2.0f;
		m_pathfindingLastPos = origin;
	}

	/* level out position/node stuff */
	if (m_pathfindingCurrentNode < 0) {
		evenpos = m_pathfindingDestination;
		evenpos[2] = origin[2];
		flNodeRadius = 8.0f;
	} else {
		evenpos = m_pathfindingGraph[m_pathfindingCurrentNode].dest;
		evenpos[2] = origin[2];
		flNodeRadius = m_pathfindingGraph[m_pathfindingCurrentNode].radius;

		if (flNodeRadius <= 0.0)
			flNodeRadius = 16.0f;
	}

	vector wishAngles = vectoangles(evenpos - origin);
	ideal_yaw = wishAngles[1];

	flDist = floor(vlen(evenpos - origin));

	if (flDist < flNodeRadius) {
		//ncActor_Log("%S reached node", targetname);
		m_pathfindingCurrentNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_pathfindingCurrentNode > -1) {
			tracebox(origin, mins, maxs, m_pathfindingDestination, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				vector idealAngles = vectoangles(m_pathfindingDestination - origin);
				ncActor_Log("Walking directly to last node at '%v'", m_pathfindingDestination);
				ideal_yaw = idealAngles[1];
				m_pathfindingCurrentNode = -1;
			}
		}
	}

#if 1
	/* check if we can reach the node after the current one */
	if (m_pathfindingCurrentNode > 0 && m_pathfindingNodeCount > 3) { /* HACK: only bother when we have more than 3 nodes in the path... this works around an issue in c1a0d I'm unsure about */
		int iNextNode = (m_pathfindingCurrentNode - 1);
		vector vecNextNode = m_pathfindingGraph[iNextNode].dest;

		other = world;
		tracebox(origin, mins, maxs, vecNextNode, MOVE_OTHERONLY, this);

		/* it's accessible */
		if (!trace_startsolid && trace_fraction == 1.0f) {
			idealAngles = vectoangles(vecNextNode - origin);
			evenpos = vecNextNode;
			m_pathfindingCurrentNode = iNextNode;

			ideal_yaw = idealAngles[1];
			ncActor_Log("Skipping to next node %i at '%v'", iNextNode, vecNextNode);
			return;
		}
	}
#endif

	/* reached the end of the line */
	if (m_pathfindingCurrentNode < -1) {
		RouteClear();
		RouteEnded();
		ncActor_Log("%S reached end", targetname);
	}

	/* crouch attempt */
	if (CanCrouch()) {
		vector src;
		bool shouldcrouch = false;

		/* test up */
		src = origin + [0,0,24];
		makevectors(angles);
		traceline(src, src + anglesToForward(angles) * 128, MOVE_NORMAL, this);

		/* we hit something */
		if (trace_fraction < 1.0) {
			src = origin + [0,0, -8];
			traceline(src, src + anglesToForward(angles) * 128, MOVE_NORMAL, this);

			/* we can crouch here, so let's do it */
			if (trace_fraction >= 1.0)
				shouldcrouch = true;
		}

		/* entire way-link needs to be crouched. that's the law of the land */
		if (shouldcrouch || Route_GetNodeFlags(&m_pathfindingGraph[m_pathfindingCurrentNode]) & LF_CROUCH)
			input_buttons |= INPUT_CROUCH;
	}

	/*if (flDist == m_flLastDist) {
		m_flNodeGiveup += frametime;
	} else {
		m_flNodeGiveup = bound(0, m_flNodeGiveup - frametime, 1.0);
	}

	m_flLastDist = flDist;

	if (m_flNodeGiveup >= 1.0f) {
		print(sprintf("ncActor::CheckNode: %s gave up route\n",
			this.netname));
		RouteClear();
	}*/
}

vector
ncActor::GetRouteMovevalues(void)
{
	vector vecDirection;
	vector facingPos;
	vector fwdDir, rightDir, upDir;
	vector outputMovement;

	fwdDir = anglesToForward(input_angles);
	rightDir = anglesToRight(input_angles);
	upDir = anglesToUp(input_angles);

	if (STRING_SET(m_pathTarget)) {
		facingPos = m_pathEntity.GetOrigin();
	} else if (m_pathfindingNodeCount) {
		if (m_pathfindingCurrentNode < 0)
			facingPos = m_pathfindingDestination;
		else
			facingPos = m_pathfindingGraph[m_pathfindingCurrentNode].dest;
	} else {
		facingPos = GetOrigin() + (fwdDir * 16.0f);
	}

	if (movetype == MOVETYPE_FLY) {
		float offset = GetSpawnFloat("fly_offset");
		facingPos += [0,0, offset];
	}

	vecDirection = vectorNormalize(facingPos - GetOrigin());

	outputMovement = fwdDir * vecDirection[0];
	outputMovement += rightDir * vecDirection[1];
	outputMovement += upDir * vecDirection[2];

	return outputMovement;
}

vector
ncActor::GetRouteDirection(void)
{
	vector direction;
	vector facingPos = g_vec_null;

	/* towards target */
	if (STRING_SET(m_pathTarget)) {
		facingPos = m_pathEntity.GetOrigin();
	} else {
		if (m_pathfindingNodeCount <= 0i) {
			/* keep going */
			return (angles);
		}else if (m_pathfindingCurrentNode < 0) {
			/* aim at the last node */
			facingPos = m_pathfindingDestination;
		} else {
			/* aim at the next node */
			facingPos = m_pathfindingGraph[m_pathfindingCurrentNode].dest;
		}
	}

	if (movetype == MOVETYPE_FLY) {
		float offset = GetSpawnFloat("fly_offset");
		facingPos += [0,0, offset];
	}

	direction = vectorToAngles(facingPos - GetOrigin());
	return (direction);
}

void
ncActor::RouteToPosition(vector destination)
{
	RouteToPositionDenyFlags(destination, 0i);
}

void
ncActor::DebugDraw(void)
{
	vector vecStart = GetOrigin();
	vector vecEnd;
	vector beamColor = [1,1,1];
	float frac = 1.0 / m_pathfindingNodeCount;

	for (int i = m_pathfindingCurrentNode; i < m_pathfindingNodeCount; i++) {
		if (m_pathfindingCurrentNode < 0)
			continue;

		vecEnd = m_pathfindingGraph[i].dest;
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(vecStart, [1,1], beamColor, 1);
		R_PolygonVertex(vecEnd, [0,1], beamColor, 1);
		R_EndPolygon();
		vecStart = vecEnd;
		beamColor[0] -= frac;
		beamColor[1] -= frac;
		beamColor[2] -= frac;
	}
}

void
ncActor::RouteToPositionDenyFlags(vector destination, int denylinkflags)
{
	/* engine calls this upon successfully creating a route */
	static void RouteToPosition_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		ncActor p = (ncActor)ent;

		if (numnodes < 1i) {
			ncActor_Log("No path available.");
		}

		{
			p.m_pathfindingNodeCount = numnodes;
			p.m_pathfindingCurrentNode = numnodes - 1;
			p.m_pathfindingGraph = nodelist;
			p.m_timeUntilDroppingRoute = time + 4.0f;
		}

		//traceline(p.origin, dest, MOVE_NORMAL, this);
		tracebox(p.origin, p.mins, p.maxs, dest, MOVE_NORMAL, p);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			ncActor_Log("Walking directly to last node");
			p.m_pathfindingNodeCount = 1;
			p.m_pathfindingCurrentNode = -1;
			p.m_timeUntilDroppingRoute = time + 5.0f;
		} else if (numnodes > 0i) {
			ncActor_Log("Path obstructed, calculating route");

			/* run through all nodes, mark the closest direct path possible */
			for (int i = 0; i < p.m_pathfindingNodeCount; i++) {
				vector vecDest = p.m_pathfindingGraph[i].dest;
				tracebox(p.origin, p.mins, p.maxs, vecDest, TRUE, p);
				//traceline(p.origin, vecDest, MOVE_NORMAL, this);

				if (trace_fraction == 1.0) {
					ncActor_Log("Walking to node %i at %v", i, p.m_pathfindingGraph[i].dest);
					p.m_pathfindingCurrentNode = i;
					break;
				}
			}

		}
	}

	if (!Nodes_Available()) {
		Nodes_Init();
		return;
	}

	/* still nothing... give up */
	if (!Nodes_Available()) {
		return;
	}

	RouteClear();
	this.origin[2] += 16.0f;
	route_calculate(this, destination, denylinkflags, RouteToPosition_RouteCB);
	this.origin[2] -= 16.0f;
	m_pathfindingDestination = destination;
}

void
ncActor::ChasePath(string startPath)
{
	if (!STRING_SET(startPath)) {
		m_pathTarget = __NULL__;
		m_pathEntity = __NULL__;
		return;
	}

	m_pathTarget = startPath;
	m_pathEntity = (ncEntity)find(world, ::targetname, m_pathTarget);
	ncActor_Log("Actor %S chase Path set to %S", netname, m_pathEntity.targetname);
}

void
ncActor::RouteClear(void)
{
	if (!m_pathfindingNodeCount) {
		return;
	}

	m_pathfindingCurrentNode = BOTROUTE_END;
	m_pathfindingNodeCount = 0;
	memfree(m_pathfindingGraph);
	ncActor_Log("Actor %S (%s) cleared their route.", netname, classname);
}

void
ncActor::SetMoveSpeedScale(float newValue)
{
	m_moveSpeedKey = newValue;
}

float
ncActor::GetMoveSpeedScale(void)
{
	return (m_moveSpeedKey == 0.0) ? 1.0f : m_moveSpeedKey;
}

void
ncActor::Physics_Run(void)
{
	input_movevalues *= GetMoveSpeedScale();

	if (CanCrouch()) {
		PMoveCustom_RunCrouchPhysics(this);
	} else {
		PMoveCustom_RunPlayerPhysics(this);
	}

	SetOrigin(origin);
}

#endif

void
ncActor::LaunchProjectile(string defName, bool thrown, float timeOfs)
{
#ifdef SERVER
	vector throwDirection;
	float throwingStrength;

	ncProjectile nade = (ncProjectile)EntityDef_CreateClassname(defName);
	nade.SetOwner(this);

	throwDirection = v_angle;
	throwDirection[0] = -10.0f; /* always aim a bit up */

	/* diminish when aiming up */
	if (v_angle[0] < 0) {
		throwDirection[0] += (v_angle[0] * 0.9f);
	} else { /* increase when aiming down */
		throwDirection[0] += (v_angle[0] * 1.1f);
	}

	throwingStrength = bound(0, (90 - throwDirection[0]) * 5.0f, 1000);

	nade.SetWeaponOwner(m_activeWeapon);
	nade.Launch(GetEyePos(), GetViewAngle(), time - timeOfs, 0.0f, 0.0f);
	nade.SetVelocity((anglesToForward(throwDirection) * throwingStrength) + GetVelocity());
#endif
}

bool
ncActor::PlantCharge(string defName)
{
	vector forwardVec;
	vector destinationVec;

	if (!defName) {
		return (false);
	}

	forwardVec = anglesToForward(v_angle) * 64;
	destinationVec = g_vec_null;

	traceline(GetEyePos(), GetEyePos() + forwardVec, MOVE_NORMAL, this);

	/* trace failed */
	if (trace_fraction >= 1.0f) {
		return (false);
	}

	destinationVec = trace_endpos;

#ifdef SERVER
	ncEntity plantedEntity;
	plantedEntity = spawnClass(defName, destinationVec);

	if (!plantedEntity) {
		EntError("Failed to plant %S", defName);
	}
	plantedEntity.SetOwner(this);
	plantedEntity.real_owner = this;

	EntLog("Planted %S at %v\n", plantedEntity.declclass, origin);
#endif

	/* push us outta the way! */
	SetOriginUnstick(GetOrigin());

	return (true);
}

int
ncActor::GetReserveAmmo(int ammoType)
{
	/* bounds check */
	if (ammoType <= 0i || ammoType >= MAX_AMMO_TYPES) {
		return (0i);
	}

	return (m_ammoTypes[ammoType]);
}

bool
ncActor::MaxAmmo(int ammoType)
{
	int maxAmmo = 0i;

	/* bounds check */
	if (ammoType <= 0i || ammoType >= MAX_AMMO_TYPES) {
		return (true);
	}

	/* read max ammo from entityDef decl first */
	maxAmmo = GetDefInt(sprintf("max_%s", ammoNameForNum(ammoType)));

	/* default when above is 0 */
	if (!maxAmmo) {
		maxAmmo = ammoMaxForNum(ammoType);
	}

	/* already at max-ammo? */
	if (m_ammoTypes[ammoType] >= maxAmmo) {
		return (true);
	}

	return (false);
}

bool
ncActor::GiveAmmo(int ammoType, int ammoAmount)
{
	int maxAmmo = 0i;

	/* bounds check */
	if (MaxAmmo(ammoType) == true) {
		return (false);
	}

	/* read max ammo from entityDef decl first */
	maxAmmo = GetDefInt(sprintf("max_%s", ammoNameForNum(ammoType)));

	/* default when above is 0 */
	if (!maxAmmo) {
		maxAmmo = ammoMaxForNum(ammoType);
	}

	m_ammoTypes[ammoType] += ammoAmount;

	if (m_ammoTypes[ammoType] >= maxAmmo) {
		m_ammoTypes[ammoType] = maxAmmo;
	}

	return (true);
}

bool
ncActor::UseAmmo(int ammoType, int ammoAmount)
{
	if (autocvar_g_infiniteAmmo == true) {
		return (true);
	}

	/* bounds check */
	if (HasAmmo(ammoType, ammoAmount) == false) {
		return (false);
	}

	m_ammoTypes[ammoType] -= ammoAmount;
	return (true);
}

bool
ncActor::HasAmmo(int ammoType, int ammoAmount)
{
	/* bounds check */
	if (ammoType < 0i || ammoType >= MAX_AMMO_TYPES) {
		return (false);
	}

	/* will underflow when used. */
	if ((m_ammoTypes[ammoType] - ammoAmount) < 0i) {
		return (false);
	}

	return (true);
}

bool
ncActor::HasExactItem(ncItem itemEntity)
{
	ncItem linkedList = __NULL__;

	/* sanity check */
	if (!itemEntity) {
		return (false);
	}

	/* we do not have an item. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* we already have the item. */
		if (linkedList == itemEntity) {
			return (true);
		}

		linkedList = (ncItem)linkedList.m_nextItem;
	}

	return (false);
}

ncItem
ncActor::GetItem(string itemName)
{
	ncItem linkedList = __NULL__;

	/* we do not have an item. */
	if (!m_itemList) {
		return (__NULL__);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* we already have the item. */
		if (linkedList.declclass == itemName) {
			return (linkedList);
		}

		linkedList = (ncItem)linkedList.m_nextItem;
	}

	return (__NULL__);
}

bool
ncActor::HasItem(string itemName)
{
	return (GetItem(itemName) == __NULL__) ? (false) : (true);
}

void
ncActor::AddedItemCallback(ncItem itemAdded)
{
#ifdef SERVER
	if (!m_activeWeapon) {
		if (itemAdded.IsWeapon()) {
			SwitchToExactWeapon((ncWeapon)itemAdded);
		}
	}
#endif
}

bool
ncActor::GiveExactItem(ncItem theItem)
{
#ifdef SERVER
	ncItem linkedList = __NULL__;
	ncItem lastItem = __NULL__;

	bool canCarry = stof(EntityDef_GetKeyValue(theItem.declclass, "inv_carry")) ? true : false;

	/* we do not have an item yet. */
	if (!m_itemList) {
		m_itemList = theItem;

		if (m_itemList == world) {
			EntError("Unable to give item %S", theItem.declclass);
			return (false);
		}

		m_itemList.SetOwner(this);
		m_itemList._AddedCallback();
		//ncLog("First Item %S", m_itemList.declclass);

		return (true);
	}

	/* since we have something in the inventory, start there */
	linkedList = (ncWeapon)m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* we already have the item. */
		if (linkedList.declclass == theItem.declclass) {
			//ncLog("we already have", linkedList.declclass);
			return (false);
		}

		lastItem = linkedList;
		linkedList = (ncItem)linkedList.m_nextItem;
	}

	/* add it to the back of the chain, so it's part of our inventory. */
	if (lastItem && linkedList == __NULL__) {
		ncItem newItem = theItem;

		if (!newItem) {
			EntError("Unable to give item %S", theItem.declclass);
			return (false);
		}

		newItem.SetOwner(this);
		lastItem.m_nextItem = newItem;
		linkedList = newItem;
		newItem._AddedCallback();
	}

	if (!m_activeWeapon) {
		SwitchToBestWeapon(false);
	}

	/* items (not weapons) may not be added permanently by default */
	if (canCarry == false && linkedList.IsWeapon() == false) {
		RemoveItem(theItem.declclass);
	}

	return (true);
#else
	return (false);
#endif
}

bool
ncActor::GiveItem(string itemName)
{
#ifdef SERVER
	ncItem linkedList = __NULL__;
	ncItem lastItem = __NULL__;

	bool canCarry = stof(EntityDef_GetKeyValue(itemName, "inv_carry")) ? true : false;

	/* we do not have an item yet. */
	if (!m_itemList) {
		m_itemList = (ncItem)EntityDef_CreateClassname(itemName);

		if (m_itemList == world) {
			EntError("Unable to give item %S", itemName);
			return (false);
		}

		m_itemList.SetOwner(this);
		m_itemList._AddedCallback();
		//ncLog("First Item %S", m_itemList.declclass);

		return (true);
	}

	/* since we have something in the inventory, start there */
	linkedList = (ncWeapon)m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* we already have the item. */
		if (linkedList.declclass == itemName) {
			//ncLog("we already have", linkedList.declclass);
			return (false);
		}

		lastItem = linkedList;
		linkedList = (ncItem)linkedList.m_nextItem;
	}

	/* add it to the back of the chain, so it's part of our inventory. */
	if (lastItem && linkedList == __NULL__) {
		ncItem newItem = (ncItem)EntityDef_CreateClassname(itemName);

		if (!newItem) {
			EntError("Unable to give item %S", itemName);
			return (false);
		}

		newItem.SetOwner(this);
		lastItem.m_nextItem = newItem;
		linkedList = newItem;
		newItem._AddedCallback();
	}

	if (!m_activeWeapon) {
		SwitchToBestWeapon(false);
	}

	/* items (not weapons) may not be added permanently by default */
	if (canCarry == false && linkedList.IsWeapon() == false) {
		RemoveItem(itemName);
	}

	return (true);
#else
	return (false);
#endif
}

void
ncActor::SwitchToBestWeapon(bool ignoreActive)
{
	string toIgnore = __NULL__;
	ncItem linkedList = __NULL__;
	ncItem bestWeapon = __NULL__;
	float bestWeight = 0.0f;

	if (ignoreActive && m_activeWeapon) {
		toIgnore = m_activeWeapon.declclass;
	}

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return;
	}

	/* iterate over all the inventory items */
	linkedList = m_itemList;

	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* inventory item may not be a weapon */
		if (linkedList.IsWeapon()) {
			string weaponName = linkedList.declclass;
			float weight;

			if (toIgnore == weaponName) {
				linkedList = (ncItem)linkedList.m_nextItem;
				continue;
			}

			weight = stof(EntityDef_GetKeyValue(weaponName, "weight"));

			if (weight > bestWeight) {
				bestWeight = weight;
				bestWeapon = linkedList;
			}
		}

		linkedList = (ncItem)linkedList.m_nextItem;
	}

	if (bestWeapon) {
		if (bestWeapon != m_activeWeapon) {
			SwitchToExactWeapon((ncWeapon)bestWeapon);
		}
	}
}

bool
ncActor::RemoveItem(string itemName)
{
#ifdef SERVER
	ncItem linkedList = __NULL__;
	ncItem frontItem = __NULL__;
	ncItem lastItem = __NULL__;
	ncItem itemToRemove = __NULL__;
	bool removeItem = false;

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return (false);
	}

	/* prevent nonsense */
	if (GetCurrentWeapon() == itemName) {
		SwitchToBestWeapon(true);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		/* found the item, mark as needing to be removed */
		if (linkedList.declclass == itemName) {
			removeItem = true;
			frontItem = lastItem; /* the one before the current one */
			itemToRemove = linkedList; /* the item to destroy */
			break;
		} else if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		lastItem = linkedList;
		linkedList = (ncItem)linkedList.m_nextItem;
	}

	/* successfully remove the last item */
	if (removeItem == true) {
		/* we had an item in front, bridge across the removed item. */
		if (frontItem) {
			frontItem.m_nextItem = (ncItem)itemToRemove.m_nextItem;
		} else {
			/* this was the first item. set to chain (can be NULL) */
			m_itemList = (ncItem)itemToRemove.m_nextItem;
		}

		/* is this our active weapon? */
		if (m_activeWeapon == linkedList) {
			m_activeWeapon._SwitchedFromCallback();
			m_activeWeapon = __NULL__;
		}

		itemToRemove._RemovedCallback();
		return (true);
	}
#endif

	return (false);
}

bool
ncActor::RemoveAllItems(bool ignoreWeapons)
{
	ncItem linkedList = __NULL__;

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		ncItem nextItem = (ncItem)linkedList.m_nextItem;

		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* respect weapon filter */
		if (!(ignoreWeapons && linkedList.IsWeapon() == true)) {
			/* is this our active weapon? give it a chance to do work first */
			if (m_activeWeapon == linkedList) {
				m_activeWeapon._SwitchedFromCallback();
				m_activeWeapon = __NULL__;
			}

			RemoveItem(linkedList.declclass);
			linkedList = nextItem;
			continue;
		}

		linkedList = nextItem;
	}

	return (true);
}

bool
ncActor::RemoveAllWeapons(void)
{
	ncItem linkedList = __NULL__;

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		ncItem nextItem = (ncItem)linkedList.m_nextItem;

		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		if (linkedList.IsWeapon() == true) {
			/* is this our active weapon? give it a chance to do work first */
			if (m_activeWeapon == linkedList) {
				m_activeWeapon._SwitchedFromCallback();
				m_activeWeapon = __NULL__;
			}

			linkedList._RemovedCallback();
			continue;
		}

		linkedList = nextItem;
	}

	return (true);
}

string
ncActor::GetCurrentWeapon(void)
{
	if (m_activeWeapon) {
		return (m_activeWeapon.declclass);
	} else {
		return "";
	}
}

void
ncActor::SwitchToWeapon(string weaponName)
{
	ncItem linkedList = __NULL__;

	/* we do not have an item. */
	if (!m_itemList) {
		return;
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		if (!STRING_SET(linkedList.declclass)) {
			linkedList = __NULL__;
			break;
		}

		/* we already have the item. */
		if (linkedList.declclass == weaponName) {
			SwitchToExactWeapon((ncWeapon)linkedList);
		}

		linkedList = (ncItem)linkedList.m_nextItem;
	}
}

void
ncActor::SwitchToExactWeapon(ncWeapon item)
{
	if (item.IsWeapon() == false) {
		return;
	}

	m_activeWeapon = item;
	m_activeWeapon._SwitchedToCallback();
	//m_activeWeapon.PrintDebugInfo();
}

bool
ncActor::AddItem(ncItem theItem)
{
	return (false);
}

ncWeapon
ncActor::SortWeaponChain(void)
{
	ncWeapon itemChain = (ncWeapon)m_itemList;
	int heighestSlot = -1i;
	int heighestPos = -1i;
	ncWeapon firstWeapon, lastWeapon;
	int hudSlot, hudPos;

	firstWeapon = lastWeapon = __NULL__;

	if (!m_itemList) {
		return __NULL__;
	}

	/* first we determine the range of our hud buckets. */
	while (itemChain) {

		/* no longer in inventory */
		if (itemChain.owner != this) {
			itemChain = (ncWeapon)itemChain.m_nextItem;
			continue;
		}

		if (itemChain.IsWeapon() == true) {
			hudSlot = itemChain.GetDefInt("hudSlot");
			hudPos = itemChain.GetDefInt("hudSlotPos");
			itemChain.m_nextWeapon = __NULL__;
			itemChain.m_prevWeapon = __NULL__;

			if (hudSlot > heighestSlot) {
				heighestSlot = hudSlot;
			}
			if (hudPos > heighestPos) {
				heighestPos = hudPos;
			}
		}

		itemChain = (ncWeapon)itemChain.m_nextItem;
	}

	for (int hS = 0i; hS <= heighestSlot; hS++) {
		for (int hP = 0i; hP <= heighestPos; hP++) {
			itemChain = (ncWeapon)m_itemList;

			while (itemChain) {
				/* no longer in inventory */
				if (itemChain.owner != this) {
					itemChain = (ncWeapon)itemChain.m_nextItem;
					continue;
				}

				if (itemChain.IsWeapon() == true) {
					hudSlot = itemChain.GetDefInt("hudSlot");
					hudPos = itemChain.GetDefInt("hudSlotPos");

					if (hudSlot == hS && hudPos == hP) {
						/* first weapon in the chain? */
						if (!lastWeapon) {
							firstWeapon = itemChain;
							lastWeapon = firstWeapon;
						} else {
							/* assign this weapon to the last weapon of our chain. */
							lastWeapon.m_nextWeapon = itemChain;
							itemChain.m_prevWeapon = lastWeapon;
							lastWeapon = itemChain;
						}
					}
				}

				itemChain = (ncWeapon)itemChain.m_nextItem;
			}
		}
	}

	/* test */
	ncWeapon weaponTest = firstWeapon;
	while (weaponTest) {
		weaponTest = weaponTest.m_nextWeapon;
	}

	if (firstWeapon) {
		firstWeapon.m_prevWeapon = lastWeapon;
		m_firstWeapon = firstWeapon;
	}

	return (firstWeapon);
}

bool
ncWeapon_CanSwitch(ncActor pl)
{
	if (!pl.m_activeWeapon) {
		return false;
	}

	return true;
}

ncWeapon
ncActor::GetNextWeapon(void)
{
	if (ncWeapon_CanSwitch(this) == false) {
		return (__NULL__);
	}

	if (m_activeWeapon.m_nextWeapon) {
		return (m_activeWeapon.m_nextWeapon);
	} else {
		return (m_firstWeapon);
	}
}

ncWeapon
ncActor::GetPreviousWeapon(void)
{
	if (ncWeapon_CanSwitch(this) == false) {
		return (__NULL__);
	}

	if (m_activeWeapon.m_prevWeapon) {
		return (m_activeWeapon.m_prevWeapon);
	} else {
		return (m_firstWeapon);
	}
}

ncWeapon
ncActor::GetLastWeapon(void)
{
	/* TODO: Finish this */
	return (m_activeWeapon);
}

void
ncActor_ListInventory(ncActor targetEntity)
{
	ncItem itemEntry = targetEntity.m_itemList;
	ncWeapon activeWeapon = targetEntity.m_activeWeapon;
	int i = 0i;

	printf("active weapon: %s (%d)\n", activeWeapon.declclass, num_for_edict(activeWeapon));

	while (itemEntry) {
		printf("%i %s (%d) (owner: %d); next: %d\n", i, itemEntry.declclass, num_for_edict(itemEntry), num_for_edict(itemEntry.owner), num_for_edict(itemEntry.m_nextItem));
		itemEntry = (ncItem)itemEntry.m_nextItem;
		i += 1i;
	}
}
