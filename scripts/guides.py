#!/usr/bin/env python

# Generate the assembly guides for each machine, as well as index files

import config
import os
import openscad
import shutil
import sys
import c14n_stl
import re
import json
import jsontools
import views
import pystache
from types import *
from assemblies import machine_dir
import csv

sourcing = {};

def md_filename(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I) + '.md'

def htm_filename(s):
    s = s.replace(" ","")
    return re.sub(r"\W+|\s+", "", s, re.I) + '.htm'

def gen_intro(m):
    md = ''

    note = jsontools.get_child_by_key_values(m, kvs={'type':'markdown', 'section':'introduction'})
    if note and ('markdown' in note):
        md += note['markdown'] + '\n\n'

    return md

def gen_bom(m):
    md = '## Bill of Materials\n\n'

    md += 'Make sure you have all of the following parts before you begin.\n\n'

    # vitamins
    if len(m['vitamins']) > 0:
        m['vitamins'].sort(key=vitamin_call, reverse=False)
        md += '### Vitamins\n\n'
        md += 'Qty | Vitamin | Image\n'
        md += '--- | --- | ---\n'
        for v in m['vitamins']:
            md += str(v['qty']) + ' | '
            md += '['+v['title']+']() | '
            md += '![](../vitamins/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
        md += '\n'


    # cut parts
    if len(m['cut']) > 0:
        m['cut'].sort(key=cut_call, reverse=False)
        md += '### Cut Parts\n\n'
        md += 'Qty | Part Name | Image\n'
        md += '--- | --- | ---\n'
        for v in m['cut']:
            md += str(v['qty']) + ' | '
            md += v['title'] + ' | '
            md += '![](../cutparts/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
        md += '\n'


    # printed parts
    if len(m['printed']) > 0:
        vol = 0
        weight = 0
        m['printed'].sort(key=printed_call, reverse=False)
        md += '### Printed Parts\n\n'
        md += 'Qty | Part Name | Image\n'
        md += '--- | --- | ---\n'
        for v in m['printed']:
            md += str(v['qty']) + ' | '
            md += '['+v['title']+'](../printedparts/stl/'+ openscad.stl_filename(v['title']) +') | '
            md += '![](../printedparts/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
            if 'plasticWeight' in v:
                weight += v['qty'] * v['plasticWeight']
                vol += v['qty'] * v['plasticVolume']
        md += '\n\n'

        md += '**Plastic Required**\n\n'
        md += str(round(vol,1))+'cm3, ';
        md += str(round(weight,2))+'KG, ';
        md += ' approx: '+str(round(weight * 13,2))+' GBP\n\n';

    md += '\n'

    return md


def vitamin_call(v):
    return v['call']

def printed_call(p):
    return p['call']

def cut_call(c):
    return c['call']


def gen_cut(m, a):
    md = '## '+a['title']
    if a['qty'] > 1:
        md += ' (x'+str(a['qty'])+')'
    md += '\n\n'

    # vitamins
    if len(a['vitamins']) > 0:
        a['vitamins'].sort(key=vitamin_call, reverse=False)
        md += '### Vitamins\n\n'
        md += 'Qty | Vitamin | Image\n'
        md += '--- | --- | ---\n'
        for v in a['vitamins']:
            md += str(v['qty']) + ' | '
            md += '['+v['title']+']() | '
            md += '![](../vitamins/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
        md += '\n'

    # fabrication steps
    if len(a['steps']) > 0:
        md += '### Fabrication Steps\n\n'
        for step in a['steps']:
            md += str(step['num']) + '. '+step['desc'] + '\n'
            for view in step['views']:
                md += '![](../cutparts/images/'+views.view_filename(a['title']+'_step'+str(step['num'])+'_'+view['title'])+')\n'
        md += '\n'

    md += '\n'

    return md


