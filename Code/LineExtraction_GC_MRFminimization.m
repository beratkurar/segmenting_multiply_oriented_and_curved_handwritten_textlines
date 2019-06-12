function[Labels] = LineExtraction_GC_MRFminimization(numLines, num, CCsparseNs,Dc, LabelCost)

K =numLines+1;

%   for i=1:K
%       drawCost(Dc(i,:),L,{});
%   end

 edgeWeights =computeEdgeWeights(CCsparseNs);
    
  sG = sparse(edgeWeights);
% 
  h = GCO_Create(num, K);             % Create new object with NumSites=CC's, NumLabels=K
% 
% 
% 
  Dc(Dc > 10000000) = 10000000-1;
  LabelCost(LabelCost > 10000000) = 10000000-1;
  LabelCost = int32(round(LabelCost));
  
% 
  GCO_SetDataCost(h,int32(round(Dc))); 
 Smooth_cost = int32(ones(K)-eye(K));
 GCO_SetSmoothCost(h,Smooth_cost);
 GCO_SetLabelCost(h,LabelCost);
% 
% 
% 
 GCO_SetNeighbors(h,sG);
 GCO_Expansion(h);
 Labels = GCO_GetLabeling(h);
 GCO_Delete(h);                   % Delete the GCoptimization object when finished
% 
% 
end

function edgeWeights = computeEdgeWeights(W)
    gcScale = 100;
    beta = 1/(0.5*mean(W(W>0)));
    edgeWeights = exp(-beta * W);
    edgeWeights(edgeWeights>=1) = 0;
    edgeWeights=(round(gcScale*edgeWeights));
end
