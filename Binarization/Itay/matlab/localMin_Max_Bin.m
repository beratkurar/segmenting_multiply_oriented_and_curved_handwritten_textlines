%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%localMin_Max_Bin
%
% Input: image - grayscale or color image
%               N - window size for local averaging
%
%
% Output: R - Binary output image
%                    E - Partial edge map (binary)


function [R,E]=localMin_Max_Bin(image,N)

[row col]=size(image);

centralRow=floor(row*0.1);
centralCol=floor(col*0.1);

D=lContrast(image,3);

tmp=D(centralRow:end-centralRow,centralCol:end-centralCol);
t=graythresh(tmp);

E=D>=t;
E(1,:)=0;E(end,:)=0;E(:,1)=0;E(:,end)=0;

im=double(image);
im(E==0)=0;

localSum=filter2(ones(N),im);
localNum=filter2(ones(N),E);
localMean=localSum./(localNum);
localMean(isnan(localMean))=0;

localVar=filter2(ones(N),im.^2)./localNum-localMean.^2;
E_Std=sqrt(localVar);
E_Mean=localMean;

 R=image<(E_Mean+0.5*E_Std);



