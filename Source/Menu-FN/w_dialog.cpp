/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class CDialog:CWidget
{
	virtual void() Draw;
};

void CDialog::Draw(void)
{
	drawfill([g_menuofs[0]+160,g_menuofs[1]+160], [320,160], [0,0,0], 1.0f);
	drawfill([g_menuofs[0]+161,g_menuofs[1]+161], [318,158], col_prompt_bg, 1.0f);
}
