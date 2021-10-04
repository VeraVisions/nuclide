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

class CBaseEntity
{
	int m_iBody;

	/* prop data */
	int m_iPropData;

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
	virtual void(string) SentenceSample;
	virtual void(string) Sentence;
	virtual void(void) ProcessWordQue;
	virtual void(float flChanged) ReceiveEntity;
	virtual float(void) predraw;
	virtual void(void) postdraw;
	virtual void(void) MakeStatic;
	virtual void(void) RendererRestarted;
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
	vector net_velocity;

	string m_parent;

	/* fire */
	entity m_eBurner;
	int m_iBurnWeapon;
	float m_flBurnTime;
	float m_flBurnNext;
	nonvirtual void(entity, float, int) Ignite;
	nonvirtual void(void) Extinguish;
	nonvirtual int(void) IsOnFire;

	/* Reliable APIs */
	nonvirtual vector(void) GetSpawnOrigin;
	nonvirtual vector(void) GetSpawnAngles;
	nonvirtual string(void) GetSpawnModel;
	nonvirtual float(void) GetSpawnHealth;
	nonvirtual int(void) HasPropData;
	nonvirtual __variant(int) GetPropData;

	/* Input/Output System */
	string m_strOnTrigger;
	string m_strOnUser1;
	string m_strOnUser2;
	string m_strOnUser3;
	string m_strOnUser4;
	nonvirtual void(entity, string) UseOutput;
	nonvirtual string(string) CreateOutput;
	virtual void(entity, string, string) Input;
	
	void(void) CBaseEntity;
	virtual void(void) Respawn;
	virtual void(void) Hide;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void(void) Pain;
	virtual void(void) Death;
	nonvirtual void(void) SpawnInit;
	nonvirtual void(void) ParentUpdate;
#endif

	/* we only provide these for networked keys, so we can send updates */
	nonvirtual void(float) SetSendFlags;
	nonvirtual void(float) SetEffects;
	nonvirtual void(float) SetFrame;
	nonvirtual void(string) SetModel;
	nonvirtual void(float) SetModelindex;
	nonvirtual void(float) SetMovetype;
	nonvirtual void(float) SetSkin;
	nonvirtual void(float) SetSolid;
	nonvirtual void(int) SetBody;
	nonvirtual void(float) SetScale;

	/* these are monitored at all times */
	nonvirtual void(vector) SetAngles;
	nonvirtual void(vector) SetOrigin;
	nonvirtual void(vector, vector) SetSize;

	virtual void(string, string) SpawnKey;
	
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

#ifdef CLIENT
class CBaseTrigger:CBaseEntity {};
#endif