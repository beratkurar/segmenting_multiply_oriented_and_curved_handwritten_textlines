close all;

srcPath = 'multi_skew_dataset/images/';
dstPath = 'multi_skew_dataset/multi_skew_dataset_result/';

delta_theta = 2.5;
theta = 0:delta_theta:180-delta_theta;

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false, 'theta',theta, 'skew',false,...
    'cacheIntermediateResults', true, 'srcPath',srcPath, 'dstPath', dstPath, 'thsLow',10,'thsHigh',200,'Margins', 0.03);


samplesDir = dir(srcPath);
mkdir([dstPath,'predicted_blended_lines']);
mkdir([dstPath,'predicted_fused_polygons']); 
mkdir([dstPath,'predicted_polygon_labels']);
mkdir([dstPath,'predicted_pixel_labels']);
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

        %[result,Labels, finalLines, newLines, oldLines ] = multiSkewDatasetLinesExtraction(I, bin, options);
        [result,Labels, linesMask, newLines] = ExtractLines(I, bin, options);
        [polygon_labels] = postProcessByBoundPolygon( result);
        blended = imfuse(I,label2rgb(polygon_labels),'blend');
        imwrite(blended, [dstPath,'/predicted_fused_polygons/',sampleName,'.png']);
        res_blended = imfuse(bin,label2rgb(linesMask),'blend');
        imwrite(res_blended, [dstPath,'/predicted_blended_lines/',sampleName,'.jpeg']);
        imwrite(label2rgb(result),[dstPath,'/predicted_pixel_labels/',sampleName,'.png']);      
        imwrite(uint8(polygon_labels),[dstPath,'/predicted_polygon_labels/',sampleName,'.png']);
        close all;
    end
end