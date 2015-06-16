---

title: "run analysis.R Cookbook"

author: "MMGLEDHILL"

date: "6/12/2015"

output:

  txt file: tiny_data.txt

---

 

## Project Description
Demonstrate good data scientist skills by being able identify relevant info and organize into a tidy dataset. 
Generate a data set where each column only has one variable; and each row is one observation, and each table has only one observational unit (

Specifically:
1) Join the training and test data sets from the accelerometers and filter for mean and std measures for each feature.
2) Generate 'tidy' dataset for each subject, activity (standing, walking, etc.), feature, measurement type (time and frequency) and vector.
 
##Study design and data processing
Merged two sets of data (train and test) for 30 subjects doing different activities (standing, walking, ect.).
Multiple features (see feature_info.txt) analysed across X,Y,Z vectors for time and frequency.

Filters:
 * The feature vector measures included are for the mean and std only. 
 * The angle measures were excluded since it is a summary measure and not a mean or std itself. 
 * The meanFrequency was also excluded because it represented a weighted average and not a uniformly weighted average or simple mean. 
 * There were duplicate columns identified in the dataset but since these were not summarized as mean or std already they were excluded.

###Collection of the raw data

This data set was provided on the Coursera website for the Getting and Cleaning data course.

Reference: Human Activity Recognition Using Smartphones Dataset
Version 1.0
www.smartlab.ws
For more information about this dataset contact: activityrecognition@smartlab.ws
Data source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

###Notes on the original (raw) data 

Original dataset had 561 'feature vectors'.
Original measurements were in scientific notation.
Some of the 'feature vector' columns were duplicated in the dataset. Example: fBodyAcc-bandsEnergy()-17,24
Each 'feature vector' name had multiple components included like signal source, units(time or frequency), Vector (X,Y,Z), and summary statistic like mean, std or iqr, etc.
Not all features had a X, Y, Z vector identified.
The angle measurements did not match naming convention for other features/variables


##Creating the tidy datafile

Step1: Read data in,join with relevant descriptions,merge data sets,and and filter for stats of interest

Step2: Get reasonable number of columns
There were still a large number of columns in the data set (66); even after filtering for mean and std only.
By collapsing these columns into a single column it was easier to see the similarities in the data.
Used 'gather' to collapse the 'feature vector' columns into a key and value.

Step3: Break out different components of 'feature' being measured. 
Used the 'separate' function to break the 'feature' column up into the feature, statistic being summarized, and vector. 
In case, there is no vector identified set it to 'OTHER'.
Created a separate columns to capture feature details, including units (time or frequency) and measurement details (jerk, magnitude, body or gravity)

Step 4: Split out variable results into different columns for single observation.
Defined key to use for splitting out observation measurements based on the vector, statistics (mean or std), and units. 
Adding the units in key increased the number of NAS in case where time or freq not collected for each measure; but reduced rows per observation from 2 (time and freq) to 1.

Step 5: Group data by subject, activity, and feature. Calculate mean, and arrange columns for writing the file out. Moved unknown/Other vector to end.


###Guide to create the tidy data file

Description on how to create the tidy data file (1. download the data, ...)/
 Download data from the source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
 Unzip file
 Set working directory to UCI HAR Dataset folder which has the test and train folders.
 After sourcing (run_analysis.R), run it with no parameters/arguments.
 A tiny_data.txt file will be written to the current folder.

###Cleaning of the data

 Filters for variables/features that are summarized by mean or standard deviation (std) only.
 Breaks variable components out into the features measured, units, vector and summary statistic
 Calculates mean for each subject, activity, feature by vector and summary stat measured.

##Description of the variables in the tiny_data.txt file

General: Tiny_data.txt is the Average X,Y,Z mean and std result for each subject, activity and feature.
The feature measure is separated into 4 different columns:
 * Measure - Body, BodyBody (Body^2) or Gravity
 * Signal_source - Accelerometer (Acceleration) or Gyroscope
 * Jerk Measurement - Yes or No
 * Magnitude Measurement - Yes or No 
In case, no vector was denoted it is set to OTHER.
The vector results are split into separate columns for the different statistics (mean and std), units (time and frequency).
The vector results are separated by unit since we couldn't write out two different tables for each observational unit as the assignment only called for one dataset output.

'data.frame':   2340 obs. of  23 variables:
 * subject          : int  1-30 for each subject in this study ...
 * activity         : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"
 * dataset          : Factor w/ 2 levels "TEST","TRAIN" retained in case there are any questions in future.
 * measure          : Factor w/ 3 levels "Body","Body^2","Gravity"
 * signal_source    : Factor w/ 2 levels "Acceleration","Gyroscope"
 * jerk_meas        : Factor w/ 2 levels "N","Y" where Y = Jerk Measurement
 * mag_meas         : Factor w/ 2 levels "N","Y" where Y = Magnitude measurement
 * X.mean..time.    : X-vector average mean results (time units) numeric  0.2216 0.0811 NA NA NA ...
 * X.std..time.     : X-vector average std results (time units) numeric  -0.928 -0.958 NA NA NA ...
 * Y.mean..time.    : Y-vector average mean results (time units) numeric  -0.04051 0.00384 NA NA NA ...
 * Y.std..time.     : Y-vector average std results (time units) numeric  -0.837 -0.924 NA NA NA ...
 * Z.mean..time.    : Z-vector average mean results (time units) numeric -0.1132 0.0108 NA NA NA ...
 * Z.std..time.     : Z-vector average std results (time units) numeric  -0.826 -0.955 NA NA NA ...
 * OTHER.mean..time.: OTHER-vector average mean results (time units) numeric NA NA -0.954 -0.842 NA ...
 * OTHER.std..time. : OTHER-vector average std results (time units) numeric  NA NA -0.928 -0.795 NA ...
 * X.mean..freq.    : same as above but (frequency units) numeric  -0.939 -0.957 NA NA NA ...
 * X.std..freq.     : same as above but (frequency units) numeric  -0.924 -0.964 NA NA NA ...
 * Y.mean..freq.    : same as above but (frequency units) numeric  -0.867 -0.922 NA NA NA ...
 * Y.std..freq.     : same as above but (frequency units) numeric  -0.834 -0.932 NA NA NA ...
 * Z.mean..freq.    : same as above but (frequency units) numeric  -0.883 -0.948 NA NA NA ...
 * Z.std..freq.     : same as above but (frequency units) numeric  -0.813 -0.961 NA NA NA ...
 * OTHER.mean..freq.: same as above but (frequency units) numeric  NA NA NA -0.862 -0.933 ...
 * OTHER.std..freq. : same as above but (frequency units) numeric  NA NA NA -0.798 -0.922 ...


##Sources

Reference: Hadley Wickham (Year Unknown), Tidy Data. Journal of Statistical Software, Volume Unknown, Issue Unknown, Page Unknown. URL:""http://vita.had.co.nz/papers/tidy-data.pdf", Date Accessed: 6/16/2015

 
