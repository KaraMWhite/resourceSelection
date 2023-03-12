#load packages
library(DBI)
library(dplyr)

#connect to database
skunks_db <- dbConnect(RSQLite::SQLite(), "C:/Users/Kara.White/Documents/PhD/resourceSelection/data/skunks.db")

#create skunk table & enforce relationships
dbExecute(skunks_db, "CREATE TABLE skunks (
skunk_id varchar(10) NOT NULL,
sex char(1) CHECK (sex IN ('M', 'F')),
age_class varchar(8) CHECK (age_class IN ('juvenile', 'subadult', 'adult')),
PRIMARY KEY (skunk_id)
);")

#read in skunks csv
skunks <- read.csv("C:/Users/Kara.White/Documents/PhD/resourceSelection/data/skunks.csv", stringsAsFactors = F)
names(skunks) #check column names

#add data from csv into skunks tables
dbWriteTable(skunks_db, "skunks", skunks, append = T)

#check data was inserted correctly
dbGetQuery(skunks_db, "SELECT * FROM skunks LIMIT 10;")

#create capture sites table
dbExecute(skunks_db, "CREATE TABLE capture_sites (
site varchar(7) NOT NULL PRIMARY KEY,
utm_x double,
utm_y double
);")

#read in capture sites csv
capture_sites <- read.csv("C:/Users/Kara.White/Documents/PhD/resourceSelection/data/capture_sites.csv", stringsAsFactors = F)
names(capture_sites) #check column names

#add data from csv into capture_sites table
dbWriteTable(skunks_db, "capture_sites", capture_sites, append = T)

#check data was inserted correctly
dbGetQuery(skunks_db, "SELECT * FROM capture_sites LIMIT 10;")

#create captures table
dbExecute(skunks_db, "CREATE TABLE captures (
capture_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(10),
date text,
site varchar(7),
FOREIGN KEY(skunk_id) REFERENCES skunks(skunks_id)
FOREIGN KEY(site) REFERENCES capture_sites(site)
);")

#read in captures csv
captures <- read.csv("C:/Users/Kara.White/Documents/PhD/resourceSelection/data/captures.csv", stringsAsFactors = F)
captures$capture_id <- 1:nrow(captures) #add column
head(captures, 2) #check column added
captures <- captures[, c("capture_id", "skunk_id", "date", "site")] #reorder columns

#append df to db table
dbWriteTable(skunks_db, "captures", captures, append = T)

#check data was inserted correctly
dbGetQuery(skunks_db, "SELECT * FROM captures LIMIT 10;")

#create biometrics table
dbExecute(skunks_db, "CREATE TABLE biometrics (
measurement_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(8),
date text,
reproductive_status char(20),
weight_g float,
ear_nose_mm float,
left_ear_mm float,
right_hindfoot_mm float,
head_mm float,
body_mm float,
tail_mm float,
neck_mm float,
temperature_F float,
pulse_per_min float,
respiration_per_min float,
eye_condition char(10),
teeth_condition varchar(10),
FOREIGN KEY (skunk_id) REFERENCES skunks(skunk_id)
);")

#read in csv
biometrics <- read.csv("C:/Users/Kara.White/Documents/PhD/resourceSelection/data/biometrics.csv", stringsAsFactors = F)
biometrics$measurement_id <- 1:nrow(biometrics) #add column
head(biometrics, 2) #check column added
biometrics <- biometrics %>% select(measurement_id, everything()) #reorder columns
head(biometrics, 2) #check columns are re-ordered

#append df to db table
dbWriteTable(skunks_db, "biometrics", biometrics, append = T)

#check data was inserted correctly
dbGetQuery(skunks_db, "SELECT * FROM biometrics LIMIT 10;")

#create biological samples table
dbExecute(skunks_db, "CREATE TABLE biological_samples (
sample_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(8),
date text,
hair char(1) CHECK (hair IN ('Y', 'N')),
ear_snip char(1) CHECK (ear_snip IN ('Y', 'N')),
scat char(1) CHECK (scat IN ('Y', 'N')),
parasites char(1) CHECK (parasites IN ('Y', 'N')),
FOREIGN KEY (skunk_id) REFERENCES skunks(skunk_id)
);")

#read in csv
biological_samples <- read.csv("C:/Users/Kara.White/Documents/PhD/resourceSelection/data/samples.csv", stringsAsFactors = F)
biological_samples$sample_id <- 1:nrow(biological_samples) #add column
head(biological_samples, 2) #check column added
biological_samples <- biological_samples %>% select(sample_id, everything()) #reorder columns
head(biological_samples, 2) #check columns are re-ordered

#append df to db table
dbWriteTable(skunks_db, "biological_samples", biological_samples, append = T)

#check data was inserted correctly
dbGetQuery(skunks_db, "SELECT * FROM biological_samples LIMIT 10;")

#create tags table
dbExecute(skunks_db, "CREATE TABLE tags (
tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(8),
ear_left char(3),
ear_right char(3),
collar_id varchar(10),
collar_type char(3),
FOREIGN KEY (skunk_id) REFERENCES skunks(skunk_id)
);")

#create deployments table
dbExecute(skunks_db, "CREATE TABLE deployments (
deployment_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(8),
collar_id varchar(10),
start_date text,
end_date text,
FOREIGN KEY (skunk_id) REFERENCES skunks(skunk_id)
FOREIGN KEY (collar_id) REFERENCES tags(collar_id)
);")

#create gps_data_raw table
dbExecute(skunks_db, "CREATE TABLE gps_data_raw (
gps_id INTEGER PRIMARY KEY AUTOINCREMENT,
collar_id varchar(10),
date text,
time_24hr text,
utm_x double,
utm_y double,
hdop double,
FOREIGN KEY(collar_id) REFERENCES tags(collar_id)
);")

#create vhf_data_raw table
dbExecute(skunks_db, "CREATE TABLE vhf_data_raw (
vhf_id INTEGER PRIMARY KEY AUTOINCREMENT,
collar_id varchar(10),
date text,
time_24hr text,
utm_x double,
utm_y double,
error_ellipse_m2 double,
FOREIGN KEY(collar_id) REFERENCES tags(collar_id)
);")

#create location data table
dbExecute(skunks_db, "CREATE TABLE location_data (
loc_id INTEGER PRIMARY KEY AUTOINCREMENT,
skunk_id varchar(8),
collar_id varchar(10),
date text,
time_24hr text,
utm_x double,
utm_y double,
FOREIGN KEY (skunk_id) REFERENCES skunks(skunk_id)
FOREIGN KEY(collar_id) REFERENCES tags(collar_id)
);")