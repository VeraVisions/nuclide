/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
NSClient:NSBot
{
public:
	void NSClient(void);

	/** Called within the class to deal with the final input handling of the client. */
	virtual void ProcessInput(void);
	/** Run once, every frame, before physics are run on the player. */
	virtual void PreFrame(void);
	/** Run once, every frame, after physics are run on the player. */
	virtual void PostFrame(void);
	/** Returns if we're a 'fake' spectator. This is a regular player acting as a spectator. */
	virtual bool IsFakeSpectator(void);
	/** Returns if we're a 'real' spectator. That is a client that can only spectate. */
	virtual bool IsRealSpectator(void);
	/** Returns if we're considered 'dead'. NSClient, NSClientSpectator will always return false. */
	virtual bool IsDead(void);
	/** Returns if we're a player. That is a type of client that is built on top of NSClientPlayer. */
	virtual bool IsPlayer(void);
	/** Like ClientInputFrame and ServerInputFrame, but run on both client and server at the same time. It is run before ClientInputFrame and ServerInputFrame. When overriding, Make sure to call the super method to enable Nuclide to handle spectator controls properly. */
	virtual void SharedInputFrame(void);

	/* overrides */
	virtual void OnRemoveEntity(void);
	virtual float GetForwardSpeed(void);
	virtual float GetSideSpeed(void);
	virtual float GetBackSpeed(void);

#ifdef CLIENT
	/** Client: Called on the client to give a chance to override input_* variables before networking them takes place. */
	virtual void ClientInputFrame(void);

	/** Client: Called every single client frame when this client is alive. You are expected to manipulate the g_view global here, which is of type NSView. */
	virtual void UpdateAliveCam(void);

	/** Client: Called every single client frame when this client is dead. You are expected to manipulate the g_view global here, which is of type NSView. */
	virtual void UpdateDeathcam(void);

	/** Client: Called every single client frame during intermission. You are expected to manipulate the g_view global here, which is of type NSView. */
	virtual void UpdateIntermissionCam(void);

	/* overrides */
	virtual float predraw(void);
#endif

#ifdef SERVER
	/** Server: This is where the input* variables arrive after sending them out from the client (see ClientInputFrame). This is also where we will instruct the server to run physics on the client. */
	virtual void ServerInputFrame(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
#endif

private:
	vector origin_net;
	vector velocity_net;

	NSXRSpace m_xrSpace;
	NSXRInput m_xrInputHead;
	NSXRInput m_xrInputLeft;
	NSXRInput m_xrInputRight;

#ifdef SERVER
	float score;
#endif
};
