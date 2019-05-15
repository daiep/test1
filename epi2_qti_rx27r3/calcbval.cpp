/*
 * GE Medical Systems
 * Copyright (C) 1998 The General Electric Company
 * 
 * $Source: %M% $
 * $Revision: %I% $  $Date: %G% %U% $
 * 
 * This file will use gradient and time cornerpoint vectors, and timing parameters
 * to calculate the bvalue on each axis of a given sequence. 
 *
 * Assumptions: Instantaneous 180s
 *              Piecewise linear gradients
 * 
 * Language : ANSI C
 * Author   : Charles Michelich
 * Date     : 2000/11/17
 */
/* do not edit anything above this line */

/*
 Version      Date      Author      Description
------------------------------------------------------------------------------
 1.0        2000/11/17  CRM         Initial version.
 1.1        2000/11/21  CRM         Fixed bug in cumTrapIntegration
                                    Added multinuclear support
 1.2        2000/11/22  CRM         Changed trapIntegrationSquared to use
                                    double precision floats for calculations
 1.3        2000/12/07  CRM         Changed GAM to gam since it is a variable not #define
 1.4SV      2013/07/31  WJZ         Modified the code so that it works for gradient with
                                    long ramp time (arbitrary gradient shape);
*/

/* System header files */
#include <float.h>
#include <stdio.h>

/* Local header files */
#include "stddef_ep.h"
#include "calcbval.h"
#include "psdutil.h"

/* Defines */
#ifndef PI
#define PI 3.14159265358979323846
#endif /*PI*/

#ifdef UNDEF
#define DUMP_WAVEFORMS 
#endif

/* SVBranch: HCSDM00259119
 * CV defined in eco_mpg.e
 * to switch between the algorithms
 * for b-value calc  */
extern int bval_arbitrary_flag;

/*
 * Private interface
 */
static STATUS cumTrapIntegration(FLOAT *area1, FLOAT *area2, const FLOAT *x,const FLOAT *fx, const FLOAT *fx2, const INT *flip, const INT npts); /* Trapezoidal integration of fx */
static STATUS trapIntegrationSquared(DOUBLE *area, const FLOAT *x, const FLOAT *fx, const FLOAT *fx2, FLOAT *bval_per_point, const INT npts); /*Trapezodal integration of fx^2 */
/*  SVBranch: HCSDM00259119  - Trapezodal integration of fx^2, for arbitrary gradient shape */
static STATUS trapIntegrationSquared2(DOUBLE *area, const FLOAT *x, const FLOAT *fa, const FLOAT *fa2, FLOAT *bval_per_point, const INT npts, const FLOAT *fx, const FLOAT *fx2, const INT *flip); 

/** CODE **/

/* 
 * calcbvalue
 * 
 * Type: Public Function
 *
 * Description:
 * This file will use gradient and time cornerpoint vectors, and timing parameters
 * to calculate the bvalue on each axis of a given sequence.  The vectors returned by
 * getCornerPoint() of pulsegen() on the host are in an appropriate format.
 *
 * Prototype:
 * STATUS
 * calcbvalue( FLOAT *bvalue,
 *             const FLOAT rf_excite_location,
 *             const FLOAT *rf_180_location,
 *             const INT num_180s,
 *             const FLOAT te,
 *             const FLOAT *time,
 *             FLOAT * const grad[3],
 *             const INT num_points,
 *             const FLOAT gam );
 *
 * Outputs: 
 *   FLOAT *bvalue,                  => b-value for gradient waveform (sec/mm^2)
 *   STATUS (returned)               => SUCCESS or FAILURE
 * 
 * Inputs:
 *   const FLOAT rf_excite_location, => Location of isocenter of excitation pulse (usec)
 *   const FLOAT *rf_180_location,   => Location of isocenter of 180 pulses (usec) pulses after
 *                                      excitation (NULL pointer for none)
 *   const INT num_180s,             => Number of 180s
 *   const FLOAT te,                 => Echo time (usec)
 *   const FLOAT *time,              => Vectors of times for each gradient waveform (all the same) (usec)
 *   const FLOAT *grad_1,            => Vector of gradient waveforms (G/cm)
 *   const FLOAT *grad_2,            => Vector of gradient waveforms (G/cm)
 *   const INT num_points,           => Number of time points in gradient and time vectors 
 *   const FLOAT gam)                => Gyromagnetic ratio (Hz/Gauss)
 *
 * Potential strange behavior:(1) Could add a very short linear segment due to round off errors.  
 *                                No divisions by this length, so it should be safe. 
 *                            (2) bvalue is scaled by 10^20 at the end for unit conversion.  
 *                                DOUBLEs used for calculatation to avoid roundoff errors
 *
 * Assumptions: Instantaneous 180s
 *              Piecewise linear gradients
 */
