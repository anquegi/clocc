      SUBROUTINE HWSSSP (TS,TF,M,MBDCND,BDTS,BDTF,PS,PF,N,NBDCND,BDPS,
     1                   BDPF,ELMBDA,F,IDIMF,PERTRB,IERROR,W)
C
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C     *                                                               *
C     *                        F I S H P A K                          *
C     *                                                               *
C     *                                                               *
C     *     A PACKAGE OF FORTRAN SUBPROGRAMS FOR THE SOLUTION OF      *
C     *                                                               *
C     *      SEPARABLE ELLIPTIC PARTIAL DIFFERENTIAL EQUATIONS        *
C     *                                                               *
C     *                  (VERSION 3.1 , OCTOBER 1980)                  *
C     *                                                               *
C     *                             BY                                *
C     *                                                               *
C     *        JOHN ADAMS, PAUL SWARZTRAUBER AND ROLAND SWEET         *
C     *                                                               *
C     *                             OF                                *
C     *                                                               *
C     *         THE NATIONAL CENTER FOR ATMOSPHERIC RESEARCH          *
C     *                                                               *
C     *                BOULDER, COLORADO  (80307)  U.S.A.             *
C     *                                                               *
C     *                   WHICH IS SPONSORED BY                       *
C     *                                                               *
C     *              THE NATIONAL SCIENCE FOUNDATION                  *
C     *                                                               *
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C     SUBROUTINE HWSSSP SOLVES A FINITE DIFFERENCE APPROXIMATION TO THE
C     HELMHOLTZ EQUATION IN SPHERICAL COORDINATES AND ON THE SURFACE OF
C     THE UNIT SPHERE (RADIUS OF 1):
C
C          (1/SIN(THETA))(D/DTHETA)(SIN(THETA)(DU/DTHETA))
C
C             + (1/SIN(THETA)**2)(D/DPHI)(DU/DPHI)
C
C             + LAMBDA*U = F(THETA,PHI)
C
C     WHERE THETA IS COLATITUDE AND PHI IS LONGITUDE.
C
C     * * * * * * * *    PARAMETER DESCRIPTION     * * * * * * * * * *
C
C             * * * * * *   ON INPUT    * * * * * *
C
C     TS,TF
C       THE RANGE OF THETA (COLATITUDE), I.E., TS .LE. THETA .LE. TF.
C       TS MUST BE LESS THAN TF.  TS AND TF ARE IN RADIANS.  A TS OF
C       ZERO CORRESPONDS TO THE NORTH POLE AND A TF OF PI CORRESPONDS TO
C       THE SOUTH POLE.
C
C     * * * * * * * * * * * * * * IMPORTANT * * * * * * * * * * * * * *
C
C     IF TF IS EQUAL TO PI THEN IT MUST BE COMPUTED USING THE STATEMENT
C     TF = PIMACH(DUM). THIS INSURES THAT TF IN THE USERS PROGRAM IS
C     EQUAL TO PI IN THIS PROGRAM WHICH PERMITS SEVERAL TESTS OF THE
C     INPUT PARAMETERS THAT OTHERWISE WOULD NOT BE POSSIBLE.
C
C
C     M
C       THE NUMBER OF PANELS INTO WHICH THE INTERVAL (TS,TF) IS
C       SUBDIVIDED.  HENCE, THERE WILL BE M+1 GRID POINTS IN THE
C       THETA-DIRECTION GIVEN BY THETA(I) = (I-1)DTHETA+TS FOR
C       I = 1,2,...,M+1, WHERE DTHETA = (TF-TS)/M IS THE PANEL WIDTH.
C       M MUST BE GREATER THAN 5
C
C     MBDCND
C       INDICATES THE TYPE OF BOUNDARY CONDITION AT THETA = TS AND
C       THETA = TF.
C
C       = 1  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THETA = TF.
C       = 2  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THE
C            DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TF (SEE NOTE 2 BELOW).
C       = 3  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS AND THETA = TF (SEE NOTES 1,2
C            BELOW).
C       = 4  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS (SEE NOTE 1 BELOW) AND THE
C            SOLUTION IS SPECIFIED AT THETA = TF.
C       = 5  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND THE
C            SOLUTION IS SPECIFIED AT THETA = TF.
C       = 6  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND THE
C            DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TF (SEE NOTE 2 BELOW).
C       = 7  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THE
C            SOLUTION IS UNSPECIFIED AT THETA = TF = PI.
C       = 8  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS (SEE NOTE 1 BELOW) AND THE
C            SOLUTION IS UNSPECIFIED AT THETA = TF = PI.
C       = 9  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND
C            THETA = TF = PI.
C
C       NOTES:  1.  IF TS = 0, DO NOT USE MBDCND = 3,4, OR 8, BUT
C                   INSTEAD USE MBDCND = 5,6, OR 9  .
C               2.  IF TF = PI, DO NOT USE MBDCND = 2,3, OR 6, BUT
C                   INSTEAD USE MBDCND = 7,8, OR 9  .
C
C     BDTS
C       A ONE-DIMENSIONAL ARRAY OF LENGTH N+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA AT
C       THETA = TS.  WHEN MBDCND = 3,4, OR 8,
C
C            BDTS(J) = (D/DTHETA)U(TS,PHI(J)), J = 1,2,...,N+1  .
C
C       WHEN MBDCND HAS ANY OTHER VALUE, BDTS IS A DUMMY VARIABLE.
C
C     BDTF
C       A ONE-DIMENSIONAL ARRAY OF LENGTH N+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA AT
C       THETA = TF.  WHEN MBDCND = 2,3, OR 6,
C
C            BDTF(J) = (D/DTHETA)U(TF,PHI(J)), J = 1,2,...,N+1  .
C
C       WHEN MBDCND HAS ANY OTHER VALUE, BDTF IS A DUMMY VARIABLE.
C
C     PS,PF
C       THE RANGE OF PHI (LONGITUDE), I.E., PS .LE. PHI .LE. PF.  PS
C       MUST BE LESS THAN PF.  PS AND PF ARE IN RADIANS.  IF PS = 0 AND
C       PF = 2*PI, PERIODIC BOUNDARY CONDITIONS ARE USUALLY PRESCRIBED.
C
C     * * * * * * * * * * * * * * IMPORTANT * * * * * * * * * * * * * *
C
C     IF PF IS EQUAL TO 2*PI THEN IT MUST BE COMPUTED USING THE
C     STATEMENT PF = 2.*PIMACH(DUM). THIS INSURES THAT PF IN THE USERS
C     PROGRAM IS EQUAL TO 2*PI IN THIS PROGRAM WHICH PERMITS TESTS OF
C     THE INPUT PARAMETERS THAT OTHERWISE WOULD NOT BE POSSIBLE.
C
C
C     N
C       THE NUMBER OF PANELS INTO WHICH THE INTERVAL (PS,PF) IS
C       SUBDIVIDED.  HENCE, THERE WILL BE N+1 GRID POINTS IN THE
C       PHI-DIRECTION GIVEN BY PHI(J) = (J-1)DPHI+PS  FOR
C       J = 1,2,...,N+1, WHERE DPHI = (PF-PS)/N IS THE PANEL WIDTH.
C       N MUST BE GREATER THAN 4
C
C     NBDCND
C       INDICATES THE TYPE OF BOUNDARY CONDITION AT PHI = PS AND
C       PHI = PF.
C
C       = 0  IF THE SOLUTION IS PERIODIC IN PHI, I.E.,
C            U(I,J) = U(I,N+J).
C       = 1  IF THE SOLUTION IS SPECIFIED AT PHI = PS AND PHI = PF
C            (SEE NOTE BELOW).
C       = 2  IF THE SOLUTION IS SPECIFIED AT PHI = PS (SEE NOTE BELOW)
C            AND THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO PHI IS
C            SPECIFIED AT PHI = PF.
C       = 3  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO PHI IS
C            SPECIFIED AT PHI = PS AND PHI = PF.
C       = 4  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO PHI IS
C            SPECIFIED AT PS AND THE SOLUTION IS SPECIFIED AT PHI = PF
C            (SEE NOTE BELOW).
C
C       NOTE:  NBDCND = 1,2, OR 4 CANNOT BE USED WITH
C              MBDCND = 5,6,7,8, OR 9 (THE FORMER INDICATES THAT THE
C                       SOLUTION IS SPECIFIED AT A POLE, THE LATTER
C                       INDICATES THAT THE SOLUTION IS UNSPECIFIED).
C                       USE INSTEAD
C              MBDCND = 1 OR 2  .
C
C     BDPS
C       A ONE-DIMENSIONAL ARRAY OF LENGTH M+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO PHI AT
C       PHI = PS.  WHEN NBDCND = 3 OR 4,
C
C            BDPS(I) = (D/DPHI)U(THETA(I),PS), I = 1,2,...,M+1  .
C
C       WHEN NBDCND HAS ANY OTHER VALUE, BDPS IS A DUMMY VARIABLE.
C
C     BDPF
C       A ONE-DIMENSIONAL ARRAY OF LENGTH M+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO PHI AT
C       PHI = PF.  WHEN NBDCND = 2 OR 3,
C
C            BDPF(I) = (D/DPHI)U(THETA(I),PF), I = 1,2,...,M+1  .
C
C       WHEN NBDCND HAS ANY OTHER VALUE, BDPF IS A DUMMY VARIABLE.
C
C     ELMBDA
C       THE CONSTANT LAMBDA IN THE HELMHOLTZ EQUATION.  IF
C       LAMBDA .GT. 0, A SOLUTION MAY NOT EXIST.  HOWEVER, HWSSSP WILL
C       ATTEMPT TO FIND A SOLUTION.
C
C     F
C       A TWO-DIMENSIONAL ARRAY THAT SPECIFIES THE VALUE OF THE RIGHT
C       SIDE OF THE HELMHOLTZ EQUATION AND BOUNDARY VALUES (IF ANY).
C       FOR I = 2,3,...,M  AND  J = 2,3,...,N
C
C            F(I,J) = F(THETA(I),PHI(J)).
C
C       ON THE BOUNDARIES F IS DEFINED BY
C
C            MBDCND   F(1,J)            F(M+1,J)
C            ------   ------------      ------------
C
C              1      U(TS,PHI(J))      U(TF,PHI(J))
C              2      U(TS,PHI(J))      F(TF,PHI(J))
C              3      F(TS,PHI(J))      F(TF,PHI(J))
C              4      F(TS,PHI(J))      U(TF,PHI(J))
C              5      F(0,PS)           U(TF,PHI(J))   J = 1,2,...,N+1
C              6      F(0,PS)           F(TF,PHI(J))
C              7      U(TS,PHI(J))      F(PI,PS)
C              8      F(TS,PHI(J))      F(PI,PS)
C              9      F(0,PS)           F(PI,PS)
C
C            NBDCND   F(I,1)            F(I,N+1)
C            ------   --------------    --------------
C
C              0      F(THETA(I),PS)    F(THETA(I),PS)
C              1      U(THETA(I),PS)    U(THETA(I),PF)
C              2      U(THETA(I),PS)    F(THETA(I),PF)   I = 1,2,...,M+1
C              3      F(THETA(I),PS)    F(THETA(I),PF)
C              4      F(THETA(I),PS)    U(THETA(I),PF)
C
C       F MUST BE DIMENSIONED AT LEAST (M+1)*(N+1).
C       NOTE
C
C       IF THE TABLE CALLS FOR BOTH THE SOLUTION U AND THE RIGHT SIDE F
C       AT  A CORNER THEN THE SOLUTION MUST BE SPECIFIED.
C
C
C     IDIMF
C       THE ROW (OR FIRST) DIMENSION OF THE ARRAY F AS IT APPEARS IN THE
C       PROGRAM CALLING HWSSSP.  THIS PARAMETER IS USED TO SPECIFY THE
C       VARIABLE DIMENSION OF F.  IDIMF MUST BE AT LEAST M+1  .
C
C     W
C       A ONE-DIMENSIONAL ARRAY THAT MUST BE PROVIDED BY THE USER FOR
C       WORK SPACE. W MAY REQUIRE UP TO 4*(N+1)+(16+INT(LOG2(N+1)))(M+1)
C       LOCATIONS. THE ACTUAL NUMBER OF LOCATIONS USED IS COMPUTED BY
C       HWSSSP AND IS OUTPUT IN LOCATION W(1). INT( ) DENOTES THE
C       FORTRAN INTEGER FUNCTION.
C
C
C     * * * * * * * * * *     ON OUTPUT     * * * * * * * * * *
C
C     F
C       CONTAINS THE SOLUTION U(I,J) OF THE FINITE DIFFERENCE
C       APPROXIMATION FOR THE GRID POINT (THETA(I),PHI(J)),
C       I = 1,2,...,M+1,   J = 1,2,...,N+1  .
C
C     PERTRB
C       IF ONE SPECIFIES A COMBINATION OF PERIODIC, DERIVATIVE OR
C       UNSPECIFIED BOUNDARY CONDITIONS FOR A POISSON EQUATION
C       (LAMBDA = 0), A SOLUTION MAY NOT EXIST.  PERTRB IS A CONSTANT,
C       CALCULATED AND SUBTRACTED FROM F, WHICH ENSURES THAT A SOLUTION
C       EXISTS.  HWSSSP THEN COMPUTES THIS SOLUTION, WHICH IS A LEAST
C       SQUARES SOLUTION TO THE ORIGINAL APPROXIMATION.  THIS SOLUTION
C       IS NOT UNIQUE AND IS UNNORMALIZED. THE VALUE OF PERTRB SHOULD
C       BE SMALL COMPARED TO THE RIGHT SIDE F. OTHERWISE , A SOLUTION
C       IS OBTAINED TO AN ESSENTIALLY DIFFERENT PROBLEM. THIS COMPARISON
C       SHOULD ALWAYS BE MADE TO INSURE THAT A MEANINGFUL SOLUTION HAS
C       BEEN OBTAINED
C
C     IERROR
C       AN ERROR FLAG THAT INDICATES INVALID INPUT PARAMETERS.  EXCEPT
C       FOR NUMBERS 0 AND 8, A SOLUTION IS NOT ATTEMPTED.
C
C       = 0  NO ERROR
C       = 1  TS.LT.0 OR TF.GT.PI
C       = 2  TS.GE.TF
C       = 3  MBDCND.LT.1 OR MBDCND.GT.9
C       = 4  PS.LT.0 OR PS.GT.PI+PI
C       = 5  PS.GE.PF
C       = 6  N.LT.5
C       = 7  M.LT.5
C       = 8  NBDCND.LT.0 OR NBDCND.GT.4
C       = 9  ELMBDA.GT.0
C       = 10 IDIMF.LT.M+1
C       = 11 NBDCND EQUALS 1,2 OR 4 AND MBDCND.GE.5
C       = 12 TS.EQ.0 AND MBDCND EQUALS 3,4 OR 8
C       = 13 TF.EQ.PI AND MBDCND EQUALS 2,3 OR 6
C       = 14 MBDCND EQUALS 5,6 OR 9 AND TS.NE.0
C       = 15 MBDCND.GE.7 AND TF.NE.PI
C
C       SINCE THIS IS THE ONLY MEANS OF INDICATING A POSSIBLY INCORRECT
C       CALL TO HWSSSP, THE USER SHOULD TEST IERROR AFTER A CALL.
C
C     W
C       CONTAINS INTERMEDIATE VALUES THAT MUST NOT BE DESTROYED IF
C       HWSSSP WILL BE CALLED AGAIN WITH INTL = 1. W(1) CONTAINS THE
C       REQUIRED LENGTH OF W .
C
C
C
C     * * * * * * *   PROGRAM SPECIFICATIONS    * * * * * * * * * * * *
C
C     DIMENSION OF   BDTS(N+1),BDTF(N+1),BDPS(M+1),BDPF(M+1),
C     ARGUMENTS      F(IDIMF,N+1),W(SEE ARGUMENT LIST)
C
C     LATEST         JANUARY 1978
C     REVISION
C
C
C     SUBPROGRAMS    HWSSSP,HWSSS1,GENBUN,POISD2,POISN2,POISP2,COSGEN,ME
C     REQUIRED       TRIX,TRI3,PIMACH
C
C     SPECIAL        NONE
C     CONDITIONS
C
C     COMMON         NONE
C     BLOCKS
C
C     I/O            NONE
C
C     PRECISION      SINGLE
C
C     SPECIALIST     PAUL SWARZTRAUBER
C
C     LANGUAGE       FORTRAN
C
C     HISTORY        VERSION 1 - SEPTEMBER 1973
C                    VERSION 2 - APRIL     1976
C                    VERSION 3 - JANUARY   1978
C
C     ALGORITHM      THE ROUTINE DEFINES THE FINITE DIFFERENCE
C                    EQUATIONS, INCORPORATES BOUNDARY DATA, AND ADJUSTS
C                    THE RIGHT SIDE OF SINGULAR SYSTEMS AND THEN CALLS
C                    GENBUN TO SOLVE THE SYSTEM.
C
C     SPACE
C     REQUIRED       CONTROL DATA 7600
C
C     TIMING AND        THE EXECUTION TIME T ON THE NCAR CONTROL DATA
C     ACCURACY       7600 FOR SUBROUTINE HWSSSP IS ROUGHLY PROPORTIONAL
C                    TO M*N*LOG2(N), BUT ALSO DEPENDS ON THE INPUT
C                    PARAMETERS NBDCND AND MBDCND.  SOME TYPICAL VALUES
C                    ARE LISTED IN THE TABLE BELOW.
C                       THE SOLUTION PROCESS EMPLOYED RESULTS IN A LOSS
C                    OF NO MORE THAN THREE SIGNIFICANT DIGITS FOR N AND
C                    M AS LARGE AS 64.  MORE DETAILED INFORMATION ABOUT
C                    ACCURACY CAN BE FOUND IN THE DOCUMENTATION FOR
C                    SUBROUTINE GENBUN WHICH IS THE ROUTINE THAT
C                    SOLVES THE FINITE DIFFERENCE EQUATIONS.
C
C
C                       M(=N)    MBDCND    NBDCND    T(MSECS)
C                       -----    ------    ------    --------
C
C                        32        0         0          31
C                        32        1         1          23
C                        32        3         3          36
C                        64        0         0         128
C                        64        1         1          96
C                        64        3         3         142
C
C     PORTABILITY    AMERICAN NATIONAL STANDARDS INSTITUTE FORTRAN.
C                    ALL MACHINE DEPENDENT CONSTANTS ARE LOCATED IN THE
C                    FUNCTION PIMACH.
C
C     REQUIRED       SIN,COS
C     RESIDENT
C     ROUTINES
C
C     REPERENCES     P. N. SWARZTRAUBER,THE DIRECT SOLUTION OF THE
C                    DISCRETE POISSON EQUATION ON THE SURFACE OF A
C                    SPHERE,S.I.A.M. J. NUMER. ANAL.,15(1974),PP 212-215
C
C                    SWARZTRAUBER,P. AND R. SWEET, 'EFFICIENT FORTRAN
C                    SUBPROGRAMS FOR THE SOLUTION OF ELLIPTIC EQUATIONS'
C                    NCAR TN/IA-109, JULY, 1975, 138 PP.
C
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C
      DIMENSION       F(IDIMF,1) ,BDTS(1)    ,BDTF(1)    ,BDPS(1)    ,
     1                BDPF(1)    ,W(1)
      NBR = NBDCND+1
      PI = PIMACH(DUM)
      TPI = 2.*PI
      IERROR = 0
      IF (TS.LT.0. .OR. TF.GT.PI) IERROR = 1
      IF (TS .GE. TF) IERROR = 2
      IF (MBDCND.LT.1 .OR. MBDCND.GT.9) IERROR = 3
      IF (PS.LT.0. .OR. PF.GT.TPI) IERROR = 4
      IF (PS .GE. PF) IERROR = 5
      IF (N .LT. 5) IERROR = 6
      IF (M .LT. 5) IERROR = 7
      IF (NBDCND.LT.0 .OR. NBDCND.GT.4) IERROR = 8
      IF (ELMBDA .GT. 0.) IERROR = 9
      IF (IDIMF .LT. M+1) IERROR = 10
      IF ((NBDCND.EQ.1 .OR. NBDCND.EQ.2 .OR. NBDCND.EQ.4) .AND.
     1    MBDCND.GE.5) IERROR = 11
      IF (TS.EQ.0. .AND.
     1    (MBDCND.EQ.3 .OR. MBDCND.EQ.4 .OR. MBDCND.EQ.8)) IERROR = 12
      IF (TF.EQ.PI .AND.
     1    (MBDCND.EQ.2 .OR. MBDCND.EQ.3 .OR. MBDCND.EQ.6)) IERROR = 13
      IF ((MBDCND.EQ.5 .OR. MBDCND.EQ.6 .OR. MBDCND.EQ.9) .AND.
     1    TS.NE.0.) IERROR = 14
      IF (MBDCND.GE.7 .AND. TF.NE.PI) IERROR = 15
      IF (IERROR.NE.0 .AND. IERROR.NE.9) RETURN
      CALL HWSSS1 (TS,TF,M,MBDCND,BDTS,BDTF,PS,PF,N,NBDCND,BDPS,BDPF,
     1             ELMBDA,F,IDIMF,PERTRB,W,W(M+2),W(2*M+3),W(3*M+4),
     2             W(4*M+5),W(5*M+6),W(6*M+7))
      W(1) = W(6*M+7)+FLOAT(6*(M+1))
      RETURN
      END