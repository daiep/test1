/*
 *  GE Medical Systems
 *  Copyright (C) 2013 The General Electric Company
 *
 *  HoecCorr.h
 *
 *  This file contains function declarations for HoecCorr.e
 *
 *  Language : ANSI C
 *  Author   : Dan Xu
 *  Date     : 02/21/2013
 */
/* do not edit anything above this line */

/*
   Version    Author     Date           Comment
----------------------------------------------------------------------
   1.0        DX         21-Feb-2013    Initial version.
  SV25 1.0    WJZ        10-Jan-2014    implemented eco-MPG case;

*/

#ifndef HoecCorr_h
#define HoecCorr_h

STATUS HoecSetEchoTrainAmp(void);

STATUS HoecSetBlipAmp(int blipsw);

STATUS HoecCalcReceiverPhase(void);

STATUS ReadHoecCorrTerms(void);

STATUS
CalcPsdReconHoecCorr(int control_psd,
                     int control_recon,
                     int per_echo_corr,
                     int numSlices,
                     long rsprot[DATA_ACQ_MAX][9],
                     float t_array[7],
                     int echoSpacing,
                     int nechoBeforeTE,
                     int echoTrainLength,
                     int interleaves);

float g_error_kcenter(float R,
                      float amp,
                      float tau,
                      float t1,
                      float t2,
                      float t5,
                      float t10);
                      
/* SVBranch: HCSDM00259119 - eco mpg:
   g_error_kcenter2: computes the HOEC normalized amplitude in eco-MPG 
                     case, where diff grad has multiple slew rate; */                      
float g_error_kcenter2(float R1,
                       float R2,
                       float R3,
                       float R4,
                       float amp,
                       float tau,
                       float t1, float t2, 
                       float t3, float t5, 
                       float t6, float t7, 
                       float t8, float t10);                     

void SaveHoecDebugInfo(int control_psd, int control_recon, int numSlices, float t_array[7], float r[3][3]);

void convertPhy2Log(float * output, int logTermIndex, int orderIndex, float rotm[3][3]);

void expandTrinomial(float output[HOEC_MAX_BASES_PER_ORDER],
                     int index[3][HOEC_MAX_BASES_PER_ORDER],
                     int num,
                     float rotm[3]);

int fractorial(int n);

STATUS failureClose(FILE * fp);

int isCommentOrBlankLine(char * str);

#endif /* HoecCorr_h */