def gen_assembly(m, a):
    if len(a['steps']) == 0:
        return ""

    md = '## '+a['title']
    if a['qty'] > 1:
        md += ' (x'+str(a['qty'])+')'
    md += '\n\n'

    # vitamins
    if len(a['vitamins']) > 0:
        a['vitamins'].sort(key=vitamin_call, reverse=False)
        md += '### Vitamins\n\n'
        md += 'Qty | Vitamin | Image\n'
        md += '--- | --- | ---\n'
        for v in a['vitamins']:
            md += str(v['qty']) + ' | '
            md += '['+v['title']+']() | '
            md += '![](../vitamins/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
        md += '\n'

    # printed parts
    if len(a['printed']) > 0:
        a['printed'].sort(key=printed_call, reverse=False)
        md += '### Printed Parts\n\n'
        md += 'Qty | Part Name | Image\n'
        md += '--- | --- | ---\n'
        for v in a['printed']:
            md += str(v['qty']) + ' | '
            md += '['+v['title']+'](../printedparts/stl/'+ openscad.stl_filename(v['title']) +') | '
            md += '![](../printedparts/images/'+views.view_filename(v['title']+'_view') + ') | '
            md += '\n'
        md += '\n'

    # cut parts
    # TODO: !!

    # sub-assemblies
    if len(a['assemblies']) > 0:
        md += '### Sub-Assemblies\n\n'
        md += 'Qty | Name \n'
        md += '--- | --- \n'
        for v in a['assemblies']:
            md += str(v['qty']) + ' | '
            md += v['title']
            md += '\n'
        md += '\n'

    # assembly animation
    if len(a['animations']) > 0:
        md += '### Assembly Animation\n\n'
        for anim in a['animations']:
            md += '![](../assemblies/'+machine_dir(m['title'])+'/'+anim['title']+'.gif)\n'
        md += '\n'

    # assembly steps
    if len(a['steps']) > 0:
        md += '### Assembly Steps\n\n'
        for step in a['steps']:
            md += str(step['num']) + '. '+step['desc'] + '\n'
            for view in step['views']:
                md += '![](../assemblies/'+machine_dir(m['title'])+'/'+views.view_filename(a['title']+'_step'+str(step['num'])+'_'+view['title'])+')\n'
        md += '\n'

    md += '\n'

    return md


def assembly_level(a):
    return a['level']


def gen_assembly_guide(m, guide_template):
    print((m['title']))

    md = ''

    md += '# '+m['title'] + '\n'
    md += '# Assembly Guide\n\n'

    # machine views
    for c in m['children']:
        if type(c) is dict and c['type'] == 'view' and 'filepath' in c:
            view = c
            md += '!['+view['caption']+']('+ view['filepath'][3:] +')\n\n'

    # intro
    md += gen_intro(m)


    # BOM
    md += gen_bom(m)

    # Cut Parts
    if len(m['cut']) > 0:
        md += '# Cutting Instructions\n\n'

        # Cut Parts
        m['cut'].sort(key=cut_call, reverse=False)
        for c in m['cut']:
            md += gen_cut(m,c)

    # Assemblies
    if len(m['assemblies']) > 0:
        md += '# Assembly Instructions\n\n'

        # Assemblies
        # sort by level desc
        m['assemblies'].sort(key=assembly_level, reverse=True)
        for a in m['assemblies']:
            md += gen_assembly(m,a)


    print("  Saving markdown")
    mdfilename = md_filename(m['title'] +'AssemblyGuide')
    mdpath = config.paths['docs'] + '/' +mdfilename
    with open(mdpath,'w') as f:
        f.write(md)

    print("  Generating htm")
    htmfilename = htm_filename(m['title'] +'AssemblyGuide')
    htmpath = config.paths['docs'] + '/' + htmfilename
    with open(htmpath, 'w') as f:
        for line in open(guide_template, "r").readlines():
            line = line.replace("{{mdfilename}}", mdfilename)
            f.write(line)

    return {'title':m['title']+ ' Assembly Guide', 'mdfilename':mdfilename, 'htmfilename':htmfilename}


