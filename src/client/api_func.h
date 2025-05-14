/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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
	AF_LEFT, /**< Align left */
	AF_TOP,  /**< Align to the top of the field */
	AF_RIGHT,  /**< Align right */
	AF_BOTTOM  /**< Align to the bottom of the field */
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

/** @defgroup clientAPI API: Client-side
    @brief Client-side Game-Logic APIs
    @ingroup multiprogs
    @ingroup client

APIs used by HudC progs and the client progs exclusively.

# HudC {#hudC}

By default, a HudC progs is loaded from `<gamedir>/hud.dat`.

If it is present, it is the chosen default.
If it doesn't exist, Nuclide will not display a Heads-Up-Display.
The game-specific code (non-Nuclide) can also choose to draw
its own HUD by providing implementations of the following functions:

```
void HUD_Init(void);
void HUD_Draw(void);
void HUD_DrawSpectator(void);
void HUD_SendStat(string statName, string statValue);
float HUD_ClientInputFrame(float inputButtons);
bool HUD_ConsoleCommand(string fullCommandString);
void HUD_WeaponSwitched(string weaponName);
```

This will force that HUD, if implemented within the game's `csprogs.dat`.

## Example HudC Progs Code

From `base/src/client/hud.qc`

```
#pragma PROGS_DAT  "../../hud.dat"

#include "../../../src/client/api.h"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;

font_s FONT_HUD;
var string g_ammoPic;

void
HUD_Init(void)
{
	font.Load("fonts/font16.font", FONT_HUD);
	g_ammoPic = 0;
}

void
HUD_Draw(void)
{

	vector hud_mins = screen.HUDMins();
	vector hud_size = screen.HUDSize();
	vector hudSize = hud_size;
	vector iconPos = hud_mins + (hudSize / 2);
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;

	string healthValue = ftos(player.GetHealth());
	string armorValue = ftos(player.GetArmor());
	string ammoValue = ftos(weapon.GetAmmo1());

	if (weapon.AmmoRequired() == true) {
		draw.RText([hudSize[0] - baseIconPadding - baseIconSize - baseIconPadding, iconPos[1]], ammoValue, FONT_HUD);
	}

	if (g_ammoPic != "") {
		draw.Pic([hudSize[0] - baseIconPadding - baseIconSize, iconPos[1]], g_ammoPic, [baseIconSize, baseIconSize], [1,1,1], 1.0f);
	}

	draw.RText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], healthValue, FONT_HUD);
	draw.Pic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f);

	draw.Text(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], armorValue, FONT_HUD);
	draw.Pic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f);
}

void
HUD_WeaponSwitched(string weaponName)
{
	g_ammoPic = entityDef.GetString(weaponName, "ammoIcon");
}
```

As you can see, you'll be primarily using functions from the [drawAPI](@ref drawAPI_t) in order to display text and images on screen. You also can load external font definitions and query the display properties using the [fontAPI](@ref fontAPI_t) and [screenAPI](@ref surfaceAPI_t)

@{
*/

/** Font library */
typedef struct
{
/** @brief Get the internal font id.

The internal font id is only useful for when you want to assign 'drawfont'
yourself, or have some other use for it. Those id's are meant to be unique,
but may change between vid_reload or other cases where video memory is de-allocated.
Overall you should never need to use this, unless you know what you're doing or are
porting old code.

@param fnt is the font to be queried.
@return the internal 'drawfont' id of the specified font. */
	float GetID(font_s fnt);

/** Load a desired .font definition into memory.

@param strFile is the path to the file in question.
@param fntNew is the location of where the font will be stored. */
	void Load(string fontDef,font_s &fntNew);

/** Converts a normalized RGB color vector to a hex color string.

@param normalizedColor is the normalized input color. E.g. [1.0f, 0.0f, 0.0f]
@return is a hex color string. e.g. "^xF00" */
	string RGBtoHex(vector normalizedColor);

/** @brief Returns the height of a specified font in pixels. 
@param fnt is the font to be queried.
@return is the height of a font in pixels.
@sa Font_StringWidth */
	int GetHeight(font_s fnt);

/** @brief Returns the width of a series of characters in pixels.

If you have a string with funstring color codes (e.g. ^1 or ^xF00) and want to make
sure those are not interpreted as visible characters, set the parameter hasColor
to true. Rendering may be more expensive this way, but you should generally cache the
result instead of querying it every frame anyway.

The return value is of type float, to be a drop-in replacement for the engine builtin
stringwidth().

@param inputText is the text to get the length of. 
@param hasColor hints if funstring color codes are present in the string.
@param fnt is the font used with the text in question. */
	float StringWidth(string inputText,bool hasColor,font_s fnt);
} fontAPI_t;
var fontAPI_t font;/**< Access fontAPI_t functions using this variable. */


