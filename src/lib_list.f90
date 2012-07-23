! DEFERRED_TYPES = {lib_ray_tracing: %w[SimpleLayer ComplexLayer]}
! これに、use, lib_ray_tracing, only: assignment(=), SimpleLayer, ComplexLayer
! いや、やはりやめよう。全て1ファイルに生成する。
! 生成すべきやつを、簡単にコメントアウトできるようにすれば良いのだ。
! 内部型のやつと外部型のやつを分けて書けば、十分。
! 一貫性も保たれるし、自分に取っては簡潔だし、必要なリストの種類がそんなにコロコロ変わるとも思えないし、コンパイル時間よりも保守にかける時間が短くて済む方が大切だ。
! module lib_@simple_layer@_list
!   use lib_@simple_layer@, only: @SimpleLayer@ => CustomType, operator(=)
!   private
!   public:: CustomTypeList

!   type CustomTypeNode
!     type(CustomType):: val
!     type(CustomTypeNode), pointer:: prev => null()
!     type(CustomTypeNode), pointer:: next => null()
!   end type CustomTypeNode

!   type CustomTypeList
!     type(CustomTypeNode), pointer:: entry => null()
!   end type CustomTypeList

! end module lib_simple_layer_list

! module lib_intrinsic_types_list
!   use lib_real_list
!   use lib_double_precision_list
! end module lib_intrinsic_types_list

! program main
!   use lib_simple_layer
!   use lib_simple_layer_list CustomTypeList => SimpleLayerList

!   call push(list, SimpleLayer(3.5, 'ad'))
! end program main
! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
module lib_list
  use lib_util, only: check
  implicit none
  private
  public:: RealList, new, size, val_at, unshift, shift, delete_at, pop, delete, insert_at, push, node_at, array_from_list, list_from_array, is_size_one, is_empty, assignment(=), operator(.val.), swap

  type RealListNode
    real:: val
    type(RealListNode), pointer:: prev => null()
    type(RealListNode), pointer:: next => null()
  end type RealListNode

  type RealList
    type(RealListNode), pointer:: entry => null()
  end type RealList

  interface operator(.val.)
    module procedure val_at
  end interface

  interface assignment(=)
    module procedure copy, list_from_array_coercion, array_from_list_coercion
  end interface

  interface is_size_one
    module procedure is_size_one_RealList
  end interface

  interface is_empty
    module procedure is_empty_RealList
  end interface

  interface size
    module procedure size_reallist
  end interface

