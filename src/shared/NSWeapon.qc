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
NSWeapon::NSWeapon(void)
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
	m_iMode = 0i;
	m_viewModel = 0;
	m_worldModel = 0;
	m_playerModel = 0.0f;
	m_flFireRate = 1.0f;
	m_dState = 0;
	m_strLastFireInfo = __NULL__;
	m_flSpeedMod = 1.0f;
	m_flReloadSpeed = -1.0f;
}

void
NSWeapon::AddedToInventory(void)
{
}

void
NSWeapon::SwitchedToWeapon(void)
{
}

void
NSWeapon::SwitchedFromWeapon(void)
{
}

void
NSWeapon::RemovedFromInventory(void)
{
}

void
NSWeapon::_SetWeaponState(nsweapon_state_t newState)
{
	if (m_dState == newState) {
		return;
	}

	m_dState = newState;

#ifdef SERVER
	printf("State changed to %s\n", nsweapon_state_s[newState]);
#endif
}

nsweapon_state_t
NSWeapon::GetWeaponState(void)
{
	return (m_dState);
}

void
NSWeapon::UpdateFireInfoCache(void)
{
	string viewGeomset;
	string ammoPerShot = GetSubDefString(m_strLastFireInfo, "ammoPerShot");
	string reloadSpeed = GetSubDefString(m_strLastFireInfo, "reloadTime");
	m_fiDetonateOnFire = GetSubDefString(m_strLastFireInfo, "detonateOnFire");
	m_fiMeleeRange = GetSubDefFloat(m_strLastFireInfo, "melee_distance");
	m_fiPunchAngle = GetSubDefVector(m_strLastFireInfo, "punchAngle");
	m_fiSndFire = GetSubDefString(m_strLastFireInfo, "snd_fire");
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

	/* only check if it's present. */
	m_bHasLoop = GetSubDefBool(m_strLastFireInfo, "actLoop");

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
	viewGeomset = GetSubDefString(m_strLastFireInfo, "view_geomset");

	if (viewGeomset) {
		setcustomskin(pSeat->m_eViewModel, "", viewGeomset);
		setcustomskin(pSeat->m_eViewModelL, "", viewGeomset);
	} else {
		setcustomskin(pSeat->m_eViewModel, "", "");
		setcustomskin(pSeat->m_eViewModelL, "", "");
	}
#endif

#if 0
	NSError("Switched FireInfo to %S", m_strLastFireInfo);
	NSError("m_fiAmmoType: %i", m_fiAmmoRequired);
	NSError("m_fiAmmoRequired: %d", m_fiAmmoRequired);
	NSError("m_fiFireRate: %f", m_fiAmmoRequired);
	NSError("m_flReloadSpeed: %f", m_flReloadSpeed);
#endif

	/* validate */
	if (ammoPerShot != __NULL__) {
		m_fiAmmoPerShot = (int)stoi(ammoPerShot);
	} else {
		m_fiAmmoPerShot = 1i;
	}
}

void
NSWeapon::SwitchFireInfo(string newInfo)
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
NSWeapon::Spawned(void)
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
}

void
NSWeapon::SpawnKey(string keyName, string setValue)
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
	case "smoke_muzzle":
		m_strSmokeParticle = ReadString(setValue);
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
NSWeapon::Save(float handle)
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
NSWeapon::Restore(string strKey, string strValue)
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
NSWeapon::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_WEAPON);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)

	if (1) {
		SENDENTITY_COORD(origin[0], WEAPONFL_CHANGED_ORIGIN)
		SENDENTITY_COORD(origin[1], WEAPONFL_CHANGED_ORIGIN)
		SENDENTITY_COORD(origin[2], WEAPONFL_CHANGED_ORIGIN)
		SENDENTITY_ANGLE(angles[0], WEAPONFL_CHANGED_ANGLES)
		SENDENTITY_ANGLE(angles[1], WEAPONFL_CHANGED_ANGLES)
		SENDENTITY_ANGLE(angles[2], WEAPONFL_CHANGED_ANGLES)
		SENDENTITY_SHORT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
		SENDENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
		SENDENTITY_FLOAT(m_flFireRate, WEAPONFL_CHANGED_MODELINDEX)
		SENDENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
		SENDENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
		SENDENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
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
		SENDENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY_X)
		SENDENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY_Y)
		SENDENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY_Z)
		SENDENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
		SENDENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
		SENDENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
		SENDENTITY_BYTE(m_iClip, WEAPONFL_CHANGED_CLIP)
		SENDENTITY_BYTE(m_iClipSize, WEAPONFL_CHANGED_CLIP)
		SENDENTITY_BYTE(m_iMode, WEAPONFL_CHANGED_CLIP)
		SENDENTITY_ENTITY(chain, WEAPONFL_CHANGED_CHAIN)
		SENDENTITY_ENTITY(owner, WEAPONFL_CHANGED_CHAIN)
		SENDENTITY_BYTE(m_dState, WEAPONFL_CHANGED_STATE)
		SENDENTITY_BYTE(m_bFiring, WEAPONFL_CHANGED_STATE)
		SENDENTITY_FLOAT(m_flOverheating, WEAPONFL_CHANGED_STATE)
	} else {
		/* the item is in the inventory */
	}

	return (1);
}

