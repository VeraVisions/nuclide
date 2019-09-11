/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

static CUIWindow winChooseTeam;
static CUIWindow winCTTeam;
static CUIWindow winTTeam;

typedef struct {
	string str;
	void() ptr;
} btnarr_t;

void VGUI_TeamJoin(float i)
{
	sendevent("TeamJoin", "f", i);
}

void VGUI_TeamBack(void)
{
	
}

void VGUI_JoinScout_B (void) { VGUI_TeamJoin(1); }
void VGUI_JoinSniper_B (void) { VGUI_TeamJoin(2); }
void VGUI_JoinSoldier_B (void) { VGUI_TeamJoin(3); }
void VGUI_JoinDemoman_B (void) { VGUI_TeamJoin(4); }
void VGUI_JoinMedic_B (void) { VGUI_TeamJoin(5); }
void VGUI_JoinHwguy_B (void) { VGUI_TeamJoin(6); }
void VGUI_JoinPyro_B (void) { VGUI_TeamJoin(7); }
void VGUI_JoinSpy_B (void) { VGUI_TeamJoin(8); }
void VGUI_JoinEngineer_B (void) { VGUI_TeamJoin(9); }

void VGUI_JoinScout_R (void) { VGUI_TeamJoin(11); }
void VGUI_JoinSniper_R (void) { VGUI_TeamJoin(12); }
void VGUI_JoinSoldier_R (void) { VGUI_TeamJoin(13); }
void VGUI_JoinDemoman_R (void) { VGUI_TeamJoin(14); }
void VGUI_JoinMedic_R (void) { VGUI_TeamJoin(15); }
void VGUI_JoinHwguy_R (void) { VGUI_TeamJoin(16); }
void VGUI_JoinPyro_R (void) { VGUI_TeamJoin(17); }
void VGUI_JoinSpy_R (void) { VGUI_TeamJoin(18); }
void VGUI_JoinEngineer_R (void) { VGUI_TeamJoin(19); }

void VGUI_JoinScout_Y (void) { VGUI_TeamJoin(21); }
void VGUI_JoinSniper_Y (void) { VGUI_TeamJoin(22); }
void VGUI_JoinSoldier_Y (void) { VGUI_TeamJoin(23); }
void VGUI_JoinDemoman_Y (void) { VGUI_TeamJoin(24); }
void VGUI_JoinMedic_Y (void) { VGUI_TeamJoin(25); }
void VGUI_JoinHwguy_Y (void) { VGUI_TeamJoin(26); }
void VGUI_JoinPyro_Y (void) { VGUI_TeamJoin(27); }
void VGUI_JoinSpy_Y (void) { VGUI_TeamJoin(28); }
void VGUI_JoinEngineer_Y (void) { VGUI_TeamJoin(29); }

void VGUI_JoinScout_G (void) { VGUI_TeamJoin(31); }
void VGUI_JoinSniper_G (void) { VGUI_TeamJoin(32); }
void VGUI_JoinSoldier_G (void) { VGUI_TeamJoin(33); }
void VGUI_JoinDemoman_G (void) { VGUI_TeamJoin(34); }
void VGUI_JoinMedic_G (void) { VGUI_TeamJoin(35); }
void VGUI_JoinHwguy_G (void) { VGUI_TeamJoin(36); }
void VGUI_JoinPyro_G (void) { VGUI_TeamJoin(37); }
void VGUI_JoinSpy_G (void) { VGUI_TeamJoin(38); }
void VGUI_JoinEngineer_G (void) { VGUI_TeamJoin(39); }

btnarr_t red_team[] = {
	{"SCOUT", VGUI_JoinScout_R },
	{"SNIPER", VGUI_JoinSniper_R },
	{"SOLDIER", VGUI_JoinSoldier_R },
	{"DEMOMAN", VGUI_JoinDemoman_R },
	{"MEDIC", VGUI_JoinMedic_R },
	{"HWGUY", VGUI_JoinHwguy_R },
	{"PYRO", VGUI_JoinPyro_R },
	{"SPY", VGUI_JoinSpy_R },
	{"ENGINEER", VGUI_JoinEngineer_R },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_TeamBack }
};

