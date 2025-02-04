/** Options for querying Game Library entry information using `Servers_GetInfo()` */
typedef enum
{
	SERVERGAME_TITLE,		/**< (string) The title of the server. E.g. "Action Game" */
	SERVERGAME_ADDRESS,		/**< (string) The address. E.g. "128.0.0.1" */
	SERVERGAME_PING,		/**< (int) Last ping value to the server. */
	SERVERGAME_PLAYERS,		/**< (int) Player count. */
	SERVERGAME_MAXPLAYERS,	/**< (int) Player slots. */
	SERVERGAME_MAP,			/**< (string) Current map/level file. */
	SERVERGAME_GAME,		/**< (string) Game directory. */
} serverGame_t;


/** Retrieves fields for a given server. See serverGame_t for a list of fields you can query. */
__variant Servers_GetInfo(int, serverGame_t);
