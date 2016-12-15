function outs = courtney__analysis__fix_psth( separated, thresh )

if ( nargin < 2 ); thresh = 100; end;

fix_psth_data = separated.fix_psth.data;

binned = get_binned_fix_counts( fix_psth_data, thresh );

summed = sum_over_bins( binned );

outs.summed = summed;
outs.binned = binned;

% [ binned_prop, n_trials_neg ] = fix_proportions( fix_psth_data, 100 );
% outs.binned_prop = binned_prop;
% figure; plot( newBinned );

end