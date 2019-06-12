# segmenting_multiply_oriented_and_curved_handwritten_textlines
This is a text line extraction algorithm using scale space theory with anisotropic gaussian for multi skew lines.

Code is adapted from [Rafi Cohen's code](http://www.cs.bgu.ac.il/~rafico/LineExtraction.zip)
### How to run the code
1. Download [VML-MOC](https://www.cs.bgu.ac.il/~berat/) dataset in the experiments 

2. Copy `moc_dataset` into `matlab_line_extraction` folder

3. Run `BatchLinesScriptMoc.m`

4. Results are in `moc_dataset/test/moc_test_result/` folder

5. Evaluation is done using divahisdb evaluator jar

6. Ground truth of this dataset is pixel labels. convert them to polygon labels to use diva evaluator.

7. Run `multi_skew_data_code/pixel_labels_to_polygon_labels.m`

8. Polygon labels are in `multi_skew_dataset/polygon_label_gt` folder

9. Copy `multi_skew_dataset/polygon_label_gt` into `multi_skew_data_and_result/multi_skew_dataset_result/polygon_label_gt` folder

10. Copy `multi_skew_dataset/images` into `multi_skew_data_and_result/multi_skew_dataset_result/images` folder

11. Run `convert_to_page_format.py` to get `multi_skew_prediction_xml` and `multi_skew_truth_xml`

12. Run `batch.py`

