/* vim: set filetype=c : */
/******************************************************************************

                           Full Time Diffusion Encoding
               			   Grant Yang
				    9/29/2018

*******************************************************************************/

#include <stdio.h>
#include <math.h>
#include "ftde.h"
/*#define gamma 267.538*/

static double calcldbval(int ramp, int pwc, int wait_time, int rf2_time, double gmax);
static void bramp(int duration, double SR, double *g, double *q, double *b);
static void bplateau(int duration, double g, double *q, double *b);

/* public function */

/* calculates the diffusion timings necessary to achieve a target b-value */
void calcpwabc(double b_target, int wait_time, int rf2_time, double gmax, int ramp, int *pwa, int *pwb, int *pwc){

    /*double tol = 0.25;*/
    /* Use ST timing as upper bound */
    int pwc_max = *pwc*1.2; 
    int pwc_min = 0;
    /* Compute timings by bisection */
    double b = calcldbval(ramp,*pwc,wait_time,rf2_time,gmax);

    printf("Initial timings: pwa = %d, pwb = %d, pwc = %d, b-value = %f s/mm^2 \n", *pwa, *pwb, *pwc, b);

    /*while (fabs(b-b_target) > tol){*/
    for (int i = 0; i < 20; i++){
        if(b > b_target){
            pwc_max = *pwc;
            *pwc = (*pwc + pwc_min)/2;
        } else {
            pwc_min = *pwc;
            *pwc = (*pwc + pwc_max)/2;
        }
        b = calcldbval(ramp,*pwc,wait_time,rf2_time,gmax);
        printf("pwc = %d, max = %d, min = %d, b-value = %f s/mm^2 \n", *pwc, pwc_max, pwc_min, b);
    }
    *pwa = (wait_time - ramp + 2*(*pwc))/2; /* dephaser gradient plateau */
    *pwb = *pwa - *pwc - ramp; /* rephaser gradient 1 plateau */
    printf("final timings: pwa = %d, pwb = %d, pwc = %d, b-value = %f s/mm^2 \n", *pwa, *pwb, *pwc, b);
}

/* private functions */
/* computes the b-value of the gradient waveform with three diffusion encoding pulses in s/mm^2 */
/* assumes time units in us, and gradient units in T/m */
static double calcldbval(int ramp, int pwc, int wait_time, int rf2_time, double gmax){
    int pwa = (wait_time - ramp + 2*pwc)/2; /* dephaser gradient plateau */
    int pwb = pwa - pwc - ramp; /* rephaser gradient 1 plateau */
    double b = 0; /* b-value */
    double q = 0; /* current q */
    double gc = 0; /* current g */
    double SR = gmax/ramp; /* slew rate */
    
    /* first ramp */
    bramp(ramp, SR, &gc, &q, &b);
    /* dephaser plateau */
    bplateau(pwa, gc, &q, &b);
    /* ramp down */
    bramp(2*ramp, -SR, &gc, &q, &b);
    /* rephaser1 plateau */
    bplateau(pwb, gc, &q, &b);
    /* rephaser1 ramp */
    bramp(ramp, SR, &gc, &q, &b);
    /* refocusing pulse time */
    bplateau(rf2_time, gc, &q, &b);
    /* rephaser2 ramp */
    bramp(ramp, -SR, &gc, &q, &b);
    /* rephaser2 plateau */
    bplateau(pwc, gc, &q, &b);
    /* rephaser2 ramp down */
    bramp(ramp, SR, &gc, &q, &b);
    /*printf("b = %f, q = %f, g = %f \n", b/1e12*gamma*gamma, q, gc); */
    return b/1e12*267.538*267.538;
}

/* calculates the effect of a gradient ramp on the q trajectory and b-value */
static void bramp(int duration, double SR, double *g, double *q, double *b){
    double qc = *q;
    double gc = *g;
    /* update b */
    *b += pow(duration,5)*SR*SR/20  + 1/4*pow(duration,4)*gc*SR + 1/3*pow(duration,3)*(gc*gc + qc*SR) + pow(duration,2)*gc*qc + duration*qc*qc;
    /* update q */
    *q += SR*pow(duration,2)/2 + gc*duration;
    /* update g */
    *g += SR*duration;
}

/* calculates the effect of a constant gradient on the q trajectory and b-value */
static void bplateau(int duration, double g, double *q, double *b){
    double qc = *q;
    /* update b */
    *b += pow(duration,3)*g*g/3 + pow(duration,2)*g*qc + duration*qc*qc;
    /* update q */
    *q += g*duration;
}