/** Surface library */
typedef struct
{
	vector Mins(void); /**< Returns the top-left starting position of the surface. You need to use this as you start position for every 2D element you want to display to ensure it's within the bounds of the visible view area. Similarily you want to avoid this when using screen filler effects because they may not cover the whole display. */
	vector Size(void); /**< The size of the surface or display. Elements with positions larger than this may not be visible. For 2D HUD elements, query HUDSize() instead. */
	float Width(void); /**< The width of the surface or display. Equivalent to the [0]/x value of Size()'s return value. */
	float Height(void); /**< The height of the surface or display. Equivalent to the [1]/y value of Size()'s return value. */
	vector HUDMins(void); /**< Returns the top-left starting position of the HUD on the surface. You need to use this as you start position for every 2D element you want to display to ensure it's within the bounds of the visible view area. Similarily you want to avoid this when using screen filler effects because they may not cover the whole display. */
	vector HUDSize(void); /**< Returns the size of the HUD. Since players may be playing with accessibility options or a VR headset - so the HUD gets passed its own canvas so it can be altered in the backend for the above reasons. */
} surfaceAPI_t;
var surfaceAPI_t screen;/**< Access surfaceAPI_t functions using this variable. */

/** Draw library */
typedef struct
{
/** Displays a solid colored rectangle at the specified position with a specified size.

@param rectPos is the position at which the rectangle will be drawn.
@param rectSize is the size at which we draw the rectangle, in pixels.
@param rectRGB  is the color of the rectangle, in normalized RGB values. E.g. `[1.0f, 0.0f, 0.0f]` for red.
@param rectAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Rect(vector rectPos, vector rectSize, vector rectRGB , float rectAlpha);
/** Displays a colored rectangle outline at the specified position with a specified size.

@param rectPos is the position at which the rectangle will be drawn.
@param rectSize is the size at which we draw the rectangle, in pixels.
@param outlineThickness is the thickness of the outline. In pixels.
@param rectRGB  is the color of the rectangle, in normalized RGB values. E.g. `[0.0f, 0.0f, 1.0f]` for blue.
@param rectAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void RectOutline(vector rectPos, vector rectSize, float outlineThickness, vector rectColor, float rectAlpha);

/** Displays a colored rounded box at the specified position with a specified size.

@param boxPos is the position at which the box will be drawn.
@param boxSize is the size at which we draw the box, in pixels.
@param boxColor  is the color of the box, in normalized RGB values. E.g. `[1.0f, 1.0f, 0.0f]` for yellow.
@param boxAlpha is the alpha channel of the box. 0.0 is invisible, 1.0 is fully visible. */
	void RoundedBox(vector boxPos, vector boxSize, vector boxColor, float boxAlpha);

/** Displays a line with a specified thickness and color.

@param lineThickness is the thickness of the line in pixels.
@param startPos is the 'starting' point of the line.
@param endPos  is the second, 'endpoint' of the line.
@param lineColor  is the color of the line, in normalized RGB values. E.g. `[0.0f, 1.0f, 0.0f]` for green.
@param lineAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Line(float lineThickness, vector startPos, vector endPos, vector lineColor, float lineAlpha);
/** Draws an image from either the virtual file-system, or the materials.

@param imagePosis the position at which the pic will be drawn.
@param imageName is the path/name of the image. Can be a material as well. E.g. "gfx/foo.png" or "conback".
@param imageSize  is the size at which we draw the pic, in pixels.
@param imageColor  is the color/tint of the pic, in normalized RGB values. E.g. `[0.5f, 0.5f, 0.5f]` for gray/grey.
@param imageAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Pic(vector imagePos, string imageName, vector imageSize, vector imageColor, float imageAlpha, float imageFlags);
/** Draws part of an image from either the virtual file-system, or the materials.

@param imagePosis the position at which the pic will be drawn.
@param imageName is the path/name of the image. Can be a material as well. E.g. "gfx/foo.png" or "conback".
@param displaySize  is the size at which we draw the pic, in pixels.
@param sourcePos  is the position at which we start cropping from (top-left corner), in normalized values
@param sourceSize  is the normalized 
@param imageColor  is the color/tint of the pic, in normalized RGB values. E.g. `[0.5f, 0.5f, 0.5f]` for gray/grey.
@param imageAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void SubPic(vector imagePos, vector displaySize, string imageName, vector sourcePos, vector sourceSize, vector imageColor, float imageAlpha, float imageFlags);
/** Draw text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param fnt is the font to be used. */
	void Text(vector vecOrigin, string strText, font_s fnt);
/** Draw alpha-blended text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
	void Text_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Draw tinted text on the screen at the desired position with a desired font. 

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param fnt is the font to be used. */
	void Text_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Draw tinted and alpha blended text on the screen at the desired position
with a desired font. 

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
	void Text_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);
