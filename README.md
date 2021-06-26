# AzureDeveloperLeageHack2021


Objective: 

In multiple projects, we have seen the requirement to impose rules on the storage account to move files from costly tiers to cheaper tiers. We are only able to move blobs older than specific days. Even with filters option, we can only check files with specific prefixes and keys. Along with this, just one wrong file movement can lead to many failures in downstream pipelines. So, we are thinking about the scenarios where we can impose similar kind of rules with last access time instead of last modified time. 

We thought of building this functionality with more customizable filters for customers using which they can move files easily with more confidence. Along with this, we came up with a model driven approach which can consider the file usage pattern to predict file inactivity more reliably. Our tool "Azure Storage Optimizer" will allow customers to 
--> perform analysis on their storage with wide variety of metrics like total number of files present in an account, number of files by tiers (Hot Cool, Archive), growth of the storage size by time and many more.... 
—> filter the files accessed and modified in specified date range according to their needs and move rarely accessed files from one tier to another (example from Hot tier to Archive tier). 
--> perform predictive analysis to figure out active and inactive files based on historical usage trend of files 


Implementation: 

Microsoft has released a feature which provides us latest access time of any blob in our storage account. Using Microsoft's Get Blob APIs, we will fetch the last access time of all blobs along with some other metadata. We will create Hap Trigger and Time Trigger Azure Functions which will extract the metadata of all blobs based on required frequency (daily, weekly, monthly, etc.) and store it into Azure SQL Database. Then, we will run our prediction model to calculate the probability of every file to become inactive in next N days/weeks/months and store all of these predictions into our Azure SQL Database itself. 

For end user, we will build Power BI report on top of the fetched and predicted data using which they will be able to perform analytics. We will also develop a web app with this Power 131 report as embedded into the app and users will be able to move files from costlier to cheap tires based on their filter selection and a click of a button which would pass the selected filters as a parameter to Set Blob API's to perform tier movement operations. We can also store these filters information and automate this movement daily (if needed). 


Constraints: 

The feature to get last access time is in preview state and only available in France Central, Canada East, and Canada Central regions. 


Business Cases: 

Based on our analysis using synthetic data, we believe that it model based approach will give us 3-X saving as compared to rule based approach which is currently offered by Azure. Along with this, it will give an additional value to customers who have files with very large sizes because we are only consuming metadata of the file and tracking its usage pattern to calculate its in-activeness in coming future.
