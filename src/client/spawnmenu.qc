/*
 * Copyright (c) 2024 Vera Visions LLC.
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

vguiWidget g_uiSpawnMenu;

void
SpawnMenu_Init(void)
{
	filestream commandFile;
	string line;
	vguiCommandButton lastButton;
	vguiCommandButton newButton;
	int braceDepth = 0i;
	vector buttonPos = g_vec_null;
	vector mainPos = g_vec_null;
	string mapFilter = "";
	string ourMap = strtolower(serverkey("map"));

	commandFile = fopen("commandmenu.txt", FILE_READ);

	if (commandFile < 0) {
		ncLog("Ignoring missing commandmenu.txt");
		return;
	}

	g_uiSpawnMenu = spawn(vguiWidget);

	while ((line = fgets(commandFile))) {
		int tokensPerLine = tokenize_console(line);

		if (argv(0) == "{") {
			if (!newButton) {
				ncError("Cannot add sub-menu to non-existant button.");
				fclose(commandFile);
				return;
			}

			lastButton = newButton;
			braceDepth++;

			/* positions are relative to the parent, not absolute */
			buttonPos = [lastButton.GetSizeWidth(), 0];
		} else if (argv(0) == "}") { /* end of button menu */
			braceDepth--;
			mapFilter = "";

			if (braceDepth == 0) {
				buttonPos = mainPos;
			} else {
				buttonPos = lastButton.GetPos() + [0, lastButton.GetSizeHeight()];
				lastButton = (vguiCommandButton)lastButton.m_parent;
			}
		} else if (tokensPerLine >= 2) {
			string buttonTitle = "";
			string buttonCommand = "";
			string buttonKey = "";

			if (tokensPerLine == 2) {
				buttonKey = (argv(0));
				buttonTitle = (argv(1));
			} else if (argv(0) == "MAP") {
				mapFilter = strtolower(argv(1));
				buttonKey = (argv(2));
				buttonTitle = (argv(3));
			} else if (substring(argv(0), 0, 4) == "TEAM") {
				//newButton.SetTeamCondition(argv(0));
				buttonKey = (argv(1));
				buttonTitle = (argv(2));
				buttonCommand = (argv(3));
			} else if (argv(0) == "CUSTOM") {
				buttonKey = (argv(1));
				buttonTitle = (argv(2));
				buttonCommand = (argv(3));
			} else if (tokensPerLine == 3) {
				buttonKey = (argv(0));
				buttonTitle = (argv(1));
				buttonCommand = (argv(2));
			}

			/* if this group is filtered, don't add it. */
			if (STRING_SET(mapFilter)) {
				if (mapFilter != ourMap) {
					continue;
				}
			}

			newButton = spawn(vguiCommandButton);
			newButton.SetPos(buttonPos);
			newButton.SetSize([192,24]);
			newButton.SetKeyEquivalent(buttonKey);
			newButton.SetTitle(buttonTitle);

			if (substring(buttonCommand, 0, 1) == "!") {
				newButton.SetExec(strtolower(substring(buttonCommand, 1,-1)));
			} else {
				newButton.SetExec(buttonCommand);
			}

			if (braceDepth == 0) {
				g_uiSpawnMenu.Add(newButton);
				buttonPos = mainPos = newButton.GetPos() + [0, newButton.GetSizeHeight()];
			} else {
				buttonPos[1] += newButton.GetSizeHeight();
				lastButton.Add(newButton);
			}
		}
	}

	fclose(commandFile);
}

void
SpawnMenu_Draw(void)
{
	if (pSeat->m_bSpawnMenu == false)
		return;

	if (g_uiSpawnMenu)
		g_uiSpawnMenu.Draw();
}

bool
SpawnMenu_Input(float flEvType, float flScanX, float flCharY, float flDevID)
{
	if (pSeat->m_bSpawnMenu == false)
		return;

	if (!g_uiSpawnMenu)
		return (false);

	return g_uiSpawnMenu.Input(flEvType, flScanX, flCharY, flDevID);
}

void
SpawnMenu_Open(void)
{
	pSeat->m_bSpawnMenu = true;
}

void
SpawnMenu_Close(void)
{
	pSeat->m_bSpawnMenu = false;
}
