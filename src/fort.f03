program hello
        ! random fortran program
        implicit none
        ! climb stairs up to 42
        integer :: prev2, prev1, i, num, current
        num = 42
        prev2 = 1
        prev1 = 1
        do i = 3, num
            current = prev1 + prev2
            prev2 = prev1
            prev1 = current
        end do
        write (*,'("can climb to stair number ", I0, " in ", I0, " ways")') num, current
end program hello
