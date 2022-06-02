/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

enumflags
{
	BASEFL_CHANGED_ORIGIN,
	BASEFL_CHANGED_ANGLES,
	BASEFL_CHANGED_MODELINDEX,
	BASEFL_CHANGED_SIZE,
	BASEFL_CHANGED_FLAGS,
	BASEFL_CHANGED_SOLID,
	BASEFL_CHANGED_FRAME,
	BASEFL_CHANGED_SKIN,
	BASEFL_CHANGED_MOVETYPE,
	BASEFL_CHANGED_EFFECTS,
	BASEFL_CHANGED_BODY,
	BASEFL_CHANGED_SCALE,
	BASEFL_CHANGED_VELOCITY,
#ifdef GS_RENDERFX
	BASEFL_CHANGED_RENDERCOLOR,
	BASEFL_CHANGED_RENDERAMT,
	BASEFL_CHANGED_RENDERMODE,
#else
	BASEFL_CHANGED_ALPHA,
#endif
};

/* NSEntity is the lowest, user accessible class.
   It's responsible for handling practically every entity in Nuclide.
*/
class NSEntity:NSTrigger
{
	void(void) NSEntity;

	/* these are the real bounds, whereas .mins .maxs are affected by .scale */
	vector m_vecMins;
	vector m_vecMaxs;

	/* important spawn values */
	vector m_oldOrigin;
	vector m_oldAngle;
	string m_oldModel;
	float m_oldSolid;

	/* keep track of these variables */
	PREDICTED_VECTOR_N(origin);
	PREDICTED_VECTOR_N(angles);
	PREDICTED_FLOAT_N(modelindex);
	PREDICTED_VECTOR_N(size);
	PREDICTED_FLOAT_N(solid);
	PREDICTED_FLOAT_N(movetype);
	PREDICTED_FLOAT_N(scale);
	PREDICTED_FLOAT_N(flags);
	PREDICTED_VECTOR_N(velocity);

	/* not needed to be saved right now */
	float m_flTouchTime;
	bool m_beingTouched;
	entity m_eTouchLast;

	virtual void(void) Spawned;

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
	virtual void(void) postdraw;
	virtual void(void) RendererRestarted;
	virtual void(void) OnRemoveEntity;
#endif

	/* overrides */
#ifdef SERVER
	virtual void(void) Respawn;
	virtual void(entity, string, string) Input;
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(void) RestoreComplete;
#endif

#ifdef SERVER
	string m_parent;
	string m_parent_attachment;

	virtual void(void) Show;
	virtual void(void) Hide;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;

	nonvirtual entity(void) GetParent;
	nonvirtual void(string) SetParent;
	nonvirtual void(string) SetParentAttachment;
	nonvirtual void(void) ClearParent;
	virtual void(void) ParentUpdate;

	/* some ents need this */
	nonvirtual void(void) RestoreAngles;
	nonvirtual void(void) ClearAngles;
#endif

	/* sets */
	virtual void(float) SetScale;
	virtual void(entity) SetOwner;
	virtual void(vector) SetVelocity;
	virtual void(void()) SetTouch;
	virtual void(float) SetSendFlags;
	virtual void(float) SetSolid;
	virtual void(string) SetModel;
	virtual void(float) SetModelindex;
	virtual void(float) SetMovetype;
	virtual void(float) SetGravity;
	virtual void(vector) SetAngles;
	virtual void(vector) SetAngularVelocity;
	virtual void(vector) SetOrigin;
	virtual void(vector, vector) SetSize;
	virtual void(float) AddFlags;
	virtual void(float) RemoveFlags;
	/* gets */
	nonvirtual vector(void) GetSpawnOrigin;
	nonvirtual vector(void) GetSpawnAngles;
	nonvirtual string(void) GetSpawnModel;

	virtual float(void) GetScale;
	virtual entity(void) GetOwner;
	virtual vector(void) GetVelocity;
	virtual float(void) GetSolid;
	virtual string(void) GetModel;
	virtual float(void) GetModelindex;
	virtual float(void) GetMovetype;
	virtual float(void) GetGravity;
	virtual vector(void) GetAngles;
	virtual vector(void) GetAngularVelocity;
	virtual vector(void) GetOrigin;
	virtual vector(void) GetMins;
	virtual vector(void) GetMaxs;
	virtual vector(void) GetRealMins;
	virtual vector(void) GetRealMaxs;
	virtual vector(void) GetAbsoluteMins;
	virtual vector(void) GetAbsoluteMaxs;
	virtual float(void) GetFlags;

	virtual void(string, string) SpawnKey;
	virtual void(void) Destroy;
	virtual void(void) UpdateBounds;

	/* useful methods, based on GMod's API */
	nonvirtual float(void) EntIndex;
	nonvirtual void(void) DropToFloor;
	nonvirtual vector(void) GetForward;
	nonvirtual vector(void) GetRight;
	nonvirtual vector(void) GetUp;
	nonvirtual vector(void) WorldSpaceCenter;
	nonvirtual float(void) WaterLevel;
	nonvirtual bool(entity) Visible;
	nonvirtual bool(vector) VisibleVec;
	nonvirtual bool(float) HasSpawnFlags;
	nonvirtual bool(void) IsOnGround;
	nonvirtual entity(void) GetGroundEntity;
	virtual void(entity) Blocked;
	nonvirtual void(void) BlockedHandler;
	nonvirtual bool(void) CreatedByMap;

	virtual void(entity) StartTouch;
	virtual void(entity) Touch;
	virtual void(entity) EndTouch;
	nonvirtual void(void) TouchHandler;

	virtual void(void) OnRemoveEntity;
};
