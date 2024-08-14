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

/**
@defgroup updates Update Manager
@ingroup menu
@brief Game and content update handler functions.

The updater is an abstraction of the engine its own package manager.
Not all packages the engine offers are related to the game you're currently
running. Therefore we offer our own API within Nuclide to deal with game updates.

You want to call Updates_Init() once, after which Updates_GetUpdaterStatus() should be queried to determine when the Updater is ready. That is not necessary, but it might be helpful to throw up a loading screen while that is returning UPDATER_PENDING.

Once Updates_GetUpdaterStatus() reports UPDATER_INITIALIZED, you can expect the loading to be fully done.

The function Updates_GetPackageCount() will report the total amount of update packages available for the game. These are not 'new' updates, they contain every package associated with the game that can and should be installed and kept updated.

Use Updates_GetInfo() to retrieve metadata about individual packages.

@{
*/

/** Different options you can pass to Updates_GetInfo() to retrieve details about a given Update entry. */
typedef enum
{
	UPDATE_NAME,			/**< (string) name of the package, for use with the pkg command. */
	UPDATE_CATEGORY,		/**< (string) category text */
	UPDATE_TITLE,			/**< (string) name of the package, for showing the user. */
	UPDATE_VERSION,			/**< (string) version info (may have multiple with the same name but different versions) */
	UPDATE_DESCRIPTION,		/**< (string) some blurb */
	UPDATE_LICENSE,			/**< (string) what license its distributed under */
	UPDATE_AUTHOR,			/**< (string) name of the person(s) who created it */
	UPDATE_WEBSITE,			/**< (string) where to contribute/find out more info/etc */
	UPDATE_STATE,			/**< (updateState_t) The current state of the update. */
	UPDATE_ACTION,			/**< (updateAction_t) Pending action of the update. */
	UPDATE_FILESIZE,		/**< (int) size to download in bytes. */
	UPDATE_PREVIEWIMAGE,	/**< (string) Path to a preview image in 4:3 aspect ratio. */
	UPDATE_STATUSSTRING,	/**< (string) Localizable string that gives you the update status. */
	UPDATE_DLPERCENTAGE,	/**< (float) Download progress in percent (0-100). */
} updateType_t;

/** Return values from passing UPDATE_STATE to Updates_GetInfo() */
typedef enum
{
	UPDATESTATE_NONE,		/**< Update is not installed, or unavailable. */
	UPDATESTATE_DISABLED,	/**< Update is installed, but disabled. */
	UPDATESTATE_ENABLED,	/**< Update is installed and enabled. */
	UPDATESTATE_CORRUPT,	/**< Update on disk is corrupted. */
	UPDATESTATE_PENDING		/**< Update is pending a change. Usually when we're downloading it. */
} updateState_t;

/** Return values from passing UPDATE_ACTION to Updates_GetInfo() */
typedef enum
{
	UPDATEACTION_NONE,			/**< Update is not marked for any change. */
	UPDATEACTION_INSTALL,		/**< Update marked for installation. */
	UPDATEACTION_REINSTALL,		/**< Update marked as needing re-installation. */
	UPDATEACTION_UNINSTALL,		/**< Update marked for removal. */
	UPDATEACTION_AUTOINSTALL,	/**< Update marked as needing to be installed, due to a dependency. */
	UPDATEACTION_DISABLE,		/**< Update has been marked for disabling. */
	UPDATEACTION_RETAIN			/**< Update has been marked as being retained. */
} updateAction_t;

/** These are the possible return values from Updates_GetUpdaterStatus().
That way you can put up a loading screen for when the updater is still initiliazing, 
or be notified of when an updater is not available at all. */
typedef enum
{
	UPDATER_NONE,			/**< Nuclide's updater has not been initialized. You need to call Updates_Init(). */
	UPDATER_UNAVAILABLE,	/**< Nuclide's updater is unavailable. This may be due to the update server being offline. */
	UPDATER_PENDING,		/**< Nuclide's updater is pending. May change to UNAVAILABLE or INITIALIZED. */
	UPDATER_INITIALIZED		/**< Nuclide's updater is initialized and may have entries. Use Updates_GetPackageCount() to query how many. */
} updaterStatus_t;

/** Data holding Updater Package entries. */
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
} updaterPackage_t;

/** Call this in order to contact the update server and fill the list of updates. */
void Updates_Init(void);
/** Retrieve the status of the updater. See updaterStatus_t for valid return values. */
updaterStatus_t Updates_GetUpdaterStatus(void);
/** Returns the total amount of updates available for the currently running game. */
int Updates_GetPackageCount(void);
/** Query a package (by ID) for its various info fields. See updateType_t for available options. */
__variant Updates_GetInfo(int, updateType_t);
/** Returns if our current game has updates available for any installed packages. */
bool Updates_Available(void);
/** Toggle the installation/disabling of an update. May return true/false if it succeeded in marking the package. */
bool Updates_Toggle(int);
/** Mark an update as pending installion. May return true/false if it succeeded in marking the package. */
bool Updates_Install(int);
/** Mark an update as pending deletion. May return true/false if it succeeded in marking the package. */
bool Updates_Remove(int);
/** Mark an update as pending uninstallation. May return true/false if it succeeded in marking the package. */
bool Updates_Destroy(int);
/** Apply all pending changes to packages. May return true/false if it succeeded in doing so. */
bool Updates_ApplyPendingChanges(void);

/** @} */ // end of updates
