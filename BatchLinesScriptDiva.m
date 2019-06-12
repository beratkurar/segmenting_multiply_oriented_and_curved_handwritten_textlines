close all;

%for diva hisdb.
srcPath = 'diva_dataset/crop_cb55/';
dstPath = 'diva_dataset/crop_cb55_result/';

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false,... 
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',15,'thsHigh',Inf,'Margins', 0);

%options = merge_options(options,varargin{:});

samplesDir = dir(srcPath);
mkdir([dstPath,'fused_polygons']); mkdir([dstPath,'polygon_labels']);
mkdir([dstPath,'pixel_labels']);
for sampleInd = 1:length(samplesDir)
    fileName = samplesDir(sampleInd).name;
    [path,sampleName,ext] = fileparts(fileName);
    if (strcmp(ext,'.jpg'))
        options.sampleName = sampleName;
        options.fileName = fileName;
        I = imread( [srcPath,'/',fileName]);
        bin = binarization(I,25,0);
        [result,Labels, linesMask, newLines] = ExtractLines(I, bin, options);
        [polygon_labels] = postProcessByBoundPolygon( result);
        DivaSaveResults2Files(I,polygon_labels,result,fileName,dstPath);
    end
end