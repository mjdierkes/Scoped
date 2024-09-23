#!/usr/bin/env ruby

require 'xcodeproj'

# Find the .xcodeproj file in the current directory
project_path = Dir.glob('./*.xcodeproj').first

unless project_path
  puts "Error: No .xcodeproj file found in the current directory."
  exit 1
end

puts "Found project: #{project_path}"

# Open the Xcode project
project = Xcodeproj::Project.open(project_path)

# Find the main group (usually named after your project)
main_group = project.root_object.main_group
puts "Main group: #{main_group.display_name}"

# Get the main target (assuming you want the first target)
main_target = project.targets.first
puts "Main target: #{main_target.name}"

# Read the content of the pbxproj file
pbxproj_path = File.join(project_path, 'project.pbxproj')
pbxproj_content = File.read(pbxproj_path)

# Get all Swift, Objective-C header, and implementation files in the project directory and its subdirectories
source_files = Dir.glob(File.join(File.dirname(project_path), '**', '*.{swift,h,m}'))
puts "Found #{source_files.length} source files"

# Function to check if a file is in pbxproj
def file_in_pbxproj?(file_name, pbxproj_content)
  pbxproj_content.include?(file_name)
end

# Function to find or create nested groups
def find_or_create_group(parent_group, group_path)
  group_path.split('/').inject(parent_group) do |current_group, group_name|
    current_group.children.find { |child| child.is_a?(Xcodeproj::Project::Object::PBXGroup) && child.display_name == group_name } ||
      current_group.new_group(group_name)
  end
end

# Add new files to the project
source_files.each do |file_path|
  file_name = File.basename(file_path)
  relative_path = Pathname.new(file_path).relative_path_from(Pathname.new(project_path).parent).to_s
  
  unless file_in_pbxproj?(file_name, pbxproj_content)
    puts "Adding file: #{relative_path}"
    
    # Find or create nested groups based on the file path
    group_path = File.dirname(relative_path)
    target_group = find_or_create_group(main_group, group_path)
    
    file_ref = target_group.new_reference(relative_path)
    
    # Ensure the path is relative to the group
    file_ref.set_path(File.basename(relative_path))
    file_ref.source_tree = '<group>'
    
    # Add file reference to the target
    main_target.add_file_references([file_ref])
    
    # Ensure the file is included in the appropriate build phases
    case File.extname(file_name)
    when '.swift', '.m'
      main_target.source_build_phase.add_file_reference(file_ref) unless main_target.source_build_phase.file_display_names.include?(file_name)
    when '.h'
      main_target.headers_build_phase.add_file_reference(file_ref) unless main_target.headers_build_phase.file_display_names.include?(file_name)
    end
  else
    puts "File already exists in project: #{relative_path}"
  end
end

# Save the project
project.save

puts "Project updated and saved."
