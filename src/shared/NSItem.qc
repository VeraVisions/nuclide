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
NSItem::NSItem(void)
{
	m_iClip = -1;
	m_iWasDropped = 0i;
	m_iInvItem = 0i;
	m_sndAcquire = __NULL__;
	m_sndRespawn = __NULL__;
	m_bFloating = false;
	m_bSpins = false;
	m_iGiveHealth = 0i;
	m_iGiveArmor = 0i;
	m_bNoTouch = false;
	m_bInvCarry = false;
	m_strRequires = __NULL__;
	m_nextItem = __NULL__;
	owner = __NULL__;
}

#ifdef SERVER
void
NSItem::Spawned(void)
{
	super::Spawned();

	Sound_Precache(m_sndAcquire);
	Sound_Precache(m_sndRespawn);
	pvsflags = PVSF_IGNOREPVS;
	_isItem = true;
}

void
NSItem::Respawn(void)
{
	super::Respawn();
	BecomePickup();

	/* being a physics entity, we might have to restore player physics */
	EnablePlayerCollision();

	if (CreatedByMap() == true) {
		RestoreAngles();
		SetOriginUnstick(GetSpawnVector("origin"));

		if (!m_bFloating) {
			DropToFloor();
		}
	}
}

void
NSItem::SpawnKey(string strKey, string strValue)
{
	/* special case for ammo type parsing... */
	if (substring(strKey, 0, 8) == "inv_ammo") {
		string ammoType = substring(strKey, 4, -1);
		int ammoID = ammoNumForName(ammoType);

		if (ammoID != -1) {
			m_GiveAmmo[ammoID] = stoi(unpackStringCommand(strValue));
		} else {
			NSError("Item %S tries to give invalid ammo type %S", declclass, ammoType);
		}
		return;
	}

	switch (strKey) {
	case "inv_weapon":
		m_strInvWeapon = ReadString(strValue);
		break;
	case "inv_item":
		m_iInvItem = ReadInt(strValue);
		break;
	case "snd_acquire":
		m_sndAcquire = ReadString(strValue);
		break;
	case "snd_respawn":
		m_sndRespawn = ReadString(strValue);
		break;
	case "modelflags":
		modelflags = ReadFloat(strValue);
		break;
	case "spin":
		m_bSpins = ReadBool(strValue);
		break;
	case "floating":
		m_bFloating = ReadBool(strValue);
		break;
	case "frame":
		frame = ReadFloat(strValue);
		break;
	case "body":
		m_iBody = ReadInt(strValue);
		break;
	case "inv_health":
		m_iGiveHealth = ReadFloat(strValue);
		break;
	case "inv_armor":
		m_iGiveArmor = ReadFloat(strValue);
		break;
	case "no_touch":
		m_bNoTouch = ReadBool(strValue);
		break;
	case "inv_carry":
		m_bInvCarry = ReadBool(strValue);
		break;
	case "requires":
		m_strRequires = ReadString(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSItem::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "m_iClip", m_iClip);
	SaveInt(handle, "m_iWasDropped", m_iWasDropped);
	SaveInt(handle, "m_iInvItem", m_iInvItem);
	SaveString(handle, "m_sndAcquire", m_sndAcquire);
	SaveString(handle, "m_sndRespawn", m_sndRespawn);
	SaveString(handle, "m_sndHum", m_sndHum);
	SaveBool(handle, "m_bFloating", m_bFloating);
	SaveBool(handle, "m_bSpins", m_bSpins);
	SaveString(handle, "m_strInvWeapon", m_strInvWeapon);
	SaveInt(handle, "m_iGiveHealth", m_iGiveHealth);
	SaveInt(handle, "m_iGiveArmor", m_iGiveArmor);
	SaveBool(handle, "m_bNoTouch", m_bNoTouch);
	SaveBool(handle, "m_bInvCarry", m_bInvCarry);
	SaveString(handle, "m_strRequires", m_strRequires);
}

void
NSItem::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iClip":
		m_iClip = ReadInt(strValue);
		break;
	case "m_iWasDropped":
		m_iWasDropped = ReadInt(strValue);
		break;
	case "m_iInvItem":
		m_iInvItem = ReadInt(strValue);
		break;
	case "m_sndAcquire":
		m_sndAcquire = ReadString(strValue);
		break;
	case "m_sndRespawn":
		m_sndRespawn = ReadString(strValue);
		break;
	case "m_sndHum":
		m_sndHum = ReadString(strValue);
		break;
	case "m_bFloating":
		m_bFloating = ReadBool(strValue);
		break;
	case "m_bSpins":
		m_bSpins = ReadBool(strValue);
		break;
	case "m_strInvWeapon":
		m_strInvWeapon = ReadString(strValue);
		break;

	case "m_iGiveHealth":
		m_iGiveHealth = ReadInt(strValue);
		break;
	case "m_iGiveArmor":
		m_iGiveArmor = ReadInt(strValue);
		break;
	case "m_bNoTouch":
		m_bNoTouch = ReadBool(strValue);
		break;
	case "m_bInvCarry":
		m_bInvCarry = ReadBool(strValue);
		break;
	case "m_strRequires":
		m_strRequires = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
NSItem::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	default:
		NSTrigger::Input(eAct, strInput, strData);
	}
}

