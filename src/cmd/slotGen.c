/**
    slotGen.c - Generate property slot offset definitions.
  
    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "ejsmod.h"

/*********************************** Locals ***********************************/

static char *defaultVersion;

/***************************** Forward Declarations ***************************/

static int  createSlotFile(EjsMod *bp, EjsModule *mp, MprFile *file);
static int  genType(EjsMod *bp, MprFile *file, EjsModule *mp, EjsType *type, int firstClassSlot, int lastClassSlot,
                int isGlobal);
static char *mapFullName(Ejs *ejs, EjsName *qname, int mapTypeName);
static char *mapName(cchar *name, int mapTypeName);
static char *mapNamespace(cchar *space);

/*********************************** Code *************************************/

int emCreateSlotFiles(EjsMod *bp, EjsModule *mp, MprFile *outfile)
{
    int     rc;

    rc = 0;
    defaultVersion = mprAsprintf("-%d", ejsParseModuleVersion(BLD_VERSION));
    if (bp->cslots) {
        rc += createSlotFile(bp, mp, outfile);
    }
    return rc;
}


static int createSlotFile(EjsMod *bp, EjsModule *mp, MprFile *file)
{
    Ejs         *ejs;
    EjsType     *type;
    MprFile     *localFile;
    char        *path, slotsName[MPR_MAX_FNAME], moduleName[MPR_MAX_FNAME];
    char        *cp, *sp, *dp;
    int         slotNum;

    mprAssert(bp);

    path = 0;
    localFile = 0;
    ejs = bp->ejs;

    scopy(moduleName, sizeof(moduleName), ejsToMulti(ejs, mp->name));
    for (cp = moduleName; *cp; cp++)  {
        if (*cp == '.') {
            *cp = '_';
        }
    }
    mprSprintf(slotsName, sizeof(slotsName), "%@Slots", mp->name);
    slotsName[0] = toupper((int) slotsName[0]);
    for (dp = sp = slotsName; *sp; sp++) {
        if (*sp == '.') {
            ++sp;
            *dp++ = toupper((int) *sp);
        } else {
            *dp++ = *sp;
        }
    }
    *dp = '\0';

    if (file == 0) {
        path = sjoin(ejsToMulti(ejs, mp->name), ".slots.h", NULL);
        localFile = file = mprOpen(path, O_CREAT | O_WRONLY | O_TRUNC | O_BINARY, 0664);
    } else {
        path = sclone(file->path);
    }
    if (file == 0) {
        mprError("Can't open %s", path);
        mprFree(path);
        return MPR_ERR_CANT_OPEN;
    }
    mprEnableFileBuffering(file, 0, 0);

    mprFprintf(file,
        "/*\n"
        "   %s -- Native property slot definitions for the \"%@\" module\n"
        "  \n"
        "   This file is generated by ejsmod\n"
        "  \n"
        "   Slot definitions. Version %s.\n"
        " */\n"
        "\n", path, mp->name, BLD_VERSION);

    mprFprintf(file,
        "#ifndef _h_SLOTS_%s\n"
        "#define _h_SLOTS_%s 1\n\n",
        slotsName, slotsName);

    mprFprintf(file, "\n/*\n   Slots for the \"%@\" module \n */\n", mp->name);

    slotNum = ejsGetPropertyCount(ejs, ejs->global);
    type = ejsCreateType(ejs, N(EJS_EJS_NAMESPACE, EJS_GLOBAL), NULL, NULL, NULL, sizeof(EjsType), slotNum, 
        ejsGetPropertyCount(ejs, ejs->global), 0, 0);
    type->constructor.block = *(EjsBlock*) ejs->global;
    TYPE(type) = ejs->typeType;
    type->constructor.block.pot.isType = 1;

    if (genType(bp, file, mp, type, mp->firstGlobal, mp->lastGlobal, 1) < 0) {
        mprError("Can't generate slot file for module %@", mp->name);
        mprFree(path);
        mprFree(localFile);
        return EJS_ERR;
    }
    mprFprintf(file, "\n#define _ES_CHECKSUM_%s   %d\n", moduleName, mp->checksum);
    mprFprintf(file, "\n#endif\n");
    mprFree(localFile);
    mprFree(path);
    return 0;
}


