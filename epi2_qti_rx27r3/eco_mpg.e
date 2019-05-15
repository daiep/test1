/*
 *  eco_mpg.e
 *
 *  This file describes the functionalities to implement
 *  ECO-MPG and contains all the external functions 
 *  defined in eco_mpg.h.
 *
 *  Language : ANSI C
 *  Author   : Jiazheng Wang
 *  Date     : June 2013
 *
 *  SV25.0 28-Jan-2014 WJZ HCSDM00259119: eco-MPG implementation;
 *  SV25.0 11-Mar-2014 WJZ HCSDM00272549: Control CVs for eco-MPG should be invisible
 *                                        in non-diffusion case;  
 *  SV25.0 01-JUL-2014 WJZ HCSDM00300336: PSD static code analysis violations in MULAN;
 *
 */



/****** global ******/
@global eco_mpg_global
#include "eco_mpg.h"
/*** end of global ***/



/****** CVs ******/
@cv eco_mpg_cv

/* Control CVs */
int eco_mpg_support = 0 with {0, 1, 0, VIS, "eco-MPG support flag: 0=not support, 1=support",};
int eco_mpg_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "ECO-MPG",};
int mpg_opt_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "MPG shape optimization",};
int dse_enh_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_ON,  INVIS, "Flag for DSE enhancement of TE reduction: 1-yes, 0-no",};
int dse_opt_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "DSE MPG optimization",};
int bval_arbitrary_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Calc b-value with arbitrary grad shape: 1-yes, 0-no",};

/* CVs for DSE opt */
float pw_d1 = 0.0 with {0.0, , 0.0, INVIS, "plateau duration of 1st&4th diff-grad",};
float pw_d2 = 0.0 with {0.0, , 0.0, INVIS, "plateau duration of 2nd&3rd diff-grad",};
float b_tol = 0.015 with {0.0, , 0.0125, INVIS, "tolerance in percentage in b-value bias for DSE opt",};

/* CVs for MPG shape opt */
int   mpg_opt_margin = 200 with {0, , 200, INVIS, "margin in diff-grad shape opt",};
float mpg_opt_derate = 1.0 with {0.0, 10.0, 1.0, INVIS, "derate of diff-grad before shape opt",};
float mpg_opt_glimit_orig = 2.8 with {0.0, 10.0, 2.8, INVIS, "original glimit before eco-mpg",};

/*** end of CVs ***/



/****** host ******/
@host eco_mpg_host

/* cvinit */
STATUS eco_mpg_cvinit(void)
{
    if(isValueSystem())
    {
        eco_mpg_support = PSD_ON;
    }
    else
    {
        eco_mpg_support = PSD_OFF;
    }

    return SUCCESS;
} /* end of eco_mpg_cvinit() */

/* cveval */
STATUS eco_mpg_cveval(void)
{
    /* turn on below features for ECO-MPG:
       MPG shape opt,
       Left diff shift for DSE,
       DSE MPG opt; */
    if (PSD_ON == eco_mpg_flag)
    {
        mpg_opt_flag = PSD_ON;
        dse_enh_flag = PSD_ON;
        dse_opt_flag = PSD_ON;
    }
    else
    {
        mpg_opt_flag = PSD_OFF;
        dse_enh_flag = PSD_OFF;
        dse_opt_flag = PSD_OFF;    
    }

    /* For MPG shape opt:
       1. Use new coil-power algorithm
          (in XFD_model.c);
       2. Use new b-value calc algorithm with 
          arbitrary grad shape (in calcbval.c) */
    if ((PSD_ON == mpg_opt_flag))
    {
        CompositeRMS_method = PSD_ON;
        bval_arbitrary_flag   = PSD_ON;
    }
    else
    {
        CompositeRMS_method = PSD_OFF;
        bval_arbitrary_flag   = PSD_OFF;
    }  
    
    return SUCCESS;
} /* end of eco_mpg_cveval() */