def gen_printing_guide(m, guide_template):
    print((m['title']))

    if len(m['printed']) == 0:
        return {};

    md = ''

    md += '# '+m['title'] + '\n'
    md += '# Printing Guide\n\n'

    vol = 0
    weight = 0
    qty = 0
    m['printed'].sort(key=printed_call, reverse=False)

    for v in m['printed']:
        md += '### '+v['title']+'\n\n'

        md += 'Metric | Value \n'
        md += '--- | --- \n'
        md += 'Quantity | ' + str(v['qty']) + '\n'
        qty += v['qty']
        md += 'STL | ' + '['+v['title']+'](../printedparts/stl/'+ openscad.stl_filename(v['title']) +')\n'

        if 'plasticWeight' in v:
            w = v['qty'] * v['plasticWeight']
            weight += w
            vol += v['qty'] * v['plasticVolume']
            md += 'Plastic (Kg) | ' + str(round(w,2)) + '\n'
            md += 'Plastic (cm3) | ' + str(round(v['qty'] * v['plasticVolume'],1)) + '\n'
            md += 'Approx Plastic Cost | '+str(round(w * 15,2))+' GBP\n';

        md += '\n'
        md += '![](../printedparts/images/'+views.view_filename(v['title']+'_view') + ')\n'
        md += '\n'

        if 'markdown' in v and len(v['markdown']) > 0:
            md += '**Notes**\n\n'
            for note in v['markdown']:
                if 'markdown' in note:
                    md += ' * ' + note['markdown'] + '\n'

        md += '\n\n'

    md += '\n\n'

    md += '## Summary\n\n'
    md += '### Statistics\n\n'
    md += 'Metric | Value \n'
    md += '--- | --- \n'
    md += 'Total Parts | ' + str(qty) + '\n'
    md += 'Total Plastic (Kg) | ' +str(round(weight,2))+'KG\n'
    md += 'Total Plastic (cm3) | ' +str(round(vol,1))+'cm3\n'
    md += 'Approx Plastic Cost | '+str(round(weight * 15,2))+' GBP\n'
    md += '\n\n'

    print("  Saving markdown")
    mdfilename = md_filename(m['title'] +'PrintingGuide')
    mdpath = config.paths['docs'] + '/' +mdfilename
    with open(mdpath,'w') as f:
        f.write(md)

    print("  Generating htm")
    htmfilename = htm_filename(m['title'] +'PrintingGuide')
    htmpath = config.paths['docs'] + '/' + htmfilename
    with open(htmpath, 'w') as f:
        for line in open(guide_template, "r").readlines():
            line = line.replace("{{mdfilename}}", mdfilename)
            f.write(line)

    return {'title':m['title'] + ' Printing Guide', 'mdfilename':mdfilename, 'htmfilename':htmfilename}


def load_sources():
    print("Loading sourcing info...")

    load_source(config.paths['sourcingcsv'])

    for filename in os.listdir(config.paths['vitamins']):
        if filename[-4:] == '.csv':
            print(("  Parsing: "+filename))
            csvfn = os.path.join(src_dir, filename)
            load_source(csvfn)

def load_source(csvfn):
    if os.path.isfile(csvfn):
        with open(csvfn, 'r') as csvfile:
            rdr = csv.DictReader(csvfile)
            for row in rdr:
                vn = row['Vitamin']
                if vn not in sourcing:
                    sourcing[vn] = []
                sourcing[vn].append({"Cost":row['Cost'], "Source":row['Source'], 'Notes':row['Notes']});


