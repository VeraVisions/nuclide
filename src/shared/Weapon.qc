/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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
ncWeapon::ncWeapon(void)
{
	m_weaponClipStartSize = 0i;
	m_fiRemoveOnEmpty = false;
	m_weaponViewModelPath = __NULL__;
	m_weaponPlayerModelPath = __NULL__;
	m_weaponScript = __NULL__;
	m_weaponAmmoType = __NULL__;
	m_weaponRequiresAmmo = false;
	m_fiMuzzleFlashMaterial = __NULL__;
	m_fiMuzzleFlashColor = g_vec_null;
	m_fiMuzzleFlashRadius = 0.0f;
	m_weaponDropsItem = __NULL__;
	m_fiFXSmokeParticle = __NULL__;
	m_fiFXSmokeContinous = false;
	m_weaponClip = 0i;
	m_weaponClipSize = 0i;
	m_weaponFireInfoValue = 0;
	m_viewModel = 0;
	m_worldModel = 0;
	m_playerModel = 0.0f;
	m_weaponFireRate = 1.0f;
	m_weaponState = 0;
	m_weaponLastFireInfo = __NULL__;
	m_fiSpeedMod = 1.0f;
	m_fiReloadTime = -1.0f;
	m_nextWeapon = __NULL__;
	m_prevWeapon = __NULL__;
	m_fiFireUnderwater = true;
}

void
ncWeapon::_AddedCallback(void)
{
	ncActor ourOwner = (ncActor)owner;
	super::_AddedCallback();

	if (!owner) {
		return;
	}

	/* after being stored in someones inventory,
	   re-sort our inventory according to their logic */
	ourOwner.SortWeaponChain();

	/* we have no active weapon, and this is our pick */
	if (!ourOwner.m_activeWeapon) {
		ourOwner.SwitchToExactWeapon(this);
	}

	/* Become the visible attachment */
	SetModelindex(m_playerModel);
}

void
ncWeapon::_RemovedCallback(void)
{
	if (owner) {
		/* give the weapon a chance to clean up the owners inventory */
		ncActor ourOwner = (ncActor)owner;
		owner = __NULL__;
		ourOwner.SortWeaponChain();
		owner = ourOwner;
	}

	super::_RemovedCallback();
}

void
ncWeapon::AddedToInventory(void)
{
}

void
ncWeapon::RemovedFromInventory(void)
{
}

void
ncWeapon::SwitchedToWeapon(void)
{
}

void
ncWeapon::SwitchedFromWeapon(void)
{
}

void
ncWeapon::_SetWeaponState(nsweapon_state_t newState)
{
	if (m_weaponState == newState) {
		return;
	}

	m_weaponState = newState;

#ifdef SERVER
	//printf("State changed to %s\n", nsweapon_state_s[newState]);
#endif
}

nsweapon_state_t
ncWeapon::GetWeaponState(void)
{
	return (m_weaponState);
}

void
ncWeapon::UpdateFireInfoCache(void)
{
#ifdef CLIENT
	ncRenderableEntity viewModelRight = (ncRenderableEntity)pSeat->m_eViewModel;
	ncRenderableEntity viewModelLeft = (ncRenderableEntity)pSeat->m_eViewModelL;
#endif

	string ammoPerShot = GetSubDefString(m_weaponLastFireInfo, "ammoPerShot");
	string reloadSpeed = GetSubDefString(m_weaponLastFireInfo, "reloadTime");
	m_fiDetonateOnFire = GetSubDefString(m_weaponLastFireInfo, "detonateOnFire");
	m_fiPunchAngle = GetSubDefVector(m_weaponLastFireInfo, "punchAngle");
	m_fiPunchSpring = GetSubDefVector(m_weaponLastFireInfo, "punchSpring");
	m_fiSndFire = GetSubDefString(m_weaponLastFireInfo, "snd_fire");
	m_fiSndFailed = GetSubDefString(m_weaponLastFireInfo, "snd_fireFailed");
	m_fiSndFireLast = GetSubDefString(m_weaponLastFireInfo, "snd_fireLast");
	m_fiSndRelease = GetSubDefString(m_weaponLastFireInfo, "snd_release");
	m_fiSndEmpty = GetSubDefString(m_weaponLastFireInfo, "snd_empty");
	m_fiAmmoType = ammoNumForName(GetSubDefString(m_weaponLastFireInfo, "ammoType"));
	m_fiAmmoRequired = GetSubDefBool(m_weaponLastFireInfo, "ammoRequired");
	m_fiFireRate = GetSubDefFloat(m_weaponLastFireInfo, "fireRate");
	m_fiSemiAuto = GetSubDefBool(m_weaponLastFireInfo, "semiAuto");
	m_fiZoomFOV = GetSubDefFloat(m_weaponLastFireInfo, "zoomFov") / 90.0f;

	/* defs to spawn */
	m_fiOnFire = GetSubDefString(m_weaponLastFireInfo, "def_onFire");
	m_fiOnRelease = GetSubDefString(m_weaponLastFireInfo, "def_onRelease");
	m_fiChargeTime = GetSubDefFloat(m_weaponLastFireInfo, "chargeTime");

	m_fiOverheatPoints = GetSubDefFloat(m_weaponLastFireInfo, "overheatPerShot");

	m_fiSndFireStart = GetSubDefString(m_weaponLastFireInfo, "snd_fireStart");
	m_fiSndFireStop = GetSubDefString(m_weaponLastFireInfo, "snd_fireStop");
	m_fiSndFireLoop = GetSubDefString(m_weaponLastFireInfo, "snd_fireLoop");
	m_fiFireUnderwater = GetSubDefBool(m_weaponLastFireInfo, "fireUnderwater");

	/* firing cosmetics */
#ifdef CLIENT
	setmodel(pSeat->m_eViewModel, GetSubDefString(m_weaponLastFireInfo, "model_view"));
	viewModelLeft.declclass = viewModelRight.declclass = declclass;

	m_fiJointMuzzle = gettagindex(pSeat->m_eViewModel, GetSubDefString(m_weaponLastFireInfo, "muzzle"));
	viewModelLeft.m_fiJointMuzzle = viewModelRight.m_fiJointMuzzle = m_fiJointMuzzle;

	m_fiJointBarrel = gettagindex(pSeat->m_eViewModel, GetSubDefString(m_weaponLastFireInfo, "barrel"));
	viewModelLeft.m_fiJointBarrel = viewModelRight.m_fiJointBarrel = m_fiJointBarrel;

	m_muzzPartSmoke = GetSubDefString(m_weaponLastFireInfo, "smoke_muzzle");
	viewModelLeft.m_muzzPartSmoke = viewModelRight.m_muzzPartSmoke = m_muzzPartSmoke;

	m_muzzOffset = GetSubDefVector(m_weaponLastFireInfo, "muzzleOffset");
	viewModelLeft.m_muzzOffset = viewModelRight.m_muzzOffset = m_muzzOffset;

	m_muzzRelativeOffset = GetSubDefVector(m_weaponLastFireInfo, "muzzleRelativeOffset");
	viewModelLeft.m_muzzRelativeOffset = viewModelRight.m_muzzRelativeOffset = m_muzzRelativeOffset;

// 	printf("%S %S %d\n", pSeat->m_eViewModel.model, GetSubDefString(m_weaponLastFireInfo, "barrel"), m_fiJointBarrel);


	setsize(viewModelLeft, [0,0,0], [0,0,0]);
	setsize(viewModelRight, [0,0,0], [0,0,0]);
#endif

	m_fiBrassDef = GetSubDefString(m_weaponLastFireInfo, "def_ejectBrass");
	m_fiBrassDelay = GetSubDefFloat(m_weaponLastFireInfo, "ejectBrassDelay");

	/* only check if it's present. */
	m_fiLoopingFire = GetSubDefBool(m_weaponLastFireInfo, "act_loop");
	m_fiCocks = GetSubDefBool(m_weaponLastFireInfo, "cocks");
	m_fiDrawAfterRelease = GetSubDefBool(m_weaponLastFireInfo, "drawAfterRelease");

	m_fiRegenAmmo = GetSubDefInt(m_weaponLastFireInfo, "regenAmmo");
	m_fiRegenRate = GetSubDefFloat(m_weaponLastFireInfo, "regenRate");

	m_fiDepleteAmmo = GetSubDefInt(m_weaponLastFireInfo, "depleteAmmo");
	m_fiDepleteRate = GetSubDefFloat(m_weaponLastFireInfo, "depleteRate");

	/* keep the last valid value (don't 0.0f it) to prevent overlay dropouts. */
	if (m_fiOverheatPoints) {
		m_fiOverheatLength = GetSubDefFloat(m_weaponLastFireInfo, "overheatLength");
	}

	/* when -1.0 we'll pull it from the animation. */
	if (reloadSpeed != "") {
		m_fiReloadTime = stof(reloadSpeed);
	} else {
		m_fiReloadTime = -1.0f;
	}

#ifdef CLIENT
	if (pSeat != __NULL__) {
		string viewGeomset = GetSubDefString(m_weaponLastFireInfo, "view_geomset");
		if (pSeat->m_eViewModel) {
			if (viewGeomset) {
				setcustomskin(pSeat->m_eViewModel, "", viewGeomset);
				setcustomskin(pSeat->m_eViewModelL, "", viewGeomset);
			} else {
				setcustomskin(pSeat->m_eViewModel, "", "");
				setcustomskin(pSeat->m_eViewModelL, "", "");
			}
		}
	}
#endif

#if 0
	ncError("Switched FireInfo to %S", m_weaponLastFireInfo);
	ncError("m_fiAmmoType: %i", m_fiAmmoRequired);
	ncError("m_fiAmmoRequired: %d", m_fiAmmoRequired);
	ncError("m_fiFireRate: %f", m_fiAmmoRequired);
	ncError("m_fiReloadTime: %f", m_fiReloadTime);
#endif

	/* validate */
	if (ammoPerShot != __NULL__) {
		m_fiAmmoPerShot = (int)stoi(ammoPerShot);
	} else {
		m_fiAmmoPerShot = 1i;
	}

#ifdef CLIENT
	if (pSeat != __NULL__) {
		ncRenderableEntity viewModel = (ncRenderableEntity)pSeat->m_eViewModel;
		ncRenderableEntity viewModel2 = (ncRenderableEntity)pSeat->m_eViewModelL;

		if (viewModel && viewModel.classname == "vm") {
			string viewModelPath2 = GetSubDefString(m_primaryFireInfo, "model_view2");
			string viewModelPath3 = GetSubDefString(m_primaryFireInfo, "model_view3");
			string viewModelPath4 = GetSubDefString(m_primaryFireInfo, "model_view4");

			viewModel.modelindex = m_viewModel;
			viewModel.modelindex2 = getmodelindex(viewModelPath2);
			viewModel.modelindex3 = getmodelindex(viewModelPath3);
			viewModel.modelindex4 = getmodelindex(viewModelPath4);
			string modelFlash = GetSubDefString(m_weaponLastFireInfo, "model_flash");
			viewModel2.m_iMuzzleModel = viewModel.m_iMuzzleModel = (int)getmodelindex(modelFlash);

			if (viewModel) {
				viewModel._UpdateBoneCount();
			}

			if (viewModel2) {
				viewModel2._UpdateBoneCount();
			}
		}
	}
#endif
}

