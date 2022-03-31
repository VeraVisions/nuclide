typedef struct
{
	string m_strMessage;
	float m_flPosX;
	float m_flPosY;
	int m_iEffect;
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flFadeIn;
	float m_flFadeOut;
	float m_flHoldTime;
	float m_flFXTime;
	float m_flTime;
} gametext_t;
gametext_t g_textchannels[6];