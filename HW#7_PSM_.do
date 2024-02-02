*************HW 7*******************
********Causal Inference************
*******Propensity Score Matching****



use "https://github.com/rabdulah85/assignment/raw/main/hw7_psm.dta", clear


**Data Description******
*Source : National Social Economic Survey (SUSENAS 2020) 
*Unit Analysis : Household, Central Java, Indonesia 


/***List of Variable***** 

Treatment/Policy
1.food_assistance : 1 = received food assistance program, 0 = 1 = received food assistance program

Outcome
2.food_score : 1 = consume below 2100 caloric, and 0 = consume above 2100 caloric

Covariates
3.caloric_cap = caloric intake per capita in a month

4.house_size : size of home, 1 =<8 m square, 0 > 8 m square

5.kks : Family Social Assistance, 1 + receive, 0 = otherwise (r2202)

6.expend : household expenditure (in IDR)*/


***************
*-------------*
***************
**Step 1 Model Logit
logit food_assistance food_score house_size kks expend food, robust


*Step 2 Balancing Test to meet CIA (Conditional Independence Assumption) ##1
logit food_assistance food_score house_size kks expend food 
pscore food_assistance food_score house_size kks expend food, pscore(myscore) logit

*the balancing test result is not satisfied

*Step 2 Balancing Test ##2
drop myscore
logit food_assistance food_score house_size kks expend 
pscore food_assistance food_score house_size kks expend, pscore(myscore) logit

*the balancing test result is not satisfied

*Step 2 Balancing Test ##3
drop myscore
logit food_assistance food_score house_size kks, ro 
pscore food_assistance food_score house_size kks, pscore(myscore) logit

*the balancing test result is satisfied, meet with CIA (Conditional Independence Assumption)


**Step 3 Estimation 
*a Impact of Food Assisstance Program to into food score
logit food_assistance food_score house_wall kks 
predict p
psmatch2 food_assistance, kernel outcome(food_score) pscore(p) k(normal)common

kdensity _pscore, normal


log close
