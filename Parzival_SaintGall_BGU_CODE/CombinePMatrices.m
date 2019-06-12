function [ PHT, Line_Accuracy ] = CombinePMatrices( Results)
% Now we combine the P matrices to one big matrix.

DocsNum = length(Results);

rowsNum = 0;
colsNum = 0;
for i=1:DocsNum
    sz = size(Results{i,1});
    rowsNum = rowsNum + sz(1);
    colsNum = colsNum + sz(2);
end

GTLinesNum = rowsNum;
P = zeros(rowsNum, colsNum);
GTArea = zeros(rowsNum,1);
RArea = zeros(colsNum,1);

rowsNum = 1;
colsNum = 1;
for i=1:DocsNum
    sz = size(Results{i,1});
    P(rowsNum:rowsNum + sz(1) - 1, colsNum:colsNum + sz(2) - 1) = Results{i,1};
    GTArea(rowsNum:rowsNum + sz(1) - 1) = Results{i,2};
    RArea(colsNum:colsNum + sz(2) - 1) = Results{i,3};
    rowsNum = rowsNum + sz(1);
    colsNum = colsNum + sz(2);
end


[Matching,Cost] = Hungarian(-P);
G_S = -Cost;
GT_Union_R = sum(sum(RArea)) + sum(sum(GTArea)) - sum(sum(P));
PHT = G_S/GT_Union_R;
[X,Y] = find(Matching);



Line_Accuracy = 0;

for t=1:length(X)
    i = X(t);
    j = Y(t);
    if (P(i,j)/GTArea(i) > 0.9)
        if (P(i,j)/RArea(j) > 0.9)
            Line_Accuracy = Line_Accuracy + 1;
        end
    end
end

Line_Accuracy = Line_Accuracy/GTLinesNum;
end

