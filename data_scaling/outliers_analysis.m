function outliers_analysis()

% A simple outlier analysis for a the pairwise comparison data collected
% in the experiment. 
%
% The function reads the experiment data, and then call the
% pw_outlier_analysis_table provided in https://github.com/mantiuk/pwcmp.
%
% 
% More information can  be found in the description of the 
% pw_outlier_analysis_table function. 
%
%
% Author: Dounia Hammou

% Add the pwcmp functions 

addpath('../pwcmp') ;
warning('off','all');

% Read the experiment data
experiment_data_path = '../data';

input_file_bright_display = fullfile(experiment_data_path, 'bright_display_experiment_data.csv') ; 
input_file_dim_display = fullfile(experiment_data_path, 'dim_display_experiment_data.csv') ; 

D1 = readtable(input_file_bright_display, 'Delimiter', ',');
D2 = readtable(input_file_dim_display, 'Delimiter', ',');

D = [D1; D2] ; 

% Call the pw_outlier_analysis_table function
% The function returns a vector of log-10 likelihoods, one entry for each
% observer. The values represent a log-10 likelihood of observing the data 
% for k-th observer (participant) if the true JOD values are given by scaling
% data for all other participants. 
% 
% The function also displays log-10 likelihood and log-ratio difference
% for each observer. Large positive log-ratio difference (e.g. greater than
% 1) could indicate that a particular observer is an outlier. 

[L, dist_L] = pw_outlier_analysis_table( D, 'scene', { 'condition_1', 'condition_2' },'observer', 'selection') ;
 

end 


