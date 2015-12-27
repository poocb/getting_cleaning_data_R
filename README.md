#Getting and Cleaning Data Course Project

###Requirements
>The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 
>
>One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
>
>http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
>
>Here are the data for the project:
>
>https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
>
> You should create one R script called run_analysis.R that does the following. 
>
>    1. Merges the training and the test sets to create one data set.
>    2. Extracts only the measurements on the mean and standard deviation for each measurement. 
>    3. Uses descriptive activity names to name the activities in the data set
>    4. Appropriately labels the data set with descriptive variable names. 
>    5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
>
>Good luck!

###Prerequisites
Follow the instructions in this section before execute the run_analysis.R.

1. Set the working directory where the run_analysis.R located.
        
         setwd("your directory path")
2. Download the data.

         url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
         download.file(url,"Dataset.zip",method="curl")
3. Extract the data.

         unzip("Dataset.zip")

###Main Code Walk-Through
#####Read Files
Call the User-Defined Function of read.dataset to read training and test dataset together with their respective subject and activity files. File variables were defined for easier maintenance.   

         train_df <- read.dataset(file_train_dataset,
                                  file_train_subject,
                                  file_train_activity
                                 )

         test_df <- read.dataset(file_test_dataset,
                                 file_test_subject,
                                 file_test_activity
                                )

#####Merge Data Frames
Merging training and test data frames.

         merged_df <- merge(train_df,test_df,all=TRUE)

#####Rename Variable Names
Rename to meaningful measurement variable names by calling User-Defined Function of rename.header.

         names(merged_df)[-1:-2] <- rename.header(paste0(
                                                         samsung_extracted_rootfolder,
                                                         "/features.txt")
                                                 )
#####Rename And Factor The Activities
Rename to descriptive activities name and further categories using factor.

         merged_df$activity <- factor(merged_df$activity,
                                      levels = c(1:6),
                                      labels = c("WALKING","WALKING_UPSTAIRS",
                                                 "WALKING_DOWNSTAIRS","SITTING",
                                                 "STANDING","LAYING")
                                     )

#####Factor The Subject
Factor the subject too because it's meaningless if summary it as numeric.

         merged_df$subject <- factor(merged_df$subject)

#####Extract The Target Variables
Extract only activity, subject, mean and standard deviation variables.

         mean_and_sd_cols <- which(grepl("-mean func|-std func",names(merged_df)))
         merged_df <- merged_df[,c(1,2,mean_and_sd_cols)]

#####Average The Variables For Each Activity For Each Subject
Load dplyr package to average variables for the group of subject and activity.

         library(dplyr)
         merged_df %>%
                   group_by(subject,activity) %>%
                   summarise_each(funs(mean))

###Example
To run the run_analysis.R and export it to txt file.

         tidyset <- createtidyset()
         write.table(tidyset,"output.txt")

