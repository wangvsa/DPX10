#!/usr/bin/python

''' 
Generate random string with given length
Each line has 100 charactors
param 1 : output filename
param 2 : string length
'''

import os
import sys
import string
import random

ALL_CHARACTORS = "abcdefghijklmnopqrstuvwxyz"

# get output filename and string length from command line
def getParameters():
	if len(sys.argv) != 3:
		print "usage: ./random_string.py filename length"
		sys.exit()
	path = sys.argv[1]
	length = sys.argv[2]
	return path, int(length)

def generateSingleLine(length):
	line = ""
	for i in range(length):
		line += random.choice(ALL_CHARACTORS)
	line += "\n"
	return line 

def generateFile():
	path, length = getParameters()

	fp = open(path, 'w')

	lines = length / 100
	for i in range(lines):
		line = generateSingleLine(100)
		fp.write(line)
	remain = length % 100
	line = generateSingleLine(remain)
	fp.write(line+"\n")
	fp.close()

generateFile()
