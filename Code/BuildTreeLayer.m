function [ layer ] = BuildTreeLayer( parentL,parentNum, childL, childNum )
%#codegen

childL = childL(:);
parentL = parentL(:);

res = zeros(1,childNum);

% TODO: Think of a way to improve this code.
for i = 1:length(childL);
    if (childL(i)~=0)
        res(childL(i)) = parentL(i);
    end
end

temp = hist(res,length(res));
max_mul = max(temp);

layer = zeros(max_mul,parentNum);

for i=1:childNum
    idx = find(layer(:,res(i)) == 0,1);
    layer(idx,res(i)) = i;
end

end