void
NSWeapon::EvaluateEntity(void)
{
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
	EVALUATE_VECTOR(velocity, 0, WEAPONFL_CHANGED_VELOCITY_X)
	EVALUATE_VECTOR(velocity, 1, WEAPONFL_CHANGED_VELOCITY_Y)
	EVALUATE_VECTOR(velocity, 2, WEAPONFL_CHANGED_VELOCITY_Z)
	EVALUATE_VECTOR(avelocity, 0, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, WEAPONFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iClip, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_iClipSize, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(m_iMode, WEAPONFL_CHANGED_CLIP)
	EVALUATE_FIELD(chain, WEAPONFL_CHANGED_CHAIN)
	EVALUATE_FIELD(owner, WEAPONFL_CHANGED_CHAIN)
	EVALUATE_FIELD(m_dState, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_bFiring, WEAPONFL_CHANGED_STATE)
	EVALUATE_FIELD(m_flOverheating, WEAPONFL_CHANGED_STATE)
}
#endif

#ifdef CLIENT
void
NSWeapon::ClientFX(bool isThirdperson)
{
	if (m_bFiring == false) {
		return;
	}

	vector src;
	vector endpos;
	NSActor pl = (NSActor)owner;

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
NSWeapon::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_SHORT(modelindex, WEAPONFL_CHANGED_MODELINDEX)

	if (1) {
		READENTITY_COORD(origin[0], WEAPONFL_CHANGED_ORIGIN)
		READENTITY_COORD(origin[1], WEAPONFL_CHANGED_ORIGIN)
		READENTITY_COORD(origin[2], WEAPONFL_CHANGED_ORIGIN)
		READENTITY_ANGLE(angles[0], WEAPONFL_CHANGED_ANGLES)
		READENTITY_ANGLE(angles[1], WEAPONFL_CHANGED_ANGLES)
		READENTITY_ANGLE(angles[2], WEAPONFL_CHANGED_ANGLES)
		READENTITY_SHORT(entityDefID, WEAPONFL_CHANGED_MODELINDEX)
		READENTITY_SHORT(m_viewModel, WEAPONFL_CHANGED_MODELINDEX)
		READENTITY_FLOAT(m_flFireRate, WEAPONFL_CHANGED_MODELINDEX)
		READENTITY_BYTE(solid, WEAPONFL_CHANGED_SOLID)
		READENTITY_BYTE(movetype, WEAPONFL_CHANGED_FLAGS)
		READENTITY_INT(flags, WEAPONFL_CHANGED_FLAGS)
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
		READENTITY_SHORT(m_iBody, MONFL_CHANGED_BODY)
		READENTITY_FLOAT(scale, WEAPONFL_CHANGED_SCALE)
		READENTITY_COORD(velocity[0], WEAPONFL_CHANGED_VELOCITY_X)
		READENTITY_COORD(velocity[1], WEAPONFL_CHANGED_VELOCITY_Y)
		READENTITY_COORD(velocity[2], WEAPONFL_CHANGED_VELOCITY_Z)
		READENTITY_COORD(avelocity[0], WEAPONFL_CHANGED_ANGULARVELOCITY)
		READENTITY_COORD(avelocity[1], WEAPONFL_CHANGED_ANGULARVELOCITY)
		READENTITY_COORD(avelocity[2], WEAPONFL_CHANGED_ANGULARVELOCITY)
		READENTITY_BYTE(m_iClip, WEAPONFL_CHANGED_CLIP)
		READENTITY_BYTE(m_iClipSize, WEAPONFL_CHANGED_CLIP)
		READENTITY_BYTE(m_iMode, WEAPONFL_CHANGED_CLIP)
		READENTITY_ENTNUM(chain_entnum, WEAPONFL_CHANGED_CHAIN)
		READENTITY_ENTNUM(owner_entnum, WEAPONFL_CHANGED_CHAIN)
		READENTITY_BYTE(m_dState, WEAPONFL_CHANGED_STATE)
		READENTITY_BYTE(m_bFiring, WEAPONFL_CHANGED_STATE)
		READENTITY_FLOAT(m_flOverheating, WEAPONFL_CHANGED_STATE)
	}

	if (flChanged & WEAPONFL_CHANGED_MODELINDEX) {
		classname = EntityDef_NameFromID(entityDefID);
	}

	if (flChanged & WEAPONFL_CHANGED_BODY)
		_UpdateGeomset();

	drawmask = (modelindex != 0) ? MASK_ENGINE : 0;

	if (flChanged & WEAPONFL_CHANGED_CHAIN) {
		chain = __NULL__;
	}

	if (scale == 0.0f)
		scale = 1.0f;

	if (flChanged & WEAPONFL_CHANGED_SIZE)
		setsize(this, mins, maxs);
}


void
NSWeapon::ReceiveEvent(float eventID)
{
	switch (eventID) {
	case WEPEVENT_FIRED:
		EntLog("Someones weapon was fired.");
		break;
	}
}


void
NSWeapon::PredictPreFrame(void)
{
	super::PredictPreFrame();

	SAVE_STATE(m_iClip)
	SAVE_STATE(m_iClipSize)
	SAVE_STATE(m_iMode)
	SAVE_STATE(m_viewModel)
	SAVE_STATE(m_flFireRate)
	SAVE_STATE(m_dState)
	SAVE_STATE(m_bFiring)
	SAVE_STATE(m_flOverheating)
}

void
NSWeapon::PredictPostFrame(void)
{
	super::PredictPostFrame();

	ROLL_BACK(m_iClip)
	ROLL_BACK(m_iClipSize)
	ROLL_BACK(m_iMode)
	ROLL_BACK(m_viewModel)
	ROLL_BACK(m_flFireRate)
	ROLL_BACK(m_dState)
	ROLL_BACK(m_bFiring)
	ROLL_BACK(m_flOverheating)
}

#endif

void
NSWeapon::_CacheWeaponDefVariables(void)
{
	string firstType, secondType;
	string muzzleModel;
	string ammoRequired;

	/* movement vars */
	m_flSpeedMod = GetDefFloat("speed_mod");

	if (m_flSpeedMod <= 0.0) {
		m_flSpeedMod = 1.0f;
	}

	/* string lookups can be expensive if done too often
	   so we'll need to cache them whenever something
	   big in the game state changes. like a save/load. */
	m_primaryFireInfo = GetDefString("def_fireInfo");
	m_secondaryFireInfo = GetDefString("def_altFireInfo");
	m_meleeDef = GetDefString("def_melee");

	if (!m_primaryFireInfo)
		m_primaryFireInfo = classname;

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
NSWeapon::_SwitchedToCallback(void)
{
	_CacheWeaponDefVariables();
	SwitchFireInfo(m_primaryFireInfo);
	SetAttackNext(0.0f);
	SetIdleNext(0.0f);

	Draw();
}

void
NSWeapon::_SwitchedFromCallback(void)
{
	//printf("Switched from %S\n", classname);
	Holster();
}

bool
NSWeapon::IsWeapon(void)
{
	return (true);
}

void
NSWeapon::Draw(void)
{
#ifdef CLIENT
	NSRenderableEntity viewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	viewModel.modelindex = m_viewModel;
	viewModel._UpdateBoneCount();
#endif

	float drawAnimation = 0;
	float drawTime;

	if (m_iClipSize > 0 && m_iClip == 0) {
		drawAnimation = GetSubDefAct(m_strLastFireInfo, "actDrawEmpty");
	}

	if (!drawAnimation) {
		drawAnimation = GetSubDefAct(m_strLastFireInfo, "actDraw");
	}

	drawTime = frameduration(m_viewModel, drawAnimation);
	SetWeaponFrame(drawAnimation);
	SetAttackNext(drawTime);
	SetIdleNext(drawTime + 1.0f);
}

void
NSWeapon::Holster(void)
{
	EntLog("Holstering Weapon!");
}

bool
NSWeapon::UseAmmo(string fireInfo)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();

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
#ifdef SERVER
					ourOwner.StartSoundDef(m_fiSndEmpty, CHAN_WEAPON, true);
#endif
					ourOwner.gflags |= GF_SEMI_TOGGLED;
					m_bFiring = false;
				}
				return (false);
			}

			m_iClip -= m_fiAmmoPerShot;
		} else if (ourOwner.UseAmmo(m_fiAmmoType, m_fiAmmoPerShot) == false) {
#ifdef SERVER
			ourOwner.StartSoundDef(m_fiSndEmpty, CHAN_WEAPON, true);
#endif
			ourOwner.gflags |= GF_SEMI_TOGGLED;
			m_bFiring = false;
			return (false);
		}
	}

	return (true);
}

