/** @brief The base VGUI widget class.

Every VGUI widget is based off of this. */
class vguiWidget
{
public:
	void vguiWidget(void);

	/** Adds a widget into this one. */
	virtual void Add(vguiWidget);
	/** Add a flag to the widget. */
	nonvirtual void FlagAdd(int);
	/** Remove a flag from the widget. */
	nonvirtual void FlagRemove(int);
	/** Check if the vguiWidget has a flag attached. */
	nonvirtual bool HasFlag(int);
	/** Returns if the widget is active. */
	nonvirtual bool IsEnabled(void);

	/** Set the position within its context. */
	nonvirtual void SetPos(vector);
	/** Return the position of the widget within its context. */
	nonvirtual vector GetPos(void);
	/** Returns the X coordinate of the widget position within its context. */
	nonvirtual int GetPosWidth(void);
	/** Returns the Y coordinate of the widget position within its context. */
	nonvirtual int GetPosHeight(void);

	/** Set the size of the widget to a new one. */
	nonvirtual void SetSize(vector);
	/** Returns the size of the widget, in pixels. */
	nonvirtual vector GetSize(void);

	/** Returns the width of the widget, in pixels. */
	nonvirtual int GetWidth(void);
	/** Returns the height of the widget, in pixels. */
	nonvirtual int GetHeight(void);

	/** Sets the minimum size of the widget. */
	nonvirtual void SetMinSize(vector);
	/** Returns the minimum size of the widget. */
	nonvirtual vector GetMinSize(void);

	/** Sets the maximum size of the widget. */
	nonvirtual void SetMaxSize(vector);
	/** Returns the maximum size of the widget. */
	nonvirtual vector GetMaxSize(void);

	/** Returns true/false depending on if the widget is visible. */
	nonvirtual bool Visible(void);
	/** Show the widget. */
	nonvirtual void Show(void);
	/** Hide the widget. */
	nonvirtual void Hide(void);

	/** Sets the vguiTheme to use on this widget (and any children it may have) */
	nonvirtual void SetTheme(vguiTheme);
	/** Returns the VGUI that will be used on this widget. */
	nonvirtual vguiTheme GetTheme(void);

	/** Called when the position of the widget was changed in any capacity. */
	virtual void PositionChanged(vector, vector);
	/** Called when the size of the widget has changed in any capacity. */
	virtual void SizeChanged(vector, vector);

	virtual void NowVisible(void);
	virtual void NowHidden(void);

	/** Enable the widget. */
	nonvirtual void Enable(void);
	/** Disable the widget. */
	nonvirtual void Disable(void);

	virtual void NowEnabled(void);
	virtual void NowDisabled(void);

	/** Called in order to draw the widget. */
	virtual void Draw(void);
	/** Called whenever the physical properties of the display change. */
	virtual void Reposition(void);
	/** Called whenever an input event gets directed to the widget. */
	virtual bool Input(float, float, float, float);
	/** Called when the widget has fully initialized.
       When you override this, you may call `super::Spawned();` to ensure
       the parent classes get to finish initializing also. */
	virtual void Spawned(void);

private:
	/* why are these 3D vectors? because drawpic() etc. take it. ..you never know what that may be used for some day! */
	vector m_vecOrigin;
	vector m_vecSize;
	vector m_vecMinSize;
	vector m_vecMaxSize;

	vguiWidget m_next;
	vguiWidget m_parent;
	vguiWidget m_children;
	int m_iFlags;
	bool m_bVisible;
	bool m_bEnabled;
	vguiTheme m_theme;
};
