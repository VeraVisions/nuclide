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

	/* the entity we're targetting */
	NSEntity m_viewTarget;

	NSClient m_client;

	void(void) NSView;

	virtual void(void) SetupView;
	virtual void(void) RenderView;

	virtual void(viewmode_e) SetViewMode;
	virtual viewmode_e(void) GetViewMode;

	virtual void(void) UpdateView;

	virtual void(void) Render2D;

	virtual void(vector) SetViewPosition;
	virtual void(vector) SetViewSize;
	virtual void(NSEntity) SetViewTarget;
	virtual void(NSClient) SetClientOwner;

	virtual void(vector) SetCameraOrigin;
	virtual void(vector) SetCameraAngle;
	virtual void(int) SetSeatID;
	virtual void(float) SetAFOV;

	virtual vector(void) GetHUDCanvasSize;
	virtual vector(void) GetHUDCanvasPos;

	virtual float(void) GetViewWidth;
	virtual float(void) GetViewHeight;

	virtual vector(void) GetCameraOrigin;
	virtual vector(void) GetCameraAngle;
};

NSView g_viewSeats[4];
NSView g_view;