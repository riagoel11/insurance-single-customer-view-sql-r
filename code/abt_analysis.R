setwd("path/to/your/data")  # original line pointed to a personal Google Drive folder

#Importing Libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(psych)
library(tidyverse)
library(scales)

abt <- read_excel("AnalyticsBaseTable.xlsx")

#Checking for null values
colSums(is.na(abt))

#data quality checks#

#customerid
#title
#given name
#middle initial
#surname
#gender
abt <- abt %>%
  mutate(Gender = as.factor(Gender)) %>%
  mutate(Gender = fct_recode(Gender, "female" = "f", "male" = "m")) %>%
  mutate(Gender = fct_drop(Gender))

#age
hist(abt$Age)
abt <- abt %>%
  mutate(Age = ifelse(Age > 105 | Age < 18, NA, Age))
abt <- abt %>%
  filter(!(is.na(Age)))

#location
abt <- abt %>%
  mutate(Location = as.factor(Location))
table(abt$Location)

#occupation
table(abt$Occupation)
summary(abt$Occupation)

#communication
table(abt$ComChannel)
abt <- abt %>%
  mutate(ComChannel = as.factor(ComChannel)) %>%
  mutate(ComChannel = fct_recode(ComChannel,
                                 "Email" = "E",
                                 "Phone" = "P",
                                 "SMS"    = "S")) %>%
  mutate(ComChannel = fct_drop(ComChannel))

#cardtype
table(abt$CardType)
abt <- abt %>%
  mutate(CardType = as.character(CardType)) %>%
  mutate(CardType = ifelse(CardType == "0", "Neither", CardType)) %>%
  mutate(CardType = as.factor(CardType))
table(abt$CardType)

#Motor

#motorid
#motorpolicystart
#motorpolicyend

#motortype
table(abt$MotorType)
abt <- abt %>%
  mutate(MotorType = as.factor(MotorType))

#veh_value
hist(abt$veh_value)

#exposure
hist(abt$Exposure)

#claim
table(abt$clm)
abt <- abt %>%
  mutate(clm = as.factor(clm))

#numclaims
hist(abt$Numclaims)
abt <- abt %>%
  mutate(Numclaims = as.integer(Numclaims))
#vbody
table(abt$v_body)
abt <- abt %>%
  mutate(v_body = as.factor(v_body))

#vage
hist(abt$v_age)
abt <- abt %>%
  mutate(v_age = as.factor(v_age))

#LastClaimDate
summary(abt$LastClaimDate)
abt <- abt %>%
  mutate(LastClaimDate = as.Date(LastClaimDate))

#Health

#Healthid
#healthpolicystart
#healthpolivyend

#HealthType = Factor
abt <- abt %>%
  mutate(HealthType = as.factor(HealthType))
table

#dependent_adults
hist(abt$HealthDependentsAdults)
abt <- abt %>%
  mutate(HealthDependentsAdults = as.factor(HealthDependentsAdults))

#dependent_kids
hist(abt$DependentsKids)
summary(abt$DependentsKids)
abt <- abt %>%
  mutate(DependentsKids = ifelse(DependentsKids>10, NA, DependentsKids))
abt <- abt %>%
  mutate(DependentsKids = as.factor(DependentsKids))

#Travel

#Travelid
#travelpolicystart
#travelpolicyend
#traveltype
table(abt$TravelType)
abt <- abt %>%
  mutate(TravelType = as.factor(TravelType))

#data analysis

# Prepare data for all products at once
all_products_long <- abt %>%
  select(Age, Location, ComChannel, MotorType, HealthType, TravelType) %>%
  pivot_longer(cols = ends_with("Type"), names_to = "Product_Category", values_to = "Policy_Status") %>%
  filter(!is.na(Policy_Status))

#Age distribution of customer across location grouped by insurance type
ggplot(all_products_long, aes(x = Location, y = Age, fill = Location)) +
  geom_boxplot() +
  facet_wrap(~Product_Category) +
  # This creates the 3 separate panels
  labs(title = "Customer Profile Comparison Across All Insurance Lines",) +
  theme_minimal()

