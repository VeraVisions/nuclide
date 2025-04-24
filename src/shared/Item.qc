/*
 * Copyright (c) 2024 Vera Visions LLC.
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
ncItem::ncItem(void)
{
	m_itemWasDropped = 0i;
	m_sndAcquire = __NULL__;
	m_sndRespawn = __NULL__;
	m_itemPickupFloats = false;
	m_itemPickupSpins = false;
	m_itemGivesHealth = 0i;
	m_itemGivesArmor = 0i;
	m_itemGivesBonusHealth = 0i;
	m_itemGivesBonusArmor = 0i;
	m_itemNoTouch = false;
	m_itemCarries = false;
	m_itemRequiresItem = __NULL__;
	m_nextItem = __NULL__;
	owner = __NULL__;
	m_itemRespawn = 0;
}

#ifdef SERVER
void
ncItem::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_sndAcquire);
	precache.Sound(m_sndRespawn);
	pvsflags = PVSF_IGNOREPVS;
	_isItem = true;
}

void
ncItem::Respawn(void)
{
	super::Respawn();
	BecomePickup();

	/* being a physics entity, we might have to restore player physics */
	EnablePlayerCollision();

	if (CreatedByMap() == true) {
		RestoreAngles();
		SetOrigin(GetSpawnVector("origin") + GetSpawnVector("origin_add"));

		if (!m_itemPickupFloats) {
			DropToFloor();
		}
	}
}

void
ncItem::SpawnKey(string keyName, string setValue)
{
	/* special case for ammo type parsing... */
	if (substring(keyName, 0, 8) == "inv_ammo") {
		string ammoType = substring(keyName, 4, -1);
		int ammoID = ammoNumForName(ammoType);

		if (ammoID != -1) {
			m_itemGivesAmmo[ammoID] = stoi(unpackStringCommand(setValue));
		} else {
			ncError("Item %S tries to give invalid ammo type %S", declclass, ammoType);
		}
		return;
	}

	switch (keyName) {
	case "inv_weapon":
		m_itemWeapon = ReadString(setValue);
		break;
	case "snd_acquire":
		m_sndAcquire = ReadString(setValue);
		break;
	case "snd_respawn":
		m_sndRespawn = ReadString(setValue);
		break;
	case "modelflags":
		modelflags = ReadFloat(setValue);
		break;
	case "spin":
		m_itemPickupSpins = ReadBool(setValue);
		break;
	case "floating":
		m_itemPickupFloats = ReadBool(setValue);
		break;
	case "frame":
		frame = ReadFloat(setValue);
		break;
	case "body":
		m_geomsetField = ReadInt(setValue);
		break;
	case "inv_health":
		m_itemGivesHealth = ReadFloat(setValue);
		break;
	case "inv_bonushealth":
		m_itemGivesBonusHealth = ReadInt(setValue);
		break;
	case "inv_bonusarmor":
		m_itemGivesBonusArmor = ReadInt(setValue);
		break;
	case "inv_armor":
		m_itemGivesArmor = ReadFloat(setValue);
		break;
	case "no_touch":
		m_itemNoTouch = ReadBool(setValue);
		break;
	case "inv_carry":
		m_itemCarries = ReadBool(setValue);
		break;
	case "requires":
		m_itemRequiresItem = ReadString(setValue);
		break;
	case "respawn":
		m_itemRespawn = ReadFloat(setValue);
		break;
	case "droptofloor":
		m_itemPickupFloats = !ReadBool(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncItem::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "itemWasDropped", m_itemWasDropped);
	SaveString(handle, "sndAcquire", m_sndAcquire);
	SaveString(handle, "sndRespawn", m_sndRespawn);
	SaveFloat(handle,  "itemRespawn", m_itemRespawn);
	SaveString(handle, "sndHum", m_sndHum);
	SaveInt(handle, "itemPickupFloats", m_itemPickupFloats);
	SaveBool(handle, "itemPickupSpins", m_itemPickupSpins);
	SaveString(handle, "itemName", m_itemName);
	SaveString(handle, "itemWeapon", m_itemWeapon);
	SaveInt(handle, "itemGivesHealth", m_itemGivesHealth);
	SaveInt(handle, "itemGivesBonusHealth", m_itemGivesBonusHealth);
	SaveInt(handle, "itemGivesBonusArmor", m_itemGivesBonusArmor);
	SaveInt(handle, "itemGivesArmor", m_itemGivesArmor);
	SaveBool(handle, "itemNoTouch", m_itemNoTouch);
	SaveBool(handle, "itemCarries", m_itemCarries);
	SaveString(handle, "itemRequiresItem", m_itemRequiresItem);

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		SaveInt(handle, sprintf("itemGivesAmmo_%i", i), m_itemGivesAmmo[i]);
	}

	SaveFloat(handle,  "hiddenModelIndex", m_hiddenModelIndex);
	SaveFloat(handle, "hiddenSequence", m_hiddenSequence);
	SaveEntity(handle, "nextItem", m_nextItem);
	SaveBool(handle, "_isItem", _isItem);
}

