readonly REPO_ROOT_DIR=/home/isucon/webapp
readonly RESULT_BASE_DIR=$REPO_ROOT_DIR/result
readonly APPSERVER1_PRIVATE_IP=192.168.0.11
readonly APPSERVER2_PRIVATE_IP=192.168.0.12
readonly APPSERVER3_PRIVATE_IP=192.168.0.13

if (( $# != 1 )); then
  echo "Usage: $0 <change log>"
  exit 1
else
  readonly changelog=$1
fi

set -eux

# get latest changes
git pull origin main
readonly commit_id=$(git rev-parse HEAD)

# create result dir
readonly dt=$(date +%Y%m%d-%H%M%S)
readonly result_dir=${RESULT_BASE_DIR}/${dt}_${commit_id}
mkdir -p $result_dir

###
# before bench
###
cmd="cd ${REPO_ROOT_DIR} && git pull origin main && bash before_bench.sh"
# appserver 1 (this)
bash -c "$cmd"
# appserver 2
ssh -i ~/.ssh/isucon11q_appserver isucon@$APPSERVER2_PRIVATE_IP $cmd
# appserver 3
ssh -i ~/.ssh/isucon11q_appserver isucon@$APPSERVER3_PRIVATE_IP $cmd

###
# run benchmark
###
echo "Run benchmark, and input your score: "
read score

###
# record score
###
echo "|${dt}|${score}|${commit_id}|${changelog}|" >> $RESULT_BASE_DIR/summary.md
git add --all
git commit -m "${commit_id}" -m "committed by bench.sh"
git push origin main

###
# after bench
###
# appserver 1 (this)
node_result_dir=${result_dir}/appserver1
cmd="cd ${REPO_ROOT_DIR} && git pull origin main && NODE_RESULT_DIR=${node_result_dir} bash after_bench.sh"
bash -c "$cmd"
git fetch
git merge origin/$node_result_dir
# appserver 2
node_result_dir=${result_dir}/appserver2
cmd="cd ${REPO_ROOT_DIR} && git pull origin main && NODE_RESULT_DIR=${node_result_dir} bash after_bench.sh"
ssh -i ~/.ssh/isucon11q_appserver isucon@$APPSERVER2_PRIVATE_IP $cmd
git fetch
git merge origin/$node_result_dir
# appserver 3
node_result_dir=${result_dir}/appserver3
cmd="cd ${REPO_ROOT_DIR} && git pull origin main && NODE_RESULT_DIR=${node_result_dir} bash after_bench.sh"
ssh -i ~/.ssh/isucon11q_appserver isucon@$APPSERVER3_PRIVATE_IP $cmd
git fetch
git merge origin/$node_result_dir

# git push
git push origin main
