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
	m_iClipStartSize = 0i;
	m_bRemoveOnEmpty = false;
	m_strWeaponViewModel = __NULL__;
	m_strWeaponPlayerModel = __NULL__;
	m_strWeaponScript = __NULL__;
	m_strAmmoType = __NULL__;
	m_bAmmoRequired = false;
	m_strFlashShader = __NULL__;
	m_strFlashModel = __NULL__;
	m_vecFlashColor = g_vec_null;
	m_flFlashRadius = 0.0f;
	m_strDropItemDef = __NULL__;
	m_strSmokeParticle = __NULL__;
	m_bSmokeContinous = false;
	m_iClip = 0i;
	m_iClipSize = 0i;
	m_iMode = 0;
	m_viewModel = 0;
	m_worldModel = 0;
	m_playerModel = 0.0f;
	m_flFireRate = 1.0f;
	m_dState = 0;
	m_strLastFireInfo = __NULL__;
	m_flSpeedMod = 1.0f;
	m_flReloadSpeed = -1.0f;
	m_nextWeapon = __NULL__;
	m_prevWeapon = __NULL__;
	m_fireUnderwater = true;
}

void
ncWeapon::_AddedCallback(void)
{
	ncActor ourOwner = (ncActor)owner;
	super::_AddedCallback();

	if (!owner) {
		return;
	}

	_CacheWeaponDefVariables();

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
	if (m_dState == newState) {
		return;
	}

	m_dState = newState;

#ifdef SERVER
	//printf("State changed to %s\n", nsweapon_state_s[newState]);
#endif
}

nsweapon_state_t
ncWeapon::GetWeaponState(void)
{
	return (m_dState);
}

