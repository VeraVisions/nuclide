/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

static CUIWindow winBuyMenu;
static CUIWindow winBuyHandgun;
static CUIWindow winBuyShotgun;
static CUIWindow winBuySMG;
static CUIWindow winBuyRifle;
static CUIWindow winBuyMG;
static CUIWindow winBuyEquipment;

typedef struct {
	string str;
	void() ptr;
} btnarr_t;

void VGUI_Back1 (void) { winBuyHandgun.Hide(); winBuyMenu.Show(); }
void VGUI_Back2 (void) { winBuyShotgun.Hide(); winBuyMenu.Show(); }
void VGUI_Back3 (void) { winBuySMG.Hide(); winBuyMenu.Show(); }
void VGUI_Back4 (void) { winBuyRifle.Hide(); winBuyMenu.Show(); }
void VGUI_Back5 (void) { winBuyMG.Hide(); winBuyMenu.Show(); }
void VGUI_Back6 (void) { winBuyEquipment.Hide(); winBuyMenu.Show(); }

void VGUI_BuyAmmo1 (void) { sendevent("GamePlayerBuyAmmo", "f", 0); }
void VGUI_BuyAmmo2 (void) { sendevent("GamePlayerBuyAmmo", "f", 1); }

void VGUI_BuyHandguns_1 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_USP45); }
void VGUI_BuyHandguns_2 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_GLOCK18); }
void VGUI_BuyHandguns_3 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_DEAGLE); }
void VGUI_BuyHandguns_4 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_P228); }
void VGUI_BuyHandguns_5 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_ELITES); }
void VGUI_BuyHandguns_6 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_FIVESEVEN); }

btnarr_t buy_handguns_t[] = {
	{"USP", VGUI_BuyHandguns_1 },
	{"Glock 18", VGUI_BuyHandguns_2 },
	{"Desert Eagle", VGUI_BuyHandguns_3 },
	{"P228", VGUI_BuyHandguns_4 },
	{"Dual Elites", VGUI_BuyHandguns_5 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back1 }
};

btnarr_t buy_handguns_ct[] = {
	{"USP", VGUI_BuyHandguns_1 },
	{"Glock 18", VGUI_BuyHandguns_2 },
	{"Desert Eagle", VGUI_BuyHandguns_3 },
	{"P228", VGUI_BuyHandguns_4 },
	{"Fiveseven", VGUI_BuyHandguns_6 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back1 }
};

void VGUI_BuyHandgun(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winBuyHandgun = spawn( CUIWindow );
		winBuyHandgun.SetTitle( "Buy Handguns" );
		winBuyHandgun.SetIcon( "gfx/vgui/buymenu" );
		winBuyHandgun.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyHandgun );
		
		btns = memalloc(sizeof(btnarr_t) * buy_handguns_t.length);
		for (int i = 0; i < buy_handguns_t.length; i++) {
			btnpos[1] += 30;
			if ( buy_handguns_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetPos( btnpos );
			winBuyHandgun.Add( btns[i] );
		}
	}

	if (stof(getplayerkeyvalue(player_localnum, "*team")) ==  TEAM_T) {
		for (int i = 0; i < buy_handguns_t.length; i++) {
			if ( buy_handguns_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_handguns_t[i].str );
			btns[i].SetFunc( buy_handguns_t[i].ptr );
		}
	} else {
		for (int i = 0; i < buy_handguns_ct.length; i++) {
			if ( buy_handguns_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_handguns_ct[i].str );
			btns[i].SetFunc( buy_handguns_ct[i].ptr );
		}
	}

	winBuyMenu.Hide();
	winBuyHandgun.Show();
	winBuyHandgun.SetPos( ( video_res / 2 ) - ( winBuyHandgun.GetSize() / 2 ) );
}

void VGUI_BuyShotgun_1 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_M3); }
void VGUI_BuyShotgun_2 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_XM1014); }

btnarr_t buy_shotgun[] = {
	{"M3", VGUI_BuyShotgun_1 },
	{"XM1014", VGUI_BuyShotgun_2 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back2 }
};

void VGUI_BuyShotgun(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winBuyShotgun = spawn( CUIWindow );
		winBuyShotgun.SetTitle( "Buy Shotguns" );
		winBuyShotgun.SetIcon( "gfx/vgui/buymenu" );
		winBuyShotgun.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyShotgun );
		
		btns = memalloc(sizeof(btnarr_t) * buy_shotgun.length);
		for (int i = 0; i < buy_shotgun.length; i++) {
			btnpos[1] += 30;
			if ( buy_shotgun[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetTitle( buy_shotgun[i].str );
			btns[i].SetPos( btnpos );
			btns[i].SetFunc( buy_shotgun[i].ptr );
			winBuyShotgun.Add( btns[i] );
		}
	}

	winBuyMenu.Hide();
	winBuyShotgun.Show();
	winBuyShotgun.SetPos( ( video_res / 2 ) - ( winBuyShotgun.GetSize() / 2 ) );
}

