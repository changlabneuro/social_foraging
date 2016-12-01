%% excel file method

outerfolder = fullfile( pathfor( 'excel_raw_data' ), '112216' );

[e.excel_images, e.excel_fields] = courtney__process__excel_method( outerfolder );

e.excel_images = e.excel_images.lower();

%% output patch files (fixed)

outerfolder = fullfile( pathfor( 'patch_raw_data' ), '113016' );

[ e.patch_images, e.patch_fields] = courtney__process__patch_method( outerfolder );

%% process patch

e.patch_image_data = courtney__fix_event_data( e.patch_images, e.patch_fields );

%% excel RUN THIS SECTION WHILE YOU do other things

e.excel_image_data = courtney__fix_event_data( e.excel_images, e.excel_fields );
processed = e.excel_image_data;
raw.excel_images = e.excel_images;
raw.excel_fields = e.excel_fields;

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

%% SAVE


cd( '/Users/court/Documents/MATLAB/EDF2Mat/pre_processed/113016' );
save('processed.mat', 'processed' );
save('raw.mat', 'raw' );
% save( 'processed.mat', 'processed', '-v7.3' );
% save( 'raw.mat', 'raw', '-v7.3' );












%% old

% % outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/data/092316/outputpatchfiles';
% 
% outerfolders.patch = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/fixed_patch_files';
% outerfolders.excel = '/Volumes/My Passport/NICK/Chang Lab 2016/courtney/behavioral/archive/social_control_data/excel_files';
% 
% [ e.patch_images, e.patch_fields] = courtney__process__patch_method( outerfolders );

