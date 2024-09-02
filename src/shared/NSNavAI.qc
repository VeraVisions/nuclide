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
NSActor::NSActor(void)
{
#ifdef SERVER
	m_iNodes = 0i;
	m_iCurNode = -1i;
	m_pRoute = __NULL__;
	m_vecLastNode = [0,0,0];
	m_vecTurnAngle = [0,0,0];
	m_flMoveSpeedKey = 0.0f;

	_m_flRouteGiveUp = 0.0f;
#endif

	m_itemList = __NULL__;

	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		m_iAmmoTypes[i] = 0;
	}
}

bool
NSActor::IsCrouching(void)
{
	return HasVFlags(VFL_CROUCHING);
}

bool
NSActor::IsProne(void)
{
	return HasVFlags(VFL_PRONE);
}

bool
NSActor::IsStanding(void)
{
	return !HasVFlags(VFL_PRONE | VFL_CROUCHING | VFL_SPRINTING);
}

bool
NSActor::IsSprinting(void)
{
	return HasVFlags(VFL_SPRINTING);
}

bool
NSActor::IsLeaning(void)
{
	return (false);
}

bool
NSActor::CanSprint(void)
{
	return (false);
}

bool
NSActor::CanProne(void)
{
	return (false);
}

bool
NSActor::CanLean(void)
{
	return (false);
}

bool
NSActor::CanCrouch(void)
{
	return (false);
}

/* filled these in with the (default) client side player movement values */
float
NSActor::GetForwardSpeed(void)
{
	return (PMOVE_FORWARD_SPEED);
}

float
NSActor::GetSideSpeed(void)
{
	return (PMOVE_SIDE_SPEED);
}

float
NSActor::GetBackSpeed(void)
{
	return (PMOVE_BACK_SPEED);
}

#ifdef SERVER
void
NSActor::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iNodes", m_iNodes);
	SaveInt(handle, "m_iCurNode", m_iCurNode);
	SaveVector(handle, "m_vecLastNode", m_vecLastNode);
	SaveVector(handle, "m_vecTurnAngle", m_vecTurnAngle);
	SaveFloat(handle, "m_flMoveSpeedKey", m_flMoveSpeedKey);
}

void
NSActor::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iNodes":
		m_iNodes = ReadInt(strValue);
		break;
	case "m_iCurNode":
		m_iCurNode = ReadInt(strValue);
		break;
	case "m_vecLastNode":
		m_vecLastNode = ReadVector(strValue);
		break;
	case "m_vecTurnAngle":
		m_vecTurnAngle = ReadVector(strValue);
		break;
	case "m_flMoveSpeedKey":
		m_flMoveSpeedKey = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSActor::Spawned(void)
{
	super::Spawned();

	/* let's not waste time and resources */
	if (wasfreed(this)) {
		return;
	}

	/* start ammo */
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		string defKey = ammoNameForNum(i);

		if (defKey != "") {
			int defValue = GetDefInt(defKey);
			EntLog("Giving %S some %i units of %S", classname, defValue, defKey);
			GiveAmmo(i, defValue);
		}
	}

	/* give them their inventory */
	string weaponList = GetDefString("weapon");
	string itemList = GetDefString("item");
	int desiredWeapon = GetDefInt("current_weapon");
	string switchTo = "";
	int weaponCount = tokenizebyseparator(weaponList, ",");

	/* append items to the end */
	if (itemList != "") {
		weaponList = sprintf("%s,%s", weaponList, itemList);
	}

	for (int i = 0; i < weaponCount; i++) {
		string itemName = argv(i);
		GiveItem(itemName);

		if (i == desiredWeapon) {
			switchTo = itemName;
		}

		/* re-calculate because GiveItem may overwrite argv() */
		weaponCount = tokenizebyseparator(weaponList, ",");
	}

	if (switchTo != "") {
		SwitchToWeapon(switchTo);
	}

	/* give them their desired appearance */
	string spawnModel = GetSpawnString("model");

	if (spawnModel != "") {
		SetModel(GetSpawnString("model"));
	}
}

