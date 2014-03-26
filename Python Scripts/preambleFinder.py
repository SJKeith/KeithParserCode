#given a bitstream
import scipy.io

#a = moriches_msk
a = scipy.io.loadmat('moriches_msk') 

#counter for number of times a valid preamble is found
check_ctr = 1

#cycles through all the bits
for ctr in mslice[1:(length(a) - 8)]:
    #creates an array of 8 bits to check
    a_check = mcat([a(ctr), a(ctr + 1), a(ctr + 2), a(ctr + 3), a(ctr + 4), a(ctr + 5), a(ctr + 6), a(ctr + 7)])

    #if the bits are a valid preamble
    if (isequal(a_check, mcat([0, 1, 1, 0, 0, 1, 1, 0]))):

        #saves their location within the signal to another array
        checkVals(check_ctr).lvalue = ctr
        check_ctr = check_ctr + 1


    end


end
