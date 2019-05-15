/*
 *  eco_mpg.h
 *
 *  This file constains the prototype declarations for all functions
 *  in eco_mpg.e.
 *
 *  Language : ANSI C
 *  Author   : Jiazheng Wang
 *  Date     : June 2013
 *
 */

#ifndef eco_mpg_h
#define eco_mpg_h

/*** host functions ***/
STATUS eco_mpg_cvinit(void);
STATUS eco_mpg_cveval(void);
STATUS mpg_opt_gen(int   avail_time, 
                   int   time_180, 
                   int   t1, 
                   int   tv1, 
                   int   t2, 
                   int   tv2, 
                   int   t3, 
                   float maxG, 
                   float SR, 
                   float b_target, 
                   int   axis_flag);
STATUS mpg_opt_timing(int   tmp_axis_flag,
                      int   tmp_Delta_time,
                      float tmp_MaxAmp,
                      float tmp_bvaltemp); 
STATUS dse_opt_timing(float b_target, 
                      int   pw_d1_guess, 
                      int   pw_ramp, 
                      int   pw_delta,                      
                      float gmax); 
float eco_mpg_calcbval(float *g, float *t, int n);                      

#endif
