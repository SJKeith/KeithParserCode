def numberpreamble(str):
    str = str + '.txt'
    file = open(str,'r')
    List = file.read() 
    print "Number of preambles found: ", List.count("01100110")
