# Inlude required packages
library( dplyr )

# Read all relevant data files
features        <- read.table( "UCI HAR Dataset\\features.txt"             )
activity_labels <- read.table( "UCI HAR Dataset\\activity_labels.txt"      )
subject_train   <- read.table( "UCI HAR Dataset\\train\\subject_train.txt" )
x_train         <- read.table( "UCI HAR Dataset\\train\\X_train.txt"       )
y_train         <- read.table( "UCI HAR Dataset\\train\\y_train.txt"       )
subject_test    <- read.table( "UCI HAR Dataset\\test\\subject_test.txt"   )
x_test          <- read.table( "UCI HAR Dataset\\test\\X_test.txt"         )
y_test          <- read.table( "UCI HAR Dataset\\test\\y_test.txt"         )

# Assign column names for the two main data frames (x_train and x_test) based on the list of features
names( x_train ) <- make.names( features$V2, unique = TRUE )
names( x_test )  <- make.names( features$V2, unique = TRUE )

# Add subject and activity columns in the front of the data frames (activity names obtained by table lookup)
x_train <- cbind( Subject = subject_train$V1, Activity = sapply( y_train$V1, function( x ) activity_labels[ x, 2 ] ), x_train )
x_test  <- cbind( Subject = subject_test$V1,  Activity = sapply( y_test$V1,  function( x ) activity_labels[ x, 2 ] ), x_test  )

# Combine training and test data frames by row binding (both data frames have exactly the same columns)
comb <- rbind( x_train, x_test )

# Keep only the mean and standard deviation feature columns 
comb_ms <- select( comb, matches("Activity|Subject|\\.mean\\.|\\.std\\."))

# Rename columns to have more descriptive variable names
names( comb_ms ) <- gsub( "\\.mean\\.\\.\\.X", "XMean", names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.mean\\.\\.\\.Y", "YMean", names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.mean\\.\\.\\.Z", "ZMean", names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.std\\.\\.\\.X",  "XStd",  names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.std\\.\\.\\.Y",  "YStd",  names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.std\\.\\.\\.Z",  "ZStd",  names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.mean\\.\\.",     "Mean",  names( comb_ms ) )
names( comb_ms ) <- gsub( "\\.std\\.\\.",      "Std",   names( comb_ms ) )
names( comb_ms ) <- gsub( "^t",                "Time",  names( comb_ms ) )
names( comb_ms ) <- gsub( "^f",                "Freq",  names( comb_ms ) )

# Group the data frame by Subject and Activity
comb_ms_grp <- group_by( comb_ms, Subject, Activity )

# Generate the final tidy data set by calculating averages grouped by each subject and activity
tidy <- summarize_each( comb_ms_grp, funs( mean ) )

# Correct grammar in activty names
tidy$Activity <- gsub( "LAYING", "LYING", tidy$Activity )

# Save final data frame
save( tidy, file = "tidy.Rdata" )
write.csv( tidy, file = "tidy.csv", row.names = FALSE )
write.table( tidy, file = "tidy.txt", row.names = FALSE )