# Age distribution
ggplot(abt, aes(x = ComChannel, y = Age)) +
  geom_boxplot() +
  theme_minimal() +
  labs(
    title = "Age Distribution by Communication Channel",
    x = "Communication Channel",
    y = "Age"
 )

#Product ownership ad cross sell potential
abt <- abt %>%
  mutate(
     NumProducts =
       (!is.na(MotorID)) +
       (!is.na(HealthID)) +
       (!is.na(TravelID))
  )

# Multi-product rate
#Stacked bar graph for proportion of customers for multiple products and single product contacted via different communication channel
abt %>%
  mutate(ProductGroup = if_else(NumProducts >= 2,
                                 "Multi-product",
                                 "Single-product")) %>%
  count(ComChannel, ProductGroup) %>%
  group_by(ComChannel) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = ComChannel, y = prop, fill = ProductGroup)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal() +
  labs(
     title = "Single vs Multi-Product Customers by Communication Channel",
     x = "Communication Channel",
     y = "Proportion of Customers",
     fill = "Customer Type"
  )

###risk and claim behaviour
motor_abt <- abt %>% filter(!(is.na(MotorID)))

# Claimant rate
motor_abt %>%
  group_by(ComChannel) %>%
  summarise(ClaimantRate = mean(Numclaims > 0, na.rm = TRUE)) %>%
  ggplot(aes(x = ComChannel, y = ClaimantRate)) +
  geom_col() +
  scale_y_continuous(labels = percent) +
  theme_minimal() +
  labs(
     title = "Claimant Rate by Communication Channel",
     y = "Claimant Rate"
  )

#Claim count distribution by communication channel
motor_abt %>%
   count(ComChannel, Numclaims) %>%
   group_by(ComChannel) %>%
  mutate(prop = n / sum(n)) %>%
   ggplot(aes(x = ComChannel,
                y = prop,
                fill = factor(Numclaims))) +
   geom_col(position = "dodge") +
   scale_y_continuous(labels = scales::percent) +
   theme_minimal() +
   labs(
      title = "Distribution of Claim Counts by Communication Channel",
      y = "Proportion of Motor Customers",
      fill = "Number of Claims"
   )

motor_abt <- abt %>%
   filter(!(is.na(MotorID))) %>%
   mutate(
      ClaimsPerExposure = if_else(
         !is.na(Exposure) & Exposure > 0,
         Numclaims / Exposure,
         NA_real_
      )
   )

#customers with high claim rate against communication channel
motor_abt %>%
   group_by(ComChannel) %>%
   summarise(
      ClaimantRate = mean(Numclaims > 0, na.rm = TRUE)
   ) %>%
   ggplot(aes(x = ComChannel, y = ClaimantRate)) +
   geom_col() +
   scale_y_continuous(labels = scales::percent) +
  theme_minimal() +
  labs(
     title = "Claimant Rate by Communication Channel",
     y = "Proportion of Customers with ≥1 Claim"
  )

#Evaluation of top 10 high claiming customers
high_risk_customers <- motor_abt %>%
  filter(!is.na(ClaimsPerExposure) & ClaimsPerExposure > 1) %>%
  select(
    CustomerID,
    ComChannel,
   Numclaims,
    Exposure,
    ClaimsPerExposure,
    veh_value,
    v_age
  ) %>%
  arrange(desc(ClaimsPerExposure))
high_risk_customers<-high_risk_customers[c(1,2,3,4,5,6,7,8,9,10), ] ##list

##health dependents
#multivaroate relationhips

###Heatmap

