function  narLst=getNarrowPixels(onLst)
   
%straight lines
l=circshift(onLst,[0 1]);
r=circshift(onLst,[0 -1]);
u=circshift(onLst,[1 0]);
d=circshift(onLst,[-1 0]);
%diagonals
lu=circshift(onLst,[1 1]);
ld=circshift(onLst,[-1 1]);
ru=circshift(onLst,[1 -1]);
rd=circshift(onLst,[-1 -1]);

tmp=l+r+u+d+lu+ld+ru+rd;
narLst=tmp>0;