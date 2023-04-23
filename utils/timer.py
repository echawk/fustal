import sys
import subprocess
from datetime import datetime

def timer(l):
    "Returns the time elapsed to run subprocess 'l' in seconds."
    t = datetime.now()
    subprocess.call(l)
    elapsed_time = datetime.now() - t
    return elapsed_time.seconds + elapsed_time.microseconds / 1000000

if __name__ == "__main__":
    print("real " + str(timer(sys.argv[1:])) + "s", file=sys.stderr)
