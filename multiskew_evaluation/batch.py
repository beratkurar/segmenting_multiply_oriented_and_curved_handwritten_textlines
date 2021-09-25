# -*- coding: utf-8 -*-
"""
Created on Tue Jan 23 10:46:02 2018

@author: B
"""

import os
import subprocess
import numpy as np

imageGroundTruth=[]
xmlGroundTruth=[]
xmlPrediction=[]
overlap=[]
outputPath='../multi_skew_overlap_output/'
os.makedirs('multi_skew_overlap_output')
csv=False


imageGroundTruth_folder='diva_pixel_label_gt/'
xmlGroundTruth_folder='multi_skew_truth_xml/'
xmlPrediction_folder='multi_skew_prediction_xml/'
original_image_folder='images/'

imageGroundTruth=sorted(os.listdir(imageGroundTruth_folder))
xmlGroundTruth=sorted(os.listdir(xmlGroundTruth_folder))
xmlPrediction=sorted(os.listdir(xmlPrediction_folder))
original_image=sorted(os.listdir(original_image_folder))

number_of_files=len(os.listdir(imageGroundTruth_folder))
args=[]
for i in range(number_of_files):
    args.append('-igt')
    args.append(imageGroundTruth_folder + imageGroundTruth[i])
    args.append('-xgt')
    args.append(xmlGroundTruth_folder + xmlGroundTruth[i])
    args.append('-xp')
    args.append(xmlPrediction_folder+xmlPrediction[i])
    args.append('-overlap')
    args.append(original_image_folder + original_image[i])
    args.append('-out')
    args.append(outputPath)

lineIU=[]
lineF1=[]
f=open(original_image_folder[:-1]+'_results.txt','w')

for i in range(number_of_files):
    cmd=args[i*10:i*10+10]
    cmd.insert(0,'LineSegmentationEvaluator.jar')
    cmd.insert(0,'-jar')
    cmd.insert(0,'java')
    print(cmd)
    p = subprocess.Popen(cmd, universal_newlines=True,
                         stdin=subprocess.PIPE, stdout=subprocess.PIPE,bufsize=1)
    stdO,stdE = p.communicate()
    print(stdO)
    ind=stdO.find('line IU')
    lineiu=stdO[ind+10:ind+15]

        
    try:
        lineiu = float(stdO[ind + 10:ind + 15])
    
    except:
        lineiu = float(stdO[ind + 10:ind + 13])
    
    lineIU.append(lineiu)

    ind = stdO.find('line F1')
    linef1 = stdO[ind + 10:ind + 15]

    try:
        linef1 = float(stdO[ind + 10:ind + 15])
    except:
        linef1 = float(stdO[ind + 10:ind + 13])
        
    lineF1.append(linef1)

    print('current lineiu ', lineIU)
    print('current linef1 ', lineF1)
    filename=args[i*10+1].split('/')[1]
    print(filename)
    f.write(filename+'\t line IU=' +str(lineiu)+'\t line F1=' +str(linef1)+'\n')

mean_lineiu=np.mean(lineIU)
mean_linef1=np.mean(lineF1)

print('mean line iu = ', mean_lineiu)
print('mean line f1 = ', mean_linef1)
f.write('\n\n\n')
f.write('mean line iu = '+ str(mean_lineiu)+'\n')
f.write('mean line f1 = '+ str(mean_linef1))

f.close()