# Run rake task to generate pages to parse
cd /Users/sfigart/code/rails_projects/search_engine
rake parser:not_indexed[to_parse.txt]

# Clear up previous run
hadoop fs -rmr /user/sfigart/parser
hadoop fs -rm /user/sfigart/to_parse.txt
rm term_doc_freq.txt

# Copy this run (sites to visit)
hadoop fs -put ./to_parse.txt /user/sfigart/

# Run map reduce in Hadoop
./mapreduce/parser.rb --run=hadoop /user/sfigart/to_parse.txt /user/sfigart/parser

# Run map reduce on the file (LOCAL NON HADOOP)
#./mapreduce/parser.rb --run=local to_parse.txt term_doc_freq.txt

# Copy results out of hadoop
hadoop fs -getmerge /user/sfigart/parser term_doc_freq.txt addnl

# Process visited
#rake crawler:update_visited[links_found.txt]
