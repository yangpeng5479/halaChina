#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Localize.py - Incremental localization on XCode projects
# João Moreno 2009
# http://joaomoreno.com/

from sys import argv
from codecs import open
from re import compile
from copy import copy
import os
import shutil

re_translation = compile(r'^"(.+)" = "(.+)";$')
re_comment_single = compile(r'^/\*.*\*/$')
re_comment_start = compile(r'^/\*.*$')
re_comment_end = compile(r'^.*\*/$')

def print_help():
	print u"""Usage: merge.py merged_file old_file new_file
Xcode localizable strings merger script. João Moreno 2009."""

class LocalizedString():
	def __init__(self, comments, translation):
		self.comments, self.translation = comments, translation
		self.key, self.value = re_translation.match(self.translation).groups()

	def __unicode__(self):
		return u'%s%s\n' % (u''.join(self.comments), self.translation)

class LocalizedFile():
	def __init__(self, fname=None, auto_read=False):
		self.fname = fname
		self.strings = []
		self.strings_d = {}

		if auto_read:
			self.read_from_file(fname)

	def read_from_file(self, fname=None):
		fname = self.fname if fname == None else fname
		try:
			f = open(fname, encoding='utf_16', mode='r')
		except:
			print 'File %s does not exist.' % fname
			exit(-1)
		
		line = f.readline()
		while line:
			comments = [line]

			if not re_comment_single.match(line):
				while line and not re_comment_end.match(line):
					line = f.readline()
					comments.append(line)
			
			line = f.readline()
			# debug log
			# print "processing line: " + line
			if line and re_translation.match(line):
				translation = line
			else:
				raise Exception('invalid file at line:\n' + line)
			
			line = f.readline()
			while line and line == u'\n':
				line = f.readline()

			string = LocalizedString(comments, translation)
			self.strings.append(string)
			self.strings_d[string.key] = string

		f.close()

	def save_to_file(self, fname=None):
		fname = self.fname if fname == None else fname
		try:
			f = open(fname, encoding='utf_16', mode='w')
		except:
			print 'Couldn\'t open file %s.' % fname
			exit(-1)

		for string in self.strings:
			f.write(string.__unicode__())

		f.close()

	def merge_with(self, new):
		merged = LocalizedFile()

#		for string in new.strings:
#			if self.strings_d.has_key(string.key):
#				new_string = copy(self.strings_d[string.key])
#				new_string.comments = string.comments
#				string = new_string
#
#			merged.strings.append(string)
#			merged.strings_d[string.key] = string

		for string in new.strings:
			if self.strings_d.has_key(string.key) and self.strings_d[string.key].value != string.value:
				new_string = copy(self.strings_d[string.key])
				new_string.comments = string.comments
				string = new_string
				merged.strings.append(string)
				merged.strings_d[string.key] = string

		# BY-LYX: append the yet-to-translate lines at the end
		for string in new.strings:
			if not self.strings_d.has_key(string.key) or self.strings_d[string.key].value == string.value:
				merged.strings.append(string)
				merged.strings_d[string.key] = string

		return merged

def merge(merged_fname, old_fname, new_fname):
	try:
#		print 'loading ' + old_fname
		old = LocalizedFile(old_fname, auto_read=True)
#		print 'loading ' + new_fname
		new = LocalizedFile(new_fname, auto_read=True)
	except Exception as inst:
		print 'Error: input files have invalid format.'
		print inst

	merged = old.merge_with(new)

	merged.save_to_file(merged_fname)

#STRINGS_FILE = 'Localizable.strings'

def localize(path):
#	languages = [name for name in os.listdir(path) if name.endswith('.lproj') and os.path.isdir(name)]
#	languages = ["ar.lproj", "en.lproj", "ja.lproj", "th.lproj","vi.lproj"];
	langfiles = [
                 "language/zh-Hans.lproj/Localizable.strings",
				 "language/en.lproj/Localizable.strings",
                 "language/ar.lproj/Localizable.strings",
                 # "language/fr.lproj/Localizable.strings",
                 #"language/th.lproj/Localizable.strings",
				 #"language/id.lproj/Localizable.strings",
                 # "language/vi.lproj/Localizable.strings",
                 #"language/zh-Hant.lproj/Localizable.strings",
				 #"ar.lproj/Localizable-Egypt.strings",
                 #"src/ja.lproj/Localizable.strings"
				 
			];
	
	for langfile in langfiles:
		print 'processing: ' + langfile

		#langfile = merged = language + os.path.sep + f
		new = "language/temp.lproj/Localizable.strings"
		old = langfile + '.old'
	
		if os.path.isfile(langfile):
			shutil.copy(langfile, old)
			#os.system('genstrings -s MOLocalizedString -q -o temp.lproj Classes/* Three20Core/*')
			os.system('find . -name "*.m" -print0 | xargs -0 genstrings  -q -o language/temp.lproj')
			#os.rename(original, new)
			merge(langfile, old, new)
		else:
			#os.system('genstrings -s MOLocalizedString -q -o temp.lproj Classes/* Three20Core/*')
			os.system('find . -name "*.m" -print0 | xargs -0 genstrings  -q -o language/temp.lproj')
			os.rename(new, langfile)

		print 'OK'

if __name__ == '__main__':
	localize(os.getcwd())

