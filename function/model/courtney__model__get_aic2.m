function aic = courtney__model__get_aic2( mdl )

mdl_aic = zeros( 1, numel(mdl) );
tt = zeros( size(mdl_aic) );

for i = 1:numel( mdl )
  mdl_aic(i) = mdl{i}.mdl.ModelCriterion.AIC;
  tt(i) = mdl{i}.travel_time;
end

m1_name = mdl{1}.name;
aic.(m1_name) = mdl_aic;
aic.travel_time = tt;

end