void
ncWeapon::SetViewZoom(float viewZoom)
{
	if (viewZoom == 0.0) {
		viewZoom = 1.0f;
	}

	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.viewzoom = viewZoom;
}

void
ncWeapon::SwitchFireInfo(string newInfo)
{
	/* nothing changed. */
	//if (m_weaponLastFireInfo == newInfo) {
	//	return;
	//}

	m_weaponLastFireInfo = newInfo;
	UpdateFireInfoCache();
}

#ifdef SERVER
void
ncWeapon::Spawned(void)
{
	super::Spawned();

	if (m_weaponClipStartSize > 0i) {
		m_weaponClip = m_weaponClipStartSize;
	} else {
		m_weaponClip = m_weaponClipSize;
	}

	m_itemCarries = true;
	precache.Model(m_weaponViewModelPath);
	precache.Model(m_weaponPlayerModelPath);

	SetViewModel(m_weaponViewModelPath);
	SetWorldModel(model);
	SetPlayerModel(m_weaponPlayerModelPath);
	_isWeapon = true;
}

void
ncWeapon::RestoreComplete(void)
{
	UpdateFireInfoCache();

	if (owner) {
		ncActor ourOwner = (ncActor)owner;
		ourOwner.SortWeaponChain();
		SendFlags = -1;
	}
}

void
ncWeapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "model_view":
		m_weaponViewModelPath = ReadString(setValue);
		break;
	case "model_world":
		model = ReadString(setValue);
		break;
	case "model_player":
		m_weaponPlayerModelPath = ReadString(setValue);
		break;
	case "weapon_scriptobject":
		m_weaponScript = ReadString(setValue);
		break;
	case "ammoType":
		m_weaponAmmoType = ReadString(setValue);
		break;
	case "clipSize":
		m_weaponClipSize = ReadInt(setValue);
		break;
	case "clipSizeDefault":
		m_weaponClipStartSize = ReadInt(setValue);
		break;
	case "mtr_flashShader":
		m_fiMuzzleFlashMaterial = ReadString(setValue);
		break;
	case "flashColor":
		m_fiMuzzleFlashColor = ReadVector(setValue);
		break;
	case "flashRadius":
		m_fiMuzzleFlashRadius = ReadFloat(setValue);
		break;
	case "def_dropItem":
		m_weaponDropsItem = ReadString(setValue);
		break;
	case "snd_hum":
		m_sndHum = ReadString(setValue);
		break;
	case "continuousSmoke":
		m_fiFXSmokeContinous = ReadBool(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncWeapon::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "weaponTitle", m_weaponTitle);
	SaveInt(handle, "weaponHUDSlot", m_weaponHUDSlot);
	SaveInt(handle, "weaponHUDSlotPos", m_weaponHUDSlotPos);
	SaveString(handle, "weaponHUDIcon", m_weaponHUDIcon);
	SaveString(handle, "weaponHUDIconSel", m_weaponHUDIconSel);
	SaveString(handle, "weaponViewModelPath", m_weaponViewModelPath);
	SaveString(handle, "weaponPlayerModelPath", m_weaponPlayerModelPath);
	SaveString(handle, "weaponScript", m_weaponScript);
	SaveString(handle, "weaponAmmoType", m_weaponAmmoType);
	SaveBool(handle, "weaponRequiresAmmo", m_weaponRequiresAmmo);
	SaveInt(handle, "weaponClipStartSize", m_weaponClipStartSize);
	SaveString(handle, "weaponDropsItem", m_weaponDropsItem);
	SaveBool(handle, "weaponIsFiring", m_weaponIsFiring);
	SaveInt(handle, "weaponClip", m_weaponClip);
	SaveInt(handle, "weaponClipSize", m_weaponClipSize);
	SaveFloat(handle, "weaponFireInfoValue", m_weaponFireInfoValue);
	SaveFloat(handle, "viewModel", m_viewModel);
	SaveFloat(handle, "worldModel", m_worldModel);
	SaveFloat(handle, "playerModel", m_playerModel);
	SaveFloat(handle, "weaponFireRate", m_weaponFireRate);
	SaveFloat(handle, "weaponState", m_weaponState);
	SaveBool(handle, "weaponIsFiring", m_weaponIsFiring);
	SaveBool(handle, "weaponOverheating", m_weaponOverheating);
	SaveEntity(handle, "nextWeapon", m_nextWeapon);
	SaveEntity(handle, "prevWeapon", m_prevWeapon);
	SaveString(handle, "weaponLastFireInfo", m_weaponLastFireInfo);
	SaveBool(handle, "_isWeapon", _isWeapon);
}

