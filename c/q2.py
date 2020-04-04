import sys

if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise ValueError("You need to specify an input")
    
    filename = sys.argv[1]
    f = open(filename, 'r')
    filename_cleaned = filename.split('.')[:-1]
    filename_cleaned = '_'.join(filename_cleaned + ['cleaned.txt'])
    f_cleaned = open(filename_cleaned, 'w+')

    lines = f.readlines()
    parsed = dict()
    for line in lines:
        n1, n2 = line.replace('\n', '').split('\t')
        n1 = int(n1)
        n2 = int(n2)
        if n1 == n2:
            print("Found self loop")
            continue
        if n2 in parsed.keys() and n1 in parsed[n2]:
            print("Found duplicate")
            continue
        else:
            # We add the pair to the file
            f_cleaned.write(line)
            if n1 not in parsed.keys():
                parsed[n1] = [n2]
            else:
                parsed[n1].append(n2)
        

    f.close()
    f_cleaned.close()
