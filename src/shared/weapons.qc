#ifdef NEW_INVENTORY
void
Weapons_Init(void)
{

}

string
Weapons_GetWorldmodel(int)
{
	return "";
}

void
Weapons_Draw(NSClientPlayer pl)
{
	if (pl.m_activeweapon)
		pl.m_activeweapon.Draw();
}

void
Weapons_Release(NSClientPlayer pl)
{
	if (pl.m_activeweapon)
		pl.m_activeweapon.Release();
}

void
Weapons_Primary(NSClientPlayer pl)
{
	if (pl.m_activeweapon)
		pl.m_activeweapon.Primary();
}

void
Weapons_Secondary(NSClientPlayer pl)
{
	if (pl.m_activeweapon)
		pl.m_activeweapon.Secondary();
}

void
Weapons_Reload(NSClientPlayer pl)
{
	if (pl.m_activeweapon)
		pl.m_activeweapon.Reload();
}

void
Weapons_PreDraw(NSClientPlayer pl, bool thirdperson)
{
}

void
Weapons_SetGeomset(string foo)
{

}

weapontype_t
Weapons_GetType(NSClientPlayer pl, int w)
{
	if (pl.m_activeweapon)
		return pl.m_activeweapon.GetType();

	return WPNTYPE_INVALID;
}

void
Weapons_UpdateAmmo(NSClientPlayer pl, int a1, int a2, int a3)
{
	/* no change */
	if (a1 == -1)
		a1 = pl.a_ammo1;
	if (a2 == -1)
		a2 = pl.a_ammo2;
	if (a3 == -1)
		a3 = pl.a_ammo3;

	/* networked as bytes, since we don't need more. Clamp to avoid errors */
	pl.a_ammo1 = a1;
	pl.a_ammo2 = a2;
	pl.a_ammo3 = a3;
}

void Weapons_PickupNotify(NSClientPlayer pl, int w) {}
void Weapons_RefreshAmmo(NSClientPlayer pl) {}
void Weapons_SwitchBest(NSClientPlayer pl, optional float skip) {}
int Weapons_AddItem(NSClientPlayer pl, int w, int startammo) {}
void Weapons_RemoveItem(NSClientPlayer pl, int w) {}
void Weapons_InitItem(int w) {}
void Weapons_ReloadWeapon(NSClientPlayer pl, .int mag, .int ammo, int max) {}
void Weapon_DropCurrentWeapon(NSClientPlayer pl) {}
int Weapon_GetCount() {}
int Weapon_GetBitID(int) {}
int Weapons_IsEmpty(NSClientPlayer, int) {}
#endif