btnarr_t blue_team[] = {
	{"SCOUT", VGUI_JoinScout_B },
	{"SNIPER", VGUI_JoinSniper_B },
	{"SOLDIER", VGUI_JoinSoldier_B },
	{"DEMOMAN", VGUI_JoinDemoman_B },
	{"MEDIC", VGUI_JoinMedic_B },
	{"HWGUY", VGUI_JoinHwguy_B },
	{"PYRO", VGUI_JoinPyro_B },
	{"SPY", VGUI_JoinSpy_B },
	{"ENGINEER", VGUI_JoinEngineer_B },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_TeamBack }
};

void 
VGUI_GoSpectator(void)
{
	VGUI_TeamJoin(0);
	winChooseTeam.Hide();
}

void VGUI_ChooseTeam_Red(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winCTTeam = spawn( CUIWindow );
		winCTTeam.SetTitle( "Choose Skin" );
		winCTTeam.SetSize( [420,320] );
		g_uiDesktop.Add( winCTTeam );
		
		btns = memalloc(sizeof(btnarr_t) * red_team.length);
		for (int i = 0; i < red_team.length; i++) {
			btnpos[1] += 30;
			if ( red_team[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetTitle( red_team[i].str );
			btns[i].SetPos( btnpos );
			btns[i].SetFunc( red_team[i].ptr );
			winCTTeam.Add( btns[i] );
		}
	}

	winChooseTeam.Hide();
	winCTTeam.Show();
	winCTTeam.SetPos( ( video_res / 2 ) - ( winCTTeam.GetSize() / 2 ) );
}

void VGUI_ChooseTeam_Blue(void)
{
	static int initialized;
	static CUIButton *btns;

	if ( !initialized ) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winTTeam = spawn( CUIWindow );
		winTTeam.SetTitle( "Choose Skin" );
		winTTeam.SetSize( [420,320] );
		g_uiDesktop.Add( winTTeam );

		btns = memalloc(sizeof(btnarr_t) * blue_team.length);
		for (int i = 0; i < blue_team.length; i++) {
			btnpos[1] += 30;
			if ( blue_team[i].ptr == __NULL__ ) {
				continue;
			}
			btns[i] = spawn( CUIButton );
			btns[i].SetTitle( blue_team[i].str );
			btns[i].SetPos( btnpos );
			btns[i].SetFunc( blue_team[i].ptr );
			winTTeam.Add( btns[i] );
		}
	}

	winChooseTeam.Hide();
	winTTeam.Show();
	winTTeam.SetPos( ( video_res / 2 ) - ( winTTeam.GetSize() / 2 ) );
}

void VGUI_ChooseTeam(void)
{
	static int initialized;
	static CUIButton btnGoRed;
	static CUIButton btnGoBlue;
	static CUIButton btnGoSpectator;

	if ( !initialized ) {
		initialized = TRUE;
		winChooseTeam = spawn( CUIWindow );
		winChooseTeam.SetTitle( "Choose Team" );
		winChooseTeam.SetSize( '420 320' );

		btnGoRed = spawn( CUIButton );
		btnGoRed.SetTitle( "Red Team" );
		btnGoRed.SetPos( '8 132' );
		btnGoRed.SetFunc( VGUI_ChooseTeam_Red );

		btnGoBlue = spawn( CUIButton );
		btnGoBlue.SetTitle( "Blue Team" );
		btnGoBlue.SetPos( '8 162' );
		btnGoBlue.SetFunc( VGUI_ChooseTeam_Blue );

		btnGoSpectator = spawn( CUIButton );
		btnGoSpectator.SetTitle( "Spectator" );
		btnGoSpectator.SetPos( '8 192' );
		btnGoSpectator.SetFunc( VGUI_GoSpectator );

		g_uiDesktop.Add( winChooseTeam );
		winChooseTeam.Add( btnGoRed );
		winChooseTeam.Add( btnGoBlue );
		winChooseTeam.Add( btnGoSpectator );
	}

	winChooseTeam.Show();
	winChooseTeam.SetPos( ( video_res / 2 ) - ( winChooseTeam.GetSize() / 2 ) );
}
