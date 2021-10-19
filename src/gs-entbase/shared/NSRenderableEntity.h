/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
	virtual float(entity, float) SendEntity;
	virtual void(entity, string, string) Input;
	virtual void(void) Respawn;
#else
	virtual void(float flChanged) ReceiveEntity;
	virtual float(void) predraw;
#endif

	/* new */
	int m_iBody;
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
	int m_iRenderFX;
	float m_iRenderMode;
	float m_flRenderAmt;
	vector m_vecRenderColor;

	/* set */
	nonvirtual void(int) SetRenderFX;
	nonvirtual void(float) SetRenderMode;
	nonvirtual void(float) SetRenderAmt;
	nonvirtual void(vector) SetRenderColor;

	#ifdef CLIENT
		nonvirtual void(void) RenderFXPass;
	#else
		/* respawn */
		int m_oldiRenderFX;
		float m_oldiRenderMode;
		float m_oldflRenderAmt;
		vector m_oldvecRenderColor;
	#endif
#endif
};