void
ncWeapon::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "weaponTitle":
		m_weaponTitle = ReadString(setValue);
		break;
	case "weaponHUDSlot":
		m_weaponHUDSlot = ReadInt(setValue);
		break;
	case "weaponHUDSlotPos":
		m_weaponHUDSlotPos = ReadInt(setValue);
		break;
	case "weaponHUDIcon":
		m_weaponHUDIcon = ReadString(setValue);
		break;
	case "weaponHUDIconSel":
		m_weaponHUDIconSel = ReadString(setValue);
		break;
	case "weaponViewModelPath":
		m_weaponViewModelPath = ReadString(setValue);
		break;
	case "weaponPlayerModelPath":
		m_weaponPlayerModelPath = ReadString(setValue);
		break;
	case "weaponScript":
		m_weaponScript = ReadString(setValue);
		break;
	case "weaponAmmoType":
		m_weaponAmmoType = ReadString(setValue);
		break;
	case "weaponRequiresAmmo":
		m_weaponRequiresAmmo = ReadBool(setValue);
		break;
	case "weaponClipStartSize":
		m_weaponClipStartSize = ReadInt(setValue);
		break;
	case "weaponDropsItem":
		m_weaponDropsItem = ReadString(setValue);
		break;
	case "weaponIsFiring":
		m_weaponIsFiring = ReadBool(setValue);
		break;
	case "weaponClip":
		m_weaponClip = ReadInt(setValue);
		break;
	case "weaponClipSize":
		m_weaponClipSize = ReadInt(setValue);
		break;
	case "weaponFireInfoValue":
		m_weaponFireInfoValue = ReadFloat(setValue);
		break;
	case "viewModel":
		m_viewModel = ReadFloat(setValue);
		break;
	case "worldModel":
		m_worldModel = ReadFloat(setValue);
		break;
	case "playerModel":
		m_playerModel = ReadFloat(setValue);
		break;
	case "weaponFireRate":
		m_weaponFireRate = ReadFloat(setValue);
		break;
	case "weaponState":
		m_weaponState = ReadFloat(setValue);
		break;
	case "weaponIsFiring":
		m_weaponIsFiring = ReadBool(setValue);
		break;
	case "weaponOverheating":
		m_weaponOverheating = ReadBool(setValue);
		break;
	case "nextWeapon":
		m_nextWeapon = (ncWeapon)ReadEntity(setValue);
		break;
	case "prevWeapon":
		m_prevWeapon = (ncWeapon)ReadEntity(setValue);
		break;
	case "weaponLastFireInfo":
		m_weaponLastFireInfo = ReadString(setValue);
		break;
	case "_isWeapon":
		_isWeapon = ReadBool(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}

/* Make sure StartFrame calls this */
float
ncWeapon::SendEntity(entity ePEnt, float flChanged)
{
	bool inInventory = InInventory();

	/* item is in somebody elses inventory. */
	if (inInventory == true && ePEnt != GetOwner()) {
		return (false);
	}

	if (inInventory == true) {
		flChanged &= ~WEAPONFL_CHANGED_ORIGIN;
		flChanged &= ~WEAPONFL_CHANGED_ANGLES;
		flChanged &= ~WEAPONFL_CHANGED_VELOCITY;
		flChanged &= ~WEAPONFL_CHANGED_ANGULARVELOCITY;
	}

	WriteByte(MSG_ENTITY, ENT_WEAPON);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_ENTITY(m_nextItem, WEAPONFL_CHANGED_CHAIN)
	SENDENTITY_ENTITY(owner, WEAPONFL_CHANGED_CHAIN)
	SENDENTITY_ENTITY(m_nextWeapon, WEAPONFL_CHANGED_NEXTWEAPON)
	SENDENTITY_ENTITY(m_prevWeapon, WEAPONFL_CHANGED_PREVWEAPON)
	SENDENTITY_COORD(origin[0], WEAPONFL_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], WEAPONFL_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], WEAPONFL_CHANGED_ORIGIN)
	SENDENTITY_ANGLE(angles[0], WEAPONFL_CHANGED_ANGLES)
	SENDENTITY_ANGLE(angles[1], WEAPONFL_CHANGED_ANGLES)
	SENDENTITY_ANGLE(angles[2], WEAPONFL_CHANGED_ANGLES)
	SENDENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(m_weaponFireRate, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(m_nuclideFlags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, WEAPONFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, WEAPONFL_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, WEAPONFL_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_geomsetField, WEAPONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, WEAPONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_weaponClip, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_weaponClipSize, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_weaponFireInfoValue, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_weaponState, WEAPONFL_CHANGED_STATE)
	SENDENTITY_BYTE(m_weaponIsFiring, WEAPONFL_CHANGED_STATE)
	SENDENTITY_FLOAT(m_weaponOverheating, WEAPONFL_CHANGED_STATE)
	return (true);
}