bool
NSWeapon::DetonateDef(string defName)
{
	bool success = false;

	for ( entity b = world; ( b = find( b, ::classname, defName ) ); ) {
		if ( b.owner == owner ) {
#ifdef SERVER
			NSProjectile toDetonate = (NSProjectile)b;
			toDetonate.Trigger(owner, TRIG_TOGGLE);
#endif
			success = true;
		}
	}

	return (success);
}

void
NSWeapon::FiredWeaponAttack(string fireInfo)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
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
NSWeapon::ReleasedWeaponAttack(string fireInfo)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.AttackByDef(fireInfo, true);

	/* knockback */
	{
		float weaponKnockBack = GetSubDefFloat(fireInfo, "knockbackRelease");
		ourOwner.AddVelocity(anglesToForward(ourOwner.v_angle) * -weaponKnockBack);
	}

	_SetWeaponState(WEAPONSTATE_RELEASED);
}

void
NSWeapon::Attack(string fireInfo)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	float shotAnim = 0;
	float fireRate = 1.0f;

	if (m_fiSemiAuto == true) {
		ourOwner.gflags |= GF_SEMI_TOGGLED;
	}

	SwitchFireInfo(fireInfo);

	/* no real attack, detonate named satchels, pipe bombs, etc. */
	if (m_fiDetonateOnFire != __NULL__) {
		if (DetonateDef(m_fiDetonateOnFire) == true) {
			SetWeaponFrame(GetSubDefAct(fireInfo, "actDetonate"));
			return;
		}
	}

	/* Remove when empty */
	if (m_bRemoveOnEmpty == true && HasReserveAmmo() == false && m_iClipSize <= 0i) {
		ourOwner.RemoveItem(classname);
		return;
	}

	/* will release projectile upon release. */
	if (m_fiOnRelease != "") {
		m_fiWillRelease = true;
		ourOwner.vv_flags |= VFL_PRIMEDFUSE;
		NSError("Will release.");
	}

	/* melee attacks go through their own routine because we have to test
	   against objects and walls and if we can even hit them. */
	if (m_meleeDef != "") {
		vector eyePos = ourOwner.GetEyePos();
		vector eyeAngles = ourOwner.v_angle;
		int oldhitcontents = ourOwner.hitcontentsmaski;
		float meleeRange = GetSubDefFloat(m_meleeDef, "melee_distance");
		vector traceStart = ourOwner.GetEyePos();
		vector traceEnd = traceStart + (anglesToForward(eyeAngles) * meleeRange);
		float meleeRate;
		NSSurfacePropEntity hitEnt;
		vector hitLoc;

		ourOwner.hitcontentsmaski = (CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE);
		traceline(traceStart, traceEnd, MOVE_NORMAL, ourOwner);
		hitEnt = (NSSurfacePropEntity)trace_ent;
		hitLoc = trace_endpos;
		ourOwner.hitcontentsmaski = oldhitcontents;

		if (trace_fraction >= 1.0) {
			SetWeaponFrame(GetSubDefAct(fireInfo, "actMeleeMiss"));
			meleeRate = GetDefFloat("meleeRateMiss");
		} else {
			SetWeaponFrame(GetSubDefAct(fireInfo, "actMeleeHit"));
			meleeRate = GetDefFloat("meleeRateHit");
		}

		SetAttackNext(meleeRate);
		SetIdleNext(meleeRate + 1.0f);

#ifdef SERVER
		PlaySound(GetSubDefString(m_meleeDef, "snd_miss"), false);

		if (trace_fraction >= 1.0) {
			return;
		}

		/* don't bother with decals, we got squibs */
		if (hitEnt.iBleeds) {
			FX_Blood(hitLoc, hitEnt.GetBloodColor());
		}

		if (hitEnt.takedamage) {
			NSDict damageDecl = spawn(NSDict);
			damageDecl.AddKey("damage", GetSubDefString(m_meleeDef, "damage"));
			hitEnt.Damage(this, owner, damageDecl, 1.0, anglesToForward(eyeAngles), traceEnd);
			remove(damageDecl);
			//Damage_Apply(trace_ent, ourOwner, meleeDamage, 0, DMG_BLUNT);

			if (hitEnt.iBleeds) {
				PlaySound(GetSubDefString(m_meleeDef, "snd_flesh"), false);
			}
		} else {
			PlaySound(GetSubDefString(m_meleeDef, "snd_hit"), false);
			DecalGroups_Place("Impact.Shot", hitLoc + (anglesToForward(eyeAngles) * -2));
		}
#endif

		/* below logic is for trace/projectile based attacks. */
		return;
	}

	if (UseAmmo(fireInfo) == false) {
		return;
	}

	/* cooking/grenade type weapons */
	if (GetSubDefFloat(fireInfo, "primed_fuse") > 0.0f) {
		shotAnim = GetSubDefAct(fireInfo, "actFire");
		SetWeaponFrame(shotAnim);
		ourOwner.vv_flags |= VFL_PRIMEDFUSE;
		ourOwner.gflags |= GF_SEMI_TOGGLED;
		m_strLastFireInfo = fireInfo;
#ifdef SERVER
		ourOwner.nadeCookingTime = time;
#endif
		return;
	}

	/* this weapon has a delay before something shoots out. */
	if (m_fiChargeTime > 0.0f) {
		/* we haven't yet tried firing while charging */
		if (GetWeaponState() != WEAPONSTATE_CHARGING) {
			shotAnim = GetSubDefAct(fireInfo, "actDelay");
			SetAttackNext(m_fiChargeTime);

			/* mark as charging, play loop anim in Idle() next */
			SetIdleNext(frameduration(m_viewModel, shotAnim));
			SetWeaponFrame(shotAnim);
			_SetWeaponState(WEAPONSTATE_CHARGING);
			return;
		}
	}

	ourOwner.punchangle += m_fiPunchAngle;

