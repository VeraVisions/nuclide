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

.float waterlevel;
.float watertype;
.float maxspeed;
.vector view_ofs;
int trace_endcontentsi;
.vector basevelocity;
.entity groundentity;

#ifdef SERVER
void PMove_StartFrame(void);
#endif

void PMove_Init(void);
int PMove_Contents(vector org);
float PMove_Gravity(entity ent);
void PMove_Categorize(void);
void PMove_CheckWaterJump(void);
int QPMove_IsStuck(entity eTarget, vector vOffset, vector vecMins, vector vecMaxs);
void PMove_AccelToss(float move_time, float premove);
void PMove_AccelMove(float move_time, float premove);
void PMove_AccelWater(float move_time, float premove);
void PMove_AccelLadder(float move_time, float premove, vector wish_dir, float wish_speed);
void PMove_AccelFriction(float move_time, float premove, vector wish_dir, float wish_speed);
void PMove_AccelGravity(float move_time, float premove, vector wish_dir, float wish_speed);
void PMove_AccelJump(float move_time, float premove);
void PMove_Acceleration(float move_time, float premove);
void PMove_DoTouch(entity tother);
float PMove_Fix_Origin(void);
void PMove_Move(void);
void PMove_Run(void);
