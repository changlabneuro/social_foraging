function tbls = courtney__model__summary( discount, mvt )

tbl_inputs.log_likes.discount = cellfun( @(x) x.mdl.LogLikelihood, discount );
tbl_inputs.log_likes.mvt = cellfun( @(x) x.mdl.LogLikelihood, mvt );
tbl_inputs.aics = courtney__model__get_aic( discount, mvt );
tbl_inputs.weights = courtney__model__get_ak_weights( tbl_inputs.aics );
tbl_inputs.d_aics = tbl_inputs.weights.d_aics;
tbl_inputs.weights = tbl_inputs.weights.weights;
tbl_inputs.k.discount = cellfun( @(x) x.k, discount );
tbl_inputs.k.mvt = nan( size(tbl_inputs.k.discount) );
tbl_inputs.RMSE.mvt = cellfun( @(x) x.RMSE, mvt );
tbl_inputs.RMSE.discount = cellfun( @(x) x.RMSE, discount );
% tbl_inputs = add_mvt_coeff( mvt, tbl_inputs );

fs = fieldnames( tbl_inputs.log_likes );
tbls = createstruct( fs, [] );
tbl_fs = fieldnames( tbl_inputs );

for i = 1:numel(fs)
  for j = 1:numel(tbl_fs)
    current = tbl_inputs.(tbl_fs{j}).(fs{i});
    tbls.(fs{i}) = [ tbls.(fs{i}) current(:) ];
  end
  tbls.(fs{i}) = [tbls.(fs{i}) tbl_inputs.aics.travel_time(:)];
  tbls.(fs{i}) = array2table( tbls.(fs{i}) );
  tbls.(fs{i}).Properties.VariableNames = [ tbl_fs; { 'travel_time' } ];
end



end