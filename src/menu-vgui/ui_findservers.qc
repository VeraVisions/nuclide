/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

int g_iServerBrowserInitialized;

void UI_FindServers_Show ( void )
{
	static vguiWindow winServers;
	static vguiList listTVGames;
	static vguiList listLANGames;
	static vguiList listInternetGames;
	static vguiList listPastGames;
	static vguiList listTVGamesID;
	static vguiList listLANGamesID;
	static vguiList listInternetGamesID;
	static vguiList listPastGamesID;
	static vguiButton btnUpdateList;
	static vguiButton btnRefreshList;
	static vguiButton btnConnect;

	static vguiButton tabInternetServers;
	static vguiButton tabLANServers;
	static vguiButton tabHistoricServers;
	static vguiButton tabSpectateServers;

	static vguiPic picMapShot;
	static vguiLabel lblTitle;
	static vguiLabel lblMap;
	static vguiLabel lblPlayers;
	static vguiLabel lblTimeLimit;
	static vguiLabel lblPing;
	static vguiList targetCategory;
	static vguiList targetCategoryID;

	static void Servers_UpdateSpectateGames ( void ) {
		int selectedEntry = listTVGames.GetSelected();
		int value = (int)stof(listTVGamesID.GetItem(selectedEntry));
		picMapShot.SetImage(Servers_GetInfo(value, SERVERGAME_MAP));
		picMapShot.SetSize( [232, 174] );
		lblTitle.SetTitle(strcat("Title: ", Servers_GetInfo(value, SERVERGAME_TITLE)));
		lblMap.SetTitle(strcat("Map: ", Servers_GetInfo(value, SERVERGAME_MAP)));
		lblPlayers.SetTitle(sprintf("Players: %i", Servers_GetInfo(value, SERVERGAME_PLAYERS)));
		lblTimeLimit.SetTitle(sprintf("Player limit: %i", Servers_GetInfo(value, SERVERGAME_MAXPLAYERS)));
		lblPing.SetTitle(sprintf("Ping: %i", Servers_GetInfo(value, SERVERGAME_PING)));
	}
	static void Servers_UpdateLANGames ( void ) {
		int selectedEntry = listLANGames.GetSelected();
		int value = (int)stof(listLANGamesID.GetItem(selectedEntry));
		picMapShot.SetImage(Servers_GetInfo(value, SERVERGAME_MAP));
		picMapShot.SetSize( [232, 174] );
		lblTitle.SetTitle(strcat("Title: ", Servers_GetInfo(value, SERVERGAME_TITLE)));
		lblMap.SetTitle(strcat("Map: ", Servers_GetInfo(value, SERVERGAME_MAP)));
		lblPlayers.SetTitle(sprintf("Players: %i", Servers_GetInfo(value, SERVERGAME_PLAYERS)));
		lblTimeLimit.SetTitle(sprintf("Player limit: %i", Servers_GetInfo(value, SERVERGAME_MAXPLAYERS)));
		lblPing.SetTitle(sprintf("Ping: %i", Servers_GetInfo(value, SERVERGAME_PING)));
	}
	static void Servers_UpdateInternetGames ( void ) {
		int selectedEntry = listInternetGames.GetSelected();
		int value = (int)stof(listInternetGamesID.GetItem(selectedEntry));
		picMapShot.SetImage(Servers_GetInfo(value, SERVERGAME_MAP));
		picMapShot.SetSize( [232, 174] );
		lblTitle.SetTitle(strcat("Title: ", Servers_GetInfo(value, SERVERGAME_TITLE)));
		lblMap.SetTitle(strcat("Map: ", Servers_GetInfo(value, SERVERGAME_MAP)));
		lblPlayers.SetTitle(sprintf("Players: %i", Servers_GetInfo(value, SERVERGAME_PLAYERS)));
		lblTimeLimit.SetTitle(sprintf("Player limit: %i", Servers_GetInfo(value, SERVERGAME_MAXPLAYERS)));
		lblPing.SetTitle(sprintf("Ping: %i", Servers_GetInfo(value, SERVERGAME_PING)));
	}
	static void Servers_UpdatePastGames ( void ) {
		int selectedEntry = listPastGames.GetSelected();
		int value = (int)stof(listPastGamesID.GetItem(selectedEntry));
		picMapShot.SetImage(Servers_GetInfo(value, SERVERGAME_MAP));
		picMapShot.SetSize( [232, 174] );
		lblTitle.SetTitle(strcat("Title: ", Servers_GetInfo(value, SERVERGAME_TITLE)));
		lblMap.SetTitle(strcat("Map: ", Servers_GetInfo(value, SERVERGAME_MAP)));
		lblPlayers.SetTitle(sprintf("Players: %i", Servers_GetInfo(value, SERVERGAME_PLAYERS)));
		lblTimeLimit.SetTitle(sprintf("Player limit: %i", Servers_GetInfo(value, SERVERGAME_MAXPLAYERS)));
		lblPing.SetTitle(sprintf("Ping: %i", Servers_GetInfo(value, SERVERGAME_PING)));
	}

	static void Servers_Update ( void ) {
		Master_UpdateCache();
	}
	static void Servers_Connect ( void ) {
		int selectedEntry = listInternetGames.GetSelected();
		localcmd(sprintf("connect %s\n", Servers_GetInfo(selectedEntry, SERVERGAME_ADDRESS)));
	}

	static void Servers_ShowMaps(void) {
		listTVGames.Hide();
		listLANGames.Hide();
		listPastGames.Hide();
		listInternetGames.Show();
		listInternetGames.SetSelected(0);
		targetCategory = listInternetGames;
		targetCategoryID = listInternetGamesID;
		Servers_UpdateInternetGames();
	}

	static void Servers_ShowAddons(void) {
		listTVGames.Hide();
		listLANGames.Hide();
		listInternetGames.Hide();
		listPastGames.Show();
		listPastGames.SetSelected(0);
		targetCategory = listPastGames;
		targetCategoryID = listPastGamesID;
		Servers_UpdatePastGames();
	}

	static void Servers_ShowMods(void) {
		listTVGames.Hide();
		listInternetGames.Hide();
		listPastGames.Hide();
		listLANGames.Show();
		listLANGames.SetSelected(0);
		targetCategory = listLANGames;
		targetCategoryID = listLANGamesID;
		Servers_UpdateLANGames();
	}

	static void Servers_ShowPatches(void) {
		listLANGames.Hide();
		listInternetGames.Hide();
		listPastGames.Hide();
		listTVGames.Show();
		listTVGames.SetSelected(0);
		targetCategory = listTVGames;
		Servers_UpdateSpectateGames();
	}

	static void Servers_FillList(void) {
		int modCount = 0i;
		int mapCount = 0i;
		int addonCount = 0i;
		int patchCount = 0i;

		for ( int i = 0; i < Master_GetTotalServers(); i++ ) {
			patchCount++;
			modCount++;
			mapCount++;
			addonCount++;
		}

		listTVGames.SetItemCount( patchCount );
		listTVGamesID.SetItemCount( patchCount );
		listLANGames.SetItemCount( modCount );
		listLANGamesID.SetItemCount( modCount );
		listPastGames.SetItemCount( addonCount );
		listPastGamesID.SetItemCount( addonCount );
		listInternetGames.SetItemCount( mapCount );
		listInternetGamesID.SetItemCount( mapCount );

		if (modCount) {
		//	tabLANServers.SetFunc( Servers_ShowMods );
		}
		if (addonCount) {
			//tabHistoricServers.SetFunc( Servers_ShowAddons );
		}
		if (mapCount) {
			tabInternetServers.SetFunc( Servers_ShowMaps );
		}
		if (patchCount) {
			//tabSpectateServers.SetFunc( Servers_ShowPatches );
		}

		for ( int i = 0; i < Master_GetTotalServers(); i++ ) {
				listTVGames.AddItem( Servers_GetInfo(i, SERVERGAME_ADDRESS) );
				listTVGamesID.AddItem(sprintf("%i", i));
				listLANGames.AddItem( Servers_GetInfo(i, SERVERGAME_ADDRESS) );
				listLANGamesID.AddItem(sprintf("%i", i));
				listInternetGames.AddItem( Servers_GetInfo(i, SERVERGAME_ADDRESS) );
				listInternetGamesID.AddItem(sprintf("%i", i));
				listPastGames.AddItem( Servers_GetInfo(i, SERVERGAME_ADDRESS) );
				listPastGamesID.AddItem(sprintf("%i", i));
			
		}
	}
	static void Servers_Refresh ( void ) {
		Master_RefreshCache();
		Servers_FillList();
	}

	if ( !g_iServerBrowserInitialized ) {
		g_iServerBrowserInitialized = TRUE;
		winServers = spawn( vguiWindow );
		winServers.SetTitle( "Find Game" );
		winServers.SetSize( [480,360] );
		winServers.SetIcon( "gfx/icon16/world" );

		tabInternetServers = spawn( vguiButton );
		tabInternetServers.SetTitle( "Internet" );
		tabInternetServers.SetIcon( "gfx/icon16/page_world" );
		tabInternetServers.SetPos( [8,32] );
		tabHistoricServers = spawn( vguiButton );
		tabHistoricServers.SetTitle( "History" );
		tabHistoricServers.SetIcon( "gfx/icon16/page_edit" );
		tabHistoricServers.SetPos( tabInternetServers.GetPos() + [tabInternetServers.GetWidth() + 8, 0] );
		tabLANServers = spawn( vguiButton );
		tabLANServers.SetTitle( "LAN" );
		tabLANServers.SetIcon( "gfx/icon16/page_lightning" );
		tabLANServers.SetPos( tabHistoricServers.GetPos() + [tabHistoricServers.GetWidth() + 8, 0] );
		tabSpectateServers = spawn( vguiButton );
		tabSpectateServers.SetTitle( "Spectate" );
		tabSpectateServers.SetIcon( "gfx/icon16/page_find" );
		tabSpectateServers.SetPos( tabLANServers.GetPos() + [tabLANServers.GetWidth() + 8, 0] );

		listTVGames = spawn( vguiList );
		listTVGamesID = spawn( vguiList );
		listTVGames.SetSize( [192, 360-16-24-64] );
		listTVGames.SetPos( [8, 32+32] );
		listTVGames.CallOnSelectionChanged(Servers_UpdateSpectateGames);

		listInternetGames = spawn( vguiList );
		listInternetGamesID = spawn( vguiList );
		listInternetGames.SetSize( [192, 360-16-24-64] );
		listInternetGames.SetPos( [8, 32+32] );
		listInternetGames.CallOnSelectionChanged(Servers_UpdateInternetGames);

		listLANGames = spawn( vguiList );
		listLANGamesID = spawn( vguiList );
		listLANGames.SetSize( [192, 360-16-24-64] );
		listLANGames.SetPos( [8, 32+32] );
		listLANGames.CallOnSelectionChanged(Servers_UpdateLANGames);

		listPastGames = spawn( vguiList );
		listPastGamesID = spawn( vguiList );
		listPastGames.SetSize( [192, 360-16-24-64] );
		listPastGames.SetPos( [8, 32+32] );
		listPastGames.CallOnSelectionChanged(Servers_UpdatePastGames);

		btnConnect = spawn( vguiButton );
		btnConnect.SetTitle( "Connect" );
		btnConnect.SetIcon( "gfx/icon16/world_go" );
		btnConnect.SetPos( [480-80-8,360-24-8] );
		btnConnect.SetSize([80,24]);
		btnConnect.SetFunc( Servers_Connect );

		btnUpdateList = spawn( vguiButton );
		btnUpdateList.SetTitle( "Update" );
		btnUpdateList.SetIcon( "gfx/icon16/page_go" );
		btnUpdateList.SetPos( [8,360-24-8] );
		btnUpdateList.SetSize([80,24]);
		btnUpdateList.SetFunc( Servers_Update );

		btnRefreshList = spawn( vguiButton );
		btnRefreshList.SetTitle( "Refresh" );
		btnRefreshList.SetIcon( "gfx/icon16/page_refresh" );
		btnRefreshList.SetPos(  btnUpdateList.GetPos() + [btnUpdateList.GetWidth() + 8, 0] );
		btnRefreshList.SetSize([80,24]);
		btnRefreshList.SetFunc( Servers_Refresh );

		picMapShot = spawn(vguiPic);
		picMapShot.SetPos( [232, 64] );
		picMapShot.SetSize( [232, 174] );
		picMapShot.SetBorder(4);

		lblTitle = spawn(vguiLabel);
		lblTitle.SetPos( picMapShot.GetPos() + [0, picMapShot.GetHeight() + 8] );
		lblTitle.SetSize( [232, 16] );

		lblMap = spawn(vguiLabel);
		lblMap.SetPos( lblTitle.GetPos() + [0, 16] );
		lblMap.SetSize( [232, 16] );

		lblPlayers = spawn(vguiLabel);
		lblPlayers.SetPos( lblMap.GetPos() + [0, 16] );
		lblPlayers.SetSize( [232, 16] );

		lblTimeLimit = spawn(vguiLabel);
		lblTimeLimit.SetPos( lblPlayers.GetPos() + [0, 16] );
		lblTimeLimit.SetSize( [232, 16] );

		lblPing = spawn(vguiLabel);
		lblPing.SetPos( lblTimeLimit.GetPos() + [0, 16] );
		lblPing.SetSize( [232, 16] );

		g_uiDesktop.Add( winServers );
		winServers.Add( listTVGames );
		winServers.Add( listInternetGames );
		winServers.Add( listLANGames );
		winServers.Add( listPastGames );
		winServers.Add( btnConnect );
		winServers.Add( btnUpdateList );
		winServers.Add( btnRefreshList );
		winServers.Add( tabInternetServers );
		winServers.Add( tabHistoricServers );
		winServers.Add( tabLANServers );
		winServers.Add( tabSpectateServers );

		winServers.Add( picMapShot );
		winServers.Add( lblTitle );
		winServers.Add( lblMap );
		winServers.Add( lblPlayers );
		winServers.Add( lblTimeLimit );
		winServers.Add( lblPing );
		Servers_ShowMaps();
	}

	winServers.Show();
	winServers.SetPos( ( g_vidsize / 2 ) - ( winServers.GetSize() / 2 ) );
}
