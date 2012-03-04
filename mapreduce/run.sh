# Run rake task to generate sites to visit
cd /Users/sfigart/code/rails_projects/search_engine
rake crawler:not_visited[to_visit.txt]

# Clear up previous run
hadoop fs -rmr /user/sfigart/crawler
hadoop fs -rm /user/sfigart/to_visit.txt
rm links_found.txt

# Copy this run (sites to visit)
hadoop fs -put ./to_visit.txt /user/sfigart/

# Run map reduce in Hadoop
./mapreduce/crawler.rb --run=hadoop /user/sfigart/to_visit.txt /user/sfigart/crawler

# Run map reduce on the file (LOCAL NON HADOOP)
# ./mapreduce/crawler.rb --run=local to_visit.txt links_found.txt

# Copy results out of hadoop
hadoop fs -getmerge /user/sfigart/crawler links_found.txt addnl

# Process visited
rake crawler:update_visited[links_found.txt]
