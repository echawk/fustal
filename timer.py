import sys
import subprocess
from datetime import datetime
t = datetime.now()
subprocess.call(sys.argv[1:])
elapsed_time = datetime.now() - t
print("real " + str(elapsed_time.seconds + elapsed_time.microseconds / 1000000) + "s", file=sys.stderr)
