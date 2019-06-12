==============================================================================================
Using Scale-Space Anisotropic Smoothing for Text Line Extraction in Historical Documents
==============================================================================================
At first, run gco-v3.0\matlab\GCO_UnitTest.m

1. Main functions:
------------------
This package contains the following functions
ExtractLines.m 			 - Implementation of the line extraction algorithm (Section 4)
BatchLinesScriptXXX.m 	 - A script for running the algorithm on the XXX(ICDAR/PARZIVAL/SAINT GALL) dataset images.

2. Usage example:
-----------------
Here is a small usage example. You may copy-paste these commands into Matlab:

I = imread('101.tif');
bin = ~I;		  													% ICDAR is composed of binary images. We assume that the text is brigher than the background.	
[result,Labels, linesMask, newLines] = ExtractLines(I, bin);		% Extract the lines, linesMask = intermediate line results for debugging.
imshow(label2rgb(result))											% Display result


The code for multi-skew lines is run using the following commands:

I = imread('ms_25.png');
bin = ~I;
[ result,Labels, finalLines, newLines, oldLines ] = multiSkewLinesExtraction(I, bin);
imshow(label2rgb(result))

3. Environment:
---------------
The code was tested on MATLAB 2013 using windows 8.1 and windows 7.

4. Proper reference:
-------------------
Using this software in any academic work you must cite the following work in any resulting publication:
Rafi Cohen, Itshak Dinstein, Jihad El-Sana, Klara Kedem. "Using Scale-Space Anisotropic Smoothing for Text Line Extraction in Historical Documents", ICIAR 2014


A. Included packages:
---------------------
1. Multi-label graph cut minimization
Delong, A., Osokin, A., Isack, H.N., Boykov, Y.: Fast approximate energy minimization with label costs. IJCV 96(1), 1{27 (2012)
2. Bar-Yosef's Binarization algorithm
H-DIBCO 2010 – Handwritten Document Image Binarization Competition
3. Fast anisotropic gauss filtering
J.-M. Geusebroek, A. W. Smeulders, and J. Van De Weijer. Fast anisotropic gauss ﬁltering. IEEE Transactions on Image Processing, 12(8):938–943, 2003.
4. Evolution maps for connected componenets in text documents, Ofer Biller, Klara Kedem, Itshak Dinstein and Jihad El-Sana, ICFHR’2012, pp. 405-410.

------------------------------------------

B. Resources:
-------------
1. ICDAR 2013  		 	- http://users.iit.demokritos.gr/~nstam/ICDAR2013HandSegmCont/resources.html
2. Parzival/Saint Gall  - http://www.iam.unibe.ch/fki/databases/iam-historical-document-database
3. BGU_LINE_EXTRACTION	- http://www.cs.bgu.ac.il/~abedas/dataset/Dataset_BGU_LINE_EXTRACTION.zip	

