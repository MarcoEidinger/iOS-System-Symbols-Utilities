#!/usr/bin/python

import sys, getopt
import os
import json

def get_files(search_path):
	 for (dirpath, _, filenames) in os.walk(search_path):
		 for filename in filenames:
			 yield os.path.join(dirpath, filename)

argv = sys.argv[1:]
if not len(argv):
	print 'listSymbols.py -p <pathToSymbolsFolderWithoutTrailingSlash>'
	sys.exit(2)

symbolsPath = argv[1]

if len(symbolsPath) == 0:
	print 'listSymbols.py -p <pathToSymbolsFolderWithoutTrailingSlash>'
	sys.exit()


filesDic = {}
for path in [symbolsPath + "/System/Library/Frameworks", symbolsPath + "/System/Library/PrivateFrameworks", symbolsPath + "/usr/lib"]:
	list_files = get_files(path)
	for filename in list_files:
		shortFilename = filename.rsplit('/', 1)[-1]
		filesDic[shortFilename] = filename
with open('list.json', 'w') as outfile:
    json.dump(filesDic, outfile)
