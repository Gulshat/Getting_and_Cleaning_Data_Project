library("data.table")
library("reshape2")

# 1. Download the UCI HAR Dataset

setwd("/Users/gulshat/Coursera/getting_cleanning_data/Getting_and_Cleaning_Data_Project/")

dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCIHARDataset.zip"
download.file(dataUrl, destfile = zipFile, method = "curl")

unzip(zipFile)

# Loading the data column name
features <- read.table("UCI HAR Dataset/features.txt")

features_n <- features[,2]

# Loading activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Extracting only the measurement on the mean and standart deviation for
# each measurment.
extract_features <- grepl("mean|std", features_n)

# Loading and process X_train and Y_train data
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

names(X_train) <- features_n

# Extracting only the measurements on the mean and standard deviation for
# each measurment
X_train = X_train[,extract_features]

# Loading activity data
Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Binding the data
train_data <- cbind(as.data.table(subject_train), Y_train, X_train)

# Loading and process X_test and Y_test data
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features_n

# Extracting only the measurements on the mean and standart deviation 
# for each measurment

X_test = X_test[, extract_features]

# Loading activity labels
Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Binding data
test_data <- cbind(as.data.table(subject_test), Y_test, X_test)

# Merging test and training data
merge_data = rbindlist(list(test_data, train_data))

id_labels = c("subject", "Activity_ID", "Activity_Label")
data_label = setdiff(colnames(merge_data), id_labels)
melt_data = melt(merge_data, id = id_labels, measure.vars = data_label)

# Apply mean function to dataset using dcast function
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "tidy_data.txt")
