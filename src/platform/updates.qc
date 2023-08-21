/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

typedef struct
{
	string name;
	string category;
	string title;
	string version;
	string description;
	string license;
	string author;
	string website;
	string installed;
	updateState_t state;
	updateAction_t pending_action;
	int size;
	int uid;
	string preview_image;
	float dlpercentage;
} update_t;

string(float id, float b) getgamedirinfo = #0;
string(int packageidx, int desiredfield) getpackagemanagerinfo = #0;

#define FN_UPDATE_IMGURL "http://www.frag-net.com/dl/img/%s.jpg"
int g_platform_update_count;
update_t *updates;

var updaterStatus_t updater_package_status = UPDATER_NONE;

void
Updates_Init(void)
{
	string packages;

	/* first, see if our game info sets any packages. */
	packages = GameLibrary_GetInfo(GAMEINFO_PACKAGELIST);

	/* we have no hard-coded list of supported packages, so query frag-net.com */
	if (!packages) {
		string gamedir = cvar_string("fs_game");
		print(sprintf("Querying package names for %s\n", gamedir));
		uri_get(sprintf("http://www.frag-net.com/dl/packages_%s", uri_escape(gamedir)), MODSERVER_REQ_PKGNAMES);
		updater_package_status = UPDATER_PENDING;
	} else {
		updater_package_status = UPDATER_INITIALIZED;
	}
}

updaterStatus_t
Updates_GetUpdaterStatus(void)
{
	return updater_package_status;
}

int
Updates_GetPackageCount(void)
{
	return g_platform_update_count;
}

/** Checks a given package name and sees if it's in the list of recommended packages. */
bool
Updates_IsRecommended(string packageName)
{
	string newName = "";
	int countPkg = 0i;
	string packageList = GameLibrary_GetInfo(GAMEINFO_PACKAGELIST);

	/* cancel out early if need be */
	if not (packageList)
		return true;

	/* get rid of the version string FTEQW appends */
	tokenizebyseparator(packageName, "=");
	newName = argv(0);

	/* iterate over the recommended packages */
	countPkg = (int)tokenizebyseparator(packageList, ";");

	for (int i = 0i; i < countPkg; i++) {
		/* there's a match */
		if (newName == argv(i))
			return true;
	}

	/* if nothing is found at all. */
	return false;
}

static void
Updates_RefreshStateValues(int packageID)
{
	int pkgUID = updates[packageID].uid;
	string installedState = getpackagemanagerinfo(pkgUID, GPMI_INSTALLED);
	string actionState = getpackagemanagerinfo(pkgUID, GPMI_ACTION);

	switch (actionState) {
	case "user":
		updates[packageID].pending_action = UPDATEACTION_INSTALL;
		break;
	case "reinstall":
		updates[packageID].pending_action = UPDATEACTION_REINSTALL;
		break;
	case "purge":
		updates[packageID].pending_action = UPDATEACTION_UNINSTALL;
		break;
	case "auto":
		updates[packageID].pending_action = UPDATEACTION_AUTOINSTALL;
		break;
	case "disable":
		updates[packageID].pending_action = UPDATEACTION_DISABLE;
		break;
	case "retain":
		/*updates[packageID].pending_action = UPDATEACTION_RETAIN;
		break;*/
	default:
		updates[packageID].pending_action = UPDATEACTION_NONE;
	}

	switch (installedState) {
	case "present":
		updates[packageID].state = UPDATESTATE_DISABLED;
		break;
	case "enabled":
		updates[packageID].state = UPDATESTATE_ENABLED;
		break;
	case "corrupt":
		updates[packageID].state = UPDATESTATE_CORRUPT;
		break;
	case "pending":
		updates[packageID].state = UPDATESTATE_PENDING;
		break;
	default:
		updates[packageID].state = UPDATESTATE_NONE;
	}

	updates[packageID].dlpercentage = stof(installedState);

	/* HACK: the engine doesn't seem to set pending while installing, so let us do the job then */
	if (updates[packageID].dlpercentage > 0)
		updates[packageID].state = UPDATESTATE_PENDING;

	/* HACK: enabled AND pending installation? smells like an engine bug! */
	if (updates[packageID].state == UPDATESTATE_ENABLED) {
		if (updates[packageID].pending_action == UPDATEACTION_INSTALL) {
			updates[packageID].pending_action = UPDATEACTION_NONE;
		}
	}
}