#ifdef SERVER
	v_angle = input_angles;

	if (m_fiSndFire) {
		ourOwner.StartSoundDef(m_fiSndFire, CHAN_WEAPON, true);
	}
#endif

	FiredWeaponAttack(fireInfo);

	if (m_bHasLoop == false) {
		if (m_iClipSize > 0 && m_iClip == 0) {
			shotAnim = GetSubDefAct(fireInfo, "actFireLast");
		}
	
		if (!shotAnim) {
			shotAnim = GetSubDefAct(fireInfo, "actFire");
		}

#ifdef CLIENT
		View_SetMuzzleflash(m_muzzleModelIndex);
#endif

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
	}

	float animTime = frameduration(m_viewModel, shotAnim);

	if (m_fiFireRate) {
		SetAttackNext(m_fiFireRate);
	} else {
		SetAttackNext(animTime);
	}

	m_bFiring = true;
}

void
NSWeapon::_PrimaryAttack(void)
{
	_WeaponStartedFiring();
	PrimaryAttack();
}

void
NSWeapon::_SecondaryAttack(void)
{
	_WeaponStartedFiring();
	SecondaryAttack();
}

void
NSWeapon::_SwitchedWeaponMode(void)
{
	float animMode;

	if (m_iMode) {
		animMode = GetSubDefAct(m_strLastFireInfo, "actModeOn");
		SwitchFireInfo(m_secondaryFireInfo);
	} else {
		SwitchFireInfo(m_primaryFireInfo);
		animMode = GetSubDefAct(m_strLastFireInfo, "actModeOff");
	}

	SetWeaponFrame(animMode);
	SetAttackNext(frameduration(m_viewModel, animMode));
	SetIdleNext(frameduration(m_viewModel, animMode));
}