void
ncWeapon::EvaluateEntity(void)
{
	EVALUATE_FIELD(m_nextItem, WEAPONFL_CHANGED_CHAIN)
	EVALUATE_FIELD(owner, WEAPONFL_CHANGED_CHAIN)
	EVALUATE_FIELD(m_nextWeapon, WEAPONFL_CHANGED_NEXTWEAPON)
	EVALUATE_FIELD(m_prevWeapon, WEAPONFL_CHANGED_PREVWEAPON)
	EVALUATE_VECTOR(origin, 0, WEAPONFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, WEAPONFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, WEAPONFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(angles, 0, WEAPONFL_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 1, WEAPONFL_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 2, WEAPONFL_CHANGED_ANGLES)
	EVALUATE_FIELD(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(modelindex, WEAPONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_weaponFireRate, WEAPONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, WEAPONFL_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(modelflags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(m_nuclideFlags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, WEAPONFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, WEAPONFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, WEAPONFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, WEAPONFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_geomsetField, WEAPONFL_CHANGED_BODY)
	EVALUATE_FIELD(scale, WEAPONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_weaponClip, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_weaponClipSize, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_weaponFireInfoValue, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_weaponState, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_weaponIsFiring, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_weaponOverheating, WEAPONFL_CHANGED_STATE)

	if (InInventory() == true) {
		SetOrigin(owner.origin);
		pvsflags = PVSF_IGNOREPVS;
		modelindex = 0;
	} else {
		pvsflags = 0;
	}
}
#endif

#ifdef CLIENT
void
ncWeapon::HandleAnimEvent(float timeStamp, int eventCode, string dataString)
{
	switch (eventCode) {

	default:
		super::HandleAnimEvent(timeStamp, eventCode, dataString);
	}
}

void
ncWeapon::ClientFX(bool isThirdperson)
{
	if (m_weaponIsFiring == false) {
		return;
	}

	vector src;
	vector endpos;
	ncActor pl = (ncActor)owner;

	if (isThirdperson == true) {
		src = pl.GetEyePos();
		endpos = src + (anglesToForward(pl.GetViewAngle()) * 1024.0f);
		traceline(src, endpos, MOVE_NORMAL, pl);
		trailparticles(m_fiFXTrail, pl, gettaginfo(this, m_jointTrailWorld), trace_endpos);
	} else {
		vector gunpos = gettaginfo(pSeat->m_eViewModel, m_jointTrailView);
		src = g_view.GetCameraOrigin();
		endpos = src + (anglesToForward(g_view.GetCameraAngle()) * 1024.0f);
		traceline(src, endpos, MOVE_NORMAL, pl);
		trailparticles(m_fiFXTrail, pl, gunpos, trace_endpos);
	}
}

void
ncWeapon::ReceiveEntity(float flNew, float flChanged)
{
	_isWeapon = true;
	READENTITY_INT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_ENTNUM(chain_entnum, WEAPONFL_CHANGED_CHAIN)
	READENTITY_ENTNUM(owner_entnum, WEAPONFL_CHANGED_CHAIN)
	READENTITY_ENTNUM(m_nextWeapon_entnum, WEAPONFL_CHANGED_NEXTWEAPON)
	READENTITY_ENTNUM(m_prevWeapon_entnum, WEAPONFL_CHANGED_PREVWEAPON)

	READENTITY_COORD(origin[0], WEAPONFL_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], WEAPONFL_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], WEAPONFL_CHANGED_ORIGIN)
	READENTITY_ANGLE(angles[0], WEAPONFL_CHANGED_ANGLES)
	READENTITY_ANGLE(angles[1], WEAPONFL_CHANGED_ANGLES)
	READENTITY_ANGLE(angles[2], WEAPONFL_CHANGED_ANGLES)
	READENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_FLOAT(m_weaponFireRate, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(modelflags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(m_nuclideFlags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], WEAPONFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, WEAPONFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, WEAPONFL_CHANGED_SKIN)
	READENTITY_FLOAT(effects, WEAPONFL_CHANGED_EFFECTS)
	READENTITY_SHORT(m_geomsetField, WEAPONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, WEAPONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_weaponClip, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_weaponClipSize, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_weaponFireInfoValue, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_weaponState, WEAPONFL_CHANGED_STATE)
	READENTITY_BYTE(m_weaponIsFiring, WEAPONFL_CHANGED_STATE)
	READENTITY_FLOAT(m_weaponOverheating, WEAPONFL_CHANGED_STATE)

	/* expensive & this has to be done first, any code below may query decl */
	if (flChanged & WEAPONFL_CHANGED_MODELINDEX) {
		EntityDef_SetFromEntNum(this, entityDefID);
	}

	ncActor ourOwner = (ncActor)findfloat(world, ::entnum, owner_entnum);

	if (ourOwner.m_activeWeapon == this) {
		SwitchFireInfo(m_primaryFireInfo);
	}

	if (flChanged & WEAPONFL_CHANGED_BODY)
		_UpdateGeomset();

	drawmask = (modelindex != 0) ? MASK_ENGINE : 0;

	if (flChanged & WEAPONFL_CHANGED_CHAIN) {
		m_nextItem = __NULL__;
	}

	if (flChanged & WEAPONFL_CHANGED_NEXTWEAPON) {
		m_nextWeapon = __NULL__;
	}

	if (flChanged & WEAPONFL_CHANGED_PREVWEAPON) {
		m_prevWeapon = __NULL__;
	}

	if (scale == 0.0f)
		scale = 1.0f;

	if (flChanged & WEAPONFL_CHANGED_SIZE)
		setsize(this, mins, maxs);
}


void
ncWeapon::ReceiveEvent(float eventID)
{
	switch (eventID) {
	case WEPEVENT_FIRED:
		EntLog("Someones weapon was fired.");
		break;
	}
}


void
ncWeapon::PredictPreFrame(void)
{
	super::PredictPreFrame();

	/* may no longer be valid */
	if (wasfreed(this)) {
		return;
	}

	if (m_nextWeapon == __NULL__ && m_nextWeapon_entnum) {
		m_nextWeapon = (ncWeapon)findentity(world, ::entnum, m_nextWeapon_entnum);
	}

	if (m_prevWeapon == __NULL__ && m_prevWeapon_entnum) {
		m_prevWeapon = (ncWeapon)findentity(world, ::entnum, m_prevWeapon_entnum);
	}

	SAVE_STATE(m_nextWeapon)
	SAVE_STATE(m_prevWeapon)
	SAVE_STATE(modelindex)
	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(entityDefID)
	SAVE_STATE(m_viewModel)
	SAVE_STATE(m_weaponFireRate)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(flags)
	SAVE_STATE(m_nuclideFlags)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
//	SAVE_STATE(frame)
//	SAVE_STATE(skin)
//	SAVE_STATE(effects)
	SAVE_STATE(m_geomsetField)
	SAVE_STATE(scale)
	SAVE_STATE(velocity)
	SAVE_STATE(avelocity)
	SAVE_STATE(m_weaponClip)
	SAVE_STATE(m_weaponClipSize)
	SAVE_STATE(m_weaponFireInfoValue)
	SAVE_STATE(m_weaponState)
	SAVE_STATE(m_weaponIsFiring)
	SAVE_STATE(m_weaponOverheating)
}

void
ncWeapon::PredictPostFrame(void)
{
	super::PredictPostFrame();

	ROLL_BACK(m_nextWeapon)
	ROLL_BACK(m_prevWeapon)
	ROLL_BACK(modelindex)
	ROLL_BACK(origin)
	ROLL_BACK(angles)
	ROLL_BACK(entityDefID)
	ROLL_BACK(m_viewModel)
	ROLL_BACK(m_weaponFireRate)
	ROLL_BACK(solid)
	ROLL_BACK(movetype)
	ROLL_BACK(flags)
	ROLL_BACK(m_nuclideFlags)
	ROLL_BACK(mins)
	ROLL_BACK(maxs)
//	ROLL_BACK(frame)
//	ROLL_BACK(skin)
//	ROLL_BACK(effects)
	ROLL_BACK(m_geomsetField)
	ROLL_BACK(scale)
	ROLL_BACK(velocity)
	ROLL_BACK(avelocity)
	ROLL_BACK(m_weaponClip)
	ROLL_BACK(m_weaponClipSize)
	ROLL_BACK(m_weaponFireInfoValue)
	ROLL_BACK(m_weaponState)
	ROLL_BACK(m_weaponIsFiring)
	ROLL_BACK(m_weaponOverheating)
}

#endif

void
ncWeapon::ReloadCachedAttributes(void)
{
	string firstType, secondType;
	string ammoRequired;

	m_weaponTitle = GetDefString("inv_name");

#ifdef CLIENT
	m_weaponTitle = localize(m_weaponTitle);
#endif

	m_weaponHUDSlot = GetDefInt("hudSlot");
	m_weaponHUDSlotPos = GetDefInt("hudSlotPos");

	/* movement vars */
	m_fiSpeedMod = GetDefFloat("speed_mod");
	m_fiBuggyIdleAnim = GetDefBool("buggyIdleAnim");

	if (m_fiSpeedMod <= 0.0) {
		m_fiSpeedMod = 1.0f;
	}

	/* string lookups can be expensive if done too often
	   so we'll need to cache them whenever something
	   big in the game state changes. like a save/load. */
	m_primaryFireInfo = GetDefString("def_fireInfo");
	m_secondaryFireInfo = GetDefString("def_altFireInfo");

	if (!m_primaryFireInfo) {
		m_primaryFireInfo = classname;
	}

	firstType = GetSubDefString(m_primaryFireInfo, "ammoType");

	/* may be defined in either fireInfo or weaponDef */
	ammoRequired = GetSubDefString(m_primaryFireInfo, "ammoRequired");
	m_weaponRequiresAmmo = stof(ammoRequired);
	m_primaryAmmoType = ammoNumForName(firstType);
	m_fiPrimedFuse = GetDefFloat("primed_fuse");
	m_fiPowerAmmo = GetDefBool("powerAmmo");
	m_fiRemoveOnEmpty = GetDefBool("removeOnEmpty");
	m_fiFXTrail = particleeffectnum(GetDefString("fx_trail"));
	m_viewModel = getmodelindex(GetDefString("model_view"));
	m_worldModel = getmodelindex(GetDefString("model"));
	m_fiAltModeSwitch = GetDefBool("altMode");

	/* gettagindex takes the silliest of parameters to determine which model to query */
	string jointTrailWorld = GetDefString("joint_world_trail");
	string jointTrailView = GetDefString("joint_view_trail");
	float oldModelindex = modelindex;
	modelindex = m_worldModel;
	m_jointTrailWorld = gettagindex(this, jointTrailWorld);
	modelindex = m_viewModel;
	m_jointTrailView = gettagindex(this, jointTrailView);
	modelindex = oldModelindex;

	/* alt fire is optional. */
	if (!m_secondaryFireInfo) {
		return;
	}

	secondType = GetSubDefString(m_secondaryFireInfo, "ammoType");
	m_secondaryAmmoType = ammoNumForName(secondType);
}

void
ncWeapon::_SwitchedToCallback(void)
{
	SetAttackNext(0.0f);
	SetIdleNext(0.0f);
	Draw();

#ifdef CLIENT
	pSeat->m_iHUDWeaponSelected = GetSharedID();
	PredictPreFrame();
	HUD_SwitchedToWeapon(classname);
#endif
}

void
ncWeapon::_SwitchedFromCallback(void)
{
	//printf("Switched from %S\n", classname);
	Holster();
}

bool
ncWeapon::IsWeapon(void)
{
	return (true);
}

bool
ncWeapon::IsEmpty(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (autocvar_g_infiniteAmmo == true) {
		return (false);
	}

	if (m_fiAmmoRequired) {
		/* this weapon uses a clip/magazine */
		if (m_weaponClipSize && m_fiAmmoType == m_primaryAmmoType) {
			/* no more ammo in clip? */
			if (m_weaponClip <= 0i || (m_weaponClip - m_fiAmmoPerShot) < 0i) {
				/* possible to reload? */
				if (ourOwner.HasAmmo(m_fiAmmoType, 1) == true) {
					return (false);
				}
				return (true);
			}

		} else if (ourOwner.HasAmmo(m_fiAmmoType, m_fiAmmoPerShot) == false) {
			return (true);
		}
	}

	return (false);
}

void
ncWeapon::Draw(void)
{
	SwitchFireInfo(m_primaryFireInfo);

	float drawAnimation = -1;
	float drawTime = 0.0f;

	if (m_weaponClipSize > 0 && m_weaponClip == 0) {
		drawAnimation = GetSubDefAct(m_primaryFireInfo, "drawEmpty");
	}

	/* no empty draw anim exists */
	if (drawAnimation < 0) {
		drawAnimation = GetSubDefAct(m_primaryFireInfo, "draw");
	}

	/* no draw anim exists at all... */
	if (drawAnimation >= 0) {
		drawTime = frameduration(m_viewModel, drawAnimation);
		SetWeaponFrame(drawAnimation);
	}

#ifdef SERVER
	PlaySound(GetDefString("snd_draw"), CHAN_AUTO, false);
#endif

	SetAttackNext(drawTime);
	SetIdleNext(drawTime);

	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.viewzoom = 1.0f;
}

void
ncWeapon::Holster(void)
{
	EntLog("Holstering Weapon!");
}

void
ncWeapon::EmptySound(void)
{
#ifdef SERVER
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.StartSoundDef(m_fiSndEmpty, CHAN_WEAPON, true);
	ourOwner.gflags |= GF_SEMI_TOGGLED;
#endif
}

bool
ncWeapon::UseAmmo(string fireInfo)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (autocvar_g_infiniteAmmo == true) {
		return (true);
	}

	if (m_fiAmmoRequired) {
		/* this weapon uses a clip/magazine */
		if (m_weaponClipSize && m_fiAmmoType == m_primaryAmmoType) {
			/* no more ammo in clip? */
			if (m_weaponClip <= 0i || (m_weaponClip - m_fiAmmoPerShot) < 0i) {
				/* possible to reload? */
				if (ourOwner.HasAmmo(m_fiAmmoType, 1) == true) {
					Reload();
					return (false);
				} else { /* no, play empty sound */
					EmptySound();
					m_weaponIsFiring = false;
				}
				return (false);
			}

			m_weaponClip -= m_fiAmmoPerShot;
		} else if (ourOwner.UseAmmo(m_fiAmmoType, m_fiAmmoPerShot) == false) {
			EmptySound();
			m_weaponIsFiring = false;
			return (false);
		}
	}

	if (TestFireAbility(fireInfo) == false) {
		float failAnim = GetSubDefAct(fireInfo, "fireFailed");
		float failRate = GetSubDefFloat(fireInfo, "failRate");
		float failDuration = frameduration(m_viewModel, failAnim);

		if (!failRate) {
			failRate = failDuration;
		}

		if (failAnim >= 0) {
			SetWeaponFrame(failAnim);
		}

		if (failRate) {
			SetAttackNext(failRate);
		}
		SetIdleNext(failDuration);

#ifdef SERVER
		ourOwner.StartSoundDef(m_fiSndFailed, CHAN_WEAPON, true);
#endif

		return (false);
	}

	return (true);
}

bool
ncWeapon::DetonateDef(string defName)
{
	bool success = false;

	for ( entity b = world; ( b = find( b, ::classname, defName ) ); ) {
		if ( b.owner == owner ) {
#ifdef SERVER
			ncProjectile toDetonate = (ncProjectile)b;
			toDetonate.Trigger(owner, TRIG_TOGGLE);
#endif
			success = true;
		}
	}

	return (success);
}

void
ncWeapon::FiredWeaponAttack(string fireInfo)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.AttackByDef(fireInfo, false);
	_SetWeaponState(WEAPONSTATE_IDLE);

	/* knockback */
	{
		float weaponKnockBack = GetSubDefFloat(fireInfo, "knockback");
		ourOwner.AddVelocity(anglesToForward(ourOwner.v_angle) * -weaponKnockBack);
	}

	/* prevent release from firing it again */
	if (m_fiPowerAmmo) {
		m_fiWillRelease = false;
	}
}

void
ncWeapon::InputFrame(void)
{

}

void
ncWeapon::ReleasedWeaponAttack(string fireInfo)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	/* don't apply to projectiles without fuses */
	if (m_fiPrimedFuse <= 0) {
#ifdef SERVER
		ourOwner.m_weaponCookingTime = time;
#endif
	}

	ourOwner.AttackByDef(fireInfo, true);

	/* knockback */
	{
		float weaponKnockBack = GetSubDefFloat(fireInfo, "knockbackRelease");
		ourOwner.AddVelocity(anglesToForward(ourOwner.v_angle) * -weaponKnockBack);
	}

	_SetWeaponState(WEAPONSTATE_RELEASED);
}

