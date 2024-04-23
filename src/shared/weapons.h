

#ifdef NEW_INVENTORY

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


#ifdef CLIENT

void
Weapons_SwitchBest(NSClientPlayer pl, optional float skip)
{

}
#endif


var int g_weapon_weights[32];