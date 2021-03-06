* 
*  closest_in_zlist.F
* 
*  Steve Hankin
*  12/27/2000
* 
*  Compress argument 1 along axis I by the mask given in argument 2
*  Argument 2 may be multidimensional
 
*  In this subroutine we provide information about
*  the function.  The user configurable information 
*  consists of the following:
* 
*  descr              Text description of the function
* 
*  num_args           Required number of arguments
* 
*  axis_inheritance   Type of axis for the result
*                        ( CUSTOM, IMPLIED_BY_ARGS, NORMAL, ABSTRACT )
*                        CUSTOM          - user defined axis
*                        IMPLIED_BY_ARGS - same axis as the incoming argument
*                        NORMAL          - the result is normal to this axis
*                        ABSTRACT        - an axis which only has index values
* 
*  piecemeal_ok       For memory optimization:
*                        axes where calculation may be performed piecemeal
*                        ( YES, NO )
* 
*
* For each argument we provide the following information:
*
* name               Text name for an argument
*
* unit               Text units for an argument
*
* desc               Text description of an argument
*
* axis_influence     Are this argument's axes the same as the result grid?
*                       ( YES, NO )
*
* axis_extend       How much does Ferret need to extend arg limits relative to result 
*


      SUBROUTINE closest_in_zlist_init(id)

      INCLUDE 'ferret_cmn/EF_Util.cmn'

      INTEGER id, arg

* **********************************************************************
*                                            USER CONFIGURABLE PORTION |
*                                                                      |
*                                                                      V

      CALL ef_set_desc(id,
     .          'Find the value in zlist that is closest to target' )

      CALL ef_set_num_args(id, 2)
      CALL ef_set_has_vari_args(id, NO)
      CALL ef_set_axis_inheritance(id, IMPLIED_BY_ARGS, 
     .     IMPLIED_BY_ARGS, IMPLIED_BY_ARGS, IMPLIED_BY_ARGS)
      CALL ef_set_piecemeal_ok(id, NO, NO, NO, NO)

      arg = 1
      CALL ef_set_arg_name(id, arg, 'target')
      CALL ef_set_arg_desc(id, arg,
     .          'value(s) to look for - Z-increasing sorted')
      CALL ef_set_axis_influence(id, arg, YES, YES, YES, YES)

      arg = 2
      CALL ef_set_arg_name(id, arg, 'zlist')
      CALL ef_set_arg_desc(id, arg,
     .          'set of candidate values - Z-increasing sorted')
      CALL ef_set_axis_influence(id, arg, YES, YES, NO, YES)
*                                                                      ^
*                                                                      |
*                                            USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 
      END






*
* In this subroutine we provide information about the lo and hi
* limits associated with each abstract or custom axis.   The user 
* configurable information consists of the following:
*
* lo_ss               lo subscript for an axis
*
* hi_ss               hi subscript for an axis
*

      SUBROUTINE closest_in_zlist_result_limits(id)

      INCLUDE 'ferret_cmn/EF_Util.cmn'

      INTEGER id

* **********************************************************************
*                                           USER CONFIGURABLE PORTION |
*                                                                     |
*                                                                     V


*                                                                     ^
*                                                                     |
*                                           USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 
      END



* 
*  In this subroutine we compute the result
* 
      SUBROUTINE closest_in_zlist_compute(id, target, zlist, result)

      INCLUDE 'ferret_cmn/EF_Util.cmn'
      INCLUDE 'ferret_cmn/EF_mem_subsc.cmn'

      INTEGER id

      REAL bad_flag(EF_MAX_ARGS), bad_flag_result
      REAL target(mem1lox:mem1hix, mem1loy:mem1hiy,
     .	   mem1loz:mem1hiz, mem1lot:mem1hit)
      REAL zlist(mem2lox:mem2hix, mem2loy:mem2hiy,
     .     mem2loz:mem2hiz, mem2lot:mem2hit)
      REAL result(memreslox:memreshix, memresloy:memreshiy,
     .     memresloz:memreshiz, memreslot:memreshit)

* After initialization, the 'res_' arrays contain indexing information 
* for the result axes.  The 'arg_' arrays will contain the indexing 
* information for each variable's axes. 

      INTEGER res_lo_ss(4), res_hi_ss(4), res_incr(4)
      INTEGER arg_lo_ss(4,EF_MAX_ARGS), arg_hi_ss(4,EF_MAX_ARGS),
     .     arg_incr(4,EF_MAX_ARGS)


* **********************************************************************
*                                            USER CONFIGURABLE PORTION |
*                                                                      |
*                                                                      V

      INTEGER i,j,k,l
      INTEGER i1, j1, k1, l1
      INTEGER i2, j2, k2, l2, k2lo
      REAL dlo, dhi

      CALL ef_get_res_subscripts(id, res_lo_ss, res_hi_ss, res_incr)
      CALL ef_get_arg_subscripts(id, arg_lo_ss, arg_hi_ss, arg_incr)
      CALL ef_get_bad_flags(id, bad_flag, bad_flag_result)

* pre-check that the zlist array has no missing values
      DO 10 l = arg_lo_ss(T_AXIS,ARG2), arg_hi_ss(T_AXIS,ARG2)
      DO 10 k = arg_lo_ss(Z_AXIS,ARG2), arg_hi_ss(Z_AXIS,ARG2)
      DO 10 j = arg_lo_ss(Y_AXIS,ARG2), arg_hi_ss(Y_AXIS,ARG2)
      DO 10 i = arg_lo_ss(X_AXIS,ARG2), arg_hi_ss(X_AXIS,ARG2)
        IF (zlist(i,j,k,l) .EQ. bad_flag(2)) CALL
     .             EF_BAIL_OUT(id, 'Missing value found in zlist')
 10   CONTINUE