void
ncWeapon::Attack(string fireInfo)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float shotAnim = -1;
	float fireRate = 1.0f;

	if (GetWeaponState() == WEAPONSTATE_RELOAD) {
		_SetWeaponState(WEAPONSTATE_RELOAD_END);
		SetIdleNext(0.0f);
		Idle();
		return;
	}

	SwitchFireInfo(fireInfo);

	if (m_fiSemiAuto == true) {
		ourOwner.gflags |= GF_SEMI_TOGGLED;
	}

	/* no real attack, detonate named satchels, pipe bombs, etc. */
	if (STRING_SET(m_fiDetonateOnFire)) {
		if (DetonateDef(m_fiDetonateOnFire) == true) {
			float detonateAct = GetSubDefAct(fireInfo, "detonate");

			if (detonateAct >= 0) {
				SetWeaponFrame(GetSubDefAct(fireInfo, "detonate"));
			}

			return;
		}
	}

	/* Remove when empty */
	if (m_fiRemoveOnEmpty == true && HasReserveAmmo() == false && m_weaponClipSize <= 0i) {
		ourOwner.RemoveItem(classname);
		return;
	}

	/* will release projectile upon release. */
	if (!(ourOwner.m_nuclideFlags & VFL_PRIMEDFUSE) && STRING_SET(m_fiOnRelease)) {
		_SetWeaponState(WEAPONSTATE_RELEASED);
		ourOwner.m_nuclideFlags |= VFL_PRIMEDFUSE;
	}

	/* "fireUnderwater" check */
	if (m_fiFireUnderwater == false && owner.waterlevel >= WATERLEVEL_SUBMERGED) {
		EmptySound();
		return;
	}

	if (IsEmpty() == true) {
		EmptySound();
		return;
	}

	/* this weapon has a delay before something shoots out. */
	if (m_fiChargeTime > 0.0f) {
		/* we haven't yet tried firing while charging */
		if (GetWeaponState() != WEAPONSTATE_CHARGING) {
			shotAnim = GetSubDefAct(fireInfo, "delay");
			SetAttackNext(m_fiChargeTime);

#ifdef SERVER
			ourOwner.m_weaponCookingTime = time;
			PlaySound(GetSubDefString(fireInfo, "snd_delay"), CHAN_WEAPON, false);
#endif

			/* mark as charging, play loop anim in Idle() next */
			SetIdleNext(frameduration(m_viewModel, shotAnim));
			SetWeaponFrame(shotAnim);
			_SetWeaponState(WEAPONSTATE_CHARGING);
			return;
		}

		if (UseAmmo(fireInfo) == false) {
			return;
		}
	} else {
		if (UseAmmo(fireInfo) == false) {
			return;
		}

#ifdef SERVER
		ourOwner.m_weaponCookingTime = time;
#endif
	}

	ourOwner.m_punchAngle += m_fiPunchAngle;
	ourOwner.m_punchVelocity += m_fiPunchSpring * 20.0f;

#ifdef SERVER
	string fireSound = m_fiSndFire;
	v_angle = input_angles;

	if (m_weaponClipSize > 0 && m_weaponClip == 0) {
		if (m_fiSndFireLast != "") {
			fireSound = m_fiSndFireLast;
		}
	}

	if (fireSound) {
		ourOwner.StartSoundDef(fireSound, CHAN_WEAPON, true);
	}