STATUS
calcbvalue( FLOAT *bvalue,
            const FLOAT rf_excite_location,
            const FLOAT *rf_180_location,
            const INT num_180s,
            const FLOAT te,
            const FLOAT *time,
            const FLOAT *grad_1,
            const FLOAT *grad_2,
            const INT num_points,
            const FLOAT gam)
{
    /* --- Declare variables --- */
    INT n180,t;                  /* Counters */
    STATUS status;                        /* Function return status */
    const CHAR funcName[] = "calcbvalue"; /*  Name of function for debug statements */
    
    FLOAT bval_time[num_points+num_180s+1]; /* Vector of times for area of waveform to calculate b-value  */
    /* note: there are two bval-grad vectors now so the cross terms can be easily computed */
    FLOAT bval_grad_1[num_points+num_180s+1]; /* Vector of gradient waveform sections to calculate b-value with */
    FLOAT bval_grad_2[num_points+num_180s+1]; /* Vector of gradient waveform sections to calculate b-value with */
    FLOAT bval_point[num_points+num_180s+1]; /* Vector of b-values at each point in the sequence */
    INT bval_sign[num_points+num_180s];     /* Sign of each linear segment of gradient (for flipping at 180s) */
    INT bval_n;                             /* Counter for index to bal_ vectors (next open location) */
    /* note: there are two kspace vectors now so the cross terms can be easily computed */
    FLOAT ktraj1[num_points+num_180s+1];     /* Temporary vector of kspace trajectory */
    FLOAT ktraj2[num_points+num_180s+1];     /* Temporary vector of kspace trajectory */
    DOUBLE bvalue_temp;                     /* Double precision bvalue for calculations */
   
#ifdef DUMP_WAVEFORMS
    FILE *fpout;                            /* file pointer for dumping waverforms */
#endif /* DUMP_WAVEFORMS */

    /* --- Check that all rf pulse locations exist and are in order --- */
    if(rf_excite_location >= time[num_points-1]){
        fprintf(stderr,"%s: Excitation time specified is longer than gradient\n",funcName);
        return FAILURE;
    }
    
    if(num_180s > 0){
        /* Check that 180s are in order */
        for(n180=1;n180 < num_180s;n180++){
            if(rf_180_location[n180]<=rf_180_location[n180-1]){
                fprintf(stderr,"%s: Location of 180s are not in order\n",funcName);
                return FAILURE;
            }
        }
        /* Check that first 180 is after excitation */
        if(rf_180_location[0] <= rf_excite_location ){
            fprintf(stderr,"%s: First 180 is before excitation pulse\n",funcName);
            return FAILURE;
        }
        /* Check that last 180 is before end */
        if(rf_180_location[num_180s-1] > (rf_excite_location+ te)){
            fprintf(stderr,"%s: Last 180 is after pulse sequence\n",funcName);
            return FAILURE;
        }
        /* Check that TE is before the end of the sequence */
        if(rf_excite_location + te > time[num_points-1]){
             fprintf(stderr,"%s: TE is after pulse sequence\n",funcName);
             return FAILURE;
        }
    }

    /* --- Generate waveforms to use to calculate b-value ---  */
    /* Initialize a counter for the bval_ arrays */
    bval_n = 0;

    /* Find the first time point at or after the excitation pulse */
    for(t=0;(time[t] < rf_excite_location); t++);

    /* Set start time */
    bval_time[0] = rf_excite_location;

    /* Set gradients */
    if (floatsAlmostEqualEpsilons(rf_excite_location, time[t], 2))
    { /* Start point is on a corner point */
        /* Copy current values */
        bval_grad_1[bval_n] = grad_1[t];
        bval_grad_2[bval_n] = grad_2[t];

        /* Increment to next element in original gradients */
        t++;
    }
    else
    { /* Start point is not on a corner point */

        /* Linear interpolate back for the first point (use Lagrange Polynomial form)
           y = (x-x1)/(x0-x1)*y0 + (x-x0)/(x1-x0)*y1
           y = ((x-x0)*y1 - (x-x1)*y0)/(x1-x0)
        */
        bval_grad_1[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_1[t-1] - 
                             (bval_time[bval_n]-time[t])*grad_1[t])/(time[t]-time[t-1]);

        bval_grad_2[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_2[t-1] - 
                             (bval_time[bval_n]-time[t])*grad_2[t])/(time[t]-time[t-1]);

        /* Do NOT increment t, because we still need to copy this point */
    }
    
    /* Increment bval_n counter */
    bval_n++;

    /* Copy arrays, insert points interpolating at 180 flip points, & fill flip array */
    for(n180=0;n180 < num_180s;n180++)
    {
        /* Look for 180s and copy points */
        while(time[t] <= rf_180_location[n180]){
            
            /* While looking for odd 180s, don't flip  */
            if(n180%2 == 0){
                bval_sign[bval_n-1] = 1; /* no flip */
            }
            else{
                bval_sign[bval_n-1] = -1; /* flip */
            }
            
            /* Copy time and increment counters */
            bval_grad_1[bval_n] = grad_1[t];
            bval_grad_2[bval_n] = grad_2[t];

            bval_time[bval_n] = time[t];
            ++t;
            ++bval_n;
        } /* End look for 180 */
        
        /* Found a 180. */
        /* Interpolate a new value at the center */
        bval_time[bval_n] = rf_180_location[n180];
        
        /* If the corner point does not lay exactly on the 180, interpolate a new point */
        if(!floatsAlmostEqualEpsilons(time[t-1], rf_180_location[n180], 2))
        { /* If the 180 was on a cornerpoint, we already copied it so check t-1 */  
            
            /* Interpolate a new value */    
            bval_grad_1[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_1[t-1] - 
                                 (bval_time[bval_n]-time[t])*grad_1[t])/(time[t]-time[t-1]);

            /* Interpolate a new value */    
            bval_grad_2[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_2[t-1] - 
                                 (bval_time[bval_n]-time[t])*grad_2[t])/(time[t]-time[t-1]);

            /* Fill flip array for segment before 180 */
            if(n180%2 == 0){
                bval_sign[bval_n-1] = 1; /* no flip */
            }
            else{
                bval_sign[bval_n-1] = -1; /* flip */
            }
            
            /* Increment counter to bval_ arrays */
            ++bval_n;
        } /* End interpolate point at 180 */
    } /* End increment through 180s */

    /* Copy the remainder of the waveform up to the echo time */
    while(time[t] < rf_excite_location + te){
        
        /* If an odd number of 180s, flip*/
        if(num_180s%2 == 0){
            bval_sign[bval_n-1] = 1; /* no flip */
        }
        else
        {
            bval_sign[bval_n-1] = -1; /* flip */
        }
                        
        /* Copy time and increment counters */
        bval_grad_1[bval_n] = grad_1[t];
        bval_grad_2[bval_n] = grad_2[t];
 
       bval_time[bval_n] = time[t];
        ++t;
        ++bval_n;
    }

    /* Found the end */
    /* Interpolate an ending value */
    bval_time[bval_n] = rf_excite_location + te;
        
    if(floatsAlmostEqualEpsilons(time[t], rf_excite_location + te, 2))
    { /* End point is at a corner point */
        bval_grad_1[bval_n] = grad_1[t]; 
        bval_grad_2[bval_n] = grad_2[t];
    }
    else
    { /* End point is not at a corner point, interpolate */
        bval_grad_1[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_1[t-1] - 
                                        (bval_time[bval_n]-time[t])*grad_1[t])/(time[t]-time[t-1]);

        bval_grad_2[bval_n] = ((bval_time[bval_n]-time[t-1])*grad_2[t-1] - 
                                        (bval_time[bval_n]-time[t])*grad_2[t])/(time[t]-time[t-1]);
    }
    /* Set flip for final segment */
    if(n180%2 == 0){
        bval_sign[bval_n-1] = 1; /* no flip */
    }
    else{
        bval_sign[bval_n-1] = -1; /* flip */
    }
   
    ++bval_n; /* Increment counter - (Equals the number of elements in the array) */

    /* --- Calculate b-values from waveforms --- */
    /* Loop through each direction */
        
    /* Calculate k-space trajectories */
    /* NOTE: ktraj needs to be scaled by gamma/(2pi) */ 
    /* units: (Hz/Gauss)*usec*Gauss/cm = 10^-4/meter for gamma/(2pi) in Hz/Gauss */
    status = cumTrapIntegration(ktraj1,ktraj2,bval_time,bval_grad_1,bval_grad_2,bval_sign,bval_n);
    if((status == FAILURE) || (status == SKIP)){
        fprintf(stderr,"calcbvalue: k-space trajectory generation failed!\n");
        return FAILURE;
    }

    /* Calculate b-value */
    /* NOTE: ktraj needs to be scaled by 2*pi (b = integral (2*pi*ktraj)^2 dt */
    /* units: (10^-4/m)^2*usec = 10^-20 sec/mm^2 */
    if (bval_arbitrary_flag) /* SVBranch: HCSDM00259119 -  for eco mpg, calculate b-value with arbitrary grad shape  */
        status = trapIntegrationSquared2(&bvalue_temp,bval_time,ktraj1,ktraj2,bval_point,bval_n,bval_grad_1, bval_grad_2,bval_sign);
    else /* original case */
        status = trapIntegrationSquared(&bvalue_temp,bval_time,ktraj1,ktraj2,bval_point,bval_n); 
    if((status == FAILURE) || (status == SKIP)){
        fprintf(stderr,"calcbvalue: b-value calc from k-space trajectories failed!\n");
        return FAILURE;
    }    
    
    /* Convert units of b-value to sec/mm^2 and cast back as float*/
    *bvalue = (FLOAT)(4.0*PI*PI*gam*gam*1.0e-20*bvalue_temp);
 
#ifdef DUMP_WAVEFORMS

     if ((fpout = fopen("bvalue_data.txt", "a+")) == NULL) { 
          fprintf(stderr,"Dang! Cant open file for writing\n");
         return FAILURE;
     }

    /* Print time, grads, ktrajs, and flip vectors if in debug mode */
    /* Print grads and ktrajs for current gradient to file */
    /* Print header and first line (without flip) */
    fprintf(fpout, "\nTime (usec)\tgrad1(t)\tgrad2(t)\tk1(t)\tk2(t)\tbval(t)\tflip\n");
    fprintf(fpout, "%12.4f\t\t%12.4f\t%12.4f\t%12.8f\t%12.8f\t%12.8f\n",bval_time[0],bval_grad_1[0],bval_grad_2[0], ktraj1[0], ktraj2[0],bval_point[0]);
    
    /* Print  vectors */
    for(n=1;n<bval_n;n++){
        bval_point[n] = (FLOAT)(4.0*PI*PI*gam*gam*1.0e-20*bval_point[n]);
        fprintf(fpout,"%12.4f\t\t%12.4f\t%12.4f\t%12.8f\t%12.8f\t%12.8f\t%d\n",bval_time[n],bval_grad_1[n],bval_grad_2[n],ktraj1[n],ktraj2[n],bval_point[n],bval_sign[n-1]);
    }

     fclose(fpout);

#endif

    return SUCCESS;
 
} /* End calcbvalue */

