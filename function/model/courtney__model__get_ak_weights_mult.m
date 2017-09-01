function [weights, delta_aics] = courtney__model__get_ak_weights_mult( varargin )

comb = [];
for i = 1:numel(varargin)
  comb = [comb; varargin{i}];
end

mins = min( comb );

delta_aics = zeros( size(comb) );
for i = 1:size(comb, 1)
  delta_aics(i, :) = comb(i, :) - mins;
end

all_liks = exp( -.5 .* delta_aics );
weights = zeros( size(all_liks) );
for i = 1:size(all_liks,1)
  weights(i,:) = all_liks(i,:) ./ sum(all_liks);
end

end