contains

  subroutine swap(list, pos1, pos2)
    type(RealList), intent(inout):: list
    integer, intent(in):: pos1, pos2

    type(RealListNode), pointer:: pos1Node, pos2Node
    real:: swapVal

    pos1Node => node_at(list, pos1)
    pos2Node => node_at(list, pos2)
    swapVal = pos1Node%val
    pos1Node%val = pos2Node%val
    pos2Node%val = swapVal
  end subroutine swap

  subroutine copy(new, original)
    type(RealList), intent(inout):: new
    type(RealList), intent(in):: original

    call list_from_array_coercion(new, array_from_list(original))
  end subroutine copy

  function array_from_list(list) result(this)
    real, allocatable:: this(:)
    type(RealList), intent(in):: list

    this = list
  end function array_from_list

  ! WARNING: Using this function can cause memory leak
  ! because
  !   list = array_to_list(array)
  ! is equivalent to
  !   call array_to_list_coercion(array, list1)
  !   call copy(list1, list2)
  ! Hence, list1 is not and can't be deleted.
  ! To avoid it, use as follows:
  !   list => array_to_list(array)
  function list_from_array(array) result(this)
    type(RealList):: this
    real, intent(in):: array(:)

    this = array
  end function list_from_array

  subroutine list_from_array_coercion(list, array)
    type(RealList), intent(inout):: list
    real, intent(in):: array(:)

    integer:: i

    if(.not.is_empty(list)) call delete(list)

    do i = lbound(array, 1), ubound(array, 1)
      call push(list, array(i))
    end do
  end subroutine list_from_array_coercion

  subroutine array_from_list_coercion(array, list)
    real, allocatable, intent(out):: array(:)
    type(RealList), intent(in):: list

    integer:: i
    type(RealListNode), pointer:: walker

    i = size(list)
    allocate(array(1:i))
    if(is_empty(list)) return

    walker => list%entry
    array(i) = walker%val
    do while(i > 1)
      walker => walker%prev
      i = i - 1
      array(i) = walker%val
    end do
  end subroutine array_from_list_coercion

  function val_at(list, pos) result(this)
    real:: this
    type(RealList), intent(in):: list
    integer, intent(in):: pos

    type(RealListNode), pointer:: targetNode

    targetNode => node_at(list, pos)
    this = targetNode%val
  end function val_at

  function unshift(list) result(this)
    real:: this
    type(RealList), intent(inout):: list

    this = delete_at(list, 1)
  end function unshift

  subroutine shift(list, val)
    type(RealList), intent(inout):: list
    real, intent(in):: val

    call insert_at(list, val, 1)
  end subroutine shift

  function delete_at(list, pos) result(this)
    real:: this
    type(RealList), intent(inout):: list
    integer:: pos

    type(RealListNode), pointer:: targetNode

    if(pos == size(list))then
      this = pop(list)
      return
    end if

    targetNode => node_at(list, pos)
    this = targetNode%val
    if(associated(targetNode%prev)) targetNode%prev%next => targetNode%next
    targetNode%next%prev => targetNode%prev
    deallocate(targetNode)
  end function delete_at

  function pop(list) result(this)
    real:: this
    type(RealList), intent(inout):: list

    type(RealListNode), pointer:: targetNode

    targetNode => list%entry
    this = targetNode%val
    if(is_size_one(list))then
      deallocate(list%entry)
      return
    end if

    list%entry => targetNode%prev
    list%entry%next => targetNode%next

    deallocate(targetNode)
  end function pop

  recursive subroutine delete(list)
    type(RealList), intent(inout):: list

    real:: trash

    do while(associated(list%entry))
      trash = pop(list)
    end do
  end subroutine delete

  subroutine insert_at(list, val, pos)
    type(RealList), intent(inout):: list
    real, intent(in):: val
    integer, intent(in):: pos

    type(RealListNode), pointer:: nextNode, newNode

    if(pos == size(list) + 1)then
      call push(list, val)
      return
    end if

    nextNode => node_at(list, pos)
    allocate(newNode)
    newNode%val = val
    newNode%prev => nextNode%prev
    newNode%next => nextNode
  end subroutine insert_at

  subroutine push(list, val)
    type(RealList), intent(inout):: list
    real, intent(in):: val

    type(RealListNode), pointer:: newNode

    if(is_empty(list))then
      call new(list, val)
      return
    end if

    allocate(newNode)
    newNode%val = val
    newNode%prev => list%entry
    newNode%next => list%entry%next
    list%entry%next => newNode
    list%entry => newNode
  end subroutine push

  ! WARNING: Returns pointer!
  ! BAD: targetNode =  node_at(list, pos)
  ! OK:  targetNode => node_at(list, pos)
  function node_at(list, pos) result(this)
    type(RealListNode), pointer:: this
    type(RealList), intent(in):: list
    integer, intent(in):: pos

    integer:: posNow

    call check(1 <= pos .and. pos <= size(list), 'pos out of range: (/size(list), pos/) = ', (/size(list), pos/))

    this => list%entry
    posNow = size(list)

    do while(posNow > pos)
      this => this%prev
      posNow = posNow - 1
    end do
  end function node_at

  function is_empty_RealList(list) result(this)
    logical:: this
    type(RealList), intent(in):: list

    this = .not.associated(list%entry)
  end function is_empty_RealList

  function is_size_one_RealList(list) result(this)
    logical:: this
    type(RealList), intent(in):: list

    this = (.not.is_empty(list)) .and. (.not.associated(list%entry%prev))
  end function is_size_one_RealList

  function size_RealList(list) result(this)
    ! arrayとの相互変換を考慮して、integerの範囲に絞る
    integer:: this
    type(RealList), intent(in):: list

    type(RealListNode), pointer:: walker

    if(is_empty(list))then
      this = 0
      return
    end if

    walker => list%entry
    this = 1
    do while(associated(walker%prev))
      walker => walker%prev
      this = this + 1
    end do
  end function size_RealList

  subroutine new(list, val)
    type(RealList), intent(inout):: list
    real, intent(in):: val

    if(.not.is_empty(list))then
      call delete(list)
    end if

    allocate(list%entry)
    list%entry%val = val
  end subroutine new
end module lib_list