/**---------------------- PRIVATE FUNCTIONS ---------------------**/

/*
 * cumTrapIntegration
 *
 * Type: Private Function
 *
 * Description:
 *     Integrate fx using trapezoidal integration (First output point is zero) 
 *     (Cummulative integration) with ability to flip any segment
 *
 * Arguments:
 *  area1* - pointer to output array (must be previously allocated to npts long)
 *  area2* - pointer to output array (must be previously allocated to npts long)
 *     x* - vector of independent variables values
 *    fx* - vector of function evaluated at x
 *   fx2* - vector of function evaluated at x (may or may not = fx2)
 *  flip* - vector of signs for each linear segment (1's are added, !=1 are subtracted) [length = npts -1] ignored if NULL
 *   npts - number of points in x and fx
 *
 */

static STATUS cumTrapIntegration(FLOAT *area1, float *area2, const FLOAT *x,const FLOAT *fx, const FLOAT *fx2, const INT *flip, const INT npts) /* Trapezoidal integration of fx */
{
    /* Declare variables */
    INT n;     /* Counter */

    /* Check inputs */
    if(x == NULL || fx == NULL || area1 == NULL || area2 == NULL){
        fprintf(stderr,"trapIntegration: area, x, or fx is a NULL pointer\n");
        return FAILURE;
    }
    if(npts < 2){
        fprintf(stderr,"trapIntegration: Must be more than 2 points\n");
        return FAILURE;
    }
    
    /* Integrate */
    area1[0]=0.0;  /* Always use an output of zero for the first point */
    area2[0]=0.0; 
    if(flip == NULL){ /* If flip is a NULL pointer, don't flip */        
        for(n=1;n < npts;n++){
            area1[n] = area1[n-1]+(fx[n]+fx[n-1])/2*(x[n]-x[n-1]);    /* area1 of each trapezoid element */
            area2[n] = area2[n-1]+(fx2[n]+fx2[n-1])/2*(x[n]-x[n-1]);  
        }
    }        
    else{ /* Apply the flip vector */
        for(n=1;n < npts;n++){
            if(flip[n-1] == 1){    /* Add these trapezoids */
                area1[n] = area1[n-1]+(fx[n]+fx[n-1])/2*(x[n]-x[n-1]);   /* Area of each trapezoid element */
                area2[n] = area2[n-1]+(fx2[n]+fx2[n-1])/2*(x[n]-x[n-1]); 
            }
            else{                  /* Subtract these trapezoids */
                area1[n] = area1[n-1]-(fx[n]+fx[n-1])/2*(x[n]-x[n-1]);   /* Area of each trapezoid element */
                area2[n] = area2[n-1]-(fx2[n]+fx2[n-1])/2*(x[n]-x[n-1]); 
            }
        }
    }
    return SUCCESS;
}

