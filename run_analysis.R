## ----------------------------------------------------------------------------
## Course Project for "Getting and Cleaning Data" to demonstrate ability to 
## collect, work with, and clean a data set. 
## Output will be a tidy data set which can be used for later analysis.
## Assumption: 
##      Samsung data already downloaded and extracted to working directory.
## ----------------------------------------------------------------------------

## create tidy data set with average of each variable for each activity and
## subject
createtidyset <- function() {
    
    ## read and combine data set with its subject and activity
    read.dataset <- function(file_dataset,file_subject,file_activity) {
        ## check for valid input files 
        if (missing(file_dataset) || !file.exists(file_dataset)) {
            stop("Must have valid dataset file")
        } 
        if (missing(file_subject) || !file.exists(file_subject)) {
            stop("Must have valid subject file")
        }
        if (missing(file_activity) || !file.exists(file_activity)) {
            stop("Must have valid activity file")
        }
        
        ## load data.table for fread
        library(data.table)
        ## read the input files;using fread for greater performance
        data_set <- fread(file_dataset,header=F)
        data_set_subject <- fread(file_subject,col.names="subject")
        data_set_activity <- fread(file_activity,col.names="activity")
        ## return the combined data frame
        data.frame(data_set_subject,data_set_activity,data_set)
    }
    
    ## read features names from input file, modify it to be more descriptive,
    ## and return in lower case
    rename.header <- function(file_features) {
        ## check for valid input files 
        if (missing(file_features) || !file.exists(file_features)) {
            stop("Must have valid features file")
        }
        ## read the input files of feature names for modification
        features <- fread(file_features,header=FALSE)
        ## firstly fix the duplicate variable name read from source file
        features$V2 <- gsub("BodyBody","body",features$V2)
        ## proceed to other neccessary descriptive naming
        features$V2 <- gsub("\\(\\)"," func",features$V2)
        features$V2 <- gsub("^t","time of ",features$V2)
        features$V2 <- gsub("^f","frequency of ",features$V2)
        features$V2 <- gsub("(\\s)?Acc"," accelerometer",features$V2)
        features$V2 <- gsub("(\\s)?Mag"," magnitude",features$V2)
        features$V2 <- gsub("(\\s)?Gyro"," gyroscope",features$V2)
        features$V2 <- gsub("(\\s)?Jerk"," jerk",features$V2)
        ## return feature names in lower case
        tolower(features$V2)
    }
    
    ## set the dataset folders and files for easier maintenance
    samsung_extracted_rootfolder <- "UCI HAR Dataset"
    training_set_subfolder <- "/train/"
    test_set_subfolder <- "/test/"
    file_train_dataset <- paste0(samsung_extracted_rootfolder,
                                 training_set_subfolder,
                                 "X_train.txt")
    file_train_subject <- paste0(samsung_extracted_rootfolder,
                                 training_set_subfolder,
                                 "subject_train.txt")
    file_train_activity <- paste0(samsung_extracted_rootfolder,
                                  training_set_subfolder,
                                  "y_train.txt")
    file_test_dataset <- paste0(samsung_extracted_rootfolder,
                                test_set_subfolder,
                                "X_test.txt")
    file_test_subject <- paste0(samsung_extracted_rootfolder,
                                test_set_subfolder,
                                "subject_test.txt")
    file_test_activity <- paste0(samsung_extracted_rootfolder,
                                 test_set_subfolder,
                                 "y_test.txt")         
    ## retrieve training set
    train_df <- read.dataset(file_train_dataset,
                             file_train_subject,
                             file_train_activity
                            )
    
    ## retrieve test set
    test_df <- read.dataset(file_test_dataset,
                            file_test_subject,
                            file_test_activity
                            )
 
    ## merging training and test set
    merged_df <- merge(train_df,test_df,all=TRUE)
    
    ## rename to meaningful measurement variable names
    names(merged_df)[-1:-2] <- rename.header(paste0(
                                                samsung_extracted_rootfolder,
                                                "/features.txt")
                                             )
        
    ## rename to descriptive activities name and further categories using factor
    merged_df$activity <- factor(merged_df$activity,levels = c(1:6),
                                 labels = c("WALKING","WALKING_UPSTAIRS",
                                            "WALKING_DOWNSTAIRS","SITTING",
                                            "STANDING","LAYING")
                                 )
    
    ## factor the subject too because it's meaningless if summary it as numeric
    merged_df$subject <- factor(merged_df$subject)

    ## extract only first two variables activity and subject
    ## and mean and standard deviation variables
    mean_and_sd_cols <- which(grepl("-mean func|-std func",names(merged_df)))
    merged_df <- merged_df[,c(1,2,mean_and_sd_cols)]
 
    ## load dplyr for group_by and summarise_each
    library(dplyr)
    ## return tidy data set
    ## with average of each variable for each activity and each subject
    merged_df %>%
        group_by(subject,activity) %>%
            summarise_each(funs(mean))
    
    ## DO NOT write to txt file, project does not require script to do it.
    ## so DO IT from working env.
}
