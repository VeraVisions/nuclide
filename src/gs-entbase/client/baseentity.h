/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

class CBaseEntity
{
#ifdef GS_RENDERFX
	int m_iRenderFX;
	float m_iRenderMode;
	float m_flRenderAmt;
	vector m_vecRenderColor;
#endif

	int m_iBody;
	float m_flSentenceTime;
	sound_t *m_pSentenceQue;
	int m_iSentenceCount;
	int m_iSentencePos;

	/* model events */
	float m_flBaseTime;

	void(void) CBaseEntity;
	virtual void(void) Init;
	virtual void(void) Initialized;
	virtual void(string, string) SpawnKey;
	virtual void(string) Sentence;
	virtual void(void) ProcessWordQue;
	virtual void(float flChanged) ReceiveEntity;
	virtual float(void) predraw;
	virtual void(void) postdraw;
	virtual void(void) customphysics;
	virtual void(float, int, string) ModelEvent;

#ifdef GS_RENDERFX
	virtual void(void) RenderFXPass;
#endif
}; 
