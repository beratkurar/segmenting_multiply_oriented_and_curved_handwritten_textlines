close all;

if (isunix)
    basePath = '~/';
elseif(ispc)
    basePath = 'D:/';
end
srcPath = [basePath,'Dropbox/Code/Line_Seg/DATASETS/saintgalldb-v1.0/data/page_images/'];
dstPath = [basePath,'Dropbox/Code/Line_Seg/Results/saintgall/'];

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false,... 
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',5,'thsHigh',60,'Margins', 0.1);

samplesDir = dir(srcPath);
mkdir([dstPath,'/masks']); mkdir([dstPath,'/lines']);

for sampleInd = 1:length(samplesDir)
    DirName = samplesDir(sampleInd).name;
    if (~strcmp(DirName(1), '.')  && ~samplesDir(sampleInd).isdir)
        fileName = samplesDir(sampleInd).name;
        [path,sampleName,ext] = fileparts(fileName);
        options.sampleName = sampleName;
        options.fileName = fileName;
        I = imread( [srcPath,'/',fileName]);
        if exist([dstPath,'masks/',sampleName,'_bin.png'], 'file') ~= 2
            bin = binarization(I,55,0);
            PageBorder = preProcessSaintGall(I);
            bin = bin & PageBorder;
            imwrite(bin, [dstPath,'masks/',sampleName,'_bin.png']);
        else
            bin = imread([dstPath,'masks/',sampleName,'_bin.png']);
        end
        [result,Labels, linesMask, LabeledLines] = ExtractLines(I, bin, options);    
        [finalResult,finalLines,rect] = postProcessByRect(LabeledLines,result);
        SaveResults2Files( I,linesMask, finalLines,finalResult,fileName,dstPath);
        
        close all;
    end
end