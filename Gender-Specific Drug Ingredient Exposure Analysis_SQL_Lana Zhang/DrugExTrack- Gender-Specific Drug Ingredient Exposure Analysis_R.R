# Data cleaning
data <- read.csv("data.csv")
data$patients_gender <- as.factor(data$patients_gender)
data$ingredients_num <- as.numeric(data$ingredients_num)
male_data <- subset(data, patients_gender == "Male")$ingredients_num
female_data <- subset(data, patients_gender == "Female")$ingredients_num

# Conduct one-tailed t-test
t_test_result <- t.test(female_data, male_data, alternative = "greater")

# Print the result
print(t_test_result)
if (t_test_result$p.value < 0.05) {
  print("Reject the null hypothesis: Female patients have significantly higher drug exposure than males.")
} else {
  print("Fail to reject the null hypothesis: No significant difference in drug exposure between genders.")
}