static void defineSlot(EjsMod *bp, MprFile *file, EjsModule *mp, EjsType *type, EjsObj *obj, int slotNum, EjsName *funName, 
        EjsName *name)
{
    Ejs     *ejs;
    char    nameBuf[MPR_MAX_STRING];
    char    *funSep, *sp, *typeStr, *funStr, *nameStr;
    ejs = bp->ejs;

    typeStr = mapFullName(ejs, &type->qname, 1);
#if UNUSED
    if (slotNum < type->numInherited && obj == type->prototype) {
        subStr = mapFullName(ejs, &type->baseType->qname, 1);
        subSep = "_";
    } else {
        subSep = subStr = "";
    }
#endif
    funStr = mapFullName(ejs, funName, 0);
    nameStr = mapFullName(ejs, name, 0);

    if (nameStr[0] != '\0') {
        funSep = (char*) ((*funStr && *typeStr) ? "_" : "");
        if (*typeStr == '\0' && *funStr == '\0') {
            mprSprintf(nameBuf, sizeof(nameBuf), "#define ES_%s", nameStr);
        } else {
            if (!(nameStr[0] == '_' && nameStr[1] == '_')) {
                mprSprintf(nameBuf, sizeof(nameBuf), "#define ES_%s%s%s_%s", typeStr, funSep, funStr, nameStr);
            } else {
                nameBuf[0] = '\0';
            }
        }
        for (sp = nameBuf; *sp; sp++) {
            if (*sp == '.') {
                *sp = '_';
            }
        }
        if (nameBuf[0]) {
            mprFprintf(file, "%-70s %d\n", nameBuf, slotNum);
        }
    }
    mprFree(typeStr);
    mprFree(funStr);
    mprFree(nameStr);
}


static void defineSlotCount(EjsMod *bp, MprFile *file, EjsModule *mp, EjsType *type, char *suffix, int numProp)
{
    char        name[MPR_MAX_STRING], *typeStr, *sp;

    typeStr = mapFullName(bp->ejs, &type->qname, 1);
    if (*typeStr == '\0') {
        mprFree(typeStr);
        typeStr = sclone(EJS_GLOBAL);
    }
    for (sp = typeStr; *sp; sp++) {
        if (*sp == '.') {
            *sp = '_';
        }
    }
    mprSprintf(name, sizeof(name), "#define ES_%s_NUM_%s_PROP", typeStr, suffix);
    mprFprintf(file, "%-70s %d\n", name, numProp);
    if (strcmp(suffix, "INSTANCE") == 0) {
        mprSprintf(name, sizeof(name), "#define ES_%s_NUM_INHERITED_PROP", typeStr);
        mprFprintf(file, "%-70s %d\n", name, type->numInherited);
    }
    mprFree(typeStr);
}


/*
    Generate the slot offsets for a type
 */
