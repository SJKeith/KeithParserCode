def findpreamble(str):
    preamble = "01100110"
    str = str + '.txt'
    file = open(str,'r')
    List = file.read()
    if preamble in List:
        print "preamble has been found!"
    else:
        print "no preamble found"
        
