/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/** id Tech 4 keys to support:


*/



/*! \brief This entity class represents non-player characters. */
/*!QUAKED NSMonster (0 0.8 0.8) (-16 -16 0) (16 16 72) WAITTILLSEEN GAG MONSTERCLIP x PRISONER x IGNOREPLAYER WAITFORSCRIPT PREDISASTER FADECORPSE MULTIPLAYER FALLING HORDE
# OVERVIEW
Represents any item within the players' inventory.
These can be used, or be dormant.

# KEYS
- "targetname" : Name
- "model" : world model.
- "model_view" : view model.
- "model_world - same as model.
- "inv_name" : Fancy title. Can be a localized string.
- "inv_weapon" : name of the weapon to give on pickup. can be the same as this entitydef.
- "inv_item" : item number. must be unique.
- "weapon_scriptobject" : mapC progs with the weapon code within.
- "ammoType" : name of the ammo type def entry which the gun uses
- "ammoRequired" : set to 1 if we require ammo. 
- "clipSize" : maximum clip size
- "mtr_flashShader" : muzzleflash material to Use.
- "model_flash" : muzzleflash model/sprite to use.
- "flashColor" : muzzleflash dlight color
- "flashRadius" : muzzleflash dlight radius
- "def_dropItem" : when this item is dropped from someones inventory, will spawn this entityDef item instead.
- "snd_acquire" : pickup noise
- "snd_respawn" : respawn noise
- "snd_hum" : idle shader
- "smoke_muzzle" : smoke particle effect name
- "continuousSmoke" : whether the particle effect is continous
- "clipSizeDefault" : CUSTOM: Default clip size on pickup.
*/
class NSItem:NSRenderableEntity
{
public:
	void NSItem(void);

	/* overrides */
#ifdef SERVER
	virtual void Spawned(void);
	virtual void Touch(entity);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);

	nonvirtual void SetItem(int i);
	nonvirtual int GetItem(void);
	nonvirtual void SetFloating(int);
	nonvirtual bool GetFloating(void);
	nonvirtual void SetSpinning(bool);
	nonvirtual bool GetSpinning(void);
	nonvirtual void PickupRespawn(void);
#endif


private:
	int m_iClip;
	int m_iWasDropped;

	/* spawn keys */
	int m_iInvItem;
	string m_sndAcquire;
	string m_sndRespawn;
	int m_bFloating;
	bool m_bSpins;
	string m_strInvWeapon;
};