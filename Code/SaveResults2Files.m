function  SaveResults2Files( I,linesMask, newLines,result,fileName,dstPath,varargin)

    [~,LetterName,~] = fileparts(fileName);

    % Saving lines before post-processing for debugging.
    [L,~] = bwlabel(linesMask); blended = imfuse(I,label2rgb(L),'blend');
    imwrite(blended, [dstPath,LetterName,'.jpeg']);
    imwrite(linesMask,[dstPath,'/masks/',LetterName,'.png']);
    imwrite(newLines,[dstPath,'/masks/',LetterName,'_.png']);

    % Saving results in ICDAR result file format.
    fid = fopen([dstPath,'/lines/',fileName,'.dat'], 'w');
    fwrite(fid, result', 'uint32'); fclose(fid);

    % Saving lines after post-processing for debugging.
    blended = imfuse(I,label2rgb(newLines),'blend');
    if (nargin == 6)        
        imwrite(blended,[dstPath,LetterName, '_' ,'.jpeg']);
    else
        rect = varargin{1};
        h = figure; imshow(blended); axis image; hold on;
        rectangle('Position',rect,'LineWidth',1,'EdgeColor','r');
        print(h,'-djpeg','-r300',[dstPath,LetterName,'_.jpeg']);
    end
    close all;
end

