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
	RDENT_CHANGED_ORIGIN_X,
	RDENT_CHANGED_ORIGIN_Y,
	RDENT_CHANGED_ORIGIN_Z,
	RDENT_CHANGED_ANGLES_X,
	RDENT_CHANGED_ANGLES_Y,
	RDENT_CHANGED_ANGLES_Z,
	RDENT_CHANGED_MODELINDEX,
	RDENT_CHANGED_SIZE,
	RDENT_CHANGED_FLAGS,
	RDENT_CHANGED_SOLIDMOVETYPE,
	RDENT_CHANGED_FRAME,
	RDENT_CHANGED_SKIN,
	RDENT_CHANGED_EFFECTS,
	RDENT_CHANGED_BODY,
	RDENT_CHANGED_SCALE,
	RDENT_CHANGED_VELOCITY,
	RDENT_CHANGED_ANGULARVELOCITY,
	RDENT_CHANGED_RENDERCOLOR,
	RDENT_CHANGED_RENDERAMT,
	RDENT_CHANGED_RENDERMODE,
	RDENT_CHANGED_CONTROLLER
} nsrenderableentity_changed_t;

typedef enum
{ 
	RM_NORMAL = 0,
	RM_COLOR = 1,
	RM_TEXTURE = 2,
	RM_GLOW = 3,
	RM_SOLID = 4,
	RM_ADDITIVE = 5,
	RM_FULLBRIGHT = 6,
	RM_ADDFRAC = 7, /* Source 2004 */
	RM_WORLDGLOW = 9, /* Source 2004 */
	RM_DONTRENDER = 10, /* Source 2004 */
} rendermode_t;

typedef enum
{
	RFX_NORMAL = 0,
	RFX_SLOWPULSE = 1,
	RFX_FASTPULSE = 2,
	RFX_SLOWWIDEPULSE = 3,
	RFX_FASTWIDEPULSE = 4,
	RFX_SLOWFADEAWAY = 5,
	RFX_FASTFADEAWAY = 6,
	RFX_SLOWBECOMESOLID = 7,
	RFX_FASTBECOMESOLID = 8,
	RFX_SLOWSTROBE = 9,
	RFX_FASTSTROBE = 10,
	RFX_FASTERSTROBE = 11,
	RFX_SLOWFLICKER = 12,
	RFX_FASTFLICKER = 13,
	RFX_CONSTANTGLOW = 14,
	RFX_DISTORT = 15,
	RFX_HOLOGRAM = 16,
	RFX_GLOWSHELL = 19,
	RFX_GLOWSHELL2 = 20,
	RFX_Q2PULSE = 21
} renderfx_t;

#ifdef CLIENT
var int autocvar_rm_unlit_additive = TRUE;
var int autocvar_rm_unlit_texture = TRUE;
#endif

/** This entity represents any NSEntity with advanced rendering properties.
This includes GoldSource and Source Engine style rendering effects.

This is the bare minimum for most characters as it allows for body
and bone control settings. */
class NSRenderableEntity:NSEntity
{
private:
	/* new */
	PREDICTED_FLOAT(m_flBoneControl1)
	PREDICTED_FLOAT(m_flBoneControl2)
	PREDICTED_FLOAT(m_flBoneControl3)
	PREDICTED_FLOAT(m_flBoneControl4)
	PREDICTED_FLOAT(m_flBoneControl5)
	PREDICTED_FLOAT_N(modelflags)
	PREDICTED_INT(m_iBody)
	PREDICTED_FLOAT_N(colormap)
	PREDICTED_VECTOR_N(glowmod)

	PREDICTED_FLOAT(m_iRenderFX)
	PREDICTED_FLOAT(m_iRenderMode)
	PREDICTED_FLOAT(m_flRenderAmt)
	PREDICTED_VECTOR(m_vecRenderColor)
	PREDICTED_VECTOR(m_vecAxialScale)

	/* model events */
	float m_flBaseTime;

#ifdef CLIENT
	nonvirtual void _UpdateGeomset();
#endif

#ifdef SERVER
	/* respawn */
	float m_oldiRenderFX;
	float m_oldiRenderMode;
	float m_oldflRenderAmt;
	vector m_oldvecRenderColor;
#endif


public:
	void NSRenderableEntity(void);

	/* overrides */
	virtual void SpawnKey(string,string);
#ifdef SERVER
	virtual void Input(entity,string,string);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void RenderDebugSkeleton(void);
	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
	virtual void RendererRestarted();
#endif

	virtual void MakeStatic(void);

	/* model events */
	/** Callback for any model event that gets triggered while playing a framegroup. */
	virtual void HandleAnimEvent(float,int,string);

	/* set */
	/** Sets the bodygroup of the entity. */
	nonvirtual void SetBody(int);
	/** Sets the body inside of a specific group. */
	nonvirtual void SetBodyInGroup(int, int);
	/** Sets the render FX type of the entity. Check renderfx_t for details. */
	nonvirtual void SetRenderFX(float);
	/** Sets the render mode type of the entity. Check rendermode_t for details. */
	nonvirtual void SetRenderMode(float);
	/** Sets the render amount of the entity. This depdends on the context. */
	nonvirtual void SetRenderAmt(float);
	/** Sets the render color of the entity. */
	nonvirtual void SetRenderColor(vector);
	/** Sets the value of the bone controller #1. */
	nonvirtual void SetBoneControl1(float);
	/** Sets the value of the bone controller #2. */
	nonvirtual void SetBoneControl2(float);
	/** Sets the value of the bone controller #3. */
	nonvirtual void SetBoneControl3(float);
	/** Sets the value of the bone controller #4. */
	nonvirtual void SetBoneControl4(float);
	/** Sets the value of the bone controller #5. */
	nonvirtual void SetBoneControl5(float);
	/** Sets the axial, anisotropic scale of an entity, affecting the individual axis (forward, right, up). */
	nonvirtual void SetAxialScale(vector);

	/** Returns the bodygroup of the entity. */
	nonvirtual int GetBody(void);
	/** Returns the body within a given group. */
	nonvirtual int GetBodyInGroup(int);
	/** Returns the render mode of the entity. */
	nonvirtual float GetRenderMode(void);
	/** Returns the render FX of the entity. */
	nonvirtual float GetRenderFX(void);
	/** Returns the render amount of the entity. */
	nonvirtual float GetRenderAmt(void);
	/** Returns the render color of the entity. */
	nonvirtual vector GetRenderColor(void);
	/** Returns the value of the entity's bone controller #1. */
	nonvirtual float GetBoneControl1(void);
	/** Returns the value of the entity's bone controller #2. */
	nonvirtual float GetBoneControl2(void);
	/** Returns the value of the entity's bone controller #3. */
	nonvirtual float GetBoneControl3(void);
	/** Returns the value of the entity's bone controller #4. */
	nonvirtual float GetBoneControl4(void);
	/** Returns the value of the entity's bone controller #5. */
	nonvirtual float GetBoneControl5(void);
	/** Returns the axial/anisotropic scale of the entity, same as input format (forward, right, up) */
	nonvirtual vector GetAxialScale(void);

	#ifdef CLIENT
	/** Called by predraw(); and will set the appropriate rendering specific fields. */
	nonvirtual void RenderFXPass(void);
	nonvirtual void RenderAxialScale(void);
	nonvirtual void RenderGLQuakeShadow(void);
	#endif
};

#ifdef CLIENT
void NSRenderableEntity_ReadEntity(bool)
#endif
