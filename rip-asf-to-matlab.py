#!/usr/bin/python

# open up an asf internal file and save the matrix to matlab format
# requires an installation of asf mapready to work

from struct import unpack
import mmap
import scipy.io as sio
import numpy as np
import os, sys, re
from subprocess import *
import math
import cmath

def runCommand(command):
    try:
        retcode = call(command, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
        else:
            print >>sys.stderr, "Child returned", retcode
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e
def mmapChannel(arrayName,  fileName,  channelNo,  line_count,  sample_count):
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
        map.seek(channelNo*line_count*sample_count*arrayName.itemsize)

        for i in xrange(line_count*sample_count):
            arrayName[0, i] = unpack('>f', map.read(arrayName.itemsize) )[0]

        #same method as above, just more verbose for the programmer
#        for i in xrange(line_count*sample_count): #row
#            be_float = map.read(arrayName.itemsize) # arrayName.itemsize should be 4 for float32
#            le_float = unpack('>f', be_float)[0] # > for big endian, < for little endian
#            arrayName[0, i]= le_float

        map.close()
    return arrayName
    
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
            elif re.search('line_count',  line):
                #print "I found line_count!"
                line_count = int( line.split(" ")[5] )
                print "Line count: ",  line_count
            elif re.search('sample_count', line):
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


basefolder = os.getcwd()
#print basefolder

rip_asf_to_matlab(basefolder, 'LED-ALPSRP072797040-H1.1__A', 0)
