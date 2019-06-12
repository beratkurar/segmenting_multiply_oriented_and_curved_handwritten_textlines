function [ppProcess, lines] = NiblackPreProcess(max_response, bin, N )

im = double(max_response);
localSum=filter2(ones(N),im);
localNum=filter2(ones(N),im*0+1);
localMean=localSum./(localNum);
localMean(isnan(localMean))=0;

localStd = stdfilt(im,ones(N)); 

ppProcess = ((im-localMean)./(localStd))*20;

high = 22; low = 8; 
lines = hysthresh(ppProcess, high, low);
lines = imreconstruct(bin & lines, lines);
[Lines,~] = bwlabel(lines);
figure; imshow(imfuse(bin,label2rgb(Lines),'blend'));

end

