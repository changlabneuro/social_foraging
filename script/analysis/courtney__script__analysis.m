%% load in
load( 'processed.mat' );
load( 'raw.mat' );
%% specify trial parameters

separated = processed.only( {'negative', '0.5'} );

%% split into sections

separated = separated.foreach( @courtney__split_percent_per_day, [.25 .5] );

%% fix psth

fix_psth_data = separated.fix_psth.data;

binned = get_binned_fix_counts( fix_psth_data, 100 );

[ binned_prop, n_trials_neg ] = fix_proportions( fix_psth_data, 100 );

newBinned = sum_over_bins( binned );

figure; plot( newBinned );

%% order of target selection

% orders = courtney__analysis__target_order( raw.patch_images.images );
orders = courtney__analysis__target_order( objects );

targPercent( orders );

%% see haydens -- delay discounting / simple exponential