void
NSWeapon::PlaySound(string soundDef, bool clientOnly)
{
#ifdef CLIENT
	if (clientOnly) {
		Sound_Play(owner, CHAN_WEAPON, soundDef);
	}
#endif

#ifdef SERVER
	if (!clientOnly) {
		Sound_Play(owner, CHAN_WEAPON, soundDef);
	}
#endif
}

void
NSWeapon::Idle(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	float idleAnim = 0;

	m_flOverheating = max(0.0f, m_flOverheating - input_timelength);

	if (CanIdle() == false) {
		return;
	}

	/* handle shotgun style reloads */
	switch (m_dState) {
	case WEAPONSTATE_RELOAD_START:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actReloadStart");
		_SetWeaponState(WEAPONSTATE_RELOAD);
		PlaySound(GetDefString("snd_reload_start"), false);
		break;
	case WEAPONSTATE_RELOAD:
		float reloadTime;
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actReload");
		m_iClip++;
		ourOwner.UseAmmo(m_primaryAmmoType, 1);

		if (HasReserveAmmo() == false || m_iClip >= m_iClipSize) {
			_SetWeaponState(WEAPONSTATE_RELOAD_END);
		}

#ifdef SERVER
		PlaySound(GetDefString("snd_reload"), false);
#endif

		if (m_flReloadSpeed == -1.0f) {
			reloadTime = frameduration(m_viewModel, idleAnim);
		} else {
			reloadTime = m_flReloadSpeed;
		}

		SetWeaponFrame(idleAnim);
		SetIdleNext(reloadTime);
		return;
		break;
	case WEAPONSTATE_RELOAD_END:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actReloadEnd");
		_SetWeaponState(WEAPONSTATE_IDLE);
#ifdef SERVER
		PlaySound(GetDefString("snd_reload_end"), false);
#endif
		break;
	case WEAPONSTATE_FIRELOOP:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actLoop");
		break;
	case WEAPONSTATE_CHARGING:
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actLoop");
		break;
	case WEAPONSTATE_RELEASED:
		//breakpoint();
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actRelease");
		_SetWeaponState(WEAPONSTATE_IDLE);
		break;
	case WEAPONSTATE_OVERHEATED:
		/* prevent fire for the next N seconds */
		_SetWeaponState(WEAPONSTATE_IDLE);
		SetAttackNext(m_fiOverheatLength);
		SetReloadNext(0.1f);
		break;
	case WEAPONSTATE_IDLE:
	default:
		if (m_iClipSize > 0 && m_iClip == 0) {
			idleAnim = GetSubDefAct(m_strLastFireInfo, "actIdleEmpty");
	
			/* this will mess with us otherwise */
			if (!idleAnim)
				return;
		}

		if (!idleAnim)
			idleAnim = GetSubDefAct(m_strLastFireInfo, "actIdle");
	}

	SetWeaponFrame(idleAnim);
	SetIdleNext(frameduration(m_viewModel, idleAnim));
}

void
NSWeapon::PrimaryAttack(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();

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

	if (m_iMode) {
		Attack(m_secondaryFireInfo);
		return;
	}

	Attack(m_primaryFireInfo);
}

