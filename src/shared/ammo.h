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

/*! @file ammo.h
    @brief Ammo Handling Helper Functions.

    Helper functions for various ammo operations.
    This header can be included in other libraries and projects to help
    deal with these sorts of issues.
    It is usually included by default in a library project.
    If you want to include this file into your own progs, you
    can include `math.h` from `src/shared/`.
*/

/** Returns the name of the specified ammo type. Returns __NULL__ when invalid. */
string ammoNameForNum(int);
/** Returns the ammo id of a given name of ammo. Return -1 when invalid. */
int ammoNumForName(string);

