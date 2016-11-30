%% excel file method

outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/112216';

[e.excel_images, e.excel_fields] = courtney__process__excel_method( outerfolder );

%% output patch files (fixed)

outerfolder = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data';

[ e.patch_images, e.patch_fields] = courtney__process__patch_method( outerfolder );

%% process

e.patch_image_data = courtney__fix_event_data( e.patch_images, e.patch_fields );
e.excel_image_data = courtney__fix_event_data( e.excel_images, e.excel_fields );

%% cleanup & combine

e.patch_image_data = courtney__add_day_labels( e.patch_image_data );
e.excel_image_data = courtney__add_day_labels( e.excel_image_data );

e.patch_image_data = e.patch_image_data.addfield( 'fileType' );
e.excel_image_data = e.excel_image_data.addfield( 'fileType' );

e.patch_image_data = e.patch_image_data.setfield( 'fileType', 'patch' );
e.excel_image_data = e.excel_image_data.setfield( 'fileType', 'excel' );

processed = e.patch_image_data.perfield( e.excel_image_data, @append );

raw.patch_images = e.patch_images;
raw.patch_fields = e.patch_fields;
raw.excel_images = e.excel_images;
raw.excel_fields = e.excel_fields;

%%

save('processed.mat', 'processed' );
save('raw.mat', 'raw' );












%% old

% % outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/092316/outputpatchfiles';
% 
% outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/fixed_patch_files';
% outerfolders.excel = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/excel_files';
% 
% [ e.patch_images, e.patch_fields] = courtney__process__patch_method( outerfolders );

