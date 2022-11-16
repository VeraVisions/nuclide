#define MAX_WEAPONS 32

/** This class represents inventory items and weapons that you can directly interact with.

*/
class
NSWeapon:NSRenderableEntity
{
private:
	entity m_owner;

	string m_strName;	/* Full character name */
	int m_iSlot;
	int m_iSlotPos;
	bool m_bAllowDropping;
	int m_iWeight;

	/* generic info */
	int m_iClip1;
	int m_iClip2;
	float m_flPrimaryNext;
	float m_flSecondaryNext;
	float m_flLastFired;

public:
	void NSWeapon(void);

	/* inspired by GMOD API https://wiki.facepunch.com/gmod/Weapon */
	/** Returns the model used to attach to players that wield this weapon */
	virtual string GetPlayerModel(void);
	/** Returns the model used to display in-world representations of this weapon. */
	virtual string GetWorldModel(void);
	/** Returns the name used in printed text for this weapon */
	virtual string GetPrintName(void);
	/** Returns if this weapon is allowed to be dropped. */
	virtual bool AllowDropping(void);
	/** Returns the framegroup used for the top-half of a player when aiming this weapon. */
	virtual int GetPlayerAnim(void);
	/** Returns a formatted obituary message.
	Should contain two %s parameters, the first is the attacker and the second is the target. */
	virtual string GetObituaryMessage(void);
	/** Returns the weapon type. Check weapontype_t for details. */
	virtual int GetType(void);

	/** Returns primary attack clip */
	virtual int GetClip1(void);
	/** Returns secondary attack clip */
	virtual int GetClip2(void);
	/** Returns primary max clip size */
	virtual int GetMaxClip1(void);
	/** Returns secondary max clip size */
	virtual int GetMaxClip2(void);
	/** Returns the next time the primary mode can fire */
	virtual float GetNextPrimaryFire(void);
	/** Returns the next time the secondary mode can fire */
	virtual float GetNextSecondaryFire(void);
	/** Returns the slot/HUD category the weapon belongs in. */
	virtual int GetSlot(void);
	/** Returns the position the weapon belongs in of the slot specified in GetSlot() */
	virtual int GetSlotPos(void);
	/** Returns the 'weight', used for deciding what the next best weapon to switch to is. */
	virtual int GetWeight(void);
	/** Returns absolute time at which the weapon was last fired */
	virtual float LastFireTime(void);
	/** Sets the primary ammo clip count */
	virtual void SetClip1(int);
	/** Sets the secondary ammo clip count */
	virtual void SetClip2(int);
	/** Returns whether the weapon allows to being switched from when a better weighted weapon is picked up */
	virtual bool AllowsAutoSwitchFrom(void);
	/** Returns whether the weapon allows to being switched to when a better weighted weapon is picked up */
	virtual bool AllowsAutoSwitchTo(void);
	/** Returns if the weapon is empty, with no reserve ammonition */
	virtual bool IsEmpty(void);
	/** Returns if the weapon has ammo left in it. */
	virtual bool HasAmmo(void);

	/* calls */
	/** Called to reload resources utilized by this weapon. */
	virtual void Precache(void);
	/** Called when the weapon was switched to from another. */
	virtual void Draw(void);
	/** Called right before switching to a new weapon. */
	virtual void Holster(void);
	/** Called whenever the command +attack is called by a client. */
	virtual void Primary(void);
	/** Called whenever the command +attack2 is called by a client. */
	virtual void Secondary(void);
	/** Called whenever the command +reload is called by a client. */
	virtual void Reload(void);
	/** Called whenever the no weapon command is called by a client. */
	virtual void Release(void);
	/** Called before 3D world rendering is performed. */
	virtual void ClientPredraw(void);
	/** Called after 3D world rendering is performed. */
	virtual void ClientPostdraw(void);
};