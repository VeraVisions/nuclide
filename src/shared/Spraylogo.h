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

#ifdef CLIENT
/** This entity class represents a ncPlayer their spraylogo. 

@ingroup baseclass
*/
class ncSpraylogo:ncEntity
{
public:
	void ncSpraylogo(void);

	virtual float predraw(void);
	virtual void ReloadVideoResources(void);

private:
	vector m_vecColor;
	vector m_vecPosition;
	vector m_vecAngles;
	int m_iOwnerID;
	string m_strName;
	string m_m_strPath;
	bool m_bInitialized;
	bool m_bMonochrome;
};

void Spray_Parse(void);


const string g_spray_mat_1 = \
	"{\n" \
		"cull disable\n" \
		"polygonOffset\n" \
		"{\n" \
			"map $rt:%s\n" \
			"blendfunc GL_SRC_COLOR GL_ONE_MINUS_SRC_COLOR\n" \
			"rgbGen vertex\n" \
		"}\n" \
	"}";

const string g_spray_mat_0 = \
	"{\n" \
		"cull disable\n" \
		"polygonOffset\n" \
		"{\n" \
			"map $rt:%s\n" \
			"blendfunc blend\n" \
			"rgbGen vertex\n" \
		"}\n" \
	"}";

#endif

#ifdef SERVER
void Spray_RemoveAll(entity entOwner);
float Spray_SendEntity(entity ePEnt, float fChanged);
void CSEv_Spraylogo(void);
#endif
