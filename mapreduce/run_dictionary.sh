# Run rake task to generate pages to parse
cd /Users/sfigart/code/rails_projects/search_engine

# Clear up previous run
hadoop fs -rmr /user/sfigart/dictionary
hadoop fs -rm /user/sfigart/term_doc_freq.txt
rm dictionary.txt

# Copy this run (term_doc_freq.txt)
hadoop fs -put ./term_doc_freq.txt /user/sfigart/

# Run map reduce in Hadoop
#./mapreduce/dictionary.rb --run=hadoop /user/sfigart/term_doc_freq.txt /user/sfigart/dictionary

# Run map reduce on the file (LOCAL NON HADOOP)
./mapreduce/dictionary.rb --run=local term_doc_freq.txt dictionary.txt

# Copy results out of hadoop
hadoop fs -getmerge /user/sfigart/dictionary dictionary.txt addnl

# Process visited
#rake crawler:update_visited[links_found.txt]
