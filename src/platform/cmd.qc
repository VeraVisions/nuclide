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

bool
Platform_ConsoleCommand(string commandString, int wordCount)
{
	switch (argv(0)) {
	case "richpresence_dump":
		RichPresence_DumpInfo();
		break;
	case "menu_musicstart":
		Music_MenuStart();
		break;
	case "menu_musictrack":
		Music_ParseTrack(argv(1));
		break;
	case "menu_musicloop":
		Music_ParseLoop(argv(1));
		break;
	//case "togglemenu":
		//m_display();
	//	break;
	case "map_background":
		localcmd(sprintf("maxplayers 2\nset coop 1\nset sv_background 1\nmap %s\n",
			argv(1)));
		break;
	case "listGameLibrary":
		GameLibrary_DebugList();
		break;
	case "devMap":
		localcmd(sprintf("disconnect;set sv_cheats 1;map %S\n", argv(1)));
		break;
	case "ap_userID":
		ActivityPub_FetchAccountData(argv(1));
		break;
	default:
		return (false);
	}

	return (true);
}

void
Platform_RegisterCommands(void)
{
	registercommand("richpresence_dump");
	registercommand("menu_musicstart");
	registercommand("menu_musictrack");
	registercommand("menu_musicloop");
	registercommand("map_background");
	registercommand("listGameLibrary");
	registercommand("devMap");
	registercommand("ap_userID");
}