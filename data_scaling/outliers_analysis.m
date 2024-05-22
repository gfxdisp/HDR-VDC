function outliers_analysis(do_plot)
arguments
    do_plot logical = false 
end
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
% 1.5) could indicate that a particular observer is an outlier. 

[L, dist_L, OBSs] = pw_outlier_analysis_table( D, 'scene', { 'condition_1', 'condition_2' },'observer', 'selection') ;

% Sort the observers by index 

[observers, sort_indexes] = sort(str2double(replace(OBSs, 'observer', ''))) ; 
L_all = sum(L(sort_indexes, :), 2) ;
dist_L = dist_L(sort_indexes);


if do_plot
    % Create plots.
    
    label_size = 16;
    tick_size = 12;
    color = '#5CA0FF';
    markersize = 7;
    clf;
    
    t = tiledlayout(2,1, 'TileSpacing','tight', 'Padding','tight');
    set(gcf,'Position',[10 10 500 1000])
    
    ax1 = nexttile;
    h1 = plot(ax1,L_all, observers, 'o', 'color', color);
    grid on;
    
    ax2 = nexttile;
    h2 = plot(ax2,dist_L, observers, 'o', 'color', color);
    grid on;
    
    set(h1, 'markerfacecolor', color, 'MarkerSize', markersize);
    set(h2, 'markerfacecolor', color, 'MarkerSize', markersize);

    
    set(ax1, 'YTick', observers, 'FontSize', tick_size);
    set(ax2, 'YTick', observers, 'FontSize', tick_size );
    
    xlabel(ax1,'Log likelihood', 'FontSize',label_size);
    xlabel(ax2,'Log ratio difference', 'FontSize',label_size);
    ylabel(ax1,'Observer', 'FontSize',label_size);
    ylabel(ax2,'Observer', 'FontSize',label_size);
    
    exportgraphics(t, 'outliers_analysis.pdf', 'Append', false);

end 

end 


