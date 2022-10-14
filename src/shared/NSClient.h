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

/** This entity class is the lowest client/player class.

It is mostly concerned with the features shared between players
and spectating clients alike.
*/
class
NSClient:NSNavAI
{
private:
	vector origin_net;
	vector velocity_net;

	NSXRSpace m_xrSpace;
	NSXRInput m_xrInputHead;
	NSXRInput m_xrInputLeft;
	NSXRInput m_xrInputRight;

public:
	void NSClient(void);

	/* final input handling of the client */
	virtual void ClientInput(void);
	virtual void PreFrame(void);
	virtual void PostFrame(void);
	virtual bool IsFakeSpectator(void);
	virtual bool IsRealSpectator(void);
	virtual bool IsDead(void);
	virtual bool IsPlayer(void);
	virtual void OnRemoveEntity(void);

#ifdef CLIENT
	/** Called to give a chance to override input variables before networking */
	virtual void ClientInputFrame(void);

	/** Called every single client frame when this client is alive */
	virtual void UpdateAliveCam(void);

	/** Called every single client frame when this client is dead */
	virtual void UpdateDeathcam(void);

	/** Called every single client frame during intermission */
	virtual void UpdateIntermissionCam(void);

	/* run every frame before renderscene() */
	virtual float predraw(void);
#else
	virtual void Save(float);
	virtual void Restore(string,string);
#endif
};
