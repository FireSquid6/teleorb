import sys
import os
import shutil


print(sys.argv)
print(os.getcwd())

version = sys.argv[1]
path = f'/exports/{version}'

if os.path.exists(path):
    shutil.rmtree(path)
os.makedirs(path)
