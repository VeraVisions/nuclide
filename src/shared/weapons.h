#ifdef NEW_INVENTORY
/* for AI identification purposes */
typedef enum
{
	WPNTYPE_INVALID,	/* no logic */
	WPNTYPE_RANGED,		/* will want to keep their distance mostly */
	WPNTYPE_THROW,		/* has to keep some distance, but not too far */
	WPNTYPE_CLOSE,		/* have to get really close */
	WPNTYPE_FULLAUTO,	/* for things that need to be held down */
	WPNTYPE_SEMI		/* semi automatic */
} weapontype_t;

void Weapons_Draw(NSClientPlayer);
void Weapons_Release(NSClientPlayer);
void Weapons_Primary(NSClientPlayer);
void Weapons_Secondary(NSClientPlayer);
void Weapons_Reload(NSClientPlayer);
void Weapons_PreDraw(NSClientPlayer, bool);
void Weapons_Init(void);
string Weapons_GetWorldmodel(int);
weapontype_t Weapons_GetType(NSClientPlayer, int);
int Weapons_IsEmpty(NSClientPlayer, int);
void Weapons_UpdateAmmo(NSClientPlayer, int, int, int);

#ifdef CLIENT
void Weapons_SetGeomset(string);
#endif
#endif