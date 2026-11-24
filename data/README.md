# Data

The four source tables were provided by the module team for the coursework and are not redistributed here. They describe a fictional insurance company.

| Table | Grain | Key fields |
|---|---|---|
| **Customer** | One row per customer | `CustomerID` (PK), Title, GivenName, MiddleInitial, Surname, CardType, Occupation, Gender, Age, Location (Rural/Urban), ComChannel (SMS/Email/Phone), `MotorID`, `HealthID`, `TravelID` (FKs) |
| **Motor Policies** | One row per motor policy | `MotorID` (PK), PolicyStart, PolicyEnd, MotorType (Single/Bundle), veh_value, Exposure (0–1), clm, Numclaims, v_body, v_age (1–4), LastClaimDate |
| **Health Policies** | One row per health policy | `HealthID` (PK), policyStart, policyEnd, HealthType (Level1–3), HealthDependentsAdults, DependentsKids |
| **Travel Policies** | One row per travel policy | `TravelID` (PK), policyStart, policyEnd, TravelType (Backpacker/Senior/Business/Premium/Standard) |

**Analytics Base Table (ABT):** Customer LEFT JOIN Motor, Health and Travel gives **4,085 rows × 32 columns**, one row per customer. The table was exported from Access as `AnalyticsBaseTable.xlsx`, which `code/abt_analysis.R` reads.
