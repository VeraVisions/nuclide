/** needs to be called upon menu-init, and call Updates_Refresh() if auto-updates
   are enabled. if a chooser does not want updates, then we won't. */
void
Updates_Init(void)
{
	/*localcmd("pkg addsource https://www.frag-net.com/pkgs/list\n");*/
	print("Update system initialized.\n");
}

/** will return a cached value */
int
Updates_GetPackageCount(void)
{
	return g_platform_update_count;
}

/** called whenever we need to re-initialize the updates struct */
void
Updates_Refresh(void)
{
	int c = 0i;
	g_platform_update_count = 0i;

	/* clear */
	if (updates) {
		memfree(updates);
	}

	/* count all updates that we've got in our package sources */
	for (int i = 0i; (Updates_GetInfo(i, GPMI_NAME)); i++) {
		g_platform_update_count++;
	}

	updates = memalloc(sizeof(update_t) * g_platform_update_count);

	/* limit it to packages that the game wants */
	tokenizebyseparator(games[gameinfo_current].pkgname, ";");

	/* fill in all the package values */
	for (int i = 0i; i < g_platform_update_count; i++) {
		int id = game_getpackageid(argv(i));

		if (id == -1)
			continue;

		updates[c].name = Updates_GetInfo(id, GPMI_NAME);
		updates[c].category = Updates_GetInfo(id, GPMI_CATEGORY);
		updates[c].title = Updates_GetInfo(id, GPMI_TITLE);
		updates[c].version = Updates_GetInfo(id, GPMI_VERSION);
		updates[c].description = Updates_GetInfo(id, GPMI_DESCRIPTION);
		updates[c].license = Updates_GetInfo(id, GPMI_LICENSE);
		updates[c].author = Updates_GetInfo(id, GPMI_AUTHOR);
		updates[c].website = Updates_GetInfo(id, GPMI_WEBSITE);
		updates[c].installed = Updates_GetInfo(id, GPMI_INSTALLED);
		updates[c].size = (int)stof(Updates_GetInfo(id, GPMI_FILESIZE));
		updates[c].uid = id;
		precache_pic(sprintf(FN_UPDATE_IMGURL, updates[c].name));

		c++;
	}

	print(sprintf("Updates packages for this game: %i (%i Total)\n", c, g_platform_update_count));
	g_platform_update_count = c;
}

/** Returns the package ID for a given name. Will return -1 when not available. */
int
Updates_IDForName(string packageName)
{
	string tempString = "";

	for (int i = 0i; (tempString = getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		if (tempString == packageName)
			return i;
	}

	return -1i;
}

/** Returns the package name for a given ID. Returns __NULL__ when not available. */
string
Updates_NameForID(int packageID)
{
	string packageName = getpackagemanagerinfo(packageID, GPMI_NAME);

	if not (packageName)
		return __NULL__;

	return packageName;
}

/** Query a package (by ID) for its various info fields. See updateType_t for available fields. */
string
Updates_GetInfo(int packageID, updateType_t fieldType)
{
	return getpackagemanagerinfo(packageID, (int)fieldType);
}

/** Returns if our current game has updates available for any installed packages. */
bool
Updates_Available(void)
{
	return true;
}

/** Toggle the installation of a package. Will return true if it was done. */
bool
Updates_Toggle(int packageID)
{
	switch (updates[packageID].installed) {
	case "":
	case "rem":
		localcmd(sprintf("pkg add %s\n", updates[packageID].name));
		updates[packageID].installed = "pending";
		break;
	default:
		localcmd(sprintf("pkg rem %s\n", updates[packageID].name));
		updates[packageID].installed = "rem";
	}

	return true;
}

/** Mark a package as pending installion. May return true/false if it succeeded in marking the package. */
bool
Updates_Install(int packageID)
{
	localcmd(sprintf("pkg add %s\n", updates[packageID].name));
	updates[packageID].installed = "pending";
	print(sprintf("Marking package %s for install.\n", updates[packageID].title));
	return true;
}

/** Mark a package as pending deletion. May return true/false if it succeeded in marking the package. */
bool
Updates_Remove(int packageID)
{

	localcmd(sprintf("pkg rem %s\n", updates[packageID].name));
	updates[packageID].installed = "rem";
	print(sprintf("Marking package %s for 'removal'.\n", updates[packageID].title));
	return true;
}

/** Apply all pending changes to packages. May return true/false if it succeeded in doing so. */
bool
Updates_ApplyPendingChanges(void)
{
	cvar_set("menu_updating", "1");
	localcmd("pkg apply\n");
	print("Applying package changes.\n");
	return true;
}