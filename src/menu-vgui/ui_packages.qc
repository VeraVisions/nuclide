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

int g_iPackagesInitialized;

void UI_Packages_Show ( void )
{
	static vguiWindow winPackages;
	static vguiList listPatches;
	static vguiList listMods;
	static vguiList listMaps;
	static vguiList listAddons;
	static vguiList listPatchesID;
	static vguiList listModsID;
	static vguiList listMapsID;
	static vguiList listAddonsID;
	static vguiScrollBar scrlSaves;
	static vguiButton btnAdd;
	static vguiButton btnDelete;
	static vguiButton btnApply;

	static vguiButton tabMaps;
	static vguiButton tabMods;
	static vguiButton tabAddons;
	static vguiButton tabPatches;

	static vguiPic picPreview;
	static vguiLabel lblAuthor;
	static vguiLabel lblStatus;
	static vguiLabel lblLicense;
	static vguiLabel lblWebsite;
	static vguiLabel lblVersion;
	static vguiList targetCategory;
	static vguiList targetCategoryID;

	static void Packages_ScrollUpdate ( void ) {
		scrlSaves.SetValue( listPatches.GetOffset() );
	}
	static void Packages_ListUpdate ( void ) {
		int value = scrlSaves.GetValue();
		listPatches.SetOffset(value, FALSE);
	}
	static void Packages_UpdateDetails ( void ) {
		int selectedEntry = listPatches.GetSelected();
		int value = (int)stof(listPatchesID.GetItem(selectedEntry));
		picPreview.SetImage(Updates_GetInfo(value, UPDATE_PREVIEWIMAGE));
		picPreview.SetSize( [232, 174] );
		lblAuthor.SetTitle(strcat("Author: ", Updates_GetInfo(value, UPDATE_AUTHOR)));
		lblStatus.SetTitle(strcat("Status: ", Updates_GetInfo(value, UPDATE_STATUSSTRING)));
		lblLicense.SetTitle(strcat("License: ", Updates_GetInfo(value, UPDATE_LICENSE)));
		lblWebsite.SetTitle(strcat("Website: ", Updates_GetInfo(value, UPDATE_WEBSITE)));
		lblVersion.SetTitle(strcat("Version: ", Updates_GetInfo(value, UPDATE_VERSION)));
	}
	static void Packages_UpdateModDetails ( void ) {
		int selectedEntry = listMods.GetSelected();
		int value = (int)stof(listModsID.GetItem(selectedEntry));
		picPreview.SetImage(Updates_GetInfo(value, UPDATE_PREVIEWIMAGE));
		picPreview.SetSize( [232, 174] );
		lblAuthor.SetTitle(strcat("Author: ", Updates_GetInfo(value, UPDATE_AUTHOR)));
		lblStatus.SetTitle(strcat("Status: ", Updates_GetInfo(value, UPDATE_STATUSSTRING)));
		lblLicense.SetTitle(strcat("License: ", Updates_GetInfo(value, UPDATE_LICENSE)));
		lblWebsite.SetTitle(strcat("Website: ", Updates_GetInfo(value, UPDATE_WEBSITE)));
		lblVersion.SetTitle(strcat("Version: ", Updates_GetInfo(value, UPDATE_VERSION)));
	}
	static void Packages_UpdateMapDetails ( void ) {
		int selectedEntry = listMaps.GetSelected();
		int value = (int)stof(listMapsID.GetItem(selectedEntry));
		picPreview.SetImage(Updates_GetInfo(value, UPDATE_PREVIEWIMAGE));
		picPreview.SetSize( [232, 174] );
		lblAuthor.SetTitle(strcat("Author: ", Updates_GetInfo(value, UPDATE_AUTHOR)));
		lblStatus.SetTitle(strcat("Status: ", Updates_GetInfo(value, UPDATE_STATUSSTRING)));
		lblLicense.SetTitle(strcat("License: ", Updates_GetInfo(value, UPDATE_LICENSE)));
		lblWebsite.SetTitle(strcat("Website: ", Updates_GetInfo(value, UPDATE_WEBSITE)));
		lblVersion.SetTitle(strcat("Version: ", Updates_GetInfo(value, UPDATE_VERSION)));
	}
	static void Packages_UpdateAddonDetails ( void ) {
		int selectedEntry = listAddons.GetSelected();
		int value = (int)stof(listAddonsID.GetItem(selectedEntry));
		picPreview.SetImage(Updates_GetInfo(value, UPDATE_PREVIEWIMAGE));
		picPreview.SetSize( [232, 174] );
		lblAuthor.SetTitle(strcat("Author: ", Updates_GetInfo(value, UPDATE_AUTHOR)));
		lblStatus.SetTitle(strcat("Status: ", Updates_GetInfo(value, UPDATE_STATUSSTRING)));
		lblLicense.SetTitle(strcat("License: ", Updates_GetInfo(value, UPDATE_LICENSE)));
		lblWebsite.SetTitle(strcat("Website: ", Updates_GetInfo(value, UPDATE_WEBSITE)));
		lblVersion.SetTitle(strcat("Version: ", Updates_GetInfo(value, UPDATE_VERSION)));
	}

	static void Packages_Add ( void ) {
		int selectedEntry = targetCategory.GetSelected();
		int value = (int)stof(targetCategoryID.GetItem(selectedEntry));
		Updates_Install(value);
	}
	static void Packages_Delete ( void ) {
		int selectedEntry = targetCategory.GetSelected();
		int value = (int)stof(targetCategoryID.GetItem(selectedEntry));
		Updates_Remove(value);
	}
	static void Packages_Apply ( void ) {
		Updates_ApplyPendingChanges();
	}

	static void Packages_ShowMaps(void) {
		listPatches.Hide();
		listMods.Hide();
		listAddons.Hide();
		listMaps.Show();
		listMaps.SetSelected(0);
		targetCategory = listMaps;
		targetCategoryID = listMapsID;
		Packages_UpdateMapDetails();
	}

	static void Packages_ShowAddons(void) {
		listPatches.Hide();
		listMods.Hide();
		listMaps.Hide();
		listAddons.Show();
		listAddons.SetSelected(0);
		targetCategory = listAddons;
		targetCategoryID = listAddonsID;
		Packages_UpdateAddonDetails();
	}

	static void Packages_ShowMods(void) {
		listPatches.Hide();
		listMaps.Hide();
		listAddons.Hide();
		listMods.Show();
		listMods.SetSelected(0);
		targetCategory = listMods;
		targetCategoryID = listModsID;
		Packages_UpdateModDetails();
	}

	static void Packages_ShowPatches(void) {
		listMods.Hide();
		listMaps.Hide();
		listAddons.Hide();
		listPatches.Show();
		listPatches.SetSelected(0);
		targetCategory = listPatches;
		Packages_UpdateDetails();
	}

	if ( !g_iPackagesInitialized ) {
		g_iPackagesInitialized = TRUE;
		Updates_Init();
		winPackages = spawn( vguiWindow );
		winPackages.SetTitle( "Packages" );
		winPackages.SetSize( [480,360] );
		winPackages.SetIcon( "gfx/icon16/package" );

		tabMaps = spawn( vguiButton );
		tabMaps.SetTitle( "Maps" );
		tabMaps.SetIcon( "gfx/icon16/map" );
		tabMaps.SetPos( [8,32] );
		tabAddons = spawn( vguiButton );
		tabAddons.SetTitle( "Addons" );
		tabAddons.SetIcon( "gfx/icon16/plugin" );
		tabAddons.SetPos( tabMaps.GetPos() + [tabMaps.GetWidth() + 8, 0] );
		tabMods = spawn( vguiButton );
		tabMods.SetTitle( "Mods" );
		tabMods.SetIcon( "gfx/icon16/rainbow" );
		tabMods.SetPos( tabAddons.GetPos() + [tabAddons.GetWidth() + 8, 0] );
		tabPatches = spawn( vguiButton );
		tabPatches.SetTitle( "Patches" );
		tabPatches.SetIcon( "gfx/icon16/page_world" );
		tabPatches.SetPos( tabMods.GetPos() + [tabMods.GetWidth() + 8, 0] );

		listPatches = spawn( vguiList );
		listPatchesID = spawn( vguiList );
		listPatches.SetSize( [192, 360-16-24-64] );
		listPatches.SetPos( [8, 32+32] );
		listPatches.CallOnSelectionChanged(Packages_UpdateDetails);

		listMaps = spawn( vguiList );
		listMapsID = spawn( vguiList );
		listMaps.SetSize( [192, 360-16-24-64] );
		listMaps.SetPos( [8, 32+32] );
		listMaps.CallOnSelectionChanged(Packages_UpdateMapDetails);

		listMods = spawn( vguiList );
		listModsID = spawn( vguiList );
		listMods.SetSize( [192, 360-16-24-64] );
		listMods.SetPos( [8, 32+32] );
		listMods.CallOnSelectionChanged(Packages_UpdateModDetails);

		listAddons = spawn( vguiList );
		listAddonsID = spawn( vguiList );
		listAddons.SetSize( [192, 360-16-24-64] );
		listAddons.SetPos( [8, 32+32] );
		listAddons.CallOnSelectionChanged(Packages_UpdateAddonDetails);

		int modCount = 0i;
		int mapCount = 0i;
		int addonCount = 0i;
		int patchCount = 0i;

		for ( int i = 0; i < Updates_GetPackageCount(); i++ ) {
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Patch/") {
				patchCount++;
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Mod/") {
				modCount++;
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Map/") {
				mapCount++;
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Addon/") {
				addonCount++;
			}
		}

		listPatches.SetItemCount( patchCount );
		listPatchesID.SetItemCount( patchCount );
		listMods.SetItemCount( modCount );
		listModsID.SetItemCount( modCount );
		listAddons.SetItemCount( addonCount );
		listAddonsID.SetItemCount( addonCount );
		listMaps.SetItemCount( mapCount );
		listMapsID.SetItemCount( mapCount );

		if (modCount) {
			tabMods.SetFunc( Packages_ShowMods );
		}
		if (addonCount) {
			tabAddons.SetFunc( Packages_ShowAddons );
		}
		if (mapCount) {
			tabMaps.SetFunc( Packages_ShowMaps );
		}
		if (patchCount) {
			tabPatches.SetFunc( Packages_ShowPatches );
		}

		for ( int i = 0; i < Updates_GetPackageCount(); i++ ) {
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Patch/") {
				listPatches.AddItem( Updates_GetInfo(i, UPDATE_TITLE) );
				listPatchesID.AddItem(sprintf("%i", i));
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Mod/") {
				listMods.AddItem( Updates_GetInfo(i, UPDATE_TITLE) );
				listModsID.AddItem(sprintf("%i", i));
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Map/") {
				listMaps.AddItem( Updates_GetInfo(i, UPDATE_TITLE) );
				listMapsID.AddItem(sprintf("%i", i));
			}
			if (Updates_GetInfo(i, UPDATE_CATEGORY) == "Addon/") {
				listAddons.AddItem( Updates_GetInfo(i, UPDATE_TITLE) );
				listAddonsID.AddItem(sprintf("%i", i));
			}
		}


		btnApply = spawn( vguiButton );
		btnApply.SetTitle( "Apply" );
		btnApply.SetIcon( "gfx/icon16/package_go" );
		btnApply.SetPos( [480-64-8,360-24-8] );
		btnApply.SetSize([64,24]);
		btnApply.SetFunc( Packages_Apply );

		btnAdd = spawn( vguiButton );
		btnAdd.SetTitle( "Add" );
		btnAdd.SetIcon( "gfx/icon16/package_add" );
		btnAdd.SetPos( [8,360-24-8] );
		btnAdd.SetSize([64,24]);
		btnAdd.SetFunc( Packages_Add );

		btnDelete = spawn( vguiButton );
		btnDelete.SetTitle( "Delete" );
		btnDelete.SetIcon( "gfx/icon16/package_delete" );
		btnDelete.SetPos( [8+64+8,360-24-8] );
		btnDelete.SetSize([80,24]);
		btnDelete.SetFunc( Packages_Delete );

		picPreview = spawn(vguiPic);
		picPreview.SetPos( [232, 64] );
		picPreview.SetSize( [232, 174] );
		picPreview.SetBorder(4);

		lblAuthor = spawn(vguiLabel);
		lblAuthor.SetPos( picPreview.GetPos() + [0, picPreview.GetHeight() + 8] );
		lblAuthor.SetSize( [232, 16] );

		lblStatus = spawn(vguiLabel);
		lblStatus.SetPos( lblAuthor.GetPos() + [0, 16] );
		lblStatus.SetSize( [232, 16] );

		lblLicense = spawn(vguiLabel);
		lblLicense.SetPos( lblStatus.GetPos() + [0, 16] );
		lblLicense.SetSize( [232, 16] );

		lblWebsite = spawn(vguiLabel);
		lblWebsite.SetPos( lblLicense.GetPos() + [0, 16] );
		lblWebsite.SetSize( [232, 16] );

		lblVersion = spawn(vguiLabel);
		lblVersion.SetPos( lblWebsite.GetPos() + [0, 16] );
		lblVersion.SetSize( [232, 16] );

		g_uiDesktop.Add( winPackages );
		winPackages.Add( listPatches );
		winPackages.Add( listMaps );
		winPackages.Add( listMods );
		winPackages.Add( listAddons );
		winPackages.Add( btnApply );
		winPackages.Add( btnAdd );
		winPackages.Add( btnDelete );
		winPackages.Add( tabMaps );
		winPackages.Add( tabAddons );
		winPackages.Add( tabMods );
		winPackages.Add( tabPatches );

		winPackages.Add( picPreview );
		winPackages.Add( lblAuthor );
		winPackages.Add( lblStatus );
		winPackages.Add( lblLicense );
		winPackages.Add( lblWebsite );
		winPackages.Add( lblVersion );
		Packages_ShowMaps();
	}

	winPackages.Show();
	winPackages.SetPos( ( g_vidsize / 2 ) - ( winPackages.GetSize() / 2 ) );
}
