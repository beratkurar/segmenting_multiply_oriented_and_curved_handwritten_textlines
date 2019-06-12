I = imread('ms_25.png');
bin = ~I;
tic
[ result,Labels, finalLines, newLines, oldLines ] = multiSkewLinesExtraction(I, bin);
toc
