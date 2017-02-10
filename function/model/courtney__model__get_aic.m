function aics = courtney__model__get_aic( discount, mvt )

discount_aic = zeros( 1, numel(discount) );
mvt_aic = zeros( size(discount_aic) );
tt = zeros( size(discount_aic) );

for i = 1:numel( discount )
  discount_aic(i) = discount{i}.mdl.ModelCriterion.AIC;
  mvt_aic(i) = mvt{i}.mdl.ModelCriterion.AIC;
  tt(i) = discount{i}.travel_time;
end

aics.mvt = mvt_aic;
aics.discount = discount_aic;
aics.travel_time = tt;

end