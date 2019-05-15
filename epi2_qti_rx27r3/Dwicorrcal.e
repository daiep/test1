/*@Start***********************************************************/
/* GEMSBG C source File
 * Copyright (C) 1996 The General Electric Company
 *
 *	File Name:  dwicorrcal.e   
 *	Developer:  X. Joe Zhou
 *
 * $Source: dwicorrcal.c $
 * $Revision: 0.0 $  $Date: 08/30/96 11:52:13 $
 */

/*@Synopsis 
Based on an input GRAFIDY file, this subroutine calculates three matrices
used for correcting the image shift, distortion, and intensity reduction in
DW-EPI pulse sequence.  The first matrix is dwigcorr (3x3), and contains the correction
information for the read-out, phase-encoding, and slice-selection gradients
DURING data acquisition.  The second matrix dwibcorr (1x3) has the b0-correction
info DURING acquisition.  The last matrix is dwikcorr (3x3).  This matrix provides the gradient area correction for the pre-phasers.  The mathematical
details are contained in Joe Zhou's note book, volume 2).

*/     

/*@Description
Type and call:
-------------

STATUS dwicorrcal(dwigcorr, dwibcorr, dwikcorr, control, debug, rsprot, xfs, yfs, zfs, t_array)

Parameters Passed:
-----------------
(I: for input parameter, O: for output parameter)

(O)  float   dwigcorr[]:            output gradient correction matrix
					(3x3; unit: none)

(O)  float   dwikcorr[]:            output k-space correction matrix
					(3x3; unit: rad/gauss)

(O)  float   dwibcorr[]:            output frequency correction matrix
					(1x3; unit: cm)

(I)  int   debug:                   debug printf switch

(I)  int   control:                 control flag for blip correction

(I)  int rsprot[DATA_ACQ_MAX][9]: rotation matrices

(I)  int   xfs,yfs,zfs:             cfxfull, cfyfull, cfzfull

(I)  float t_array[7]:              PSD time parameter array:


			   t[0]: ramp time of DW gradient in us;
			   t[1]: flat-top time of the DW gradient in us;
			   t[2]: interval between the end of the first gradient
				 lobe and the begining of the 2nd gradient
				 lobe.  unit: us;
			   t[3]: interval between the very begining of the
				 first DW gradient pulse and the center of
			         the 180 degree pulse.  Unit: us;
			   t[4]: interval between the end of the
				 2nd DW gradient pulse and the begining
			         of the read-out starting point.  Unit: us;

			   t[5]: interval between the begining of the read-out
				 and the time where
				 the center of the k-space data is acquired.
				 unit: us.
     
*/

/* *********************************************************************
Rev        Date      Person    Comments
           08/30/96  XJZ       Created.

sccs1.6    06/17/97  VB        Created a LX2 version.
 
           12/24/98  GFN       Removed prototype for fopen(). It is already
                               provided by the main PSD.

*/


/*@End*********************************************************/


@host Predownload



/*
    Note: the current implementation does NOT cover the case of multi-angle oblique.
    So, we treat dwigcorr, dwikcorr, and dwibcorr as 1D arrays.  For future
    multi-angle oblique implementation, the following codes should be used. -- XJZ
 
    float dwigcorr[DATA_ACQ_MAX][9];	
    float dwibcorr[DATA_ACQ_MAX][3];	
    float dwikcorr[DATA_ACQ_MAX][9];

 */
