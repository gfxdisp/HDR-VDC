# HDR-VDC: HDR AV1 video streaming quality dataset across Viewing and Display Conditions

The ''HDR AV1 video streaming quality dataset across Viewing and Display Conditions (HDR-VDC)'' is a dataset that captures the effect of viewing distance and display  luminance on the visibility of streaming distortions in HDR content. 

The dataset is composed of 16 reference videos collected from different sources [1]-[4] and 132 test videos, including the reference. The distortion space includes two main streaming artifacts: compression and upscaling. We employed three compression levels (CRF values) using the SVT-AV1 codec [5] and three resolutions, namely,  3840x2160, 1920x1080, and 1280x720. The downscaling and upscaling of the videos were performed using the Lanczos (a=3) filter [6]. 

We employ the pairwise comparison methodology [7] and collect Just-Objectionable-Difference (JOD) scores from 30 participants. 

We provide the reference and test videos as well as the JOD scores in: ... 

## References

[1] Song, L., Liu, Y., Yang, X., Zhai, G., Xie, R., & Zhang, W. (2016, June). The SJTU HDR video sequence dataset. In _Proceedings of International Conference on Quality of Multimedia Experience (QoMEX 2016)_ (p. 100).

[2] Froehlich, J., Grandinetti, S., Eberhardt, B., Walter, S., Schilling, A., & Brendel, H. (2014, March). Creating cinematic wide gamut HDR-video for the evaluation of tone mapping operators and HDR-displays. In _Digital photography X_ (Vol. 9023, pp. 279-288). SPIE.

[3] Barman, N., & Martini, M. G. (2021). User generated HDR gaming video streaming: dataset, codec comparison, and challenges. _IEEE Transactions on Circuits and Systems for Video Technology_, _32_(3), 1236-1249.

[4] Netflix (2020). Open Source Content. Available: [URL](https://opencontent.netflix.com). 

[5] Kossentini, F., Guermazi, H., Mahdi, N., Nouira, C., Naghdinezhad, A., Tmar, H., ... & Amara, F. B. (2020). The SVT-AV1 encoder: overview, features and speed-quality tradeoffs. _Applications of Digital Image Processing XLIII_, _11510_, 469-490.

[6] Duchon, C. E. (1979). Lanczos filtering in one and two dimensions. _Journal of Applied Meteorology and Climatology_, _18_(8), 1016-1022.

[7] Perez-Ortiz, M., & Mantiuk, R. K. (2017). A practical guide and software for analysing pairwise comparison experiments. _arXiv preprint arXiv:1712.03686_.