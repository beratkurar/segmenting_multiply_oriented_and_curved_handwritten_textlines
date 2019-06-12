# segmenting_multiply_oriented_and_curved_handwritten_textlines
This is a text line extraction algorithm using scale space theory with anisotropic gaussian for multi skew lines.
### How to run the code
1. We used [VML-MOC](https://www.cs.bgu.ac.il/~berat/) dataset in the experiments 

2. Multi skew dataset experiment:

Copy `moc_dataset` into `matlab_line_extraction` folder

Run `BatchLinesScriptMoc.m`

Results are in `moc_dataset/test/moc_test_result/` folder

3. Multi skew dataset evaluation:
Evaluation is done using divahisdb evaluator jar
Ground truth of this dataset is pixel labels. convert them to polygon labels to use diva evaluator.
Run `multi_skew_data_code/pixel_labels_to_polygon_labels.m`
Polygon labels are in `multi_skew_dataset/polygon_label_gt` folder
Copy `multi_skew_dataset/polygon_label_gt` into `multi_skew_data_and_result/multi_skew_dataset_result/polygon_label_gt` folder
Copy `multi_skew_dataset/images` into `multi_skew_data_and_result/multi_skew_dataset_result/images` folder

4. Run `convert_to_page_format.py` to get `multi_skew_prediction_xml` and `multi_skew_truth_xml`
Run `batch.py`

