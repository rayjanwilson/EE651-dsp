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


class Metadata:
    """
    This class pulls in the metadata from the image.meta file
    """
    pass

def runCommand(command):
    try:
        retcode = call(command, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
        else:
            print >>sys.stderr, "Child returned", retcode
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e

def mmapChannel(arrayName,  fileName,  channelNo,  line_count,  sample_count, data_type):
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

        print "\tarrayName.itemsize: ", arrayName.itemsize
        #print "mapread: ", map.read(arrayName.itemsize)

        print "total number of elements: ", line_count*sample_count
        for i in xrange(line_count*sample_count):
            if (i%1000 == 0):
                print "%s of %s"% (str(i), str(line_count*sample_count) )
            if(data_type == 'BYTE'):
                arrayName[0, i] = unpack('>b', map.read(arrayName.itemsize) )[0]
            else:
                arrayName[0, i] = unpack('>f', map.read(arrayName.itemsize) )[0]

        #same method as above, just more verbose for the programmer
#        for i in xrange(line_count*sample_count): #row
#            be_float = map.read(arrayName.itemsize) # arrayName.itemsize should be 4 for float32
#            le_float = unpack('>f', be_float)[0] # > for big endian, < for little endian
#            arrayName[0, i]= le_float

        map.close()
    return arrayName

def mmapChannelComplex(arrayReal, arrayImag, fileName,  channelNo,  line_count,  sample_count):
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

def process_L0(image):
    pass
def process_L1(image):
    pass
def process_L10(image):
    pass
def process_L11(image):
    if (band_count == 1):
        print "Working on band 1"
        print "Initializing the Amp HH and Phase HH arrays..."
        HHamp = np.ones((1,  line_count*sample_count),  dtype='float32')
        HHphase = np.ones((1,  line_count*sample_count),  dtype='float32')

        print "Ingesting HH_Amp..."
        HHamp = mmapChannel(HHamp, image_img,  0,  line_count,  sample_count)

        print "Reshaping HHamp...."
        HHamp_orig = HHamp.reshape(line_count, -1)
        print "saving HHamp to .mat format for matlab"
        saveAsMatlab(HHamp_orig, 'HHamp_orig')

        print "Ingesting HH_phase..."
        HHphase = mmapChannel(HHphase, image_img,  1,  line_count,  sample_count)
        print "Reshaping HHphase..."
        HHphase_orig = HHphase.reshape(line_count, -1)
        print "saving HHphase to .mat format for matlab"
        saveAsMatlab(HHphase_orig, 'HHphase_orig')

        print "Turning HH into complex images"
        shape=HHamp_orig.shape
        HHcomplex = np.ones(shape,  dtype='complex64')

        for i in xrange(line_count):     #line_count... set to 10 for testing
            for j in xrange(sample_count):     #sample_count.... set to 10 for testing
                HHcomplex[i, j] = cmath.rect(HHamp_orig[i, j],  HHphase_orig[i, j])

        print "saving HHcomplex to .mat format for matlab"
        saveAsMatlab(HHcomplex, 'HHcomplex')
    elif (band_count > 1):
        print "Initializing the Amp HH HV, and Phase HH HV arrays..."
        HHamp = np.ones((1,  line_count*sample_count),  dtype='float32')
        HHphase = np.ones((1,  line_count*sample_count),  dtype='float32')
        HVamp = np.ones((1,  line_count*sample_count),  dtype='float32')
        HVphase = np.ones((1,  line_count*sample_count),  dtype='float32')

        print "I think image is: ",  image

        print "Ingesting HH_Amp..."
        HHamp = mmapChannel(HHamp, image_img,  0,  line_count,  sample_count)
        print "Ingesting HH_phase..."
        HHphase = mmapChannel(HHphase, image_img,  1,  line_count,  sample_count)
        print "Ingesting HV_AMP..."
        HVamp = mmapChannel(HVamp, image_img,  2,  line_count,  sample_count)
        print "Ingesting HV_phase..."
        HVphase = mmapChannel(HVphase, image_img,  3,  line_count,  sample_count)

        print "Reshaping...."
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
def process_LB2(image):
    image_img = image + '.img'

    print "asf_import ", image
    cmd = "asf_import "+ image + " " + image
    runCommand(cmd)

    data_type = ""
    band_count = 0
    line_count = 0
    sample_count = 0
    x_pixel_size = 0
    y_pixel_size = 0
    center_latitude = 0
    center_longitude = 0
    metafile = image + ".meta"

    with open(metafile, "rb") as file:
        for line in file:
            if re.search('original_line_count',  line):
                pass
            elif re.search('original_sample_count',  line):
                pass
            elif re.search(' data_type', line):
                data_type = line.split(" ")[5]
                print "data type: ", data_type
            elif re.search('band_count', line):
                band_count = int( line.split(" ")[5] )
                print "band_count: ", band_count
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

    if (band_count == 1):
        print "Working on band 1"
        print "Initializing the Amp array..."
        #Amp = np.ones((1,  line_count*sample_count),  dtype='float32')
        Amp = np.ones((1,  line_count*sample_count),  dtype='b')

        print "Ingesting Amp..."
        Amp = mmapChannel(Amp, image_img,  0,  line_count,  sample_count, data_type)

        print "Reshaping Amp...."
        Amp_orig = Amp.reshape(line_count, -1)
        print "saving Amp to .mat format for matlab"
        saveAsMatlab(Amp_orig, 'Amplitude')
    else:
        print "Dont know what to do"

def imageImport(image):
    print "asf_import ", image
    cmd = "asf_import "+ image + " " + image
    runCommand(cmd)

    band_count = 0
    line_count = 0
    sample_count = 0
    x_pixel_size = 0
    y_pixel_size = 0
    center_latitude = 0
    center_longitude = 0
    metafile = image + ".meta"

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

def rip_asf_to_matlab(imageType, image):
    if(imageType == 'L0'):
        imageImport(image)
        process_L0(image)
    elif(imageType == 'L1'):
        imageImport(image)
        process_L1(image)
    elif(imageType == 'L1.0'):
        imageImport(image)
        process_L10(image)
    elif(imageType == 'L1.1'):
        imageImport(image)
        process_L11(image)
    elif(imageType == 'LB1'):
        print "Unsupported optical image"
    elif((imageType == 'optical') or (imageType == 'LB2')):
        #imageImport(image)
        process_LB2(image)
    else:
        print "Unknown image type!!"
        print "Aborting"




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
    parser.add_option(
        '-r', '--recursive',
        dest='recursive',
        default=False,
        action='store_true',
        help="Recursively search directories and perform conversion"
    )
    parser.add_option(
        '-t', '--type',
        dest='type',
        action='store',
        help="tell it what type of image\nlegacy: L0, L1\nalos palsar: L1.0, L1.1\nalos prism: LB1 LB2\nnote: LB1 is not supported by asf_import and will pass over it"
    )
    (opts, args) = parser.parse_args()

    workingDir = args[0]
    os.chdir(workingDir)
    basedir = os.getcwd()

    if(opts.type):
        print "The type is: ", opts.type

    if(opts.recursive): #perform conversion on every LED or .ldr file under this directory
        print "recursively converting all LED and .ldr files"
        for root, dirs, files in os.walk(basedir):
            for file in files:
                if re.search('LED-', file) or re.search('.ldr', file):
                    print "%s/%s" % (root, file)
                    workingDir = root
                    os.chdir(workingDir)
                    if re.search('LED-', file):
                        image = file.split("LED-")[1]
                        rip_asf_to_matlab(opts.type, image)
                        #print "\tIm in:\t", os.getcwd()
                        os.chdir(basedir)
                    elif re.search('.ldr', file):
                        image = file.split(".ldr")[0]
                        rip_asf_to_matlab(opts.type, image)
                        os.chdir(basedir)


    else:   #only work in this directory
        for file in os.listdir("."):
            if re.search('LED-', file):
                image = file.split("LED-")[1]
                rip_asf_to_matlab(opts.type, image)
            elif re.search('.ldr', file):
                image = file.split(".ldr")[0]
                rip_asf_to_matlab(opts.type, image)
            else:
                pass





