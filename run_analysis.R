run_analysis <- function () {
	# This function reads data from train and test folders, and joins it with the subjects and activity/feature descriptions.
	# It then looks for all features that have a mean () or std () variable; and organizes the data to return a single row for 
	# each feature and measurement type (Time or Frequency) per subject and actvity.

	doc_list <- list.files()

	if(!(any(doc_list=="test") && any(doc_list=="train"))) {
		print("Please set your wd (setwd) to root folder with train/test sub folders\n")
		return
	}

	#
	## Read Data
	#
	#Using read.table based on discussihaon thread suggestion by Carolyn Duby (Community TA)
	#reference: https://class.coursera.org/getdata-015/forum/thread?thread_id=120 
	#date accessed 6/12/2015
	#set colClasses = numeric to handle scientific notation
	#reference: http://stackoverflow.com/questions/17715509/how-can-i-get-r-to-read-a-column-of-numbers-in-exponential-notation
	#date accessed 6/12/2015

	#read data
	data_train <- read.table("./train/X_train.txt",header=FALSE, colClasses="numeric")
	data_test <- read.table("./test/X_test.txt",header=FALSE, colClasses="numeric")

	#retain visibility to dataset source; just in case it is needed later
	data_train <- data_train %>% mutate(dataset="TRAIN")
	data_test <- data_test %>% mutate(dataset="TEST")

	#read subjects info to join with data
	subjects_train <- read.table("./train/subject_train.txt",header=FALSE, colClasses="numeric")
	subjects_test <- read.table("./test/subject_test.txt",header=FALSE, colClasses="numeric")

	#bind subjects to data
	data_train<-cbind(subject = subjects_train[,1],data_train)
	data_test<-cbind(subject=subjects_test[,1],data_test)

	#read activity labels
	labels_train <- read.table("./train/y_train.txt",header=FALSE)
	labels_test <- read.table("./test/y_test.txt",header=FALSE)
	
	#bind actvity labels to data
	data_train<-cbind(labels = labels_train[,1],data_train)
	data_test<-cbind(labels=labels_test[,1],data_test)

	#merge train and test data
	all_data <- rbind(data_train,data_test)

	## Add decriptions for feature vectors and actvity labels.
	
	#add columns labels from feature vectors and 
	features_names <- read.table("./features.txt",header=FALSE)
	names(all_data)<- make.names(c("labels","subject", as.character(features_names[,2]),"dataset"),unique=TRUE)

	#join 'activity' label to table based on 'labels' key
	activity_labels<-read.table("./activity_labels.txt",header=FALSE)
	names(activity_labels)<-c("labels","activity")
	all_data<-left_join(all_data,activity_labels,by=c("labels"))


	#grab mean and std columns only
	#since angle is a variable that is estimated from main signals and not itself a mean or std it is excluded.
	#since meanFreq is a weighted average and not a simple mean it is excluded.
	select_stats<-select(all_data,activity,subject,dataset,matches("(mean\\.|std\\.)",ignore.case=TRUE),-starts_with("angle"))
		
	#reorder columns
	numcols<- dim(select_stats)[2]
	select_stats<-select(select_stats,subject,activity,dataset,4:numcols)

	#
	## Tidy up data
	# Modify select_stat table to get nice format for future analysis
	#gather compresses multiple 'feature vector' columns into one column with key-label 'feature_vector' and values 'value'
	mod<-gather(select_stats,feature_vector,value,-subject,-activity,-dataset)

	#seperate function attempts to seperate the different attributes in the feature vector, like the feature name, statistics, and vector angle
	mod<-separate(mod,feature_vector,sep="\\.",into=c("feature","stat","vector"),extra="merge")
	
	#pretty up vector column by removing extra ..
	mod <- mod %>% mutate(vector=gsub("\\.","",mod$vector))
	
	#in case there is no XYZ specified set the vector direction to OTHER
	mod$vector[mod$vector==""]="OTHER"

	#split out the measurement type, time or frequency from feature tame
	mod <- mod %>% mutate(unit="(time)")
	mod$unit[grep("^f",mod$feature)]="(freq)"

	#added to help with grouping columns
	mod <- mod %>% mutate(order="1")
	mod$order[grep("^f",mod$feature)]="2"

	
	#remove the t/f from the feature name
	mod$feature <- substring(mod$feature,2,length(mod$feature))

	#break out the feature measured further into the different signals measured (measure, signal_source, jerk, mag)
	mod<-mod %>% mutate(measure="Body")
	mod$measure[grep("BodyBody",mod$feature)]="Body^2"
	mod$measure[grep("Gravity",mod$feature)]="Gravity"

	mod<-mod %>% mutate(signal_source="Acceleration")
	mod$signal_source[grep("Gyro",mod$feature)]="Gyroscope"

	mod<-mod %>% mutate(jerk_meas="N")
	mod$jerk_meas[grep("Jerk",mod$feature)]="Y"

	mod<-mod %>% mutate(mag_meas="N")
	mod$mag_meas[grep("Mag",mod$feature)]="Y"

		
	#define key to split out data into columns
	mod<-mod %>% mutate(keyid = paste(order,vector,stat,unit,sep=" "))%>% select(-stat,-vector,-order,-unit)

	#summarise data using group_by and summarise_each; had tried summarize by itself but it wasn't working; found suggestion on forum
	by_sub_act<-group_by(mod,subject,activity,dataset,feature,measure,signal_source,jerk_meas,mag_meas,keyid)
	by_sub_act <- by_sub_act %>% arrange(subject,activity,dataset,feature,measure,signal_source,jerk_meas,mag_meas,keyid)
	final_results<- by_sub_act %>% summarise_each(funs(mean))
	
	#split out metric results by key (vector XYZ , and stat mean or std)
	final_results<- final_results %>% spread(keyid,value) %>% select(-feature)
	#move OTHER to end since it isn't the main focus
	final_results<- select(final_results,1:7,10:15,8:9,18:23,16:17)
	colfinal <- names(final_results)
	cleanname <- substring(names(final_results),3,length(names(final_results)))
	names(final_results)<-c(names(final_results)[1:7],cleanname[8:23])

	#write the results out to a csv file
	write.table(final_results,file="tiny_data.txt",row.names=FALSE,sep="\t")

	##CELEBRATE!!!!
}