static int genType(EjsMod *bp, MprFile *file, EjsModule *mp, EjsType *type, int firstClassSlot, int lastClassSlot,
    int isGlobal)
{
    Ejs             *ejs;
    EjsPot          *prototype, *activation;
    EjsObj          *vp;
    EjsTrait        *trait, *lp;
    EjsType         *nt;
    EjsFunction     *fun;
    EjsName         qname, lqname;
    int             slotNum, i, methodHeader, count, offset;

    mprAssert(bp);
    mprAssert(type);
    mprAssert(ejsIsType(ejs, type));

    ejs = bp->ejs;
    lastClassSlot = max(firstClassSlot, lastClassSlot);

    if (!isGlobal || ejsCompareMulti(ejs, mp->name, "ejs") == 0) {
        /*
            Only emit global property slots for "ejs"
         */
        if (isGlobal) {
            mprFprintf(file, "\n\n/*\n    Global property slots\n */\n");
        } else {
            mprFprintf(file, "\n\n/*\n    Class property slots for the \"%@\" type \n */\n", type->qname.name);
        }
        if (firstClassSlot < lastClassSlot) {
            for (slotNum = firstClassSlot; slotNum < lastClassSlot; slotNum++) {
                trait = ejsGetPropertyTraits(ejs, (EjsObj*) type, slotNum);
                qname = ejsGetPropertyName(ejs, (EjsObj*) type, slotNum);
                if (qname.name == 0) {
                    continue;
                }
                defineSlot(bp, file, mp, type, (EjsObj*) type, slotNum, NULL, &qname);
            }
        }
        defineSlotCount(bp, file, mp, type, "CLASS", lastClassSlot);
    }

    /*
        Process instance traits
     */
    prototype = type->prototype;
    if (prototype) {
        mprFprintf(file, "\n/*\n   Prototype (instance) slots for \"%@\" type \n */\n", type->qname.name);
        count = ejsGetPropertyCount(ejs, prototype);
        offset = 0;
        for (slotNum = offset; slotNum < count; slotNum++) {
            trait = ejsGetPropertyTraits(ejs, prototype, slotNum);
            qname = ejsGetPropertyName(ejs, prototype, slotNum);
            if (qname.name == 0) {
                continue;
            }
            defineSlot(bp, file, mp, type, (EjsObj*) prototype, slotNum, NULL, &qname);
        }
    } else {
        slotNum = 0;
    }

    /*
        For the global type, only emit the count for the "ejs" module
     */
    if (!isGlobal || ejsCompareMulti(ejs, mp->name, "ejs") == 0) {
        defineSlotCount(bp, file, mp, type, "INSTANCE", slotNum);
    }

    /*
        Now examine methods in the type and define any locals and args
     */
    methodHeader = 0;
    for (slotNum = firstClassSlot; slotNum < lastClassSlot; slotNum++) {
        trait = ejsGetPropertyTraits(ejs, (EjsObj*) type, slotNum);
        qname = ejsGetPropertyName(ejs, (EjsObj*) type, slotNum);
        if (trait == 0 || qname.name == 0) {
            continue;
        }
        if (trait->type != ejs->functionType) {
            continue;
        }
        vp = ejsGetProperty(ejs, (EjsObj*) type, slotNum);
        if (vp == 0 || !ejsIsFunction(ejs, vp)) {
            continue;
        }
        fun = ((EjsFunction*) vp);
        activation = fun->activation;
        if (activation == 0) {
            continue;
        }
        if (!methodHeader) {
            if (isGlobal) {
                mprFprintf(file, "\n/*\n    Local slots for global methods \n */\n");
            } else {
                mprFprintf(file, "\n/*\n    Local slots for methods in type \"%@\" \n */\n", type->qname.name);
            }
            methodHeader++;
        }
        /*
            Output the arg names and local variable names.
         */
        for (i = 0; i < (int) fun->numArgs; i++) {
            lp = ejsGetPropertyTraits(ejs, activation, i);
            lqname = ejsGetPropertyName(ejs, activation, i);
            defineSlot(bp, file, mp, type, (EjsObj*) activation, i, &qname, &lqname);
        }
        for (; i < fun->block.pot.numProp; i++) {
            lp = ejsGetPropertyTraits(ejs, activation, i);
            lqname = ejsGetPropertyName(ejs, activation, i);
            defineSlot(bp, file, mp, type, (EjsObj*) activation, i, &qname, &lqname);
        }
    }

    /*
        Now process nested types.
     */
    for (slotNum = firstClassSlot; slotNum < lastClassSlot; slotNum++) {
        trait = ejsGetPropertyTraits(ejs, (EjsObj*) type, slotNum);
        qname = ejsGetPropertyName(ejs, (EjsObj*) type, slotNum);

        if (qname.name == 0) {
            continue;
        }
        vp = ejsGetProperty(ejs, (EjsObj*) type, slotNum);
        if (vp == 0) {
            continue;
        }
        if (! ejsIsType(ejs, vp) || VISITED(vp)) {
            continue;
        }
        nt = (EjsType*) vp;
        if (nt->module != mp) {
            continue;
        }
        VISITED(vp) = 1;

        count = ejsGetPropertyCount(ejs, (EjsObj*) nt);
        if (genType(bp, file, mp, nt, 0, count, 0) < 0) {
            VISITED(vp) = 0;
            return EJS_ERR;
        }
        VISITED(vp) = 0;
    }
    return 0;
}


static char *mapFullName(Ejs *ejs, EjsName *qname, int mapTypeName)
{
    cchar       *name, *space;
    char        *cp, *buf;

    if (qname == 0) {
        return sclone("");
    }
    name = mapName(ejsToMulti(ejs, qname->name), mapTypeName);
    space = mapNamespace(ejsToMulti(ejs, qname->space));

    if (*space) {
        buf = sjoin(space, "_", name, NULL);
    } else {
        buf = sclone(name);
    }
    for (cp = buf; *cp; cp++)  {
        if (*cp == '-') {
            *cp = '_';
        }
    }
    return buf;
}


