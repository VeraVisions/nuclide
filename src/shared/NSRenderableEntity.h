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

enumflags
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
};

enum
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
	RM_TRIGGER
};

enum
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
};

#ifdef CLIENT
var int autocvar_cl_showtriggers = FALSE;
var int autocvar_rm_unlit_additive = TRUE;
var int autocvar_rm_unlit_texture = TRUE;
#endif

/* anything with a physical appearance that's networked */
class NSRenderableEntity:NSEntity
{
	void(void) NSRenderableEntity;

	/* overrides */
	virtual void(string, string) SpawnKey;
#ifdef SERVER
	virtual void(entity, string, string) Input;
	virtual void(void) Respawn;
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#else
	virtual void(void) RenderDebugSkeleton;
	virtual void(float,float) ReceiveEntity;
	virtual float(void) predraw;
#endif

	/* new */
	PREDICTED_FLOAT(m_flBoneControl1);
	PREDICTED_FLOAT(m_flBoneControl2);
	PREDICTED_FLOAT(m_flBoneControl3);
	PREDICTED_FLOAT(m_flBoneControl4);
	PREDICTED_FLOAT(m_flBoneControl5);
	PREDICTED_INT(m_iBody);
	PREDICTED_FLOAT_N(colormap);
	PREDICTED_VECTOR_N(glowmod);

	/* model events */
	float m_flBaseTime;

#ifdef SERVER
	virtual void(void) Show;
	virtual void(void) Hide;
#endif
	nonvirtual void(float) SetEffects;
	nonvirtual void(float) SetFrame;
	nonvirtual void(float) SetSkin;
	nonvirtual void(int) SetBody;
	nonvirtual void(float) SetScale;
	virtual void(void) MakeStatic;

	PREDICTED_FLOAT(m_iRenderFX);
	PREDICTED_FLOAT(m_iRenderMode);
	PREDICTED_FLOAT(m_flRenderAmt);
	PREDICTED_VECTOR(m_vecRenderColor);

	/* set */
	nonvirtual void(float) SetRenderFX;
	nonvirtual void(float) SetRenderMode;
	nonvirtual void(float) SetRenderAmt;
	nonvirtual void(vector) SetRenderColor;
	nonvirtual void(float) SetBoneControl1;
	nonvirtual void(float) SetBoneControl2;
	nonvirtual void(float) SetBoneControl3;
	nonvirtual void(float) SetBoneControl4;
	nonvirtual void(float) SetBoneControl5;

	nonvirtual float(void) GetRenderMode;
	nonvirtual float(void) GetRenderFX;
	nonvirtual float(void) GetRenderAmt;
	nonvirtual vector(void) GetRenderColor;
	nonvirtual float(void) GetBoneControl1;
	nonvirtual float(void) GetBoneControl2;
	nonvirtual float(void) GetBoneControl3;
	nonvirtual float(void) GetBoneControl4;
	nonvirtual float(void) GetBoneControl5;

	#ifdef CLIENT
		nonvirtual void(void) RenderFXPass;
	#else
		/* respawn */
		float m_oldiRenderFX;
		float m_oldiRenderMode;
		float m_oldflRenderAmt;
		vector m_oldvecRenderColor;
	#endif
};

#ifdef CLIENT
void NSRenderableEntity_ReadEntity(bool)
#endif
