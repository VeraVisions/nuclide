/* The job of a NSView is to contain a single player seat.
   Boxing is important for splitscreen etc. play.

	The NSView has a target, which may or may not have prediction
   run on them. Things such as stair smoothing and viewmodel handling
   is done in the NSView.
*/

class
NSView
{
	int m_iSeat;

	/* the dimensions of our view */
	vector m_vecPosition;
	vector m_vecSize;
	float m_flFieldOfView;

	/* the entity we're targetting */
	NSEntity m_viewTarget;

	NSClient m_client;

	void(void) NSView;

	virtual void(void) SetupView;
	virtual void(void) RenderView;

	virtual void(vector) SetViewPosition;
	virtual void(vector) SetViewSize;
	virtual void(NSEntity) SetViewTarget;
	virtual void(NSClient) SetClientOwner;

	virtual void(vector) SetCameraOrigin;
	virtual void(vector) SetCameraAngle;
	virtual void(int) SetSeatID;
	virtual void(float) SetAFOV;
};

NSView g_viewSeats[4];
NSView g_view;