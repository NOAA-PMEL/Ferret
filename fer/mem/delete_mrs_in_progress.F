	SUBROUTINE DELETE_MRS_IN_PROGRESS

*
*
*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration''s (NOAA) Pacific Marine Environmental Lab(PMEL),
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
* delete from memory all in-progress grids ( grids that have been cataloged in
* the memory variable table but whose computation is not yet completed )
* 6/89 - and other temporary data

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* revision 0.0 - 2/25/87
* V200:  6/27/89 - delete temporary variables, too 
* V420: 11/95 - also delete un-cached memory vars
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* V702:  3/17 *sh* dynamic memory
* V720:  4/17 *sh* mr_table_entry_only used by DSGs for line memory cache hits

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'

* internal variable declarations:
	INTEGER	mr

	DO mr = 1, max_mrs

	   IF ( mr_protected( mr ) .EQ. mr_in_progress
     .	   .OR. mr_protected( mr ) .EQ. mr_table_entry_only
     .	   .OR. mr_protected( mr ) .EQ. mr_temporary ) THEN
	      CALL DELETE_VARIABLE( mr )
	   ELSEIF ( mr_protected( mr ) .GT. mr_not_protected ) THEN
	      CALL MR_AVAILABLE(mr) ! use count=0 and onto deletion chain
	   ENDIF

	ENDDO

* also delete un-cached memory variables
	CALL DELETE_UN_CACHED_MVARS

* sanity check that memory management is working correctly
	IF (essential_mem .NE. 0 ) THEN
	   CALL WARN("crptn??: delete_mrs_in_progress")
	   essential_mem = 0
	ENDIF

	RETURN
	END

