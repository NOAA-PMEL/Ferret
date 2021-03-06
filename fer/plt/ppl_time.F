	SUBROUTINE PPL_TIME( lo_val, hi_val, cal_id )

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
* send the PLOT+ TIME command with WHOI-formatted dates to PLOT+

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* V300:  10/93 - *sh* extracted logic from AXIS_FORMAT
* V420: 11/27/95 - 4-digit PLOT+ YEARS!!
* V450: 11/14/97 - the arbitrary tstart, 1 year before start of interval,
*	causes the /XLIMITS=lo_date:hi_date to mis-represent the data
*	(see err450_time_xlimits.jnl). Eliminated tstart.
* V530  *acm* cal_id for alternative calendar axis types
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
*       *acm* 3/12 6D Ferret (common uses nferdims in tmap_dims.parm)

        IMPLICIT NONE
	include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'plot_setup.parm'
	include 'xplot_setup.cmn'
* special equivalence needed only with DEC risc compiler: bug fix
        include 'xrisc.cmn'     ! for f77 bug
        CHARACTER rbuff(4)*14
        EQUIVALENCE ( rbuff, risc_buff )


* calling argument declarations:
	REAL*8	  lo_val, hi_val
	INTEGER	  cal_id

* internal variable declarations:
!	REAL*8	  tstart
	CHARACTER ABS_WHOI_DATE*14

* internal parameter declarations
	REAL*8		yrofsecs
	PARAMETER     ( yrofsecs = 60.*60.*24.*365. )

!* set tstart 1 year before the beginning
!	tstart = MAX( 0.0D0, lo_val - yrofsecs )

* TIME command (time axis limits)

              rbuff(1) = ABS_WHOI_DATE( lo_val, cal_id )      ! f77 bug
              rbuff(2) = ABS_WHOI_DATE( hi_val, cal_id )
!              rbuff(3) = ABS_WHOI_DATE( tstart, cal_id )
              WRITE ( ppl_buff, 3020 )  'W'//rbuff(1),
     .                                  'W'//rbuff(2)
!     .                                  'W'//rbuff(3)

! 3020	      FORMAT ('TIME ',A15,',',A15,',',A15)
 3020	      FORMAT ('TIME ',A15,',',A15)
	      CALL PPLCMD ( from, line, 0, ppl_buff, 1, 1 )
	RETURN
      END
