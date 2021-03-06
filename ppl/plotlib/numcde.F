	SUBROUTINE NUMCDE(XZ,STR,LETTER,NC,FRMTZ,DMS)
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
* revised for TMAP
* from PPLUS :
*	Directory PMEL:[PLOT5.PPLV11.PLOTLIB]NUMCDE.FOR

* search for "TMAP" to find all revisions
* *sh*  - 2/13/89 - added MOD 360. to LONE formatting
*		  ... no explicit declarations (too much trouble !) so it must
*		      be compiled with /WARNINGS=NODECLARATIONS
* *acm* - 1/ 6/04 - For longitude axes, do not label 0 degrees with E
*            (so they are now consistent with latitude axes)
* V600: *acm* 11/05 add xdms,ydms for deg/min labels
* V600: *acm* 5/06 Allow seconds in DMS axis labelling; had removed this.
* V63  *acm* 10/09 Changes for gfortran build
* V7    *acm* 6/16 Ticket 2434: command qualifiers /DEGMINSEC= /HALFSPAC
*                  DEGMINSEC=1 for Deg-Min axis labels, =2 for Deg-Min-Sec. Default = 1
*                  /HALFSPAC adds a half space between the degree sign and E/W or N/S


C**
C**    @(#)numcde.f	1.1    3/10/88
C**
C**
C***********************************************************************
C**
C**                 PLOT+ Scientific Graphics System
C**
C***********************************************************************
C**
C**
C     ROUTINE ADDS LEADING ZEROS TO A NUMBER IF
C     LESS THAN ONE AND IFRMT=('0'....
C
c  Modified so that if FRMTZ has ",'LAT')" or ",'LON')" as last non-blank
c  characters, XZ will be assumed to be either latitude (+ for N, - for S)
c  or longitude (+0 to +180 for W, +180 to +360 for E, ie, continuous across
c  dateline) in EPIC format. FRMT and X will be modified so that axis labels
c  will be of the form 165 E or 6 S, etc.
c  NNS, Jun 85.
c
	CHARACTER*(*) FRMTZ
	CHARACTER*20 FRMT,STR,TEMP,STR_DMS
	CHARACTER*1  LETTER
        INTEGER TM_LENSTR1, dms, imin, isec, dot, deg
        REAL val, frac, minutes, seconds
C
	FRMT=FRMTZ
	TEMP=FRMTZ
	CALL UPPER(TEMP,20)
	X=XZ
	ILAT = INDEX (TEMP, ',''LAT'')')
	IF (ILAT .NE. 0) THEN
	  FRMT (ILAT+1:) = '''#'')'
	  IF (X .LT. 0) THEN
	    X=-X
	    LETTER = 'S'
	  ELSE IF (X .EQ. 0.) THEN
	    LETTER = ' '
	  ELSE
	    LETTER = 'N'
	  ENDIF
	ELSE
	  ILON = INDEX (TEMP, ',''LON'')') + INDEX (TEMP, ',''LONW'')')
	  ILONE = INDEX (TEMP, ',''LONE'')')
	  IF (ILON .NE. 0) THEN
	    FRMT (ILON+1:) = '''#'')'
	    IF (X .GT. 180.) THEN
	      X=360.-X
	      LETTER = 'E'
	    ELSE IF (X .EQ. 180.) THEN
	      LETTER = ' '
	    ELSE IF (X .LT. 0.) THEN
	      LETTER = 'E'
	      X = -X
	    ELSE
	      LETTER = 'W'
	    ENDIF
	  ELSE IF (ILONE .NE. 0)THEN
* TMAP insert 2/13/89
* Further fixes for X LE -180  1/18/2013

	    X = MOD( X, 360. )
* ... end of TMAP insert
	    FRMT (ILONE+1:) = '''#'')'
	    IF (X .GT.180.) THEN
	      X=360.-X
	      LETTER = 'W'
	    ELSE IF (ABS(X) .EQ. 180.) THEN
	      LETTER = ' '
	      X = ABS(X)
	    ELSE IF (X .LT. -180.) THEN
	      LETTER = 'E'
	      X = 360.+X
	    ELSE IF (X .LT. 0.) THEN
	      LETTER = 'W'
	      X = -X
	    ELSE IF (X .NE. 0.) THEN
	      LETTER = 'E'
            ELSE
	      LETTER = ' '
	    ENDIF
	  ENDIF
	ENDIF
C
	FLAG=0
	IF(FRMT(1:2).EQ.'(I'.OR.FRMT(1:2).EQ.'(i')THEN
	    WRITE(STR,FRMT)IFIX(X+SIGN(.5,X))
	ELSE
	    WRITE(STR,FRMT)X
	END IF
C     STRIP OFF LEADING ZERO AND SET FLAG
	IF(FRMT(1:4).EQ.'(''0''')THEN
	    TEMP=STR(2:20)
	    STR=TEMP
	    FLAG=1
	END IF
C     LEFT JUSTIFY STRING
	NC=0
100	IF(STR(1:1).EQ.' ')THEN
	    TEMP=STR(2:20)
	    STR=TEMP
	    NC=NC+1
	    IF(NC.LE.20)GOTO 100
	END IF
C     ADD LEADING ZERO
	IF(FLAG.EQ.1.AND.ABS(X).LT.1.1)THEN
	    IF(STR(1:1).EQ.'.')THEN
		TEMP='0'
		TEMP(2:)=STR(1:19)
	    ENDIF
	    IF(STR(1:2).EQ.'+.'.OR.STR(1:2).EQ.'-.')THEN
		TEMP=STR(1:1)
		TEMP(2:2)='0'
		TEMP(3:)=STR(2:18)
	    ENDIF
	    STR=TEMP
	END IF
	NC=LNBLK(STR,20)

* Reformat the value into deg,min,sec if requested.
* This means moving the degree symbol after the degrees
* and putting the direction (N,S,E,W) at the end
* For longitudes larger than 180, format them as is and
* translate to west longitude afterwards.
 
        STR_DMS = ' '
        IF (dms .GE. 1) THEN
            
           dot = INDEX(str,'.')
           deg = INDEX(str,'#')
           IF (dot .EQ. 0) dot = TM_LENSTR1(str) +1
           val = xz
           IF (xz .LT. 0) val = x

           ideg = INT(val)
           frac = val - FLOAT(ideg)
           minutes = 60.*frac
           imin = INT(minutes+0.1)  ! sun at least, turns 40 into 39 sometimes...
           frac = minutes - FLOAT(imin)
           seconds = 60.* frac
           isec = INT(seconds+0.1)

           IF (xz .GT. 180.) THEN
              ideg = 360-ideg
              imin = 60-imin
           ENDIF

           IF (dms .EQ. 2) THEN  ! write as deg,min,sec
              IF (ideg .LT. 100) THEN
                 WRITE (STR_DMS, 1100) ideg, imin, isec
              ELSE
                 WRITE (STR_DMS, 1101) ideg, imin, isec
              ENDIF
1100          FORMAT (I2.2, '#', I2.2, '''', I2.2, '''', '''')
1101          FORMAT (I3.3, '#', I2.2, '''', I2.2, '''', '''')

           ELSE IF (dms .EQ. 1) THEN  ! break into deg,min
              IF (ideg .LT. 100) THEN
                 WRITE (STR_DMS, 1200) ideg, imin
              ELSE
                 WRITE (STR_DMS, 1201) ideg, imin
              ENDIF
1200          FORMAT (I2.2, '#', I2.2, '''')
1201          FORMAT (I3.3, '#', I2.2, '''')

           ELSE IF (dms .EQ. 3) THEN  ! write as deg,min.frac

* get number of digits from the format given by the format that came into this routine.
* seeing if it is Fn.m.  If M=0, use minutes only. If M=1, then use one digit for the 
* fractional part of the mintues, otherwise write two digits. Round rather than truncating
* for degrees and fractions.

              dot = INDEX(frmtz,'.')
              READ (frmtz(dot+1:dot+1), *) digits
              IF (digits .EQ. 0) THEN   ! degrees, minutes only
                 imin = INT(minutes+0.5)
                 IF (ideg .LT. 100) THEN
                    WRITE (STR_DMS, 1300) ideg, imin
                 ELSE
                    WRITE (STR_DMS, 1301) ideg, imin
                 ENDIF
1300             FORMAT (I2.2, '#', I2.2, '''')
1301             FORMAT (I3.3, '#', I2.2, '''')
              ELSE IF (digits .EQ. 1) THEN  ! degrees,min.f

                 IF (ideg .LT. 100) THEN
                    WRITE (STR_DMS, 1400) ideg, minutes
                 ELSE
                    WRITE (STR_DMS, 1401) ideg, minutes
                 ENDIF
1400             FORMAT (I2.2, '#', F4.1, '''')
1401             FORMAT (I3.3, '#', F4.1, '''')
              ELSE                          ! degrees,min.ff
                 IF (ideg .LT. 100) THEN
                    WRITE (STR_DMS, 1500) ideg, minutes
                 ELSE
                    WRITE (STR_DMS, 1501) ideg, minutes
                 ENDIF
1500             FORMAT (I2.2, '#', F5.2, '''')
1501             FORMAT (I3.3, '#', F5.2, '''')
              ENDIF

           ELSE 
              STR_DMS = str
           ENDIF
           str = STR_DMS
           NC=LNBLK(STR,20)

        ENDIF

	RETURN
	END
