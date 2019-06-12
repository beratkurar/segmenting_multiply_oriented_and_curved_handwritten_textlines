close all;
if (isunix)
    basePath = '~/';
elseif(ispc)
    basePath = 'D:/';
end
% srcPath = [basePath,'Dropbox/Code/Line_Seg/DATASETS/ICDAR 2009/images_test/'];
% dstPath = [basePath,'Dropbox/Code/Line_Seg/Results/ICDAR2009/'];

%for ICDAR 2013.
srcPath = [basePath,'Dropbox/Code/Line_Seg/DATASETS/ICDAR 2013/images_test/'];
dstPath = [basePath,'Dropbox/Code/Line_Seg/Results/ICDAR2013/'];

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false,... 
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',15,'thsHigh',Inf,'Margins', 0);

%options = merge_options(options,varargin{:});

samplesDir = dir(srcPath);
mkdir([dstPath,'masks']); mkdir([dstPath,'lines']);

for sampleInd = 1:length(samplesDir)
    fileName = samplesDir(sampleInd).name;
    [path,sampleName,ext] = fileparts(fileName);
    if (strcmp(ext,'.tif'))
        options.sampleName = sampleName;
        options.fileName = fileName;
        I = imread( [srcPath,'/',fileName]);
        bin = ~I;
        [result,Labels, linesMask, newLines] = ExtractLines(I, bin, options);
        SaveResults2Files(I,linesMask, newLines,result,fileName,dstPath)
    end
end