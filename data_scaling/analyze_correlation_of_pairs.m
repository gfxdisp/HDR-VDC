if( ~exist( 'pw_scale', 'file' ) )
    addpath( fullfile( pwd, '..', '..', 'pwcmp/' ) );
end

M = readtable( '../../metric_calibration/metric_results/HDR-VDC_cvvdp.csv' );

N = height(M);
M.luminance = cell(N,1);
M.scene = cell(N,1);
M.resolution = cell(N,1);
M.compression = cell(N,1);
M.group = cell(N,1);
for kk=1:N
    C = strsplit( M.condition_id{kk}, '_' );
    M.scene{kk} = C{1};
    M.compression{kk} = C{2};
    M.resolution{kk} = C{3};
    M.luminance{kk} = C{4};
    M.group{kk} = strcat( M.scene{kk}, '_', M.luminance{kk} );
end

% Add reference conditions
GRPs = unique( M.group );
old_height = height(M);
new_height = height(M)+length(GRPs);
M(new_height+1,:) = M(1,:);
M(end,:) = [];
M.group((old_height+1):new_height) = GRPs;
M.condition_id((old_height+1):new_height) = { 'ref' };
M.Q((old_height+1):new_height) = 10;

Rs_dim = load( "hdr-vdc_scaled_dim.mat" );
for kk=1:length(Rs_dim.Rs)
    % if strcmp(Rs_dim.Rs{kk}.group,'ref')
    %     continue
    % end
    Rs_dim.Rs{kk}.group = strcat( Rs_dim.Rs{kk}.group, '_dim' );
end

Rs_bright = load( "hdr-vdc_scaled_bright.mat" );
for kk=1:length(Rs_bright.Rs)
    % if strcmp(Rs_bright.Rs{kk}.group,'ref')
    %     continue
    % end
    Rs_bright.Rs{kk}.group = strcat( Rs_bright.Rs{kk}.group, '_bright' );
end

Rs = cat( 1, Rs_bright.Rs, Rs_dim.Rs );

figure(1);
pw_metric_pairwise_correlation( Rs, M, '', scatter_plot=true, group_column='group', condition_column='condition_id' );

