void
vguiWidget::vguiWidget(void)
{
	m_vecOrigin = [0.0f, 0.0f];
	m_vecSize = [0.0f, 0.0f];
	m_vecMinSize = [0.0f, 0.0f];
	m_vecMaxSize = [9999.0f, 9999.0f];
	m_next = __NULL__;
	m_parent = __NULL__;
	m_iFlags = 0i;
	m_bVisible = true;
	m_bEnabled = true;
	isVGUI = true;

	Spawned();
}

void
vguiWidget::SetTheme(vguiTheme theme)
{
	m_theme = theme;
}

bool
vguiWidget::IsEnabled(void)
{
	return (m_bEnabled);
}

void
vguiWidget::Enable(void)
{
	m_bEnabled = true;
}

void
vguiWidget::Disable(void)
{
	m_bEnabled = false;
}

void
vguiWidget::NowEnabled(void)
{
}

void
vguiWidget::NowDisabled(void)
{
}

vguiTheme
vguiWidget::GetTheme(void)
{
	/* if no theme set, but we have a parent... inherit the parents' theme recursively */
	if (!m_theme && m_parent) {
		return m_parent.GetTheme();
	}

	/* we have nothing, use the default one. */
	if (!m_theme) {
		m_theme = spawn(vguiTheme);
	}

	return (m_theme);
}

bool
vguiWidget::Visible(void)
{
	return (m_bVisible);
}

void
vguiWidget::Hide(void)
{
	m_bVisible = false;
	NowHidden();
}

void
vguiWidget::NowHidden(void)
{
}


void
vguiWidget::NowVisible(void)
{
}


void
vguiWidget::Show(void)
{
	m_bVisible = true;
	NowVisible();
}

void
vguiWidget::PositionChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SizeChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SetPos(vector vecNewPos)
{
	vector vecOld = m_vecOrigin;
	m_vecOrigin[0] = bound(0, vecNewPos[0], 9999.0);
	m_vecOrigin[1] = bound(0, vecNewPos[1], 9999.0);
	PositionChanged(vecOld, m_vecOrigin);
}

vector
vguiWidget::GetPos(void)
{
	return (m_vecOrigin);
}

int
vguiWidget::GetPosWidth(void)
{
	return (m_vecOrigin[0]);
}

int
vguiWidget::GetPosHeight(void)
{
	return (m_vecOrigin[1]);
}

void
vguiWidget::SetSize(vector vecNewSize)
{
	vector vecOld = m_vecSize;
	m_vecSize[0] = bound(m_vecMinSize[0], vecNewSize[0], m_vecMaxSize[0]);
	m_vecSize[1] = bound(m_vecMinSize[1], vecNewSize[1], m_vecMaxSize[1]);
	SizeChanged(vecOld, m_vecSize);
}

vector
vguiWidget::GetSize(void)
{
	return (m_vecSize);
}

int
vguiWidget::GetWidth(void)
{
	return (m_vecSize[0]);
}

int
vguiWidget::GetHeight(void)
{
	return (m_vecSize[1]);
}

void
vguiWidget::SetMinSize (vector vecNewSize)
{
	m_vecMinSize = vecNewSize;
}

vector
vguiWidget::GetMinSize(void)
{
	return (m_vecMinSize);
}

void
vguiWidget::SetMaxSize (vector vecNewSize)
{
	m_vecMaxSize = vecNewSize;
}

vector
vguiWidget::GetMaxSize(void)
{
	return (m_vecMaxSize);
}

void
vguiWidget::FlagAdd(int iFlag)
{
	m_iFlags |= iFlag;
}

void
vguiWidget::FlagRemove(int iFlag)
{
	m_iFlags -= (m_iFlags & iFlag);
}

bool
vguiWidget::HasFlag(int flag)
{
	return (m_iFlags & flag) ? (true) : (false);
}

void
vguiWidget::Reposition(void)
{
	vguiWidget wNext = this;

	do {
		wNext = wNext.m_next;

		if (wNext) {
			wNext.Reposition();
		}
	} while (wNext);
}

void
vguiWidget::Add(vguiWidget wNew)
{
	vguiWidget wNext = this;
	vguiWidget wParent;

	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while (wNext);

	wParent.m_next = wNew;
	wNew.m_parent = this;
}

void
vguiWidget::Draw(void)
{
	vguiWidget wNext = this;
	g_vguiWidgetCount = 0;

	do {
		wNext = wNext.m_next;
		if (wNext && wNext.Visible() && wNext.m_parent.Visible()) {
			g_vguiWidgetCount++;
			wNext.Draw();
		}
	} while (wNext);
}

bool
vguiWidget::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	vguiWidget wNext = this;
	vguiWidget wLast = __NULL__;
	vguiWidget wLastBefore = __NULL__;

	/* figure out the last window in the chain... */
	do {
		wLastBefore = wNext;
		wNext = wNext.m_next;

		if (wNext) {
			wLast = wNext;
		}
	} while (wNext);

	//print(sprintf("Last widget: %S\n", wLast.classname)); 

	/* we've found a window, let's test inputs backwards. */
	while (wLast.classname) {
		bool test = false;

		if (wLast.Visible())
			test = wLast.Input(flEVType, flKey, flChar, flDevID);

		//print(sprintf("Testing input for... widget: %S %d\n", wLast.classname, test));

		/* input successful */
		if (test == true) {
			return (true);
		}

		/* select the former input */
		for (vguiWidget a = this; a != __NULL__; a = a.m_next) {
			/* we've reached the end, take one from before */
			if (a == wLast) {
				wLast = wLastBefore;
				break;
			}
			wLastBefore = a;
		}

		/* the end of the world. */
		if (wLast == this)
			return (false);
	}

	return (false);
}

void
vguiWidget::Spawned(void)
{
}
