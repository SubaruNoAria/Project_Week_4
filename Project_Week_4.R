################################################################
#Description: run_analysis.R - Getting and Cleaning Data

################################################################

        #This project will:
        #1. merge the training and the test sets to create one data set.
        #2. Extracts only the measurements on the mean and standard deviation for each measurement
        #3. Uses descriptive activity names to name the activties in the data set
        #4. Appropriately labels the data set with descriptive variable names
        #5. From the data set in step 4, creates a second 

# Data Resource:    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Data Description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

#Load Libraries

########################################
library(reshape2)
library(data.table)

#download file and upzip files
if(!file.exists("UCI HAR Dataset")){
        dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(dataURL, zipFile)
        unzip(zipfile, 
              files = NULL, 
              list = FALSE, 
              overwrite = TRUE, 
              junkpaths = FALSE,
              exdir = ".", 
              unzip = "internal",
              setTimes = FALSE)
}

#load test data files X_test.txt and Y_test.txt
test_x <- read.table("./UCI HAR Dataset/test/X_test.txt")
test_y <- read.table("./UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#load training data files X_training.txt and Y_training.txt
train_x <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("./UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

##########################################################################################################
# part 1 - Merges the training and the test sets to create one data set
##########################################################################################################
merged_x <- rbind(test_x, train_x)
merged_y <- rbind(test_y, train_y)
merged_subject <- rbind(subject_test, subject_train)

# add feature names to columns
features_names <- read.table("./UCI HAR Dataset/features.txt")
features_names <- features_names$V2
colnames(merged_x) <- features_names

#########################################################################################################
# part 2 - Extracts only the measurements on the mean and standard deviation for each measurement
#########################################################################################################
merged_subset <- merged_x[, grep("mean|std", colnames(merged_x))]

#########################################################################################################
# part 3 - Uses descriptive activity names to name the activities in the data set
#########################################################################################################

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
merged_y$activity <- activity_labels[merged_y$V1, 2]

#########################################################################################################
# part 4 - Appropriately labels the data set with descriptive variable names
#########################################################################################################

names(merged_y) <- c("ActivityID", "ActivityLabel")
names(merged_subject) <- "Subject"

#########################################################################################################
# part 5 - From the data set in step 4, creates a second, independent tidy data set with 
# the average of each variable for each activity and each subject
#########################################################################################################

# merge all data to single data
merged_all <- cbind(merged_subject, merged_y, merged_x)
labels_all <- c("Subject", "ActivityID", "ActivityLabel")

data_labels <- setdiff(colnames(merged_all), labels_all)
melted_data <- melt(merged_all, id = labels_all, measure.vars = data_labels, na.rm = TRUE)
tidy_data <- dcast(melted_data, Subject + ActivityLabel ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt", row.names = FALSE)







