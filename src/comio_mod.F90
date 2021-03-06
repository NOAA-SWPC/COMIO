module comio

  use mpi, only : MPI_INFO_NULL
  use comio_class
  use hdf_class
  use pnc_class
  
  implicit none

  ! -- format selector
  integer, parameter :: COMIO_FMT_HDF5    = 1, &
                        COMIO_FMT_PNETCDF = 2

  private

  public :: COMIO_T
  public :: COMIO_FMT_HDF5,   &
            COMIO_FMT_PNETCDF

  public :: comio_create

contains

  ! -- constructors

  subroutine comio_create(this, fmt, comm, info, rc)
    class(COMIO_T),   allocatable  :: this
    integer,           intent(in)  :: fmt
    integer, optional, intent(in)  :: comm
    integer, optional, intent(in)  :: info
    integer, optional, intent(out) :: rc
    ! -- local variables
    integer        :: linfo
    type (IOERR_T) :: err
    ! -- begin
    if (present(rc)) rc = err % success
    select case (fmt)
      case (COMIO_FMT_HDF5)
#ifdef HAVE_HDF5
        allocate(HDF5_IO_T::this, stat=err % rc)
        if (err % check(msg="Unable to create HDF5 I/O object", rc=rc)) return
#else
        call err % set(msg="COMIO was built without HDF5 support", rc=rc)
        return
#endif
      case (COMIO_FMT_PNETCDF)
#ifdef HAVE_PNETCDF
        allocate(PNC_IO_T::this, stat=err % rc)
        if (err % check(msg="Unable to create PnetCDF I/O object", rc=rc)) return
#else
        call err % set(msg="COMIO was built without PnetCDF support", rc=rc)
        return
#endif
      case default
        call err % set(msg="COMIO: Unsupported I/O Format", rc=rc)
        return
    end select
    ! -- initialize I/O layer
    linfo = MPI_INFO_NULL
    if (present(info)) linfo = info
    call this % startup(comm=comm, info=linfo)
    if (this % err % check(msg="Failed to initialize I/O", rc=rc)) return
  end subroutine comio_create
  
end module comio
