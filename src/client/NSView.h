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

/*! @file NSView.h
    @brief NSView handles camera and viewpoints.

    The job of the NSView is to draw a 3D view into an area of the screen.
	 It can contain a player seat. It can also be used to simply render another view
    anywhere on the screen.

	The NSView has a target, which may or may not have prediction
   run on them. Things such as stair smoothing and viewmodel handling
   is done in the NSView.
*/

/** The view mode type of the NSView. */
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
public:
	void NSView(void);

	/** the only method we we want to call setproperty() */
	virtual void SetupView(void);
	/** only does one thing: renderscene() */
	virtual void RenderView(void);
	
	/** when called, will modify 'origin' to vertically smoothed when on ground */
	virtual void StairSmooth(void);
	
	/** called every CSQC_UpdateView for each player */
	virtual void UpdateView(void);
	
	/** applies an punch to our camera angle, temporarily */
	nonvirtual void AddPunchAngle(vector);

	/* set/get */
	/** Sets the viewmode_t of the NSView. */
	nonvirtual void SetViewMode(viewmode_t);
	/** Gets the viewmode_t of the NSView. */
	nonvirtual viewmode_t GetViewMode(void);

	/** Sets the position of the NSView on the screen. */
	nonvirtual void SetViewPosition(vector);
	/** Sets the canvas of the NSView. */
	nonvirtual void SetViewSize(vector);
	/** Sets the view target of the NSView. We'll be seeing the world through their eyes. */
	nonvirtual void SetViewTarget(NSEntity);
	/** Sets the client owner of the NSView.
       For example, when you're spectating somebody, 
       our View Target will be the person we're spectating; 
       whereas the owner is the client doing the spectating. */
	nonvirtual void SetClientOwner(NSClient);

	/** Call with the argument `true` and you will draw the body of the view target. */
	nonvirtual void SetDrawLocalPlayer(bool);

	/** Sets the 3D position of the NSView. */
	nonvirtual void SetCameraOrigin(vector);
	/** Sets the 3D direction of the NSView. */
	nonvirtual void SetCameraAngle(vector);
	/** Sets the client-angle of the NSView. */
	nonvirtual void SetClientAngle(vector);
	/** Sets the seat id of the NSView */
	nonvirtual void SetSeatID(int);
	/** Sets the absolute field of view of the NSView. */
	nonvirtual void SetAFOV(float);
	/** Returns the absolute field of view of the NSView. */
	nonvirtual float GetAFOV(void);
	/** Sets the sensitivity multiplier of the NSView. */
	nonvirtual void SetSensitivity(float);
	/** Returns the sensitivity of the NSView. */
	nonvirtual float GetSensitivity(void);

	/** Returns the canvas size of the heads up display. */
	nonvirtual vector GetHUDCanvasSize(void);
	/** Returns the canvas size of a heads-up-display. */
	nonvirtual vector GetHUDCanvasPos(void);

	/** Get the absolute width of the view, in pixels. */
	nonvirtual float GetViewWidth(void);
	/** Get the absolute height of the view, in pixels. */
	nonvirtual float GetViewHeight(void);

	/** Returns the 3D world coordinate of the NSView. */
	nonvirtual vector GetCameraOrigin(void);
	/** Returns the 3D direction of the NSView. */
	nonvirtual vector GetCameraAngle(void);

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
	bool m_bDrawEntities;
};

/** one NSView for each seat */
NSView g_viewSeats[4];

/** the current seat run for each draw call, for each player. always use talk to this! */
NSView g_view;
