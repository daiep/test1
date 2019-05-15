/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  DTI.h
 *  
 *  
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 1/26/01
 */
/* do not edit anything above this line */

#ifndef DTI_h
#define DTI_h

/*
 * @host section
 */

STATUS DTI_Init(void);

STATUS DTI_Eval(void);

STATUS DTI_Predownload(void);

STATUS DTI_Check(void);

STATUS verify_bvalue(FLOAT *curr_bvalue, 
                     const FLOAT rf_excite_location, 
                     const FLOAT *rf_180_location, 
                     const INT num180s, 
                     const INT seq_entry_index, 
                     const INT bmat_flag, 
                     const INT debug);

STATUS calc_b_matrix( FLOAT * curr_bvalue, 
                      const FLOAT rf_excite_location, 
                      const FLOAT * rf_180_location, 
                      const INT num180s, 
                      const INT seq_entry_index, 
                      const INT bmat_flag, 
                      const INT seg_debug);



#endif /* DTI_h */
