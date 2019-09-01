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

/*
=================
Client_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void Client_Init(float apilevel, string enginename, float engineversion)
{
	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud4.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640hud6.spr");
}

void Client_InitDone(void)
{
}

void Game_RendererRestarted(string rstr)
{
	
}

/*
#ifdef REWOLF
				case "decore_asteroid":
					eEnt = spawn(decore_asteroid);
					iClass = TRUE;
					break;
				case "decore_baboon":
					eEnt = spawn(decore_baboon);
					iClass = TRUE;
					break;
				case "decore_bodygib":
					eEnt = spawn(decore_bodygib);
					iClass = TRUE;
					break;
				case "decore_butterflyflock":
					eEnt = spawn(decore_butterflyflock);
					iClass = TRUE;
					break;
				case "decore_explodable":
					eEnt = spawn(decore_explodable);
					iClass = TRUE;
					break;
				case "decore_foot":
					eEnt = spawn(decore_foot);
					iClass = TRUE;
					break;
				case "decore_goldskull":
					eEnt = spawn(decore_goldskull);
					iClass = TRUE;
					break;
				case "decore_hatgib":
					eEnt = spawn(decore_hatgib);
					iClass = TRUE;
					break;
				case "decore_nest":
					eEnt = spawn(decore_nest);
					iClass = TRUE;
					break;
				case "decore_pteradon":
					eEnt = spawn(decore_pteradon);
					iClass = TRUE;
					break;
				case "decore_torch":
					eEnt = spawn(decore_torch);
					iClass = TRUE;
					break;
				case "decore_spacedebris":
					eEnt = spawn(decore_spacedebris);
					iClass = TRUE;
					break;
				case "decore_swampplants":
					eEnt = spawn(decore_swampplants);
					iClass = TRUE;
					break;
				case "decore_mushroom":
					eEnt = spawn(decore_mushroom);
					iClass = TRUE;
					break;
				case "decore_mushroom2":
					eEnt = spawn(decore_mushroom2);
					iClass = TRUE;
					break;
				#endif
				default:
					eEnt.classname = strValue;
				}
				break;
*/
