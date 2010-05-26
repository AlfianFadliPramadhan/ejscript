/**
    ejsc.c - Ejscript Compiler main program

    This compiler will compile the files given on the command line.

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "ejs.h"
#include    "ecCompiler.h"

/********************************** Forwards **********************************/

static void require(MprList *list, cchar *name);

/************************************ Code ************************************/

MAIN(ejscMain, int argc, char **argv)
{
    Mpr             *mpr;
    Ejs             *ejs;
    EcCompiler      *cp;
    EjsService      *ejsService;
    MprList         *requiredModules;
    char            *argp, *searchPath, *outputFile, *certFile, *name, *tok, *modules;
    int             nextArg, err, ejsFlags, ecFlags, bind, debug, doc, merge, modver;
    int             warnLevel, noout, parseOnly, tabWidth, optimizeLevel, strict, strip;

    /*
        Create the Embedthis Portable Runtime (MPR) and setup a memory failure handler
     */
    mpr = mprCreate(argc, argv, ejsMemoryFailure);
    mprSetAppName(mpr, argv[0], 0, 0);

    if (mprStart(mpr) < 0) {
        mprError(mpr, "Can't start mpr services");
        return EJS_ERR;
    }
    err = 0;
    searchPath = 0;
    strict = 0;
    certFile = 0;
    ecFlags = 0;
    bind = 0;
    debug = 0;
    doc = 0;
    merge = 0;
    modver = 0;
    noout = 0;
    parseOnly = 0;
    tabWidth = 4;
    warnLevel = 1;
    outputFile = 0;
    optimizeLevel = 9;
    requiredModules = 0;

    for (nextArg = 1; nextArg < argc; nextArg++) {
        argp = argv[nextArg];
        if (*argp != '-') {
            break;
        }
        if (strcmp(argp, "--bind") == 0) {
            bind = 1;

        } else if (strcmp(argp, "--debug") == 0) {
            debug = 1;

        } else if (strcmp(argp, "--doc") == 0) {
            doc = 1;

        } else if (strcmp(argp, "--log") == 0) {
            /*
                Undocumented logging switch
             */
            if (nextArg >= argc) {
                err++;
            } else {
                ejsStartLogging(mpr, argv[++nextArg]);
            }

        } else if (strcmp(argp, "--merge") == 0) {
            merge = 1;

        } else if (strcmp(argp, "--modver") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                modver = ejsParseModuleVersion(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--nobind") == 0) {
            bind = 0;

        } else if (strcmp(argp, "--noout") == 0) {
            noout = 1;

        } else if (strcmp(argp, "--standard") == 0) {
            strict = 0;

        } else if (strcmp(argp, "--strict") == 0) {
            strict = 1;

        } else if (strcmp(argp, "--optimize") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                optimizeLevel = atoi(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--out") == 0) {
            /*
                Create a single output module file containing all modules
             */
            if (nextArg >= argc) {
                err++;
            } else {
                outputFile = argv[++nextArg];
            }

        } else if (strcmp(argp, "--parse") == 0) {
            parseOnly = 1;

        } else if (strcmp(argp, "--search") == 0 || strcmp(argp, "--searchpath") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                searchPath = argv[++nextArg];
            }

        } else if (strcmp(argp, "--require") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                if (requiredModules == 0) {
                    requiredModules = mprCreateList(mpr);
                }
                modules = mprStrdup(mpr, argv[++nextArg]);
                name = mprStrTok(modules, " \t,", &tok);
                while (name != NULL) {
                    require(requiredModules, name);
                    name = mprStrTok(NULL, " \t", &tok);
                }
            }

        } else if (strcmp(argp, "--sign") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                certFile = argv[++nextArg];
            }

        } else if (strcmp(argp, "--strip") == 0) {
            strip = 1;

        } else if (strcmp(argp, "--tabWidth") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                tabWidth = atoi(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--version") == 0 || strcmp(argp, "-V") == 0) {
            mprPrintfError(mpr, "%s %s-%s\n", BLD_NAME, BLD_VERSION, BLD_NUMBER);
            exit(0);

        } else if (strcmp(argp, "--warn") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                warnLevel = atoi(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--web") == 0) {
            if (requiredModules == 0) {
                requiredModules = mprCreateList(mpr);
            }
            require(requiredModules, "ejs");
            require(requiredModules, "ejs.unix");
            require(requiredModules, "ejs.db");
            //  TODO MOB - decouple and remove this
            require(requiredModules, "ejs.db.mapper");
            require(requiredModules, "ejs.web");

        } else {
            err++;
            break;
        }
    }
    if (noout || merge) {
        bind = 1;
    }
    if (outputFile && noout) {
        mprPrintfError(mpr, "Can't use --out and --noout\n");
        err++;
    }
    if (argc == nextArg) {
        err++;
    }
    if (err) {
        /*
            Usage Examples:
                ejsc Person.es User.es Customer.es
                ejsc --out group.mod Person.es User.es Customer.es
                ejsc --out group.mod Person.es User.es Customer.es
         */
        mprPrintfError(mpr,
            "Usage: %s [options] files...\n"
            "  Ejscript compiler options:\n"
            "  --bind                 # Bind global properties to slots. Requires --out.\n"
            "  --debug                # Include symbolic debugging information in output\n"
            "  --doc                  # Include documentation strings in output\n"
            "  --merge                # Merge dependent input modules into the output\n"
            "  --modver version       # Set the default module version\n"
            "  --noout                # Do not generate any output\n"
            "  --optimize level       # Set optimization level (0-9)\n"
            "  --out filename         # Name a single output module (default: \"default.mod\")\n"
            "  --parse                # Just parse source. No output\n"
            "  --search ejsPath       # Module search path\n"
            "  --standard             # Default compilation mode to standard (default)\n"
            "  --strict               # Default compilation mode to strict\n"
#if FUTURE
            "  --sign certFile        # Sign the module file (not implemented) \n"
            "  --strip                # Strip all symbolic names (Can't import)\n"
            "  --tabwidth             # Tab width for '^' error reporting\n"
#endif
            "  --require 'module ...' # List of required modules to pre-load\n"
            "  --version              # Emit the compiler version information\n"
            "  --warn level           # Set the warning message level (0-9)\n\n",
            mpr->name);
        return -1;
    }

    ejsService = ejsCreateService(mpr);
    if (ejsService == 0) {
        return MPR_ERR_NO_MEMORY;
    }
    ejsFlags = EJS_FLAG_NO_INIT;
    if (doc) {
        ejsFlags |= EJS_FLAG_DOC;
    }
    ejs = ejsCreateVm(ejsService, NULL, searchPath, requiredModules, ejsFlags);
    if (ejs == 0) {
        return MPR_ERR_NO_MEMORY;
    }
    ecFlags |= (debug) ? EC_FLAGS_DEBUG: 0;
    ecFlags |= (merge) ? EC_FLAGS_MERGE: 0;
    ecFlags |= (bind) ? EC_FLAGS_BIND: 0;
    ecFlags |= (noout) ? EC_FLAGS_NO_OUT: 0;
    ecFlags |= (parseOnly) ? EC_FLAGS_PARSE_ONLY: 0;

    cp = ecCreateCompiler(ejs, ecFlags);
    if (cp == 0) {
        return MPR_ERR_NO_MEMORY;
    }
    cp->require = requiredModules;
    cp->modver = modver;

    ecSetOptimizeLevel(cp, optimizeLevel);
    ecSetWarnLevel(cp, warnLevel);
    ecSetStrictMode(cp, strict);
    ecSetTabWidth(cp, tabWidth);
    ecSetOutputFile(cp, outputFile);
    ecSetCertFile(cp, certFile);

    if (nextArg < argc) {
        /*
            Compile the source files supplied on the command line. This will compile in-memory and
            optionally also save to module files.
         */
        if (ecCompile(cp, argc - nextArg, &argv[nextArg]) < 0) {
            mprError(cp, "%s", cp->errorMsg);
            err++;
        }
    }
    if (cp->errorCount > 0) {
        err++;
    }
    mprStop(mpr);
    mprFree(mpr);
    return err;
}


static void require(MprList *list, cchar *name) 
{
    mprAssert(list);
    if (name && *name) {
        mprAddItem(list, name);
    }
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
