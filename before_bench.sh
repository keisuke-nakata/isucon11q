readonly REPO_ROOT_DIR=/home/isucon/webapp
readonly NGINX_ACCESS_LOG=/var/log/nginx/access.log
readonly NGINX_ERROR_LOG=/var/log/nginx/error.log
readonly MYSQL_SLOW_LOG=/var/log/mysql/mysql-slow.log
readonly MYSQL_CONF_DIR=/etc/mysql/mariadb.conf.d
readonly NGINX_CONF_DIR=/etc/nginx

###
# refresh logs
###

# refresh nginx access & error log
sudo truncate --size 0 $NGINX_ACCESS_LOG $NGINX_ERROR_LOG

# refresh mysql slow query log
sudo truncate --size 0 $MYSQL_SLOW_LOG
sudo mysqladmin flush-logs

###
# deploy
###

# deploy env.sh
cp ${REPO_ROOT_DIR}/conf/env.sh /home/isucon/

# deploy mysql
sudo cp ${REPO_ROOT_DIR}/conf/mysql/50-server.cnf $MYSQL_CONF_DIR/
sudo systemctl restart mysql.service
sudo systemctl restart mysqld.service

# for file in $(find $MYSQL_DEPLOY_DIR -type f); do
#   mysql --force isuconp < $file
# done

# deploy nginx
sudo cp $REPO_ROOT_DIR/conf/nginx/nginx.conf $NGINX_CONF_DIR/
sudo cp $REPO_ROOT_DIR/conf/nginx/isucondition.conf $NGINX_CONF_DIR/sites-enabled/
sudo systemctl reload nginx

# deploy go
(
  cd $REPO_ROOT_DIR/go
  go build -o isucondition
)
sudo systemctl restart isucondition.go.service

###
# prepare benchmark
###

# # start collectl
# readonly collectl_result_dir=$result_dir/collectl
# mkdir -p $collectl_result_dir
# collectl -scdm -f $collectl_result_dir -P &
# readonly collectl_job_id=$!

# # start profile
# readonly profile_tmp_dir=$(mktemp -d)
# curl "http://localhost:80/pprof/start?path=${profile_tmp_dir}/"
