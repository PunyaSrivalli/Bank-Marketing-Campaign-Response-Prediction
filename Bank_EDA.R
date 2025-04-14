rm(list=ls())

setwd("directory_path")
library("data.table")
library("ggplot2")
library("psych")
library(dplyr)
library(Hmisc)

bank = fread(file = "bank_cleaned.csv",
                 na.strings = c("NA", ""), 
                 sep = "auto",
                 stringsAsFactors = FALSE,
                 data.table = TRUE
)
nrow(bank)
head(bank)
str(bank)
describe(bank)
#Delete the rows which column 'poutcome' contains 'other'
condition <- bank$poutcome != 'other'
bank <- bank[condition, , drop = FALSE]

#Replace 'unknown' values in 'job' and 'education' columns with 'other'
bank$job <- ifelse(bank$job == 'unknown', 'other', bank$job)
bank$education <- ifelse(bank$education == 'unknown', 'other', bank$education)

#dropping outliers in 'balance'
# Calculate mean of the 'balance' column
balance_mean <- mean(bank$balance)

# Calculate z-score for 'balance' column
bank$balance_outliers <- scale(bank$balance)

# Identify outliers based on z-score
condition1 <- abs(bank$balance_outliers) > 3
bank <- bank[!condition1, ]

# Remove the 'balance_outliers' column
bank <- subset(bank, select = -c(balance_outliers))

# Step 3: Change the unit of 'duration' from seconds to minutes
bank$duration = bank$duration/60
bank$duration = round(bank$duration, 2)
head(bank)
#########################################
#enumerate months
month_to_int <- function(month_name) {
  switch(month_name,
         "jan" = 1,
         "feb" = 2,
         "mar" = 3,
         "apr" = 4,
         "may" = 5,
         "jun" = 6,
         "jul" = 7,
         "aug" = 8,
         "sep" = 9,
         "oct" = 10,
         "nov" = 11,
         "dec" = 12,
         NA_integer_)
}

# Apply the function to create 'month_int' column
bank$month_int <- sapply(bank$month, month_to_int)



##########################################################################
#filtering
# Step 1: Drop rows that 'duration' < 5s
condition2 <- bank$duration < 5/60
bank <- bank[!condition2, , drop = FALSE]

#drop rows with education="other"
condition3 <- bank$education == "other"
bank <- bank[!condition3, ,drop=FALSE]




#######################################################################
##Visualizing 'age','balance'
dist_age_balance <- mfrow=c(1, 2)
par(mar=c(5, 4, 4, 2) + 0.1)

# Plot the distribution of age
ggplot(data = bank, aes(x = age)) +
  geom_histogram(fill = "indianred", color = "black", bins = 10) +
  labs(title = "The Distribution of Age", x = "Age")

# Plot the distribution of balance
ggplot(data = bank, aes(x = balance)) +
  geom_histogram(fill = "darkslategray", color = "black", bins = 10) +
  labs(title = "The Distribution of Balance", x = "Balance")

#Age vs Balance
ggplot(data = bank, aes(x = age, y = balance)) +
  geom_point(size = 1, color = "coral") +  # Change size, shape, and color
  labs(title = "The Relationship between Age and Balance",
       x = "Age", y = "Balance") +
  theme_minimal()

#######################################################################################
#The Relationship between the Number and Duration of Calls (with Response Result)

ggplot(data = bank, aes(x = duration, y = campaign, color = response)) +
  geom_point(alpha = 1) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "black", size = 1) +
    scale_color_manual(values = c( "yes" = "darkorange","no" = "darkolivegreen4")) +  # Customize colors
  labs(title = "The Relationship between the Number and Duration of Calls (with Response Result)",
       x = "Duration of Calls (Minutes)", y = "Number of Calls") +
  theme_minimal() 
#higher subscription when calls < 5

#######################################################################################
#age group-contacted-subscribed
bank$age_group <- cut(bank$age, breaks = c(0, 29, 39, 49, 59, Inf), labels = c("<30", "30-39", "40-49", "50-59", "60+"))

# Calculate count and percentage of contacted and subscribed for each age group
count_age_response <- table(bank$response, bank$age_group)
count_age_response_pct <- prop.table(count_age_response, margin = 2)

# Create DataFrame for analysis
age <- as.data.frame(table(bank$age_group))
names(age) <- c("age_group", "Count_Contacted")
age$Percentage_Contacted <- age$Count_Contacted * 100 / sum(age$Count_Contacted)
age$Percentage_Subscription <- count_age_response_pct["yes", ]
age$yes_within_contacted <- age$Percentage_Contacted*age$Percentage_Subscription

# Reorder age groups
age <- age[order(match(age$age_group, c("<30", "30-39", "40-49", "50-59", "60+"))), ]

