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

/* both NSClientPlayer and base_NSClientSpectator are based off this class */
class
NSClient:NSNavAI
{
	vector origin_net;
	vector velocity_net;

	NSXRSpace m_xrSpace;
	NSXRInput m_xrInputHead;
	NSXRInput m_xrInputLeft;
	NSXRInput m_xrInputRight;

	void(void) NSClient;

	/* final input handling of the client */
	virtual void(void) ClientInput;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;

	const bool(void) IsFakeSpectator;
	const bool(void) IsRealSpectator;
	const bool(void) IsDead;
	const bool(void) IsPlayer;

	virtual void(void) OnRemoveEntity;

#ifdef CLIENT
	/* gives the chance to override input variables before networking */
	virtual void(void) ClientInputFrame;

	/* our camera when we're alive */
	virtual void(void) UpdateAliveCam;

	/* our camera when we're dead */
	virtual void(void) UpdateDeathcam;

	/* our camera when we're in an intermission */
	virtual void(void) UpdateIntermissionCam;

	/* run every frame before renderscene() */
	virtual float(void) predraw;
#else
	virtual void(float) Save;
	virtual void(string,string) Restore;
#endif
};