void VGUI_BuySMG_1 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_MP5); }
void VGUI_BuySMG_2 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_P90); }
void VGUI_BuySMG_3 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_UMP45); }
void VGUI_BuySMG_4 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_MAC10); }
void VGUI_BuySMG_5 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_TMP); }

btnarr_t buy_smg_t[] = {
	{"MP5", VGUI_BuySMG_1 },
	{"P90", VGUI_BuySMG_2 },
	{"UMP45", VGUI_BuySMG_3 },
	{"MAC10", VGUI_BuySMG_4 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back3 }
};

btnarr_t buy_smg_ct[] = {
	{"MP5", VGUI_BuySMG_1 },
	{"P90", VGUI_BuySMG_2 },
	{"UMP45", VGUI_BuySMG_3 },
	{"TMP", VGUI_BuySMG_5 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back3 }
};

void VGUI_BuySMG(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winBuySMG = spawn( CUIWindow );
		winBuySMG.SetTitle( "Buy SMGs" );
		winBuySMG.SetIcon( "gfx/vgui/buymenu" );
		winBuySMG.SetSize( [420,320] );
		g_uiDesktop.Add( winBuySMG );
		
		btns = memalloc(sizeof(btnarr_t) * buy_smg_t.length);
		for (int i = 0; i < buy_smg_t.length; i++) {
			btnpos[1] += 30;
			if ( buy_smg_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetPos( btnpos );
			winBuySMG.Add( btns[i] );
		}
	}

	if (stof(getplayerkeyvalue(player_localnum, "*team")) ==  TEAM_T) {
		for (int i = 0; i < buy_smg_t.length; i++) {
			if ( buy_smg_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_smg_t[i].str );
			btns[i].SetFunc( buy_smg_t[i].ptr );
		}
	} else {
		for (int i = 0; i < buy_smg_ct.length; i++) {
			if ( buy_smg_ct[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_smg_ct[i].str );
			btns[i].SetFunc( buy_smg_ct[i].ptr );
		}
	}

	winBuyMenu.Hide();
	winBuySMG.Show();
	winBuySMG.SetPos( ( video_res / 2 ) - ( winBuySMG.GetSize() / 2 ) );
}

void VGUI_BuyRifle_1 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_AK47); }
void VGUI_BuyRifle_2 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_SG552); }
void VGUI_BuyRifle_3 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_SCOUT); }
void VGUI_BuyRifle_4 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_AWP); }
void VGUI_BuyRifle_5 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_G3SG1); }
void VGUI_BuyRifle_6 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_M4A1); }
void VGUI_BuyRifle_7 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_AUG); }
void VGUI_BuyRifle_8 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_SG550); }

btnarr_t buy_rifle_t[] = {
	{"AK47", VGUI_BuyRifle_1 },
	{"SG552", VGUI_BuyRifle_2 },
	{"SCOUT", VGUI_BuyRifle_3 },
	{"AWP", VGUI_BuyRifle_4 },
	{"G3SG1", VGUI_BuyRifle_5 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back4 }
};
btnarr_t buy_rifle_ct[] = {
	{"M4A1", VGUI_BuyRifle_6 },
	{"AUG", VGUI_BuyRifle_7 },
	{"SCOUT", VGUI_BuyRifle_3 },
	{"AWP", VGUI_BuyRifle_4 },
	{"SG550", VGUI_BuyRifle_8 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back4 }
};

void VGUI_BuyRifle(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winBuyRifle = spawn( CUIWindow );
		winBuyRifle.SetTitle( "Buy Rifles" );
		winBuyRifle.SetIcon( "gfx/vgui/buymenu" );
		winBuyRifle.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyRifle );

		/* Dangerous if rifle_t and ct were different */
		btns = memalloc(sizeof(btnarr_t) * buy_rifle_t.length);
		for (int i = 0; i < buy_rifle_t.length; i++) {
			btnpos[1] += 30;
			if ( buy_rifle_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetPos( btnpos );
			winBuyRifle.Add( btns[i] );
		}
	}

	if (stof(getplayerkeyvalue(player_localnum, "*team")) == TEAM_T) {
		for (int i = 0; i < buy_rifle_t.length; i++) {
			if ( buy_rifle_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_rifle_t[i].str );
			btns[i].SetFunc( buy_rifle_t[i].ptr );
		}
	} else {
		for (int i = 0; i < buy_rifle_ct.length; i++) {
			if ( buy_rifle_t[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i].SetTitle( buy_rifle_ct[i].str );
			btns[i].SetFunc( buy_rifle_ct[i].ptr );
		}
	}

	winBuyMenu.Hide();
	winBuyRifle.Show();
	winBuyRifle.SetPos( ( video_res / 2 ) - ( winBuyRifle.GetSize() / 2 ) );
}

void VGUI_BuyMG_1 (void) { sendevent("PlayerBuyWeapon", "f", WEAPON_PARA); }