/*  float dwigcorr[9];	output grad correction matrix */
/*  float dwibcorr[3];	output b0 (freg) correction matrix */
/*  float dwikcorr[9];	output pre-phaser area correction matrix */
/*  int   debug;           debug printf switch */
/*  int   rsprot[DATA_ACQ_MAX][9];  	 unscaled rotation matrices */
/*  float t_array[7];			 timing parametrers for DW-EPI sequence */
/*  int   xfs,yfs,zfs;               	 cfxfull, cfyfull, cfzfull */
/*  int   control;        control flag for dwi correction */
/** int   nslices;                   	number of slices */
STATUS
dwicorrcal(float dwigcorr[9],
           float dwibcorr[3],
           float dwikcorr[9], 
           int control, 
           int debug, 
           long rsprot[DATA_ACQ_MAX][9],
           int xfs, 
           int yfs,
           int zfs, 
           float t_array[7])
{
    STATUS status;                   	/* flag to return or exit */
  
    FILE *fp, *dwi_outfile;
    int   lines_header = 2;   		/* header lines to skip */
    int   lines_info_2_data = 1;		/* lines to skip between info and eddy data */
    int	lines_intra_axial = 1;		/* lines to skip between different eddy
                                       current acceptor axes for the SAME eddy
                                       current donor axis */
    int	lines_inter_axial = 2;		/* lines to skip between different eddy
                                       current donor axes  */
    int   max_chars_per_line = 100;  	/* for reading from delay.esp.xyz file */
    char  dummy[100];			/* dummy characters for the input file */

    int i, j;               		/* counter */

    float rot_norm[9]; 			/* normalized rotation matrix */


    /* Note: the current implementation does NOT cover the case of
       multi-angle oblique.  So, we treat rsp_norm as a 1D array.
       For future multi-angle oblique implementation, the following codes
       should be used. -- XJZ

       float rot_norm[DATA_ACQ_MAX][9]; 	
 
    */

    float *amp_x, *amp_y, *amp_z; 	/* eddy current amplitudes */

    float *tau_x, *tau_y, *tau_z; 	/* eddy current time constants */
 
    int  nx_eddy[4], ny_eddy[4],
        nz_eddy[4], nx_eddy_all,
        ny_eddy_all, nz_eddy_all;
    /* number of eddy current elements */

    float temp_g[9], temp_k[9], temp_b[3]; /* temp arrays  */

    const char  *infilename="grafidy.dwi";
    const char  *pathname="/usr/g/caldir/";
    char  basefilename[80];

    float xxx, yyy;			/* temporary variables  */  
    int offset_2d;			/* offset control for the 2D array */

    float t1, t2, t3, t4, t5, t9, t10, d4;   
    /* timing parameters */
    float R;		 		/* normalized slew-rate in 1.0/us  */

    float amp, tau;	    /* subroutine variables */  
  
    status = SUCCESS;


    /* I. Initialization and scaling the rotation matrix  */
 
    /* Note: the current implementation does NOT cover the case of multi-angle oblique.
       So, we treat dwigcorr, dwikcorr, and dwibcorr as 1D arrays.  For future
       multi-angle oblique implementation, the following codes should be used. -- XJZ 
   

       for(i=0; i<DATA_ACQ_MAX; i++) {
       for(j = 0; j<9; j++) {
       dwigcorr[i][j] = 0.0;
       dwikcorr[i][j] = 0.0;
       }
       for (j=0; j<3; j++) {
       dwibcorr[i][j] = 0.0;
       }
       }

    */

    for(j=0; j<9; j++) {
        dwigcorr[j] = 0.0;
        dwikcorr[j] = 0.0;
    }
    for(j=0; j<3; j++) {
        dwibcorr[j] = 0.0;
    }



    if (control == 1) {

        /* normailzing rotation matrices */
    
        rot_norm[0] = (float)rsprot[0][0]/(float)xfs;
        rot_norm[1] = (float)rsprot[0][1]/(float)xfs;
        rot_norm[2] = (float)rsprot[0][2]/(float)xfs;
        rot_norm[3] = (float)rsprot[0][3]/(float)yfs;
        rot_norm[4] = (float)rsprot[0][4]/(float)yfs;
        rot_norm[5] = (float)rsprot[0][5]/(float)yfs;
        rot_norm[6] = (float)rsprot[0][6]/(float)zfs;
        rot_norm[7] = (float)rsprot[0][7]/(float)zfs;
        rot_norm[8] = (float)rsprot[0][8]/(float)zfs;
    

        /* Note: the current implementation does NOT cover the case of
           multi-angle oblique.  So, we only take the [0][i] elements from
           the rotation matrix rsprot.  For future multi-angle oblique
           implementation, the following codes should be used. -- XJZ

           for(i=0; i<nslices; i++) {
           rot_norm[i][0] = (float)rsprot[i][0]/(float)xfs;
           rot_norm[i][1] = (float)rsprot[i][1]/(float)xfs;
           rot_norm[i][2] = (float)rsprot[i][2]/(float)xfs;
           rot_norm[i][3] = (float)rsprot[i][3]/(float)yfs;
           rot_norm[i][4] = (float)rsprot[i][4]/(float)yfs;
           rot_norm[i][5] = (float)rsprot[i][5]/(float)yfs;
           rot_norm[i][6] = (float)rsprot[i][6]/(float)zfs;
           rot_norm[i][7] = (float)rsprot[i][7]/(float)zfs;
           rot_norm[i][8] = (float)rsprot[i][8]/(float)zfs;
           }

        */



        /* II.  Open the GRAFIDY file */

        /* the GRAFIDY file has to follow the following format

        # header
        # header  (total lines of the header:  "lines_header")
        lx  (The numbers of x->x eddy currents)
        mx  (The numbers of x->y eddy currents)
        nx  (The numbers of x->z eddy currents)
        px  (The numbers of x->B0 eddy currents)

		(separated by "lines_info_2_data" lines)
	   
        tau(xx1)  alpha(xx1)
        tau(xx2)  alpha(xx2)
        ...		(x->x eddy currents; lx terms in total)
        tau(xxlx)  alpha(xxlx)

		(separated by "lines_intra_axial" lines)

        tau(xy1)  alpha(xy1)
        tau(xy2)  alpha(xy2)
        ...		(x->y eddy currents; mx terms in total)		
        tau(xymx)  alpha(xymx)
		
		(separated by "lines_intra_axial" lines)

        tau(xz1)  alpha(xz1)
        tau(xz2)  alpha(xz2)
        ...		(x->z eddy currents; nx terms in total)		
        tau(xznx)  alpha(xznx)

		(separated by "lines_intra_axial" lines)
	
        tau(x01)  alpha(x01)
        tau(x02)  alpha(x02)
        ...		(x->b0 eddy currents; px terms in total)		

        tau(x0px)  alpha(x0px)


		(separated by "lines_inter_axial" lines)


        ly   (The numbers of y->x eddy currents) 
        my   (The numbers of y->y eddy currents)
        ny   (The numbers of y->z eddy currents)
        py   (The numbers of y->b0 eddy currents)
	   
        tau(yx1)  alpha(yx1)
        tau(yx2)  alpha(yx2)
        ...		(y->x eddy currents; ly terms in total)
        tau(yxly)  alpha(yxly)

	
        tau(yy1)  alpha(yy1)
        tau(yy2)  alpha(yy2)
        ...		(y->y eddy currents; my terms in total)		
        tau(yymy)  alpha(yymy)
 

        tau(yz1)  alpha(yz1)
        tau(yz2)  alpha(yz2)
        ...		(y->z eddy currents; ny terms in total)		
        tau(yzny)  alpha(yzny)

	
        tau(y01)  alpha(y01)
        tau(y02)  alpha(y02)
        ...		(y->b0 eddy currents; py terms in total)		
        tau(y0py)  alpha(y0py)



        lz  (The numbers of z->x eddy currents)
        mz  (The numbers of z->y eddy currents)
        nz  (The numbers of z->z eddy currents)
        pz  (The numbers of z->b0 eddy currents) 
	   
        tau(zx1)  alpha(zx1)
        tau(zx2)  alpha(zx2)
        ...		(z->x eddy currents; lz terms in total)
        tau(zxlz)  alpha(zxlz)

	
        tau(zy1)  alpha(zy1)
        tau(zy2)  alpha(zy2)
        ...		(z->y eddy currents; mz terms in total)		
        tau(zymz)  alpha(zymz)
 

        tau(zz1)  alpha(zz1)
        tau(zz2)  alpha(zz2)
        ...		(z->z eddy currents; nz terms in total)		
        tau(zznz)  alpha(zznz)

	
        tau(z01)  alpha(z01)
        tau(z02)  alpha(z02)
        ...		(z->b0 eddy currents; pz terms in total)		
        tau(z0pz)  alpha(z0pz)

        ***************************************************************/


        strcpy(basefilename, pathname);
        strcat(basefilename, infilename);

        if ((fp = fopen(basefilename, "r")) == NULL) {
            /* Make non-fatal for now... */
            if (debug == 1)
                printf("dwicorrcal: could not open file: %s\n",basefilename);
            status = FAILURE;
            goto graceful_exit; 
        }


        if ((dwi_outfile = fopen("/usr/g/bin/dwi_dwbug_out", "w")) == NULL ) {
            printf("dwicorrcal: could not open file for debug.\n");
            status = FAILURE;
            goto graceful_exit;
        }

        if(lines_intra_axial > lines_inter_axial)  {
            if (debug == 1)
                printf("dwicorrcal: illed file format! \n the spacing of inter_axial info must be no smaller than the intra_axial spacing in %s\n",basefilename);
            status = FAILURE;
            goto graceful_exit; 
        }


        /* skip the header lines */
   
      	for (i=0; i<lines_header; i++)
            fgets(dummy, max_chars_per_line, fp);

        /* read in the x-eddy info */

        for (i=0; i<4; i++)
            fscanf(fp,"%d\n",&nx_eddy[i]);

        /* allocate memory for x_eddy terms */

        nx_eddy_all = nx_eddy[0]+nx_eddy[1]+nx_eddy[2]+nx_eddy[3];
        amp_x = (float *)malloc(nx_eddy_all*sizeof(float));
        tau_x = (float *)malloc(nx_eddy_all*sizeof(float));


        /* skipping the lines that separate the x_info from the x_data */

        for (i=0; i<lines_info_2_data; i++)
            fgets(dummy, max_chars_per_line, fp);

        /* read in the x-eddy data */

        offset_2d = 0;   
        for(j=0; j<4; j++)  {
            for(i=0; i<nx_eddy[j]; i++)  {
                fscanf(fp,"%f %f\n",&xxx, &yyy);
                tau_x[i+offset_2d] = xxx;
                amp_x[i+offset_2d] = yyy;
            }
            offset_2d = offset_2d+nx_eddy[j];
            for (i=0; i<lines_intra_axial; i++)
                fgets(dummy, max_chars_per_line, fp);
        }

        for (i=0; i<(lines_inter_axial-lines_intra_axial); i++)
            fgets(dummy, max_chars_per_line, fp);

        if(debug==1) {
            for(i=0; i<nx_eddy_all; i++) 
                fprintf(dwi_outfile, "tau_x[%d]=%f \t amp_x[%d]=%f\n", i,tau_x[i], i, amp_x[i]);

        }

        /* read in y-eddy info */

        for (i=0; i<4; i++)
            fscanf(fp,"%d\n",&ny_eddy[i]);

        /* allocate memory for y_eddy terms */

        ny_eddy_all = ny_eddy[0]+ny_eddy[1]+ny_eddy[2]+ny_eddy[3];
        amp_y = (float *)malloc(ny_eddy_all*sizeof(float));
        tau_y = (float *)malloc(ny_eddy_all*sizeof(float));

        /* skipping the lines that separate the y_info from the y_data */

        for (i=0; i<lines_info_2_data; i++)
            fgets(dummy, max_chars_per_line, fp);

        /* read in the y-eddy data */

        offset_2d = 0;
        for(j=0; j<4; j++)  {
            for(i=0; i<ny_eddy[j]; i++)  {
                fscanf(fp,"%f %f\n",&xxx, &yyy);
                tau_y[i+offset_2d] = xxx;
                amp_y[i+offset_2d] = yyy;
            }

            offset_2d = offset_2d+ny_eddy[j];
            for (i=0; i<lines_intra_axial; i++)
                fgets(dummy, max_chars_per_line, fp);
        }

        for (i=0; i<(lines_inter_axial-lines_intra_axial); i++)
            fgets(dummy, max_chars_per_line, fp);

        if(debug==1) {
            for(i=0; i<ny_eddy_all; i++) 
                fprintf(dwi_outfile, "tau_y[%d]=%f \t amp_y[%d]=%f\n", i,tau_y[i], i, amp_y[i]);
        }


        /* read in z-eddy info */

        for (i=0; i<4; i++)
            fscanf(fp,"%d\n",&nz_eddy[i]);

        /* allocate memory for z_eddy terms */

        nz_eddy_all = nz_eddy[0]+nz_eddy[1]+nz_eddy[2]+nz_eddy[3];
        amp_z = (float *)malloc(nz_eddy_all*sizeof(float));
        tau_z = (float *)malloc(nz_eddy_all*sizeof(float));

        /* skipping the lines that separate the z_info from the z_data */

        for (i=0; i<lines_info_2_data; i++)
            fgets(dummy, max_chars_per_line, fp);

        /* read in the z-eddy data */

        offset_2d = 0;
        for(j=0; j<4; j++)  {
            for(i=0; i<nz_eddy[j]; i++)  {
                fscanf(fp,"%f %f\n",&xxx, &yyy);
                tau_z[i+offset_2d] = xxx;
                amp_z[i+offset_2d] = yyy;
            }

            offset_2d = offset_2d+nz_eddy[j];
            if(j<3)  {
                for (i=0; i<lines_intra_axial; i++)
                    fgets(dummy, max_chars_per_line, fp);
            }
        }

        if(debug==1) {
            for(i=0; i<nz_eddy_all; i++) 
                fprintf(dwi_outfile, "tau_z[%d]=%f \t amp_z[%d]=%f\n", i,tau_z[i], i, amp_z[i]);
        }

        fclose(fp);


        /** end of reading the GRADIFY file **/


        /*  III. calculating the timing paramters        */

        t1= t_array[0]; 		/* all time units are in us */
        t2= t_array[0]+t_array[1];
        t3= 2*t_array[0]+t_array[1];
        t4= t_array[3];
        t5= t3+t_array[2];
        t9= 2*t3+t_array[2]+t_array[4];
        d4= t_array[4];
        t10 = t9+t_array[5];

        R = 1.0/t1;  		/* slew rate in 1.0/us */

        /* IV.  calculating the x-gradient-induced errors */

        offset_2d = 0;
        for(j=0; j<3; j++)  {
            for(i=0; i<nx_eddy[j]; i++)  {
                amp = amp_x[i+offset_2d];
                tau = tau_x[i+offset_2d];
                dwikcorr[j] = dwikcorr[j]+k_error(R, amp, tau, t1, t2, t3, t4, t9, d4, 0.0);
                dwigcorr[j] = dwigcorr[j]+g_error(R, amp, tau, t1, t2, t5, t10);
            }
            offset_2d = offset_2d+nx_eddy[j];

        }

        /*   b0 errors   */
        for(i=0; i<nx_eddy[3]; i++)  {
            amp = amp_x[i+offset_2d];
            tau = tau_x[i+offset_2d];
            dwibcorr[0] = dwibcorr[0]+g_error(R, amp, tau, t1, t2, t5, t10);
        }


        /* V.  calculating the y-gradient-induced errors */

        offset_2d = 0;
        for(j=0; j<3; j++)  {
            for(i=0; i<ny_eddy[j]; i++)  {
                amp = amp_y[i+offset_2d];
                tau = tau_y[i+offset_2d];
                dwikcorr[j+3] = dwikcorr[j+3]+k_error(R, amp, tau, t1, t2, t3, t4, t9, d4, 0.0);
                dwigcorr[j+3] = dwigcorr[j+3]+g_error(R, amp, tau, t1, t2, t5, t10);
            }
            offset_2d = offset_2d+ny_eddy[j];
        }

        /*   b0 errors   */
        for(i=0; i<ny_eddy[3]; i++)  {
            amp = amp_y[i+offset_2d];
            tau = tau_y[i+offset_2d];
            dwibcorr[1] = dwibcorr[1]+g_error(R, amp, tau, t1, t2, t5, t10);
        }


        /* VI.  calculating the z-gradient-induced errors */

        offset_2d = 0;
        for(j=0; j<3; j++)  {
            for(i=0; i<nz_eddy[j]; i++)  {
                amp = amp_z[i+offset_2d];
                tau = tau_z[i+offset_2d];
                dwikcorr[j+6] = dwikcorr[j+6]+k_error(R, amp, tau, t1, t2, t3, t4, t9, d4, 0.0);
                dwigcorr[j+6] = dwigcorr[j+6]+g_error(R, amp, tau, t1, t2, t5, t10);
            }
            offset_2d = offset_2d+nz_eddy[j];
        }

        /*   b0 errors   */
        for(i=0; i<nz_eddy[3]; i++)  {
            amp = amp_z[i+offset_2d];
            tau = tau_z[i+offset_2d];
            dwibcorr[2] = dwibcorr[2]+g_error(R, amp, tau, t1, t2, t5, t10);
        }


        if (debug == 1) {

            fprintf(dwi_outfile, "time array elements:\n\n");

            for(i=0; i<7; i++)  {
                fprintf(dwi_outfile, "t[%d]=%e\n", i, t_array[i]);
            }

            fprintf(dwi_outfile, "control flag for blip correction = %d\n",control);

            fprintf(dwi_outfile, "\n\nLamda matrix for gradient:\n");
            fprintf(dwi_outfile, "\t g[0]=%e \t g[1]=%e \t g[2]=%e\n", dwigcorr[0], dwigcorr[1], dwigcorr[2]);
            fprintf(dwi_outfile, "\t g[3]=%e \t g[4]=%e \t g[5]=%e\n", dwigcorr[3], dwigcorr[4], dwigcorr[5]);
            fprintf(dwi_outfile, "\t g[6]=%e \t g[7]=%e \t g[8]=%e\n", dwigcorr[6], dwigcorr[7], dwigcorr[8]);

            fprintf(dwi_outfile, "\n\nLamda matrix for k-space:\n");
            fprintf(dwi_outfile, "\t k[0]=%e \t k[1]=%e \t k[2]=%e\n", dwikcorr[0], dwikcorr[1], dwikcorr[2]);
            fprintf(dwi_outfile, "\t k[3]=%e \t k[4]=%e \t k[5]=%e\n", dwikcorr[3], dwikcorr[4], dwikcorr[5]);
            fprintf(dwi_outfile, "\t k[6]=%e \t k[7]=%e \t k[8]=%e\n", dwikcorr[6], dwikcorr[7], dwikcorr[8]);

            fprintf(dwi_outfile, "\n\nLamda matrix for B0-correction:\n");
            fprintf(dwi_outfile, "\t b[0]=%e \t b[1]=%e \t b[2]=%e\n", dwibcorr[0], dwibcorr[1], dwibcorr[2]);


            fprintf(dwi_outfile, "\n\nOriginal Rotation Matrix:\n");
            fprintf(dwi_outfile, "\t r[0]=%ld \t r[1]=%ld \t r[2]=%ld\n", rsprot[0][0], rsprot[0][1], rsprot[0][2]);
            fprintf(dwi_outfile, "\t r[3]=%ld \t r[4]=%ld \t r[5]=%ld\n", rsprot[0][3], rsprot[0][4], rsprot[0][5]);
            fprintf(dwi_outfile, "\t r[6]=%ld \t r[7]=%ld \t r[8]=%ld\n", rsprot[0][6], rsprot[0][7], rsprot[0][8]);

            fprintf(dwi_outfile, "\n\nfull scale gradient values:\n");
            fprintf(dwi_outfile, "\t xfs=%d \t yfs=%d \t zfs=%d\n", xfs, yfs, zfs);




            fprintf(dwi_outfile, "\n\nRotation matrix:\n");
            fprintf(dwi_outfile, "\t r[0]=%e \t r[1]=%e \t r[2]=%e\n", rot_norm[0], rot_norm[1], rot_norm[2]);
            fprintf(dwi_outfile, "\t r[3]=%e \t r[4]=%e \t r[5]=%e\n", rot_norm[3], rot_norm[4], rot_norm[5]);
            fprintf(dwi_outfile, "\t r[6]=%e \t r[7]=%e \t r[8]=%e\n", rot_norm[6], rot_norm[7], rot_norm[8]);

        }


        /** end of error calculation  **/


        /* VII.  Similarity transform of the correction matrix  **/

        /** first round for dwigcorr and dwikcorr matrices  **/

        for(j=0; j<3; j++)  {
            for(i=0; i<3; i++)  {
                temp_g[i+3*j] = rot_norm[j*3]*dwigcorr[i]+rot_norm[j*3+1]*dwigcorr[i+3]+rot_norm[j*3+2]*dwigcorr[i+6];
                temp_k[i+3*j] = rot_norm[j*3]*dwikcorr[i]+rot_norm[j*3+1]*dwikcorr[i+3]+rot_norm[j*3+2]*dwikcorr[i+6];
            }
        }

        /** second round for dwigcorr and dwikcorr matrices  **/

        for(i=0; i<3; i++)  {
            for(j=0; j<3; j++)  {
                dwigcorr[i+3*j] = temp_g[j*3]*rot_norm[i*3]+temp_g[j*3+1]*rot_norm[i*3+1]+temp_g[j*3+2]*rot_norm[i*3+2];

                dwikcorr[i+3*j] = temp_k[j*3]*rot_norm[i*3]+temp_k[j*3+1]*rot_norm[i*3+1]+temp_k[j*3+2]*rot_norm[i*3+2];
            }

        }

        /*  VIII. calculating the B0 errors  **/

        for(i=0; i<3; i++)
            temp_b[i] = dwibcorr[0]*rot_norm[i*3]+dwibcorr[1]*rot_norm[i*3+1]+dwibcorr[2]*rot_norm[i*3+2];

        for(i=0; i<3; i++)
            dwibcorr[i] = temp_b[i];

        /* IX.  Printing out info  **/

        if (debug == 1) {

            fprintf(dwi_outfile, "\n\n\nmatrices after the similarity transform:\n");
            fprintf(dwi_outfile, "\n\nLamda matrix for gradient:\n");
            fprintf(dwi_outfile, "\t g[0]=%e \t g[1]=%e \t g[2]=%e\n", dwigcorr[0], dwigcorr[1], dwigcorr[2]);
            fprintf(dwi_outfile, "\t g[3]=%e \t g[4]=%e \t g[5]=%e\n", dwigcorr[3], dwigcorr[4], dwigcorr[5]);
            fprintf(dwi_outfile, "\t g[6]=%e \t g[7]=%e \t g[8]=%e\n", dwigcorr[6], dwigcorr[7], dwigcorr[8]);

            fprintf(dwi_outfile, "\n\nLamda matrix for k-space:\n");
            fprintf(dwi_outfile, "\t k[0]=%e \t k[1]=%e \t k[2]=%e\n", dwikcorr[0], dwikcorr[1], dwikcorr[2]);
            fprintf(dwi_outfile, "\t k[3]=%e \t k[4]=%e \t k[5]=%e\n", dwikcorr[3], dwikcorr[4], dwikcorr[5]);
            fprintf(dwi_outfile, "\t k[6]=%e \t k[7]=%e \t k[8]=%e\n", dwikcorr[6], dwikcorr[7], dwikcorr[8]);

            fprintf(dwi_outfile, "\n\nLamda matrix for B0-correction:\n");
            fprintf(dwi_outfile, "\t b[0]=%e \t b[1]=%e \t b[2]=%e\n", dwibcorr[0], dwibcorr[1], dwibcorr[2]);

        }

        fclose(dwi_outfile);
    }  /* closing for the control flag  */

 graceful_exit:
    return status;


}  /* end of the dwicorrcal routine */


