/*
 * Copyright (c) 2024 Vera Visions LLC.
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

void MapC_Init(void);

void MapC_CallMainFunction(void);

void MapC_CallNamedFunction(entity, string);

bool RuleC_CallFunc(float, entity, string);
bool RuleC_CallFrame(float, string);

bool RuleC_CallDamage(float, entity, entity, entity, string, string);

bool RuleC_CallRequestSpawn(float, entity, string);
bool RuleC_CallRequestTeam(float, entity, int, string);

bool RuleC_CallString(float, entity, string, string);

bool RuleC_CallFloat(float, entity, float, string);
int RuleC_CallMaxItemsPerSlot(float, int, string);
void RuleC_CallInput(float, entity, string, string);