/* This function optimizes the MPG shape
   such that the plateaus of the MPG pairs
   are furhter separated, and long ramps
   are used between the MPG pairs; 
   
   Inputs:
     avail_time: Total duration of diffusion module;
                 This should be kept because we don't
                 want to increase TE;
     time_180:   refocusing RF time;
     t1:         duration of 1st diff in DSE;
     tv1:        1st refocusing RF total duration and 
                 the margin time between excitation and 1st refocusing;       
     t2:         total duration of the 2nd and 3rd diff in DSE;
     tv2:        2nd refocusing RF total duration;
     t3:         duration of 4th diff in DSE;
     maxG:       upper limit of diffusion gradient;
     SR:         max slew rate of diffusion gradient;
     b_target:   targeted b-value;
     axis_flag:  0 = X, 1 = Y, 2 = Z; */
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
                   int   axis_flag)
{
    int   Gnum = 0;
    int   num = 0;
    int   i = 0;
    int   j = 0;
    float tstep = 24.0; /* us, search step */   
    float b_curr = 0.0;
    float G[20];
    float t[20];  

    /* HCSDM00300336: PSD static code analysis violations in MULAN;
       avoid zero b_curr in the calculations below; */
    if (b_target <= 0)
    {
        epic_error(use_ermes, "mpg_opt_gen() in eco_mpg.e failed, b_target should be larger than 0", 
                   EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," mpg_opt_gen()");
        return FAILURE;
    }    

    if(PSD_OFF == dualspinecho_flag)
    { 
     /* The grad amp values and time points, indexed
        from 0 to 7, correspond to:
        
        start of 1st diff;
        start of 1st diff plateau;
        end   of 1st diff plateau;
        end   of 1st diff;
        start of 2nd diff;
        start of 2nd diff plateau, negated due to 180;
        end   of 2nd diff plateau, negated due to 180;
        end   of 2nd diff; 
        
     */
    
        G[0] = 0;     
        G[1] = maxG;  
        G[2] = maxG;  
        G[3] = 0;     
        G[4] = 0;     
        G[5] = -maxG; 
        G[6] = -maxG;  
        G[7] = 0;     

        t[0] = 0;
        t[1] = maxG/SR;
        t[2] = maxG/SR+tstep;
        t[3] = (avail_time-time_180) / 2.0;
        t[4] = avail_time -t[3];
        t[7] = avail_time;
        t[6] = avail_time - maxG/SR;
        t[5] = t[6]-tstep;

        num = (t[3] - maxG/SR - t[1])/tstep;
        Gnum = 8;
    }  
    else
    {
    
     /* The grad amp values and time points, indexed
        from 0 to 14, correspond to:
        
        start of 1st diff;
        start of 1st diff plateau;
        end   of 1st diff plateau;
        end   of 1st diff;
        start of 2nd diff;
        start of 2nd diff plateau, negated due to 180;
        end   of 2nd diff plateau, negated due to 180;
        end   of 2nd diff (also, start of 3rd diff); 
        start of 3rd diff plateau, negated due to 180;
        end   of 3rd diff plateau, negated due to 180;
        end   of 3rd diff;    
        start of 4th diff;
        start of 4th diff plateau;
        end   of 4th diff plateau;
        end   of 4th diff;        
        
     */    
    
        G[0]  = 0;
        G[1]  = maxG;
        G[2]  = maxG;
        G[3]  = 0;
        G[4]  = 0;
        G[5]  = maxG;
        G[6]  = maxG;
        G[7]  = 0;
        G[8]  = -maxG;
        G[9]  = -maxG;
        G[10] = 0;
        G[11] = 0;
        G[12] = -maxG;
        G[13] = -maxG;
        G[14] = 0;

        t[0]  = 0;
        t[1]  = (maxG/SR);
        t[2]  = t1-maxG/SR;
        t[3]  = t1;
        t[4]  = t1+tv1;
        t[5]  = t[4]+maxG/SR;
        t[6]  = t1+tv1+t2/2-maxG/SR;
        t[7]  = t[6]+maxG/SR;
        t[8]  = t[7]+maxG/SR;
        t[10] = t1+tv1+t2;
        t[9]  = t[10]-maxG/SR;
        t[11] = t1+tv1+t2+tv2;
        t[12] = t[11]+maxG/SR;
        t[14] = t1+tv1+t2+tv2+t3;
        t[13] = t[14]-maxG/SR;

        Gnum = 15;
        num = (t[6]-tstep-t[5])/tstep;
    } 

    for(i=0; i<Gnum; i++)
    {
        t[i] = t[i]/1.0e6;    /* change us to s */
    }

    /* The algorithm below is, start from a pair of triangular-shaped
       diffusion gradient, search for a proper plateau to meet the
       b-value requirement;
    */
    for(j=1; j<num; j++)
    {
        if(PSD_OFF == dualspinecho_flag)
        {
            t[2] = (maxG/SR + tstep*j) / 1.0e6;
            t[5] = (avail_time - maxG/SR - tstep*j) / 1.0e6;
        }
        else
        {
            t[6]=t[5]+tstep*j/1.0e6;
            t[8]=t[9]-tstep*j/1.0e6;
        }

        b_curr = eco_mpg_calcbval(G, t, Gnum);

        if((b_curr > b_target) && (PSD_OFF == dualspinecho_flag))
        {
            switch(axis_flag)
            {
                case 0:   /* X axis */
                    pw_gxdla = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdl  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdld = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdra = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdrd = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    incdifx = sqrt(b_target/b_curr) * maxG;
                    a_gxdl = incdifx;
                    a_gxdr = incdifx;
                    break;
                case 1:   /* Y axis */
                    pw_gydla = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydl  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydld = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydra = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydrd = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    incdify = sqrt(b_target/b_curr) * maxG;
                    a_gydl = incdify;
                    a_gydr = incdify;
                    break;
                case 2:    /* Z axis */
                    pw_gzdla = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdl  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdld = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdra = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdrd = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    incdifz = sqrt(b_target/b_curr) * maxG;
                    a_gzdl = incdifz;
                    a_gzdr = incdifz;
                    break;
                default:
                    epic_error(use_ermes, "mpg_opt_gen() in eco_mpg.e failed, unknown axis index", 
                               EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," mpg_opt_gen()");
                    return FAILURE;
                    break;
            }
            break;
        }
        if((b_curr > b_target) && (PSD_ON == dualspinecho_flag))
        {
            switch(axis_flag)
            {
                case 0:   /* X axis */
                    pw_gxdl1a = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdl1  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdl1d = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr1a = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr1  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr1d = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;

                    pw_gxdl2a = ((int)(((t[8]-t[7])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdl2  = ((int)(((t[9]-t[8])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdl2d = ((int)(((t[10]-t[9])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr2a = ((int)(((t[12]-t[11])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr2  = ((int)(((t[13]-t[12])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gxdr2d = ((int)(((t[14]-t[13])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    
                    /* avoid ridiculous values */
                    if (pw_gxdl1 < GRAD_UPDATE_TIME) pw_gxdl1 = GRAD_UPDATE_TIME;
                    if (pw_gxdr1 < GRAD_UPDATE_TIME) pw_gxdr1 = GRAD_UPDATE_TIME;
                    if (pw_gxdl2 < GRAD_UPDATE_TIME) pw_gxdl2 = GRAD_UPDATE_TIME;
                    if (pw_gxdr2 < GRAD_UPDATE_TIME) pw_gxdr2 = GRAD_UPDATE_TIME;                   
                    
                    incdifx = sqrt(b_target/b_curr) * maxG;
                    a_gxdl1 = incdifx;
                    a_gxdr1 = -incdifx;
                    a_gxdl2 = incdifx;
                    a_gxdr2 = -incdifx;
                    break;
                case 1:   /* Y axis */
                    pw_gydl1a = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydl1  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydl1d = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr1a = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr1  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr1d = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;

                    pw_gydl2a = ((int)(((t[8]-t[7])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydl2  = ((int)(((t[9]-t[8])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydl2d = ((int)(((t[10]-t[9])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr2a = ((int)(((t[12]-t[11])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr2  = ((int)(((t[13]-t[12])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gydr2d = ((int)(((t[14]-t[13])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;   

                    /* avoid ridiculous values */
                    if (pw_gydl1 < GRAD_UPDATE_TIME) pw_gydl1 = GRAD_UPDATE_TIME;
                    if (pw_gydr1 < GRAD_UPDATE_TIME) pw_gydr1 = GRAD_UPDATE_TIME;
                    if (pw_gydl2 < GRAD_UPDATE_TIME) pw_gydl2 = GRAD_UPDATE_TIME;
                    if (pw_gydr2 < GRAD_UPDATE_TIME) pw_gydr2 = GRAD_UPDATE_TIME;
                    
                    incdify = sqrt(b_target/b_curr) * maxG;
                    a_gydl1 = incdify;
                    a_gydr1 = -incdify;
                    a_gydl2 = incdify;
                    a_gydr2 = -incdify;
                    break;
                case 2:    /* Z axis */
                    pw_gzdl1a = ((int)(((t[1]-t[0])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdl1  = ((int)(((t[2]-t[1])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdl1d = ((int)(((t[3]-t[2])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr1a = ((int)(((t[5]-t[4])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr1  = ((int)(((t[6]-t[5])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr1d = ((int)(((t[7]-t[6])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;

                    pw_gzdl2a = ((int)(((t[8]-t[7])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdl2  = ((int)(((t[9]-t[8])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdl2d = ((int)(((t[10]-t[9])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr2a = ((int)(((t[12]-t[11])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr2  = ((int)(((t[13]-t[12])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;
                    pw_gzdr2d = ((int)(((t[14]-t[13])*1.0e6 + 2.0) / GRAD_UPDATE_TIME)) * GRAD_UPDATE_TIME;    

                    /* avoid ridiculous values */
                    if (pw_gzdl1 < GRAD_UPDATE_TIME) pw_gzdl1 = GRAD_UPDATE_TIME;
                    if (pw_gzdr1 < GRAD_UPDATE_TIME) pw_gzdr1 = GRAD_UPDATE_TIME;
                    if (pw_gzdl2 < GRAD_UPDATE_TIME) pw_gzdl2 = GRAD_UPDATE_TIME;
                    if (pw_gzdr2 < GRAD_UPDATE_TIME) pw_gzdr2 = GRAD_UPDATE_TIME;
                    
                    incdifz = sqrt(b_target/b_curr) * maxG;
                    a_gzdl1 = incdifz;
                    a_gzdr1 = -incdifz;
                    a_gzdl2 = incdifz;
                    a_gzdr2 = -incdifz;
                    break;
                default:
                    epic_error(use_ermes, "mpg_opt_gen() in eco_mpg.e failed, unknown axis index", 
                               EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," mpg_opt_gen()");
                    return FAILURE;
                    break;                    
            }
            break;
        }
        /* b_curr < b_target should not happen. If it happens,does not change anything */ 
    }
    
    return SUCCESS;
} /* end of mpg_opt_gen() */

/* this function performs mpg_opt_gen() for
   each axis 
   
   Inputs:
     tmp_axis_flag:  axis index, 0=X, 1=Y, 2=Z;
     tmp_Delta_time: time between central 2 diff;
     tmp_MaxAmp:     max grad amp to use for diff;
     tmp_bvaltemp:   targeted b value; */
STATUS mpg_opt_timing(int tmp_axis_flag,
                      int tmp_Delta_time,
                      float tmp_MaxAmp,
                      float tmp_bvaltemp)
{
    /* Params below correspond to the required params
       in function mpg_opt_gen(); */
    int tmp_avail_time = 0;
    int tmp_time_180   = 0;
    int tmp_t1         = 0;
    int tmp_tv1        = 0;
    int tmp_t2         = 0;
    int tmp_tv2        = 0;
    int tmp_t3         = 0;
    float tmp_maxG     = 0.0;
    float tmp_SR       = 0.0;
    float tmp_target_b = 0.0;   
    
    switch(tmp_axis_flag)
    {
        case 0: /* X axis */
            tmp_avail_time = pw_gxdla + pw_gxdl + pw_gxdld + 
                             tmp_Delta_time + 
                             pw_gxdra + pw_gxdr + pw_gxdrd;    
            tmp_time_180   = tmp_Delta_time;
            tmp_t1         = pw_gxdl1a + pw_gxdl1 + pw_gxdl1d;
            if (rfov_flag)
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso + pw_gyex1_tot - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;                
            }
            else
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;
            }
            tmp_t2         = pw_gxdr1a + pw_gxdr1 + pw_gxdr1d + 
                             pw_gxdl2a + pw_gxdl2 + pw_gxdl2d;
            tmp_tv2        = pw_gzrf2rightl1a + pw_gzrf2rightl1 + pw_gzrf2rightl1d + 
                             pw_gzrf2right + 
                             pw_gzrf2rightr1a + pw_gzrf2rightr1 + pw_gzrf2rightr1d - 
                             mpg_opt_margin;
            tmp_t3         = pw_gxdr2a + pw_gxdr2 + pw_gxdr2d;
            tmp_maxG       = tmp_MaxAmp / mpg_opt_derate;
            tmp_SR         = tmp_maxG / (float)pw_gxdla;
            tmp_target_b   = tmp_bvaltemp;
            break;
        case 1: /* Y axis */
            tmp_avail_time = pw_gydla + pw_gydl + pw_gydld + 
                             tmp_Delta_time + 
                             pw_gydra + pw_gydr + pw_gydrd;    
            tmp_time_180   = tmp_Delta_time;
            tmp_t1         = pw_gydl1a + pw_gydl1 + pw_gydl1d;
            if (rfov_flag)
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso + pw_gyex1_tot - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;            
            }
            else
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;
            }
            tmp_t2         = pw_gydr1a + pw_gydr1 + pw_gydr1d + 
                             pw_gydl2a + pw_gydl2 + pw_gydl2d;
            tmp_tv2        = pw_gzrf2rightl1a + pw_gzrf2rightl1 + pw_gzrf2rightl1d + 
                             pw_gzrf2right + 
                             pw_gzrf2rightr1a + pw_gzrf2rightr1 + pw_gzrf2rightr1d - 
                             mpg_opt_margin;
            tmp_t3         = pw_gydr2a + pw_gydr2 + pw_gydr2d;
            tmp_maxG       = tmp_MaxAmp / mpg_opt_derate;
            tmp_SR         = tmp_maxG / (float)pw_gydla;
            tmp_target_b   = tmp_bvaltemp;
            break; 
        case 2: /* Z axis */
            tmp_avail_time = pw_gzdla + pw_gzdl + pw_gzdld + 
                             tmp_Delta_time + 
                             pw_gzdra + pw_gzdr + pw_gzdrd;    
            tmp_time_180   = tmp_Delta_time;
            tmp_t1         = pw_gzdl1a + pw_gzdl1 + pw_gzdl1d;
            if (rfov_flag)
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso + pw_gyex1_tot - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;
            }
            else
            {
                tmp_tv1        = pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d +
                                 pw_gzrf2left +
                                 pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d + 
                                 fabs(rfExIso - tdaqhxa - pw_gx1a - pw_gx1 - pw_gx1d) -
                                 mpg_opt_margin;            
            }
            tmp_t2         = pw_gzdr1a + pw_gzdr1 + pw_gzdr1d + 
                             pw_gzdl2a + pw_gzdl2 + pw_gzdl2d;
            tmp_tv2        = pw_gzrf2rightl1a + pw_gzrf2rightl1 + pw_gzrf2rightl1d + 
                             pw_gzrf2right + 
                             pw_gzrf2rightr1a + pw_gzrf2rightr1 + pw_gzrf2rightr1d - 
                             mpg_opt_margin;
            tmp_t3         = pw_gzdr2a + pw_gzdr2 + pw_gzdr2d;
            tmp_maxG       = tmp_MaxAmp / mpg_opt_derate;
            tmp_SR         = tmp_maxG / (float)pw_gzdla;
            tmp_target_b   = tmp_bvaltemp;
            break;
        default:
            epic_error(use_ermes, "mpg_opt_timing() in eco_mpg.e failed, unknown axis index", 
                       EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," mpg_opt_timing()");
            return FAILURE;
            break;            
    }  
    
    if ( FAILURE == mpg_opt_gen(tmp_avail_time, 
                                tmp_time_180, 
                                tmp_t1, 
                                tmp_tv1, 
                                tmp_t2, 
                                tmp_tv2, 
                                tmp_t3, 
                                tmp_maxG, 
                                tmp_SR, 
                                tmp_target_b, 
                                tmp_axis_flag) )
        return FAILURE;
    
    return SUCCESS;
} /* end of mpg_opt_timing() */ 

/* This function optimizes the diffusion
   gradient plateau duration for DSE case;
   Inputs:
      b_target:    in rad*s/mm2, target b-value;
      pw_d1_guess: in us, initial guess of the 
                   first diff-grad plateau duration;
      pw_ramp:     in us, ramp time of each diff-grad;
      pw_delta:    in us, delay between the central two
                   diffusion gradients;      
      gmax:        in Gauss/cm, diff-grad amp;
   Outputs:
      pw_d1:       in us, duration of 1st/4th diff-grad plateau;
      pw_d2:       in us, duration of 2nd/3rd diff-grad plateau;
*/   
STATUS dse_opt_timing(float b_target, 
                      int   pw_d1_guess, 
                      int   pw_ramp,
                      int   pw_delta,                      
                      float gmax)                      
{          
    /* Initialize */
    int   cnt = 0;
    int   find_max = PSD_ON;
    int   cnt_limit = 100;
    float b_error = 1000000.0;
    float b_curr = 0.0;
    float pw_delay = 0.0; /* end of 4th diff to TE */
    float pw_shift = 0.0;
    float pw_max = 0.0;
    float pw_min = 0.0;
    float t[20];
    float G[20];
    float b_tol_abs = 0.0;
    int   i = 0;   
    if (pw_delta < 1e-6)
    {
        pw_delta = GRAD_UPDATE_TIME;
    }
    b_curr = b_target;
    pw_delay = (float)(tdaqhxa + pw_gx1a + pw_gx1 + pw_gx1d);
    pw_d1 = (float)pw_d1_guess;
    pw_d2 = pw_d1 + pw_delay - (float)pw_delta/2.0;
    if (dse_enh_flag)
    {
        pw_shift = pw_delay - (float)rfExIso;
        if (rfov_flag)
        {
            pw_shift = pw_delay - (float)rfExIso - pw_gyex1_tot;
        }
    }
    else
    {
        pw_shift = 0.0;
    }
    pw_max = (float)pw_d1_guess;
    
    /* Search for proper diffusion plateau */
    b_tol_abs = b_tol * b_target;
    while ( (b_error>b_tol_abs) && (cnt<cnt_limit) && (pw_max-pw_min>4.0) )
    {
        /* Recalc 1st/4th diff plateau */
        if (b_curr < b_target)
        {
            if (PSD_ON == find_max)
            {
                /* Search for initial max */
                pw_max = 2 * pw_max;
                pw_d1 = pw_max;
            }
            else
            {
                /* Update current min */
                pw_min = pw_d1;
                /* Update pw_d1 */
                pw_d1 = (pw_max+pw_min)/2;
            }
        }
        else if (b_curr > b_target)
        {
            /* Terminate search for initial max */
            find_max = PSD_OFF;
            /* Update current max */
            pw_max = pw_d1;
            /* Update pw_d1 */
            pw_d1 = (pw_max+pw_min)/2; 
        }
        
        /* Recalc 2nd/3rd diff plateau, based
           on the fact that a Spin Echo is
           required; */
        pw_d2 = pw_d1 + pw_delay - (float)pw_delta/2.0;
        
        /* Generate time line */
        t[0]  = 0.0;
        t[1]  = t[0]  + (float)pw_ramp;
        t[2]  = t[1]  + pw_d1;
        t[3]  = t[2]  + (float)pw_ramp;
        t[4]  = t[3]  + pw_shift + (float)(pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot);
        t[5]  = t[4]  + (float)pw_ramp;
        t[6]  = t[5]  + pw_d2;
        t[7]  = t[6]  + (float)pw_ramp;
        t[8]  = t[7]  + (float)pw_delta;
        t[9]  = t[8]  + (float)pw_ramp;
        t[10] = t[9]  + pw_d2;
        t[11] = t[10] + (float)pw_ramp;
        t[12] = t[11] + (float)(pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot);
        t[13] = t[12] + (float)pw_ramp;
        t[14] = t[13] + pw_d1;
        t[15] = t[14] + (float)pw_ramp;   

        /* Generate grad wave */
        G[0]  = 0.0;
        G[1]  = gmax;
        G[2]  = gmax;
        G[3]  = 0.0;
        G[4]  = 0.0;
        G[5]  = gmax; /* flipped after 180 */
        G[6]  = gmax; /* flipped after 180 */
        G[7]  = 0.0;
        G[8]  = 0.0;
        G[9]  = -gmax; /* flipped after 180 */
        G[10] = -gmax; /* flipped after 180 */       
        G[11] = 0.0;
        G[12] = 0.0;
        G[13] = -gmax; 
        G[14] = -gmax;
        G[15] = 0.0;
        int Gnum = 16;

        /* us to s */
        for(i=0; i<Gnum; i++)
        {
            t[i] = t[i]/1.0e6;
        }        
        
        /* Calc current b-value */
        b_curr = eco_mpg_calcbval(G, t, Gnum);
        
        /* Calc current error in b */
        b_error = fabs(b_curr - b_target);  
        /* Ensure a b_curr >= b_target, so that
           some margin is left for verify_bvalue() */
        if (b_curr < b_target) b_error = b_tol_abs + 1.0;        
        
        /* Increment */
        cnt = cnt + 1;         
        
    } /* end While */  

    /* In case of no converge */
    if (cnt >= cnt_limit)
    {
        epic_error(use_ermes,"Search for diffusion duration failed",
                   EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"dse_opt_timing()");
        return FAILURE;        
    }
        
    return SUCCESS;    
        
} /* end dse_opt_timing() */

/* calculate b-value given the corner-points;
   Inputs:
       g: vector of grad amp, in Gauss/cm;
       t: vector of time pts, in s;
       n: number of valid pts in the vector; */
float eco_mpg_calcbval(float *g, float *t, int n)
{
    float A = 0.0; /* area */
    float B = 0.0; /* calced b-value */
    float C = 0.0; /* a tmp variable */
    float a = 0.0; /* slope */
    float b = 0.0; /* intercept */
    int   i = 0;
    
    for(i=0; i<n; i++)
    {
        if(0 == i)
        {
            A = 0;
            B = 0;
        }
        else
        {
            a = (g[i] - g[i-1]) / (t[i] - t[i-1]); 
            b = g[i-1]-a*t[i-1]; 
            C = A - 0.5*a*t[i-1]*t[i-1]-b*t[i-1];

            B = B + (
                        ( 
                            (1/20.0)*a*a*t[i]*t[i]*t[i]*t[i]*t[i] + 
                            (1/4.0)*a*b*t[i]*t[i]*t[i]*t[i] +
                            (1/3.0)*b*b*t[i]*t[i]*t[i] + 
                            (1/3.0)*a*C*t[i]*t[i]*t[i] + 
                            b*C*t[i]*t[i] +
                            C*C*t[i] 
                        ) -
                        (  
                            (1/20.0)*a*a*t[i-1]*t[i-1]*t[i-1]*t[i-1]*t[i-1] +
                            (1/4.0)*a*b*t[i-1]*t[i-1]*t[i-1]*t[i-1] +
                            (1/3.0)*b*b*t[i-1]*t[i-1]*t[i-1] +
                            (1/3.0)*a*C*t[i-1]*t[i-1]*t[i-1] +
                            b*C*t[i-1]*t[i-1] +
                            C*C*t[i-1]                                                                
                        ) 
                    ) * 
                    (TWOPI_GAMMA * TWOPI_GAMMA / 100.0);  
            A = A + ( (g[i] + g[i-1]) / 2 ) * (t[i]-t[i-1]);
        }            
    }
    
    return B;
}
  
/*** end of host ***/


/***********************/
/*** Inline Contents ***/
/***********************/
@pg left_xdiff_dse
if(dse_enh_flag)
{
    if(ss_rf1 == PSD_ON)
    {
#if defined(IPG_TGT) || defined(MGD_TGT)
        tempx = RDN_GRD(pend(&gzrf1, "gzrf1", gzrf1.ninsts-1) + pw_gxdl1a +pw_wgxdl1);
#elif defined(HOST_TGT)
        tempx = RDN_GRD(pend(&gzrf1d, "gzrf1d", gzrf1.ninsts-1) + pw_gxdl1a + pw_wgxdl1);
#endif
    }
    else if (rfov_flag)
    {
        tempx = RDN_GRD(pendall(&gyex1, gyex1.ninsts-1) + pw_gxdl1a + pw_wgxdl1);
    }
    else
    {
        tempx = RDN_GRD(pendall(&gzrf1, gzrf1.ninsts-1) + pw_gxdl1a + pw_wgxdl1);
    }
}

@pg left_ydiff_dse
if(dse_enh_flag)
{
    if(ss_rf1 == PSD_ON)
    {
#if defined(IPG_TGT) || defined(MGD_TGT)
        tempy = RDN_GRD(pend(&gzrf1, "gzrf1", gzrf1.ninsts-1) + pw_gydl1a + pw_wgydl1);
#elif defined(HOST_TGT)
        tempy = RDN_GRD(pend(&gzrf1d, "gzrf1d", gzrf1.ninsts-1) + pw_gydl1a + pw_wgydl1);
#endif
    }
    else if (rfov_flag)
    {
        tempy = RDN_GRD(pendall(&gyex1, gyex1.ninsts-1) + pw_gydl1a + pw_wgydl1);
    }    
    else
    {
        tempy = RDN_GRD(pendall(&gzrf1, gzrf1.ninsts-1) + pw_gydl1a +pw_wgydl1);
    }
}

@pg left_zdiff_dse
if(dse_enh_flag)
{
    if(ss_rf1 == PSD_ON)
    {
#if defined(IPG_TGT) || defined(MGD_TGT)
        tempz = RDN_GRD(pend(&gzrf1, "gzrf1", gzrf1.ninsts-1) + pw_gzdl1a +pw_wgzdl1);
#elif defined(HOST_TGT)
        tempz = RDN_GRD(pend(&gzrf1d, "gzrf1d", gzrf1.ninsts-1) + pw_gzdl1a + pw_wgzdl1);
#endif
    }
    else if (rfov_flag)
    {
        tempz = RDN_GRD(pendall(&gyex1, gyex1.ninsts-1) + pw_gzdl1a + pw_wgzdl1);
    }    
    else
    {
        tempz = RDN_GRD(pendall(&gzrf1, gzrf1.ninsts-1) + pw_gzdl1a + pw_wgzdl1);
    }
}
