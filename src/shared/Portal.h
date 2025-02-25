/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
	PORTALFL_CHANGED_ORIGIN_X,
	PORTALFL_CHANGED_ORIGIN_Y,
	PORTALFL_CHANGED_ORIGIN_Z,
	PORTALFL_CHANGED_ANGLES_X,
	PORTALFL_CHANGED_ANGLES_Y,
	PORTALFL_CHANGED_ANGLES_Z,
	PORTALFL_CHANGED_TARG_ENTITY,
	PORTALFL_CHANGED_TARG_ORIGIN_X,
	PORTALFL_CHANGED_TARG_ORIGIN_Y,
	PORTALFL_CHANGED_TARG_ORIGIN_Z,
	PORTALFL_CHANGED_TARG_ANGLES_X,
	PORTALFL_CHANGED_TARG_ANGLES_Y,
	PORTALFL_CHANGED_TARG_ANGLES_Z,
	PORTALFL_CHANGED_ENABLED,
	PORTALFL_CHANGED_MODELINDEX
} nsportal_changed_t;

class
ncPortal:ncEntity
{
	void ncPortal(void);

	nonvirtual void _PortalUpdated(void);
	nonvirtual vector _OriginTransform(vector);
	nonvirtual vector _DirectionTransform(vector);

	/** overrides */
	virtual vector camera_transform(vector, vector);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);

	virtual void PortalWasClosed(void);
	virtual void PortalWasOpened(void);

	/** Sets the ncPortal ID. Only used to link portals together via PortalAutoLink. */
	nonvirtual void SetPortalID(int);
	/** Will link this portal to another ncPortal. */
	nonvirtual bool PortalLinkTo(ncPortal, bool);
	/** Will link this portal to the youngest other ncPortal. */
	nonvirtual void PortalAutoLink(bool);
	/** Closes the portal, will not remove it from world. */
	nonvirtual void PortalClose(void);
	/** Sets the model to use for the portal. */
	nonvirtual void SetPortalModel(string);
#endif
#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
	virtual float predraw(void);
#endif

private:
	ncPortal m_ePortalTarget;
	ncPortal m_ePortalTarget_net;
	NETWORKED_VECTOR(m_vecTargetPos)
	NETWORKED_VECTOR(m_vecTargetAngle)
	NETWORKED_BOOL(m_bEnabled)
	NETWORKED_FLOAT(m_flPortalModel)

	vector m_vecPortalPos;
	vector m_vecPortalN;
	vector m_vecPortalS;
	vector m_vecPortalT;

	bool m_bWasEnabled;

	/** Will transport an entity from its position to the exit position. */
	nonvirtual void TransportEntity(ncEntity);

	vector m_vecTargetPos;
	vector m_vecTargetN;
	vector m_vecTargetS;
	vector m_vecTargetT;

#ifdef CLIENT
	float m_flSize;
#endif

#ifdef SERVER
	int m_iPortalValue;
#endif

	int m_brushNum;
};

#ifdef CLIENT
#define READENTITY_PORTAL(field, changedflag) {\
	if (flChanged & changedflag) {\
		field = (ncPortal)findfloat(world, ::entnum, readentitynum());\
		PRINTFLAG(changedflag); \
	}\
}
#endif

#define SOLID_PORTAL 21

.float portalnum;
.float impulse;	 //used as the radius for the solid_portal csg subtraction
.bool isPortal;
