function scale_data_to_JOD()

% A simple scaling function for the data collected from the pairwise
% comparison. 
%
% The functions takes into assumption that all conditions of the same scene have
% been compared to each other. There is no
% display-luminance-cross-comparison, and all combinations of viewing
% distances have been compared. 
%
% The reference conditions are assigned a value of 10, and all test
% conditions are scaled accordingly to ensure the same scale of quality
% scores across the contents, viewing distances and display luminance
% levels. 
%
% The function uses the pw_scale_table provided in 
% https://github.com/mantiuk/pwcmp.
%
% 
% More information on the scaling method and calculation of the confidence
% interval can  be found in the description of the pw_scale_table function 
% and in https://arxiv.org/abs/1712.03686. 
%
%
% Author: Dounia Hammou


% Add the pwcmp functions 
addpath('../pwcmp') ;

% Define the path to the ouput csv file, as well as the folder for jod
% distribution scores files.
output_file = '../data/scaled_jod_scores.csv' ;
jod_distribution_files_path = '../data/jod_distribution';

% Define the stuttgart scenes. These scenes do not have the 4K resolution.
stuttgart_scenes = {'FishingCloseshot', 'Showgirl01', 'Bistro', 'SmithHammering'} ;

% Define the luminance levels
display_luminance_levels = {'bright', 'dim'} ;

% Iterate over the two experiment data files (for each display luminance level)

for ii = 1:length(display_luminance_levels)

    display_luminance_level = display_luminance_levels{ii} ;

    % Read the file

    input_file = fullfile('../data', strcat(display_luminance_level, '_display_experiment_data.csv')) ;
    D = readtable(input_file, 'Delimiter', ',');

    % Find the reference conditions for each content, and assign them the
    % same node.
    % This method allows us to ensure the same quality scale across the
    % contents, viewing distances and display luminance levels.

    for jj=1:height(D)
        conditions = {D.condition_1{jj}, D.condition_2{jj}} ;
        scene = D.scene{jj} ;

        for zz = 1:length(conditions)
            condition = split(conditions{zz}, '_') ;
            % The reference condition will be either H_3840x2160 or
            % H_1920x1080 for stuttgart scenes

            if (strcmp(condition(1), 'H') && strcmp(condition(2), '3840x2160')) || (strcmp(condition(1), 'H') && strcmp(condition(2), '1920x1080') && any(strcmp(scene, stuttgart_scenes)))
                conditions{zz} = 'ref' ;
            end
        end

        D.condition_1{jj} = conditions{1} ;
        D.condition_2{jj} = conditions{2} ;

    end

    % Scale the data using the pw_scale_table function in pwcmp. We
    % calculate the confidence interval using bootstrapping with 500
    % samples

    [R, Rs] = pw_scale_table(D, 'scene', { 'condition_1', 'condition_2' }, ...
        'observer', 'selection', 'bootstrap_samples', 500, 'do_all', false );

    % Here we will iterate over each content, find the reference node, assign
    % the quality 10 to it, and scale the test conditions (for the content)
    % accordingly

    scenes = unique(R.scene, 'stable') ;

    viewing_distances = {'near', 'far'} ;

    for jj=1:length(scenes)
        scene_R = R(strcmp(R.scene, scenes{jj}),:) ;
        ref_jod = scene_R(strcmp(scene_R.condition, 'ref'), :) ;
        ref_jod = 10 - ref_jod.jod ;

        scene_R.jod = scene_R.jod+ref_jod ;
        scene_R.jod_low = scene_R.jod_low+ref_jod ;
        scene_R.jod_high = scene_R.jod_high+ref_jod ;

        % We do the same for the bootstrapped JOD distribution

        distribution = Rs{jj}.stats.bstrp + ref_jod ;
        distribution = distribution(:, 1:width(distribution)-1) ;

        temp_line = scene_R(height(scene_R), :) ;

        scene_R = scene_R(1:height(scene_R)-1, :) ;

        % Here we create the CSV file of the JOD distributions for each
        % content (scene), where each column is representing a different
        % test condition of the content, and the 500 rows, are the 500
        % bootstrapped JOD scores.

        distribution_table = array2table(distribution) ;
        distribution_table.Properties.VariableNames = scene_R.condition ;

        distribution_filename = fullfile(jod_distribution_files_path, strcat(Rs{jj}.scene, '_', display_luminance_level, '.csv') );

        writetable(distribution_table, distribution_filename) ;

        % Replace the reference node by the corresponding test conditions

        condition = 'H' ;
        if any(strcmp(scenes{jj}, stuttgart_scenes))
            resolution = '1920x1080' ;
        else
            resolution = '3840x2160' ;
        end
        condition = strcat(condition, '_', resolution) ;

        for i = 1:length(viewing_distances)
            temp_line.condition = strcat(condition, '_', display_luminance_level, '_', viewing_distances{i}) ;
            scene_R = [scene_R ;  temp_line] ;
        end

        if ~exist('scaled_R', 'var')
            scaled_R = scene_R ;
        else
            scaled_R = [scaled_R; scene_R] ;
        end

    end

end

writetable(scaled_R, output_file);


end
