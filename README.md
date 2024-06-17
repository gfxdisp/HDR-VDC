
# HDR-VDC: HDR AV1 video streaming quality dataset across Viewing and Display Conditions

[project webpage](https://www.cl.cam.ac.uk/research/rainbow/projects/hdr-vdc/) | [dataset](https://doi.org/10.17863/CAM.107964) | [paper](https://www.cl.cam.ac.uk/research/rainbow/projects/hdr-vdc/hdr_vdc_qomex_paper.pdf)

The ''HDR AV1 video streaming quality dataset across Viewing and Display Conditions (HDR-VDC)'' is a dataset that captures the effect of viewing distance and display  luminance on the visibility of streaming distortions in HDR content. 

The dataset is composed of 16 reference videos collected from different sources [1]-[4] and 132 test videos, including the reference. The distortion space includes two main streaming artifacts: compression and upscaling. We employed three compression levels (CRF values) using the SVT-AV1 codec [5] and three resolutions, namely,  3840x2160, 1920x1080, and 1280x720. The downscaling and upscaling of the videos were performed using the Lanczos (a=3) filter [6]. 

We employ the pairwise comparison methodology [7] and collect Just-Objectionable-Difference (JOD) scores from 30 participants. 

##

This repository contains both the code and data used to scale the pairwise comparisons to Just-Objectionable-Difference (JOD) scores. 

The dataset (the reference and test videos as well as the JOD scores) can be found and downloaded from the [dataset repository](https://doi.org/10.17863/CAM.107964) 

The details about the dataset and experiment methodology can be found on the [project website](https://www.cl.cam.ac.uk/research/rainbow/projects/hdr-vdc/). 

## Code

Currently, we provide a simple outliers analysis function in [`data_scaling/outliers_analysis.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/outliers_analysis.m), a scaling function of the pairwise comparisons to JOD scores in [`data_scaling/scale_data_to_JOD.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/scale_data_to_JOD.m), as well as statistical analysis (ANOVA) function in [`data_scaling/statistical_analysis.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/statistical_analysis.m) to measure the effect of viewing distance and display peak luminance on the JOD scores. 

The [`pwcmp`](https://github.com/gfxdisp/HDR-VDC/tree/main/pwcmp) folder contains the necessary base functions for our functions. 

## Display Model

The video files are encoded using the PQ transfer function and can span a very large dynamic range. 
They were presented in the experiment on a pair of LG G2 OLED displays, which have a limited peak luminance and color gamut. 
The video files also do not account for the dimming of the content in the `luminance_level`==`dim` conditions. 
To correctly simulate the light emitted from the display during the experiment, it is necessary to use the Python code 
with the display model, which can be found at [`display_model`](https://github.com/gfxdisp/HDR-VDC/tree/main/display_model).


## Data

The data folder contains the following CSV files:

* [`data/bright_display_experiment_data.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/bright_display_experiment_data.csv): pairwise comparisons collected in the bright-display block of all sessions. The file consists of 5 columns. 
    * observer: the anonymized unique ID of an observer. 
    * scene: the video content name.
    * condition_1: the compared test condition. 
    * condition_2: the compared test condition. 
    * selection: the condition that is selected by the observer. 1: if condition_1 is selected. 0: if condition_2 is selected. 

* [`data/dim_display_experiment_data.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/dim_display_experiment_data.csv): pairwise comparisons collected in the dim-display block of all sessions. The format of the file is the same as the previous one. 

* [`data/scaled_jod_scores.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/scaled_jod_scores.csv): The JOD scores obtained from the [`data_scaling/scale_data_to_JOD.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/scale_data_to_JOD.m) function. The file consists of 5 columns. 
    * scene: the video content name.
    * condition: the test condition.
    * jod: the quality score obtained from scaling the pairwise comparisons. The reference video would have a JOD = 10. Higher scores mean higher quality (lower visibility of distortions), and lower scores mean lower quality (higher visibility of distortions).
	* jod_high: the upper value of the 95% confidence interval of the JOD score.
	* jod_low: the lower value of the 95% confidence interval of the JOD score.

* [`data/HDR_VDC_JOD_Scores.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/HDR_VDC_JOD_Scores.csv): The file is a cleaner version of [`data/scaled_jod_scores.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/scaled_jod_scores.csv), which provides more information on the test videos. More information on the format of the file is provided in the dataset webpage README file.

* [`data/jod_distribution`](https://github.com/gfxdisp/HDR-VDC/tree/main/data/jod_distribution): The folder contains the distribution of the JOD score of each test condition, for each content and each display and viewing conditon, computed using bootstrapping with 500 samples. The results may differ slightly after re-running the [`data_scaling/scale_data_to_JOD.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/scale_data_to_JOD.m) function. The folder is composed of multiple files, for each content and each display luminance level. Where each file consists of 9 columns, corresponding to the test conditions of the content and display luminance level, and 500 rows, corresponding to the 500 samples of the distribution of the JOD score. 

* [`data/jod_distributions.csv`](https://github.com/gfxdisp/HDR-VDC/tree/main/data/jod_distributions.csv): The file is a cleaner and more compact version of the [`data/jod_distribution`](https://github.com/gfxdisp/HDR-VDC/tree/main/data/jod_distribution) files. The file consists of 11 columns: 
	* content: the video content name. 
	* viewing_distance: the viewing distance from the display. It can take 2 values: 'near' (effective resolution = 60 ppd) or 'far' (effective resolution = 120 ppd).
	* luminance_level: the luminance level of the display. It can take 2 values: 'bright' or 'dim' (where the luminance of the video is reduced by a factor of 8).
	* H_1920x1080: the distribution of the JOD score of the `crf='H'` and `resolution=1920x1080` test condition, for each content, viewing distance and display luminance level. 
	* H_1280x720: the distribution of the JOD score of the `crf='H'` and `resolution=1280x720` test condition, for each content, viewing distance and display luminance level. 
	* M_3840x2160: the distribution of the JOD score of the `crf='M'` and `resolution=3840x2160` test condition, for each content, viewing distance and display luminance level. 
	* M_1920x1080: the distribution of the JOD score of the `crf='M'` and `resolution=1920x1080` test condition, for each content, viewing distance and display luminance level. 
	* M_1280x720: the distribution of the JOD score of the `crf='M'` and `resolution=1280x720` test condition, for each content, viewing distance and display luminance level. 
	* L_3840x2160: the distribution of the JOD score of the `crf='L'` and `resolution=3840x2160` test condition, for each content, viewing distance and display luminance level. 
	* L_1920x1080: the distribution of the JOD score of the `crf='L'` and `resolution=1920x1080` test condition, for each content, viewing distance and display luminance level. 
	* L_1280x720: the distribution of the JOD score of the `crf='L'` and `resolution=1280x720` test condition, for each content, viewing distance and display luminance level. 

* [`data/HDR_VDC_sureal_dataset_file.py`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/HDR_VDC_sureal_dataset_file.py): The file is the sureal dataset file version of [`data/HDR_VDC_JOD_Scores.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/HDR_VDC_JOD_Scores.csv), which provides the same information in a different format. It also includes the distorted videos jod distribution for easier access to them. 

* [`data/HDR_VDC_sureal_dataset_file_raw.py`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/HDR_VDC_sureal_dataset_file_raw.py): The file is the sureal dataset file format of the raw pairwise comparisons, which can be also found in [`data/bright_display_experiment_data.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/bright_display_experiment_data.csv) and [`data/dim_display_experiment_data.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/dim_display_experiment_data.csv). 

* [`data/statistical_test_results.csv`](https://github.com/gfxdisp/HDR-VDC/blob/main/data/statistical_test_results.csv): statistical significance and effect size of the viewing distance and display peak luminance over all contents and for each distortion separately. The results are from the [`data_scaling/statistical_analysis.m`](https://github.com/gfxdisp/HDR-VDC/blob/main/data_scaling/statistical_analysis.m) function.

## References

[1] Song, L., Liu, Y., Yang, X., Zhai, G., Xie, R., & Zhang, W. (2016, June). The SJTU HDR video sequence dataset. In _Proceedings of International Conference on Quality of Multimedia Experience (QoMEX 2016)_ (p. 100).

[2] Froehlich, J., Grandinetti, S., Eberhardt, B., Walter, S., Schilling, A., & Brendel, H. (2014, March). Creating cinematic wide gamut HDR-video for the evaluation of tone mapping operators and HDR-displays. In _Digital photography X_ (Vol. 9023, pp. 279-288). SPIE.

[3] Barman, N., & Martini, M. G. (2021). User generated HDR gaming video streaming: dataset, codec comparison, and challenges. _IEEE Transactions on Circuits and Systems for Video Technology_, _32_(3), 1236-1249.

[4] Netflix (2020). Open Source Content. Available: [URL](https://opencontent.netflix.com). 

[5] Kossentini, F., Guermazi, H., Mahdi, N., Nouira, C., Naghdinezhad, A., Tmar, H., ... & Amara, F. B. (2020). The SVT-AV1 encoder: overview, features and speed-quality tradeoffs. _Applications of Digital Image Processing XLIII_, _11510_, 469-490.

[6] Duchon, C. E. (1979). Lanczos filtering in one and two dimensions. _Journal of Applied Meteorology and Climatology_, _18_(8), 1016-1022.

[7] Perez-Ortiz, M., & Mantiuk, R. K. (2017). A practical guide and software for analysing pairwise comparison experiments. _arXiv preprint arXiv:1712.03686_.
