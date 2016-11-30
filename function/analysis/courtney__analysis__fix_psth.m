function outs = courtney__analysis__fix_psth( separated )

fix_psth_data = separated.fix_psth.data;

binned = get_binned_fix_counts( fix_psth_data, 100 );

[ binned_prop, n_trials_neg ] = fix_proportions( fix_psth_data, 100 );

newBinned = sum_over_bins( binned );

figure; plot( newBinned );

outs.newBinned = newBinned;
outs.binned = binned;
outs.binned_prop = binned_prop;

end