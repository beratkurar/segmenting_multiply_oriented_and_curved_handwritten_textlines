function draw_baseline_image(all_baseline_indices,original_image,draw_save_path)
    for i=1:length(all_baseline_indices)
        one_baseline_indices=all_baseline_indices{i};
        original_image(one_baseline_indices)=255;

    end
    imwrite(original_image,draw_save_path);
end
    
