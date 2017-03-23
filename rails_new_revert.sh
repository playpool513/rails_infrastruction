read -p "Project name: " project_name
echo

set -x

output_file="$(pwd)/project_"$project_name"_revert.rb"

(
  cd ~/Projects/$project_name
  pwd
  echo

  rake db:drop
  echo

  rm -rf ~/Projects/$project_name
  ls -l ~/Projects/$project_name
  echo
) 2>&1 | tee $output_file
