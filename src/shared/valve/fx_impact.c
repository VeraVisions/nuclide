/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

var float DECAL_SHOT;
var float DECAL_GLASS;
var float PARTICLE_PIECES_BLACK;
var float PARTICLE_SMOKE_BROWN;
var float PARTICLE_SMOKE_GREY;

void
FX_Impact_Init(void)
{
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/ric4.wav");
	precache_sound("weapons/ric5.wav");

	DECAL_SHOT = particleeffectnum("decal_shot");
	DECAL_GLASS = particleeffectnum("decal_glass");
	PARTICLE_PIECES_BLACK = particleeffectnum("part_pieces_black");
	PARTICLE_SMOKE_GREY = particleeffectnum("part_smoke_grey");
	PARTICLE_SMOKE_BROWN = particleeffectnum("part_smoke_brown");
}

void
FX_Impact(int iType, vector vecPos, vector vNormal)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_IMPACT);
	WriteByte(MSG_MULTICAST, (float)iType);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	WriteCoord(MSG_MULTICAST, vNormal[0]); 
	WriteCoord(MSG_MULTICAST, vNormal[1]); 
	WriteCoord(MSG_MULTICAST, vNormal[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	/* decals */
	switch (iType) {
	case IMPACT_GLASS:
		Decals_Place(vecPos, sprintf("{break%d", floor(random(1,4))));
		break;
	case IMPACT_MELEE:
		Decals_Place(vecPos, sprintf("{shot%d", floor(random(1,6))));
		break;
	default:
		Decals_Place(vecPos, sprintf("{bigshot%d", floor(random(1,6))));
		break;
	}

	switch (iType) {
		case IMPACT_EXPLOSION:
			break;
		case IMPACT_GLASS:
			pointparticles(PARTICLE_PIECES_BLACK, vecPos, vNormal, 1);
			break;
		case IMPACT_WOOD:
			FX_Spark(vecPos, vNormal);
			pointparticles(PARTICLE_PIECES_BLACK, vecPos, vNormal, 1);
			pointparticles(PARTICLE_SMOKE_BROWN, vecPos, vNormal, 1);
			break;
		case IMPACT_METAL:
			FX_Spark(vecPos, vNormal);
			pointparticles(PARTICLE_PIECES_BLACK, vecPos, vNormal, 1);
			break;
		case IMPACT_FLESH:
			FX_Blood(vecPos, vNormal);
			break;
		case IMPACT_DEFAULT:
			FX_Spark(vecPos, vNormal);
			pointparticles(PARTICLE_PIECES_BLACK, vecPos, vNormal, 1);
			pointparticles(PARTICLE_SMOKE_GREY, vecPos, vNormal, 1);
			break;
		default:
	}

	switch (iType) {
		case IMPACT_FLESH:
			break;
		default:
			pointsound(vecPos, sprintf("weapons/ric%d.wav", floor((random() * 5) + 1)), 1, ATTN_STATIC);
			break;
	}
#endif
} 
