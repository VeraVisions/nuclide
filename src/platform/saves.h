 
typedef struct
{
	string m_strName;
	string m_strPic;
} savegame_t;
var savegame_t *g_savegames;
var int g_savegame_count;

/** Options querying Map Library entries using `MapLibrary_GetInfo()`. */
typedef enum
{
	SAVEINFO_NAME,		/**< (string) Name of the save. E.g. quick */
	SAVEINFO_PREVIEW	/**< (string) URL to a preview of the save. __NULL__ if not available.*/
} saveInfo_t;

/** Returns the total amount of savegames available. */
int Saves_GetSaveCount(void);

/** Retrieve information about a given saveID. See saveInfo_t for which fields you can query. */
__variant Saves_GetInfo(int, saveInfo_t);

void Saves_Init(void);