/** Right-aligned variant of Text().
@sa Text */
	void RText(vector vecOrigin, string strText, font_s fnt);
/** Right-aligned variant of Text_A().
@sa Font_DrawText_A */
	void RText_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Right-aligned variant of Text_RGB().
@sa Font_DrawText_RGB */
	void RText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Right-aligned variant of Text_RGBA().
@sa Font_DrawText_RGBA */
	void RText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);
/** Draws a textfield with line wrapping.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
	void TextField(vector vecOrigin, vector vecSize, string strText, font_s fnt, alignflags_t iAlignFlags);
/** Draws a textfield with line wrapping at a custom text height.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param iTextHeight is the desired text height in pixels.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
	void TextFieldAtHeight(vector vecOrigin, vector vecSize, int iTextHeight, string strText, font_s fnt, alignflags_t iAlignFlags);
} drawAPI_t;
var drawAPI_t draw;/**< Access drawAPI_t functions using this variable. */

/** Player library */
typedef struct
{

/** Get the current 3D viewport's camera position.

@return the absolute world-space coordinate of the camera. */
	vector GetCameraPosition(void);
/** Get the current 3D viewport's camera angle.

@return the direction the camera is facing in euler-angle form. */
	vector GetCameraAngles(void);
/** Get the current player's armor value.

@return the current armor value. */
	float GetArmor(void);
/** Get the current player's health value.

@return the current health value. */
	float GetHealth(void);
/** Get the current player's stamina value. 

@return the current stamina value, ranging from 0.0f to 1.0f. */
	float GetStamina(void);
/** Get the current player's team ID.

@return the current player's team ID. */
	int GetTeam(void);
/** Check if the current player is standing upright. As in, not ducking, prone.
They may still be walking or running.

@return whether the current player is standing upright. */
	bool IsStanding(void);
/** Check if the current player is leaning in any direction.

@return whether the current player is leaning. */
	bool IsLeaning(void);
/** Check if the current player is actively sprinting.

@return whether the current player is sprinting. */
	bool IsSprinting(void);
/** Check if the current player is actively crouched/ducked.

@return whether the current player is crouched. */
	bool IsCrouched(void);
/** Check if the current player is actively prone/laying flat on the ground.

@return whether the current player is prone. */
	bool IsProne(void);
/** Check if the current player is actively moving.

@return whether the current player is moving. */
	bool IsMoving(void);
/** Check if the current player is not on ground.

@return whether the current player is falling. */
	bool IsFalling(void);
/** Check if the current player has a particular item.

@param itemClassName the classname of the item. E.g. "item_suit"
@return whether the named item exists in the current player's inventory.*/
	bool HasItem(string itemClassName);
} playerAPI_t;
var playerAPI_t player; /**< Access playerAPI_t functions using this variable. */