void
ncItem::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "_isItem":
		_isItem = ReadBool(setValue);
		break;
	case "itemWasDropped":
		m_itemWasDropped = ReadInt(setValue);
		break;
	case "sndAcquire":
		m_sndAcquire = ReadString(setValue);
		break;
	case "sndRespawn":
		m_sndRespawn = ReadString(setValue);
		break;
	case "sndHum":
		m_sndHum = ReadString(setValue);
		break;
	case "itemPickupFloats":
		m_itemPickupFloats = ReadBool(setValue);
		break;
	case "itemPickupSpins":
		m_itemPickupSpins = ReadBool(setValue);
		break;
	case "itemName":
		m_itemName = ReadString(setValue);
		break;
	case "itemWeapon":
		m_itemWeapon = ReadString(setValue);
		break;
	case "itemGivesHealth":
		m_itemGivesHealth = ReadInt(setValue);
		break;
	case "itemGivesBonusHealth":
		m_itemGivesBonusHealth = ReadInt(setValue);
		break;
	case "itemGivesBonusArmor":
		m_itemGivesBonusHealth = ReadInt(setValue);
		break;
	case "itemGivesArmor":
		m_itemGivesArmor = ReadInt(setValue);
		break;
	case "itemNoTouch":
		m_itemNoTouch = ReadBool(setValue);
		break;
	case "itemCarries":
		m_itemCarries = ReadBool(setValue);
		break;
	case "itemRequiresItem":
		m_itemRequiresItem = ReadString(setValue);
		break;
	case "hiddenModelIndex":
		m_hiddenModelIndex = ReadFloat(setValue);
		break;
	case "hiddenSequence":
		m_hiddenSequence = ReadFloat(setValue);
		break;
	case "nextItem":
		m_nextItem = (ncItem)ReadEntity(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}

void
ncItem::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	/* gamemodes can alternatively use this to set the respawn time of items post-init */
	case "SetRespawnTime":
		SetRespawnTime(stof(strData));
		break;
	default:
		ncTrigger::Input(eAct, strInput, strData);
	}
}

void
ncItem::OnUse(entity user)
{

}

void
ncItem::SetRespawnTime(float newTime)
{
	m_itemRespawn = newTime;
}

bool
ncItem::ItemBonusCheck(entity pickerUpper)
{
	ncActor pl = (ncActor)pickerUpper;

	if (m_itemGivesHealth > 0i) {
		if (pl.GetHealth() < pl.GetMaxHealth()) {
			return (true);
		}
	}

	if (m_itemGivesBonusHealth >= 1i && pl.GetHealth() < 200) {
		return (true);
	}

	if (m_itemGivesBonusArmor >= 1i && pl.GetArmor() < 200) {
		return (true);
	}

	if (m_itemGivesArmor > 0i) {
		if (pl.armor < pl.GetMaxArmor()) {
			return (true);
		}
	}

	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		if (m_itemGivesAmmo[i] > 0i) {
			if (pl.MaxAmmo(i) == false) {
				return (true);
			}
		}
	}

	return (false);
}

bool
ncItem::ItemPickupCheck(entity pickerUpper)
{
	ncActor pl = (ncActor)pickerUpper;

	/* do we already have the item? */
	if (STRING_SET(m_itemWeapon) || m_itemCarries) {
		string itemToAdd = (m_itemWeapon != "") ? m_itemWeapon : declclass;

		if (STRING_SET(itemToAdd)) {
			if (pl.HasItem(itemToAdd) == false) {
				return (true);
			}
		}
	}

	return (false);
}

