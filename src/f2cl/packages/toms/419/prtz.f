      SUBROUTINE PRTZ(N,ZR,ZI)
      DOUBLE PRECISION ZR(50),ZI(50)
      WRITE(6,10) (ZR(I),ZI(I) ,I=1,N)
   10 FORMAT(//' ZEROS'/ 50(2D26.16/))
      RETURN
      END