void
NSActor::RestoreComplete(void)
{
	if (m_iNodes <= 0i) {
		return;
	}

	/* re-plot our route */
	RouteToPosition(m_vecLastNode);
}

void
NSActor::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
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
	default:
		super::Input(eAct, strInput, strData);
	}
}
#endif


#ifdef SERVER
void
NSActor::RouteEnded(void)
{

}

void
NSActor::CheckRoute_Path(void)
{
	float flDist = floor(vlen(m_pathEntity.GetOrigin() - GetOrigin()));

	//print(sprintf("Check Path! %f\n", flDist));

	/* close enough...? */
	if (flDist < 80) {
		NSActor_Log("Reached path node %S", m_pathTarget);

		m_pathTarget = m_pathEntity.target;
		m_pathEntity = (NSEntity)m_pathEntity.GetTargetEntity();
		velocity = [0,0,0]; /* clamp friction */
	}
}

void
NSActor::CheckRoute(void)
{
	float flDist;
	float flNodeRadius;
	vector evenpos;

	if (m_pathTarget) {
		CheckRoute_Path();
		return;
	}

	if (!m_iNodes) {
		return;
	}

	if (_m_flRouteGiveUp < time) {
		float distanceToLastFrame = distanceSquared(_m_vecRoutePrev, origin);
		//printf("distanceToLastFrame: %f\n", distanceToLastFrame);

		/* 50 units in 2 seconds is not good. */
		if (distanceToLastFrame < 50.0f) {
			/* HACK: for followers */
			if (m_eFollowing) {
				RouteToPosition(m_eFollowing.origin);
				NSActor_Log("Giving up current route to follower, re-calculating");
			} else {
				RouteToPosition(m_vecLastNode);
				NSActor_Log("Giving up current route, re-calculating.");
			}
		}
		_m_flRouteGiveUp = time + 2.0f;
		_m_vecRoutePrev = origin;
	}

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		evenpos = m_vecLastNode;
		evenpos[2] = origin[2];
		flNodeRadius = 8.0f;
	} else {
		evenpos = m_pRoute[m_iCurNode].dest;
		evenpos[2] = origin[2];
		flNodeRadius = m_pRoute[m_iCurNode].radius;

		if (flNodeRadius <= 0.0)
			flNodeRadius = 8.0f;
	}

	flDist = floor(vlen(evenpos - origin));

	if (flDist < flNodeRadius) {
		NSActor_Log("%S reached node", targetname);
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				NSActor_Log("Walking directly to last node at '%v'", m_vecLastNode);
				m_iCurNode = -1;
			}
		}
	}

#if 1
	/* check if we can reach the node after the current one */
	if (m_iCurNode > 0 && m_iNodes > 3) { /* HACK: only bother when we have more than 3 nodes in the path... this works around an issue in c1a0d I'm unsure about */
		int iNextNode = (m_iCurNode - 1);
		vector vecNextNode = m_pRoute[iNextNode].dest;

		other = world;
		tracebox(origin, mins, maxs, vecNextNode, MOVE_OTHERONLY, this);

		/* it's accessible */
		if (!trace_startsolid && trace_fraction == 1.0f) {
			evenpos = vecNextNode;
			m_iCurNode = iNextNode;
			NSActor_Log("Skipping to next node %i at '%v'", iNextNode, vecNextNode);
			return;
		}
	}
#endif

	/* reached the end of the line */
	if (m_iCurNode < -1) {
		RouteClear();
		RouteEnded();
		NSActor_Log("%S reached end", targetname);
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
		if (shouldcrouch || Route_GetNodeFlags(&m_pRoute[m_iCurNode]) & LF_CROUCH)
			input_buttons |= INPUT_CROUCH;
	}

	/*if (flDist == m_flLastDist) {
		m_flNodeGiveup += frametime;
	} else {
		m_flNodeGiveup = bound(0, m_flNodeGiveup - frametime, 1.0);
	}

	m_flLastDist = flDist;

	if (m_flNodeGiveup >= 1.0f) {
		print(sprintf("NSActor::CheckNode: %s gave up route\n",
			this.netname));
		RouteClear();
	}*/
}

