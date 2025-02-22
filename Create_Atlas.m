%% Create_Atlas.m
% By Sam Rosenberg
% Last Updated: 1/6/2025
%
% Input: Directory with .nii files of brain regions to include in atlas
% Output: .nii file of the atlas, .txt file with atlas labels that are
% taken directly from the filenames themselves
%
%    *Note* Must have the .nii and .txt in the same directory to view the
%    atlas with labels
%
%% Input data - GUI interface
% Select Directory GUI interface
data_input=uipickfiles('FilterSpec', '*', 'Prompt', 'Select a directory with your ROI files(make sure it is a directory');
atlasdir=data_input{1};
name=inputdlg('Please enter a name for your atlas:');
atlas_name=name{1};

% If you would like to skip the GUI for selecting the folder/name, then
%   1 - Comment the above lines
%   2 - Uncomment the two lines below this text chunk(beginning with atlasdir 
%   and atlas_name)
%   3 - Change the string for atlasdir and atlas_name to the folder and name
%       that you would like to use

%atlasdir="replace me";
%atlas_name='replace me';

%% Load in presaved header 
% MUST be in the SAME folder as the script or have the correct path to this
% file
%   - This is what makes sure the output is an atlas file and not an
%     unnamed .nii file
load('nifti_header.mat')
%% Get filenames
% Get names of all files in directory
filt_files = dir(fullfile(atlasdir, '*.nii'));
% Isolate filenames with path to the atlas directory
fnames={};
for i=1:length(filt_files)
    fname=fullfile(atlasdir, filt_files(i).name);
    fnames{i}=fname;
end
numfiles=length(fnames);
%% Check that files are the same resolution
% Make an array of the files' dimensions
sizes=zeros(length(fnames), 3);
rois={};
% Get array of dimensions of regions
for i =1:numfiles
    rois{i}=niftiread(fnames{i});
    sizes(i,:)=size(rois{i});
end
% Check that all are the same size
sizecheck = all(all(bsxfun(@eq, sizes, sizes(1,:))));
% If files are different resolution, throw error
if sizecheck==0;
    rowDifferences = all(sizes == sizes(1,:), 2); 
    differentRow = find(~rowDifferences);
    [~,name,ext]=fileparts(fnames{differentRow});
    diffname=strcat(name, ext);
    errormess=sprintf("Input files have different resolutions... \n\n%s Dimensions: \n[%s, %s, %s] \n\nOther Files Dimensions: \n[%s, %s, %s] \n\n", ...
        diffname, string(sizes(differentRow, :)), string(sizes(1, :)));
    error(errormess)
end

%% Compile atlas
q=1;
% Preallocate a 3D matrix of zeros
nifti_out=uint8(zeros((sizes(1,:))));
% Preallocate list for region names
text_out={};
overlap_regions={};
for i=1:numfiles
    % Take binary region and multiply it by the number assigned to it
    region=rois{1,i};
    region=region.*i;
    
    % Ask user to chose if there are overlapping portions of regions
    if nonzeros(nifti_out(region>0)>0)
        regnum=max(nifti_out(region>0));
        overlap=nifti_out & region;
        stats = regionprops(overlap, 'Centroid');
        centroid = stats.Centroid;
        % Adjust the view to center on the centroid
        % Assuming centroid is in voxel coordinates [x, y, z]
        % You might need to convert this to appropriate slice number if needed
        slice_x = round(centroid(1));
        slice_y = round(centroid(2));
        slice_z = round(centroid(3));
        option=struct();
        option.setunit='voxel';
        option.setviewpoint=[slice_y slice_x slice_z];
        option.setcolorindex=4;
        option.usepanel=0;
        temp=nifti_out;
        temp(temp~=regnum)=0;
        overlap=make_nii(temp+region);
        option.glblocminmax=[1 max(temp(:)+region(:))];
        % Display the specific slice
        h = view_nii(overlap, option);
        question = 'The following regions overlap, please chose one:';
        title = 'Overlap Selection';
        option1 = string(filt_files(i).name);
        option2 = string(filt_files(regnum).name);
        defaultOption = option2;
        % Display the dialog box
        choice = questdlg(question, title, option1, option2, 'Cancel', defaultOption);
        close(h.fig)
        pause(0.500)
        % If keeping original region for overlap, then remove that portion
        % from the new region
        if choice==option2
            region(nifti_out>0 & region>0)=0;
            overlap_regions{q}=strcat(string(q), ', Selected: ', string(filt_files(i).name), ' over ', string(filt_files(regnum).name));
            q=q+1;
        elseif choice==option1
            % Otherwise set that region in the output to zero so you can
            % add the new region easily
            nifti_out(nifti_out>0 & region>0)=0;
            overlap_regions{q}=strcat(string(q), 'Selected: ', string(filt_files(regnum).name), ' over ', string(filt_files(i).name));
            q=q+1;
        else
            disp('User cancelled script')
            return
        end
        
        nifti_out=nifti_out+region;
    else
        % Add the new region to the preallocated matrix of zeros
        nifti_out=nifti_out+region; 
    end

    % Create text for atlas file where it is two columns: Intensity, Region
    filePath=char(fnames{i});
    lastSlashIndex = find(filePath == '/', 1, 'last'); % Find the last occurrence of '/'
    fileNameWithExtension = filePath((lastSlashIndex + 1):end); % Extract everything after the last '/'
    fileName = strrep(fileNameWithExtension, '.nii', '');
    text_out{i,1}=i;
    text_out{i,2}=fileName;
end
% Add in a label for 0
first={0, 'Not Brain or Not Labeled'};
text_out=[first; text_out];
% Make atlas file name and write the nifti file
name_out=sprintf('%s.nii', atlas_name);
niftiwrite(nifti_out,name_out, info);

%% Write the text file of Number, Region, Intensity
txtFileName=sprintf('%s.txt', atlas_name);
fileID = fopen(txtFileName, 'w');
for i = 1:size(text_out, 1)
    fprintf(fileID, '%d %s, %d\n', text_out{i, 1}, text_out{i, 2}, text_out{i,1});
end
fclose(fileID);
%%
overlaptxtFileName=sprintf('%s_overlap_selections.txt', atlas_name);
fileID = fopen(overlaptxtFileName, 'w');
for i = 1:size(overlap_regions, 2)
    fprintf(fileID, '%s \n', overlap_regions{i});
end
fclose(fileID);
