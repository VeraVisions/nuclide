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
	virtual float(entity, vector) SendEntity;
	virtual void(entity, string, string) Input;
	virtual void(void) Respawn;
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(void) EvaluateEntity;
#else
	virtual void(float,float) ReceiveEntity;
	virtual float(void) predraw;
#endif

	/* new */
	PREDICTED_INT(m_iBody);
	PREDICTED_FLOAT_N(frame);
	PREDICTED_FLOAT_N(skin);
	PREDICTED_FLOAT_N(effects);
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

#ifdef GS_RENDERFX
	PREDICTED_FLOAT(m_iRenderFX);
	PREDICTED_FLOAT(m_iRenderMode);
	PREDICTED_FLOAT(m_flRenderAmt);
	PREDICTED_VECTOR(m_vecRenderColor);

	/* set */
	nonvirtual void(float) SetRenderFX;
	nonvirtual void(float) SetRenderMode;
	nonvirtual void(float) SetRenderAmt;
	nonvirtual void(vector) SetRenderColor;

	#ifdef CLIENT
		nonvirtual void(void) RenderFXPass;
	#else
		/* respawn */
		float m_oldiRenderFX;
		float m_oldiRenderMode;
		float m_oldflRenderAmt;
		vector m_oldvecRenderColor;
	#endif
#endif
};