vector
NSActor::GetRouteMovevalues(void)
{
	vector vecDirection;
	vector fwdDir, rightDir, upDir;

	fwdDir = anglesToForward(input_angles);
	rightDir = anglesToRight(input_angles);
	upDir = anglesToUp(input_angles);

	if (m_pathTarget) {
		vecDirection = vectorNormalize(m_pathEntity.GetOrigin() - GetOrigin());
	} else {
		if (!m_iNodes)
			return m_vecLastNode;

		if (m_iCurNode < 0)
			vecDirection = vectorNormalize(m_vecLastNode - GetOrigin());
		else
			vecDirection = vectorNormalize(m_pRoute[m_iCurNode].dest - GetOrigin());
	}

	return [fwdDir * vecDirection, rightDir * vecDirection, upDir * vecDirection];
}

vector
NSActor::GetRouteDirection(void)
{
	if (m_pathTarget) {
		return vectorToAngles(m_pathEntity.GetOrigin() - GetOrigin());
	} else {

		if (!m_iNodes) {
			return angles;
		}

		if (m_iCurNode < 0) {
			return vectorToAngles(m_vecLastNode - origin);
		} else {
			return vectorToAngles(m_pRoute[m_iCurNode].dest - origin);
		}
	}
}

void
NSActor::RouteToPosition(vector destination)
{
	RouteToPositionDenyFlags(destination, 0i);
}