void
ncItem::Touch(entity eToucher)
{
	ncPlayer pl;
	bool removeFromMap = false;

	if (is.Player(eToucher) == false) {
		return;
	}

	if (m_itemNoTouch) {
		return;
	}

	pl = (ncPlayer)eToucher;

	/* 'requires' affects main item and bonus items */
	if (STRING_SET(m_itemRequiresItem)) {
		if (pl.HasItem(m_itemRequiresItem) == false) {
			return;
		}
	}

	if (ItemBonusCheck(pl) == true) {
		GiveBonusItems(pl);
		removeFromMap = true;
	}

	if (ItemPickupCheck(pl) == true) {
		/* don't remove if AddItem fails */
		string itemToAdd = STRING_SET(m_itemWeapon) ? m_itemWeapon : declclass;

		if (CreatedByMap()) {
			ncItem copy = spawn(ncItem);
			copyentity(this, copy);
			pl.GiveExactItem(copy);
		} else {
			pl.GiveExactItem(this);
		}

		/* if we have the carry flag set in addition, we'll put in an extra copy of this item */
		if (STRING_SET(m_itemWeapon) && m_itemCarries) {
			pl.GiveItem(itemToAdd);
		}

		removeFromMap = true;
	}

	if (removeFromMap == false) {
		return;
	}

	UseTargets(pl, TRIG_TOGGLE, GetTriggerDelay());

	if (m_itemRespawn <= 0) {
		if (CreatedByMap()) {
			Disappear();
		} else {
			Destroy();
		}
	} else {
		if (m_hiddenSequence) {
			SetFrame(m_hiddenSequence);
		} else {
			Disappear();
		}

		ScheduleThink(PickupRespawn, m_itemRespawn);
	}
}

void ncItem::SetFloating(int i)
{
	m_itemPickupFloats = i ? (true) : (false);
}

bool
ncItem::GetFloating(void)
{
	return m_itemPickupFloats;
}

void
ncItem::SetSpinning(bool value)
{
	m_itemPickupSpins = value;
}

bool
ncItem::GetSpinning(void)
{
	return m_itemPickupSpins;
}


void
ncItem::PickupRespawn(void)
{
	Respawn();
	StartSoundDef(m_sndRespawn, CHAN_ITEM, true);
	ReleaseThink();
}

void
ncItem::OnPickup(void)
{
}

void
ncItem::OnInventoryUse(void)
{
}

void
ncItem::PrintDebugInfo(void)
{
	DebugInt("m_itemWasDropped", m_itemWasDropped);
	DebugString("m_sndAcquire", m_sndAcquire);
	DebugString("m_sndRespawn", m_sndRespawn);
	DebugString("m_sndHum", m_sndHum);
	DebugBool("m_itemPickupFloats", m_itemPickupFloats);
	DebugBool("m_itemPickupSpins", m_itemPickupSpins);
	DebugString("m_itemWeapon", m_itemWeapon);
}

void
ncItem::BecomePickup(void)
{
	SetBotTag(BOTINFO_WEAPON);
	SetModel(GetSpawnString("model"));

	if (m_itemPickupSpins)
		modelflags = MF_ROTATE;
	else
		modelflags &= ~MF_ROTATE;

	Show();
	SetFrame(GetSpawnFloat("frame"));
	m_hiddenSequence = GetSpawnFloat("hidden_frame");

	if (/*GetSpawnBool("physics") == true*/ 0) {
		/* be shootable! */
		Wake();
		SetMovetype(MOVETYPE_PHYSICS);
		SetSolid(SOLID_CORPSE);
	} else {
		vector desiredMins = GetSpawnVector("mins");
		vector desiredMaxs = GetSpawnVector("maxs");
		Sleep();
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_TRIGGER);
		MakeInvulnerable();

		if (desiredMins != g_vec_null) {
			mins = desiredMins;
		}

		if (desiredMaxs != g_vec_null) {
			maxs = desiredMaxs;
		}

		SetSize(mins, maxs);
	}

	Relink();
}

