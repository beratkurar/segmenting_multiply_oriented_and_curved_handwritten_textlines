function [all_baseline_points,all_baseline_indices] = multi_baseline_extractor(labeled_image)
    labels=unique(labeled_image);
    all_baseline_points=cell([length(labels)-1,1]);
    all_baseline_indices=cell([length(labels)-1,1]);
    for i=2:length(labels)
        label=labels(i);
        I=(labeled_image==label);
        I=bwareaopen(I,60);
        components=bwlabel(I);
        component_labels=unique(components);
        baseline_indices=cell([length(component_labels)-1,1]);
        baseline_points=cell([length(component_labels)-1,1]);
        for j=2:length(component_labels)
            component_label=component_labels(j);
            component=(components==component_label);
            [component_baseline_points,component_baseline_indices]=baseline_extractor(component);
            baseline_points{j-1}=component_baseline_points;
            baseline_indices{j-1}=component_baseline_indices;
        end
       
        all_baseline_indices{i-1}=cell2mat(baseline_indices);
        all_baseline_points{i-1}=cell2mat(baseline_points);
    end
   

end