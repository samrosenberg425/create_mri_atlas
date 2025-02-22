# Create_Atlas.m

## Overview

**Create_Atlas.m** is a MATLAB script designed to generate a brain atlas from a directory containing individual **.nii** files representing different brain regions. The script compiles these regions into a single **.nii** file and creates a corresponding **.txt** file listing the region labels extracted from filenames.

## Features

- **Graphical User Interface (GUI) Selection:** Users can select the directory containing the **.nii** files.
- **Custom Naming:** Users can specify a name for the generated atlas.
- **Automated Region Checking:** Ensures that all input files have matching resolutions.
- **Overlap Resolution:** If regions overlap, the script prompts the user to select which region to prioritize.
- **Output Files:**
  - **Atlas file (.nii):** The compiled atlas containing all regions.
  - **Label file (.txt):** A text file listing region names and corresponding intensity values.
  - **Overlap log (.txt):** A record of user-selected region overlaps.

## Installation and Dependencies

- MATLAB (Tested on versions with **niftiread** and **niftiwrite** functions)
- **NIfTI Toolbox** (for viewing NIfTI images if needed)
- The script requires a **nifti_header.mat** file in the same directory to ensure proper formatting of the output atlas.

## Usage

1. **Run the script** in MATLAB:
   ```matlab
   Create_Atlas
   ```
2. **Select the directory** containing the **.nii** files when prompted.
3. **Enter a name** for your atlas when prompted.
4. **Resolve any overlapping regions** via the GUI selection process.
5. **Check the output files** in the working directory:
   - `your_atlas_name.nii`
   - `your_atlas_name.txt`
   - `your_atlas_name_overlap_selections.txt`

### Alternative: Non-GUI Mode

To bypass the GUI and manually specify paths:

1. Comment out the GUI selection lines:
   ```matlab
   % data_input=uipickfiles(...);
   % atlasdir=data_input{1};
   % name=inputdlg(...);
   % atlas_name=name{1};
   ```
2. Uncomment and modify the manual selection lines:
   ```matlab
   atlasdir = "path/to/your/directory";
   atlas_name = "your_atlas_name";
   ```

## Error Handling

- If input files have different resolutions, the script will terminate with an error message listing the mismatched file.
- If the **nifti_header.mat** file is missing, the script will not execute properly.

## License

MIT License

## Author

Sam Rosenberg

## Last Updated

January 6, 2025