float
ncItem::SendEntity(entity ePEnt, float flChanged)
{
	bool inInventory = InInventory();

	/* item is in somebody elses inventory. */
	if (inInventory == true && ePEnt != GetOwner()) {
		return (false);
	}

	if (inInventory == true) {
		flChanged &= ~ITEMFL_CHANGED_ORIGIN_X;
		flChanged &= ~ITEMFL_CHANGED_ORIGIN_Y;
		flChanged &= ~ITEMFL_CHANGED_ORIGIN_Z;
		flChanged &= ~ITEMFL_CHANGED_ANGLES_X;
		flChanged &= ~ITEMFL_CHANGED_ANGLES_Y;
		flChanged &= ~ITEMFL_CHANGED_ANGLES_Z;
		flChanged &= ~ITEMFL_CHANGED_VELOCITY;
		flChanged &= ~ITEMFL_CHANGED_ANGULARVELOCITY;
		flChanged &= ~ITEMFL_CHANGED_RENDERPROPS;
	}


	WriteByte(MSG_ENTITY, ENT_ITEM);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(entityDefID, ITEMFL_CHANGED_MODELINDEX)
	SENDENTITY_ENTITY(m_nextItem, ITEMFL_CHANGED_CHAIN)
	SENDENTITY_ENTITY(owner, ITEMFL_CHANGED_CHAIN)
	SENDENTITY_COORD(origin[0], ITEMFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], ITEMFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], ITEMFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], ITEMFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], ITEMFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], ITEMFL_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, ITEMFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, ITEMFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(m_nuclideFlags, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], ITEMFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], ITEMFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], ITEMFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], ITEMFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], ITEMFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], ITEMFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, ITEMFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, ITEMFL_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, ITEMFL_CHANGED_EFFECTS)
	SENDENTITY_FLOAT(scale, ITEMFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], ITEMFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], ITEMFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], ITEMFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], ITEMFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], ITEMFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], ITEMFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_renderColor[0], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_renderColor[1], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_renderColor[2], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_renderAmount, ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_renderMode, ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_renderFX, ITEMFL_CHANGED_RENDERPROPS)

	return (true);
}

void
ncItem::EvaluateEntity(void)
{
	EVALUATE_FIELD(m_nextItem, ITEMFL_CHANGED_CHAIN)
	EVALUATE_FIELD(owner, ITEMFL_CHANGED_CHAIN)
	EVALUATE_VECTOR(origin, 0, ITEMFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, ITEMFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, ITEMFL_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, ITEMFL_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, ITEMFL_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, ITEMFL_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, ITEMFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(entityDefID, ITEMFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, BASEFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(movetype, ITEMFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, ITEMFL_CHANGED_FLAGS)
	EVALUATE_FIELD(modelflags, ITEMFL_CHANGED_FLAGS)
	EVALUATE_FIELD(m_nuclideFlags, ITEMFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, ITEMFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, ITEMFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, ITEMFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, ITEMFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, ITEMFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, ITEMFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, ITEMFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, ITEMFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, ITEMFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(scale, ITEMFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, ITEMFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, ITEMFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, ITEMFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, ITEMFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, ITEMFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, ITEMFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(m_renderColor, 0, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_VECTOR(m_renderColor, 1, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_VECTOR(m_renderColor, 2, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_renderAmount, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_renderMode, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_renderFX, ITEMFL_CHANGED_RENDERPROPS)

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
ncItem::ReceiveEntity(float flNew, float flChanged)
{
	_isItem = true;
	READENTITY_INT(entityDefID, ITEMFL_CHANGED_MODELINDEX)
	READENTITY_ENTNUM(chain_entnum, ITEMFL_CHANGED_CHAIN)
	READENTITY_ENTNUM(owner_entnum, ITEMFL_CHANGED_CHAIN)
	READENTITY_COORD(origin[0], ITEMFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], ITEMFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], ITEMFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], ITEMFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], ITEMFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], ITEMFL_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, ITEMFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, ITEMFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(flags, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(modelflags, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(m_nuclideFlags, ITEMFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], ITEMFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], ITEMFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], ITEMFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], ITEMFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], ITEMFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], ITEMFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, ITEMFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, ITEMFL_CHANGED_SKIN)
	READENTITY_FLOAT(effects, ITEMFL_CHANGED_EFFECTS)
	READENTITY_FLOAT(scale, ITEMFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], ITEMFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], ITEMFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], ITEMFL_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], ITEMFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], ITEMFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], ITEMFL_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_renderColor[0], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_renderColor[1], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_renderColor[2], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_renderAmount, ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_renderMode, ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_renderFX, ITEMFL_CHANGED_RENDERPROPS)

	/* expensive & this has to be done first, any code below may query decl */
	if (flChanged & ITEMFL_CHANGED_MODELINDEX) {
		EntityDef_SetFromEntNum(this, entityDefID);
	}

	/* HACK: PHYSICS should not run client-side, act as if it's 'none' */
	if (movetype == MOVETYPE_PHYSICS) {
		movetype = MOVETYPE_NONE;
	}

	drawmask = (modelindex != 0) ? MASK_ENGINE : 0;

	if (flChanged & ITEMFL_CHANGED_CHAIN) {
		m_nextItem = __NULL__;
	}

	if (scale == 0.0f) {
		scale = 1.0f;
	}

	if (flChanged & ITEMFL_CHANGED_SIZE || flChanged & ITEMFL_CHANGED_ORIGIN_X || flChanged & ITEMFL_CHANGED_ORIGIN_Y || flChanged & ITEMFL_CHANGED_ORIGIN_Z) {
		Relink();
	}
}

