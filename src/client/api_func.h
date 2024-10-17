/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/** Flags for 2D drawing operations. */
typedef enum
{
	DRAWFLAG_NORMAL = 0, /**< The default. */
	DRAWFLAG_ADDITIVE, /**< Render with an additive blend mode. */
	DRAWFLAG_MODULATE, /**< Not implemented in FTEQW. */
	DRAWFLAG_2XMODULATE /**< Not implemented in FTEQW. */
} drawflag_t;

/** Defines the valid alignment flags for text fields.
@sa Font_DrawField */
typedef enumflags
{
	AF_LEFT,
	AF_TOP,
	AF_RIGHT,
	AF_BOTTOM
} alignflags_t;
#define AF_NONE 0

/** Representation of a font. */
typedef struct
{
	int iID;	/**< Internal ID, will be passed to 'drawfont' before rendering text. */
	int iScaleX; /**< Suggested maximum width of a character in the font. */
	int iScaleY; /**< Maximum height of a chracter in the font. */
	vector vecColor; /**< Suggested default color of the font. */
	float flAlpha; /**< Suggested default alpha of the font. */
	int iFlags;	/**< Rendering flags that the font posesses. @sa drawflag_t */
	string hexColor;
} font_s;

/** @defgroup hudc HudC
    @brief Client-side Game-Logic API
    @ingroup multiprogs

APIs used by HudC progs and the client progs exclusively.

@{
*/

/* Font library */
typedef struct
{
	float GetID(font_s);
	void Load(string,font_s &);
	string RGBtoHex(vector);
	int GetHeight(font_s);
	float StringWidth(string,bool,font_s);
} fontAPI_t;
var fontAPI_t font;


/* Surface library */
typedef struct
{
	float Width(void);
	float Height(void);
	vector HUDMins(void);
	vector HUDSize(void);
} surfaceAPI_t;
var surfaceAPI_t screen;

/* Surface library */
typedef struct
{
	void Rect(vector, vector, vector, float);
	void RectOutline(vector, vector, float, vector, float);
	void RoundedBox(vector, vector, vector, float);
	void Line(float, vector, vector, vector, float);
	void Pic(vector, string, vector, vector, float);
	void Text(vector,string,font_s);
	void Text_A(vector,string,float,font_s);
	void Text_RGB(vector,string,vector,font_s);
	void Text_RGBA(vector,string,vector,float,font_s);
	void RText(vector,string,font_s);
	void RText_A(vector,string,float,font_s);
	void RText_RGB(vector,string,vector,font_s);
	void RText_RGBA(vector,string,vector,float,font_s);
	void TextField(vector,vector,string,font_s,alignflags_t);
	void TextFieldAtHeight(vector,vector,int,string,font_s,alignflags_t);
} drawAPI_t;
var drawAPI_t draw;

/* Player library */
typedef struct
{
	float GetArmor(void);
	float GetHealth(void);
	float GetStamina(void);
	int GetTeam(void);
	bool IsStanding(void);
	bool IsLeaning(void);
	bool IsSprinting(void);
	bool IsCrouched(void);
	bool IsProne(void);
	bool HasItem(string);
} playerAPI_t;
var playerAPI_t player;

/* Weapon library */
typedef struct
{
	bool IsValid(entity);
	string GetTitle(entity);
	int GetSlot(entity);
	int GetSlotPos(entity);
	string GetIcon(entity);
	string GetSelectedIcon(entity);
	int GetAmmo1(void);
	int GetAmmo2(void);
	int GetClip(void);
	int GetClipSize(void);
	bool UsesSecondaryAmmo(void);
	bool AmmoRequired(void);

	entity GetActiveWeapon(void);
	entity GetFirstWeaponInInventory(void);
	entity GetLastWeaponInInventory(void);

	entity GetNextWeaponRelativeTo(entity);
	entity GetPreviousWeaponRelativeTo(entity);

	void SelectWeapon(entity);
} weaponAPI_t;
var weaponAPI_t weapon;


/** @} */ // end of hudC

/* To be implemented by HUD */
void HUD_Init(void);

__variant
linkToClientProgs(string funcName)
{
	static void empty(void)
	{
		print("Called unimplemented client-side API call.\n");
		breakpoint();
	}

	void *func = externvalue(0, funcName);

	if (func) {
		return ((__variant)func);
	} else {
		return (empty);
	}
}

