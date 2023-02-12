class CPageTab:CWidget
{
	int m_page;
	int m_maxpage;
	CWidget m_children;
	int m_items;

	int m_lbtnstate;
	int m_rbtnstate;

	void CPageTab(void);
	virtual void Draw(void);
	virtual void Input(float, float, float, float);

	virtual void AddWidget(CWidget);
};

void
CPageTab::CPageTab(void)
{
	m_page = 1;
	m_maxpage = 1;
}

.string classname;
void
CPageTab::Draw(void)
{
	string lbtn = g_bmp[LARROWDEFAULT];
	string rbtn = g_bmp[RARROWDEFAULT];

	if (m_lbtnstate & 2)
		lbtn = g_bmp[LARROWPRESSED];
	else if (m_lbtnstate & 1)
		lbtn = g_bmp[LARROWFLYOVER];

	if (m_rbtnstate & 2)
		rbtn = g_bmp[RARROWPRESSED];
	else if (m_rbtnstate & 1)
		rbtn = g_bmp[RARROWFLYOVER];

	drawpic([g_menuofs[0]+440,g_menuofs[1]+108], lbtn,
				[16,16], [1,1,1], 1.0f, 0);
	drawpic([g_menuofs[0]+573,g_menuofs[1]+108], rbtn,
				[16,16], [1,1,1], 1.0f, 0);

	WLabel_Static(460, 111, sprintf("Page %i of %i", m_page, m_maxpage), 14, 14, [1,1,1],
				1.0, 0, font_label);

	CWidget wNext = m_children;
	do {
		if (wNext) {
			//print(sprintf("%i %s\n", wNext.m_onpage, wNext.classname));
			if (wNext.m_onpage == m_page)
				wNext.Draw();
		}
		wNext = wNext.m_next;
	} while (wNext);
}

void
CPageTab::Input(float type, float x, float y, float devid)
{
	/* left button hover check */
	if (Util_CheckMouse(440, 108, 26, 26))
		m_lbtnstate |= 1;
	else
		m_lbtnstate &= ~ 1;

	/* right button hover check */
	if (Util_CheckMouse(573, 108, 26, 26))
		m_rbtnstate |= 1;
	else
		m_rbtnstate &= ~ 1;

	/* left button click check */
	if ((m_lbtnstate & 1) && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_lbtnstate |= 2;
	}

	/* right button click check */
	m_rbtnstate = Util_CheckMouse(573, 108, 26, 26) ? 1 : 0;
	if ((m_rbtnstate & 1) && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_rbtnstate |= 2;
	}

	/* unclick + trigger (if need be) */
	if (type == IE_KEYUP && x == K_MOUSE1) {
		m_lbtnstate &= ~2;
		m_rbtnstate &= ~2;

		if (m_lbtnstate & 1) {
			m_page--;

			if (m_page < 1)
				m_page = 1;
		}
		if (m_rbtnstate & 1) {
			m_page++;

			if (m_page > m_maxpage)
				m_page = m_maxpage;
		}
	}

	/* pass inputs to our children */
	CWidget wNext = m_children;
	do {
		if (wNext) {
			if (wNext.m_onpage == m_page)
				wNext.Input(type, x, y, devid);
		}
		wNext = wNext.m_next;
	} while (wNext);
}

void
CPageTab::AddWidget(CWidget new)
{
	/* 8 widgets plus their label = 16 items per page */
	m_maxpage = 1 + floor((float)m_items / 16.0);

	new.m_y -= (m_maxpage - 1) * (32*8);

	if (m_children) {
		CWidget wNext = m_children;
		do {
			if (!wNext.m_next) {
				wNext.m_next = new;
				new.m_onpage = m_maxpage;
				//print(sprintf("%d adding %S to page %i\n", num_for_edict(this), new.classname, m_maxpage));
				m_items++;
				return;
			}
			wNext = wNext.m_next;
		} while (wNext);
	} else {
		m_children = new;
		new.m_onpage = m_maxpage;
		m_items++;
		//print(sprintf("%d adding %S to page %i\n", num_for_edict(this), new.classname, m_maxpage));
	}
}