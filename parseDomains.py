import sys

# *.google.com becomes google.com
# https://soundcloud.com becomes soundcloud.com
def parseDomains(domain):

    if len(domain) >= 7 and domain[:7] == "http://":
        domain = domain[7:]
    elif len(domain) >= 8 and domain[:8] == "https://":
        domain = domain[8:]

    if "*" in domain:
        if domain[len(domain)-1] == "*":
            domain = domain[:len(domain)-2]
        else:
            star_index = domain.index('*')
            domain = domain[star_index+1:]
            if domain[0] == ".":
                domain = domain[1:]
            else:
                domain = ""

    return domain

# print(parseDomains("https://*api.soundcloud.com"))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 parseDomains.py file.txt output.txt")
        sys.exit(1)

    file = sys.argv[1]
    o_file = sys.argv[2]
    
    f = open(file, "r")
    output = open(o_file, "a")

    for domain in f:
        if domain[-1] == "\n":
            domain = domain[:len(domain)-1]
        output.write(parseDomains(domain) + "\n")
        # print()
