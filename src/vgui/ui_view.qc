/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

class VGUIView:VGUIWidget
{
public:
	void VGUIView(void);

	/* overrides */
	virtual void Add(VGUIWidget);
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
};

void
VGUIView::VGUIView(void)
{
}

void
VGUIView::Add(VGUIWidget wNew)
{
	VGUIWidget wNext = this;
	VGUIWidget wParent;
	do {
		wParent = wNext;
		wNext = wNext.m_children;
	} while (wNext);
	wParent.m_children = wNew;
	wNew.m_parent = this;
}

void VGUIView::Draw(void)
{
	VGUIWidget wNext = this;
	g_vguiWidgetCount = 0;
	do {
		wNext = wNext.m_children;
		if (wNext && wNext.Visible() && wNext.m_parent.Visible()) {
			g_vguiWidgetCount++;
			wNext.Draw();
		}
	} while (wNext);
}

bool VGUIView::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	float ret = false;

	VGUIWidget wNext = this;
	do {
		wNext = wNext.m_children;
		if (wNext && wNext.Visible() && wNext.m_parent.Visible()) {
			ret = wNext.Input(flEVType, flKey, flChar, flDevID);
		}

		if (ret == true)
			return true;

	} while (wNext);

	return (ret);
}
