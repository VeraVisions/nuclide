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

typedef enumflags
{
	ITEMFL_CHANGED_MODELINDEX,
	ITEMFL_CHANGED_ORIGIN_X,
	ITEMFL_CHANGED_ORIGIN_Y,
	ITEMFL_CHANGED_ORIGIN_Z,
	ITEMFL_CHANGED_ANGLES_X,
	ITEMFL_CHANGED_ANGLES_Y,
	ITEMFL_CHANGED_ANGLES_Z,
	ITEMFL_CHANGED_VELOCITY_X,
	ITEMFL_CHANGED_VELOCITY_Y,
	ITEMFL_CHANGED_VELOCITY_Z,
	ITEMFL_CHANGED_ANGULARVELOCITY,
	ITEMFL_CHANGED_SIZE,
	ITEMFL_CHANGED_FLAGS,
	ITEMFL_CHANGED_SOLID,
	ITEMFL_CHANGED_FRAME,
	ITEMFL_CHANGED_SKIN,
	ITEMFL_CHANGED_MOVETYPE,
	ITEMFL_CHANGED_EFFECTS,
	ITEMFL_CHANGED_SCALE,
	ITEMFL_CHANGED_ENTITYDEF,
	ITEMFL_CHANGED_CHAIN,
} nsitem_changed_t;

/*! \brief This entity class represents inventory items, weapons. */
/*!QUAKED NSItem (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
Represents any item within the players' inventory.
These can be used, or be dormant.

# KEYS
- "targetname" : Name
- "model" : world model.
- "model_view" : view model.
- "model_world" : same as model.
- "model_player" : (Optional) when equipped, will use this model.
- "inv_name" : Fancy title. Can be a localized string.
- "inv_weapon" : name of the weapon to give on pickup. can be the same as this entitydef.
- "inv_item" : item number. must be unique.
- "inv_health" : How much health points to give on pick-up.
- "inv_armor" : How much armor points to give on pick-up.
- "no_touch" : If 1, will have to be triggered to be given to the activator.
- "inv_carry" : If 1, will not use the item instantly.
- "inv_icon" : Material for HUD graphics.
- "requires" : Name of the item that has to be present in the players inventory in order to be picked up.


@ingroup baseclass
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
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);

	/* item related accessors */
	nonvirtual void SetItem(int i);
	nonvirtual int GetItem(void);
	nonvirtual void SetFloating(int);
	nonvirtual bool GetFloating(void);
	nonvirtual void SetSpinning(bool);
	nonvirtual bool GetSpinning(void);
	nonvirtual void PickupRespawn(void);

	/* only if the entity is usable in the inventory. */
	virtual void OnInventoryUse(void);

	/** Overridable: Called when this item is picked up. */
	virtual void OnPickup(void);

	virtual void PrintDebugInfo(void);
	/** Call to turn a weapon into a pickup. */
	nonvirtual void BecomePickup(void);
#endif

	/** Called when an item was added to someones inventory. */
	virtual void AddedToInventory(void);
	/** Called when an item was removed from someones inventory. */
	virtual void RemovedFromInventory(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual void ReceiveEvent(float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
#endif

	virtual bool IsWeapon(void);
	virtual bool InInventory(void);

private:
	/** Called to signal that the owner added this weapon to their inventory. */
	virtual void _AddedCallback(void);
	/** Called to signal that the owner removed this weapon from their inventory. */
	virtual void _RemovedCallback(void);

	int m_iClip;
	int m_iWasDropped;

	/* item related spawn keys */
	int m_iInvItem;
	string m_sndAcquire;
	string m_sndRespawn;
	string m_sndHum;
	int m_bFloating;
	bool m_bSpins;
	string m_strInvName;
	string m_strInvWeapon;

	int m_iGiveHealth;
	int m_iGiveArmor;
	bool m_bNoTouch;
	bool m_bInvCarry;
	string m_strRequires;

	int m_GiveAmmo[MAX_AMMO_TYPES];

#ifdef CLIENT
	NETWORKED_FLOAT(chain_entnum)
	NETWORKED_FLOAT(owner_entnum)
#endif

	NSItem m_nextItem;
	NSItem m_nextItem_net;
	entity owner_net;
};
