/*
 * Copyright (c) 2022 Vera Visions LLC.
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

/* The job of a NSView is to contain a single player seat.
   Boxing is important for splitscreen etc. play.

	The NSView has a target, which may or may not have prediction
   run on them. Things such as stair smoothing and viewmodel handling
   is done in the NSView.
*/

/** The view mode type of an NSView. */
typedef enum
{
	VIEWMODE_NORMAL,		/**< just a regular camera with no special logic */
	VIEWMODE_FPS,			/**< uses view target position + view offset */
	VIEWMODE_THIRDPERSON,	/**< third person view, fixed */
	VIEWMODE_SPECTATING		/**< spectating, mixed viewmodes inside */
} viewmode_t;

/** This class represents 3D views, used for rendering the game.
It can also be used to render picture-in-picture views on top
of other views. */
class
NSView
{
private:
	int m_iSeat;

	/* the dimensions of our view */
	vector m_vecPosition;
	vector m_vecSize;
	float m_flFieldOfView;
	viewmode_t m_viewmode;
	float m_flSensitivity;

	vector m_vecLastOrigin;

	/* the entity we're targetting */
	NSEntity m_viewTarget;

	NSClient m_client;

	vector m_vecClientAngle;
	bool m_bSetClientAngle;

	bool m_bDrawLocalPlayer;

public:
	void NSView(void);

	/** the only method we we want to call setproperty() */
	virtual void SetupView(void);
	/** only does one thing: renderscene() */
	virtual void RenderView(void);
	
	/** when called, will modify 'origin' to vertically smoothed when on ground */
	virtual void StairSmooth(void);
	
	/** applies an punch to our camera angle, temporarily */
	virtual void AddPunchAngle(vector);
	
	/** called every CSQC_UpdateView for each player */
	virtual void UpdateView(void);

	/* set/get */
	virtual void SetViewMode(viewmode_t);
	virtual viewmode_t GetViewMode(void);
	
	virtual void SetViewPosition(vector);
	virtual void SetViewSize(vector);
	virtual void SetViewTarget(NSEntity);
	virtual void SetClientOwner(NSClient);

	virtual void SetDrawLocalPlayer(bool);
	
	virtual void SetCameraOrigin(vector);
	virtual void SetCameraAngle(vector);
	virtual void SetClientAngle(vector);
	virtual void SetSeatID(int);
	virtual void SetAFOV(float);
	virtual float GetAFOV(void);
	virtual void SetSensitivity(float);
	virtual float GetSensitivity(void);
	
	virtual vector GetHUDCanvasSize(void);
	virtual vector GetHUDCanvasPos(void);
	
	virtual float GetViewWidth(void);
	virtual float GetViewHeight(void);
	
	virtual vector GetCameraOrigin(void);
	virtual vector GetCameraAngle(void);

};

/* one NSView for each seat */
NSView g_viewSeats[4];

/* the current seat run for each draw call, for each player. always use talk to this! */
NSView g_view;
