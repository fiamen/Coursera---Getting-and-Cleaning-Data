##########################################################################################################

## Coursera Getting and Cleaning Data Course Project
## Mario Fiamenghi
## 25/07/2014



# This script will perform steps in order to clean and organise data from  human activity reconition in smart phones
# This project is part of the course Getting and Cleaning Data course offered on line from www.coursera.org on Jully/2014

# The dataset has been download from:
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#A full description is available at the site bellow: 
#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones   

#Summary steps performed
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

##########################################################################################################


# 1 - Script to merge train and test dataset

library("data.table", lib.loc="~/R/win-library/3.0")

# reference to directories
path_train="C:/BI/R/coursera/q1/Project/UCI HAR Dataset/train"
path_test="C:/BI/R/coursera/q1/Project/UCI HAR Dataset/test"
path_merged="C:/BI/R/coursera/q1/Project/UCI HAR Dataset/merged"
path_merged_Inertial="C:/BI/R/coursera/q1/Project/UCI HAR Dataset/merged/Inertial Signals"

# Create merged directory if not exist
if(!file.exists(path_merged)){dir.create(path_merged)}
if(!file.exists(path_merged_Inertial)){dir.create(path_merged_Inertial)}


#Create the  list of files to be merged
file1=list.files(path=path_train,recursive=TRUE,full.name=TRUE)
file2=list.files(path=path_test,recursive=TRUE,full.name=TRUE)

#Names for the merged files
file=gsub("_train","",list.files(path=path_train,recursive=TRUE) )

setwd(path_merged)

for (i in 1:length(file1) ) 

  {
  
  temp1=read.table(file1[i])
  temp2=read.table(file2[i])
  TEMP=rbind(temp1,temp2)
  write.table(TEMP,file=file[i])  
 
   }

# removes temporary values
rm(file,file1,file2,i,path_merged,path_test,path_train,path_merged_Inertial)




# 2 - Extracts only the measurements on the mean and standard deviation for each measurement. 


# Read variable labels from file
var=read.table("../features.txt")


# Creates a table with all measures 
mes=read.table("./X.txt",col.names=var$V2)

# Extract only mean variables
xmean=mes[,grep("mean",names(mes))]

# Extract only standard deviation variables
xstd=mes[,grep("std",names(mes))]

# combine data with only mean and standard deviation
measures=cbind(xmean,xstd)


# Removes redundate data
rm(var,xmean,xstd,TEMP,mes,temp1,temp2)



# 3 - Uses descriptive activity names to name the activities in the data set


# Read list of activities  from file
activity=read.table("./y.txt",col.names="id")

# Read activities description labels
labels=read.table("../activity_labels.txt",col.name=c("id","label")) 

# Create a descritive list of activities
actdes=merge(activity,labels)

# Add descriptive list of activities above to table of measures
measures=cbind(actdes$label,measures)

# rename activity variable (column)
names(measures)[1]="activity"

# remove unecessry tables
rm(actdes,activity,labels)



# 4 -  Appropriately labels the data set with descriptive variable names. 

# transform all labels to lower case
names(measures)=tolower(names(measures))

# removes all "." from the labels
names(measures)=gsub("\\.","",names(measures))



# 5 - Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 


# include subject variable in the data
measures=cbind(read.table("./subject.txt"),measures)

# rename column name 
names(measures)[1]="subject"


# calculate mean for all variable
second=aggregate(measures[,3:ncol(measures)],list(subject=measures$subject, activity=measures$activity), mean)

# creates a new file path to save the final tables
path_tidy="../tidy"
if(!file.exists(path_tidy)){dir.create(path_tidy)}

# save first tidy table
write.table(measures,"../tidy/measures.txt")

# save second tidy table
write.table(second,"../tidy/second.txt")

