# Run rake task to generate pages to parse
cd /Users/sfigart/code/rails_projects/search_engine

# Clear up previous run
hadoop fs -rmr /user/sfigart/dictionary
hadoop fs -rm /user/sfigart/term_doc_freq.txt
rm dictionary.txt

# Copy this run (term_doc_freq.txt)
hadoop fs -put ./term_doc_freq.txt /user/sfigart/

# Run map reduce in Hadoop
./mapreduce/dictionary.rb --run=hadoop /user/sfigart/term_doc_freq.txt /user/sfigart/dictionary

# Run map reduce on the file (LOCAL NON HADOOP)
#./mapreduce/dictionary.rb --run=local term_doc_freq.txt dictionary.txt

# Copy results out of hadoop
hadoop fs -getmerge /user/sfigart/dictionary dictionary.txt addnl

# Mark pages visited
rake parser:mark_indexed[to_parse.txt]

# Update dictionary with terms
rake dictionary:generate[dictionary.txt]

# Compute IDF for all dictionary entries
rake dictionary:compute_idf

# Create/Update Postings
rake postings:generate[term_doc_freq.txt]

# Compute page vector lengths
rake page:compute_vector_length

# End
