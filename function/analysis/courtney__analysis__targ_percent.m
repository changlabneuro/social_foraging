function out = courtney__analysis__targ_percent( order )

nans = isnan( order(:, 1) );
order(nans, :) = [];

pos_perc = nan( size(order) );
neg_perc = nan( size(order) );

total_p = 4;
total_n = 4;

for i = 1:size(order, 1)
  trial = order(i, :);
  trial = trial( ~isnan(trial) );
  
  n_p = 1;
  n_n = 1;
  
  for j = 1:numel(trial)
    if ( trial(j) )
      pos_perc(i, j) = n_p / total_p;
      if ( j > 1 )
        neg_perc(i, j) = neg_perc(i, j-1);
      else neg_perc(i, j) = 0;
      end
      n_p = n_p + 1;
    else
      neg_perc(i, j) = n_n / total_n;
      if ( j > 1 )
        pos_perc(i, j) = pos_perc(i, j-1);
      else pos_perc(i, j) = 0;
      end
      n_n = n_n + 1;
    end
  end
end

pos_mean = nanmean( pos_perc, 1 );
neg_mean = nanmean( neg_perc, 1 );

pos_dev = zeros( size(pos_mean) );
neg_dev = zeros( size(pos_mean) );

for i = 1:size(pos_dev, 2)
  pos_dev(i) = nanSEM( pos_perc(:, i) );
  neg_dev(i) = nanSEM( neg_perc(:, i) );
end

means = Container( [pos_mean; neg_mean], 'valence', {'pos'; 'neg'} );
devs = Container( [pos_dev; neg_dev], 'valence', {'pos'; 'neg'} );

means = means.add_field( 'measure', 'mean' );
devs = devs.add_field( 'measure', 'sem' );

out = means.append( devs );
out = out.sparse();

end