import sys, os, time

if __name__ == "__main__":
    time.sleep(1)
    os.execl(sys.executable, sys.executable, *sys.argv[1:])
