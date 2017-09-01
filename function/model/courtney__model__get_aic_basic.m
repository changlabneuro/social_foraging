function [mdl_aic, tt] = courtney__model__get_aic_basic( mdl )

mdl_aic = zeros( 1, numel(mdl) );
tt = zeros( size(mdl_aic) );

for i = 1:numel( mdl )
  mdl_aic(i) = mdl{i}.mdl.ModelCriterion.AIC;
  tt(i) = mdl{i}.travel_time;
end

end