! Simple program to swap some data between 2 processes
PROGRAM MPISENDRECV
	IMPLICIT NONE
	INCLUDE 'mpif.h'
	
	! Variable Declaration
	INTEGER, DIMENSION(10) :: a,b,c
	INTEGER :: i, ierr, ndata, tag, stat(MPI_STATUS_SIZE), pid, comm_size
	
	CALL MPI_INIT(ierr) ! Initialize MPI Program
	
	CALL MPI_COMM_SIZE(MPI_COMM_WORLD,comm_size,ierr) ! Get Size of Communicator
	CALL MPI_COMM_RANK(MPI_COMM_WORLD,pid,ierr) ! Get Size of Communicator

	DO i = 1,10
		a(i) = pid*10 + i ! Fill in Data Array indidivual to each process
	ENDDO
 
	ndata = 10 ! Amount of data to send/recv
	tag = 101  ! Individual communication tag	
	
	IF(PID.eq.0) then
		! Send from ID 0 --> ID 1 
		CALL MPI_SEND(a,ndata,MPI_INTEGER,pid+1,tag,MPI_COMM_WORLD,ierr)
		! Recv from ID 1 --> ID 0 
		CALL MPI_RECV(b,ndata,MPI_INTEGER,pid+1,tag,MPI_COMM_WORLD,stat,ierr)
	ELSE
		! Recv from ID 0 --> ID 1 
		CALL MPI_RECV(b,ndata,MPI_INTEGER,pid-1,tag,MPI_COMM_WORLD,stat,ierr)	
	  ! Send from ID 1 --> ID 0 
		CALL MPI_SEND(a,ndata,MPI_INTEGER,pid-1,tag,MPI_COMM_WORLD,ierr)
	ENDIF
	c = a + b	 ! Add together
	WRITE(*,*) "PID", pid, "c", c ! Write out to screen
		
	CALL MPI_FINALIZE(ierr) ! Terminate MPI Program

END PROGRAM MPISENDRECV
