#!/usr/bin/env python

# Perform static code analysis

from __future__ import print_function

import os
import sys
import shutil
import re

# Severity levels
SEV_OK = 0
SEV_INFO = 1
SEV_WARNING = 2
SEV_ERROR = 3

SEV_NAMES = ['OK', 'Note', 'Warning', 'Error'];

# Utility functions

def init_totals():
	return [0 for i in range(SEV_ERROR + 1)];

def init_errors():
	return [[] for i in range(SEV_ERROR + 1)];
	
def find_scad_file(assembly):
    for filename in os.listdir(source_dir):
        if filename[-5:] == ".scad":
            #
            # look for module which makes the assembly
            #
            for line in open(source_dir + "/" + filename, "r").readlines():
                words = line.split()
                if len(words) and words[0] == "module":
                    module = words[1].split('(')[0]
                    if module == assembly:
                        return filename


    return None

# Faster regex
_regexp_compile_cache = {}

def recache(pattern):
    if pattern not in _regexp_compile_cache:
        _regexp_compile_cache[pattern] = re.compile(pattern)
        # print('Caching: '+pattern)
    return _regexp_compile_cache[pattern]

def match(pattern, s):
  """Matches the string with the pattern, caching the compiled regexp."""
  p = recache(pattern)
  return p.match(s) != None
	

# Reusable regex patterns
re_modules = (r"\bmodule\s+(", r")\s*\(\s*");
re_functions = (r"\bfunction\s+(", r")\s*\(");
re_includes = (r"[^//]\binclude\s+[\<\"](", r")[\>\"]");
re_uses = (r"\buse\s+[\<\"](", r")[\>\"]");

re_upper_camel_case = "([A-Z][a-z0-9]+)+";
re_upper_camel_case_with_abbr = "([A-Z]+[a-z0-9]*)+";

re_supplementary_modules = "(_*[A-Z]+[a-z0-9]*)*";


def extract_definitions(fpath, name_re=r"\w+", def_re=""):
    pattern = name_re.join(def_re)
    matcher = recache(pattern)
    fpath.seek(0)
    return [m.group(1) for m in matcher.finditer(fpath.read())]

def extract_mod_names(fpath, name_re=r"\w+"):
    return extract_definitions(fpath, name_re=name_re, def_re=re_modules)

def extract_func_names(fpath, name_re=r"\w+"):
    return extract_definitions(fpath, name_re=name_re, def_re=re_functions)
    
def extract_includes(fpath, name_re=r"[\w\.\\\/]+"):
    return extract_definitions(fpath, name_re=name_re, def_re=re_includes)
	
def extract_uses(fpath, name_re=r"[\w\.\\\/]+"):
    return extract_definitions(fpath, name_re=name_re, def_re=re_uses)
	
"""
Report structure

report ->
	count by severity
	section ->
		count by severity
		file ->
			count by severity
			errors [ severity ] [ item ] =  description

"""

# Global vars
	
report = {'totals':init_totals(), 'sections': {} }

# rules

def rr(isok, sevbad, desc):
    return { 
	    'sev': SEV_OK if isok else sevbad, 
	    'desc':desc
	    }
	
def filename_format_ucc(fn):
	return rr(match(re_upper_camel_case_with_abbr, fn[:-5]), SEV_WARNING, 'Filename is not in UpperCamelCase')
	
def assembly_module_name_matches_filename(f):
    return rr(f['name'][:-5]+'Assembly' in f['modules'], SEV_ERROR, 'Assembly module name does not match filename')
    
def vitamin_module_name_matches_filename(f):
    return rr(f['name'][:-5] in f['modules'], SEV_WARNING, 'Vitamin module name does not match filename')

def no_includes(f):
    return rr(len(f['includes'])==0, SEV_WARNING, 'Contains include statements - these should be in the relevant global config file')

def no_uses(f):
    return rr(len(f['uses'])==0, SEV_WARNING, 'Contains use statements')

def supplementary_module_naming(f):
    errors = 0
    s = ''
    prefix = f['name'][:-5]
    for m in f['modules']:
        if not match(prefix + re_supplementary_modules, m):
            if s > '':
                s += ', '
            s += m
            errors += 1
    
    return rr(errors == 0, SEV_WARNING, str(errors)+' supplementary modules do not comply with naming convention ('+s+')')
    
def function_naming(f):
    errors = 0
    s = ''
    prefix = f['name'][:-5]
    for m in f['functions']:
        if not match(prefix + re_supplementary_modules, m):
            if s > '':
                s += ', '
            s += m
            errors += 1
    
    return rr(errors == 0, SEV_WARNING, str(errors)+' functions do not comply with naming convention ('+s+')')


# * Assembly module contains step() calls
# * Any variables have correct naming convention
# * Any functions have correct naming convention
# * Any included _STL modules have associated _View modules
# * _View modules contain an echo line with correct structure
# * Exists in /config/assemblies.scad


	
# section processors

def add_result(f, res):
    f['totals'][res['sev']] += 1
    f['errors'][res['sev']].append(res['desc'])
    
def extract_all(f, file):
    f['modules'] = extract_mod_names(file)
    f['functions'] = extract_func_names(file)
    f['includes'] = extract_includes(file)
    f['uses'] = extract_uses(file)
    