* pre-check that the zlist array is z-sorted
      DO 25 l = arg_lo_ss(T_AXIS,ARG2), arg_hi_ss(T_AXIS,ARG2)
      DO 25 j = arg_lo_ss(Y_AXIS,ARG2), arg_hi_ss(Y_AXIS,ARG2)
      DO 25 i = arg_lo_ss(X_AXIS,ARG2), arg_hi_ss(X_AXIS,ARG2)
        IF (arg_hi_ss(Z_AXIS,ARG2) .GT.  arg_lo_ss(Z_AXIS,ARG2)) THEN
          DO 20 k = arg_lo_ss(Z_AXIS,ARG2)+1, arg_hi_ss(Z_AXIS,ARG2)
            IF (zlist(i,j,k,l) .LT.zlist(i,j,k-1,l) ) CALL
     .             EF_BAIL_OUT(id, 'Unsorted values in zlist')
 20       CONTINUE
        ENDIF
 25   CONTINUE

* pre-check that the target array is z-sorted
      DO 35 l = arg_lo_ss(T_AXIS,ARG1), arg_hi_ss(T_AXIS,ARG1)
      DO 35 j = arg_lo_ss(Y_AXIS,ARG1), arg_hi_ss(Y_AXIS,ARG1)
      DO 35 i = arg_lo_ss(X_AXIS,ARG1), arg_hi_ss(X_AXIS,ARG1)
        IF (arg_hi_ss(Z_AXIS,ARG1) .GT.  arg_lo_ss(Z_AXIS,ARG1)) THEN
          DO 32 k = arg_lo_ss(Z_AXIS,ARG1)+1, arg_hi_ss(Z_AXIS,ARG1)
            IF (target(i,j,k,l) .EQ. bad_flag(1)) THEN
               DO 30 k2 = k+1, arg_hi_ss(Z_AXIS,ARG1)
                 IF (target(i,j,k2,l) .NE. bad_flag(1)) CALL EF_BAIL_OUT
     .                 (id, 'Z-unsorted missing values in target array')
 30            CONTINUE
               GOTO 35
            ENDIF
            IF (target(i,j,k,l) .LT.target(i,j,k-1,l) ) CALL
     .             EF_BAIL_OUT(id, 'Z-unsorted values in target array')
 32      CONTINUE
        ENDIF
 35   CONTINUE

* fill in the points as specified by the mask
      l1 = arg_lo_ss(T_AXIS,ARG1)
      l2 = arg_lo_ss(T_AXIS,ARG2)
      DO 400 l=res_lo_ss(T_AXIS), res_hi_ss(T_AXIS)

        j1 = arg_lo_ss(Y_AXIS,ARG1)
        j2 = arg_lo_ss(Y_AXIS,ARG2)
        DO 300 j=res_lo_ss(Y_AXIS), res_hi_ss(Y_AXIS)

          i1 = arg_lo_ss(X_AXIS,ARG1)
          i2 = arg_lo_ss(X_AXIS,ARG2)
          DO 200 i=res_lo_ss(X_AXIS), res_hi_ss(X_AXIS)

            k2lo = arg_lo_ss(Z_AXIS,ARG2)  ! best prospect for zlist < target
            DO 100 k1=res_lo_ss(Z_AXIS), res_hi_ss(Z_AXIS)
              IF (target(i1,j1,k1,l1) .EQ. bad_flag(1)) THEN
                 result(i,j,k1,l) = bad_flag_result
                 GOTO 100
              ENDIF
* ... find first value in zlist greater than the target
              DO 50 k2 = k2lo+1, arg_hi_ss(Z_AXIS,ARG2)
                IF (zlist(i2,j2,k2,l2) .GE. target(i1,j1,k1,l1)) THEN
                  dlo = target(i1,j1,k1,l1) - zlist(i2,j2,k2lo,l2)
                  dhi = zlist(i2,j2,k2,l2)  - target(i1,j1,k1,l1)
                  IF ( ABS(dlo) .LE. ABS(dhi) ) THEN
                     result(i,j,k1,l) = zlist(i2,j2,k2lo,l2)
                  ELSE
                     result(i,j,k1,l) = zlist(i2,j2,k2,l2)
                  ENDIF
                  GOTO 100
                ELSE
                  k2lo = k2
                ENDIF
 50           CONTINUE

              result(i,j,k1,l) = zlist(i2,j2,k2lo,l2) ! top value in zlist
 100        CONTINUE

            i1 = i1 + arg_incr(X_AXIS,ARG1)
            i2 = i2 + arg_incr(X_AXIS,ARG2)
 200      CONTINUE

          j1 = j1 + arg_incr(Y_AXIS,ARG1)
          j2 = j2 + arg_incr(Y_AXIS,ARG2)
 300    CONTINUE

        l1 = l1 + arg_incr(T_AXIS,ARG1)
        l2 = l2 + arg_incr(T_AXIS,ARG2)
 400  CONTINUE
      
         
*                                                                      ^
*                                                                      |
*                                            USER CONFIGURABLE PORTION |
* **********************************************************************

      RETURN 
      END

