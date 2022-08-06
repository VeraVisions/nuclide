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

typedef enum
{
	VIEWMODE_NORMAL,		/* just a regular camera with no special logic */
	VIEWMODE_FPS,			/* uses view target position + view offset */
	VIEWMODE_THIRDPERSON,	/* third person view, fixed */
	VIEWMODE_SPECTATING		/* spectating, mixed viewmodes inside */
} viewmode_e;

class
NSView
{
	int m_iSeat;

	/* the dimensions of our view */
	vector m_vecPosition;
	vector m_vecSize;
	float m_flFieldOfView;
	viewmode_e m_viewmode;

	vector m_vecLastOrigin;

	/* the entity we're targetting */
	NSEntity m_viewTarget;

	NSClient m_client;

	vector m_vecClientAngle;
	bool m_bSetClientAngle;

	void(void) NSView;

	/* the only method we we want to call setproperty() */
	virtual void(void) SetupView;
	/* only does one thing: renderscene() */
	virtual void(void) RenderView;

	/* when called, will modify 'origin' to vertically smoothed when on ground */
	virtual void(void) StairSmooth;

	/* applies an punch to our camera angle, temporarily */
	virtual void(vector) AddPunchAngle;

	/* called every CSQC_UpdateView for each player */
	virtual void(void) UpdateView;

	/* set/get */
	virtual void(viewmode_e) SetViewMode;
	virtual viewmode_e(void) GetViewMode;

	virtual void(vector) SetViewPosition;
	virtual void(vector) SetViewSize;
	virtual void(NSEntity) SetViewTarget;
	virtual void(NSClient) SetClientOwner;

	virtual void(vector) SetCameraOrigin;
	virtual void(vector) SetCameraAngle;
	virtual void(vector) SetClientAngle;
	virtual void(int) SetSeatID;
	virtual void(float) SetAFOV;
	virtual float(void) GetAFOV;

	virtual vector(void) GetHUDCanvasSize;
	virtual vector(void) GetHUDCanvasPos;

	virtual float(void) GetViewWidth;
	virtual float(void) GetViewHeight;

	virtual vector(void) GetCameraOrigin;
	virtual vector(void) GetCameraAngle;
};

/* one NSView for each seat */
NSView g_viewSeats[4];

/* the current seat run for each draw call, for each player. always use talk to this! */
NSView g_view;