void
_client_main(void)
{
	font.GetHeight = linkToClientProgs("Font_GetHeight");
	font.GetID = linkToClientProgs("Font_GetID");
	font.Load = linkToClientProgs("Font_Load");
	font.RGBtoHex = linkToClientProgs("Font_RGBtoHex");
	font.StringWidth = linkToClientProgs("Font_StringWidth");

	screen.Width = linkToClientProgs("Surface_ScreenHeight");
	screen.Height = linkToClientProgs("Surface_ScreenHeight");

	screen.HUDMins = linkToClientProgs("Surface_HUDMins");
	screen.HUDSize = linkToClientProgs("Surface_HUDSize");

	player.GetHealth = linkToClientProgs("Player_GetHealth");
	player.GetArmor = linkToClientProgs("Player_GetArmor");
	player.GetStamina = linkToClientProgs("Player_GetStamina");
	player.GetTeam = linkToClientProgs("Player_GetTeam");
	player.HasItem = linkToClientProgs("Player_HasItem");
	player.IsStanding = linkToClientProgs("Player_IsStanding");
	player.IsLeaning = linkToClientProgs("Player_IsLeaning");
	player.IsSprinting = linkToClientProgs("Player_IsSprinting");
	player.IsCrouched = linkToClientProgs("Player_IsCrouched");
	player.IsProne = linkToClientProgs("Player_IsProne");

	weapon.IsValid = linkToClientProgs("Weapon_IsValid");
	weapon.GetTitle = linkToClientProgs("Weapon_GetTitle");
	weapon.GetIcon = linkToClientProgs("Weapon_GetIcon");
	weapon.GetSelectedIcon = linkToClientProgs("Weapon_GetSelectedIcon");
	weapon.GetSlot = linkToClientProgs("Weapon_GetSlot");
	weapon.GetSlotPos = linkToClientProgs("Weapon_GetSlotPos");
	weapon.GetAmmo1 = linkToClientProgs("Weapon_GetAmmo1");
	weapon.GetAmmo2 = linkToClientProgs("Weapon_GetAmmo2");
	weapon.GetClip = linkToClientProgs("Weapon_GetClip");
	weapon.GetClipSize = linkToClientProgs("Weapon_GetClipSize");
	weapon.UsesSecondaryAmmo = linkToClientProgs("Weapon_UsesSecondaryAmmo");
	weapon.AmmoRequired = linkToClientProgs("Weapon_AmmoRequired");
	weapon.GetActiveWeapon = linkToClientProgs("Weapon_GetActiveWeapon");
	weapon.GetFirstWeaponInInventory = linkToClientProgs("Weapon_GetFirstWeaponInInventory");
	weapon.GetLastWeaponInInventory = linkToClientProgs("Weapon_GetLastWeaponInInventory");
	weapon.GetNextWeaponRelativeTo = linkToClientProgs("Weapon_GetNextWeaponRelativeTo");
	weapon.GetPreviousWeaponRelativeTo = linkToClientProgs("Weapon_GetPreviousWeaponRelativeTo");
	weapon.SelectWeapon = linkToClientProgs("Weapon_SelectWeapon");

	draw.Rect = linkToClientProgs("Draw_Rect");
	draw.RectOutline = linkToClientProgs("Draw_RectOutline");
	draw.RoundedBox = linkToClientProgs("Draw_RoundedBox");
	draw.Line = linkToClientProgs("Draw_Line");
	draw.Pic = linkToClientProgs("Draw_Pic");
	draw.TextField = linkToClientProgs("Font_DrawField");
	draw.TextFieldAtHeight = linkToClientProgs("Font_DrawFieldAtHeight");
	draw.RText = linkToClientProgs("Font_DrawRText");
	draw.RText_A = linkToClientProgs("Font_DrawRText_A");
	draw.RText_RGB = linkToClientProgs("Font_DrawRText_RGB");
	draw.RText_RGBA = linkToClientProgs("Font_DrawRText_RGBA");
	draw.Text = linkToClientProgs("Font_DrawText");
	draw.Text_A= linkToClientProgs("Font_DrawText_A");
	draw.Text_RGB= linkToClientProgs("Font_DrawText_RGB");
	draw.Text_RGBA = linkToClientProgs("Font_DrawText_RGBA");
}
