function tbl = courtney__model__summary2( mdl )

travel_times = cellfun( @(x) x.travel_time, mdl );
inputs = zeros( numel(travel_times), 7 );

log_like = cellfun( @(x) x.mdl.LogLikelihood, mdl );
aic = courtney__model__get_aic_basic( mdl );

end