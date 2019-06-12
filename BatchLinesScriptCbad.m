close all;

%for cbad simple.
orgsPath = 'cropped_cbad_2017_simple_test/images/';
partsPath = 'cropped_cbad_2017_simple_test/crop_text_regions/';
dstPath = 'cropped_cbad_2017_simple_test/crop_cbad_2017_simple_test_result/';

% Evaluation Map estimation -  turn this option on for highly degraded gray scale images.
options = struct('EuclideanDist',true, 'mergeLines', true, 'EMEstimation',false,... 
    'cacheIntermediateResults', true, 'orgPath',orgsPath, 'dstPath', dstPath, 'thsLow',15,'thsHigh',Inf,'Margins', 0);

%options = merge_options(options,varargin{:});

orgsDir = dir(orgsPath);
partsDir=dir(partsPath);
% mkdir([dstPath,'fused_polygons']); 
% mkdir([dstPath,'polygon_labels']);
% mkdir([dstPath,'pixel_labels']);
% mkdir([dstPath,'baseline_images']);
mkdir([dstPath,'baseline_coordinates']);

for orgInd = 34:length(orgsDir)
    fileName = orgsDir(orgInd).name;
    if (contains(fileName,'.jpg'))
        fprintf('%d - filename %s \n',orgInd,fileName);
        options.sampleName = fileName;
        page = imread([orgsPath,fileName]);
        [width,height,ch]=size(page);
        whole_polygon_labels=zeros(width,height);
        part_names=dir([partsPath,'*',fileName]);
        for part_ind = 1:length(part_names)
            part_name=part_names(part_ind).name;
            fprintf('%d - partname %s \n',part_ind,part_name);
            split_part_name=split(part_name,'#');
            y=str2double(split_part_name(2));
            x=str2double(split_part_name(3));
            part_image=imread([partsPath,part_name]);

            bin = binarization(part_image,25,0);
            [result,Labels, linesMask, newLines] = ExtractLines(part_image, bin, options);
            [part_polygon_labels] = postProcessByBoundPolygon( result);
            
            [part_width,part_height]=size(part_polygon_labels);
            x_end=x+part_width;
            y_end=y+part_height;
            max_label=max(unique(whole_polygon_labels));
            new_polygon_labels=make_new_labels(part_polygon_labels,max_label);
  
            whole_polygon_labels(x:x_end-1,y:y_end-1)=new_polygon_labels;

        end

        
        CbadSaveResults2Files(page,whole_polygon_labels,result,fileName,dstPath);
    end

 end

    function [new_polygon_labels]=make_new_labels(part_polygon_labels, max_label)
        new_polygon_labels=zeros(size(part_polygon_labels));
        part_labels=unique(part_polygon_labels);
        for i=2:length(part_labels)
            part_label=part_labels(i);
            new_polygon_labels(part_polygon_labels==part_label)=max_label+i;
        end
    end