/** Weapon library */
typedef struct
{

/** Returns whether this entity reference to a weapon is still valid.

@param weaponRef is the weapon entity to reference
@return whether the weapon entity reference is valid to the current player.*/
	bool IsValid(entity weaponRef);
/** Returns the title of the weapon specified.

@param weaponRef is the weapon entity to reference
@return string value containing a localized weapon name.*/
	string GetTitle(entity weaponRef);
/** Returns the slot number of the weapon specified.

@param weaponRef is the weapon entity to reference
@return integer value containing the inventory slot the weapon is in. */
	int GetSlot(entity weaponRef);
/** Returns if the slot position of the weapon specified.

@param weaponRef is the weapon entity to reference
@return integer value containing the position within an inventory slot that the weapon is in. */
	int GetSlotPos(entity weaponRef);
/** Returns the inventory icons of the weapon specified.

@param weaponRef is the weapon entity to reference
@return string value containing the material/image of the weapon inventory icon.*/
	string GetIcon(entity weaponRef);
/** Returns the selected variant inventory icons of the weapon specified.

@param weaponRef is the weapon entity to reference
@return string value containing the material/image of the selected weapon inventory icon.*/
	string GetSelectedIcon(entity weaponRef);
/** Returns if the current/active weapons present reserve ammo.

@return integer value of the present reserve ammo.*/
	int GetAmmo1(void);
/** Returns if the current/active weapons present reserve ammo, but for the second ammo type.

@return integer value of the present reserve ammo.*/
	int GetAmmo2(void);
/** Returns if the current/active weapons present clip/magazine size.

@return integer value of the present clip/magazine size.*/
	int GetClip(void);
/** Returns if the current/active weapons maximum clip/magazine size.

@return integer value of the maximum clip/magazine size.*/
	int GetClipSize(void);
/** Returns if the maximum reserve ammo.

@return integer value of the maximum ammo size.*/
	int MaxAmmo(void);
/** Returns if the current/active weapon item in the player's inventory makes use of a secondary ammo type.

@return **true** when it supports a second ammo type.*/
	bool UsesSecondaryAmmo(void);
/** Returns if the current/active weapon item in the player's inventory requires ammo.

@return **true** when it requires ammo.*/
	bool AmmoRequired(void);

/** Returns the current/active weapon item in the player's inventory.

@return the active weapon in the player's inventory. __NULL__ if invalid.*/
	entity GetActiveWeapon(void);
/** Returns the first weapon item in the player's inventory.

@return the first weapon in the player's inventory. __NULL__ if invalid.*/
	entity GetFirstWeaponInInventory(void);
/** Returns the last weapon item in the player's inventory.

@return the last weapon in the player's inventory. __NULL__ if invalid.*/
	entity GetLastWeaponInInventory(void);

/** Returns the weapon that comes after (in the player's inventory) the input weapon.

@param playerWeapon the weapon entity of the player.
@return the weapon after playerWeapon in the player's inventory. __NULL__ if invalid.*/
	entity GetNextWeaponRelativeTo(entity);

/** Returns the weapon that comes before (in the player's inventory) the input weapon.

@param playerWeapon the weapon entity of the player.
@return the weapon before playerWeapon in the player's inventory. __NULL__ if invalid.*/
	entity GetPreviousWeaponRelativeTo(entity playerWeapon);

/** Attempts to make the player switch to the specified weapon reference.

@param weaponRef is the weapon entity to switch to. */
	void SelectWeapon(entity);
} weaponAPI_t;
var weaponAPI_t weapon; /**< Access weaponAPI_t functions using this variable. */


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
	screen.Size = linkToClientProgs("Surface_ScreenSize");
	screen.Mins = linkToClientProgs("Surface_ScreenMins");
	screen.HUDMins = linkToClientProgs("Surface_HUDMins");
	screen.HUDSize = linkToClientProgs("Surface_HUDSize");

	player.GetCameraPosition = linkToClientProgs("Player_GetCameraPosition");
	player.GetCameraAngles = linkToClientProgs("Player_GetCameraAngles");
	player.GetHealth = linkToClientProgs("Player_GetHealth");
	player.GetArmor = linkToClientProgs("Player_GetArmor");
	player.GetStamina = linkToClientProgs("Player_GetStamina");
	player.GetTeam = linkToClientProgs("Player_GetTeam");
	player.HasItem = linkToClientProgs("Player_HasItem");
	player.IsStanding = linkToClientProgs("Player_IsStanding");
	player.IsLeaning = linkToClientProgs("Player_IsLeaning");
	player.IsSprinting = linkToClientProgs("Player_IsSprinting");
	player.IsCrouched = linkToClientProgs("Player_IsCrouching");
	player.IsProne = linkToClientProgs("Player_IsProne");
	player.IsMoving = linkToClientProgs("Player_IsMoving");
	player.IsFalling = linkToClientProgs("Player_IsFalling");

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
	weapon.MaxAmmo = linkToClientProgs("Weapon_MaxAmmo");
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
	draw.SubPic = linkToClientProgs("Draw_SubPic");
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
