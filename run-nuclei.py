import time, getopt, sys, os

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def usage():
	print("python3 run-nuclei.py -l list")

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hl:", ["help", "list ="])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(str(err))  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    list = None
    for o, a in opts:
        if o == "-l":
        	list = a
        	templates = os.popen("ls ~/nuclei-templates/")
        	exclude = ["GUIDE.md", "LICENSE", "README.md", "brute-force", "examples"]
        	for template in templates:
        		if template[:-1] not in exclude:
        			print("\n" + bcolors.WARNING + bcolors.BOLD + "Running template " + template + bcolors.OKGREEN)
        			command = "nuclei -silent -c 77 -t ~/nuclei-templates/" + template[:-1] + " -l " + list
        			# print(command)
        			os.system(command)

        elif o in ("-h", "--help"):
            usage()
            sys.exit()

if __name__ == "__main__":
    main()
