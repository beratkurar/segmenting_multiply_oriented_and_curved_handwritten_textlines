close all;

if (isunix)
    basePath = '~/';
elseif(ispc)
    basePath = 'D:/';
end
srcPath = [basePath,'Dropbox/Code/Line_Seg/DATASETS/parzivaldb-v1.0/data/page_images/'];
dstPath = [basePath,'Dropbox/Code/Line_Seg/Results/parzival/'];

options = struct('EuclideanDist',false, 'mergeLines', false, 'EMEstimation',false,... 
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',5,'thsHigh',60,'Margins', 0.1);

samplesDir = dir(srcPath);
mkdir([dstPath,'masks']); mkdir([dstPath,'lines']);

for sampleInd = 1:length(samplesDir)
    DirName = samplesDir(sampleInd).name;
    if (~strcmp(DirName(1), '.')  && ~samplesDir(sampleInd).isdir)
        fileName = samplesDir(sampleInd).name;
        [path,sampleName,ext] = fileparts(fileName);
        options.sampleName = sampleName;
        options.fileName = fileName;
        I = imread( [srcPath,'/',fileName]);
        if exist([dstPath,'masks/',sampleName,'_bin.png'], 'file') ~= 2
            bin = binarization(I,50,0);
            PageBorder = preProcessSaintGall(I);
            bin = bin & PageBorder;
            imwrite(bin, [dstPath,'masks/',sampleName,'_bin.png']);
        else
            bin = imread([dstPath,'masks/',sampleName,'_bin.png']);
        end
        [result,Labels, linesMask, LabeledLines] = ExtractLines(I, bin, options);      
        [result,Lines,rect] = postProcessByRect(LabeledLines,result);
        finalLines = PostProcessParzival(I, result, Lines, rect);
        [L,num] = bwlabel(bin);
        charRange=estimateCharsHeight(I,bin,options);
        [finalResult,~,finalLines] = PostProcessByMRF(L,num,finalLines,charRange, options); 
        SaveResults2Files( I,linesMask, finalLines,finalResult,fileName,dstPath);
        close all;
    end
end