static void
Updates_Refresh(void)
{
	int c = 0i;
	g_platform_update_count = 0i;

	/* clear */
	if (updates) {
		memfree(updates);
	}

	/* count all updates that we've got in our package sources */
	for (int i = 0i; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		g_platform_update_count++;
	}

	updates = memalloc(sizeof(update_t) * g_platform_update_count);

	/* fill in all the package values */
	for (int i = 0i; i < g_platform_update_count; i++) {
		int id = i;

		/* skip not recommended packages */
		if (Updates_IsRecommended(getpackagemanagerinfo(id, GPMI_NAME)) == false)
			continue;

		updates[c].name = getpackagemanagerinfo(id, GPMI_NAME);
		updates[c].category = getpackagemanagerinfo(id, GPMI_CATEGORY);
		updates[c].title = getpackagemanagerinfo(id, GPMI_TITLE);
		updates[c].version = getpackagemanagerinfo(id, GPMI_VERSION);
		updates[c].description = getpackagemanagerinfo(id, GPMI_DESCRIPTION);
		updates[c].license = getpackagemanagerinfo(id, GPMI_LICENSE);
		updates[c].author = getpackagemanagerinfo(id, GPMI_AUTHOR);
		updates[c].website = getpackagemanagerinfo(id, GPMI_WEBSITE);

		updates[c].size = (int)stof(getpackagemanagerinfo(id, GPMI_FILESIZE));
		updates[c].uid = i;
		updates[c].preview_image = sprintf(FN_UPDATE_IMGURL, updates[c].name);
		Updates_RefreshStateValues(c);

		c++;
	}

	print(sprintf("Updates packages for this game: %i (%i Total)\n", c, g_platform_update_count));
	g_platform_update_count = c;
}

__variant
Updates_GetInfo(int packageID, updateType_t fieldType)
{
	if (packageID >= g_platform_update_count || packageID < 0i) {
		print(sprintf("Updates_GetInfo: Invalid package id %i!\n", packageID));
		return __NULL__;
	}

	switch (fieldType) {
	case UPDATE_NAME:
		return (string)updates[packageID].name;
		break;
	case UPDATE_CATEGORY:
		return (string)updates[packageID].category;
		break;
	case UPDATE_TITLE:
		return (string)updates[packageID].title;
		break;
	case UPDATE_VERSION:
		return (string)updates[packageID].version;
		break;
	case UPDATE_DESCRIPTION:
		return (string)updates[packageID].description;
		break;
	case UPDATE_LICENSE:
		return (string)updates[packageID].license;
		break;
	case UPDATE_AUTHOR:
		return (string)updates[packageID].author;
		break;
	case UPDATE_WEBSITE:
		return (string)updates[packageID].website;
		break;
	case UPDATE_STATE:
		return (updateState_t)updates[packageID].state;
		break;
	case UPDATE_ACTION:
		return (updateAction_t)updates[packageID].pending_action;
		break;
	case UPDATE_FILESIZE:
		return (int)updates[packageID].size;
		break;
	case UPDATE_PREVIEWIMAGE:
		return (string)updates[packageID].preview_image;
		break;
	case UPDATE_STATUSSTRING:
		/* if we have a action, focus on that */
		switch (updates[packageID].pending_action) {
			case UPDATEACTION_INSTALL:
				Updates_RefreshStateValues(packageID);

				if (updates[packageID].dlpercentage > 0.0) {
					return sprintf("%d %%", updates[packageID].dlpercentage);
				} else {
					return _("UPDATE_PENDING_INSTALL");
				}
				break;
			case UPDATEACTION_REINSTALL:
				Updates_RefreshStateValues(packageID);
				return _("UPDATE_PENDING_REINSTALL");
				break;
			case UPDATEACTION_UNINSTALL:
				Updates_RefreshStateValues(packageID);
				return _("UPDATE_PENDING_UNINSTALL");
				break;
			case UPDATEACTION_AUTOINSTALL:
				Updates_RefreshStateValues(packageID);
				return _("UPDATE_PENDING_AUTOINSTALL");
				break;
			case UPDATEACTION_DISABLE:
				Updates_RefreshStateValues(packageID);
				return _("UPDATE_PENDING_DISABLE");
				break;
			case UPDATEACTION_RETAIN:
				Updates_RefreshStateValues(packageID);
				return _("UPDATE_PENDING_RETAIN");
				break;
			default:
				switch (updates[packageID].state) {
				case UPDATESTATE_DISABLED:
					return _("UPDATE_DISABLED");
					break;
				case UPDATESTATE_ENABLED:
					return _("UPDATE_ENABLED");
					break;
				case UPDATESTATE_CORRUPT:
					return _("UPDATE_CORRUPT");
					break;
				default:
					return _("UPDATE_NOTINSTALLED");
				}
			}
			break;
		break;
	case UPDATE_DLPERCENTAGE:
		return updates[packageID].dlpercentage;
		break;
	default:
		return __NULL__;
	}
}

