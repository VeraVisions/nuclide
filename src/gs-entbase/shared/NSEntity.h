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

/* NSEntity is the lowest, user accessible class.
   It's responsible for handling practically every entity in Nuclide.
*/

class NSEntity:NSTrigger
{
	void(void) NSEntity;

	/* these are the real bounds, whereas .mins .maxs are affected by .scale */
	vector m_vecMins;
	vector m_vecMaxs;

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

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
	virtual void(void) postdraw;
	virtual void(void) RendererRestarted;
	virtual void(void) ClientRemove;
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
	/* respawn */
	float m_oldSolid;
	vector m_oldOrigin;
	vector m_oldAngle;
	string m_oldModel;

	string m_parent;
	string m_parent_attachment;

	virtual void(void) Show;
	virtual void(void) Hide;
	virtual void(void) EvaluateEntity;
	virtual float(entity, vector) SendEntity;

	nonvirtual void(string) SetParent;
	nonvirtual void(string) SetParentAttachment;
	nonvirtual void(void) ClearParent;
	virtual void(void) ParentUpdate;

	/* some ents need this */
	nonvirtual void(void) RestoreAngles;
	nonvirtual void(void) ClearAngles;

	nonvirtual vector(void) GetSpawnOrigin;
	nonvirtual vector(void) GetSpawnAngles;
	nonvirtual string(void) GetSpawnModel;
#endif

	virtual void(float) SetScale;
	virtual void(entity) SetOwner;
	virtual void(vector) SetVelocity;
	virtual void(void()) SetTouch;
	virtual void(float) SetSendFlags;
	virtual void(float) SetSolid;
	virtual void(string) SetModel;
	virtual void(float) SetModelindex;
	virtual void(float) SetMovetype;
	virtual void(vector) SetAngles;
	virtual void(vector) SetOrigin;
	virtual void(vector, vector) SetSize;
	virtual void(string, string) SpawnKey;
	nonvirtual void(void) Destroy;
	virtual void(void) UpdateBounds;
};
