/** An abstract control class for various VGUI related widgets. */
class
VGUIControl:VGUIWidget
{
public:
	virtual void VGUIControl(void);

	/** Set the control tag. Used for identification purposes. */
	nonvirtual void SetTag(int);
	/** Returns the control tag. Used for identification purposes. */
	nonvirtual int GetTag(void);

	/* overridable */
	/** Called when the mouse starts hovering over this element. */
	virtual void OnMouseEntered(void);
	/** Called when the mouse stops hovering over this element. */
	virtual void OnMouseExited(void);
	/** Called when the mouse starts klicking down on this element. */
	virtual void OnMouseDown(void);
	/** Called when the mouse stops klicking down on this element. This is when actions usually need to be triggered. */
	virtual void OnMouseUp(void);

private:
	int m_iTag;
};

void
VGUIControl::VGUIControl(void)
{
	m_iTag = 0i;
}

void
VGUIControl::SetTag(int val)
{
	m_iTag = val;
}

int
VGUIControl::GetTag(void)
{
	return m_iTag;
}

void
VGUIControl::OnMouseEntered(void)
{
}

void
VGUIControl::OnMouseExited(void)
{
}

void
VGUIControl::OnMouseDown(void)
{
}

void
VGUIControl::OnMouseUp(void)
{
}