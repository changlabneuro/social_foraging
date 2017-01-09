function fixed = courtney__fix_day_labels( obj )

assert( any(strcmp(obj.fieldnames(), 'days')), ...
  '''days'' field does not exist in the object' );

days = obj.uniques( 'days' );
correct_days = cellfun( @(x) x(1:4), days, 'UniformOutput', false );

fixed = obj;

for i = 1:numel( days )
  fixed = fixed.replace( days{i}, correct_days{i} );
end


end