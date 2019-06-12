function  CbadSaveResults2Files( I,polygon_labels,result,fileName,dstPath,varargin)

    [~,LetterName,~] = fileparts(fileName);
%     blended = imfuse(I,label2rgb(polygon_labels),'blend');
%     imwrite(blended, [dstPath,'/fused_polygons/',LetterName,'.png']);
%     imwrite(uint8(polygon_labels),[dstPath,'/polygon_labels/',LetterName,'.png']);
%     imwrite(label2rgb(result),[dstPath,'/pixel_labels/',LetterName,'.png']);
    [all_baseline_points,all_baseline_indices]=multi_baseline_extractor(polygon_labels);
%     draw_save_path=[dstPath,'/baseline_images/',LetterName,'.png'];
%     draw_baseline_image(all_baseline_indices,I,draw_save_path);
    baseline_save_path=[dstPath,'/baseline_coordinates/',LetterName,'.txt'];
    save_baselines_to_file(all_baseline_points,baseline_save_path);
    
    close all;
end
function save_baselines_to_file(all_baseline_points,baseline_save_path)
    format shortG;
    fid=fopen(baseline_save_path,'w');
    for i=1:length(all_baseline_points)
        baseline=round(all_baseline_points{i});
        for coord=1:length(baseline)
            if coord==length(baseline)
                fprintf(fid,'%d,%d\n',baseline(coord,1),baseline(coord,2));
            else
                fprintf(fid,'%d,%d;',baseline(coord,1),baseline(coord,2));
            end
        end
    end
    fclose(fid);
end
