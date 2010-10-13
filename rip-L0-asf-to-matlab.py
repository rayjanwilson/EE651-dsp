#!/usr/bin/env python
#-*- coding:utf-8 -*-

__description__ = """
Open up an asf internal file and save the matrix to matlab format
Requires an installation of asf mapready to work
"""

import os
from struct import unpack
import mmap
import scipy.io as sio
import numpy as np
import sys
import re
from subprocess import *
import math
import cmath

__author__ = "Rayjan Wilson"
__copyright__ = "Copyright 2010, Rayjan Wilson"
__credits__ = ""
__license__ = "GNU GPL"
__version__= "0.1"
__maintainer__ = "Rayjan Wilson"
__email__ = "<rayjan.wilson@alaska.edu>"
__status__ = "Prototype" #Prototype, Development, Production


def runCommand(command):
    try:
        retcode = call(command, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
        else:
            print >>sys.stderr, "Child returned", retcode
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e

def mmapChannel(arrayReal, arrayImag, fileName,  channelNo,  line_count,  sample_count):
    """
    We need to read in the asf internal file and convert it into a numpy array.
    It is stored as a single row, and is binary. The number of lines (rows), samples (columns),
    and channels all come from the .meta text file
    ASF internal files are packed big endian, but most systems use little endian, so we need
    to make that conversion as well.
    Memory mapping seemd to improve the ingestion speed a bit

    to use this you'll need to import:
    from struct import unpack
    import mmap
    """
    with open(fileName, "rb") as f:

        # memory-map the file, size 0 means whole file
        #length = line_count * sample_count * arrayName.itemsize
        print "\tMemory Mapping..."

        map = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        map.seek(channelNo*line_count*sample_count*arrayReal.itemsize)

        length = arrayReal.itemsize
        print "arrayReal.itemsize: ", length
        #print "mapread: ", map.read(arrayName.itemsize)

        print "total number of bytes: ", line_count*sample_count
        for i in xrange(line_count*sample_count):
            arrayReal[0, i] = unpack('>b', map.read(length) )[0]
            arrayImag[0, i] = unpack('>b', map.read(length) )[0]

        print "real[0,0]: ", arrayReal[0,0]
        print "imag[0,0]: ", arrayImag[0,0]

        #same method as above, just more verbose for the programmer
#        for i in xrange(line_count*sample_count): #row
#            be_float = map.read(arrayName.itemsize) # arrayName.itemsize should be 4 for float32
#            le_float = unpack('>f', be_float)[0] # > for big endian, < for little endian
#            arrayName[0, i]= le_float

        map.close()
    return arrayReal, arrayImag

def saveAsMatlab(array, fileName):
    """
    save a numpy array as a matlab .mat file

    to use this you'll need to import:
    import scipy.io as sio
    """
    sio.savemat(fileName, {fileName:array}, appendmat=True)


def rip_asf_to_matlab(workingDir, plrimage, cpu):
    plrimage_img = plrimage + '.img'
    print "cpu %d: asf_import " %cpu,  plrimage
    cmd = "asf_import "+ plrimage + " " + plrimage
    runCommand(cmd)

    band_count = 0
    line_count = 0
    sample_count = 0
    x_pixel_size = 0
    y_pixel_size = 0
    center_latitude = 0
    center_longitude = 0
    metafile = plrimage + ".meta"

    with open(metafile, "rb") as file:
        for line in file:
            if re.search('original_line_count',  line):
                pass
            elif re.search('original_sample_count',  line):
                pass
            elif re.search('band_count', line):
                band_count = int( line.split(" ")[5] )
                print "band_count: ", band_count
            elif re.search('line_count',  line):
                #print "I found line_count!"
                line_count = int( line.split(" ")[5] )
                print "Line count: ",  line_count
            elif re.search('sample_count', line) and (sample_count == 0):
                #print "I found sample_count!"
                sample_count = int( line.split(" ")[5] )
                print "Sample count: ",  sample_count
            elif re.search('x_pixel_size', line):
                #print "I found sample_count!"
                x_pixel_size = float( line.split(" ")[5] )
                print "x_pixel_size: ",  x_pixel_size
            elif re.search('y_pixel_size', line):
                #print "I found sample_count!"
                y_pixel_size = float( line.split(" ")[5] )
                print "y_pixel_size: ",  y_pixel_size
            elif re.search('center_latitude', line):
                #print "I found sample_count!"
                center_latitude = float( line.split(" ")[5] )
                print "center_latitude: ",  center_latitude
            elif re.search('center_longitude', line):
                #print "I found sample_count!"
                center_longitude = float( line.split(" ")[5] )
                print "center_longitude: ",  center_longitude
            else:
                pass

    if (band_count == 1):
        print "Working on band 1"
        print "cpu %d: Initializing the Amp HH and Phase HH arrays..." %cpu
        HHamp_ones = np.ones((1,  line_count*sample_count),  dtype='b')
        HHphase_ones = np.ones((1,  line_count*sample_count),  dtype='b')

        print "cpu %d: Ingesting HH_Amp and HHphase..." %cpu
        HHamp, HHphase = mmapChannel(HHamp_ones, HHphase_ones, plrimage_img,  0,  line_count,  sample_count)


        print "cpu %d: Reshaping...." %cpu
        HHamp_orig = HHamp.reshape(line_count, -1)
        HHphase_orig = HHphase.reshape(line_count, -1)

        shape=HHamp_orig.shape

        print "cpu %d: Turning HH into complex images" %cpu
        HHcomplex = np.ones(shape,  dtype='complex64')

        for ii in xrange(line_count):     #line_count... set to 10 for testing
            for jj in xrange(sample_count):     #sample_count.... set to 10 for testing
                #HHcomplex[ii, jj] = cmath.rect(HHamp_orig[ii, jj],  HHphase_orig[ii, jj]) #this may be wrong for L0 since it may be packed as real imag, not amp phase
                HHcomplex[ii, jj] = complex(HHamp_orig[ii,jj], HHphase_orig[ii,jj])

        print "saving to .mat format for matlab"
        saveAsMatlab(HHamp_orig, 'HHreal')
        saveAsMatlab(HHphase_orig, 'HHimag')
        saveAsMatlab(HHcomplex, 'HHcomplex_new')
        print "saving to .npy format for python"
        np.save('./HHcomplex_py', HHcomplex)
    elif (band_count > 1):
        print "cpu %d: Initializing the Amp HH HV, and Phase HH HV arrays..." %cpu
        HHamp = np.ones((1,  line_count*sample_count),  dtype='float32')
        HHphase = np.ones((1,  line_count*sample_count),  dtype='float32')
        HVamp = np.ones((1,  line_count*sample_count),  dtype='float32')
        HVphase = np.ones((1,  line_count*sample_count),  dtype='float32')

        print "cpu %d: I think plrimage is: " %cpu,  plrimage

        print "cpu %d: Ingesting HH_Amp..." %cpu
        HHamp = mmapChannel(HHamp, plrimage_img,  0,  line_count,  sample_count)
        print "cpu %d: Ingesting HH_phase..." %cpu
        HHphase = mmapChannel(HHphase, plrimage_img,  1,  line_count,  sample_count)
        print "cpu %d: Ingesting HV_AMP..." %cpu
        HVamp = mmapChannel(HVamp, plrimage_img,  2,  line_count,  sample_count)
        print "cpu %d: Ingesting HV_phase..." %cpu
        HVphase = mmapChannel(HVphase, plrimage_img,  3,  line_count,  sample_count)

        print "cpu %d: Reshaping...." %cpu
        HHamp_orig = HHamp.reshape(line_count, -1)
        HHphase_orig = HHphase.reshape(line_count, -1)
        HVamp_orig = HVamp.reshape(line_count, -1)
        HVphase_orig = HVphase.reshape(line_count, -1)

        shape=HHamp_orig.shape

        print "cpu %d: Turning HH and HV into complex images" %cpu
        HHcomplex = np.ones(shape,  dtype='complex64')
        HVcomplex = np.ones(shape,  dtype='complex64')
        for i in xrange(line_count):     #line_count... set to 10 for testing
            for j in xrange(sample_count):     #sample_count.... set to 10 for testing
                HHcomplex[i, j] = cmath.rect(HHamp_orig[i, j],  HHphase_orig[i, j])
                HVcomplex[i, j] = cmath.rect(HVamp_orig[i, j],  HVphase_orig[i, j])

        print "saving to .mat format for matlab"
        saveAsMatlab(HHamp_orig, 'HHamp_orig')
        saveAsMatlab(HHphase_orig, 'HHphase_orig')
        saveAsMatlab(HVamp_orig, 'HVamp_orig')
        saveAsMatlab(HVphase_orig, 'HVphase_orig')
        saveAsMatlab(HHcomplex, 'HHcomplex')
        saveAsMatlab(HVcomplex, 'HVcomplex')
    else:
        pass




if __name__ == '__main__':
    import optparse
    #ver='%prog version 0.1'
    parser = optparse.OptionParser(usage='Usage: %prog <options> basefolder', description=__description__, version="%prog version "+__version__)
    parser.add_option(
        '-v', '--verbose',
        dest='verbose',
        action='count',
        help="Increase verbosity (specify multiple times for more)"
    )
    (opts, args) = parser.parse_args()

    workingDir = args[0]
    os.chdir(workingDir)

    for file in os.listdir("."):
        if re.search('LED-', file):
            plrimage = file.split("LED-")[1]
        elif re.search('.ldr', file):
            plrimage = file.split(".ldr")[0]
        else:
            pass

    rip_asf_to_matlab(workingDir, plrimage, 0)

else:
    basefolder = os.getcwd()
    #print basefolder
    rip_asf_to_matlab(basefolder, 'LED-ALPSRP072797040-H1.1__A', 0)






