function  DivaSaveResults2Files( I,polygon_labels,result,fileName,dstPath,varargin)

    [~,LetterName,~] = fileparts(fileName);
    blended = imfuse(I,label2rgb(polygon_labels),'blend');
    imwrite(blended, [dstPath,'/fused_polygons/',LetterName,'.png']);
    imwrite(uint8(polygon_labels),[dstPath,'/polygon_labels/',LetterName,'.png']);
    imwrite(label2rgb(result),[dstPath,'/pixel_labels/',LetterName,'.png']);
    close all;
end

