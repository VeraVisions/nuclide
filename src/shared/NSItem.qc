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
#ifdef SERVER
	m_iClip = -1;
	m_iWasDropped = 0i;
	m_iInvItem = 0i;
	m_sndAcquire = __NULL__;
	m_sndRespawn = __NULL__;
	m_bFloating = false;
	m_bSpins = false;
#endif
}

#ifdef SERVER
void
NSItem::Spawned(void)
{
	super::Spawned();

	Sound_Precache(m_sndAcquire);
	Sound_Precache(m_sndRespawn);
}

void
NSItem::Respawn(void)
{
	/* we need to delay the DropToFloor() by at least a frame.
	   otherwise they may just fall through an entity (func_wall, func_train etc.)
	   that came after this entity in the lump. */
	static void AdjustSpawnPos(void) {
		RestoreAngles();
		SetOrigin(GetSpawnOrigin());

		if (!m_bFloating) {
			DropToFloor();
			SetMovetype(MOVETYPE_TOSS);
		}
	}

	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	botinfo = BOTINFO_WEAPON;

	if (m_bSpins)
		modelflags = MF_ROTATE;
	else
		modelflags &= ~MF_ROTATE;

	/* At some points, the item id might not yet be set */
	if (GetSpawnModel()) {
		SetModel(GetSpawnModel());
	}

	SetSize([-16,-16,0], [16,16,16]);
	ScheduleThink(AdjustSpawnPos, 0.0f);
}

void
NSItem::SpawnKey(string strKey, string strValue)
{
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
	case "frame":
		frame = ReadFloat(strValue);
		break;
	case "body":
		m_iBody = ReadInt(strValue);
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
	SaveBool(handle, "m_bFloating", m_bFloating);
	SaveBool(handle, "m_bSpins", m_bSpins);
	SaveString(handle, "m_strInvWeapon", m_strInvWeapon);
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
	case "m_bFloating":
		m_bFloating = ReadBool(strValue);
		break;
	case "m_bSpins":
		m_bSpins = ReadBool(strValue);
		break;
	case "m_strInvWeapon":
		m_strInvWeapon = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
NSItem::Touch(entity eToucher)
{
	NSClientPlayer pl = (NSClientPlayer)eToucher;

	if (eToucher.classname != "player") {
		return;
	}

#if 0
	/* don't remove if AddItem fails */
	if (pl.GiveWeapon(m_strInvWeapon) == false) {
		return;
	}
#endif

	Logging_Pickup(eToucher, this, __NULL__);
	StartSoundDef(m_sndAcquire, CHAN_ITEM, true);

	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	if (real_owner || m_iWasDropped == 1 || cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(PickupRespawn, 30.0f);
	}
}

void
NSItem::SetItem(int i)
{
	m_iInvItem = i;
	m_oldModel = Weapons_GetWorldmodel(m_iInvItem);
	SetModel(GetSpawnModel());
	SetSize([-16,-16,0], [16,16,16]);
}

int
NSItem::GetItem(void)
{
	return m_iInvItem;
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
}

void
NSItem::Draw(void)
{
}

void
NSItem::Holster(void)
{
}

void
NSItem::PrimaryAttack(void)
{
}

void
NSItem::SecondaryAttack(void)
{
}

void
NSItem::Reload(void)
{
}

void
NSItem::Release(void)
{
}

void
NSItem::OnPickup(void)
{
}

void
NSItem::OnInventoryUse(void)
{
}
#endif

