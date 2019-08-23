program t2lab
	implicit none
	INCLUDE 'mpif.h'
	
	!Variable declaration
	integer :: i,unit, nx=101, nprocs,pid,nlocal,il,ih,ndata,tag,tag2,ierr,stat(MPI_STATUS_SIZE),ol,oh  !Create integer. 
	real(kind=8):: alpha = 0.1,dx,dt=0.0001,t,L = 1,nxx =101 ! Create real number..
	real(kind = 8), allocatable :: T0(:),T1(:),T2(:) !Create array.
	character(len=80) ::filename ! for file creating
	
	! Make the file.
	filename = 'lab2solution.txt' ! Name the file to store the data
	unit = 1001 ! Still don't know what does this do, but this is necessary
	open(unit, file = filename, form = 'formatted', status = 'replace') ! Create the file
	
	CALL MPI_INIT(ierr) 	! Initialize MPI Program
	CALL MPI_COMM_SIZE(MPI_COMM_WORLD,nprocs,ierr) ! Get Number of processors
	CALL MPI_COMM_RANK(MPI_COMM_WORLD,pid,ierr) 	 ! Assign processor ID
	
	
	nlocal = (nx+2*(nprocs-1))/nprocs ! Number of local nodes in each processor
	dx = L/(nxx-1.) ! Grid spacing.
	allocate(T0(nx),T1(nx)) ! Allocate the dimension of those arrays.
	do i= 1,nx ! Initial condition
		T0(i) = exp((-0.5)*(((i-1.)*dx-0.5*L)/0.05)**2)
	enddo
	T2 = T0
	!do i = 1,nx
	!write(*,*) T0(i)
	!enddo 
	! Boundary condition
	T0(1) = 0
	T0(nx) = 0
	t = 0 ! Initialize t from 0.
	
	! Set local limit indices for each processor
	il = 1+pid*(nlocal-2)! Set the lower index limit
	ih = il + nlocal-1 ! Set the higher index limit	
	
	!Calculate the value in each local node.
	do while (t.lt.2)
		t = t+dt
		do i = il+1,ih-1
			T1(i) = (alpha*dt/(dx**2))*(T0(i+1)-2*T0(i)+T0(i-1))+T0(i)
		enddo
		T0(il+1:ih-1) = T1(il+1:ih-1)
		
		!Communicate between each processor
		tag = 111 ! To send value for calculation.
		ndata = 1
		if(pid.gt.0) then !Receive from the left.
			call mpi_recv(T0(il),ndata,mpi_double_precision,pid-1,tag,MPI_COMM_WORLD,stat,ierr) 
		endif
		
		if(pid.lt.nprocs-1) then !Send to the right.
			call mpi_ssend(T0(ih-1),ndata,mpi_double_precision,pid+1,tag,MPI_COMM_WORLD,ierr) 
		endif
		
		if(pid.lt.nprocs-1) then ! Receive from the right.
			call mpi_recv(T0(ih),ndata,mpi_double_precision,pid+1,tag,MPI_COMM_WORLD,stat,ierr)
		endif
		
		if(pid.gt.0) then ! Send to the left.
			call mpi_ssend(T0(il+1),ndata,mpi_double_precision,pid-1,tag,MPI_COMM_WORLD,ierr)
		endif 
	enddo
	
	call mpi_barrier(MPI_COMM_WORLD,ierr)
	
	
	tag2 = 112 ! tag2 is created to send the solution.
	
	! Gather the final data.
	if (pid.eq.0) then
		do i = 1, nprocs-1 ! i represent pid number here. 
			ol = 1+i*(nlocal-2) ! Set the lower limit to receive the solution.
			oh = il + nlocal-1 ! Set the higher index limit	
	call mpi_recv(T1(ol+1:oh-1),nlocal-2,mpi_double_precision,i,tag2+i,MPI_COMM_WORLD,stat,ierr)
		enddo 
	else
		call mpi_ssend(T1(il+1:ih-1),nlocal-2,mpi_double_precision,0,tag2+pid,MPI_COMM_WORLD,ierr)
	endif
	call mpi_barrier(MPI_COMM_WORLD,ierr)
	
	! Write data in file
	if (pid.eq.0) then
		do i = 1,nx
			write(unit,*) T1(i) 
		enddo
	endif
		
	
	! Finalize MPI program
	CALL MPI_FINALIZE(ierr)
	
	! Close the file
	close(unit)
	
end program t2lab
