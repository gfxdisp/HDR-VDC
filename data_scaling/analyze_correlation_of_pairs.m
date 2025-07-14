% Run scale_data_to_JOD before running this script

if( ~exist( 'pw_scale', 'file' ) )
    addpath( fullfile( pwd, '..', '..', 'pwcmp/' ) );
end

METRICs = { 'cvvdp', 'VMAF', 'FUNQUE', 'DISTS' };
QREFs = [10 100 0 0]; % Reference image quality

figure(1);
clf;
tiledlayout( 2, length(METRICs) )

for dd=1:2

for mm=1:length(METRICs)
    nexttile;

    M = readtable( ['../../metric_calibration/metric_results/HDR-VDC_', METRICs{mm}, '.csv'] );
    Q_ref = QREFs(mm); % Reference image quality

    % M = readtable( '../../metric_calibration/metric_results/HDR-VDC_VMAF.csv' );
    % Q_ref = 100; % Reference image quality

    % M = readtable( '../../metric_calibration/metric_results/HDR-VDC_FUNQUE.csv' );
    % Q_ref = 0; % Reference image quality


    N = height(M);

    % We cannot have underscores in the scene names to parse conditions
    % correctly
    for kk=1:N
        if startsWith( M.condition_id{kk}, 'PUBG' )
            M.condition_id{kk}(5) = '-';
        end
        if startsWith( M.condition_id{kk}, 'SolLevante' )
            M.condition_id{kk}(11) = '-';
        end
    end


    % Get all condition attributes from condition_id
    M.luminance = cell(N,1);
    M.scene = cell(N,1);
    M.resolution = cell(N,1);
    M.compression = cell(N,1);
    M.distance = cell(N,1);
    M.group = cell(N,1);
    M.condition = cell(N,1);
    for kk=1:N
        C = strsplit( M.condition_id{kk}, '_' );
        M.scene{kk} = strrep( C{1}, '-', '_' );
        M.compression{kk} = C{2};
        M.resolution{kk} = C{3};
        M.luminance{kk} = C{4};
        M.distance{kk} = C{5};
        M.group{kk} = strcat( M.scene{kk}, '_', M.luminance{kk} );
        M.condition{kk} = strcat( M.compression{kk}, '_', M.resolution{kk}, '_', M.luminance{kk}, '_', M.distance{kk} );
    end

    % Add reference conditions
    GRPs = unique( M.group );
    old_height = height(M);
    new_height = height(M)+length(GRPs);
    M(new_height+1,:) = M(1,:);
    M(end,:) = [];
    M.group((old_height+1):new_height) = GRPs;
    M.condition((old_height+1):new_height) = { 'ref' };
    M.Q((old_height+1):new_height) = Q_ref;
    for kk=1:length(GRPs)
        ind = strfind( GRPs{kk}, '_' );
        M.scene{old_height+kk} = GRPs{kk}(1:(ind(end)-1));
        M.luminance{old_height+kk} = GRPs{kk}((ind(end)+1):end);
    end

    Rs_dim = load( "hdr-vdc_scaled_dim.mat" );
    for kk=1:length(Rs_dim.Rs)
        Rs_dim.Rs{kk}.group = strcat( Rs_dim.Rs{kk}.group, '_dim' );
    end

    Rs_bright = load( "hdr-vdc_scaled_bright.mat" );
    for kk=1:length(Rs_bright.Rs)
        Rs_bright.Rs{kk}.group = strcat( Rs_bright.Rs{kk}.group, '_bright' );
    end

    Rs = cat( 1, Rs_bright.Rs, Rs_dim.Rs );

    switch( dd )
        case 1
            M.set = strcat( M.scene, '_', M.compression, '_', M.resolution, '_', M.distance );
            ylab = 'Across luminance';
        case 2
            M.set = strcat( M.scene, '_', M.compression, '_', M.resolution, '_', M.luminance );
            ylab = 'Across view distance';
    end


    pw_metric_pairwise_correlation( Rs, M, 'set', scatter_plot=true, group_column='group', condition_column='condition' );

    if dd==1
        title( { METRICs{mm}, get( gca, 'Title' ).String } );
    end
    if mm==1
        ylabel( { ylab, get( gca, 'YLabel' ).String } );
    end


end

end