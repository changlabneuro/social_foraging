function tbl = courtney__model__coefficient_summary( mvt )


coeffs = cellfun( @(x) x.mdl.Coefficients{:,'Estimate'}, mvt, 'UniformOutput', false );
ps = cellfun( @(x) x.mdl.Coefficients{:,'pValue'}, mvt, 'UniformOutput', false );
coeff_names = mvt{1}.coefficient_names;

for i = 1:numel(coeff_names)
  tbl_inputs.(['beta__' coeff_names{i}]) = cellfun( @(x) x(i), coeffs );
  tbl_inputs.(['p__' coeff_names{i}]) = cellfun( @(x) x(i), coeffs );
end

fs = fieldnames( tbl_inputs );
array = zeros( numel(mvt), numel(fs) );

for i = 1:numel(fs)
  array(:,i) = tbl_inputs.(fs{i});
end

array(:, end+1) = cellfun( @(x) x.travel_time, mvt );
tbl = array2table( array );
tbl.Properties.VariableNames = [fs; 'travel_time'];



end