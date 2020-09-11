def generateRustCommand(file):
    f = open(file, "r")
    hosts = ""
    for domain in f:
        if domain[-1] == '\n':
            domain = domain[:len(domain)-1]
        hosts += (domain + ", ")
    hosts = hosts[:len(hosts)-2]
    print("rustscan " + hosts + " -r 1-65535")

generateRustCommand("1.txt")
