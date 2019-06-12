close all;

polyPath = 'moc_dataset/train/moc_train_polygon_label/';
imgPath = 'moc_dataset/train/moc_train_images/';
dstPath = 'moc_dataset/train/moc_train_diva_pixel_label/';

samplesDir = dir(imgPath);
mkdir(dstPath);
%bacground is encoded to  rgb 0,0,1
%text body is encoded to rgb 0,0,128
%boundary is encoded to rgb 128,0,0
for sampleInd = 1:length(samplesDir)
    fileName = samplesDir(sampleInd).name;
    if (~strcmp(fileName(1), '.')  && ~samplesDir(sampleInd).isdir)
        fileName = samplesDir(sampleInd).name;
        fprintf('%d - filename %s \n',sampleInd,fileName);
        img = imread( [imgPath,fileName]);
        poly = imread( [polyPath,fileName]);
        [h,w,c]=size(img);
        gt=zeros(h,w,3,'uint8');
        red=gt(:,:,1);
        green=gt(:,:,2);
        blue=gt(:,:,3);
        blue(img==1)=1;
        blue(img==0)=8;
        red(img==1 & poly~=0)=128;
        gt=cat(3,red,green,blue);
        imwrite(gt,[dstPath,fileName]);

    end
end





