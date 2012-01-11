/** 
    ejsc.c - Ejscript Compiler main program

    This compiler will compile the files given on the command line.

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "ejsCompiler.h"

/********************************** Forwards **********************************/

typedef struct App {
    Ejs         *ejs;
    EcCompiler  *compiler;
    MprList     *modules;
} App;

static App *app;

static void manageApp(App *app, int flags);
static void require(cchar *name);

/************************************ Code ************************************/

MAIN(ejscMain, int argc, char **argv, char **envp)
{
    Mpr             *mpr;
    Ejs             *ejs;
    EcCompiler      *cp;
    char            *argp, *searchPath, *outputFile, *outputDir, *certFile, *name, *tok, *modules;
    int             nextArg, err, ejsFlags, ecFlags, bind, debug, doc, merge, modver;
    int             warnLevel, noout, parseOnly, tabWidth, optimizeLevel, strict;

    /*
        Initialize the Multithreaded Portable Runtime (MPR)
     */
    mpr = mprCreate(argc, argv, 0);
    mprSetAppName(argv[0], 0, 0);
    app = mprAllocObj(App, manageApp);
    mprAddRoot(app);
    mprAddStandardSignals();

    if (mprStart() < 0) {
        mprError("Can't start mpr services");
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
    outputDir = 0;
    optimizeLevel = 9;

    for (nextArg = 1; nextArg < argc; nextArg++) {
        argp = argv[nextArg];
        if (*argp != '-') {
            break;
        }
        if (strcmp(argp, "--bind") == 0) {
            bind = 1;

        } else if (strcmp(argp, "--debug") == 0) {
            debug = 1;

        } else if (strcmp(argp, "--debugger") == 0 || strcmp(argp, "-D") == 0) {
            mprSetDebugMode(1);

        } else if (strcmp(argp, "--dir") == 0) {
            /*
                Set the output directory for modules
             */
            if (nextArg >= argc) {
                err++;
            } else {
                outputDir = argv[++nextArg];
            }

        } else if (strcmp(argp, "--doc") == 0) {
            doc = 1;

        } else if (strcmp(argp, "--log") == 0) {
            /*
                Undocumented logging switch
             */
            if (nextArg >= argc) {
                err++;
            } else {
                mprStartLogging(argv[++nextArg], 0);
                mprSetCmdlineLogging(1);
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
                if (app->modules == 0) {
                    app->modules = mprCreateList(-1, 0);
                }
                modules = sclone(argv[++nextArg]);
#if MACOSX || WIN
                /*  Fix for Xcode and Visual Studio */
                if (modules[0] == ' ' || scmp(modules, "null") == 0) {
                    modules[0] = '\0';                    
                }
#endif
                name = stok(modules, " \t,", &tok);
                while (name != NULL) {
                    require(name);
                    name = stok(NULL, " \t", &tok);
                }
            }

        } else if (strcmp(argp, "--sign") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                certFile = argv[++nextArg];
            }

#if FUTURE
        } else if (strcmp(argp, "--strip") == 0) {
            strip = 1;
#endif
        } else if (strcmp(argp, "--tabWidth") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                tabWidth = atoi(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--version") == 0 || strcmp(argp, "-V") == 0) {
            mprPrintfError("%s %s-%s\n", BLD_NAME, BLD_VERSION, BLD_NUMBER);
            return 0;

        } else if (strcmp(argp, "--warn") == 0) {
            if (nextArg >= argc) {
                err++;
            } else {
                warnLevel = atoi(argv[++nextArg]);
            }

        } else if (strcmp(argp, "--web") == 0) {
            if (app->modules == 0) {
                app->modules = mprCreateList(-1, 0);
            }
            require("ejs");
            require("ejs.unix");
            require("ejs.db");
            //  TODO - decouple and remove this
            require("ejs.db.mapper");
            require("ejs.web");

        } else {
            err++;
            break;
        }
    }
    if (noout || merge) {
        bind = 1;
    }
    if (outputFile && noout) {
        mprPrintfError("Can't use --out and --noout\n");
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

            NOTE: bind is deliberately not documented and is for internal use only.
         */
        mprPrintfError("Usage: %s [options] files...\n"
            "  Ejscript compiler options:\n"
            "  --debug                # Include symbolic debugging information in output\n"
            "  --doc                  # Include documentation strings in output\n"
            "  --dir directory        # Set the output directory for modules (default: \".\")\n"
            "  --merge                # Merge dependent input modules into the output\n"
            "  --modver version       # Set the default module version\n"
            "  --noout                # Do not generate any output\n"
            "  --optimize level       # Set optimization level (0-9)\n"
            "  --out filename         # Name a single output module (default: \"default.mod\")\n"
            "  --parse                # Just parse source. No output\n"
            "  --require 'module ...' # List of required modules to pre-load\n"
            "  --search ejsPath       # Module search path\n"
            "  --standard             # Default compilation mode to standard (default)\n"
            "  --strict               # Default compilation mode to strict\n"
#if FUTURE
            "  --sign certFile        # Sign the module file (not implemented) \n"
            "  --strip                # Strip all symbolic names (Can't import)\n"
            "  --tabwidth             # Tab width for '^' error reporting\n"
#endif
            "  --version              # Emit the compiler version information\n"
            "  --warn level           # Set the warning message level (0-9)\n\n",
            mpr->name);
        return -1;
    }
    ejsFlags = EJS_FLAG_NO_INIT;
    if (doc) {
        ejsFlags |= EJS_FLAG_DOC;
    }
    if ((ejs = ejsCreateVM(0, 0, ejsFlags)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (ejsLoadModules(ejs, searchPath, app->modules) < 0) {
        return MPR_ERR_CANT_READ;
    }
    app->ejs = ejs;
    ecFlags |= (debug) ? EC_FLAGS_DEBUG: 0;
    ecFlags |= (merge) ? EC_FLAGS_MERGE: 0;
    ecFlags |= (bind) ? EC_FLAGS_BIND: 0;
    ecFlags |= (noout) ? EC_FLAGS_NO_OUT: 0;
    ecFlags |= (parseOnly) ? EC_FLAGS_PARSE_ONLY: 0;
    ecFlags |= (doc) ? EC_FLAGS_DOC: 0;

    cp = app->compiler = ecCreateCompiler(ejs, ecFlags);
    if (cp == 0) {
        return MPR_ERR_MEMORY;
    }
    cp->require = app->modules;
    cp->modver = modver;

    ecSetOptimizeLevel(cp, optimizeLevel);
    ecSetWarnLevel(cp, warnLevel);
    ecSetStrictMode(cp, strict);
    ecSetTabWidth(cp, tabWidth);
    ecSetOutputDir(cp, outputDir);
    ecSetOutputFile(cp, outputFile);
    ecSetCertFile(cp, certFile);

    if (nextArg < argc) {
        /*
            Compile the source files supplied on the command line. This will compile in-memory and
            optionally also save to module files.
         */
        if (ecCompile(cp, argc - nextArg, &argv[nextArg]) < 0) {
            err++;
        }
        if (cp->warningCount > 0 || cp->errorCount > 0) {
            mprRawLog(0, "%s\n", cp->errorMsg);
        }
    }
    if (cp->errorCount > 0) {
        err++;
    }
    mprDestroy(MPR_EXIT_DEFAULT);
    return err;
}


static void manageApp(App *app, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(app->compiler);
        mprMark(app->ejs);
        mprMark(app->modules);
    }
}


static void require(cchar *name) 
{
    mprAssert(app->modules);
    if (name && *name) {
        mprAddItem(app->modules, sclone(name));
    }
}

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2012. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2012. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire
    a commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.TXT distributed with
    this software for full details.

    This software is open source; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version. See the GNU General Public License for more
    details at: http://embedthis.com/downloads/gplLicense.html

    This program is distributed WITHOUT ANY WARRANTY; without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    This GPL license does NOT permit incorporating this software into
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses
    for this software and support services are available from Embedthis
    Software at http://embedthis.com

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
