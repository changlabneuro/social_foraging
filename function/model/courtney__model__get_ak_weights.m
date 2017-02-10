function outs = courtney__model__get_ak_weights( aics )

mvts = aics.mvt;
discounts = aics.discount;

comb = [mvts; discounts];
mins = min( comb );

delta_aics = [mvts-mins; discounts-mins];

% d_aics.mvt = mvts - mins;
% d_aics.discount = discounts - mins;

all_liks = exp( -.5 .* delta_aics );
normed = zeros( size(all_liks) );
for i = 1:size(all_liks,1)
  normed(i,:) = all_liks(i,:) ./ sum(all_liks);
end

outs.weights.mvt = normed(1,:);
outs.weights.discount = normed(2,:);
outs.weights.relative = normed(1,:) ./ normed(2,:);
outs.d_aics.mvt = delta_aics(1,:);
outs.d_aics.discount = delta_aics(2,:);

end