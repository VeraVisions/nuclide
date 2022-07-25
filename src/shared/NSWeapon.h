#define MAX_WEAPONS 32

class
NSWeapon:NSRenderableEntity
{
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

	/* inspired by GMOD API https://wiki.facepunch.com/gmod/Weapon */
	virtual string(void) GetPlayerModel;
	virtual string(void) GetWorldModel;
	virtual string(void) GetPrintName;
	virtual bool(void) AllowDropping;
	virtual int(void) GetPlayerAnim; /* aim anim */
	virtual string(void) GetObituaryMessage;
	virtual int(void) GetType;
	virtual entity(void) GetOwner;
	virtual int(void) GetClip1;					/* returns primary attack clip */
	virtual int(void) GetClip2;					/* returns secondary attack clip */
	virtual int(void) GetMaxClip1; 				/* returns primary max clip size */
	virtual int(void) GetMaxClip2;				/* returns secondary max clip size */
	virtual float(void) GetNextPrimaryFire;	/* gets next time the primary can fire */
	virtual float(void) GetNextSecondaryFire;/* gets next time the secondary can fire */
	virtual bool(void) HasAmmo;
	virtual int(void) GetSlot;
	virtual int(void) GetSlotPos;
	virtual int(void) GetWeight;
	virtual float(void) LastFireTime;		/* returns absolute time at which the weapon was last fired */
	virtual void(int) SetClip1;					/* sets the primary ammo clip */
	virtual void(int) SetClip2;					/* sets the secondary ammo clip */
	virtual bool(void) AllowsAutoSwitchFrom;	/* whether the weapon allows to being switched from when a better weighted weapon is picked up */
	virtual bool(void) AllowsAutoSwitchTo;	/* whether the weapon allows to being switched to when a better weighted weapon is picked up */

	/* calls */
	virtual void(void) Precache;
	virtual void(void) Draw;
	virtual void(void) Holster;
	virtual void(void) Primary;
	virtual void(void) Secondary;
	virtual void(void) Reload;
	virtual void(void) Release;
	virtual void(void) ClientPredraw;
	virtual void(void) ClientPostdraw;
};