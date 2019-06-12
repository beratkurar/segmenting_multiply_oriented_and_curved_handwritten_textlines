close all;
% Are we evaluating Saint-Gall or Parzival ?
if (~exist('isSaintGall'))
    isSaintGall = true;
end

if (isSaintGall)
    srcPath = 'D:\Dropbox\Code\Line_Seg\DATASETS\saintgalldb-v1.0\data\page_images\';
    dstPath = 'D:\Dropbox\Code\Line_Seg\Results\saintgall\';
    GT = 'D:\Dropbox\Code\Line_Seg\DATASETS\saintgalldb-v1.0\ground_truth\line_location\';
    DocsNum = 60;
else
    srcPath = 'D:\Dropbox\Code\Line_Seg\DATASETS\parzivaldb-v1.0\data\page_images\';
    dstPath = 'D:\Dropbox\Code\Line_Seg\Results\parzival\';
    GT = 'D:\Dropbox\Code\Line_Seg\DATASETS\parzivaldb-v1.0\ground_truth\line_location\';
    DocsNum = 47;
end

cd(srcPath);
LettersDir = dir(srcPath);
Results = cell(DocsNum,3);
index = 1;
for LetterInd = 1:length(LettersDir)
    DirName = LettersDir(LetterInd).name;
    if (~strcmp(DirName(1), '.')  && ~LettersDir(LetterInd).isdir)
        fileName = LettersDir(LetterInd).name;
        [path,LetterName,ext] = fileparts(fileName);
        I = imread( [srcPath,'/',fileName]);
        bin = imread([dstPath,'masks/',LetterName,'_bin.png']);
        fid = fopen([dstPath,'\lines\',fileName,'.dat'], 'r');
        sz = size(I);
        result = fread(fid,[sz(2) sz(1)], 'uint32' );
        result = result';
        if (isSaintGall)
            GT_filename = [GT,LetterName,'.svg'];
        else
            GT_filename = [GT,LetterName,'.mat'];
        end
        [P, RArea, GTArea,GTMask] =  evalLD_SaintGallOrParzival(GT_filename, result, bin, isSaintGall);
        Results{index,1} = P;
        Results{index,2} = GTArea;
        Results{index,3} = RArea;
        index = index + 1;

        if exist([dstPath,LetterName,'_gt.jpeg'], 'file') ~= 2
            blended = imfuse(I,label2rgb(GTMask),'blend');
            imwrite(blended, [dstPath,LetterName,'_gt.jpeg']);
        end
        
        fclose(fid);
        clear result;
    end
end

[ PHT, Line_Accuracy ] = CombinePMatrices( Results);
fprintf('PHT: %0.4f,  Line_Accuracy: %0.4f\n',PHT,Line_Accuracy);