void
NSItem::OnUse(entity user)
{

}

bool
NSItem::ItemPickupCheck(entity pickerUpper)
{
	NSActor pl = (NSActor)pickerUpper;

	/* do we already have the item? */
	if (STRING_SET(m_strInvWeapon) || m_bInvCarry) {
		string itemToAdd = (m_strInvWeapon != "") ? m_strInvWeapon : classname;

		if (STRING_SET(itemToAdd)) {
			if (pl.HasItem(itemToAdd) == false) {
				return (true);
			}
		}
	}

	if (m_iGiveHealth > 0i) {
		if (pl.GetHealth() < 100) {
			return (true);
		}
	}

	if (m_iGiveArmor > 0i) {
		if (pl.armor < 100) {
			return (true);
		}
	}

	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		if (m_GiveAmmo[i] > 0i) {
			if (pl.MaxAmmo(i) == false) {
				return (true);
			}
		}
	}

	return (false);
}

void
NSItem::Touch(entity eToucher)
{
	NSClientPlayer pl;

	if (isPlayer(eToucher) == false) {
		return;
	}

	pl = (NSClientPlayer)eToucher;

	if (STRING_SET(m_strRequires)) {
		if (pl.HasItem(m_strRequires) == false) {
			return;
		}
	}

	if (ItemPickupCheck(pl) == false) {
		return;
	}

	/* don't remove if AddItem fails */
	string itemToAdd = (m_strInvWeapon) ? m_strInvWeapon : classname;
	pl.GiveItem(itemToAdd);
	UseTargets(pl, TRIG_TOGGLE, m_flDelay);

	if (real_owner || m_iWasDropped == 1 || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(PickupRespawn, 30.0f);
	}
}

void NSItem::SetFloating(int i)
{
	m_bFloating = i ? true : false;
}

bool
NSItem::GetFloating(void)
{
	return m_bFloating;
}

void
NSItem::SetSpinning(bool value)
{
	m_bSpins = value;
}

bool
NSItem::GetSpinning(void)
{
	return m_bSpins;
}


void
NSItem::PickupRespawn(void)
{
	Respawn();
	StartSoundDef(m_sndRespawn, CHAN_ITEM, true);
	ReleaseThink();
}

void
NSItem::OnPickup(void)
{
}

void
NSItem::OnInventoryUse(void)
{
}

void
NSItem::PrintDebugInfo(void)
{
	DebugInt("m_iClip", m_iClip);
	DebugInt("m_iWasDropped", m_iWasDropped);
	DebugInt("m_iInvItem", m_iInvItem);
	DebugString("m_sndAcquire", m_sndAcquire);
	DebugString("m_sndRespawn", m_sndRespawn);
	DebugString("m_sndHum", m_sndHum);
	DebugBool("m_bFloating", m_bFloating);
	DebugBool("m_bSpins", m_bSpins);
	DebugString("m_strInvWeapon", m_strInvWeapon);
}

void
NSItem::BecomePickup(void)
{
	SetBotTag(BOTINFO_WEAPON);
	SetModel(GetSpawnString("model"));

	if (m_bSpins)
		modelflags = MF_ROTATE;
	else
		modelflags &= ~MF_ROTATE;

	Show();

	if (GetSpawnBool("physics") == true) {
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
NSItem::SendEntity(entity ePEnt, float flChanged)
{
	/* item is in somebody elses inventory. */
	if (InInventory() == true && ePEnt != GetOwner()) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_ITEM);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_ENTITY(m_nextItem, ITEMFL_CHANGED_CHAIN)
	SENDENTITY_ENTITY(owner, ITEMFL_CHANGED_CHAIN)
	SENDENTITY_COORD(origin[0], ITEMFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], ITEMFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], ITEMFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], ITEMFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], ITEMFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], ITEMFL_CHANGED_ANGLES_Z)
	SENDENTITY_INT(entityDefID, ITEMFL_CHANGED_MODELINDEX)
	SENDENTITY_SHORT(modelindex, ITEMFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, ITEMFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, ITEMFL_CHANGED_FLAGS)
	SENDENTITY_INT(vv_flags, ITEMFL_CHANGED_FLAGS)
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
	SENDENTITY_BYTE(m_vecRenderColor[0], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_vecRenderColor[1], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_vecRenderColor[2], ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_flRenderAmt, ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_iRenderMode, ITEMFL_CHANGED_RENDERPROPS)
	SENDENTITY_BYTE(m_iRenderFX, ITEMFL_CHANGED_RENDERPROPS)

	return (1);
}