#endif

	FiredWeaponAttack(fireInfo);

	if (wasfreed(this)) {
		return;
	}

	if (m_fiLoopingFire == false) {
		if (m_weaponClipSize > 0 && m_weaponClip == 0) {
			shotAnim = GetSubDefAct(fireInfo, "fireLast");
		}

		if (shotAnim <= 0) {
			shotAnim = GetSubDefAct(fireInfo, "fire");
		}

		SetWeaponFrame(shotAnim);
		SetIdleNext(frameduration(m_viewModel, shotAnim));
	} else {
		_SetWeaponState(WEAPONSTATE_FIRELOOP);
		Idle();
	}

	/* build up heat */
	if (m_fiOverheatLength > 0.0f && m_fiOverheatPoints > 0.0f) {
		m_weaponOverheating += m_fiOverheatPoints;

#ifdef SERVER
		//printf("%f (%f)\n", m_weaponOverheating, (m_weaponOverheating / m_fiOverheatLength));
#endif

		if (m_weaponOverheating >= m_fiOverheatLength) {
			_SetWeaponState(WEAPONSTATE_OVERHEATED);
		}
	} else if (m_fiCocks) {
		_SetWeaponState(WEAPONSTATE_COCK);
	}

	float animTime = frameduration(m_viewModel, shotAnim);

	if (m_fiFireRate) {
		SetAttackNext(m_fiFireRate);
	} else {
		SetAttackNext(animTime);
	}
	SetIdleNext(animTime);

#if 0
#ifdef CLIENT
	/* dispatch brass */
	if (STRING_SET(m_fiBrassDef)) {
	//	View_AddEvent(_EjectBrass, m_fiBrassDelay);
	}

	/* dispatch muzzle */
	if (m_fiJointBarrel) {
		View_AddEvent(_EjectMuzzleFlash, 0.0f);
		pSeat->m_iEventEntity = this;
	}
#endif
#endif

	m_weaponIsFiring = true;
}

void
ncWeapon::_PrimaryAttack(void)
{
	if (!owner) {
		return;
	}

	_WeaponStartedFiring();
	PrimaryAttack();
}

void
ncWeapon::_SecondaryAttack(void)
{
	if (!owner) {
		return;
	}

	if (GetDefBool("altAlternates") == true) {
		return;
	} else {
		_WeaponStartedFiring();
		SecondaryAttack();
	}
}

void
ncWeapon::_SwitchedWeaponMode(void)
{
	float animMode = -1;

	if (m_weaponFireInfoValue) {
		animMode = GetSubDefAct(m_weaponLastFireInfo, "modeOn");
		SwitchFireInfo(m_secondaryFireInfo);
	} else {
		SwitchFireInfo(m_primaryFireInfo);
		animMode = GetSubDefAct(m_weaponLastFireInfo, "modeOff");
	}

	if (animMode >= 0) {
		SetWeaponFrame(animMode);
		SetAttackNext(frameduration(m_viewModel, animMode));
		SetIdleNext(frameduration(m_viewModel, animMode));
	}
}

void
ncWeapon::PlaySound(string soundDef, float soundChannel, bool clientOnly)
{
#ifdef CLIENT
	if (clientOnly) {
		SoundDef_Play(owner, soundChannel, soundDef);
	}
#endif

#ifdef SERVER
	if (!clientOnly) {
		SoundDef_Play(owner, soundChannel, soundDef);
	}
#endif
}

bool
ncWeapon::TestFireAbility(string fireInfo)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float fiTestDistance = GetSubDefFloat(fireInfo, "testDistance");

	if (fiTestDistance != 0.0f) {
		bool invertCheck = (fiTestDistance < 0.0) ? true : false;
		vector eyePos = ourOwner.GetEyePos();
		vector eyeAngles = ourOwner.v_angle;
		int oldhitcontents = ourOwner.hitcontentsmaski;
		vector traceStart = ourOwner.GetEyePos();

		if (invertCheck) {
			fiTestDistance = fabs(fiTestDistance);
		}

		vector traceEnd = traceStart + (anglesToForward(eyeAngles) * fiTestDistance);
		ourOwner.hitcontentsmaski = (CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE);
		traceline(traceStart, traceEnd, MOVE_NORMAL, ourOwner);
		ourOwner.hitcontentsmaski = oldhitcontents;

		if (trace_fraction >= 1.0) {
			return (invertCheck) ? false : true;
		} else {
			return (invertCheck) ? true : false;
		}
	}

	return (true);
}

void
ncWeapon::Idle(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float idleAnim = -1;

	m_weaponOverheating = max(0.0f, m_weaponOverheating - input_timelength);

	if (m_fiDepleteAmmo > 0) {
		if (CanFire() == true) {
			if (m_weaponAmmoDepleteTime < time) {
				ourOwner.UseAmmo(m_primaryAmmoType, m_fiDepleteAmmo);
				m_weaponAmmoDepleteTime = (time + m_fiDepleteRate);
			}
		}
	}

	if (CanIdle() == false) {
		return;
	}

	if (m_fiWillRelease) {
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "cooking");

		if (idleAnim >= 0) {
			SetWeaponFrame(idleAnim);
			SetIdleNext(frameduration(m_viewModel, idleAnim));
		}
		return;
	}

	/* handle shotgun style reloads */
	switch (m_weaponState) {
	case WEAPONSTATE_RELOAD_START:
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "reloadStart");
		_SetWeaponState(WEAPONSTATE_RELOAD);
#ifdef SERVER
		PlaySound(GetDefString("snd_reloadStart"), CHAN_AUTO, false);
#endif
		SetAttackNext(frameduration(m_viewModel, idleAnim));
		break;
	case WEAPONSTATE_RELOAD:
		float reloadTime;
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "reload");
		m_weaponClip++;
		ourOwner.UseAmmo(m_primaryAmmoType, 1);

		if (HasReserveAmmo() == false || m_weaponClip >= m_weaponClipSize) {
			_SetWeaponState(WEAPONSTATE_RELOAD_END);
		}

		if (m_fiReloadTime == -1.0f) {
			reloadTime = frameduration(m_viewModel, idleAnim);
		} else {
			reloadTime = m_fiReloadTime;
		}
#ifdef SERVER
		PlaySound(GetDefString("snd_reload"), CHAN_AUTO, false);
#endif
		SetWeaponFrame(idleAnim);
		SetIdleNext(reloadTime);
		/* SetAttackNext(reloadTime); */ /* people like instant feedback, hence commented out */
		return;
		break;
	case WEAPONSTATE_RELOAD_END:
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "reloadEnd");
		_SetWeaponState(WEAPONSTATE_IDLE);
#ifdef SERVER
		PlaySound(GetDefString("snd_reloadEnd"), CHAN_AUTO, false);
#endif
		SetAttackNext(frameduration(m_viewModel, idleAnim));
		break;
	case WEAPONSTATE_FIRELOOP:
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "loop");
		break;
	case WEAPONSTATE_CHARGING:
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "loop");
		break;
	case WEAPONSTATE_COCK:
		//breakpoint();
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "cock");
#ifdef SERVER
		PlaySound(GetDefString("snd_cock"), CHAN_AUTO, false);
