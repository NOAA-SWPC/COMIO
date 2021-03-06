!
! Error handling
!
module ioerr_class

  implicit none

  integer, parameter :: IOERR_SUCCESS = 0, &
                        IOERR_FAILURE = 1

  integer, parameter :: IOERR_MSGLEN  = 1024
  integer, parameter :: IOERR_IOUNIT  = 6

  type IOERR_T
    integer             :: success  = IOERR_SUCCESS
    integer             :: failure  = IOERR_FAILURE
    integer             :: rc       = IOERR_SUCCESS
    integer             :: errlog   = IOERR_IOUNIT
    character(len=IOERR_MSGLEN) :: message = ""
    character(len=IOERR_MSGLEN) :: srcfile = ""
  contains
    generic   :: check => check_rc, check_status
    procedure :: set
    procedure, private :: check_rc
    procedure, private :: check_status
  end type

  private
  public :: IOERR_T

contains

  logical function check_rc(this, msg, file, line, rc)
    class(IOERR_T)                          :: this
    character(len=*), optional, intent(in)  :: msg
    character(len=*), optional, intent(in)  :: file
    integer,          optional, intent(in)  :: line
    integer,          optional, intent(out) :: rc

    character(len=IOERR_MSGLEN) :: errmsg

    check_rc = (this % rc /= this % success)

    if (check_rc) then

      errmsg = "ERROR:"
      if (present(file)) then
        errmsg = trim(errmsg) // file
      else
        errmsg = trim(errmsg) // this % srcfile
      end if
      if (present(line)) write(errmsg, '(a,":",i0)') trim(errmsg), line
      if (present(msg)) then
        errmsg = trim(errmsg) // " - " // msg
      else
        errmsg = trim(errmsg) // " - " // this % message
      end if

      write(this % errlog, '(a)') trim(errmsg)

      ! -- overwrite return code with standard failure code
      this % rc = this % failure

    end if

    if (present(rc)) rc = this % rc
    
  end function check_rc

  logical function check_status(this, status, msg, file, line, rc)
    class(IOERR_T)                          :: this
    logical                   , intent(in)  :: status
    character(len=*), optional, intent(in)  :: msg
    character(len=*), optional, intent(in)  :: file
    integer,          optional, intent(in)  :: line
    integer,          optional, intent(out) :: rc

    if (status) this % rc = this % failure
    check_status = this % check(msg=msg, line=line)
    if (present(rc)) rc = this % rc

  end function check_status

  subroutine set(this, msg, file, line, rc)
    class(IOERR_T)                          :: this
    character(len=*), optional, intent(in)  :: msg
    character(len=*), optional, intent(in)  :: file
    integer,          optional, intent(in)  :: line
    integer,          optional, intent(out) :: rc

    logical :: errflag

    this % rc = this % failure
    errflag = this % check(msg=msg, file=file, line=line, rc=rc)

  end subroutine set
  
end module ioerr_class