void
NSWeapon::SecondaryAttack(void)
{
	float shotAnim = 0;
	NSClientPlayer ourOwner;
	float fireRate = 0.0f;

	/* zoom takes priority */
	if (m_flZoomFOV > 0.0f) {
		if (CanFire() == false) {
			return;
		}

		ourOwner = (NSClientPlayer)GetOwner();
		ourOwner.viewzoom = (ourOwner.viewzoom == 1.0) ? m_flZoomFOV : 1.0;

#ifdef SERVER
		if (ourOwner.viewzoom == 1.0) {
			PlaySound(GetDefString("snd_lower_scope"), false);
		} else {
			PlaySound(GetDefString("snd_raise_scope"), false);
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
NSWeapon::_ReloadFinished(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	int ammoToDeduct;

	ammoToDeduct = m_iClipSize - m_iClip;

	/* not enough ammo. assign whatever is left. */
	if (ourOwner.HasAmmo(m_primaryAmmoType, ammoToDeduct) == false) {
		ammoToDeduct = ourOwner.m_iAmmoTypes[m_primaryAmmoType];
	}

	m_iClip = m_iClipSize;
	ourOwner.UseAmmo(m_primaryAmmoType, ammoToDeduct);
}
#endif

void
NSWeapon::Reload(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	float reloadAnimation = 0;
	float reloadTime;
	string ammoType;
	int ammoTypeID;
	float reloadStartAct;

	/* already in a reload? */
	if (m_dState >= WEAPONSTATE_RELOAD_START && m_dState <= WEAPONSTATE_RELOAD_END) {
		return;
	}
	reloadStartAct = GetSubDefAct(m_strLastFireInfo, "actReloadStart");

	/* we cannot reload this weapon by principle. */
	if (!m_iClipSize) {
		return;
	}

	if (CanReload() == false) {
		Idle();
		return;
	}

	ammoType = GetSubDefString(m_strLastFireInfo, "ammoType");
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
	if (reloadStartAct) {
		_SetWeaponState(WEAPONSTATE_RELOAD_START);
		Release();
		return;
	}

	if (m_iClipSize > 0 && m_iClip == 0) {
		reloadAnimation = GetSubDefAct(m_strLastFireInfo, "actReloadEmpty");
	}
	
	if (!reloadAnimation) {
		reloadAnimation = GetSubDefAct(m_strLastFireInfo, "actReload");
	}

	if (m_flReloadSpeed == -1.0f) {
		reloadTime = frameduration(m_viewModel, reloadAnimation);
	} else {
		reloadTime = m_flReloadSpeed;
	}

	PlaySound(GetDefString("snd_reload"), false);

#ifdef SERVER
	ScheduleThink(_ReloadFinished, reloadTime - 0.1f);
#endif

	SetWeaponFrame(reloadAnimation);
	SetAttackNext(reloadTime - 0.01);
	SetIdleNext(reloadTime);
}

bool
NSWeapon::HasReserveAmmo(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
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
NSWeapon::_WeaponStartedFiring(void)
{
	if (CanFire() == false) {
		return;
	}

	/* hasn't been fired yet. */
	if (!(owner.vv_flags & VFL_FIRING)) {
		float actFireStart = GetSubDefAct(m_strLastFireInfo, "actFireStart");

#ifdef SERVER
		NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();

		if (m_fiSndFireStart) {
			ourOwner.StartSoundDef(m_fiSndFireStart, CHAN_WEAPON, true);
		}

		if (m_fiSndFireLoop) {
			//ourOwner.StartSoundDef(m_fiSndFireLoop, CHAN_LOOP, true);
		}

		//printf("actFireStart %d %S\n", actFireStart, m_strLastFireInfo);
#endif

		if (actFireStart) {
			SetWeaponFrame(actFireStart);
			SetAttackNext(frameduration(m_viewModel, actFireStart));
			SetIdleNext(frameduration(m_viewModel, actFireStart));
			_SetWeaponState(WEAPONSTATE_FIRELOOP);
		}

		WeaponStartedFiring();
	}

	owner.vv_flags |= VFL_FIRING;
}

void
NSWeapon::_WeaponStoppedFiring(void)
{
	if (m_bHasLoop == false)
	if (CanFire() == false) {
		return;
	}

	/* was still registed as firing */
	if (owner.vv_flags & VFL_FIRING) {
		float actFireStop = GetSubDefAct(m_strLastFireInfo, "actFireStop");

		if (actFireStop) {
			SetWeaponFrame(actFireStop);
			SetAttackNext(frameduration(m_viewModel, actFireStop));
			SetIdleNext(frameduration(m_viewModel, actFireStop));
			_SetWeaponState(WEAPONSTATE_RELEASED);
		}

		WeaponStoppedFiring();
	}

	owner.vv_flags &= ~VFL_FIRING;
}

bool
NSWeapon::WeaponIsFiring(void)
{
	return (owner.vv_flags & VFL_FIRING) ? (true) : (false);
}

void
NSWeapon::WeaponStartedFiring(void)
{
}

void
NSWeapon::WeaponStoppedFiring(void)
{
}

void
NSWeapon::Release(void)
{
	float idleAnim = 0;
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.gflags &= ~GF_SEMI_TOGGLED;

	if (m_fiWillRelease) {
		string defThrown = GetSubDefString(m_strLastFireInfo, "def_thrown");
		string defPlant = GetSubDefString(m_strLastFireInfo, "def_plant");

		/* delayed shot release */
		idleAnim = GetSubDefAct(m_strLastFireInfo, "actRelease");

		/* aimed at attached to whatever we're looking at */
		if (defPlant != "") {
			/* attempt to plant */
			if (ourOwner.PlantCharge(defPlant) == true) {
				/* no ammo type, so remove item from inventory once depleted */
				if (m_strAmmoType == "") {
					if (m_iClip == 0i) {
						ourOwner.RemoveItem(this.classname);
					}
				}
			}
		}

		if (m_fiSndRelease) {
			ourOwner.StartSoundDef(m_fiSndRelease, CHAN_WEAPON, true);
		}

		ReleasedWeaponAttack(m_strLastFireInfo);
		m_fiWillRelease = false;
		SetWeaponFrame(idleAnim);
		SetAttackNext(1.0f);
		SetIdleNext(1.0f);
		ourOwner.vv_flags &= ~VFL_PRIMEDFUSE;
		return;
	}

#if 0
	/* Remove when empty */
	if (m_bRemoveOnEmpty && HasReserveAmmo() == false && m_iClipSize <= 0i) {
		ourOwner.RemoveItem(classname);
		return;
	}
#endif

	/* already in a reload? */
	if (!(m_dState >= WEAPONSTATE_RELOAD_START && m_dState <= WEAPONSTATE_RELOAD_END)) {
		_SetWeaponState(WEAPONSTATE_IDLE);
	}

#ifdef SERVER
	if (m_bFiring == true) {
		NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();

		if (m_fiSndFireStop) {
			ourOwner.StartSoundDef(m_fiSndFireStop, CHAN_WEAPON, true);
		}

		ourOwner.StopSound(CHAN_LOOP, true);
		//printf("actFireStop %d %S\n", actFireStop, m_strLastFireInfo);
	}
#endif

	m_bFiring = false;

#if 0
	if (ourOwner.vv_flags & VFL_REDRAW) {
		Draw();
		ourOwner.vv_flags &= ~VFL_REDRAW;
		return;
	}
#endif

	Idle();
}

void
NSWeapon::UpdateGUI(void)
{
}

void
NSWeapon::SetViewModel(string modelPath)
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
NSWeapon::SetWorldModel(string modelPath)
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
NSWeapon::SetPlayerModel(string modelPath)
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
NSWeapon::SetWeaponFrame(float newSequence)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.weaponframe = newSequence;
	ourOwner.weapontime = 0.0f;
}

void
NSWeapon::SetAttackNext(float newDelay)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.w_attack_next = newDelay;
	SetReloadNext(newDelay);
}

void
NSWeapon::SetReloadNext(float newDelay)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.w_reload_next = newDelay;
}

void
NSWeapon::SetIdleNext(float newDelay)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	ourOwner.w_idle_next = newDelay;
}

