	SUBROUTINE MR_IN_USE ( mr )

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
* flag that the specified variable is in use as a component of a calculation
* and is therefore not available to be deleted
* (multiple calculations can claim the same component by incrementing the
* protection counter)

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program
* written for VAX computer under VMS operating system
*
* V200:  6/12/89
*        2/12 *kms* Add E and F dimensions (use nferdims in tmap_dims.parm)
* V702 12/16 *sh* doc change only

        IMPLICIT NONE
        include 'tmap_dims.parm'
	include 'ferret.parm'
	include 'xvariables.cmn'

* calling argument declarations:
	INTEGER mr

* internal variable declarations:
	INTEGER prev, next

* remove it from the deletion chain if it is in there
	IF ( mr_protected(mr) .EQ. mr_not_protected ) THEN
	   prev = mr_del_blink(mr)
	   next = mr_del_flink(mr)
	   mr_del_flink(prev) = next
	   mr_del_blink(next) = prev
	   mr_del_flink(mr)   = unspecified_int4	! important 12/16
	   mr_del_blink(mr)   = unspecified_int4	! important 12/16
* ... changing to "in use" makes it "essential memory"
	   essential_mem = essential_mem + mr_size(mr)
	   IF (essential_mem.GT.peak_essential_mem) 
     .		peak_essential_mem = essential_mem

	ELSEIF ( mr_protected(mr) .EQ. mr_in_progress ) THEN
	   mr_protected(mr) = mr_not_protected  ! to be incremented just below
* ... mr_in_progress vars are already considered "essential memory"
	ENDIF

* bump claims counter
	IF ( mr_protected(mr) .GE. mr_not_protected ) 
     .		mr_protected(mr) = mr_protected(mr) + 1
	   
	RETURN
	END