/*
 * trapIntegrationSquared
 *
 * Type: Private Function
 *
 * Description:
 *     Integrate fx^2 using trapezoidal integration (First output point is zero)
 *     Calculations done using double precision floats.
 *
 * Arguments:
 *  area*  - pointer to output value (single preallocated value) - DOUBLE precision
 *     x*  - vector of independent variables values
 *    fx*  - vector of function evaluated at x
 *    fx2* - vector of function evalauated at x (may or may not = fx)
 *   npts  - number of points in x and fx
 *
 */
        
static STATUS trapIntegrationSquared(DOUBLE *area, const FLOAT *x, const FLOAT *fx, const FLOAT *fx2, FLOAT *bval_per_point, const INT npts)
{
    /* Declare variables */
    INT n;           /* Counter */
    DOUBLE slope, slope2;          /* Slopes of current line segment */
    DOUBLE intercept, intercept2;  /* y-intercepts of current line segment */
    
    /* Check inputs */
    if(x == NULL || fx == NULL || area == NULL)
    {
        fprintf(stderr,"trapIntegration: area, x, or fx is a NULL pointer");
        return FAILURE;
    }
    if(npts < 2){
        fprintf(stderr,"trapIntegration: Must be more than 2 points\n");
        return FAILURE;
    }

    /* Integrate */
    *area = 0.0;  /* Always use an output of zero for the first point */
    for(n=1;n < npts;n++){
        /* Calculate the area of the square of the line (a parabola) through the current points
           
           y = (mx+b)^2  where m = (y1-y0)/(x1-x0) and b = y0-m*x0

           area = int (mx+b)^2 from x0 to x1
                = (mx+b)^3/(m*3) from x0 to x1
                = ( (m*x1+b)^3 - (m*x0+b)^3 )/(m*3) => Don't use this form!  Divide by zero for m=0
                = m^2/3*(x1^3-x0^3) + mb*(x1^2-x0^2) + b^2*(x1-x0)
        */

        slope = ((DOUBLE)fx[n]-(DOUBLE)fx[n-1])/((DOUBLE)x[n]-(DOUBLE)x[n-1]);
        slope2 = ((DOUBLE)fx2[n]-(DOUBLE)fx2[n-1])/((DOUBLE)x[n]-(DOUBLE)x[n-1]);
        intercept = (DOUBLE)fx[n-1]-slope*(DOUBLE)x[n-1];
        intercept2 = (DOUBLE)fx2[n-1]-slope2*(DOUBLE)x[n-1];

        /* *area += (powf(slope*x[n]+intercept,3.0) - powf(slope*x[n-1]+intercept,3.0))/(slope*3);*/
        *area += slope*slope2/3*((DOUBLE)x[n]*(DOUBLE)x[n]*(DOUBLE)x[n] -
                                (DOUBLE)x[n-1]*(DOUBLE)x[n-1]*(DOUBLE)x[n-1]) +
            slope*intercept2/2*((DOUBLE)x[n]*(DOUBLE)x[n] - (DOUBLE)x[n-1]*(DOUBLE)x[n-1]) + 
            slope2*intercept/2*((DOUBLE)x[n]*(DOUBLE)x[n] - (DOUBLE)x[n-1]*(DOUBLE)x[n-1]) +
            intercept*intercept2*((DOUBLE)x[n] - (DOUBLE)x[n-1]);

        /* BJM: area for b-value at each point in the sequence */
        bval_per_point[n] = *area; 
    }

    return SUCCESS; 
} 



