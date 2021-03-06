	SUBROUTINE SHADE (z, cells)


*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
*	Modified of PLOTZ to get data into proper grids for 
*	SHADE command

*	J Davison 8.26.88
*
*	Mod JD 4.18.90 to allow data all of the same value to be shaded. 
*       MOD *JD* To permit use of centered levels and specify the delta Z
*       value as well.  Added variables to CONT.INC common 8.3.95  
*	   *jd 8.28 fix bug in dz specification
*	*jd* 2.96 Change centered option so that data not spanning zero
*			is centered as well.
*	*jd* 5.96 Fix bug where if shade/lev=N option is used with constant 
*	field, no shade results
*       *jd* 1.98 Fix bug: shade misses top level, when top level is lt 0.
* V510 4/00 *sh - corrected faulty logic for centered levels (delta wrong)
* V550 11/02*acm* To use cellarray calls for rectangular shade plots, pass 
*                 cells in as a work array.  Remove VAX includes
* V550 12/02*acm* After levels are set, call setlab_syms to create the LEVELS symbols
* V552  3/03*acm* Check for too many levels, as is done for FILL and CONTOUR plots.
* v552  6/03*acm* Rename the array used for cellarray call.
* v554  3/04*acm* In the section marked correction for rounding errors, under g77 
*                 on linux this incorrectly uses low-order bits to reset NLEV2
* v570  4/04*acm* The fix above went too far.  Use TM_FPEQ to see if
*                 values are equal or close.  Also fixes this adjustment
*                 when the range has negative values; was always incorrect.
* v580  8/04*acm* Fix bug 957 shade/lev=1 of a constant field needs zlev(1) to be set.
* v581  4/05*acm* For cellarray plots JTYPE had erroneously been set to 1 (?!)
* v581 *acm* 3/05 open levels (-INF) (INF)
* v611 *acm* 4/08 Fix bug 1567: Set jj as in PLOTZ so SHADE/LINE gets labels with 
*                 enough precision
* v68  *acm* 4/08 Allow shade, vector plots of degenerate regions - world region 
*              within a grid cell
* V68  *acm* 1/12  changes for double-precision ferret, single-precision pplus


	include		'parampl5_dat.decl'
	include		'PARAMPL5.DAT'

	include		'axis_inc.decl'
	include		'AXIS.INC'
	include		'plt_inc.decl'
	include		'PLT.INC'
	include		'miss_inc.decl'
	include		'MISS.INC'
	include		'hd_inc.decl'
	include		'HD.INC'
	include		'cont_inc.decl'
	include		'CONT.INC'
	include		'zgrid_inc.decl'
	include		'ZGRID.INC'
	include		'zgridd_inc.decl'
	include		'ZGRIDD.INC'
        include         'errmsg.parm'
        include         'shade_vars.cmn'

	real		dx,dy,dz,z(nx,ny),znp,zmp

	integer		status, i, j, cells(*), slen1, slen2
        CHARACTER       TM_FMT*48, buff1*20, buff2*20, err_msg*40

C       Add external stmt for linux port *jd* 12.96 RANGE is intrinsic fcn
        external range

******************************************************************************

C
C  Set the contour/color levels

        CALL SET_LEVELS_SHADE_FILL (status)
	IF (status .NE. ferr_ok) GOTO 5000

C       DRAW
C
C       from ppl/include/PPL.INC:
C
C       JTYPE: = 2 2-d irregular rectangular grid
C              = 1 1-d set
C              = 0 2-d regular rectangular grid (integer)
C              =-1 2-d second component of a vector regular grid
C              =-2 2-d second component of a vector irregular grid
C

C  WHY HAD JTYPE BEEN SET TO 1 HERE??!! 

c        IF (use_cell) JTYPE = 1
        IF (use_cell) JTYPE = 0

C       If it's a 2-d irregular grid, the irregular grid values
C       are also stored in the Z array.  Pass them to shade_sub.
	
	IF (JTYPE.EQ.2 .OR. JTYPE.EQ.-2) THEN

	   CALL SHADE_SUB(Z,Z(1,NY+1),Z(1,NY+2),XX(IZSE-NX-1),
     .        YY(IZSE-NY-1), cells)

C       For all other plot types fill in XX() and YY() by
C       multiplying the index value by the DX or DY delta values.

	ELSE

	   DX = (XMAX - XMIN)/(NX - 1)
	   DY = (YMAX - YMIN)/(NY - 1)
	   IF (NX .EQ. 1) DX = 1.
	   IF (NY .EQ. 1) DY = 1.

	   DO 500 I=1,NX
	      XX(IZLEN+I)=DX*(I-1)+XMIN
 500	   CONTINUE
	   DO 510 J=1,NY
	      YY(IZLEN+J)=DY*(J-1)+YMIN
 510	   CONTINUE

c *kob* 8/97 had to move the continuation marker to col 5 - it was in col 8
c       this bombed aix compiler, though it seems to work on others
	   CALL SHADE_SUB(Z,XX(IZLEN+1),YY(IZLEN+1),XX(IZLEN+NX+1),
     1	       YY(IZLEN+NY+1), cells)

	ENDIF

	RETURN

C  Error exit when too many levels specified.
C  Arrays LWGT, LDIG, and ZLEV are length ICNLEV=500

 5000   ii = ICNLEV
        buff1 = TM_FMT(DBLE(ICNLEV), 0, 20, slen1)
        buff2 = TM_FMT(DBLE(NLEV2), 0, 20, slen2)
        err_msg = '# of shade levels > '// buff1(1:slen1) //
     .          '  (' // buff2(1:slen2) // ')'
        CALL errmsg (ferr_out_of_range, status, err_msg, *5002)
 5002   RETURN
	END




