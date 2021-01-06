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
	int m_iBody;

#ifdef CLIENT
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
#endif

#ifdef SERVER
	string m_oldstrTarget; /* needed due to trigger_changetarget */

	/* respawn */
	string m_oldModel;
	float m_oldSolid;
	float m_oldHealth;
	vector m_oldOrigin;
	vector m_oldAngle;

	/* keep track of these variables */
	vector net_origin;
	vector net_angles;

	string m_parent;
	
	void(void) CBaseEntity;
	virtual void(void) Respawn;
	virtual void(void) Hide;
	virtual void(void) ParentUpdate;
	virtual float(entity, float) SendEntity;
	virtual void(void) Pain;
	virtual void(void) Death;

	virtual void(float) SetEffects;
	virtual void(float) SetFrame;
	virtual void(string) SetModel;
	virtual void(float) SetModelindex;
	virtual void(float) SetMovetype;
	virtual void(float) SetSkin;
	virtual void(float) SetSolid;
	virtual void(int) SetBody;
	virtual void(float) SetScale;
	virtual void(vector) SetAngles;
	virtual void(vector) SetOrigin;
	virtual void(vector, vector) SetSize;
	virtual void(string, string) SpawnKey;
	virtual void(void) SpawnInit;
#endif

#ifdef GS_RENDERFX
	int m_iRenderFX;
	float m_iRenderMode;
	float m_flRenderAmt;
	vector m_vecRenderColor;

	#ifdef CLIENT
		virtual void(void) RenderFXPass;
	#else
		/* respawn */
		int m_oldiRenderFX;
		float m_oldiRenderMode;
		float m_oldflRenderAmt;
		vector m_oldvecRenderColor;

		virtual void(int) SetRenderFX;
		virtual void(float) SetRenderMode;
		virtual void(float) SetRenderAmt;
		virtual void(vector) SetRenderColor;
	#endif
#endif
};
