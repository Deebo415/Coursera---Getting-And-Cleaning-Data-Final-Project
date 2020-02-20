download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","wearable_data.zip")
unzip("wearable_data.zip")

features <- fread("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
activity_labels <- fread("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)

names(features) <- c("ID","Feature")
names(activity_labels) <- c("ID","Activity")

subject_test <- fread("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE)
names(subject_test) <- "Subject.Code"

test_data <- fread("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)

features2 <- transpose(features)
names(test_data) <- as.character(features2[2,])

test_activity_codes <- fread("UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE)

test_activities <- test_activity_codes %>%
  mutate(V1 = replace(V1, V1 == "1","WALKING")) %>%
  mutate(V1 = replace(V1, V1 == "2","WALKING_UPSTAIRS")) %>%
  mutate(V1 = replace(V1, V1 == "3","WALKING_DOWNSTAIRS")) %>%
  mutate(V1 = replace(V1, V1 == "4","SITTING")) %>%
  mutate(V1 = replace(V1, V1 == "5","STANDING")) %>%
  mutate(V1 = replace(V1, V1 == "6","LAYING"))

names(test_activities) <- "Subject.Activity"

new_test_data <- cbind(subject_test,test_activities,test_data)

subject_train <- fread("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE)
names(subject_train) <- "Subject.Code"

training_data <- fread("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)
names(training_data) <- as.character(features2[2,])

training_activity_codes <- fread("UCI HAR Dataset/train/y_train.txt", stringsAsFactors = FALSE)

training_activities <- training_activity_codes %>%
  mutate(V1 = replace(V1, V1 == "1","WALKING")) %>%
  mutate(V1 = replace(V1, V1 == "2","WALKING_UPSTAIRS")) %>%
  mutate(V1 = replace(V1, V1 == "3","WALKING_DOWNSTAIRS")) %>%
  mutate(V1 = replace(V1, V1 == "4","SITTING")) %>%
  mutate(V1 = replace(V1, V1 == "5","STANDING")) %>%
  mutate(V1 = replace(V1, V1 == "6","LAYING"))
names(training_activities) <- "Subject.Activity"
new_training_data <- cbind(subject_train,training_activities,training_data)

total_data <- rbind(new_test_data, new_training_data)

cols1 <- total_data[,1:304]
cols2 <- total_data[,347:383]
cols3 <- total_data[,426:462]
cols4 <- total_data[,505:563]
total_data_new <- cbind(cols1, cols2, cols3, cols4)

total_stdmean_data <- select(total_data_new, Subject.Code:Subject.Activity, contains("std()"), contains("mean()"))

names(total_stdmean_data) <- gsub("^f","Frequency.",names(total_stdmean_data))
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
names(total_stdmean_data) <- gsub("Gravity","Gravity.",names(total_stdmean_data))

averages_by_subject_and_activity <- total_stdmean_data %>%
group_by(Subject.Code, Subject.Activity) %>%
summarise_all(list(mean = mean))

averages_by_subject_and_activity <- ungroup(averages_by_subject_and_activity)