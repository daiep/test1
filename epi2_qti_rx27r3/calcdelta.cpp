/*@Start***********************************************************/
/* GEMSBG C source File
 * Copyright (C) 1996 The General Electric Company
 *
 *	File Name:  calcdelta.c
 *	Developer:  Bryan J. Mock, Manoj Saranathan
 *
 * $Source: calc_little_delta.c $
 * $Revision: 1.0 $  $Date: 5/11/98 18:04:22 $
 */

/*@Synopsis 

  Given a user prescribed B-value, this routine calculates the delta, or 
  duration of the diffusion lobes, by solving the Stejskal/Tanner 
  diffusion equation.  This is a cubic equation and the solution below is 
  modeled after the solution formed in Numerical Recipes in C, pg 184, 
  2nd Edition.

*/     

/*@Description

This routine calculates the total pulse width of the diffusion 
gradients required to provide the user prescribed B-value IN THE ABSENCE OF 
ANY IMAGING GRADIENTS.  This provides a somewhat "optimal" pulse width that 
will minimize the TE for a given B-value by using the maximum gradient 
strength for the system in question.  Then, when the imaging gradients are 
taken into account, the amplitude will be derated accordingly.  Note: since 
this routine uses the Stejskal/Tanner Equation, all trapezoid pulses are 
treated as "equivalent" rectangles for the calcs below.   

Type and Call:
_____________

STATUS
calcdelta(opdflag,*pw_diff,*pw_difr,pw_sep,bval,targetAmp)

Passed Parameters:
__________________
(I: for input parameter, O: for output parameter)
(I)     INT opdflag:      Optimized DW Flag (1 = do it, 0 = use LX2 values)
(O)     INT *pw_diff:     The total diffusion pulse width for the given bvalue
                          and target amp of the pulse
(O)     INT *pw_diffr:     The ramp time for the diffusion lobe
(I)     INT pw_sep:       The total separation between diffusion lobes 
                          (rf2+left & right crusher widths)
(I)	INT bval:         The user prescribed b-value. 
(I)	DOUBLE targetAmp: The potential max amp for the diffusion pulses



**@End***********************************************************************/

/* *************************************************************
	Author	       	Date		Comments
________________________________________________________________
        Bryan Mock      05/15/98        Created.

        Bryan Mock      09/23/99        Added ramp times into
                                        cubic equation.

*****************************************************************************/

#include <stdio.h>
#include <math.h>
#include <support_decl.h>
#include "calcdelta.h"

#define TWOPI_GAM 26748.0  /* 2*PI*GAMMA */
#define DOUBLE double

STATUS 
#ifdef __STDC__
calcdelta( INT opdflag,
           INT *pw_diff,
           INT *pw_diffr,
           INT pw_sep,
           INT bval,
           DOUBLE targetAmp)
#else /* !__STDC__ */
calcdelta( opdflag,pw_diff, pw_diffr, pw_sep, bval, targetAmp)
    INT opdflag;
    INT *pw_diff;
    INT *pw_diffr;
    INT pw_sep;
    INT bval;
    DOUBLE targetAmp;
#endif /* __STDC__ */
{
    INT i,j;
    DOUBLE Q,R,Rsq,Qcub,theta;
    DOUBLE sep, ramp;
    FLOAT temp;
    DOUBLE a,b,c;
    FLOAT BETA;
    FLOAT root[3];

    /* ******************************************************
       Solving the equation b = (GAM)^2*g^2*(d^2*(D - d/3.0)+r^3/30 - d*r^2/6)
       for "d" which results in a cubic equation (the r^ are teh ramp times to
       account for the trapezoid diffusion lobes):

       d^3 - 3D*d^2 + dr^2/2B -(r^3/(10*B) -3b/BETA) = 0 
       where BETA = (GAM*g)^2 and D = (pw_sep+d).  Thus, the equ. becomes..

       d^3 + (3/2*pw_sep)*d^2 - (r^2/4)*d - (3*b/2BETA - r^3/20) = 0
  
       **************************************************** */ 

    sep = (DOUBLE)(pw_sep/1.0e6);        /* cast 180/crusher time in seconds */
    ramp = (DOUBLE)(*pw_diffr/1.0e6);    /* diffusion ramps in seconds */

    BETA = TWOPI_GAM*TWOPI_GAM*(targetAmp/10.0)*(targetAmp/10.0);
    a = (3.0/2)*sep;     /* cast 180/crusher time in seconds */
    b = -1.0*(ramp)*(ramp)/4;
    c = ((-3.0/2)*bval)/BETA + ((ramp*ramp*ramp)/20.0);

    Q = (DOUBLE)(a*a-3.0*b)/9.0;
    R = (DOUBLE)((2.0*(a*a*a)- 9.0*a*b + 27*c)/54.0);
    Rsq = (DOUBLE)(R*R);  
    Qcub = (DOUBLE)(Q*Q*Q);
   
    *pw_diff =0;

    if (Rsq < Qcub)
    {
        theta = acos(R/sqrt(Qcub));
        /* cast roots in terms of us */
        root[0] = 1e6*(-2.0*sqrt(Q)*cos(theta/3.0) - a/3.0);
        root[1] = 1e6*(-2.0*sqrt(Q)*cos((theta+2.0*M_PI)/3.0) - a/3.0);
        root[2] = 1e6*(-2.0*sqrt(Q)*cos((theta-2.0*M_PI)/3.0) - a/3.0);
  
        /* order roots and take the smallest - non negative value */
        for (i=0; i<=2; i++)
        {
            temp = root[i];
            for (j=i+1; j<=2; j++)
            {
                if (root[j] < temp)
                {
                    root[i] = root[j];
                    root[j] = temp;
                    temp = root[i];
                }
            }
        }
      
        /* take smallest that is larger than GRAD_UPDATE_TIME */
        if (root[0] > GRAD_UPDATE_TIME)
            *pw_diff = (INT)root[0];
        else if (root[1] > GRAD_UPDATE_TIME)
            *pw_diff = (INT)root[1];
        else if (root[2] > GRAD_UPDATE_TIME)
            *pw_diff = (INT)root[2];

    }
    else
    {
        INT sign;
        DOUBLE A,B;
   
        /* check sign of R */
        if (R >= 0) sign = 1.0;
        else        sign = -1.0;
 
        A = -sign*cbrt(fabs(R) + sqrt(Rsq-Qcub));
        B = Q/A;

        /* This is the only real root - the other two are complex */
        root[0] = 1e6*(FLOAT)(A + B - a/3.0);  
 
        if(root[0] >= GRAD_UPDATE_TIME)
            *pw_diff = (INT)root[0];

    }

    /* Put *pw_diff on GRAD_UPDATE boundaries */
    *pw_diff = RUP_GRD(*pw_diff);

    /* final check - if something doesn't make sense or if feature not */
    /* activated by user, set the pulse width back to hardcoded value  */
    /* used in LX2 (pre-NO release) */
    if((*pw_diff < GRAD_UPDATE_TIME) || (opdflag == PSD_OFF))
    {
      
        /* BJM: the extra 1.2 ms is necessary since the attack */
        /*      is subtracted in epi2.e */
        *pw_diff = 31000 + 1200; 
        *pw_diffr = 1200;
    }
    return SUCCESS;
}