def proc_assemblies(f):
    fn = f['name']
    print("  Validating: "+fn)
    
    fpath = f['dir']+'/'+f['name']
    file = open(fpath, 'r')
    
    extract_all(f, file)
    
    # Apply validation rules
    add_result(f, filename_format_ucc(fn))
    add_result(f, assembly_module_name_matches_filename(f))
    add_result(f, no_includes(f))
    add_result(f, no_uses(f))
    add_result(f, supplementary_module_naming(f))
    add_result(f, function_naming(f))
    
def proc_vitamins(f):
    fn = f['name']
    print("  Validating: "+fn)
    
    fpath = f['dir']+'/'+f['name']
    file = open(fpath, 'r')
    
    extract_all(f, file)
    
    # Apply validation rules
    add_result(f, filename_format_ucc(fn))
    add_result(f, vitamin_module_name_matches_filename(f))
    add_result(f, supplementary_module_naming(f))
    add_result(f, function_naming(f))
	
	
# stuff	

def update_section_totals(sec):
	for f in sec['files']:
	    for i in range(SEV_ERROR+1):
	        sec['totals'][i] += sec['files'][f]['totals'][i]
	
def add_file(sec, dir, fn):
	f = {'name':fn, 'dir':dir, 'totals':init_totals(), 'errors':init_errors() }
	sec['files'][fn] = f
	return f
	
def do_section(target_dir, processor, sec):
	print("Section: "+target_dir)
	for filename in os.listdir(target_dir):
		if filename[-5:] == ".scad":
			processor(add_file(sec, target_dir, filename))

	update_section_totals(sec)
	
def add_section(s):
	sec = {'name':s, 'totals':init_totals(), 'files':{} }
	report['sections'][s] = sec
	return sec
	
def update_totals():
    for sec in report['sections']:
        for i in range(SEV_ERROR+1):
            report['totals'][i] += report['sections'][sec]['totals'][i]


# Saving

def to_anchor_link(s):
    return '['+s+'](#'+s.lower().replace('.','')+')'

def writeln(f, s):
    f.write(s + '\n');
    
def fit_to_publish():
    return True if report['totals'][SEV_ERROR] == 0 else False

def write_summary(f):
    writeln(f,'## Summary')
    writeln(f,'')
    
    writeln(f,'**Fit to Publish:** '+ ('Yes' if fit_to_publish() else 'No' ))
    writeln(f,'')
    
    # workout longest section name
    secchars = 8;
    for sec in report['sections']:
        if len(sec) > secchars:
            secchars = len(sec)
        
    headings = 'Section '.ljust(secchars)
    underline = '------'.ljust(secchars,'-') + ' '
    for i in range(SEV_ERROR+1):
        headings += ' | '+ SEV_NAMES[i].ljust(3)
        underline += '|:'.ljust(len(SEV_NAMES[i])-1,'-') + '---:'
    writeln(f,headings)
    writeln(f,underline)
    print(headings)
    print(underline)
    
    for sec in report['sections']:
        secn = sec.ljust(secchars)
        secl = to_anchor_link(secn)
        for i in range(SEV_ERROR+1):
            s = ' | '+str(report['sections'][sec]['totals'][i]).ljust(3 if len(SEV_NAMES[i])<3 else len(SEV_NAMES[i]))
            secn += s
            secl += s
        writeln(f,secl)
        print(secn)
        
    f.write('**Total** ')
    for i in range(SEV_ERROR+1):
        f.write(' | **'+str(report['totals'][i]) + '** ')
    writeln(f,'')
        
    writeln(f,'')
    
def write_section_summary(f, sec):
    writeln(f,'## ' + sec)
    writeln(f,'')
        
    headings = 'File    '
    underline = '------ '
    for i in range(SEV_ERROR+1):
        headings += ' | '+ SEV_NAMES[i]
        underline += ' | :---: '
    writeln(f,headings)
    writeln(f,underline)
    
    for file in report['sections'][sec]['files']:
        f.write(to_anchor_link(file))
        for i in range(SEV_ERROR+1):
            f.write(' | '+str(report['sections'][sec]['files'][file]['totals'][i]))
        writeln(f,'')
        
    f.write('**Total** ')
    for i in range(SEV_ERROR+1):
        f.write(' | **'+str(report['sections'][sec]['totals'][i]) + '** ')
    writeln(f,'')
        
    writeln(f,'')
    

def write_file_summary(f, sec, file):
    seco = report['sections'][sec]
    fileo = seco['files'][file]
        
    bad_things = 0
    for i in range(1,SEV_ERROR + 1):
        bad_things += fileo['totals'][i]
        
    if (bad_things > 0):
        writeln(f,'### ' + file)
        writeln(f,'')
    
        for i in range(1,SEV_ERROR + 1):
            if fileo['totals'][i] > 0:
                writeln(f, '* **'+SEV_NAMES[i]+'s**')
                for d in fileo['errors'][i]:
                    writeln(f, '  * '+d)
                writeln(f,'')
    

def save_report():
    print("Saving report...")
    print("")
    f = open('static.md', "w")
    
    writeln(f,'# Static Analysis Report')
    writeln(f,'')
    
    write_summary(f);
    
    for sec in report['sections']:
        write_section_summary(f, sec)
        
        for file in report['sections'][sec]['files']:
            write_file_summary(f, sec, file)
    
    f.close()
	
def static():
	print()
	print("Static Analysis")
	print("---------------")
	
	do_section('assemblies', proc_assemblies, add_section('Assemblies'))
	do_section('vitamins', proc_vitamins, add_section('Vitamins'))
	
	update_totals()
	
	save_report()
	
	print()
	
	return (0 if fit_to_publish() else 1)
	
if __name__ == '__main__':
    sys.exit(static())