static char *mapName(cchar *name, int mapTypeName)
{
    cchar   *value;
    char    *buf, *cp;

    if (name == 0) {
        name = "";
    }

    value = name;
    if (mapTypeName) {
        if (strcmp(name, EJS_GLOBAL) == 0) {
            value = "";
        }
    }
    if (strcmp(name, "*") == 0) {
        value = "DEFAULT";
    }
    if (strcmp(name, "+") == 0) {
        value = "PLUS";
    } else if (strcmp(name, "-") == 0) {
        value = "MINUS";
    } else if (strcmp(name, "/") == 0) {
        value = "DIV";
    } else if (strcmp(name, "*") == 0) {
        value = "MUL";
    } else if (strcmp(name, "%") == 0) {
        value = "MOD";
    } else if (strcmp(name, "[") == 0) {
        value = "LBRACKET";
    } else if (strcmp(name, "&") == 0) {
        value = "AND";
    } else if (strcmp(name, "|") == 0) {
        value = "OR";
    } else if (strcmp(name, "<<") == 0) {
        value = "LSH";
    } else if (strcmp(name, ">>") == 0) {
        value = "RSH";
    } else if (strcmp(name, "<") == 0) {
        value = "LT";
    } else if (strcmp(name, ">") == 0) {
        value = "GT";
    } else if (strcmp(name, "<=") == 0) {
        value = "LE";
    } else if (strcmp(name, ">=") == 0) {
        value = "GE";
    } else if (strcmp(name, "=") == 0) {
        value = "ASSIGN";
    } else if (strcmp(name, "==") == 0) {
        value = "EQ";
    } else if (strcmp(name, "!=") == 0) {
        value = "NE";
    } else if (strcmp(name, "===") == 0) {
        value = "STRICT_EQ";
    } else if (strcmp(name, "!==") == 0) {
        value = "STRICT_NE";
    } else if (strcmp(name, "!") == 0) {
        value = "NOT";
    } else if (strcmp(name, "~") == 0) {
        value = "NEG";
    } else if (strcmp(name, "< ") == 0) {
        value = "LT_BUG";
    } else if (strcmp(name, "= ") == 0) {
        value = "ASSIGN_BUG";
    }

    buf = sclone(value);
    for (cp = buf; *cp; cp++)  {
        if (*cp == '-') {
            *cp = '_';
        }
    }
    return buf;
}


static char *mapNamespace(cchar *space)
{
    char    *cp, *value;

    if (space == 0) {
        space = "";
    }
    if (strcmp(space, EJS_EJS_NAMESPACE) == 0) {
        space = "";
    } else if (strcmp(space, EJS_PUBLIC_NAMESPACE) == 0) {
        space = "";
    } else if (strcmp(space, EJS_PRIVATE_NAMESPACE) == 0) {
        space = "";
#if UNUSED
    } else if (strcmp(space, EJS_ITERATOR_NAMESPACE) == 0) {
        space = "iter";
#endif
    } else if (strcmp(space, EJS_CONSTRUCTOR_NAMESPACE) == 0) {
        space = "";
    } else if (strstr(space, ",private]") != 0) {
        space = "";
    } else if (strstr(space, ",protected]") != 0) {
        space = "";
    } else if (strstr(space, "internal-") != 0) {
        space = "";
    } else if ((cp = strstr(space, defaultVersion)) != 0 && strcmp(cp, defaultVersion) == 0) {
        space = sclone(space);
        cp = strstr(space, defaultVersion);
        *cp = '\0';
    }
    value = (char*) space;
    return value;
}


/*
    @copy   default
  
    Copyright (c) Embedthis Software LLC, 2003-2010. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2010. All Rights Reserved.
  
    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire
    a commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.TXT distributed with
    this software for full details.
  
    This software is open source; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version. See the GNU General Public License for more
    details at: http://www.embedthis.com/downloads/gplLicense.html
  
    This program is distributed WITHOUT ANY WARRANTY; without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  
    This GPL license does NOT permit incorporating this software into
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses
    for this software and support services are available from Embedthis
    Software at http://www.embedthis.com
  
    @end
 */
