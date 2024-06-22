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

enumflags
{
	IMAGE_VISIBLE
};

/** VGUI Widget: Picture Frame

@ingroup vgui
*/
class
VGUIPic:VGUIWidget
{
public:
	void VGUIPic(void);
	
	nonvirtual void SetImage(string);
	nonvirtual string GetImage(void);
	
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	string m_strImage;
};

void
VGUIPic::VGUIPic(void)
{
	m_strImage = __NULL__;
}

void
VGUIPic::Spawned(void)
{
	SetSize([16,16, 0]);
}

void
VGUIPic::Draw(void)
{
	if (m_strImage) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, m_strImage, m_vecSize, [1,1,1], 1.0f, 0);
	}
}

bool
VGUIPic::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}

void
VGUIPic::SetImage (string strName)
{
	m_strImage = strName;
	SetSize(drawgetimagesize(m_strImage));
}

string
VGUIPic::GetImage(void)
{
	return m_strImage;
}