#Heat map of Insurance uptake rate vs communication channel
abt %>%
  mutate(
    Motor = ifelse(!is.na(MotorID), 1, 0),
    Health = ifelse(!is.na(HealthID), 1, 0),
    Travel = ifelse(!is.na(TravelID), 1, 0)
  ) %>%
  group_by(ComChannel) %>%
  summarise(
    Motor = mean(Motor),
    Health = mean(Health),
    Travel = mean(Travel),
    .groups = "drop"
  ) %>%
  pivot_longer(-ComChannel,
                names_to = "Policy",
                values_to = "UptakeRate") %>%
  ggplot(aes(x = Policy, y = ComChannel, fill = UptakeRate)) +
  geom_tile() +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(
     title = "Insurance Uptake Rate by Communication Channel",
     x = "Policy Type",
     y = "Communication Channel",
     fill = "Uptake Rate"
  )
###Travel Insurance Type by age

abt %>%
  filter(!is.na(TravelType), !is.na(Age)) %>%
  group_by(TravelType) %>%
  summarise(
     Avg_Age = mean(Age),
     .groups = "drop"
  ) %>%
  ggplot(aes(x = TravelType, y = Avg_Age, fill = TravelType)) +
  geom_col() +
  theme_minimal() +
  labs(
     title = "Average Customer Age by Travel Insurance Type",
     x = "Travel Type",
     y = "Average Age",
     fill = "Travel Type"
  )

###Health Insurance Type vs Average age

abt %>%
  filter(!is.na(HealthType), !is.na(Age)) %>%
  group_by(HealthType) %>%
  summarise(
     Avg_Age = mean(Age),
     .groups = "drop"
  ) %>%
  ggplot(aes(x = HealthType, y = Avg_Age, fill = HealthType)) +
  geom_col() +
  theme_minimal() +
  labs(
     title = "Average Customer Age by Health Insurance Type",
     x = "Health Insurance Type",
     y = "Average Age",
     fill = "Health Type"
  )

###Density of dependent adults against age

abt %>%
  filter(!is.na(Age), !is.na(HealthDependentsAdults)) %>%
  mutate(
     HealthDependentsAdults = factor(HealthDependentsAdults)
  ) %>%
  ggplot(aes(x = Age, fill = HealthDependentsAdults)) +
  geom_density(alpha = 0.5) +
  theme_minimal() +
  labs(
     title = "Age Density by Number of Adult Health Dependents",
     x = "Age",
     y = "Density",
     fill = "Adult Health Dependents"
  )

###Density of dependent kids with age

abt %>%
  filter(!is.na(Age), !is.na(DependentsKids)) %>%
  mutate(
     DependentsKids = factor(DependentsKids)
  ) %>%
  ggplot(aes(x = Age, fill = DependentsKids)) +
  geom_density(alpha = 0.5) +
  theme_minimal() +
  labs(
     title = "Age Density by Number of Dependent Kids",
     x = "Age",
     y = "Density",
     fill = "Dependent Kids"
  )

###Density of Number of claims by age

abt %>%
   filter(!is.na(Age), !is.na(Numclaims)) %>%
   mutate(Numclaims = factor(Numclaims)) %>%
   ggplot(aes(x = Age, fill = Numclaims)) +
   geom_density(alpha = 0.5) +
   theme_minimal() +
   labs(
      title = "Age Density by Number of Claims",
      x = "Age",
      y = "Density",
      fill = "Number of Claims"
   )

###Numerical Analysis

#CATEGORICAL VS CATEGORICAL
# Motor and Age
chisq.test(table(ifelse(is.na(abt$MotorID), "No", "Yes"),
                   abt$ComChannel))

# Health and Age
chisq.test(table(ifelse(is.na(abt$HealthID), "No", "Yes"),
                   abt$ComChannel))

# Travel and Age
chisq.test(table(ifelse(is.na(abt$TravelID), "No", "Yes"),
                   abt$ComChannel))

#NUMERIC X CATEGORICAL

# Health and Age
t.test(
   Age ~ !is.na(HealthID),
   data = abt
)

#Motor and Age
t.test(
   Age ~ !is.na(MotorID),
   data = abt
)

#Travel and Age
t.test(
   Age ~ !is.na(TravelID),
   data = abt
)