void
NSActor::DebugDraw(void)
{
	vector vecStart = GetOrigin();
	vector vecEnd;
	vector beamColor = [1,1,1];
	float frac = 1.0 / m_iNodes;

	for (int i = m_iCurNode; i < m_iNodes; i++) {
		if (m_iCurNode < 0)
			continue;

		vecEnd = m_pRoute[i].dest;
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
NSActor::RouteToPositionDenyFlags(vector destination, int denylinkflags)
{
	/* engine calls this upon successfully creating a route */
	static void RouteToPosition_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		NSActor p = (NSActor)ent;
		p.m_iNodes = numnodes;
		p.m_iCurNode = numnodes - 1;
		p.m_pRoute = nodelist;
		p._m_flRouteGiveUp = time + 4.0f;

		//traceline(p.origin, dest, MOVE_NORMAL, this);
		tracebox(p.origin, [-16, -16, -16], [16, 16, 16], dest, MOVE_NORMAL, this);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			NSActor_Log("Walking directly to last node");
			p.m_iCurNode = -1;
		} else {
			NSActor_Log("Path obstructed, calculating route");

			/* run through all nodes, mark the closest direct path possible */
			for (int i = 0; i < p.m_iNodes; i++) {
				vector vecDest = p.m_pRoute[i].dest;
				tracebox(p.origin, p.mins, p.maxs, vecDest, TRUE, p);
				//traceline(p.origin, vecDest, MOVE_NORMAL, this);

				if (trace_fraction == 1.0) {
					p.m_iCurNode = i;
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

	if (!m_iNodes) {
		route_calculate(this, destination, denylinkflags, RouteToPosition_RouteCB);
		m_vecLastNode = destination;
	}
}

void
NSActor::ChasePath(string startPath)
{
	if (!startPath || startPath == "") {
		m_pathTarget = __NULL__;
		m_pathEntity = __NULL__;
		return;
	}

	m_pathTarget = startPath;
	m_pathEntity = (NSEntity)find(world, ::targetname, m_pathTarget);
	NSActor_Log("Actor %S chase Path set to %S", netname, m_pathEntity.targetname);
}

void
NSActor::RouteClear(void)
{
	if (!m_iNodes)
		return;

	m_iCurNode = BOTROUTE_END;
	m_iNodes = 0;
	memfree(m_pRoute);
	NSActor_Log("Actor %S (%s) cleared their route.", netname, classname);
}

void
NSActor::SetMoveSpeedScale(float newValue)
{
	m_flMoveSpeedKey = newValue;
}

float
NSActor::GetMoveSpeedScale(void)
{
	return (m_flMoveSpeedKey == 0.0) ? 1.0f : m_flMoveSpeedKey;
}

void
NSActor::Physics_Run(void)
{
	input_movevalues *= GetMoveSpeedScale();

	if (CanCrouch())
		PMoveCustom_RunCrouchPhysics(this);
	else
		PMoveCustom_RunPlayerPhysics(this);

	SetOrigin(origin);
}

#endif

void
NSActor::LaunchProjectile(string defName, bool thrown, float timeOfs)
{
#ifdef SERVER
	vector throwDirection;
	float throwingStrength;

	NSProjectile nade = (NSProjectile)EntityDef_CreateClassname(defName);
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
	makevectors(throwDirection);
	nade.SetVelocity((v_forward * throwingStrength) + GetVelocity());
#endif
}

bool
NSActor::PlantCharge(string defName)
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
	NSEntity plantedEntity;
	plantedEntity = spawnClass(defName, destinationVec);

	if (!plantedEntity) {
		EntError("Failed to plant %S", defName);
	}
	plantedEntity.SetOwner(this);
	plantedEntity.real_owner = this;

	printf("Planted %S at %v\n", plantedEntity.classname, origin);
#endif

	/* push us outta the way! */
	SetOriginUnstick(GetOrigin());

	return (true);
}

int
NSActor::GetReserveAmmo(int ammoType)
{
	/* bounds check */
	if (ammoType <= 0i || ammoType >= MAX_AMMO_TYPES)
		return (0i);

	return (m_iAmmoTypes[ammoType]);
}

bool
NSActor::GiveAmmo(int ammoType, int ammoAmount)
{
	int maxAmmo = 0i;

	/* bounds check */
	if (ammoType <= 0i || ammoType >= MAX_AMMO_TYPES)
		return (false);

	/* read max ammo from entityDef decl first */
	maxAmmo = GetDefInt(sprintf("max_%s", ammoNameForNum(ammoType)));

	/* default when above is 0 */
	if (!maxAmmo) {
		maxAmmo = ammoMaxForNum(ammoType);
	}

	/* already at max-ammo? */
	if (m_iAmmoTypes[ammoType] >= maxAmmo)
		return (false);

	m_iAmmoTypes[ammoType] += ammoAmount;

	if (m_iAmmoTypes[ammoType] >= maxAmmo)
		m_iAmmoTypes[ammoType] = maxAmmo;

	return (true);
}

bool
NSActor::UseAmmo(int ammoType, int ammoAmount)
{
	if (autocvar_g_infiniteAmmo == true) {
		return (true);
	}

	/* bounds check */
	if (HasAmmo(ammoType, ammoAmount) == false)
		return (false);

	m_iAmmoTypes[ammoType] -= ammoAmount;
	return (true);
}

bool
NSActor::HasAmmo(int ammoType, int ammoAmount)
{
	/* bounds check */
	if (ammoType < 0i || ammoType >= MAX_AMMO_TYPES)
		return (false);

	/* will underflow when used. */
	if ((m_iAmmoTypes[ammoType] - ammoAmount) < 0i)
		return (false);

	return (true);
}

bool
NSActor::HasExactItem(NSItem itemEntity)
{
	NSItem linkedList = __NULL__;

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
		/* we already have the item. */
		if (linkedList == itemEntity) {
			return (true);
		}

		linkedList = (NSItem)linkedList.m_nextItem;
	}

	return (false);
}


bool
NSActor::HasItem(string itemName)
{
	NSItem linkedList = __NULL__;

	/* we do not have an item. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		/* we already have the item. */
		if (linkedList.classname == itemName) {
			return (true);
		}

		linkedList = (NSItem)linkedList.m_nextItem;
	}

	return (false);
}

void
NSActor::AddedItemCallback(NSItem itemAdded)
{
#ifdef SERVER
	if (!m_activeWeapon) {
		if (itemAdded.IsWeapon()) {
			SwitchToExactWeapon(itemAdded);
		}
	}
#endif
}

bool
NSActor::GiveItem(string itemName)
{
#ifdef SERVER
	NSItem linkedList = __NULL__;
	NSItem lastItem = __NULL__;

	bool canCarry = stof(EntityDef_GetKeyValue(itemName, "inv_carry")) ? true : false;

	/* we do not have an item yet. */
	if (!m_itemList) {
		m_itemList = (NSItem)EntityDef_CreateClassname(itemName);

		if (m_itemList == world) {
			EntError("Unable to give item %S", itemName);
			return (false);
		}

		m_itemList.SetOwner(this);
		m_itemList._AddedCallback();
		//NSLog("First Item %S", m_itemList.classname);

		return (true);
	}

	/* since we have something in the inventory, start there */
	linkedList = (NSWeapon)m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		/* we already have the item. */
		if (linkedList.classname == itemName) {
			//NSLog("we already have", linkedList.classname);
			return (false);
		}

		lastItem = linkedList;
		linkedList = (NSItem)linkedList.m_nextItem;
	}

	/* add it to the back of the chain, so it's part of our inventory. */
	if (lastItem && linkedList == __NULL__) {
		NSItem newItem = (NSItem)EntityDef_CreateClassname(itemName);

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
NSActor::SwitchToBestWeapon(bool ignoreActive)
{
	string toIgnore = __NULL__;
	NSItem linkedList = __NULL__;
	NSItem bestWeapon = __NULL__;
	float bestWeight = 0.0f;

	if (ignoreActive && m_activeWeapon) {
		toIgnore = m_activeWeapon.classname;
	}

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return;
	}

	/* iterate over all the inventory items */
	linkedList = m_itemList;

	while (linkedList) {
		/* inventory item may not be a weapon */
		if (linkedList.IsWeapon()) {
			string weaponName = linkedList.classname;
			float weight;

			if (toIgnore == weaponName) {
				linkedList = (NSItem)linkedList.m_nextItem;
				continue;
			}

			weight = stof(EntityDef_GetKeyValue(weaponName, "weight"));

			if (weight > bestWeight) {
				bestWeight = weight;
				bestWeapon = linkedList;
			}
		}

		linkedList = (NSItem)linkedList.m_nextItem;
	}

	if (bestWeapon) {
		if (bestWeapon != m_activeWeapon) {
			SwitchToExactWeapon((NSWeapon)bestWeapon);
		}
	}
}

bool
NSActor::RemoveItem(string itemName)
{
#ifdef SERVER
	NSItem linkedList = __NULL__;
	NSItem frontItem = __NULL__;
	NSItem lastItem = __NULL__;
	NSItem itemToRemove = __NULL__;
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
		if (linkedList.classname == itemName) {
			removeItem = true;
			frontItem = lastItem; /* the one before the current one */
			itemToRemove = linkedList; /* the item to destroy */
			break;
		}

		lastItem = linkedList;
		linkedList = (NSItem)linkedList.m_nextItem;
	}

	/* successfully remove the last item */
	if (removeItem == true) {
		/* we had an item in front, bridge across the removed item. */
		if (frontItem) {
			frontItem.m_nextItem = (NSItem)itemToRemove.m_nextItem;
		} else {
			/* this was the first item. set to chain (can be NULL) */
			m_itemList = (NSItem)itemToRemove.m_nextItem;
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
NSActor::RemoveAllItems(bool ignoreWeapons)
{
	NSItem linkedList = __NULL__;

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		NSItem nextItem = (NSItem)linkedList.m_nextItem;

		/* respect weapon filter */
		if (!(ignoreWeapons && linkedList.IsWeapon() == true)) {
			/* is this our active weapon? give it a chance to do work first */
			if (m_activeWeapon == linkedList) {
				m_activeWeapon._SwitchedFromCallback();
				m_activeWeapon = __NULL__;
			}

			RemoveItem(linkedList.classname);
			linkedList = nextItem;
			continue;
		}

		linkedList = nextItem;
	}

	return (true);
}

bool
NSActor::RemoveAllWeapons(void)
{
	NSItem linkedList = __NULL__;

	/* we posess nothing. auto return false. */
	if (!m_itemList) {
		return (false);
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		NSItem nextItem = (NSItem)linkedList.m_nextItem;

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
NSActor::GetCurrentWeapon(void)
{
	if (m_activeWeapon) {
		return (m_activeWeapon.classname);
	} else {
		return "";
	}
}

void
NSActor::SwitchToWeapon(string weaponName)
{
	NSItem linkedList = __NULL__;

	/* we do not have an item. */
	if (!m_itemList) {
		return;
	}

	/* since we have something in the inventory, start there */
	linkedList = m_itemList;

	/* iterate through the inventory, then figure out if we already have it*/
	while (linkedList) {
		/* we already have the item. */
		if (linkedList.classname == weaponName) {
			SwitchToExactWeapon((NSWeapon)linkedList);
		}

		linkedList = (NSItem)linkedList.m_nextItem;
	}
}

void
NSActor::SwitchToExactWeapon(NSWeapon item)
{
	if (item.IsWeapon() == false) {
		return;
	}

	m_activeWeapon = item;
	m_activeWeapon._SwitchedToCallback();
	//m_activeWeapon.PrintDebugInfo();
}

bool
NSActor::AddItem(NSItem theItem)
{
	return (false);
}

NSWeapon
NSActor::SortWeaponChain(void)
{
	NSWeapon itemChain = (NSWeapon)m_itemList;
	int heighestSlot = -1i;
	int heighestPos = -1i;
	NSWeapon firstWeapon, lastWeapon;
	int hudSlot, hudPos;

	firstWeapon = lastWeapon = __NULL__;

	if (!m_itemList) {
		return __NULL__;
	}

	/* first we determine the range of our hud buckets. */
	while (itemChain) {

		/* no longer in inventory */
		if (itemChain.owner != this) {
			itemChain = (NSWeapon)itemChain.m_nextItem;
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

		itemChain = (NSWeapon)itemChain.m_nextItem;
	}

	for (int hS = 0i; hS <= heighestSlot; hS++) {
		for (int hP = 0i; hP <= heighestPos; hP++) {
			itemChain = (NSWeapon)m_itemList;

			while (itemChain) {
				/* no longer in inventory */
				if (itemChain.owner != this) {
					itemChain = (NSWeapon)itemChain.m_nextItem;
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

				itemChain = (NSWeapon)itemChain.m_nextItem;
			}
		}
	}

	/* test */
	NSWeapon weaponTest = firstWeapon;
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
NSWeapon_CanSwitch(NSActor pl)
{
	if (!pl.m_activeWeapon) {
		return false;
	}

	return true;
}

NSWeapon
NSActor::GetNextWeapon(void)
{
	if (NSWeapon_CanSwitch(this) == false) {
		return (__NULL__);
	}

	if (m_activeWeapon.m_nextWeapon) {
		return (m_activeWeapon.m_nextWeapon);
	} else {
		return (m_firstWeapon);
	}
}

NSWeapon
NSActor::GetPreviousWeapon(void)
{
	if (NSWeapon_CanSwitch(this) == false) {
		return (__NULL__);
	}

	if (m_activeWeapon.m_prevWeapon) {
		return (m_activeWeapon.m_prevWeapon);
	} else {
		return (m_firstWeapon);
	}
}

NSWeapon
NSActor::GetLastWeapon(void)
{
	/* TODO: Finish this */
	return (m_activeWeapon);
}

void
NSActor_ListInventory(NSActor targetEntity)
{
	NSItem itemEntry = targetEntity.m_itemList;
	NSWeapon activeWeapon = targetEntity.m_activeWeapon;
	int i = 0i;

	printf("active weapon: %s (%d)\n", activeWeapon.classname, num_for_edict(activeWeapon));

	while (itemEntry) {
		printf("%i %s (%d) (owner: %d); next: %d\n", i, itemEntry.classname, num_for_edict(itemEntry), num_for_edict(itemEntry.owner), num_for_edict(itemEntry.m_nextItem));
		itemEntry = (NSItem)itemEntry.m_nextItem;
		i += 1i;
	}
}
