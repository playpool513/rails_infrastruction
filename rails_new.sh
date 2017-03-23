read -p "Project name: " project_name
read -s -p "Mysql password: " mysql_password
echo

set -x

output_file="$(pwd)/project_"$project_name".rb"

(
  command="rails new $project_name -T -d mysql"
  msg="$ $command"
  cd ~/Projects
  pwd
  $command
  cd ~/Projects/$project_name
  pwd
  git init
  git add .
  git commit -m "$msg"
  echo

  msg="Add README.md"
  (ruby -v; rails -v) 2>&1 | tee ~/Projects/$project_name/README.md
  git status
  git add .
  git commit -m "$msg"
  echo

  msg="Fix error message: Expected string default value for '--rc'; got false (boolean)"
  append_text="gem 'thor', '0.19.1'"
  echo $append_text >> Gemfile
  bundle update thor
  git status
  git add .
  git commit -m "$msg"
  echo

  msg="Fix README.md"
  (ruby -v; rails -v) 2>&1 | tee ~/Projects/$project_name/README.md
  git status
  git add .
  git commit -m "$msg"
  echo

  database_file="config/database.yml"
  secrets_file="config/secrets.yml"
  database_eg_file="config/database.yml.example"
  secrets_eg_file="config/secrets.yml.example"

  msg="Add $database_eg_file & $secrets_eg_file"
  cp $database_file $database_eg_file
  cp $secrets_file $secrets_eg_file
  sed -i '' "s/password:$/password: \"fill_in_mysql_password\"/g" $database_eg_file
  sed -i '' "s/secret_key_base: .*$/secret_key_base: \"fill_in_secret_key\"/g" $secrets_eg_file
  git status
  git add .
  git commit -m "$msg"
  echo

  msg="Modify $database_file & $secrets_file and add them to .gitignore"
  append_text="\n# config\n/$database_file\n/$secrets_file"
  echo $append_text >> .gitignore
  git rm --cached $database_file
  git rm --cached $secrets_file
  sed -i '' "s/password:$/password: \"$mysql_password\"/g" $database_file
  # secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  # sed -i '' "s/secret_key_base: \<\%\= ENV["SECRET_KEY_BASE"] \%\>/secret_key_base: $(pwd) %>/g" $secrets_file
  git status
  git add .
  git commit -m "$msg"
  echo

  command="rake db:create db:migrate"
  msg="$ $command"
  $command
  git status
  git add .
  git commit -m "$msg"
  echo

  msg="Add gem 'awesome_rails_console'"
  append_text="gem 'awesome_rails_console'"
  echo $append_text >> Gemfile
  bundle install
  git status
  git add .
  git commit -m "$msg"
  echo
) 2>&1 | tee $output_file