/* SVBranch: HCSDM00259119 
 * trapIntegrationSquared2
 *  
 * Type : Private Function
 *
 * Description:
 * This function calculates b-value for gradients with
 * arbitrary shapes.
 * This function was originally designed for usage in 
 * eco mpg, where the diffusion gradients have very
 * long ramps;
 * 
 * Arguments:
 *   For the renewed code, meanings of some inputs: 
 *     fa  - previous gradient area for axis 1;
 *     fa2 - previous gradient area for axis 2;
 *     fx  - gradient waveform for axis1;
 *     fx2 - gradient waveform for axis2;
 *     x   - time index;
 *
 *  
 *
 */
   
static STATUS trapIntegrationSquared2(DOUBLE *area, const FLOAT *x, const FLOAT *fa, const FLOAT *fa2, FLOAT *bval_per_point, const INT npts, const FLOAT *fx, const FLOAT *fx2, const INT *sign) /*Trapezodal integration of fx^2 */
{
    /* Declare variables */
    INT n;           /* Counter */
    DOUBLE slope, slope2;          /* Slopes of current line segment */
    DOUBLE intercept, intercept2;  /* y-intercepts of current line segment */
    DOUBLE C, C2; /* eco mpg: mpg opt: intermediate constants  */

    /* Check inputs */
    if(x == NULL || fx == NULL || area == NULL)
    {
        fprintf(stderr,"trapIntegration: area, x, or fx is a NULL pointer");
        return FAILURE;
    }
    if(npts < 2){
        fprintf(stderr,"trapIntegration: Must be more than 2 points\n");
        return FAILURE;
    }

    /* Integrate */
    *area = 0.0;  /* Always use an output of zero for the first point */
    
    for(n=1;n < npts;n++){

        slope = ((DOUBLE)fx[n]*sign[n-1]-(DOUBLE)fx[n-1]*sign[n-1])/((DOUBLE)x[n]-(DOUBLE)x[n-1]);
        slope2 = ((DOUBLE)fx2[n]*sign[n-1]-(DOUBLE)fx2[n-1]*sign[n-1])/((DOUBLE)x[n]-(DOUBLE)x[n-1]);
        intercept = (DOUBLE)fx[n-1]*sign[n-1]-slope*(DOUBLE)x[n-1];
        intercept2 = (DOUBLE)fx2[n-1]*sign[n-1]-slope2*(DOUBLE)x[n-1];
        
        /* eco mpg: mpg opt  */
        C = fa[n-1]-0.5*slope*x[n-1]*x[n-1] - intercept*x[n-1];
        C2 = fa2[n-1]-0.5*slope2*x[n-1]*x[n-1] - intercept2*x[n-1];

        /* eco mpg: mpg opt: 
           The original code does not correctly calculate the ramp
           portion of the gradient;
           For MPG optimization, a large portion of the gradient is
           under ramping, and therefore the algorithm is renewed
           as below; 
           The idea used here is, we divide the gradient on both 
           axis (G1, G2) into several partitions in time, 
           according to the corner point read in. Then for each 
           partition of the gradients, we do the integration:
           
              b12 = int(A(t)*B(t)) from t1 to t2,
              
           where:
               
               t1 is start time of this partition;
               t2 is end time of this partition;
               A(t) = int[G1(s)] from 0 to t,
               B(t) = int[G2(s)] from 0 to t;
               
        */
        *area += (1/20.0) * slope*slope2*x[n]*x[n]*x[n]*x[n]*x[n] +
                 (1/8.0)  * slope*intercept2*x[n]*x[n]*x[n]*x[n] +
                 (1/8.0)  * slope2*intercept*x[n]*x[n]*x[n]*x[n] +
                 (1/6.0)  * slope*C2*x[n]*x[n]*x[n] +
                 (1/6.0)  * slope2*C*x[n]*x[n]*x[n] +
                 (1/3.0)  * intercept*intercept2*x[n]*x[n]*x[n] +                
                 (1/2.0)  * intercept*C2*x[n]*x[n] + 
                 (1/2.0)  * intercept2*C*x[n]*x[n] +
                            C*C2*x[n] - 
                 (1/20.0) * slope*slope2*x[n-1]*x[n-1]*x[n-1]*x[n-1]*x[n-1] -
                 (1/8.0)  * slope*intercept2*x[n-1]*x[n-1]*x[n-1]*x[n-1] -
                 (1/8.0)  * slope2*intercept*x[n-1]*x[n-1]*x[n-1]*x[n-1] -
                 (1/6.0)  * slope*C2*x[n-1]*x[n-1]*x[n-1] -
                 (1/6.0)  * slope2*C*x[n-1]*x[n-1]*x[n-1] -
                 (1/3.0)  * intercept*intercept2*x[n-1]*x[n-1]*x[n-1] -                
                 (1/2.0)  * intercept*C2*x[n-1]*x[n-1] - 
                 (1/2.0)  * intercept2*C*x[n-1]*x[n-1] -
                            C*C2*x[n-1];           
 

        /* BJM: area for b-value at each point in the sequence */
        bval_per_point[n] = *area; 
    }

    return SUCCESS; 
}
