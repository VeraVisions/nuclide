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
@defgroup gamelibrary Game Library
@ingroup menu
@brief Locally-installed games, modification control functions

The GameLibrary concerns itself with everything around what a game is,
how to install, activate and deactivate it. Mods are included in this,
so we'll proceed calling them 'games' or 'custom games'.

A game can be installed through two primary means:

- Manual install, like from a .zip or some installer or archive
- Engine package manager install, through our own user interface

And between these, they can come with different metadata/manifests.

It assumed that every game has either a FTE Manifest description,
a gameinfo.txt (Source Engine format) or liblist.gam (GoldSrc format)
that describes various aspects of the game. Like which version it is, what
map will be loaded when you press 'New Game' and so on.

If that info is not available, some placeholder data will be used instead.
However, games installed via the package manager will at least for the
custom game menus not use the on-disk manifest file, but information
provided by the package manager. Once you switch into said game everything
within will be pulled from a file on disk, such as a liblist.gam or gameinfo.txt.

The menu needs to call GameLibrary_Init() once for parsing the currently running
game its own metadata. If you want to index custom games, aka mods, you need
to do so with GameLibrary_InitCustom() afterwards.

Because indexing mods can take a very long time depending on the amount
that is stored on disk, you may want to call GameLibrary_InitCustom() at
a later time.

@{
*/

/** Options for querying Game Library entry information using `GameLibrary_GetInfo()` */
typedef enum
{
	GAMEINFO_TITLE,			/**< (string) The title of the game. E.g. "Action Game" */
	GAMEINFO_GAMEDIR,		/**< (string) The game directory name. E.g. "data" */
	GAMEINFO_FALLBACKDIR,	/**< (string) The directory to be loaded before the game directory. */
	GAMEINFO_BASEDIR,		/**< (string) The first game directory to be loaded. */
	GAMEINFO_WEBSITE,		/**< (string) The game its official website. */
	GAMEINFO_VERSION,		/**< (string) Version number string. */
	GAMEINFO_SIZE,			/**< (int) The size of the game, in bytes. */
	GAMEINFO_TYPE,			/**< (string) The game type. E.g. "Singleplayer" */
	GAMEINFO_NOPLAYERMODELS,/**< (bool) If the game allows player model selection. */
	GAMEINFO_NOSPRAYS,		/**< (bool) If the game allows custom spray logos. */
	GAMEINFO_STARTMAP,		/**< (string) The command for starting a new game. */
	GAMEINFO_TRAININGMAP,	/**< (string) The command for starting the training. */
	GAMEINFO_MINVERSION,	/**< (string) The minimum base game version. */
	GAMEINFO_CHATROOM,		/**< (string) The chatroom for this game. E.g. #action */
	GAMEINFO_READMEFILE,	/**< (string) File name of the readme documentation. */
	GAMEINFO_INTROVIDEO,	/**< (string) File name of the intro video to play. */
	GAMEINFO_MENUMAP,		/**< (string) Name of the map to be used as a background. */
	GAMEINFO_AUTHOR,		/**< (string) Name of the author. */
	GAMEINFO_AUTHORSITE,	/**< (string) The author their website. */
	GAMEINFO_PACKAGELIST,	/**< (string) List of packages, separated by white-space. */
	GAMEINFO_INSTALLED,		/**< (bool) Whether the game is installed. */
} gameInfo_t;

/** Called when initializing the current game. Does not cache custom game/mod info. */
void GameLibrary_Init(void);
/** Called when you want to initialize custom games/mods. Might want to call this later
if the amount of locally installed mods is overwhelming. */
void GameLibrary_InitCustom(void);

/** Install the specified game. */
void GameLibrary_Install(int);
/** Activate the specified game. */
void GameLibrary_Activate(int);
/** Deactivate the currently running mod. Switching back to the base game. */
void GameLibrary_Deactivate(void);

/** Returns true/false depending on if a Game installation is in progress. */
bool GameLibrary_IsInstalling(void);
/** Returns a 0-100% value of game install progress, tracking across multiple packages. */
float GameLibrary_InstallProgress(void);
/** Returns the total amount of games currently available. */
int GameLibrary_GetGameCount(void);
/** Return the ID for the currently active game. */
int GameLibrary_GetCurrentGame(void);
/** Retrieves fields for a given game. See gameInfo_t for a list of fields you can query. */
__variant GameLibrary_GetGameInfo(int, gameInfo_t);
/** Retrieves fields for the currently running game. See gameInfo_t for a list of fields you can query. */
__variant GameLibrary_GetInfo(gameInfo_t);

/** Prints debug info about the currently cached games to the console. */
void GameLibrary_DebugList(void);

typedef enum
{
	GAMEINFO_NONE,		/**< No gameinfo available. This is probably the engine making assumptions. */
	GAMEINFO_MANIFEST,	/**< Game info was read from a manifest within the path. */
	GAMEINFO_GITXT,		/**< Game info stems from a Source Engine style gameinfo.txt file. */
	GAMEINFO_LIBLIST,	/**< Game info stems from a GoldSrc style liblist.gam file. */
	GAMEINFO_PACKAGE,
} gi_type;

/** Data holding Game Library entries. */
typedef struct
{
	string game;
	string gamedir;
	string base_dir;
	string url_info;
	string url_dl;
	string version;
	string readme;
	int size;
	int svonly;
	int cldll;
	string type;
	string minversion;
	string pkgname;
	string pkgfile;
	int pkgid;
	int nomodels;
	int nosprays;
	int installed;
	string mpentity;
	string gamedll;
	string startmap;
	string trainingmap;
	string fallback_dir;
	string chatroom;
	string menumap;
	string introvideo;
	gi_type info_type;
} gameEntry_t;

#ifndef DOXYGEN
int gameinfo_count;
gameEntry_t *games;
#endif

/** @} */ // end of gamelibrary
