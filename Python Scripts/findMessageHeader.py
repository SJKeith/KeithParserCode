def findpreamble(Data):
    preamble = "01100110"
    if preamble in Data:
        print "preamble has been found!"
    else:
        print "no preamble found"


def findMessageHeader(str):
    str = str + '.txt'
    file = open(str,'r')
    Stream = file.read()
    Data = [Stream]
    MessageHeaderList = []
    
    print "this is the stream: ",Data
    print "Message Header List: ",MessageHeaderList
    
    preamble = "01100110"
    if preamble in Stream:
        print "preamble has been found"
        MessageHeaderList.append("01100110")
    else:
        print "no preamble found"
    
    print "this is the stream: ",Data
    print "Message Header List: ",MessageHeaderList
