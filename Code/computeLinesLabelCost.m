function [ LabelCost ] = computeLinesLabelCost( L,Lines,numLines )

acc = zeros(numLines+1,1);
mask_ = L(:);
L_ = Lines(:);

for i=1:length(L_)
    if ((L_(i)) && (mask_(i)))
        acc(L_(i)) = acc(L_(i))+1;
    end
end

 LabelCost = exp(0.2*max(acc)./acc);
 LabelCost(numLines+1) = 0;
end

