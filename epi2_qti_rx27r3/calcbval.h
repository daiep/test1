/*
 * GE Medical Systems
 * Copyright (C) 1998 The General Electric Company
 * 
 * Interface file for the calcbvalue.c file.
 * 
 * Language : ANSI C
 * Author   : Charles Michelich
 * Date     : 2000/11/22
 */
/* do not edit anything above this line */

/*
 Version      Date      Author      Description
------------------------------------------------------------------------------
 1.0        2000/11/22  CRM         Initial version.
 */

#ifndef calcbvalue_h
#define calcbvalue_h

/* Public function declarations */

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
 * STATUS calcbvalue( FLOAT *bvalue,
             const FLOAT gw_sale_axis,
 *           const FLOAT rf_excite_location,
 *           const FLOAT *rf_180_location,
 *           const INT num_180s,
 *           const FLOAT te,
 *           const FLOAT *time,
 *           FLOAT * const grad[3],
 *           const INT num_points,
 *           const FLOAT GAM);
 *
 * Outputs: 
 *   FLOAT *bvalue,                  => b-value for each gradient waveform (sec/mm^2)
 *   STATUS (returned)               => SUCCESS or FAILURE
 * 
 * Inputs:
 *   const FLOAT gw_scale_axis       => will scale each axis for gradwarp testing
 *   const FLOAT rf_excite_location, => Location of isocenter of excitation pulse (usec)
 *   const FLOAT *rf_180_location,   => Location of isocenter of 180 pulses (usec) pulses after
 *                                      excitation (NULL pointer for none)
 *   const INT num_180s,             => Number of 180s
 *   const FLOAT te,                 => Echo time (usec)
 *   const FLOAT *time,              => Vectors of times for each gradient waveform (all the same) (usec)
 *   const FLOAT *grad[3],           => Vector of gradient waveforms (G/cm)
 *   const INT num_points,           => Number of time points in gradient and time vectors 
 *   const FLOAT GAM)                => Gyromagnetic ratio (Hz/Gauss)
 *
 * Potential strange behavior:(1) Could add a very short linear segment due to round off errors.  
 *                                No divisions by this length, so it should be safe. 
 *                            (2) bvalue is scaled by 10^20 at the end for unit conversion.  
 *                                DOUBLEs used for calculatation to avoid roundoff errors
 *
 * Assumptions: Instantaneous 180s
 *              Piecewise linear gradients
 */
STATUS calcbvalue( FLOAT *bvalue,
            const FLOAT rf_excite_location,
            const FLOAT *rf_180_location,
            const INT num_180s,
            const FLOAT te,
            const FLOAT *time,
            const FLOAT *grad_1,
            const FLOAT *grad_2,
            const INT num_points,
            const FLOAT GAM);

/* Public constants */

/* Public constants */

/* Public typedefs */

#endif /* calcbvalue_h */
