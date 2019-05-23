/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  calcdelta.h - header file for calcdelta() routine used in DW-EPI
 *  
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 7/8/98
 */
/* do not edit anything above this line */

/*
   Version    Author     Date       Comment
----------------------------------------------------------------------
     1.0       BJM    8-Jul-1998   Created.
 */

#ifndef calcdelta_h
#define calcdelta_h
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */
STATUS calcdelta(
#ifdef __STDC__
    INT opdflag,
    INT *pw_diff,
    INT *pw_diffr,
    INT pw_sep,
    INT bval,
    DOUBLE targetAmp
#endif /* __STDC__ */
);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* calcdelta_h */