def gen_sourcing_guide(m, guide_template):
    print((m['title']))

    if len(m['vitamins']) == 0:
        return {};

    md = ''

    md += '# '+m['title'] + '\n'
    md += '# Sourcing Guide\n\n'

    missing = []

    cost = 0
    qty = 0
    m['vitamins'].sort(key=vitamin_call, reverse=False)

    for v in m['vitamins']:
        vn = v['title']
        md += '### '+str(v['qty']) + 'x ' + vn+'\n\n'
        qty += v['qty']


        # table of sources and effective cost for qty required
        if vn in sourcing:
            md += 'Unit Cost | Source | Notes \n'
            md += '--- | --- | --- \n'

            # calc cheapest option and add to running total
            lc = 0
            for src in sourcing[vn]:
                tc = float(src['Cost'])
                if tc < lc or lc == 0:
                    lc = tc
                md += src['Cost'] + ' | '
                link = src['Source']
                if link[:7] == 'http://':
                    md += '[link]('+link+') | '
                else:
                    md += link + ' | '
                md += src['Notes'] + '\n'

            cost += lc * v['qty']

        else:
            md += 'No sources found\n'
            missing.append('"'+vn+'",0,"","No sources found"')

        md += '\n'
        md += '![](../vitamins/images/'+views.view_filename(v['title']+'_view') + ') \n'
        md += '\n'

        if 'markdown' in v and len(v['markdown']) > 0:
            md += '**Notes**\n\n'
            for note in v['markdown']:
                if 'markdown' in note:
                    md += ' * ' + note['markdown'] + '\n'

        md += '\n\n'

    md += '\n'

    md += '\n\n'

    md += '## Summary\n\n'
    md += '### Total Costs\n\n'
    md += 'Metric | Value \n'
    md += '--- | --- \n'
    md += 'Total Vitamins | ' + str(qty) + '\n'
    md += 'Total Cost (cheapest) | '+str(round(cost,2))+' GBP\n'
    md += '\n\n'

    print("  Saving markdown")
    mdfilename = md_filename(m['title'] +'SourcingGuide')
    mdpath = config.paths['docs'] + '/' +mdfilename
    with open(mdpath,'w') as f:
        f.write(md)

    print("  Generating htm")
    htmfilename = htm_filename(m['title'] +'SourcingGuide')
    htmpath = config.paths['docs'] + '/' + htmfilename
    with open(htmpath, 'w') as f:
        for line in open(guide_template, "r").readlines():
            line = line.replace("{{mdfilename}}", mdfilename)
            f.write(line)

    print("  Updating sourcing.csv")
    with open(config.paths['sourcingcsv'], 'a') as f:
        for line in missing:
            f.write(line + "\n")

    return {'title':m['title'] + ' Sourcing Guide', 'mdfilename':mdfilename, 'htmfilename':htmfilename}



def gen_index(jso, index_file, index_template):
    # Generate index file

    # build object
    indexObj = { 'machines': [], 'project':'' };
    for m in jso:
        if type(m) is dict and m['type'] == 'machine':

            # tack in a view filename
            m['viewFilename'] = views.view_filename(m['title'] + '_view')
            if indexObj['project'] == '':
                indexObj['project'] = m['title']

            indexObj['machines'].append(m)

    print("Saving index")
    with open(index_file,'w') as o:
        with open(index_template,'r') as i:
            o.write(pystache.render(i.read(), indexObj))



def copytree(src, dst, symlinks=False, ignore=None):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            copytree(s, d, symlinks, ignore)
        else:
            if not os.path.exists(d) or os.stat(s).st_mtime - os.stat(d).st_mtime > 1:
                shutil.copy2(s, d)


def guides():
    print("Guides")
    print("------")

    #
    # Make the target directories
    #
    if not os.path.isdir(config.paths['docs']):
        os.makedirs(config.paths['docs'])

    assembly_guide_template = os.path.join(config.paths['templatedocs'], "AssemblyGuide.htm")
    printing_guide_template = os.path.join(config.paths['templatedocs'], "PrintingGuide.htm")
    sourcing_guide_template = os.path.join(config.paths['templatedocs'], "SourcingGuide.htm")
    index_template = os.path.join(config.paths['templatedocs'], "index.htm")
    index_file = os.path.join(config.paths['docs'], 'index.htm')

    # load hardware.json
    jf = open(config.paths['json'],"r")
    jso = json.load(jf)
    jf.close()

    # load sourcing info
    load_sources()

    dl = {'type':'docs', 'assemblyGuides':[], 'printingGuides':[] }
    jso.append(dl)

    # for each machine
    for m in jso:
        if type(m) is dict and m['type'] == 'machine':

            if 'guides' not in m:
                m['guides'] = []

            m['guides'].append(gen_assembly_guide(m, assembly_guide_template))

            m['guides'].append(gen_printing_guide(m, printing_guide_template))

            m['guides'].append(gen_sourcing_guide(m, sourcing_guide_template))


    gen_index(jso, index_file, index_template)

    # copy over css and js folders
    copytree(os.path.join(config.paths['frameworkdocs'], 'js'), os.path.join(config.paths['docs'], 'js'))
    copytree(os.path.join(config.paths['frameworkdocs'], 'css'), os.path.join(config.paths['docs'], 'css'))


    return 0


if __name__ == '__main__':
    guides()
