%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%sw_Length
%
% Input: image - binary image
%
%
%                   verSW - vertical stroke width for each boundary pixel

function [verSW]=ver_sw_Length(image)

[row, col]=size(image);
verSW=zeros(row,col);


r=1;
c=1;
index=0;
while( c<=col)
    l = image(r,c);
    %count number of pixels
    while(r<=row && image(r,c)==l)
        index=index+1;
        r=r+1;
    end
    verSW(r-1,c)=index;
    verSW(r-index,c)=index;
    
    index=0;
    if (r>row)
        c=c+1;
        r=1;
    end
end


