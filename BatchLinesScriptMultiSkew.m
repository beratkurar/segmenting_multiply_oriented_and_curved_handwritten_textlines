close all;
if (isunix)
    basePath = '~/';
elseif(ispc)
    basePath = 'D:/';
end
srcPath = [basePath,'Dropbox/Code/Line_Seg/DATASETS/Multi-Skew/images'];
dstPath = [basePath,'Dropbox/Code/Line_Seg/Results/Multi-Skew/'];

delta_theta = 2.5;
theta = 0:delta_theta:180-delta_theta;

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false, 'theta',theta, 'skew',false,...
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',10,'thsHigh',200,'Margins', 0.03);


samplesDir = dir(srcPath);
mkdir([dstPath,'masks']); mkdir([dstPath,'lines']); mkdir([dstPath,'broken_lines']);

for sampleInd = 1:length(samplesDir)
    fileName = samplesDir(sampleInd).name;
    if (~strcmp(fileName(1), '.')  && ~samplesDir(sampleInd).isdir)
        fileName = samplesDir(sampleInd).name;
        [path,sampleName,ext] = fileparts(fileName);
        sampleNum = str2double(sampleName(8:end));
        I = imread( [srcPath,'/',fileName]);
        bin = ~I;
        options.sampleName = sampleName;
        options.fileName = fileName;
        if exist([dstPath,'lines/',sampleName,'.mat'], 'file') ~= 2
            [result,Labels, finalLines, newLines, oldLines ] = multiSkewLinesExtraction(I, bin, options);
            save([dstPath,'lines/',sampleName],'result','Labels', 'finalLines', 'newLines', 'oldLines');
        else
            load([dstPath,'lines/',sampleName]);
        end
        close all;
        res_blended = imfuse(bin,label2rgb(finalLines),'blend');
        imwrite(res_blended, [dstPath,sampleName,'.jpeg']);
        imwrite(label2rgb(result),[dstPath,sampleName,'.png']);
    end
end