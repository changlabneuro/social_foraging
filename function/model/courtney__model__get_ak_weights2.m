function outs = courtney__model__get_ak_weights2( aic1, aic2, name1, name2 )

comb = [aic1; aic2];
mins = min( comb );

delta_aics = [aic1-mins; aic2-mins];

% d_aics.mvt = mvts - mins;
% d_aics.discount = discounts - mins;

all_liks = exp( -.5 .* delta_aics );
normed = zeros( size(all_liks) );
for i = 1:size(all_liks,1)
  normed(i,:) = all_liks(i,:) ./ sum(all_liks);
end

outs.weights.(name1) = normed(1,:);
outs.weights.(name2) = normed(2,:);
outs.weights.relative = normed(1,:) ./ normed(2,:);
outs.d_aics.(name1) = delta_aics(1,:);
outs.d_aics.(name2) = delta_aics(2,:);

end