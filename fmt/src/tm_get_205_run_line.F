	SUBROUTINE TM_GET_205_RUN_LINE ( filename, expno, col_head,
     .					 table_row, status )
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
* This routine will read a row from a file storing information about the
* model runs (and maybe other data sets). It will return column heading
* names, the row of experiment information, and a status key.
*
* Arguments:
*	filename  - file to read from
*	expno     - experiment number for desired info
*	col_head  - a string containing column information (Bottom line)
*	table_row - a string containing experiment information
*	status    - return status
*
* Written 04/26/88 by M. Verschell for PMEL/TMAP
*
* revision 0.00 - 04/27/88
* revision 0.01 - 02/20/89 - Clarified error message 9100
* revision 0.02 -  1/91 *sh* syntax changes to accomodate DEC RISC compiler
*               - and added TM_INQ_PATH with TMAP_RUNS
*
* IBM Port 14apr94 *kob* : READONLY not allowed in file open statments.  Added
*			   an "#ifdef READONLY_ALLOWED"
* V6.74 3/12 *acm* cleanup ifdefs and unnecessary include files

* Include files
	include 'tmap_errors.parm'
        include 'xsys_names.cmn_text'
        external xsys_names_data

* Argument definitions
	CHARACTER*(*)	filename, expno, col_head, table_row
	INTEGER*4	status

* Local Definitions 
	CHARACTER*132	TM_INQ_PATH, buffer
	INTEGER*4	lunit, explen
	INTEGER*4	TM_LENSTR1
	integer		flen	!  for RISC compiler
	character*4	buff4

* for RISC compiler: can't concatenate with CHAR*(*) variable
	flen = MIN( LEN(filename), 132 )	! 132 is buffer size

* locate the data base file (use "buffer" to store the path name temporarily)
        buffer = TM_INQ_PATH( filename, tmap_model_runs, ' ',
     .                        .TRUE., status )
        IF ( status .NE. merr_ok ) GOTO 9999

* Get available logical unit
	CALL LIB_GET_LUN ( lunit )

* Look for filename and open it
	OPEN	( UNIT=lunit,
     .		  FILE=buffer,
     .		  STATUS='OLD',
#ifdef READONLY_ALLOWED
     .		  READONLY,
#endif
     .		  ERR=9000 )

* Now search for the bottom line of the column headings
  100	READ	( lunit, '(A132)', END=9100 ) buffer
	IF ( INDEX(buffer,'=====') .EQ. 0 ) THEN
          col_head = buffer
	  GOTO 100
	ENDIF

* We found the column headings, search for the experiment info
	explen = TM_LENSTR1(expno)
  110	READ	( lunit, '(A132)', END=9200 ) buffer
	IF ( INDEX(buffer(1:10),expno(1:explen)) .EQ. 0 ) GOTO 110
	table_row = buffer
	GOTO 9900

* ERROR - opening filename
 9000	buffer = filename
	CALL TM_ERRMSG ( merr_erreq, status, 'TM_GET_205_RUN_LINE',
     .			 no_descfile, no_stepfile, 'FILE='//buffer(:flen),
     .			 no_errstring, *9999 )

* ERROR - searching for column headings
 9100	buffer = filename
	CALL TM_ERRMSG ( merr_eof, status, 'TM_GET_205_RUN_LINE',
     .			 no_descfile, no_stepfile, 'FILE='//buffer(:flen)//
     .			 '. File not a correct Parameter file.',
     .			 no_errstring, *9990 )

* ERROR - searching for column headings
 9200	buffer = filename
	explen = MIN( explen, 4 )
	buff4 = expno
	CALL TM_ERRMSG ( merr_eof, status, 'TM_GET_205_RUN_LINE',
     .			 no_descfile, no_stepfile,'FILE='//buffer(:flen)//
     .			 ' Experiment "'//buff4(:explen)//'" not found',
     .			 no_errstring, *9990 )

* Status set
 9900	status = merr_ok

* Close file
 9990	CLOSE	( lunit, ERR=9000 )

* Bye bye
 9999	RETURN
	END
