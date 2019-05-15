/*
 *  GE Medical Systems
 *  Copyright (C) 1998 The General Electric Company
 *  
 *  T1flair.h
 *  
 *  
 *  
 *  Language : ANSI C
 *  Author   : Steve Tan
 *  Date     : Intial Revison 07/15/98
 */
/* do not edit anything above this line */

#ifndef T1flair_h
#define T1flair_h

/*
 * @host section
 */

STATUS
T1flairInit(void);

STATUS 
T1flair_setup(void);

STATUS 
T1flair_options(void);

STATUS
T1flairPredownload (void);


/*
 * @pg section
 */


/*
 * @rsp section
 */


#endif /* T1flair_h */
