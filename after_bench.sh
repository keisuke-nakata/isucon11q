readonly REPO_ROOT_DIR=/home/isucon/webapp
readonly NGINX_ACCESS_LOG=/var/log/nginx/access.log
readonly NGINX_ERROR_LOG=/var/log/nginx/error.log
# readonly MYSQL_SLOW_LOG=/var/log/mysql/mysql-slow.log
readonly RESULT_BASE_DIR=$REPO_ROOT_DIR/result
# readonly MYSQL_DEPLOY_DIR=$REPO_ROOT_DIR/sql
# readonly MYSQL_CONF_DIR=/etc/mysql/mysql.conf.d
readonly NGINX_CONF_DIR=/etc/nginx

node_result_dir=$NODE_RESULT_DIR

###
# collect result
###
mkdir -p $node_result_dir

# # stop profile & analyze
# curl "http://localhost:80/pprof/stop"
# readonly profile_result_dir=$result_dir/profile
# mkdir -p $profile_result_dir
# go tool pprof --pdf ${profile_tmp_dir}/cpu.pprof > ${profile_result_dir}/prof.pdf

# # finish collectl & run colplot
# kill -SIGINT $collectl_job_id
# colplot -dir $collectl_result_dir -plots cpu,disk,mem -filetype png -filedir $collectl_result_dir -height 0.5 -lastmins 3

# alp
readonly alp_result_dir=$node_result_dir/alp
mkdir -p $alp_result_dir
sudo alp json --file $NGINX_ACCESS_LOG --sort=sum -r -m "/api/condition/\w+,/api/isu/\w+" > $alp_result_dir/alp.log

# # analyze mysql slow query log
# readonly mysql_result_dir=$result_dir/mysql
# mkdir -p $mysql_result_dir
# # sudo pt-query-digest $MYSQL_SLOW_LOG > $mysql_result_dir/pt-query-digest.log  # 遅いので後回し
# # sudo gzip --best -c $MYSQL_SLOW_LOG > $mysql_result_dir/mysql-slow.log.gz  # 重すぎる

# git push
sudo chown -R isucon $node_result_dir
sudo chgrp -R isucon $node_result_dir
git checkout -b "auto${node_result_dir}"
git add --all
git commit -m "committed by after_bench.sh"
git push -u origin "auto${node_result_dir}"
git checkout main

# # 後回しにされた処理を実行
# sudo pt-query-digest $MYSQL_SLOW_LOG > $mysql_result_dir/pt-query-digest.log

# sudo chown -R isucon $result_dir
# sudo chgrp -R isucon $result_dir
# git add --all
# git commit -m "${commit_id}" -m "committed by deploy_and_benchmark.sh"
# git push origin main
