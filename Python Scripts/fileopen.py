def fileopen(str):
    str = str + '.txt'
    file = open(str, 'r')

    return file.read()