void
NSItem::EvaluateEntity(void)
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
	EVALUATE_FIELD(vv_flags, ITEMFL_CHANGED_FLAGS)
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
	EVALUATE_VECTOR(m_vecRenderColor, 0, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_VECTOR(m_vecRenderColor, 1, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_VECTOR(m_vecRenderColor, 2, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_flRenderAmt, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_iRenderMode, ITEMFL_CHANGED_RENDERPROPS)
	EVALUATE_FIELD(m_iRenderFX, ITEMFL_CHANGED_RENDERPROPS)
}
#endif

#ifdef CLIENT
void
NSItem::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_ENTNUM(chain_entnum, ITEMFL_CHANGED_CHAIN)
	READENTITY_ENTNUM(owner_entnum, ITEMFL_CHANGED_CHAIN)
	READENTITY_COORD(origin[0], ITEMFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], ITEMFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], ITEMFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], ITEMFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], ITEMFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], ITEMFL_CHANGED_ANGLES_Z)
	READENTITY_INT(entityDefID, ITEMFL_CHANGED_MODELINDEX)
	READENTITY_SHORT(modelindex, ITEMFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, ITEMFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(flags, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(modelflags, ITEMFL_CHANGED_FLAGS)
	READENTITY_INT(vv_flags, ITEMFL_CHANGED_FLAGS)
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
	READENTITY_BYTE(m_vecRenderColor[0], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_vecRenderColor[1], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_vecRenderColor[2], ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_flRenderAmt, ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_iRenderMode, ITEMFL_CHANGED_RENDERPROPS)
	READENTITY_BYTE(m_iRenderFX, ITEMFL_CHANGED_RENDERPROPS)

	if (flChanged & ITEMFL_CHANGED_MODELINDEX) {
		classname = EntityDef_NameFromNetID(entityDefID);
		declclass = classname;
	}

	movetype = MOVETYPE_NONE;
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
NSItem::ReceiveEvent(float eventType)
{
}

void
NSItem::PredictPreFrame(void)
{
	if (wasfreed(this)) {
		return;
	}

	/* relink */
	if (m_nextItem == __NULL__ && chain_entnum)
		m_nextItem = (NSItem)findentity(world, ::entnum, chain_entnum);

	if (owner == __NULL__ && owner_entnum) {
		owner = findentity(world, ::entnum, owner_entnum);

		if (owner && owner == pSeat->m_ePlayer) {
			_AddedCallback();
		}
	}

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(flags)
	SAVE_STATE(vv_flags)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
	SAVE_STATE(scale)
	SAVE_STATE(velocity)
	SAVE_STATE(avelocity)
	SAVE_STATE(owner)
	SAVE_STATE(m_nextItem)
}

void
NSItem::PredictPostFrame(void)
{
	ROLL_BACK(origin)
	ROLL_BACK(angles)
	ROLL_BACK(solid)
	ROLL_BACK(movetype)
	ROLL_BACK(flags)
	ROLL_BACK(vv_flags)
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
NSItem::AddedToInventory(void)
{
}

void
NSItem::RemovedFromInventory(void)
{
}

bool
NSItem::InInventory(void)
{
	return (owner) ? (true) : (false);
}

bool
NSItem::IsWeapon(void)
{
	return (false);
}


void
NSItem::_AddedCallback(void)
{
	NSActor ourOwner = (NSActor)owner;

#if 0
	if (pSeat->m_ePlayer == owner) {
		localcmd("bf\n");
	}
#endif

#ifdef SERVER

	if (m_iGiveHealth > 0i) {
		if (ourOwner.GetHealth() < 100) {
			ourOwner.health = bound(0, ourOwner.health + m_iGiveHealth, ourOwner.max_health);
		}
	}

	if (m_iGiveArmor > 0i) {
		if (ourOwner.armor < 100) {
			ourOwner.armor += (float)m_iGiveArmor;

			if (ourOwner.armor > 100) {
				ourOwner.armor = 100;
			}
		}
	}

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		ourOwner.GiveAmmo(i, m_GiveAmmo[i]);
	}

	Logging_Pickup(ourOwner, this, __NULL__);
	ourOwner.StartSoundDef(m_sndAcquire, CHAN_ITEM, true);
	OnPickup();
	MakeInvulnerable();
#endif

	Disappear();
	ourOwner.AddedItemCallback(this);
	AddedToInventory();
	SetMovetype(MOVETYPE_NONE);
}

void
NSItem::_RemovedCallback(void)
{
	RemovedFromInventory();
	owner = __NULL__;
	chain = __NULL__;
	m_nextItem = __NULL__;
	Destroy();
}
