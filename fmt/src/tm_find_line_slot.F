	INTEGER*4 FUNCTION TM_FIND_LINE_SLOT ( islot )
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
*
* Locates an unused space in XGRID common for a new line. If no space available,
* returns error.
*
* revision 0.00 - 11/22/88
* revision 1.00 - 12/13/88 - changed to reverse order search
* bug fix - 10/2/91 - inserted comma in statement 9000 right before the *9999.  This error was
*                     caught by version 3 of f77, but not 2.1.    kob
* Arguments
	INTEGER*4	islot
*
* *kob* 10/96 	- Linux port.  Linux didn't like tabs between "include"
*	          and what was being included.  removed them
* V6.74 3/12 *acm* cleanup ifdefs and unnecessary include files

* Parameters and commons
	include 'tmap_dims.parm'
#include "tmap_dset.parm"
	include 'tmap_errors.parm'
	include 'xtm_grid.cmn_text'
	external xgt_grid_data

*
* Local declarations
	CHARACTER*13	TM_STRING
	INTEGER*4	igrd
*
	DO 100 igrd = max_lines,1,-1
	  IF (line_name(igrd) .NE. char_init16) THEN
	    IF (igrd .EQ. max_lines) GOTO 9000
	    islot = igrd + 1
	    GOTO 200
	  ENDIF
  100	CONTINUE
	islot = 1
  200	TM_FIND_LINE_SLOT = merr_ok
	GOTO 9999
*
* No slot available
 9000	CALL TM_ERRMSG (merr_linelim, TM_FIND_LINE_SLOT,
     .	                'TM_FIND_LINE_SLOT', no_descfile, no_stepfile,
     .	                'MAX='//TM_STRING(DBLE(max_lines)), 
     .                   no_errstring,*9999)


 9999	RETURN
	END
