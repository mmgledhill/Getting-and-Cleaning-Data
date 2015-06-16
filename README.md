README.md

###Function Description
Name: run_analysis

High-level flow of function
 * Read/merge data
 * Add feature descriptions (column headings) to data
 * Select stats of interest
 * Split out feature measurement components (units, vectors, measurement types)
 * Define key for organizing metric values into unique measures for each vector, stat and unit
 * Group by variables, and summarize each with mean
 * Orgnaize output and write to file

Assumptions:
* You are in the right directory that has a test/train subdirectory with the right files.
* The number of features/measurements can change (not hard-coded)
 
Requirements:
 * dplyr package needs to be installed/loaded
 * tidyr package needs to be installed/loaded

See run_analysis.r code for full technical details/comments.
See Cookbook_run_analysis.md for more details about tidy logic or variables.

References:
Using read.table based on discussion thread suggestion by Carolyn Duby (Community TA), with colClasses=numeric to handle scientific notation.
reference: https://class.coursera.org/getdata-015/forum/thread?thread_id=120 
date accessed 6/12/2015
reference: http://stackoverflow.com/questions/17715509/how-can-i-get-r-to-read-a-column-of-numbers-in-exponential-notation
date accessed 6/12/2015
group by and summarize_each suggestion from the coursera discussion forum/thread to get group averages