#plot
ggplot(age, aes(x = age_group)) +
  geom_bar(aes(y = Percentage_Contacted, fill = "Percentage_Contacted"), stat = "identity", width = 0.5) +
  geom_bar(aes(y = yes_within_contacted, fill = "Yes_Within_Contacted"), stat = "identity", width = 0.5) +
  geom_text(aes(y = Percentage_Contacted, label = paste0(round(Percentage_Contacted, 2), "%")), 
            vjust = -0.5, size = 3, color = "black", fontface = "bold") +
  scale_fill_manual(values = c("Percentage_Contacted" = "lightblue3", "Yes_Within_Contacted" = "coral"), 
                    labels = c("Percentage Contacted", "Yes Within Contacted")) +
  labs(title = "Percentage Contacted and 'yes' Within Contacted by Age Group",
       x = "Age Group", y = "Percentage") +
  theme_minimal() +
  theme(legend.position = "top") +
  guides(fill = guide_legend(title = NULL))

#########################################################################################
#balance Vs contacted and subscribed
bank$balance_group <- cut(bank$balance, breaks = c(-Inf, 0, 1000, 5000, Inf),
                          labels = c("no balance", "low balance", "average balance", "high balance"))

# Calculate count and percentage of contacted and subscribed for each balance group
count_balance_response <- table(bank$response, bank$balance_group)
count_balance_response_pct <- prop.table(count_balance_response, margin = 2) 

# Create DataFrame for analysis
bal <- as.data.frame(table(bank$balance_group))
names(bal) <- c("balance_group", "Count_Contacted")
bal$Percentage_Contacted <- bal$Count_Contacted * 100 / sum(bal$Count_Contacted)
bal$Percentage_Subscription <- count_balance_response_pct["yes", ]
bal$Yes_Within_Contacted_balance <- bal$Percentage_Contacted * bal$Percentage_Subscription

# Reorder balance groups
bal <- bal[order(match(bal$balance_group, c("no balance", "low balance", "average balance", "high balance"))), ]
#plot
ggplot(bal, aes(x = balance_group)) +
  geom_bar(aes(y = Percentage_Contacted, fill = "Percentage_Contacted"), stat = "identity", width = 0.5) +
  geom_bar(aes(y = Yes_Within_Contacted_balance, fill = "Yes_Within_Contacted_balance"), stat = "identity", width = 0.5) +
  geom_text(aes(label = paste0(round(Percentage_Contacted, 2), "%"), y = Percentage_Contacted), 
            vjust = -0.5, size = 3, color = "black", fontface = "bold") +
  scale_fill_manual(values = c("Percentage_Contacted" = "lightblue3", "Yes_Within_Contacted_balance" = "darkblue"), 
                    labels = c("Percentage Contacted", "Yes Within Contacted")) +
  labs(title = "Percentage Contacted and 'Yes' Within Contacted by Balance Group",
       x = "Balance Group", y = "Percentage") +
  theme_minimal() +
  theme(legend.position = "top") +
  guides(fill = guide_legend(title = NULL))


#######################################################################################
#subscribed - job
#balance Vs contacted and subscribed

# Calculate count and percentage of contacted and subscribed for each balance group
count_job_response <- table(bank$response, bank$job)
count_job_response_pct <- prop.table(count_job_response, margin = 2) 

# Create DataFrame for analysis
job_data <- as.data.frame(table(bank$job))
names(job_data) <- c("job_group", "Count_Contacted")
job_data$Percentage_Contacted_job <- job_data$Count_Contacted * 100 / sum(job_data$Count_Contacted)
job_data$Percentage_Subscription <- count_job_response_pct["yes", ]
job_data$Yes_Within_Contacted_job <- job_data$Percentage_Contacted_job * job_data$Percentage_Subscription
#plot
ggplot(job_data, aes(x = job_group)) +
  geom_bar(aes(y = Percentage_Contacted_job, fill = "Percentage_Contacted"), stat = "identity", width = 0.5) +
  geom_bar(aes(y = Yes_Within_Contacted_job, fill = "Yes_Within_Contacted_job"), stat = "identity", width = 0.5) +
  geom_text(aes(label = paste0(round(Percentage_Contacted_job, 2), "%"), y = Percentage_Contacted_job), 
            hjust = -0.1, size = 3, color = "black", fontface = "bold") +  # Adjusted vjust value
  scale_fill_manual(values = c("Percentage_Contacted" = "lightblue3", "Yes_Within_Contacted_job" = "darkblue"), 
                    labels = c("Percentage Contacted", "Yes Within Contacted")) +
  labs(title = "Percentage Contacted and 'Yes' Within Contacted by Job Group",
       x = "Job Group", y = "Percentage") +
  theme_minimal() +
  theme(legend.position = "top") +
  guides(fill = guide_legend(title = NULL)) +
  coord_flip() 

##########################################################################################
head(bank)

