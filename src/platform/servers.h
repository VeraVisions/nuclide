/** Options for querying Game Library entry information using `GameLibrary_GetInfo()` */
typedef enum
{
	SERVERGAME_TITLE,		/**< (string) The title of the game. E.g. "Action Game" */
	SERVERGAME_ADDRESS,		/**< (string) The game directory name. E.g. "data" */
	SERVERGAME_PING,		/**< (int) The directory to be loaded before the game directory. */
	SERVERGAME_PLAYERS,		/**< (int) The first game directory to be loaded. */
	SERVERGAME_MAXPLAYERS,	/**< (int) The game its official website. */
	SERVERGAME_MAP,			/**< (string) Version number string. */
	SERVERGAME_GAME,		/**< (string) The size of the game, in bytes. */
} serverGame_t;


/** Retrieves fields for a given game. See gameInfo_t for a list of fields you can query. */
__variant Servers_GetInfo(int, serverGame_t);
