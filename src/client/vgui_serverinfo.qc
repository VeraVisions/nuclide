/*
 * Copyright (c) 2025 Vera Visions LLC.
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

int g_iServerInfoInitialized;
static vguiList lsbServerInfo;
static vguiScrollBar scrlServerInfo;

#define SERVERINFO_FIELDS 5i

string cg_serverinfoFields = "hostname,ip,mode,sv_playerslots,maxclients,maxspectators,mapname";

static void
VGUI_ShowServerInfo_ScrollUpdate (void)
{
	scrlServerInfo.SetValue(lsbServerInfo.GetOffset());
}

static void
VGUI_ShowServerInfo_ListUpdate (void)
{
	lsbServerInfo.SetOffset(scrlServerInfo.GetValue(), FALSE);
}


void
VGUI_ShowServerInfo_RefreshEntries(void)
{
	int serverInfoCount = tokenizebyseparator(cg_serverinfoFields, ",");
	lsbServerInfo.RemoveAllItems();
	lsbServerInfo.SetItemCount(serverInfoCount);
	lsbServerInfo.CallOnScroll(VGUI_ShowServerInfo_ScrollUpdate);

	for (int i = 0; i < tokenizebyseparator(cg_serverinfoFields, ","); i++) {
		string keyName = argv(i);
		string keyValue = serverkey(keyName);
		lsbServerInfo.AddItem(strcat("^8",keyName, ": ^7", keyValue));
	}

	scrlServerInfo.SetMax(lsbServerInfo.GetMaxVisibleItems());
}

void
VGUI_ShowServerInfo(void)
{
	static vguiWindow winServerInfo;
	static vguiButton btnRefresh;

	if (!g_iServerInfoInitialized) {
		g_iServerInfoInitialized = true;
		winServerInfo = spawn(vguiWindow);
		winServerInfo.SetTitle("Server Info");
		winServerInfo.SetSize([256,180]);
		winServerInfo.SetIcon("gfx/icon16/server");

		lsbServerInfo = spawn(vguiList);
		lsbServerInfo.SetSize([192, 96]);
		lsbServerInfo.SetPos([8, 32]);
		lsbServerInfo.CallOnScroll(VGUI_ShowServerInfo_ScrollUpdate);

		scrlServerInfo = spawn(vguiScrollBar);
		scrlServerInfo.SetLength(96);
		scrlServerInfo.SetPos([201,32]);
		scrlServerInfo.SetMin(0);
		scrlServerInfo.SetStep(1);
		scrlServerInfo.CallOnChange(VGUI_ShowServerInfo_ListUpdate);

		btnRefresh = spawn(vguiButton);
		btnRefresh.SetTitle("Refresh");
		btnRefresh.SetIcon("gfx/icon16/refresh");
		btnRefresh.SetPos([8,132]);
		btnRefresh.SetSize([64,24]);
		btnRefresh.SetFunc(VGUI_ShowServerInfo_RefreshEntries);

		g_uiDesktop.Add(winServerInfo);
		winServerInfo.Add(lsbServerInfo);
		winServerInfo.Add(scrlServerInfo);
		winServerInfo.Add(btnRefresh);

		VGUI_ShowServerInfo_RefreshEntries();
	}

	winServerInfo.Show();
	winServerInfo.SetPos((g_vidsize / 2) - (winServerInfo.GetSize() / 2));
}
