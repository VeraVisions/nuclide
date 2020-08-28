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
	string m_strTarget;
	string m_oldstrTarget; /* needed due to trigger_changetarget */
	string m_strTargetName;
	int m_iBody;

	/* respawn */
	string m_oldModel;
	float m_oldSolid;
	float m_oldHealth;
	vector m_oldOrigin;
	vector m_oldAngle;

	/* keep track of these variables */
	vector net_origin;
	vector net_angles;

#ifdef GS_RENDERFX
	int m_iRenderFX;
	float m_iRenderMode;
	float m_flRenderAmt;
	vector m_vecRenderColor;

	/* respawn */
	int m_oldiRenderFX;
	float m_oldiRenderMode;
	float m_oldflRenderAmt;
	vector m_oldvecRenderColor;
#endif

	string m_parent;
	
	void(void) CBaseEntity;
	virtual void(void) Respawn;
	virtual void(void) Hide;
	virtual void(void) ParentUpdate;
	virtual float(entity, float) SendEntity;
	virtual void(int iHitBody) Pain;
	virtual void(int iHitBody) Death;

	virtual void(float) SetEffects;
	virtual void(float) SetFrame;
	virtual void(string) SetModel;
	virtual void(float) SetModelindex;
	virtual void(float) SetMovetype;
	virtual void(float) SetSkin;
	virtual void(float) SetSolid;
	virtual void(int) SetBody;
	virtual void(vector) SetAngles;
	virtual void(vector) SetOrigin;
	virtual void(vector, vector) SetSize;

#ifdef GS_RENDERFX
	virtual void(int) SetRenderFX;
	virtual void(float) SetRenderMode;
	virtual void(float) SetRenderAmt;
	virtual void(vector) SetRenderColor;
#endif
};
