/*
    ejsTune.h - Tunable parameters for the C VM and compiler

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

#ifndef _h_EJS_TUNE
#define _h_EJS_TUNE 1

/********************************* Includes ***********************************/

#include    "mpr.h"

#ifdef __cplusplus
extern "C" {
#endif

/********************************** Defines ***********************************/

#define HEAP_OVERHEAD (MPR_ALLOC_HDR_SIZE + MPR_ALLOC_ALIGN(sizeof(MprRegion) + sizeof(MprHeap) + sizeof(MprDestructor)))

/*
    Tunable Constants
    TODO - consistency of names needs work
 */
#if BLD_TUNE == MPR_TUNE_SIZE || DOXYGEN
    /*
     *  Tune for size
     */
    #define EJS_ARENA_SIZE          ((1 * 1024 * 1024) - MPR_HEAP_OVERHEAD) /* Initial virt memory for objects */
    #define EJS_LOTSA_PROP          256             /* Object with lots of properties. Grow by bigger chunks */
    #define EJS_MAX_OBJ_POOL        512             /* Maximum number of objects per type to cache */
    #define EJS_MAX_RECURSION       10000           /* Maximum recursion */
    #define EJS_MAX_REGEX_MATCHES   32              /* Maximum regular sub-expressions */
    #define EJS_MAX_SQLITE_MEM      (2*1024*1024)   /* Maximum buffering for Sqlite */
    #define EJS_MAX_TYPE            256             /* Maximum number of types */
    #define EJS_MIN_FRAME_SLOTS     16              /* Miniumum number of slots for function frames */
    #define EJS_NUM_GLOBAL          256             /* Number of globals slots to pre-create */
    #define EJS_ROUND_PROP          16              /* Rounding for growing properties */
    #define EJS_WORK_QUOTA          1024            /* Allocations required before garbage colllection */
    #define EJS_XML_MAX_NODE_DEPTH  64              /* Max nesting of tags */

#elif BLD_TUNE == MPR_TUNE_BALANCED
    /*
        Tune balancing speed and size
     */
    #define EJS_ARENA_SIZE          ((4 * 1024 * 1024) - MPR_HEAP_OVERHEAD)
    #define EJS_LOTSA_PROP          256
    #define EJS_MAX_OBJ_POOL        1024
    #define EJS_MAX_SQLITE_MEM      (20*1024*1024)
    #define EJS_MAX_RECURSION       (1000000)
    #define EJS_MAX_REGEX_MATCHES   64
    #define EJS_MIN_FRAME_SLOTS     24
    #define EJS_NUM_GLOBAL          512
    #define EJS_MAX_TYPE            512
    #define EJS_ROUND_PROP          24
    #define EJS_WORK_QUOTA          2048
    #define EJS_XML_MAX_NODE_DEPTH  256

#else
    /*
        Tune for speed
     */
    #define EJS_ARENA_SIZE          ((8 * 1024 * 1024) - MPR_HEAP_OVERHEAD)
    #define EJS_NUM_GLOBAL          1024
    #define EJS_LOTSA_PROP          1024
    #define EJS_MAX_OBJ_POOL        4096
    #define EJS_MAX_RECURSION       (1000000)
    #define EJS_MAX_REGEX_MATCHES   128
    #define EJS_MAX_TYPE            1024
    #define EJS_MAX_SQLITE_MEM      (20*1024*1024)
    #define EJS_MIN_FRAME_SLOTS     32
    #define EJS_ROUND_PROP          32
    #define EJS_WORK_QUOTA          4096
    #define EJS_XML_MAX_NODE_DEPTH  1024
#endif

#define EJS_XML_BUF_MAX             (256 * 1024)    /* Max XML document size */
#define EJS_HASH_MIN_PROP           8               /* Min props to hash */

#define EJS_SQLITE_TIMEOUT          30000           /* Database busy timeout */
#define EJS_SESSION_TIMEOUT         1800
#define EJS_TIMER_PERIOD            1000            /* Timer checks ever 1 second */
#define EJS_FILE_PERMS              0664            /* Default file perms */
#define EJS_DIR_PERMS               0775            /* Default dir perms */


#if BLD_FEATURE_MMU
    #if BLD_TUNE == MPR_TUNE_SIZE
        #define EJS_STACK_MAX       (1024 * 1024)   /* Stack size on virtual memory systems */
    #elif BLD_TUNE == MPR_TUNE_BALANCED
        #define EJS_STACK_MAX       (1024 * 1024 * 4)
    #else
        #define EJS_STACK_MAX       (1024 * 1024 * 16)
    #endif
#else
    /*
        Highly recursive workloads may need to increase the stack values
     */
    #if BLD_TUNE == MPR_TUNE_SIZE
        #define EJS_STACK_MAX       (1024 * 32)     /* Stack size without MMU */
    #elif BLD_TUNE == MPR_TUNE_BALANCED
        #define EJS_STACK_MAX       (1024 * 64)
    #else
        #define EJS_STACK_MAX       (1024 * 128)
    #endif
#endif

/*
    Sanity constants. Only for sanity checking. Set large enough to never be a
    real limit but low enough to catch some errors in development.
 */
#define EJS_MAX_POOL            (4*1024*1024)   /* Size of constant pool */
#define EJS_MAX_ARGS            (8192)          /* Max number of args */
#define EJS_MAX_LOCALS          (10*1024)       /* Max number of locals */
#define EJS_MAX_EXCEPTIONS      (8192)          /* Max number of exceptions */
#define EJS_MAX_TRAITS          (0x7fff)        /* Max number of declared properties per block */

/*
    Should not need to change these
 */
#define EJS_INC_ARGS            8               /* Frame stack increment */
#define EJS_MAX_BASE_CLASSES    256             /* Max inheritance chain */
#define EJS_DOC_HASH_SIZE       1007            /* Hash for doc descriptions */

/*
    Compiler constants
 */
#define EC_MAX_INCLUDE          32              /* Max number of nested includes */
#define EC_LINE_INCR            1024            /* Growth increment for input lines */
#define EC_TOKEN_INCR           64              /* Growth increment for tokens */
#define EC_MAX_LOOK_AHEAD       8
#define EC_BUFSIZE              4096            /* General buffer size */
#define EC_MAX_ERRORS           25              /* Max compilation errors before giving up */

#define EC_CODE_BUFSIZE         4096            /* Initial size of code gen buffer */
#define EC_NUM_PAK_PROP         32              /* Initial number of properties */

#ifdef __cplusplus
}
#endif
#endif /* _h_EJS_TUNE */

/*
    @copy   

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