void
ncWeapon::UpdateFireInfoCache(void)
{
	string ammoPerShot = GetSubDefString(m_strLastFireInfo, "ammoPerShot");
	string reloadSpeed = GetSubDefString(m_strLastFireInfo, "reloadTime");
	m_fiDetonateOnFire = GetSubDefString(m_strLastFireInfo, "detonateOnFire");
	m_fiPunchAngle = GetSubDefVector(m_strLastFireInfo, "punchAngle");
	m_fiPunchSpring = GetSubDefVector(m_strLastFireInfo, "punchSpring");
	m_fiSndFire = GetSubDefString(m_strLastFireInfo, "snd_fire");
	m_fiSndFailed = GetSubDefString(m_strLastFireInfo, "snd_fireFailed");
	m_fiSndFireLast = GetSubDefString(m_strLastFireInfo, "snd_fireLast");
	m_fiSndRelease = GetSubDefString(m_strLastFireInfo, "snd_release");
	m_fiSndEmpty = GetSubDefString(m_strLastFireInfo, "snd_empty");
	m_fiAmmoType = ammoNumForName(GetSubDefString(m_strLastFireInfo, "ammoType"));
	m_fiAmmoRequired = GetSubDefBool(m_strLastFireInfo, "ammoRequired");
	m_fiFireRate = GetSubDefFloat(m_strLastFireInfo, "fireRate");
	m_fiSemiAuto = GetSubDefBool(m_strLastFireInfo, "semiAuto");

	/* defs to spawn */
	m_fiOnFire = GetSubDefString(m_strLastFireInfo, "def_onFire");
	m_fiOnRelease = GetSubDefString(m_strLastFireInfo, "def_onRelease");
	m_fiChargeTime = GetSubDefFloat(m_strLastFireInfo, "chargeTime");

	m_fiOverheatPoints = GetSubDefFloat(m_strLastFireInfo, "overheatPerShot");

	m_fiSndFireStart = GetSubDefString(m_strLastFireInfo, "snd_fireStart");
	m_fiSndFireStop = GetSubDefString(m_strLastFireInfo, "snd_fireStop");
	m_fiSndFireLoop = GetSubDefString(m_strLastFireInfo, "snd_fireLoop");
	m_fireUnderwater = GetSubDefBool(m_strLastFireInfo, "fireUnderwater");

	/* firing cosmetics */
#ifdef CLIENT
	setmodel(pSeat->m_eViewModel, GetSubDefString(m_strLastFireInfo, "model_view"));
	pSeat->m_eViewModel.declclass = declclass;
	m_fiJointMuzzle = gettagindex(pSeat->m_eViewModel, GetSubDefString(m_strLastFireInfo, "muzzle"));
	m_fiJointBarrel = gettagindex(pSeat->m_eViewModel, GetSubDefString(m_strLastFireInfo, "barrel"));

// 	printf("%S %S %d\n", pSeat->m_eViewModel.model, GetSubDefString(m_strLastFireInfo, "barrel"), m_fiJointBarrel);
#endif

	m_fiBrassDef = GetSubDefString(m_strLastFireInfo, "def_ejectBrass");
	m_fiBrassDelay = GetSubDefFloat(m_strLastFireInfo, "ejectBrassDelay");

	/* only check if it's present. */
	m_bHasLoop = GetSubDefBool(m_strLastFireInfo, "act_loop");
	m_fiCocks = GetSubDefBool(m_strLastFireInfo, "cocks");
	m_fiDrawAfterRelease = GetSubDefBool(m_strLastFireInfo, "drawAfterRelease");

	/* keep the last valid value (don't 0.0f it) to prevent overlay dropouts. */
	if (m_fiOverheatPoints) {
		m_fiOverheatLength = GetSubDefFloat(m_strLastFireInfo, "overheatLength");
	}

	/* when -1.0 we'll pull it from the animation. */
	if (reloadSpeed != "") {
		m_flReloadSpeed = stof(reloadSpeed);
	} else {
		m_flReloadSpeed = -1.0f;
	}

#ifdef CLIENT
	if (pSeat != __NULL__) {
		string viewGeomset = GetSubDefString(m_strLastFireInfo, "view_geomset");
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
	NSError("Switched FireInfo to %S", m_strLastFireInfo);
	NSError("m_fiAmmoType: %i", m_fiAmmoRequired);
	NSError("m_fiAmmoRequired: %d", m_fiAmmoRequired);
	NSError("m_fiFireRate: %f", m_fiAmmoRequired);
	NSError("m_flReloadSpeed: %f", m_flReloadSpeed);
#endif

	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float zoomFov = GetSubDefFloat(m_strLastFireInfo, "zoomFov");

	if (zoomFov > 0) {
		ourOwner.viewzoom = zoomFov / cvar("fov");
	} else {
		ourOwner.viewzoom = 1.0f;
	}

	/* validate */
	if (ammoPerShot != __NULL__) {
		m_fiAmmoPerShot = (int)stoi(ammoPerShot);
	} else {
		m_fiAmmoPerShot = 1i;
	}
}

void
ncWeapon::SwitchFireInfo(string newInfo)
{
	/* nothing changed. */
	if (m_strLastFireInfo == newInfo) {
		return;
	}

	m_strLastFireInfo = newInfo;
	UpdateFireInfoCache();
}

#ifdef SERVER
void
ncWeapon::Spawned(void)
{
	super::Spawned();

	if (m_iClipStartSize > 0i) {
		m_iClip = m_iClipStartSize;
	} else {
		m_iClip = m_iClipSize;
	}

	m_bInvCarry = true;
	precache_model(m_strWeaponViewModel);
	precache_model(m_strWeaponPlayerModel);

	SetViewModel(m_strWeaponViewModel);
	SetWorldModel(model);
	SetPlayerModel(m_strWeaponPlayerModel);
	_isWeapon = true;
}

void
ncWeapon::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "model_view":
		m_strWeaponViewModel = ReadString(setValue);
		break;
	case "model_world":
		model = ReadString(setValue);
		break;
	case "model_player":
		m_strWeaponPlayerModel = ReadString(setValue);
		break;
	case "weapon_scriptobject":
		m_strWeaponScript = ReadString(setValue);
		break;
	case "ammoType":
		m_strAmmoType = ReadString(setValue);
		break;
	case "clipSize":
		m_iClipSize = ReadInt(setValue);
		break;
	case "clipSizeDefault":
		m_iClipStartSize = ReadInt(setValue);
		break;
	case "mtr_flashShader":
		m_strFlashShader = ReadString(setValue);
		break;
	case "model_flash":
		m_strFlashModel = ReadString(setValue);
		break;
	case "flashColor":
		m_vecFlashColor = ReadVector(setValue);
		break;
	case "flashRadius":
		m_flFlashRadius = ReadFloat(setValue);
		break;
	case "def_dropItem":
		m_strDropItemDef = ReadString(setValue);
		break;
	case "snd_hum":
		m_sndHum = ReadString(setValue);
		break;
	case "continuousSmoke":
		m_bSmokeContinous = ReadBool(setValue);
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

	/* weapon */
	SaveString(handle, "m_strWeaponViewModel", m_strWeaponViewModel);
	SaveString(handle, "m_strWeaponPlayerModel", m_strWeaponPlayerModel);
	SaveString(handle, "m_strWeaponScript", m_strWeaponScript);
	SaveString(handle, "m_strAmmoType", m_strAmmoType);
	SaveInt(handle, "m_iClipSize", m_iClipSize);
	SaveInt(handle, "m_iClipStartSize", m_iClipStartSize);
	SaveInt(handle, "m_iMode", m_iMode);
	SaveString(handle, "m_strFlashShader", m_strFlashShader);
	SaveString(handle, "m_strFlashModel", m_strFlashModel);
	SaveVector(handle, "m_vecFlashColor", m_vecFlashColor);
	SaveFloat(handle, "m_flFlashRadius", m_flFlashRadius);
	SaveString(handle, "m_strDropItemDef", m_strDropItemDef);
	SaveString(handle, "m_strSmokeParticle", m_strSmokeParticle);
	SaveBool(handle, "m_bSmokeContinous", m_bSmokeContinous);
}