void VGUI_BuyMG(void)
{
	static int initialized;
	static CUIButton btnPara;
	static CUIButton btnBack;

	if ( !initialized ) {
		initialized = TRUE;
		winBuyMG = spawn( CUIWindow );
		winBuyMG.SetTitle( "Buy Machineguns" );
		winBuyMG.SetIcon( "gfx/vgui/buymenu" );
		winBuyMG.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyMG );

		/* Lonely bugger */
		btnPara = spawn( CUIButton );
		btnPara.SetTitle( "PARA" );
		btnPara.SetPos( [16,32] );
		btnPara.SetFunc( VGUI_BuyMG_1 );
		winBuyMG.Add( btnPara );

		/* Lonely bugger */
		btnBack = spawn( CUIButton );
		btnBack.SetTitle( "< Back" );
		btnBack.SetPos( [16,60] );
		btnBack.SetFunc( VGUI_Back5 );
		winBuyMG.Add( btnBack );
		
	}

	winBuyMenu.Hide();
	winBuyMG.Show();
	winBuyMG.SetPos( ( video_res / 2 ) - ( winBuyMG.GetSize() / 2 ) );
}

void VGUI_BuyEquipment_1 (void) { sendevent("PlayerBuyEquipment", "f", EQUIPMENT_KEVLAR); }
void VGUI_BuyEquipment_2 (void) { sendevent("PlayerBuyEquipment", "f", EQUIPMENT_HELMET); }
void VGUI_BuyEquipment_3 (void) { sendevent("PlayerBuyEquipment", "f", 3); }
void VGUI_BuyEquipment_4 (void) { sendevent("PlayerBuyEquipment", "f", 4); }
void VGUI_BuyEquipment_5 (void) { sendevent("PlayerBuyEquipment", "f", 5); }
void VGUI_BuyEquipment_6 (void) { sendevent("PlayerBuyEquipment", "f", EQUIPMENT_DEFUSALKIT); }
void VGUI_BuyEquipment_7 (void) { sendevent("PlayerBuyEquipment", "f", EQUIPMENT_NIGHTVISION); }

btnarr_t buy_equipment[] = {
	{"Kevlar", VGUI_BuyEquipment_1 },
	{"Kevlar & Helmet", VGUI_BuyEquipment_2 },
	{"Flashbang Grenade", VGUI_BuyEquipment_3 },
	{"HE Grenade", VGUI_BuyEquipment_4 },
	{"Smoke Grenade", VGUI_BuyEquipment_5 },
	{"Defusal Kit", VGUI_BuyEquipment_6 },
	{"Night Visions", VGUI_BuyEquipment_7 },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_Back6 }
};

void VGUI_BuyEquipment(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winBuyEquipment = spawn( CUIWindow );
		winBuyEquipment.SetTitle( "Buy Equipment" );
		winBuyEquipment.SetIcon( "gfx/vgui/buymenu" );
		winBuyEquipment.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyEquipment );

		btns = memalloc(sizeof(btnarr_t) * buy_equipment.length);
		for (int i = 0; i < buy_equipment.length; i++) {
			btnpos[1] += 30;
			if ( buy_equipment[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetTitle( buy_equipment[i].str );
			btns[i].SetPos( btnpos );
			btns[i].SetFunc( buy_equipment[i].ptr );
			winBuyEquipment.Add( btns[i] );
		}
	}

	winBuyMenu.Hide();
	winBuyEquipment.Show();
	winBuyEquipment.SetPos( ( video_res / 2 ) - ( winBuyEquipment.GetSize() / 2 ) );
}

btnarr_t buy_main[] = {
	{"Handguns", VGUI_BuyHandgun },
	{"Shotguns", VGUI_BuyShotgun },
	{"Sub-Machine-Guns", VGUI_BuySMG },
	{"Rifles", VGUI_BuyRifle },
	{"Machineguns", VGUI_BuyMG },
	{"Primary Ammo", VGUI_BuyAmmo1 },
	{"Secondary Ammo", VGUI_BuyAmmo2 },
	{"Equipment", VGUI_BuyEquipment }
};

void VGUI_BuyMenu(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,30];
		initialized = TRUE;
		winBuyMenu = spawn( CUIWindow );
		winBuyMenu.SetTitle( "Buy Menu" );
		winBuyMenu.SetIcon( "gfx/vgui/buymenu" );
		winBuyMenu.SetSize( [420,320] );
		g_uiDesktop.Add( winBuyMenu );
		
		btns = memalloc(sizeof(btnarr_t) * buy_main.length);
		for (int i = 0; i < buy_main.length; i++) {
			btns[i] = spawn( CUIButton );
			btns[i].SetTitle( buy_main[i].str );
			btns[i].SetPos( btnpos );
			btns[i].SetFunc( buy_main[i].ptr );
			winBuyMenu.Add( btns[i] );
			btnpos[1] += 30;
		}
	}

	winBuyMenu.Show();
	winBuyMenu.SetPos( ( video_res / 2 ) - ( winBuyMenu.GetSize() / 2 ) );
}
