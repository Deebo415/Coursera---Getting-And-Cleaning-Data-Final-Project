# Getting and Cleaning Data - Capstone Project Code Book
## Sean Dobbs

This code book describes steps taken to download, read, clean, and transform data sets from wearable motion detection devices using the "run_analysis.R" script contained within this GitHub repo. 

## The focus of this project was to create one R script called run_analysis.R that does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Before you start, the "dplyr" and "data.table" packages were used extensively to complete this project. So, if trying to recreate the results, ensure that you have these packages installed and ready to go by running the folowing code:

***install_packages("dplyr")***
***library(dplyr)***   
***install_packages("data.table")***   
***library(data.table)***   

# Walkthrough of the tasks:

## Combined three of the requirements into one "task chunk"
### 1. Merges the training and the test sets to create one data set.   
### 3. Uses descriptive activity names to name the activities in the data set.   
### 4. Appropriately labels the data set with descriptive variable names.   

- Download the ZIP file containing the data needed for the project, and unzip it into the working folder:

***download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","wearable_data.zip")***
***unzip("wearable_data.zip")***   

- At that point, an unzipped folder called "UCI HAR Dataset", containing all the data needed for this assignment, is created   
- That folder contains two couple reference files (features_info.txt, README.txt), as well as two "helper" files ("activity_labels.txt" and "features.txt")   
- The two "helper" files contain data that will likely be useful later, so they were read into data tables as such:   

  ***features <- fread("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)***   
  contains 561 rows and just one column of characters that ultimately serve as the column names for "test_data". So, need to make that one column into one row/vector to prepare it to be used as such:   
  ***features_header <- transpose(features)***   
    
  ***activity_labels <- fread("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)***   
  contains 6 rows and 2 columns. Ends up as a "decoder ring" for the "test_activities" variable created a bit later   

-The columns in the resultant data tables were then given meaningful names("ID", "Feature", and "Activity"):      
***names(features) <- c("ID","Feature")***   
***names(activity_labels) <- c("ID","Activity")***   

- The UCI HAR Dataset folder also contained two subfolders, /test and /train, which contain the test and training data to  
be combined into one data set.   
- The /test and /train folders each contain three .txt files (with the word "test" or "train" replacing the parentheses in the corresponding folder:      
    *- subject_(   ).txt (gives the code number for each test subject)*  
    *- X_(  ).txt (a huge file that contains the actual test data)*  
    *- y_(  ).txt (gives a code number corresponding to each activity)*    
    
- There is also another subfolder within each called "Inertial Signals". These seem to be a further breakdown of what's already contained in the "X" files, and were not directly used.   

- The useful files were read into data tables, and the columns were given more useful names:   

***subject_test <- fread("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE)***   
***names(subject_test) <- "Subject.Code"***   
"subject_test" contains 2947 rows and 1 column   

***test_data <- fread("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)***   
contains 2947 rows and 561 columns, none with headers. Set the "features2" variable from above as the column names    
names(test_data) <- as.character(features2[2,])   

***test_activity_codes <- fread("UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE)***   
contains 2947 rows with a single column of numbers ranging from 1 to 6; each nimber corresponding to a specific activity   

- Decode these activites with the "activity_code" data table created above to give descriptive names to the numerically identified activities within test_data, creating "test_activities", which will ultimately serve as a column in the final database:   

***test_activities <- test_activity_codes %>%   
  mutate(V1 = replace(V1, V1 == "1","WALKING")) %>%   
  mutate(V1 = replace(V1, V1 == "2","WALKING_UPSTAIRS")) %>%   
  mutate(V1 = replace(V1, V1 == "3","WALKING_DOWNSTAIRS")) %>%   
  mutate(V1 = replace(V1, V1 == "4","SITTING")) %>%   
  mutate(V1 = replace(V1, V1 == "5","STANDING")) %>%   
  mutate(V1 = replace(V1, V1 == "6","LAYING"))***   
  
- And give a descriptive column name to "test_activities"     
  
  ***names(test_activities) <- "Subject.Activity"***   

- Combine the "subject_test","test_activities", and "test_data" variable data tables into one, which is the complete test data set:   

***new_test_data <- cbind(subject_test,test_activities,test_data)***   
contains 2947 rows, 563 columns   

- Do the same thing for the training data set. Will only call out differences between the two creation processes. Other than that, the only difference is the word "training" replacing the word "test":   

***subject_train <- fread("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE)***   
Contains 7352 rows, and one column containing the numerical code for each subject   

***names(subject_train) <- "Subject.Code"***   
***training_data <- fread("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)***   
Contains 7352 rows, 561 columns   
***names(training_data) <- as.character(features2[2,])   
training_activity_codes <- fread("UCI HAR Dataset/train/y_train.txt", stringsAsFactors = FALSE)***   
Contains 7352 rows   
***training_activities <- training_activity_codes %>%   
  mutate(V1 = replace(V1, V1 == "1","WALKING")) %>%   
  mutate(V1 = replace(V1, V1 == "2","WALKING_UPSTAIRS")) %>%   
  mutate(V1 = replace(V1, V1 == "3","WALKING_DOWNSTAIRS")) %>%   
  mutate(V1 = replace(V1, V1 == "4","SITTING")) %>%   
  mutate(V1 = replace(V1, V1 == "5","STANDING")) %>%   
  mutate(V1 = replace(V1, V1 == "6","LAYING"))   
names(training_activities) <- "Subject.Activity"   
new_training_data <- cbind(subject_train,training_activities,training_data)***   
Contains 7352 rows, 563 columns   

- Combine those two data sets into one:    
***total_data <- rbind(new_test_data, new_training_data)***   
Contains 10299 rows, 563 columns   


## Next, must ensure that "run_analysis.R":##      
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.##   

- According to the "features_info.txt" reference document, those measures identified with "std()" are standard deviations, and those with "mean()" are means. Isolate only the columns containing standard deviations and means.   

- BUT FIRST, Not sure whether it was purposeful and intended to be part of the "cleaning" process, or if it was an error, but each column name containing the string "bandsEnergy" has an EXACT DUPLICATE. This will return an error when trying to select columns to for the new data table. Two courses of action: a) give the duplicated columns unique names, or b) remove the columns altogether.  Since none of the duplicated columns contain any means or standard deviations, considered them useless for this project's purposes and went with option b). That was done by chopping the "total_data" table into four parts, which are what is left over after disregarding the troublesome columns, and then combining them together again, thus yielding a total data set ("total_data_new") that is devoid of the bad columns:

***cols1 <- total_data[,1:304]   
cols2 <- total_data[,347:383]   
cols3 <- total_data[,426:462]   
cols4 <- total_data[,505:563]   
total_data_new <- cbind(cols1, cols2, cols3, cols4)***   
Contains 10299 rows, 437 columns   

- Now, the standard deviation and mean columns can be isolated, and a new data table is created, "total_stdmean_data":   

***total_stdmean_data <- select(total_data_new, Subject.Code:Subject.Activity, contains("std()"), contains("mean()"))***   
Contains 10299 rows, 68 columns   

## The next thing to do is to       
## 4. Appropriately label the data set with descriptive variable names.   

***names(total_stdmean_data) <- gsub("^f","Frequency.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("^t","Time.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("mean()","Mean",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("std()","Standard.Deviation",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("X$","X.Axis",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Y$","Y.Axis",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Z$","Z.Axis",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("BodyBody","Body",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Body","Body.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Gyro","Gyroscope.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Acc","Accelerometer.",names(total_stdmean_data))
names(total_stdmean_data) <- gsub("Jerk","Jerk.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Mag","Magnitude.",names(total_stdmean_data))   
names(total_stdmean_data) <- gsub("Gravity","Gravity.",names(total_stdmean_data))***   

## The final thing to do is:##    
## 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject##   

- So, success for this means that there should be one unique row for each subject/activity combination.  
- There are 30 subjects and 6 activites, so the new data set should contain 180 rows.   

- "group_by" the two things (activity and subject) to create the for which we want averages, then execute "summarise_all", calling the "mean" function for each of the numeric columns, then ungroup the new data table ("averages_by_subject_and_activity"), if the desired result is obtained, so that it can be used in an ungrouped fashion going forward, if needed:   

***averages_by_subject_and_activity <- total_stdmean_data %>%   
group_by(Subject.Code, Subject.Activity) %>%   
summarise_all(averages_by_subject_and_activity,list(mean = mean))***   
- Which contains the expected 180 rows and 68 columns, so:   

***averages_by_subject_and_activity <- ungroup(averages_by_subject_and_activity)***   
yields the final required data set.   