void
ncWeapon::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strWeaponViewModel":
		m_strWeaponViewModel = ReadString(strValue);
		break;
	case "m_strWeaponPlayerModel":
		m_strWeaponPlayerModel = ReadString(strValue);
		break;
	case "m_strWeaponScript":
		m_strWeaponScript = ReadString(strValue);
		break;
	case "m_strAmmoType":
		m_strAmmoType = ReadString(strValue);
		break;
	case "m_iClipSize":
		m_iClipSize = ReadInt(strValue);
		break;
	case "m_iClipStartSize":
		m_iClipStartSize = ReadInt(strValue);
		break;
	case "m_iMode":
		m_iMode = ReadFloat(strValue);
		break;
	case "m_strFlashShader":
		m_strFlashShader = ReadString(strValue);
		break;
	case "m_strFlashModel":
		m_strFlashModel = ReadString(strValue);
		break;
	case "m_vecFlashColor":
		m_vecFlashColor = ReadVector(strValue);
		break;
	case "m_flFlashRadius":
		m_flFlashRadius = ReadFloat(strValue);
		break;
	case "m_strDropItemDef":
		m_strDropItemDef = ReadString(strValue);
		break;
	case "m_strSmokeParticle":
		m_strSmokeParticle = ReadString(strValue);
		break;
	case "m_bSmokeContinous":
		m_bSmokeContinous = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

