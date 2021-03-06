	SUBROUTINE GKSMV_makedot
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
*	Mod 1.9.90 J Davison to reduce the maximum #pts in any one call to 
*	polyline to 100 as GKS 4.0 under VMS 5.2, i.e., DECWindows, blows up
*	with too many points

*  8/2001  acm  for PLOT/SYMBOL=DOT
*  Version of GKSMV to be called by make_dot.  Call GPM for polymarker
*  rather than GPL (polyline) 
*
*  10/2001 Buffer calls to GPM.  Rename X and Y to xdot, ydot for clarity.
* V73  3/18 *kms*  For clarity, append MD to makedot.cmn values IPT, XDOT, 
*                  and YDOT; make MDOT (99) a makedot.cmn parameter DOTSYMIM
* V741 7/18 *acm*  Issue #1881
*                  Reset IPTMD after the call to plot a buffer's worth pf points

C
C	This routine creates a binary file that can be used to
c	construct device dependent plotting code
c
c
	include 'pltcom_dat.decl'
	include 'PLTCOM.DAT'
	include 'gkscm1_inc.decl'
	include 'GKSCM1.INC'

	IF(.NOT.GKSOPN)THEN
#ifdef core
            call crinit
#else
	    call gkinit
C
	    CALL GCLRWK(WSID,0)
#endif
	    GKSOPN=.TRUE.
	    LPEN=.NOT.PEN
	ENDIF

	IF(PEN)THEN
	  CALL GKPLOT_makedot(A,B,1)
	ELSE
	  CALL GKPLOT_makedot(A,B,0)
	ENDIF

	RETURN
	END

	SUBROUTINE GKPLOT_makedot(XN,YN,IP)
#ifdef core
        if(ip.ne.0)then
            call lineabs2(xn,yn)
        else
            call moveabs2(xn,yn)
        endif
#else
        INCLUDE         'makedot.cmn'    ! 10/01 *acm*

	IF(IP.EQ.0)THEN
	    CALL DOIT_makedot(IPTMD,XDOTMD,YDOTMD)
	    IPTMD=1
	ELSE
	    IPTMD=IPTMD+1
	    IF(IPTMD.GE.MAXDOT)THEN
		CALL DOIT_makedot(IPTMD,XDOTMD,YDOTMD)
		IPTMD=2
		XDOTMD(1)=XDOTMD(MAXDOT)
		YDOTMD(1)=YDOTMD(MAXDOT)
	    ENDIF
	ENDIF
	XDOTMD(IPTMD)=XN
	YDOTMD(IPTMD)=YN
#endif
	RETURN
        END

	SUBROUTINE DOIT_makedot(ipt,xdot,ydot)
	DIMENSION xdot(*),ydot(*)
	IF(ipt.LE.0)RETURN
	IF(ipt.EQ.1)THEN
	    xdot(2)=xdot(1)
	    ydot(2)=ydot(1)
	    ipt=2
	ENDIF
	CALL GPM(ipt,xdot,ydot)
	RETURN
	END