bool
Updates_Available(void)
{
	return true;
}

bool
Updates_Toggle(int packageID)
{
	if (packageID >= g_platform_update_count || packageID < 0i) {
		print(sprintf("Updates_Toggle: Invalid package id %i!\n", packageID));
		return false;
	}

	switch (updates[packageID].pending_action) {
	case UPDATEACTION_INSTALL:
	case UPDATEACTION_REINSTALL:
		localcmd(sprintf("pkg rem %s\n", updates[packageID].name));
		break;
	case UPDATEACTION_UNINSTALL:
	case UPDATEACTION_DISABLE:
		localcmd(sprintf("pkg add %s\n", updates[packageID].name));
		break;
	default:
		if (updates[packageID].state == UPDATESTATE_ENABLED) {
			localcmd(sprintf("pkg rem %s\n", updates[packageID].name));
		} else {
			localcmd(sprintf("pkg add %s\n", updates[packageID].name));
		}
		break;
	}
	localcmd(sprintf("platformRefreshUpdates %i\n", packageID));

	return true;
}

bool
Updates_Install(int packageID)
{
	if (packageID >= g_platform_update_count || packageID < 0i) {
		print(sprintf("Updates_Install: Invalid package id %i!\n", packageID));
		return false;
	}

	localcmd(sprintf("pkg add %s\n", updates[packageID].name));
	localcmd(sprintf("platformRefreshUpdates %i\n", packageID));
	print(sprintf("Marking package %s for install.\n", updates[packageID].title));
	return true;
}

bool
Updates_Remove(int packageID)
{
	if (packageID >= g_platform_update_count || packageID < 0i) {
		print(sprintf("Updates_Remove: Invalid package id %i!\n", packageID));
		return false;
	}

	localcmd(sprintf("pkg rem %s\n", updates[packageID].name));
	localcmd(sprintf("platformRefreshUpdates %i\n", packageID));
	print(sprintf("Marking package %s for 'removal'.\n", updates[packageID].title));
	return true;
}

bool
Updates_Destroy(int packageID)
{
	if (packageID >= g_platform_update_count || packageID < 0i) {
		print(sprintf("Updates_Destroy: Invalid package id %i!\n", packageID));
		return false;
	}

	localcmd(sprintf("pkg del %s\n", updates[packageID].name));
	localcmd(sprintf("platformRefreshUpdates %i\n", packageID));
	print(sprintf("Marking package %s for 'deletion'.\n", updates[packageID].title));
	return true;
}

bool
Updates_ApplyPendingChanges(void)
{
	cvar_set("menu_updating", "1");
	localcmd("pkg apply\n");
	print("Applying package changes.\n");
	return true;
}

/* I hate having to put this in, but because we can only interact with the
engine its own package manager via console commands (they are delayed as
as result) we cannot query the result of our `pkg` commands right after
calling them via localcmd(). Therefore menus need to implement the console
command `platformRefreshUpdates` which calls this very function below.
All in the hopes of improving performance just a tiny bit. */
void
Updates_RefreshState(void)
{
	/* at least try to be a bit clever about it. */
	if (argv(0) == "platformRefreshUpdates") {
		Updates_RefreshStateValues((int)stof(argv(1)));
		return;
	}

	/* just force refresh them all otherwise. */
	for (int i = 0i; i < g_platform_update_count; i++) {
		Updates_RefreshStateValues(i);
	}
}

void
Updater_URI_Callback(float id, float code, string data, int resourcebytes)
{
	/* game does not have a recommended package listing remotely? make something up. */
	if (code == 404) {
		string gameDir = cvar_string("fs_game");
		games[GameLibrary_GetCurrentGame()].pkgname = strcat("cg_", gameDir, ";game_", gameDir, ";");

	} else {
		//print(sprintf("URI: %d %d %S %i\n", id, code, data, resourcebytes));
		games[GameLibrary_GetCurrentGame()].pkgname = data;
	}

	updater_package_status = UPDATER_INITIALIZED;
	Updates_Refresh();
}