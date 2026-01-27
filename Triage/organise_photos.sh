# the folder picsamples in the current directory contains files. I want to copy those files to a sibling folder of picsamples, called DennisPhotos, but with a structure I will now describe.
# For each file in the folder picsamples, look at the month and year the photo was taken. See if a folder exists in DennisPhotos for that month/year, in the format year-month. For example 2024-05. If the folder does not exist, create it.
# Copy the current file to the appropriate year-month folder.
# Continue processing each file in picsamples, until all have been copied to the appropriate folder under DennisPhotos.

parent_directory="/Users/mark/MarkPhotos"
target_directory_name="/Volumes/DennisPhotos"
read -p "Enter the path to the parent directory (default: $parent_directory): " input_parent_directory
parent_directory="${input_parent_directory:-$parent_directory}"
read -p "Enter the name of the target directory (default: $target_directory_name): " input_target_directory_name
target_directory_name="${input_target_directory_name:-$target_directory_name}"
cd "$parent_directory"
mkdir -p "$target_directory_name"
for file in picsamples/*; do
    year_month=$(date -r "$file" "+%Y-%m")
    mkdir -p "$target_directory_name/$year_month"
    cp "$file" "$target_directory_name/$year_month/"
done
