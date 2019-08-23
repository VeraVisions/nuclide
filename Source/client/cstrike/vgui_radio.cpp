
static CUIWindow winRadio1;
static CUIWindow winRadio2;
static CUIWindow winRadio3;

typedef struct {
	int id;
	void() func;
} radiomsg_t;

void rad_cmd_1(void) { sendevent("RadioMessage", "f", RADIO_CT_COVERME); winRadio1.Hide(); } 
void rad_cmd_2(void) { sendevent("RadioMessage", "f", RADIO_CT_POINT); winRadio1.Hide(); }
void rad_cmd_3(void) { sendevent("RadioMessage", "f", RADIO_POSITION); winRadio1.Hide(); }
void rad_cmd_4(void) { sendevent("RadioMessage", "f", RADIO_REGROUP); winRadio1.Hide(); }
void rad_cmd_5(void) { sendevent("RadioMessage", "f", RADIO_FOLLOWME); winRadio1.Hide(); }
void rad_cmd_6(void) { sendevent("RadioMessage", "f", RADIO_FIREASSIS); winRadio1.Hide(); }

radiomsg_t rad_cmds[] = {
	{ RADIO_CT_COVERME, rad_cmd_1 },
    { RADIO_CT_POINT, rad_cmd_2 },
    { RADIO_POSITION, rad_cmd_3 },
    { RADIO_REGROUP, rad_cmd_4 },
    { RADIO_FOLLOWME, rad_cmd_5 },
    { RADIO_FIREASSIS, rad_cmd_6 }
};
CUIButton *radioCommands;

void rad_group_1(void) { sendevent("RadioMessage", "f", RADIO_GO); winRadio2.Hide(); }
void rad_group_2(void) { sendevent("RadioMessage", "f", RADIO_FALLBACK); winRadio2.Hide(); }
void rad_group_3(void) { sendevent("RadioMessage", "f", RADIO_STICKTOG); winRadio2.Hide(); }
void rad_group_4(void) { sendevent("RadioMessage", "f", RADIO_CT_INPOS); winRadio2.Hide(); }
void rad_group_5(void) { sendevent("RadioMessage", "f", RADIO_STORMFRONT); winRadio2.Hide(); }
void rad_group_6(void) { sendevent("RadioMessage", "f", RADIO_COM_REPORTIN); winRadio2.Hide(); } 

radiomsg_t rad_group[] = {
    { RADIO_GO, rad_group_1 },
    { RADIO_FALLBACK, rad_group_2 },
    { RADIO_STICKTOG, rad_group_3 },
    { RADIO_CT_INPOS, rad_group_4 },
    { RADIO_STORMFRONT, rad_group_5 },
    { RADIO_COM_REPORTIN, rad_group_6 }
};
CUIButton *radioGroup;

void rad_res_1(void) { sendevent("RadioMessage", "f", RADIO_CT_AFFIRM); winRadio3.Hide(); }
void rad_res_2(void) { sendevent("RadioMessage", "f", RADIO_CT_ENEMYS); winRadio3.Hide(); }
void rad_res_3(void) { sendevent("RadioMessage", "f", RADIO_CT_BACKUP); winRadio3.Hide(); }
void rad_res_4(void) { sendevent("RadioMessage", "f", RADIO_CLEAR); winRadio3.Hide(); }
void rad_res_5(void) { sendevent("RadioMessage", "f", RADIO_CT_INPOS); winRadio3.Hide(); }
void rad_res_6(void) { sendevent("RadioMessage", "f", RADIO_CT_REPORTINGIN); winRadio3.Hide(); }
void rad_res_7(void) { sendevent("RadioMessage", "f", RADIO_BLOW); winRadio3.Hide(); }
void rad_res_8(void) { sendevent("RadioMessage", "f", RADIO_NEGATIVE); winRadio3.Hide(); }
void rad_res_9(void) { sendevent("RadioMessage", "f", RADIO_ENEMYDOWN); winRadio3.Hide(); }

radiomsg_t rad_res[] = {
    { RADIO_CT_AFFIRM, rad_res_1 },
    { RADIO_CT_ENEMYS, rad_res_2 },
    { RADIO_CT_BACKUP, rad_res_3 },   
    { RADIO_CLEAR, rad_res_4 },
    { RADIO_CT_INPOS, rad_res_5 },
    { RADIO_CT_REPORTINGIN, rad_res_6 },
    { RADIO_BLOW, rad_res_7 },
    { RADIO_NEGATIVE, rad_res_8 },
    { RADIO_ENEMYDOWN, rad_res_9 }
};
CUIButton *radioResponse;

void VGUI_RadioCommands(void)
{
	static int initialized;

	if (!initialized) {
		vector vecButtonpos = [8,32];
		initialized = TRUE;
		winRadio1 = spawn(CUIWindow);
		winRadio1.SetTitle("Radio Commands");
		winRadio1.SetSize('196 216');
		radioCommands = memalloc(sizeof(CUIButton) * rad_cmds.length);

		for (int i = 0; i < rad_cmds.length; i++) {
			radioCommands[i] = spawn(CUIButton);
			radioCommands[i].SetTitle(sRadioChat[rad_cmds[i].id]);
			radioCommands[i].SetPos(vecButtonpos);
			radioCommands[i].SetFunc(rad_cmds[i].func);
			winRadio1.Add(radioCommands[i]);
			vecButtonpos[1] += 30;
		}
		
		g_uiDesktop.Add(winRadio1);
		winRadio1.SetPos([18, video_res[1] - 296]);
	}

	winRadio1.Show();
}

void VGUI_RadioGroup(void)
{
    static int initialized;

    if (!initialized) {
        vector vecButtonpos = [8,32];
        initialized = TRUE;
        winRadio2 = spawn(CUIWindow);
        winRadio2.SetTitle("Group Commands");
        winRadio2.SetSize('196 216');
        radioGroup = memalloc(sizeof(CUIButton) * rad_group.length);

        for (int i = 0; i < rad_group.length; i++) {
            radioGroup[i] = spawn(CUIButton);
            radioGroup[i].SetTitle(sRadioChat[rad_group[i].id]);
            radioGroup[i].SetPos(vecButtonpos);
            radioGroup[i].SetFunc(rad_group[i].func);
            winRadio2.Add(radioGroup[i]);
            vecButtonpos[1] += 30;
        }

        g_uiDesktop.Add(winRadio2);
    	winRadio2.SetPos([18, video_res[1] - 296]);
	}

    winRadio2.Show();
}

void VGUI_RadioResponse(void)
{
    static int initialized;

    if (!initialized) {
        vector vecButtonpos = [8,32];
        initialized = TRUE;
        winRadio3 = spawn(CUIWindow);
        winRadio3.SetTitle("Radio Responses");
        winRadio3.SetSize('216 306');
        radioResponse = memalloc(sizeof(CUIButton) * rad_res.length);

        for (int i = 0; i < rad_res.length; i++) {
            radioResponse[i] = spawn(CUIButton);
            radioResponse[i].SetTitle(sRadioChat[rad_res[i].id]);
            radioResponse[i].SetPos(vecButtonpos);
            radioResponse[i].SetFunc(rad_res[i].func);
            winRadio3.Add(radioResponse[i]);
            vecButtonpos[1] += 30;
        }

        g_uiDesktop.Add(winRadio3);
    	winRadio3.SetPos([18, video_res[1] - 386]);
	}

    winRadio3.Show();
}
