/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  epi2.h
 *  
 *  This file contains the prototypes declarations for all functions 
 *  the epi2 project. 
 *  
 *  Language : ANSI C
 *  Author   : Vinod Baskaran
 *  Date     : 12/11/97
 */
/* do not edit anything above this line */

/*
   Version    Author     Date       Comment
----------------------------------------------------------------------
     1.0       VB      1-May-98   Initial version.

 sccs1.2  Dale Thayer  9-Sep-98   Added prototypes for all *.e and *.c files.
 ML1.0     ZZ & MJM     30-Jun-2015 Modified to support slice fov shift blips

 */

#include "epic_ifcc_sizes.h"
#include "epic_waveform_types.h"
#include "filter_defs.h"
#include "psd_proto.h"

#ifndef epi2_h
#define epi2_h

/* from epi2.e @host section */

float parab( float amp, float time, float offset);

void   myscan(void);

STATUS cveval1(void); 

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

STATUS  getminesp( FILTER_INFO epi_filt,
               INT xtr_pkt_off,
               INT ileaves,
               INT hrd_per,
               INT vrgf_on,
               INT *minesp );

#ifdef __cplusplus
}
#endif /* __cplusplus */

STATUS avmintecalc(void);

STATUS setburstmode(void);

STATUS setb0rotmats(void);

STATUS nexcalc(void);

STATUS predownload1(void);

STATUS setUserCVs(void);


/* from epi2.e @pg section */

void ssisat(void);

void dummyssi(void);

STATUS setupphases(int *phase,int *freq,int slice,float rel_phase,int time_delay, int sign_flag);

STATUS makephaseencode(int pos);

STATUS makephaserewinder(int pos);


 
/* from epi2.e @rsp section */

STATUS CardInit(
    int ctlend_tab[], int ctlend_intern,int ctlend_last[], 
    int ctlend_fill[],int ctlend_unfill[], int subhacq, int subhrep, int subphases);

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

STATUS ref(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

STATUS ref_init(void);

STATUS fstune(void);

STATUS rtd(void);

STATUS scan_init(void);

STATUS recv_phase_freq_init(void);

STATUS scanloop(void);

STATUS core(void);

STATUS blineacq(void);

STATUS dabrbaload(int blipsw, int blipstart, int blipinc, int numblips, int fovshift);

STATUS diffamp( int dshot );
 
STATUS diffstep( int dshot );

STATUS ddpgatetrig(void);

STATUS msmpTrig(void);

STATUS phaseReset(WF_PULSE_ADDR pulse, int control);

STATUS pgatetrig(void);

STATUS pgatedelay(void);

STATUS setreadpolarity(void);

STATUS ygradctrl(int blipsw,int blipwamp,int numblips);

STATUS zgradctrl(int blipsw, int blipstart, int blipinc, int numblips, int fovshift);

STATUS getfiltdelay(float *delay_val,int fastrec,int vrgfflag);

STATUS rotateToLogical(float * idifx, float * idify, float * idifz, int dir);

STATUS inversRspRot(float inversRot[9], long origRot[9]);

STATUS reset_for_scan( void );

void getDiffGradAmp(float * difx, float * dify, float * difz, int dshot);

void loadDiffVecMatrix(void);

STATUS set_diff_order();

int get_diff_order(int pass, int slice);

int getLCD(int a, int b);

STATUS get_gy1_time(void);

STATUS get_flowcomp_time(void);

int get_extra_dpc_tetime(void);

int get_extra_rtb0_tetime(void);

/* from Dwicorrcal.e */

STATUS dwicorrcal( float dwigcorr[9], float dwibcorr[3], float dwikcorr[9], 
                   int control, int debug, long rsprot[DATA_ACQ_MAX][9], 
                   int xfs, int yfs, int zfs, float t_array[7] );

float k_error( float R, float amp, float tau, float t1, float t2, 
               float t3, float t4, float t9, float d4, float delta);

float g_error( float R, float amp, float tau, float t1, float t2, 
               float t5, float t10 );


/* from Inversion_new.e */
float get_fa_scaling_factor_ir(float act_fa, float nom_fa, float nom_max_b1);

#endif /* epi2_h */