/* Make sure StartFrame calls this */
float
ncWeapon::SendEntity(entity ePEnt, float flChanged)
{
	/* item is in somebody elses inventory. */
	if (InInventory() == true && ePEnt != GetOwner()) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_WEAPON);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)
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
	SENDENTITY_INT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(m_flFireRate, WEAPONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_INT(vv_flags, WEAPONFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], WEAPONFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, WEAPONFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, WEAPONFL_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, WEAPONFL_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_iBody, WEAPONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, WEAPONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iClip, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_iClipSize, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_iMode, WEAPONFL_CHANGED_CLIP)
	SENDENTITY_BYTE(m_dState, WEAPONFL_CHANGED_STATE)
	SENDENTITY_BYTE(m_bFiring, WEAPONFL_CHANGED_STATE)
	SENDENTITY_FLOAT(m_flOverheating, WEAPONFL_CHANGED_STATE)
	return (1);
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
	EVALUATE_FIELD(m_flFireRate, WEAPONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, WEAPONFL_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(modelflags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(vv_flags, WEAPONFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, WEAPONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, WEAPONFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, WEAPONFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, WEAPONFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, WEAPONFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, WEAPONFL_CHANGED_BODY)
	EVALUATE_FIELD(scale, WEAPONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, WEAPONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iClip, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_iClipSize, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_iMode, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_dState, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_bFiring, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_flOverheating, WEAPONFL_CHANGED_STATE)
}
#endif

#ifdef CLIENT
void
ncWeapon::HandleAnimEvent(float timeStamp, int eventCode, string dataString)
{
	switch (eventCode) {
	case 5000:
		string muzzModel = GetSubDefString(m_strLastFireInfo, "model_flash");
		string partSmoke = GetSubDefString(m_strLastFireInfo, "smoke_muzzle");
		vector muzzOffset = GetSubDefVector(m_strLastFireInfo, "muzzleOffset");
		vector muzzlePos = g_vec_null;

		if (m_fiJointBarrel > 0) {
			muzzlePos = gettaginfo(pSeat->m_eViewModel, m_fiJointBarrel);
		} else {
			vector muzzOfs = GetSubDefVector(m_strLastFireInfo, "muzzleRelativeOffset");
			vector camPos = pSeat->m_eViewModel.origin;

			muzzlePos = camPos + anglesToForward(pSeat->m_eViewModel.angles) * muzzOfs[0];
			muzzlePos += anglesToRight(pSeat->m_eViewModel.angles) * muzzOfs[1];
			muzzlePos += anglesToUp(pSeat->m_eViewModel.angles) * muzzOfs[2];
		}


		muzzlePos += anglesToForward(pSeat->m_eViewModel.angles) * muzzOffset[0];
		muzzlePos += anglesToRight(pSeat->m_eViewModel.angles) * muzzOffset[1];
		muzzlePos += anglesToUp(pSeat->m_eViewModel.angles) * muzzOffset[2];

		if (STRING_SET(muzzModel)) {
			EV_MuzzleFlash_CreateAtPos(pSeat->m_eViewModel, muzzlePos, 1.0, getmodelindex(muzzModel));
		}

		if (STRING_SET(partSmoke)) {
			setproperty(VF_ANGLES,g_view.GetCameraAngle());
			setproperty(VF_ORIGIN, g_view.GetCameraOrigin());
			pointparticles(particleeffectnum(partSmoke), muzzlePos, g_vec_null, 1);
		}
		break;
	default:
		super::HandleAnimEvent(timeStamp, eventCode, dataString);
	}
}

void
ncWeapon::ClientFX(bool isThirdperson)
{
	if (m_bFiring == false) {
		return;
	}

	vector src;
	vector endpos;
	ncActor pl = (ncActor)owner;

	if (isThirdperson == true) {
		src = pl.GetEyePos();
		endpos = src + (anglesToForward(pl.GetViewAngle()) * 1024.0f);
		traceline(src, endpos, MOVE_NORMAL, pl);
		trailparticles(m_fxTrail, pl, gettaginfo(this, m_jointTrailWorld), trace_endpos);
	} else {
		vector gunpos = gettaginfo(pSeat->m_eViewModel, m_jointTrailView);
		src = g_view.GetCameraOrigin();
		endpos = src + (anglesToForward(g_view.GetCameraAngle()) * 1024.0f);
		traceline(src, endpos, MOVE_NORMAL, pl);
		trailparticles(m_fxTrail, pl, gunpos, trace_endpos);
	}
}

void
ncWeapon::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)
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
	READENTITY_INT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_FLOAT(m_flFireRate, WEAPONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(modelflags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_INT(vv_flags, WEAPONFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], WEAPONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], WEAPONFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, WEAPONFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, WEAPONFL_CHANGED_SKIN)
	READENTITY_FLOAT(effects, WEAPONFL_CHANGED_EFFECTS)
	READENTITY_SHORT(m_iBody, WEAPONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, WEAPONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iClip, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_iClipSize, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_iMode, WEAPONFL_CHANGED_CLIP)
	READENTITY_BYTE(m_dState, WEAPONFL_CHANGED_STATE)
	READENTITY_BYTE(m_bFiring, WEAPONFL_CHANGED_STATE)
	READENTITY_FLOAT(m_flOverheating, WEAPONFL_CHANGED_STATE)

	/* weapon view model update */
	ncActor ourOwner = (ncActor)findfloat(world, ::entnum, owner_entnum);

	if (ourOwner.m_activeWeapon == this) {
		UpdateViewmodel();
	}

	if (flChanged & WEAPONFL_CHANGED_MODELINDEX) {
		classname = EntityDef_NameFromNetID(entityDefID);
		declclass = classname;
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
	SAVE_STATE(m_flFireRate)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(flags)
	SAVE_STATE(vv_flags)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
//	SAVE_STATE(frame)
//	SAVE_STATE(skin)
//	SAVE_STATE(effects)
	SAVE_STATE(m_iBody)
	SAVE_STATE(scale)
	SAVE_STATE(velocity)
	SAVE_STATE(avelocity)
	SAVE_STATE(m_iClip)
	SAVE_STATE(m_iClipSize)
	SAVE_STATE(m_iMode)
	SAVE_STATE(m_dState)
	SAVE_STATE(m_bFiring)
	SAVE_STATE(m_flOverheating)
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
	ROLL_BACK(m_flFireRate)
	ROLL_BACK(solid)
	ROLL_BACK(movetype)
	ROLL_BACK(flags)
	ROLL_BACK(vv_flags)
	ROLL_BACK(mins)
	ROLL_BACK(maxs)
//	ROLL_BACK(frame)
//	ROLL_BACK(skin)
//	ROLL_BACK(effects)
	ROLL_BACK(m_iBody)
	ROLL_BACK(scale)
	ROLL_BACK(velocity)
	ROLL_BACK(avelocity)
	ROLL_BACK(m_iClip)
	ROLL_BACK(m_iClipSize)
	ROLL_BACK(m_iMode)
	ROLL_BACK(m_dState)
	ROLL_BACK(m_bFiring)
	ROLL_BACK(m_flOverheating)
}