bool
NSWeapon::CanIdle(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	
	if (ourOwner.w_idle_next > 0.0f) {
		return (false);
	}

	return (true);
}

bool
NSWeapon::CanFire(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	
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
NSWeapon::CanReload(void)
{
	NSClientPlayer ourOwner = (NSClientPlayer)GetOwner();
	
	if (ourOwner.w_reload_next > 0.0f) {
		return (false);
	}

	return (true);
}

/* required because we might need to look it up inside the
info for the primary attack mode. */
static string
NSWeapon_GetPrimaryKeyValue(string weaponDef, string keyName)
{
	string fireInfo1 = EntityDef_GetKeyValue(weaponDef, "def_fireInfo");
	string defValue = EntityDef_GetKeyValue(weaponDef, keyName);
	string fireInfoValue = EntityDef_GetKeyValue(fireInfo1, keyName);

	/* fireinfo takes priority */
	if (fireInfoValue) {
		return (fireInfoValue);
	}

	return (defValue);
}

string
weaponType(string weaponDef)
{
	return ("unknown");
}

int
weaponStartAmmo(string weaponDef)
{
	return (int)stof(EntityDef_GetKeyValue(weaponDef, "clipSize"));
}

int
weaponMaxAmmo(string weaponDef)
{
	string ammoType = NSWeapon_GetPrimaryKeyValue(weaponDef, "ammoType");
	return (ammoMaxForName(ammoType));
}

bool
weaponIsSemiAuto(string weaponDef)
{
	return (bool)stof(NSWeapon_GetPrimaryKeyValue(weaponDef, "semiAuto"));
}

string
weaponInventoryType(string weaponDef)
{
	return ("item");
}

float
weaponFireTime(string weaponDef)
{
	return stof(NSWeapon_GetPrimaryKeyValue(weaponDef, "fireRate"));
}

int
weaponClipSize(string weaponDef)
{
	return (int)stoi(EntityDef_GetKeyValue(weaponDef, "clipSize"));
}

string
weaponClass(string weaponDef)
{
	return ("unknown");
}

bool
isWeaponClipOnly(string weaponDef)
{
	int clipSize = (int)stoi(EntityDef_GetKeyValue(weaponDef, "clipSize"));
	string ammoType = NSWeapon_GetPrimaryKeyValue(weaponDef, "ammoType");

	/* no ammo type... */
	if (!ammoType) {
		/* but a clip is defined */
		if (clipSize > 0i) {
			return (true);
		}
	}
	return (false);
}

bool
isWeaponDetonationTimed(string weaponDef)
{
	string projectileDef = NSWeapon_GetPrimaryKeyValue(weaponDef, "def_projectile");
	bool isFused = (bool)stof(EntityDef_GetKeyValue(projectileDef, "detonate_on_fuse"));
	return (isFused);
}

.NSWeapon m_nextWeapon;
.NSWeapon m_prevWeapon;

NSWeapon
NSWeapon_SortWeaponChain(NSActor targetPlayer)
{
	NSWeapon itemChain = (NSWeapon)targetPlayer.m_itemList;
	int heighestSlot = -1i;
	int heighestPos = -1i;
	NSWeapon firstWeapon, lastWeapon;
	int hudSlot, hudPos;

	firstWeapon = lastWeapon = __NULL__;

	if (!targetPlayer.m_itemList) {
		return __NULL__;
	}

	/* first we determine the range of our hud buckets. */
	while (itemChain) {
		if (itemChain.IsWeapon() == true) {
			hudSlot = itemChain.GetDefInt("hudSlot");
			hudPos = itemChain.GetDefInt("hudSlotPos");

			if (hudSlot > heighestSlot) {
				heighestSlot = hudSlot;
			}
			if (hudPos > heighestPos) {
				heighestPos = hudPos;
			}
		}

		itemChain = (NSWeapon)itemChain.chain;
	}

	for (int hS = 0i; hS <= heighestSlot; hS++) {
		for (int hP = 0i; hP <= heighestPos; hP++) {
			itemChain = (NSWeapon)targetPlayer.m_itemList;

			while (itemChain) {
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

				itemChain = (NSWeapon)itemChain.chain;
			}
		}
	}

	/* test */
	NSWeapon weaponTest = firstWeapon;
	while (weaponTest) {
		weaponTest = weaponTest.m_nextWeapon;
	}

	firstWeapon.m_prevWeapon = lastWeapon;

	return (firstWeapon);
}

#ifdef CLIENT
bool
NSWeapon_CanSwitch(NSActor pl)
{
	if (!pl.m_activeWeapon)
		return false;

	return true;
}

void
NSWeapon_SelectWeapon(NSWeapon nextWeapon)
{
	if (!nextWeapon) {
		pSeat->m_iHUDWeaponSelected = 0i;
		return;
	}

	/* this gets passed in NSClientPlayer::ClientInputFrame() to the server */
	pSeat->m_iHUDWeaponSelected = nextWeapon.GetSharedID();
}
#endif

/** Select the next item in the list. */
void
NSWeapon_NextWeapon(NSActor pl)
{
#ifdef CLIENT
	NSWeapon firstWeapon;

	if (NSWeapon_CanSwitch(pl) == false) {
		return;
	}

	firstWeapon = NSWeapon_SortWeaponChain(pl);

	if (pl.m_activeWeapon.m_nextWeapon) {
		NSWeapon_SelectWeapon(pl.m_activeWeapon.m_nextWeapon);
	} else {
		NSWeapon_SelectWeapon(firstWeapon);
	}
#endif
}

/** Select the previous item in the list. */
void
NSWeapon_PrevWeapon(NSActor pl)
{
#ifdef CLIENT
	NSWeapon firstWeapon;

	if (NSWeapon_CanSwitch(pl) == false) {
		return;
	}

	firstWeapon = NSWeapon_SortWeaponChain(pl);

	if (pl.m_activeWeapon.m_prevWeapon) {
		NSWeapon_SelectWeapon(pl.m_activeWeapon.m_prevWeapon);
	} else {
		NSWeapon_SelectWeapon(firstWeapon);
	}
#endif
}

/** Select the previous item in the list. */
void
NSWeapon_LastWeapon(NSActor pl)
{
#ifdef CLIENT
	NSWeapon firstWeapon;

	if (NSWeapon_CanSwitch(pl) == false) {
		return;
	}

	firstWeapon = NSWeapon_SortWeaponChain(pl);

	if (pl.m_activeWeapon.m_prevWeapon) {
		NSWeapon_SelectWeapon(pl.m_activeWeapon.m_prevWeapon);
	} else {
		NSWeapon_SelectWeapon(firstWeapon);
	}
#endif
}
