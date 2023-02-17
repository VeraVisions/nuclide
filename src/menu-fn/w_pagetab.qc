class CPageTab:CWidget
{
	int m_page;
	int m_maxpage;
	CWidget m_children;
	int m_items;

	int m_lbtnstate;
	int m_rbtnstate;
	resource_t m_resLeft;
	resource_t m_resRight;

	void CPageTab(void);
	virtual void Draw(void);
	virtual void Input(float, float, float, float);

	virtual void AddWidget(CWidget);

	nonvirtual void DrawArrowLeft(vector);
	nonvirtual void DrawArrowRight(vector);
};

void
CPageTab::CPageTab(void)
{
	m_page = 1;
	m_maxpage = 1;
	m_resLeft = Resource_Check(strcat(g_bmp[LARROWDEFAULT], ".bmp"));
	m_resRight = Resource_Check(strcat(g_bmp[RARROWDEFAULT], ".bmp"));
}

void
CPageTab::DrawArrowLeft(vector vecPos)
{
	if (Resource_Available(m_resLeft)) {
		if (m_lbtnstate & 2) {
			drawpic(vecPos, g_bmp[LARROWPRESSED], [16,16], [1,1,1], 1.0f, 0);
		} else if (m_lbtnstate & 1) {
			drawpic(vecPos, g_bmp[LARROWFLYOVER], [16,16], [1,1,1], 1.0f, 0);
		} else {
			drawpic(vecPos, g_bmp[LARROWDEFAULT], [16,16], [1,1,1], 1.0f, 0);
		}
	} else {
		drawfill(vecPos, [16,16], [0.25,0.25,0.25], 1.0f);
		drawfill(vecPos + [3,3], [10,10], [0,0,0], 1.0f);

		if (m_lbtnstate & 2) {
			drawfill(vecPos, [16,16], [1,1,1], 1.0f);
		} else if (m_lbtnstate & 1) {
			drawfill(vecPos, [16,16], [1,1,1], 0.75f);
		}
	}
}

void
CPageTab::DrawArrowRight(vector vecPos)
{
	if (Resource_Available(m_resRight)) {
		if (m_rbtnstate & 2) {
			drawpic(vecPos, g_bmp[RARROWPRESSED], [16,16], [1,1,1], 1.0f, 0);
		} else if (m_rbtnstate & 1) {
			drawpic(vecPos, g_bmp[RARROWFLYOVER], [16,16], [1,1,1], 1.0f, 0);
		} else {
			drawpic(vecPos, g_bmp[RARROWDEFAULT], [16,16], [1,1,1], 1.0f, 0);
		}
	} else {
		drawfill(vecPos, [16,16], [0.25,0.25,0.25], 1.0f);
		drawfill(vecPos + [3,3], [10,10], [0,0,0], 1.0f);

		if (m_rbtnstate & 2) {
			drawfill(vecPos, [16,16], [1,1,1], 1.0f);
		} else if (m_rbtnstate & 1) {
			drawfill(vecPos, [16,16], [1,1,1], 0.75f);
		}
	}
}

.string classname;
void
CPageTab::Draw(void)
{
	DrawArrowLeft([g_menuofs[0]+440,g_menuofs[1]+108]);
	DrawArrowRight([g_menuofs[0]+573,g_menuofs[1]+108]);

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