void
ncItem::ReceiveEvent(float eventType)
{
}

void
ncItem::PredictPreFrame(void)
{
	/* may no longer be valid */
	if (wasfreed(this)) {
		return;
	}

	/* relink, if still valid */
	if (m_nextItem == __NULL__ && chain_entnum) {
		m_nextItem = (ncItem)findentity(world, ::entnum, chain_entnum);
	}

	if (owner == __NULL__ && owner_entnum) {
		owner = findentity(world, ::entnum, owner_entnum);

		if (owner && owner == pSeat->m_ePlayer) {
			_AddedCallback();

			/* we may have been removed in _AddedCallback */
			if (wasfreed(this)) {
				return;
			}
		}
	}

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(flags)
	SAVE_STATE(m_nuclideFlags)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
	SAVE_STATE(scale)
	SAVE_STATE(velocity)
	SAVE_STATE(avelocity)
	SAVE_STATE(owner)
	SAVE_STATE(m_nextItem)
}

void
ncItem::PredictPostFrame(void)
{
	ROLL_BACK(origin)
	ROLL_BACK(angles)
	ROLL_BACK(solid)
	ROLL_BACK(movetype)
	ROLL_BACK(flags)
	ROLL_BACK(m_nuclideFlags)
	ROLL_BACK(mins)
	ROLL_BACK(maxs)
	ROLL_BACK(scale)
	ROLL_BACK(velocity)
	ROLL_BACK(avelocity)
	ROLL_BACK(owner)
	ROLL_BACK(m_nextItem)
}
#endif

void
ncItem::OnRemoveEntity(void)
{
	m_nextItem = 0;
	owner = 0;
}

void
ncItem::AddedToInventory(void)
{
}

void
ncItem::RemovedFromInventory(void)
{
}

bool
ncItem::InInventory(void)
{
	return (owner) ? (true) : (false);
}

bool
ncItem::IsWeapon(void)
{
	return (false);
}

#ifdef SERVER
void
ncItem::GiveBonusItems(entity theOwner)
{
	ncActor ourOwner = (ncActor)theOwner;

	/* let the client-game know, reliably - both us and our spectators perhaps. */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_PICKUP);
	WriteInt(MSG_MULTICAST, entityDefID);
	msg_entity = theOwner;
	multicast([0,0,0], MULTICAST_ONE_R);

	if (m_itemGivesHealth > 0i) {
		if (ourOwner.GetHealth() < 100) {
			ourOwner.SetHealth(bound(0, ourOwner.GetHealth() + m_itemGivesHealth, ourOwner.GetMaxHealth()));
		}
	}

	//EntWarning("m_itemGivesBonusHealth: %i", m_itemGivesBonusHealth);

	if (m_itemGivesBonusHealth > 0i && ourOwner.GetHealth() < 200) {
		ourOwner.AddBonusHealth((float)m_itemGivesBonusHealth);
	}

	if (m_itemGivesBonusArmor > 0i && ourOwner.GetArmor() < 200) {
		ourOwner.AddBonusArmor((float)m_itemGivesBonusArmor);
	}

	if (m_itemGivesArmor > 0i) {
		if (ourOwner.armor < 100) {
			ourOwner.armor += (float)m_itemGivesArmor;

			if (ourOwner.armor > 100) {
				ourOwner.armor = 100;
			}
		}
	}

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		ourOwner.GiveAmmo(i, m_itemGivesAmmo[i]);
	}
}
#endif

void
ncItem::_AddedCallback(void)
{
	ncActor ourOwner = (ncActor)owner;

#ifdef SERVER
	SendFlags |= -1;

	GiveBonusItems(ourOwner);

	Logging_Pickup(ourOwner, this, __NULL__);
	ourOwner.StartSoundDef(m_sndAcquire, CHAN_ITEM, true);
	OnPickup();
	MakeInvulnerable();
#endif
	Disappear();

	ourOwner.AddedItemCallback(this);
	AddedToInventory();
	SetMovetype(MOVETYPE_NONE);

#ifdef SERVER
	if (m_itemCarries == false) {
		Destroy();
	}
#endif
}

void
ncItem::_RemovedCallback(void)
{
	RemovedFromInventory();
	owner = __NULL__;
	chain = __NULL__;
	m_nextItem = __NULL__;
	ScheduleThink(Destroy, 0.0f);
}
