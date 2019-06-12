close all;
imgPath = 'moc_dataset/train/moc_train_images/';
srcPath = 'moc_dataset/train/moc_train_pixel_label/';
dst2Path = 'moc_dataset/train/moc_train_rgb_polygon_label/';
dst1Path = 'moc_dataset/train/moc_train_polygon_label/';

samplesDir = dir(srcPath);
mkdir(dst1Path);
mkdir(dst2Path);
for sampleInd = 1:length(samplesDir)
    fileName = samplesDir(sampleInd).name;
    if (~strcmp(fileName(1), '.')  && ~samplesDir(sampleInd).isdir)
        fileName = samplesDir(sampleInd).name;
        fprintf('%d - filename %s \n',sampleInd,fileName);
        I = imread( [imgPath,fileName]);
        pixel_labels = imread( [srcPath,fileName]);
        [polygon_labels] = postProcessByThreshedBoundPolygon(pixel_labels);     
        imwrite(uint8(polygon_labels),[dst1Path,fileName]);
        blended = imfuse(I,label2rgb(polygon_labels),'blend');
        imwrite(blended,[dst2Path,fileName]);
    end
end





