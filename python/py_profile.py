# this file will load on python startup if the PYTHONSTARTUP 
# environment variable is set to point to it. You can add this 
# "export"  to the end of your .bashrc file for example.
# export PYTHONSTARTUP=~/share/python/py_startup.py
# add tab completion
import types
import uuid

helpers = types.ModuleType('helpers')
helpers.uuid4 = uuid.uuid4()

# tab completion in py repl
try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

#append current dir to path
import sys, os
sys.path.append(os.getenv("PWD"))