#endif

void
ncWeapon::_CacheWeaponDefVariables(void)
{
	string firstType, secondType;
	string muzzleModel;
	string ammoRequired;

	m_strWeaponTitle = GetDefString("inv_name");
	m_iHudSlot = GetDefInt("hudSlot");
	m_iHudSlotPos = GetDefInt("hudSlotPos");

	/* movement vars */
	m_flSpeedMod = GetDefFloat("speed_mod");
	m_bBuggyIdleAnim = GetDefBool("buggyIdleAnim");

	if (m_flSpeedMod <= 0.0) {
		m_flSpeedMod = 1.0f;
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
	m_bAmmoRequired = stof(ammoRequired);
	m_primaryAmmoType = ammoNumForName(firstType);
	muzzleModel = GetSubDefString(m_primaryFireInfo, "model_flash");
	m_muzzleModelIndex = getmodelindex(muzzleModel, false);
	m_flPrimedFuse = GetDefFloat("primed_fuse");
	m_flZoomFOV = GetDefFloat("zoomFov") / 90;
	m_bPowerAmmo = GetDefBool("powerAmmo");
	m_bRemoveOnEmpty = GetDefBool("removeOnEmpty");
	m_fxTrail = particleeffectnum(GetDefString("fx_trail"));
	m_viewModel = getmodelindex(GetDefString("model_view"));
	m_worldModel = getmodelindex(GetDefString("model"));
	m_bAltModeSwitch = GetDefBool("altMode");

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
	muzzleModel = GetSubDefString(m_secondaryFireInfo, "model_flash");
	m_altMuzzleModelIndex = getmodelindex(muzzleModel, false);
}

void
ncWeapon::_SwitchedToCallback(void)
{
	SwitchFireInfo(m_primaryFireInfo);
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
		if (m_iClipSize && m_fiAmmoType == m_primaryAmmoType) {
			/* no more ammo in clip? */
			if (m_iClip <= 0i || (m_iClip - m_fiAmmoPerShot) < 0i) {
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

#ifdef CLIENT
.float vw_index;
void
ncWeapon::UpdateViewmodel(void)
{
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

			if (viewModel) {
				viewModel._UpdateBoneCount();
			}

			if (viewModel2) {
				viewModel2._UpdateBoneCount();
			}
		}
	}
}
#endif

void
ncWeapon::Draw(void)
{
#ifdef CLIENT
	UpdateViewmodel();
#endif

	float drawAnimation = -1;
	float drawTime = 0.0f;

	if (m_iClipSize > 0 && m_iClip == 0) {
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
		if (m_iClipSize && m_fiAmmoType == m_primaryAmmoType) {
			/* no more ammo in clip? */
			if (m_iClip <= 0i || (m_iClip - m_fiAmmoPerShot) < 0i) {
				/* possible to reload? */
				if (ourOwner.HasAmmo(m_fiAmmoType, 1) == true) {
					Reload();
					return (false);
				} else { /* no, play empty sound */
					EmptySound();
					m_bFiring = false;
				}
				return (false);
			}

			m_iClip -= m_fiAmmoPerShot;
		} else if (ourOwner.UseAmmo(m_fiAmmoType, m_fiAmmoPerShot) == false) {
			EmptySound();
			m_bFiring = false;
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
	if (m_bPowerAmmo) {
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
	if (m_bRemoveOnEmpty == true && HasReserveAmmo() == false && m_iClipSize <= 0i) {
		ourOwner.RemoveItem(classname);
		return;
	}

	/* will release projectile upon release. */
	if (!(ourOwner.vv_flags & VFL_PRIMEDFUSE) && STRING_SET(m_fiOnRelease)) {
		_SetWeaponState(WEAPONSTATE_RELEASED);
		ourOwner.vv_flags |= VFL_PRIMEDFUSE;
	}

	/* "fireUnderwater" check */
	if (m_fireUnderwater == false && owner.waterlevel >= WATERLEVEL_SUBMERGED) {
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
			ourOwner.nadeCookingTime = time;
			PlaySound(GetSubDefString(fireInfo, "snd_delay"), CHAN_WEAPON, false);
#endif

			/* mark as charging, play loop anim in Idle() next */
			SetIdleNext(frameduration(m_viewModel, shotAnim));
			SetWeaponFrame(shotAnim);
			_SetWeaponState(WEAPONSTATE_CHARGING);
			return;
		} if (UseAmmo(fireInfo) == false) {
			return;
		}
	} else {
		if (UseAmmo(fireInfo) == false) {
			return;
		}

#ifdef SERVER
		ourOwner.nadeCookingTime = time;
#endif
	}

	ourOwner.punchangle += m_fiPunchAngle;
	ourOwner.punchvelocity += m_fiPunchSpring * 20.0f;

#ifdef SERVER
	string fireSound = m_fiSndFire;
	v_angle = input_angles;

	if (m_iClipSize > 0 && m_iClip == 0) {
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

	if (m_bHasLoop == false) {
		if (m_iClipSize > 0 && m_iClip == 0) {
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
		m_flOverheating += m_fiOverheatPoints;

#ifdef SERVER
		//printf("%f (%f)\n", m_flOverheating, (m_flOverheating / m_fiOverheatLength));
#endif

		if (m_flOverheating >= m_fiOverheatLength) {
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

	m_bFiring = true;
}

void
ncWeapon::_PrimaryAttack(void)
{
	_WeaponStartedFiring();
	PrimaryAttack();
}

void
ncWeapon::_SecondaryAttack(void)
{
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

	if (m_iMode) {
		animMode = GetSubDefAct(m_strLastFireInfo, "modeOn");
		SwitchFireInfo(m_secondaryFireInfo);
	} else {
		SwitchFireInfo(m_primaryFireInfo);
		animMode = GetSubDefAct(m_strLastFireInfo, "modeOff");
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
		Sound_Play(owner, soundChannel, soundDef);
	}
#endif

#ifdef SERVER
	if (!clientOnly) {
		Sound_Play(owner, soundChannel, soundDef);
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

	m_flOverheating = max(0.0f, m_flOverheating - input_timelength);

	if (CanIdle() == false) {
		return;
	}

	if (m_fiWillRelease) {
		idleAnim = GetSubDefAct(m_strLastFireInfo, "cooking");
		
		if (idleAnim >= 0) {
			SetWeaponFrame(idleAnim);
			SetIdleNext(frameduration(m_viewModel, idleAnim));
		}
		return;
	}

	/* handle shotgun style reloads */
	switch (m_dState) {
	case WEAPONSTATE_RELOAD_START:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "reloadStart");
		_SetWeaponState(WEAPONSTATE_RELOAD);
#ifdef SERVER
		PlaySound(GetDefString("snd_reloadStart"), CHAN_AUTO, false);
#endif
		SetAttackNext(frameduration(m_viewModel, idleAnim));
		break;
	case WEAPONSTATE_RELOAD:
		float reloadTime;
		idleAnim = GetSubDefAct(m_strLastFireInfo, "reload");
		m_iClip++;
		ourOwner.UseAmmo(m_primaryAmmoType, 1);

		if (HasReserveAmmo() == false || m_iClip >= m_iClipSize) {
			_SetWeaponState(WEAPONSTATE_RELOAD_END);
		}

		if (m_flReloadSpeed == -1.0f) {
			reloadTime = frameduration(m_viewModel, idleAnim);
		} else {
			reloadTime = m_flReloadSpeed;
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
		idleAnim = GetSubDefAct(m_strLastFireInfo, "reloadEnd");
		_SetWeaponState(WEAPONSTATE_IDLE);
#ifdef SERVER
		PlaySound(GetDefString("snd_reloadEnd"), CHAN_AUTO, false);
#endif
		SetAttackNext(frameduration(m_viewModel, idleAnim));
		break;
	case WEAPONSTATE_FIRELOOP:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "loop");
		break;
	case WEAPONSTATE_CHARGING:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "loop");
		break;
	case WEAPONSTATE_COCK:
		//breakpoint();
		idleAnim = GetSubDefAct(m_strLastFireInfo, "cock");
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
			UseAmmo(m_strLastFireInfo);
		}

		ReleasedWeaponAttack(m_strLastFireInfo);
		ourOwner.vv_flags &= ~VFL_PRIMEDFUSE;
		idleAnim = GetSubDefAct(m_strLastFireInfo, "release");
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
		if (m_iClipSize > 0 && m_iClip == 0) {
			idleAnim = GetSubDefAct(m_strLastFireInfo, "idleEmpty");

			/* TODO: may want this? hard to say. */
			/*if (idleAnim < 0) {
				SetIdleNext(5.0f);
				return;
			}*/
		}

		if (idleAnim < 0) {
			idleAnim = GetSubDefAct(m_strLastFireInfo, "idle");
		}
	}

	/* no anim, so delay it by a bit more so we don't constantly query decl */
	if (idleAnim < 0) {
		SetIdleNext(5.0f);
		return;
	}

	SetWeaponFrame(idleAnim);
	SetIdleNext(frameduration(m_viewModel, idleAnim));
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

		if (m_bHasLoop) {
			Release();
		} else {
			Idle();
		}

		return;
	}

	if (m_bAltModeSwitch == true) {
		if (CanFire() == false) {
			return;
		}
	}

	if (GetDefBool("altAlternates") == true) {
		m_iMode = 1 - m_iMode;
	}

	if (m_iMode) {
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
	if (m_flZoomFOV > 0.0f) {
		if (CanFire() == false) {
			return;
		}

		ourOwner = (ncPlayer)GetOwner();
		ourOwner.viewzoom = (ourOwner.viewzoom == 1.0) ? m_flZoomFOV : 1.0;

#ifdef SERVER
		if (ourOwner.viewzoom == 1.0) {
			PlaySound(GetDefString("snd_lowerScope"), CHAN_AUTO, false);
		} else {
			PlaySound(GetDefString("snd_raiseScope"), CHAN_AUTO, false);
		}
#endif

		ourOwner.gflags |= GF_SEMI_TOGGLED;
		return;
	} else if (m_bAltModeSwitch == true) {
		if (CanFire() == false) {
			Idle();
			return;
		}

		m_iMode = 1 - m_iMode;

#ifdef SERVER
		if (m_iMode) {
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
	if (m_secondaryFireInfo == "") {
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

	ammoToDeduct = m_iClipSize - m_iClip;

	/* not enough ammo. assign whatever is left. */
	if (ourOwner.HasAmmo(m_primaryAmmoType, ammoToDeduct) == false) {
		ammoToDeduct = ourOwner.m_iAmmoTypes[m_primaryAmmoType];
		m_iClip += ammoToDeduct;
	} else {
		m_iClip = m_iClipSize;
	}

	ourOwner.UseAmmo(m_primaryAmmoType, ammoToDeduct);
}
#endif

void
ncWeapon::Reload(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	float reloadAnimation = -1;
	float reloadEndAnimation = -1;
	float reloadTime;
	string ammoType;
	int ammoTypeID;
	float reloadStartAct = -1;

	/* already in a reload? */
	if (m_dState >= WEAPONSTATE_RELOAD_START && m_dState <= WEAPONSTATE_RELOAD_END) {
		return;
	}
	reloadStartAct = GetSubDefAct(m_strLastFireInfo, "reloadStart");

	/* we cannot reload this weapon by principle. */
	if (!m_iClipSize) {
		return;
	}

	if (CanReload() == false) {
		Idle();
		return;
	}

	/* NOTE: this affects our clip, so primary fireInfo only */
	ammoType = GetSubDefString(m_primaryFireInfo, "ammoType");
	ammoTypeID = ammoNumForName(ammoType);

	if (m_iClip == m_iClipSize) {
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

	if (m_iClipSize > 0 && m_iClip == 0) {
		reloadAnimation = GetSubDefAct(m_strLastFireInfo, "reloadEmpty");
	}

	if (reloadAnimation < 0) {
		reloadAnimation = GetSubDefAct(m_strLastFireInfo, "reload");
		
		/* check if we should schedule a reload-end */
		if (GetSubDefAct(m_strLastFireInfo, "reloadEnd") >= 0) {
			_SetWeaponState(WEAPONSTATE_RELOAD_END);
		}
	}

	if (m_flReloadSpeed == -1.0f) {
		reloadTime = frameduration(m_viewModel, reloadAnimation);
	} else {
		reloadTime = m_flReloadSpeed;
	}

#ifdef SERVER

	string reloadSound = GetDefString("snd_reload");

	if (m_iClipSize > 0 && m_iClip == 0) {
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
	if (!(owner.vv_flags & VFL_FIRING)) {
		float actFireStart = GetSubDefAct(m_strLastFireInfo, "fireStart");

		/* we may be supposed to be looping */
		if (m_bHasLoop) {
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

		//printf("actFireStart %d %S\n", actFireStart, m_strLastFireInfo);
#endif

		WeaponStartedFiring();
	}

	owner.vv_flags |= VFL_FIRING;
}

void
ncWeapon::_WeaponStoppedFiring(void)
{
	if (m_bHasLoop == false) {
		if (CanFire() == false) {
			return;
		}
	}

	/* was still registed as firing */
	if (WeaponIsFiring() == true) {
		ncPlayer ourOwner = (ncPlayer)GetOwner();
		float actFireStop = GetSubDefAct(m_strLastFireInfo, "fireStop");

		if (actFireStop >= 0) {
			SetWeaponFrame(actFireStop);
			SetAttackNext(frameduration(m_viewModel, actFireStop));
			SetIdleNext(frameduration(m_viewModel, actFireStop));
		}

		/* only go through the 'released' arc if we were either looping or got something to release? */
		if (m_bHasLoop || actFireStop >= 0) {
			_SetWeaponState(WEAPONSTATE_RELEASED);
		}

		WeaponStoppedFiring();

		/* Remove when empty, but not when we're supposed to be detonating on fire */
		if (!STRING_SET(m_fiDetonateOnFire) && m_bRemoveOnEmpty && HasReserveAmmo() == false && m_iClipSize <= 0i) {
			ourOwner.RemoveItem(classname);
			return;
		}
	}

	owner.vv_flags &= ~VFL_FIRING;
}

bool
ncWeapon::WeaponIsFiring(void)
{
	return (owner.vv_flags & VFL_FIRING) ? (true) : (false);
}

void
ncWeapon::WeaponStartedFiring(void)
{
}

void
ncWeapon::WeaponStoppedFiring(void)
{
}

void
ncWeapon::Release(void)
{
	float idleAnim = -1;
	ncPlayer ourOwner = (ncPlayer)GetOwner();
	ourOwner.gflags &= ~GF_SEMI_TOGGLED;

	/* we're allowed to release any time. allow it! */
	if (ourOwner.vv_flags & VFL_PRIMEDFUSE) {
		_SetWeaponState(WEAPONSTATE_RELEASED);
		SetIdleNext(0.0f);
	}

	if (GetWeaponState() == WEAPONSTATE_CHARGING) {
		if (CanFire() == true) {
			/* hack to get around the ammo usage when charging */
			float oldChargeTime = m_fiChargeTime;
			m_fiChargeTime = 0.0f;
			Attack(m_strLastFireInfo);
			m_fiChargeTime = oldChargeTime;
			return;
		}
	}

#if 0
	/* already in a reload? */
	if (!(m_dState >= WEAPONSTATE_RELOAD_START && m_dState <= WEAPONSTATE_RELOAD_END)) {
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

	m_bFiring = false;

	Idle();
}

void
ncWeapon::UpdateGUI(void)
{
#ifdef CLIENT
	ncPlayer ourOwner = __NULL__;
	static float baseIconSize = 32.0f;
	static float baseIconPadding = 16.0f;

	if (m_bAmmoRequired == false) {
		return;
	}

	ourOwner = (ncPlayer)GetOwner();

	vector hudSize = g_view.GetHUDCanvasSize();
	vector iconPos = g_view.GetHUDCanvasPos() + (hudSize / 2);
	iconPos[0] = (hudSize[0] - baseIconSize) - baseIconPadding;
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;
	drawpic(iconPos, "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f);

	ourOwner.a_ammo2 = ourOwner.GetReserveAmmo(m_primaryAmmoType);
	iconPos[0] -= baseIconSize + baseIconPadding;
	Font_DrawRText(iconPos, itos(ourOwner.a_ammo2), FONT_16);

	iconPos[0] -= baseIconSize + baseIconPadding;

	if (m_iClipSize > 0i) {
		ourOwner.a_ammo1 = m_iClip;
		Font_DrawRText(iconPos, itos(ourOwner.a_ammo1), FONT_16);
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
		ourOwner.weaponframe = newSequence;
		ourOwner.weapontime = 0.0f;
	}
}

void
ncWeapon::SetAttackNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	ourOwner.w_attack_next = newDelay;
	SetReloadNext(newDelay);
}

void
ncWeapon::SetReloadNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	ourOwner.w_reload_next = newDelay;
}

void
ncWeapon::SetIdleNext(float newDelay)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (!ourOwner) {
		return;
	}

	/* HACK: RT2 requires this as their anims have junk at the end :/ */
	if (m_bBuggyIdleAnim == true)
		ourOwner.w_idle_next = bound(0.0, newDelay - 0.05f, newDelay);
	else
		ourOwner.w_idle_next = newDelay;
}

bool
ncWeapon::CanIdle(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner.w_idle_next > 0.0f) {
		return (false);
	}

	return (true);
}

bool
ncWeapon::CanFire(void)
{
	ncPlayer ourOwner = (ncPlayer)GetOwner();

	if (ourOwner.w_attack_next > 0.0f) {
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

	if (ourOwner.w_reload_next > 0.0f) {
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