/* sub-subroutines  */

float k_error(float R, 
              float amp, 
              float tau,
              float t1, 
              float t2, 
              float t3, 
              float t4, 
              float t9,
              float d4,
              float delta)

/*float t1, t2, t3, t4, t9, d4;    timing parameters */
/*float R; 		           normalized slew-rate in 1.0/us  */
/*float amp, tau, delta; 	   subroutine variables */  


{

double gamma=0.0267475;          /* gyromagnetic ratio in MHz/gauss:
			  	   2*3.1415926*4.257*0.001 */
 
double error_a, error_b, error_c, error_d;

      	error_a = 0.01*(double)R*gamma*(double)(amp*tau*tau);
							/* 0.01 comes from
							the % expression of
							amp */
	error_b = 1-exp((double)(t1/tau));
	error_c = 1-exp((double)(t2/tau));
	error_d = (double)(2*exp(-t4/tau)-exp(-(t9+delta)/tau)-exp(-(t3+d4+delta)/tau));

return((float)(error_a*error_b*error_c*error_d));


	
/** return(R*gamma*amp*tau*tau*(1-exp(t1/tau))*
(1-exp(t2/tau))*(2*exp(-t4/tau)-exp(-(t9+delta)/tau)-exp(-(t3+d4+delta)/tau)));

**/

}

float g_error(float R,
              float amp,
              float tau,
              float t1,
              float t2,
              float t5,
              float t10)
{

double error_a, error_b, error_c, error_d;

        error_a = 0.01*(double)R*(double)(amp*tau);  /* 0.01 comes from
							the % expression of
							amp */
	error_b = 1-exp((double)(t1/tau));
	error_c = 1-exp((double)(t2/tau));
	error_d = (1+exp((double)(t5/tau)))*exp(-(double)(t10/tau));

/** return(R*amp*tau*(1-exp(t1/tau))*(1-exp(t2/tau))*(1+exp(t5/tau))*exp(-t10/tau));
**/ 

 return((float)(error_a*error_b*error_c*error_d));


}

/* end of file -- XJZ */ 

