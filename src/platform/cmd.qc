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
		localcmd(sprintf("set g_gametype \"singleplayer\"\nset sv_playerslots 2\nset coop 1\nset sv_background 1\nmap %s\n",
			argv(1)));
		break;
	case "menu_refreshSavedGames":
		Saves_Init();
		SavesCallback_EntriesUpdated();
		break;
	case "listGameLibrary":
		GameLibrary_DebugList();
		break;
	case "ap_userID":
		ActivityPub_FetchAccountData(argv(1));
		break;
	case "signOn":
		FragNet_SignOn();
		break;
	case "signOff":
		FragNet_SignOff();
		break;
	case "addFriend":
		FragNet_AddFriend(argv(1));
		break;
	case "removeFriend":
		FragNet_RemoveFriend(argv(1));
		break;
	case "reloadMenuLocale":
		Locale_Reload();
		break;
	case "listProfiles":
		ncProfileManager::ListProfiles();
		break;
	case "profile_create":
		ncProfileManager::CreateNamedProfile(argv(1));
		break;
	case "profile_delete":
		ncProfileManager::DeleteNamedProfile(argv(1));
		break;
	case "profile_select":
		ncProfileManager::SetProfileByName(argv(1));
		break;
	case "profile_save":
		ncProfileManager::SaveActiveProfile();
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
	registercommand("ap_userID");
	registercommand("menu_refreshSavedGames");

	/* online service */
	registercommand("signOn");
	registercommand("signOff");
	registercommand("addFriend");
	registercommand("removeFriend");
	registercommand("reloadMenuLocale");
	registercommand("listProfiles");

	registercommand("profile_create");
	registercommand("profile_delete");
	registercommand("profile_select");
	registercommand("profile_save");
}