#endif
		_SetWeaponState(WEAPONSTATE_IDLE);
		SetAttackNext(frameduration(m_viewModel, idleAnim));
		break;
	case WEAPONSTATE_RELEASED:
		//breakpoint();

		if (STRING_SET(m_fiSndRelease)) {
			ourOwner.StartSoundDef(m_fiSndRelease, CHAN_WEAPON, true);
		}

		if (STRING_SET(m_fiOnRelease)) {
			UseAmmo(m_weaponLastFireInfo);
		}

		ReleasedWeaponAttack(m_weaponLastFireInfo);
		ourOwner.m_nuclideFlags &= ~VFL_PRIMEDFUSE;
		idleAnim = GetSubDefAct(m_weaponLastFireInfo, "release");
		SetAttackNext(frameduration(m_viewModel, idleAnim));

		if (m_fiDrawAfterRelease == true) {
			_SetWeaponState(WEAPONSTATE_DRAW);
		} else {
			_SetWeaponState(WEAPONSTATE_IDLE);
		}
		break;
	case WEAPONSTATE_DRAW:
		Draw();
		_SetWeaponState(WEAPONSTATE_IDLE);
		return;
	case WEAPONSTATE_OVERHEATED:
		/* prevent fire for the next N seconds */
		_SetWeaponState(WEAPONSTATE_IDLE);
		SetAttackNext(m_fiOverheatLength);
		SetReloadNext(0.1f);
		/* prevent anything else. */
		return;
	case WEAPONSTATE_IDLE:
	default:
		if (m_weaponClipSize > 0 && m_weaponClip == 0) {
			idleAnim = GetSubDefAct(m_weaponLastFireInfo, "idleEmpty");

			/* TODO: may want this? hard to say. */
			/*if (idleAnim < 0) {
				SetIdleNext(5.0f);
				return;
			}*/
		}

		if (idleAnim < 0) {
			idleAnim = GetSubDefAct(m_weaponLastFireInfo, "idle");
		}
	}

	/* no anim, so delay it by a bit more so we don't constantly query decl */
	if (idleAnim < 0) {
		SetIdleNext(5.0f);
		return;
	}

	SetWeaponFrame(idleAnim);

	float nextIdle = frameduration(m_viewModel, idleAnim);

	/* not a valid idle length to begin with. pad it */
	if (nextIdle <= 0.0f) {
		SetIdleNext(10.0f);
	} else {
		SetIdleNext(frameduration(m_viewModel, idleAnim));
	}
}

void
ncWeapon::PrimaryAttack(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (CanFire() == false) {
		if (!(ourOwner.gflags & GF_SEMI_TOGGLED)) {
			Idle();
			return;
		}

		if (m_fiLoopingFire) {
			Release();
		} else {
			Idle();
		}

		return;
	}

	if (m_fiAltModeSwitch == true) {
		if (CanFire() == false) {
			return;
		}
	}

	if (GetDefBool("altAlternates") == true) {
		m_weaponFireInfoValue = 1 - m_weaponFireInfoValue;
	}

	if (m_weaponFireInfoValue) {
		Attack(m_secondaryFireInfo);
		return;
	}

	Attack(m_primaryFireInfo);
}

void
ncWeapon::SecondaryAttack(void)
{
	float shotAnim = 0;
	ncPlayer ourOwner;
	float fireRate = 0.0f;

	/* zoom takes priority */
	if (m_fiZoomFOV > 0.0f) {
		if (CanFire() == false) {
			return;
		}

		ourOwner = (ncPlayer)GetOwner();

#ifdef SERVER
		if (ourOwner.viewzoom == 1.0) {
			PlaySound(GetDefString("snd_lowerScope"), CHAN_AUTO, false);
			SetViewZoom(m_fiZoomFOV);
		} else {
			PlaySound(GetDefString("snd_raiseScope"), CHAN_AUTO, false);
			SetViewZoom(1.0f);
		}
#endif

		ourOwner.gflags |= GF_SEMI_TOGGLED;
		return;
	} else if (m_fiAltModeSwitch == true) {
		if (CanFire() == false) {
			Idle();
			return;
		}

		m_weaponFireInfoValue = 1 - m_weaponFireInfoValue;

#ifdef SERVER
		if (m_weaponFireInfoValue) {
			PlaySound(GetDefString("snd_modeOn"), CHAN_AUTO, false);
		} else {
			PlaySound(GetDefString("snd_modeOff"), CHAN_AUTO, false);
		}
#endif

		SetAttackNext(1.0);
		SetIdleNext(1.0f);
		_SwitchedWeaponMode();
		return;
	}


	/* no fire info? don't even bother then */
	if (!STRING_SET(m_secondaryFireInfo)) {
		Release();
		return;
	}

	/* don't run any further logic */
	if (CanFire() == false) {
		Idle();
		return;
	}

	Attack(m_secondaryFireInfo);
}

#ifdef SERVER
void
ncWeapon::_ReloadFinished(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	int ammoToDeduct;

	ammoToDeduct = m_weaponClipSize - m_weaponClip;

	/* not enough ammo. assign whatever is left. */
	if (ourOwner.HasAmmo(m_primaryAmmoType, ammoToDeduct) == false) {
		ammoToDeduct = ourOwner.m_ammoTypes[m_primaryAmmoType];
		m_weaponClip += ammoToDeduct;
	} else {
		m_weaponClip = m_weaponClipSize;
	}

	ourOwner.UseAmmo(m_primaryAmmoType, ammoToDeduct);
}
#endif

void
ncWeapon::Reload(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	float reloadAnimation = -1;
	float reloadEndAnimation = -1;
	float reloadTime;
	string ammoType;
	int ammoTypeID;
	float reloadStartAct = -1;

	/* already in a reload? */
	if (m_weaponState >= WEAPONSTATE_RELOAD_START && m_weaponState <= WEAPONSTATE_RELOAD_END) {
		return;
	}
	reloadStartAct = GetSubDefAct(m_weaponLastFireInfo, "reloadStart");

	/* we cannot reload this weapon by principle. */
	if (!m_weaponClipSize) {
		return;
	}

	if (CanReload() == false) {
		Idle();
		return;
	}

	/* NOTE: this affects our clip, so primary fireInfo only */
	ammoType = GetSubDefString(m_primaryFireInfo, "ammoType");
	ammoTypeID = ammoNumForName(ammoType);

	if (m_weaponClip == m_weaponClipSize) {
		Idle();
		return;
	}

	/* no leftover ammo at all. */
	if (ourOwner.HasAmmo(ammoTypeID, 1) == false) {
		return;
	}

	/* we have a start-reload, so this is a shotgun styled weapon reload */
	if (reloadStartAct >= 0) {
		_SetWeaponState(WEAPONSTATE_RELOAD_START);
		SetIdleNext(0.0);
		Release();
		return;
	}

	if (m_weaponClipSize > 0 && m_weaponClip == 0) {
		reloadAnimation = GetSubDefAct(m_weaponLastFireInfo, "reloadEmpty");
	}

	if (reloadAnimation < 0) {
		reloadAnimation = GetSubDefAct(m_weaponLastFireInfo, "reload");

		/* check if we should schedule a reload-end */
		if (GetSubDefAct(m_weaponLastFireInfo, "reloadEnd") >= 0) {
			_SetWeaponState(WEAPONSTATE_RELOAD_END);
		}
	}

	if (m_fiReloadTime == -1.0f) {
		reloadTime = frameduration(m_viewModel, reloadAnimation);
	} else {
		reloadTime = m_fiReloadTime;
	}

#ifdef SERVER
	string reloadSound = GetDefString("snd_reload");

	if (m_weaponClipSize > 0 && m_weaponClip == 0) {
		string emptyReload = GetDefString("snd_reloadEmpty");

		if (emptyReload != "") {
			reloadSound = emptyReload;
		}
	}

	ourOwner.StartSoundDef(reloadSound, CHAN_AUTO, true);
	ScheduleThink(_ReloadFinished, reloadTime - 0.1f);
#endif

	SetWeaponFrame(reloadAnimation);
	SetAttackNext(reloadTime - 0.01);
	SetIdleNext(reloadTime);
}

bool
ncWeapon::HasReserveAmmo(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	string ammoType1 = GetSubDefString(m_primaryFireInfo, "ammoType");
	int ammoTypeID1 = ammoNumForName(ammoType1);

	if (ourOwner.HasAmmo(ammoTypeID1, 1)) {
		return (true);
	}

	string ammoType2 = GetSubDefString(m_secondaryFireInfo, "ammoType");
	int ammoTypeID2 = ammoNumForName(ammoType2);

	if (ourOwner.HasAmmo(ammoTypeID2, 1)) {
		return (true);
	}

	return (false);
}

