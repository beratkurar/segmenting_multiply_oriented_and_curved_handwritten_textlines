%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%
% Input: labImage - binary image to be processed
%                edgeLab -  partial edge image (binary)
%                 ths - threshold for blob filtering               
%                              1 - slower and more accurate method
%                              (including level set method)
%
% Output: res - Filtered binary image
%                    edgeCount - edge feature for each blob
%                    areaCount- area feature for each blob

function [res,edgeCount,areaCount]=edgeCountConnectivity(labImage,edgeLab,ths)

[dimX,dimY]=size(labImage);
res=zeros(dimX,dimY);
[l,num]=bwlabel(labImage);
le=bwlabel(edgeLab);

s=regionprops(l,'Area','BoundingBox');
area=[s.Area];
%for each component in labImage, check if there it is connected to a
%component in edgeLab
for ind=1:num
   box=s(ind).BoundingBox;
    
    row=max(floor(box(2))-2,1);
    col=max(floor(box(1))-2,1);
    width=floor(box(3));
    height=floor(box(4));
    
    rowEnd=min(row+height+4,dimX);
    colEnd=min(col+width+4,dimY);
    
    im=edgeLab(row:rowEnd,col:colEnd);
    bin=l(row:rowEnd,col:colEnd);
    bin=bin==ind;
    %Check in the edge image if there is some pixel connecticity
    tmp=im;
    tmp(bin==0)=0;
    if (sum(tmp(:))>0)
        res(row:rowEnd,col:colEnd)=or(res(row:rowEnd,col:colEnd),bin);
    end
 
    areaCount(ind)=sum(tmp(:))./area(ind);
    e=bin-imerode(bin,ones(3,3));
    edgeCount(ind)=sum(tmp(:))./sum(e(:));
    
end

idx=find(edgeCount>=ths);
res=ismember(l,idx);