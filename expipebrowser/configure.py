import argparse
import subprocess
import os
import os.path

parser = argparse.ArgumentParser()
parser.add_argument("qmake_path", help="path to qmake executable from your favorite Qt installation")
args = parser.parse_args()
print args.qmake_path

os.chdir("libs/pyotherside")

subprocess.call([args.qmake_path])
subprocess.call(["make"])
subprocess.call(["make", "install"])