void
ncWeapon::_WeaponStartedFiring(void)
{
	if (CanFire() == false) {
		return;
	}

	/* hasn't been fired yet. */
	if (!(owner.m_nuclideFlags & VFL_FIRING)) {
		float actFireStart = GetSubDefAct(m_weaponLastFireInfo, "fireStart");

		/* we may be supposed to be looping */
		if (m_fiLoopingFire) {
			_SetWeaponState(WEAPONSTATE_FIRELOOP);
			SetIdleNext(0.0); /* to be potentially overriden by actFireStart! */
		}

		/* if we got a 'start firing' animation play it */
		if (actFireStart >= 0) {
			SetWeaponFrame(actFireStart);
			SetAttackNext(frameduration(m_viewModel, actFireStart));
			SetIdleNext(frameduration(m_viewModel, actFireStart));
		}


#ifdef SERVER
		ncPlayer ourOwner = (ncPlayer)GetOwner();

		if (m_fiSndFireStart) {
			ourOwner.StartSoundDef(m_fiSndFireStart, CHAN_WEAPON, true);
		}

		if (m_fiSndFireLoop) {
			ourOwner.StartSoundDef(m_fiSndFireLoop, CHAN_LOOP, true);
		}

		//printf("actFireStart %d %S\n", actFireStart, m_weaponLastFireInfo);
#endif

		WeaponStartedFiring();
	}

	owner.m_nuclideFlags |= VFL_FIRING;
}

void
ncWeapon::_WeaponStoppedFiring(void)
{
	if (m_fiLoopingFire == false) {
		if (CanFire() == false) {
			return;
		}
	}

	/* was still registed as firing */
	if (WeaponIsFiring() == true) {
		ncPlayer ourOwner = (ncPlayer)GetOwner();
		float actFireStop = GetSubDefAct(m_weaponLastFireInfo, "fireStop");

		if (actFireStop >= 0) {
			SetWeaponFrame(actFireStop);
			SetAttackNext(frameduration(m_viewModel, actFireStop));
			SetIdleNext(frameduration(m_viewModel, actFireStop));
		}

		/* only go through the 'released' arc if we were either looping or got something to release? */
		if (m_fiLoopingFire || actFireStop >= 0) {
			_SetWeaponState(WEAPONSTATE_RELEASED);
		}

		WeaponStoppedFiring();

		/* Remove when empty, but not when we're supposed to be detonating on fire */
		if (!STRING_SET(m_fiDetonateOnFire) && m_fiRemoveOnEmpty && HasReserveAmmo() == false && m_weaponClipSize <= 0i) {
			ourOwner.RemoveItem(classname);
			return;
		}
	}

	owner.m_nuclideFlags &= ~VFL_FIRING;
}

bool
ncWeapon::WeaponIsFiring(void)
{
	return (owner.m_nuclideFlags & VFL_FIRING) ? (true) : (false);
}

void
ncWeapon::WeaponStartedFiring(void)
{
}

void
ncWeapon::WeaponStoppedFiring(void)
{
}

float
ncWeapon::PlayerSpeedMod(void)
{
	return (m_fiSpeedMod);
}

float
ncWeapon::OverheatingProgress(void)
{
	return (m_weaponOverheating);
}

int
ncWeapon::GetClip(void)
{
	return (m_weaponClip);
}

int
ncWeapon::GetClipSize(void)
{
	return (m_weaponClipSize);
}

bool
ncWeapon::RequiresAmmo(void)
{
	return (m_weaponRequiresAmmo);
}

int
ncWeapon::FireInfoSelected(void)
{
	return (m_weaponFireInfoValue);
}

void
ncWeapon::Release(void)
{
	float idleAnim = -1;
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.gflags &= ~GF_SEMI_TOGGLED;

	if (m_fiRegenAmmo > 0) {
		if (m_weaponAmmoRegenTime < time) {
			ourOwner.GiveAmmo(m_primaryAmmoType, m_fiRegenAmmo);
			m_weaponAmmoRegenTime = (time + m_fiRegenRate);
		}
	}

	/* we're allowed to release any time. allow it! */
	if (ourOwner.m_nuclideFlags & VFL_PRIMEDFUSE) {
		_SetWeaponState(WEAPONSTATE_RELEASED);
		SetIdleNext(0.0f);
	}

	if (GetWeaponState() == WEAPONSTATE_CHARGING) {
		if (CanFire() == true) {
			/* hack to get around the ammo usage when charging */
			float oldChargeTime = m_fiChargeTime;
			m_fiChargeTime = 0.0f;
			Attack(m_weaponLastFireInfo);
			m_fiChargeTime = oldChargeTime;
			return;
		}
	}

#if 0
	/* already in a reload? */
	if (!(m_weaponState >= WEAPONSTATE_RELOAD_START && m_weaponState <= WEAPONSTATE_RELOAD_END)) {
		_SetWeaponState(WEAPONSTATE_IDLE);
	}
#endif

#ifdef SERVER
	if (WeaponIsFiring() == true) {

		if (m_fiSndFireStop) {
			ourOwner.StartSoundDef(m_fiSndFireStop, CHAN_WEAPON, true);
		}

		ourOwner.StopSound(CHAN_LOOP, true);
	}
#endif

	m_weaponIsFiring = false;

	Idle();
}

void
ncWeapon::UpdateGUI(void)
{
#ifdef CLIENT
	ncPlayer ourOwner = __NULL__;
	static float baseIconSize = 32.0f;
	static float baseIconPadding = 16.0f;

	if (RequiresAmmo() == false) {
		return;
	}

	ourOwner = (ncPlayer)GetOwner();

	vector hudSize = g_view.GetHUDCanvasSize();
	vector iconPos = g_view.GetHUDCanvasPos() + (hudSize / 2);
	iconPos[0] = (hudSize[0] - baseIconSize) - baseIconPadding;
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;
	drawpic(iconPos, "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f);

	iconPos[0] -= baseIconSize + baseIconPadding;
	Font_DrawRText(iconPos, itos(ourOwner.GetReserveAmmo(m_primaryAmmoType)), FONT_16);

	iconPos[0] -= baseIconSize + baseIconPadding;

	if (m_weaponClipSize > 0i) {
		Font_DrawRText(iconPos, itos(m_weaponClip), FONT_16);
	}
#endif
}

void
ncWeapon::SetViewModel(string modelPath)
{
	if (!modelPath) {
		return;
	}

	m_viewModel = getmodelindex(modelPath, true);

	if (m_viewModel == 0) {
		EntError("%s was not precached.", modelPath);
	}
}

void
ncWeapon::SetWorldModel(string modelPath)
{
	if (!modelPath) {
		return;
	}

	m_worldModel = getmodelindex(modelPath, true);

	if (m_worldModel == 0) {
		EntError("%s was not precached.", modelPath);
	}
}

void
ncWeapon::SetPlayerModel(string modelPath)
{
	if (!modelPath) {
		return;
	}

	m_playerModel = getmodelindex(modelPath, true);

	if (m_playerModel == 0) {
		EntError("%s was not precached.", modelPath);
	}
}

void
ncWeapon::SetWeaponFrame(float newSequence)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner) {
		ourOwner.m_weaponAnimSequence = newSequence;
		ourOwner.m_weaponAnimTime = 0.0f;
	}
}

void
ncWeapon::SetAttackNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	ourOwner.m_timeUntilNextAttack = newDelay;
	SetReloadNext(newDelay);
}

void
ncWeapon::SetReloadNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	ourOwner.m_timeUntilReloaded = newDelay;
}

void
ncWeapon::SetIdleNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	/* HACK: RT2 requires this as their anims have junk at the end :/ */
	if (m_fiBuggyIdleAnim == true)
		ourOwner.m_timeUntilNextIdle = bound(0.0, newDelay - 0.05f, newDelay);
	else
		ourOwner.m_timeUntilNextIdle = newDelay;
}

bool
ncWeapon::CanIdle(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner.m_timeUntilNextIdle > 0.0f) {
		return (false);
	}

	return (true);
}

bool
ncWeapon::CanFire(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner.m_timeUntilNextAttack > 0.0f) {
		return (false);
	}

	/* sanity check */
	if (GetWeaponState() == WEAPONSTATE_OVERHEATED) {
		return (false);
	}

	if (ourOwner.gflags & GF_SEMI_TOGGLED) {
		return (false);
	}

	return (true);
}

bool
ncWeapon::CanReload(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner.m_timeUntilReloaded > 0.0f) {
		return (false);
	}

	return (true);
}

ncWeapon
ncWeapon::GetNextWeapon(void)
{
	return (m_nextWeapon);
}

ncWeapon
ncWeapon::GetPreviousWeapon(void)
{
	return (m_prevWeapon);
}

bool
ncWeapon::UsesSecondaryAmmo(void)
{
	return (m_secondaryAmmoType && m_primaryAmmoType != m_secondaryAmmoType) ? (true) : (false);
}
