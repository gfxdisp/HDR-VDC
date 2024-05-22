function statistical_analysis()

path = '../data/jod_distributions.csv' ;

T = readtable(path);

% Define the variables in which we want to measure their statistical
% significance

contents = unique(T.content) ;

viewing_distances = unique(T.viewing_distance) ;

luminance_levels = unique(T.luminance_level) ;

distortions = {'H_1920x1080', 'H_1280x720', 'M_3840x2160', 'M_1920x1080',...
    'M_1280x720', 'L_3840x2160', 'L_1920x1080', 'L_1280x720'} ;

% We do not consider the reference conditions ('H_3840x2160')


% Create empty vectors where we will be storing the p-values and effect
% sizes over all iterations

p_values_overall = [];
p_values_distortion = [];

eta_overall = [];
eta_distortion = [];

% We iterate 100 times
iterations = 100;

for ii=1:iterations

    % Define the factors which will be used for the overall ANOVA analysis
    factors = cell (1, 6); % content, crf, resolution, viewing distance, display peak luminance, JOD
    index = 1;

    for jj=1:length(distortions)

        % Get distortion
        distortion = distortions{jj} ;

        % Get compression level and resolution
        distortion_split = split(distortion, '_') ;
        crf = distortion_split{1} ;
        resolution = distortion_split{2} ;

        % Define the factors which will be used for the distortions' ANOVA
        % analysis

        distortion_factors = cell(1, 4) ; % content, viewing distance, luminance level, JOD
        distortion_index = 1 ;

        for kk=1:length(contents)

            content = contents{kk};

            for ll=1:length(viewing_distances)

                viewing_distance = viewing_distances{ll};

                for mm=1:length(luminance_levels)

                    luminance_level = luminance_levels{mm};


                    % Find the JOD distribution of this specific test condition

                    condition_table = T(strcmp(T.content, content),:) ;
                    condition_table = condition_table(strcmp(condition_table.viewing_distance, viewing_distance),:) ;
                    condition_table = condition_table(strcmp(condition_table.luminance_level, luminance_level),:) ;

                    jod_score = condition_table.(distortion) ;

                    % Only select 30 random values from the 500 boostraped
                    % distribution

                    % What if we does remove this or replace it by 1!

                    idx = randperm(500);
                    jod_score = jod_score(idx(1:30)) ;
                    jod_score = reshape(jod_score, [1, 30]) ;

                    if ~isnan(jod_score)

                        for bb=1:length(jod_score)

                            factors{index, 1} = content ;
                            factors{index, 2} = crf ;
                            factors{index, 3} = resolution ;
                            factors{index, 4} = viewing_distance ;
                            factors{index, 5} = luminance_level ;
                            factors{index, 6} = jod_score(bb) ;

                            index = index+1 ;

                            distortion_factors{distortion_index, 1} = content ;
                            distortion_factors{distortion_index, 2} = viewing_distance ;
                            distortion_factors{distortion_index, 3} = luminance_level ;
                            distortion_factors{distortion_index, 4} = jod_score(bb) ;

                            distortion_index = distortion_index+1 ;

                        end
                    end
                end
            end
        end

        % Conduct ANOVA for each distortion

        distortion_factors = cell2table(distortion_factors);

        formula = 'distortion_factors4 ~ distortion_factors1 + distortion_factors2 + distortion_factors3' ;

        mov = anova(distortion_factors, formula) ;

        p_values_distortion =[p_values_distortion mov.stats.pValue(1:3)]; % p-values of each factor

        effect_size = mov.stats.SumOfSquares(1:3) ;
        total_sum = mov.stats.SumOfSquares(5) ;

        eta_distortion = [eta_distortion effect_size/total_sum] ; % effect size of each factor

    end

    % Conduct ANOVA overall distortions

    factors = cell2table(factors);

    formula = 'factors6 ~ factors1 + factors2 + factors3 + factors4 + factors5' ;

    mov = anova(factors, formula) ;

    p_values_overall =[p_values_overall mov.stats.pValue(1:5)]; % p-values of each factor

    effect_size = mov.stats.SumOfSquares(1:5) ;
    total_sum = mov.stats.SumOfSquares(7) ;

    eta_overall = [eta_overall effect_size/total_sum] ; % effect size of each factor


end

% Reshape the distortion data correctly

p_values_distortion = reshape(p_values_distortion, [3, 8, iterations]);
eta_distortion = reshape(eta_distortion, [3, 8, iterations]);

% Get the median of the effect sizes for all iterations

eta_overall = median(eta_overall, 2);
eta_distortion = median(eta_distortion, 3);

% Get the maximum of the p-values for all iterations

p_values_overall = max(p_values_overall, [], 2);
p_values_distortion = max(p_values_distortion, [], 3);

% Concatenate things together (we are only interested in the effect of viewing distance and luminance level)

p_values = [p_values_overall(4:end) p_values_distortion(2:end, :)];
eta = [eta_overall(4:end) eta_distortion(2:end, :)];

% Get statistical significance
significance = p_values < 0.05;

% Save the results in a CSV file
results = [significance; eta];
results = num2cell(results) ;

column_names = {'viewing_distance_significance', 'luminance_level_significance', ...
    'viewing_distance_effect_size', 'luminance_level_effect_size'}' ;

results = [column_names results];

variable_names = [{'type'}, {'overall'}, distortions];
T = cell2table(results, "VariableNames",variable_names) ;

writetable(T, '../data/statistical_test_results.csv');

end